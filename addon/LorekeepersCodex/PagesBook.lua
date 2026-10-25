-- The Pages tab: on the left, the codex at a glance, then the chapters and
-- the pages found in them (a chapter's bar and count tell how many are left;
-- a click on its title folds it away or opens it; a search finds the pages
-- found by their words); on the right, the open page (the kit's): its title,
-- its chapter and kind, a round picture (for a figure, a creature or a
-- faction, the game's still portrait of it; a calling's class icon; else an
-- icon of its kind), the text, where and when it was found, and the related
-- pages found as cards. The codex at a glance: its figures, the pages found
-- lately, the chapters opened to pick.
local _, ns = ...
local L = ns.kit.L
local C = ns.content
local ui = ns.ui
local T, TITLE_FONT, BODY_FONT, KINDS = ui.T, ui.TITLE_FONT, ui.BODY_FONT, ui.KINDS
local OVERVIEW = "overview" -- (the codex at a glance, in place of a page)

local chapterTitle = {}
for _, ch in ipairs(C.chapters) do
  chapterTitle[ch.id] = ch.title
end

local book, list, page
local current

-- ── the open page ────────────────────────────────────────────────────────────
-- What a page is, in a line: its chapter and its kind.
local function aboutPage(e)
  local kind = KINDS[e.kind] or KINDS.note
  local chapter = e.chapter ~= "" and chapterTitle[e.chapter]
  return chapter and (chapter .. "  -  " .. kind) or kind
end

-- Where and when this character found it (found by looking back: since when
-- the codex holds it).
local function foundLine(rec)
  if rec.retro then return L["In your codex since %s, at level %d."]:format(ui.day(rec.at), rec.level or 0) end
  local zone, sub = ns.placeNames(rec)
  local where = zone or "?"
  if sub then where = sub .. ", " .. where end
  return L["Found in %s, at level %d, on %s."]:format(where, rec.level or 0, ui.day(rec.at))
end

local showOverview
local function showPage(id)
  if id == OVERVIEW then return showOverview() end
  current = id
  local e = C.entries[id]
  if not e or not ns.page(id) then return end
  ns.markRead(id)
  page:start(e.title, aboutPage(e), ns.pictureOf(e))
  local paras = {}
  for _, para in ipairs(e.text) do
    -- (an aside: Parqual's note, set apart by the kit's page)
    if ns.shown(para) then table.insert(paras, para.aside and para or para[1]) end
  end
  page:text(paras)
  page:paragraph(foundLine(ns.page(id)), T.soft)

  -- "See also": the related pages this character has found, as cards.
  local also = {}
  for _, other in ipairs(e.also) do
    if ns.page(other) then table.insert(also, other) end
  end
  if #also > 0 then
    page:section(L["See also"])
    for _, other in ipairs(also) do
      local o = C.entries[other]
      page:card(o.title, aboutPage(o), ns.pictureOf(o, true), function()
        showPage(other)
        ns.refresh(true)
      end)
    end
  end
  page:finish()
end

-- ── the codex at a glance ────────────────────────────────────────────────────
-- Its figures, the pages found lately (not those looked back on), the
-- chapters opened, to pick.
local LATELY = 5
function showOverview()
  current = OVERVIEW
  page:start(L["The Codex"], L["%d of %d pages found"]:format(ns.count(), ns.knownTotal()), ui.icon(ui.BOOK))
  local opened, unread, recent = {}, 0, {}
  for _, ch in ipairs(C.chapters) do
    if ns.found(ch) > 0 then table.insert(opened, ch) end
  end
  for id, e in pairs(C.entries) do
    local rec = ns.page(id)
    if rec then
      if not ns.isRead(id) then unread = unread + 1 end
      if not rec.retro then table.insert(recent, { id = id, e = e, at = rec.at or 0 }) end
    end
  end
  table.sort(recent, function(a, b)
    if a.at ~= b.at then return a.at > b.at end
    return a.e.title < b.e.title
  end)
  page:stats({
    { tostring(ns.count()), L["pages found"] },
    { tostring(#opened), ns.kit.plural(#opened, "chapter", "chapters") },
    { tostring(unread), L["unread"] },
    { tostring(ns.libraryCount()), L["library texts"] },
  })
  if #recent > 0 then
    page:section(L["Found lately"])
    for i = 1, math.min(LATELY, #recent) do
      local r = recent[i]
      page:card(r.e.title, ("%s  -  %s"):format(aboutPage(r.e), ui.day(r.at)), ns.pictureOf(r.e, true), function()
        showPage(r.id)
        ns.refresh(true)
      end)
    end
  end
  if #opened > 0 then
    page:section(L["The chapters"])
    local chips = {}
    for _, ch in ipairs(opened) do
      table.insert(chips, {
        ("%s  %d/%d"):format(ch.title, ns.found(ch), #ch.entries),
        function()
          -- (its first page found, its chapter open)
          for _, id in ipairs(ch.entries) do
            if ns.page(id) then
              showPage(id)
              return ns.refresh(true)
            end
          end
        end,
      })
    end
    page:chips(chips)
  end
  page:finish()
end

-- ── the list of chapters and pages ───────────────────────────────────────────
local rows = {}
ns.listRows = rows -- for the tests
local function row(i)
  local r = rows[i]
  if r then return r end
  r = ui.listRow(list.child)
  r.text:SetPoint("RIGHT", -4, 0)
  -- A chapter's fold: the plus and minus of the game's own lists.
  r.fold:SetPoint("TOPLEFT", 2, -4)
  -- A chapter's progress, under its title: a bar, then the pages found.
  r.bar = ui.bar(r)
  r.bar:SetPoint("BOTTOMLEFT", 18, 4)
  r.bar:SetPoint("BOTTOMRIGHT", -44, 4)
  r.bar:SetHeight(4)
  r.count:SetPoint("LEFT", r.bar, "RIGHT", 6, 0)
  rows[i] = r
  return r
end

-- Pages found in a chapter.
function ns.found(ch)
  local n = 0
  for _, id in ipairs(ch.entries) do
    if ns.page(id) then n = n + 1 end
  end
  return n
end

-- Search: the pages this character has found whose title or text holds the
-- query (never locked ones: no spoilers). Text is lowered once, on first use.
-- The kit's plain words: lowercase beyond ASCII, accents and curly
-- apostrophes aside (typed or pasted).
local plain = ns.kit.plain
local haystack = {}
local function matches(id, query)
  if not haystack[id] then
    local e = C.entries[id]
    local parts = { e.title }
    for _, para in ipairs(e.text) do
      if ns.shown(para) then table.insert(parts, para[1]) end
    end
    haystack[id] = plain(table.concat(parts, " "))
  end
  return haystack[id]:find(query, 1, true) ~= nil
end

function ns.search(query)
  local out = {}
  query = plain(query or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if query == "" then return out end
  for _, ch in ipairs(C.chapters) do
    for _, id in ipairs(ch.entries) do
      if ns.page(id) and matches(id, query) then table.insert(out, id) end
    end
  end
  for id, e in pairs(C.entries) do
    if e.chapter == "" and ns.page(id) and matches(id, query) then table.insert(out, 1, id) end
  end
  return out
end

-- Scroll the list so the open page's row shows, in the middle if it was out
-- of sight. The scroll range is worked out here: the frame's own may not have
-- caught up with the list's new height yet.
local function reveal(y)
  local height = list:GetHeight()
  local top = list:GetVerticalScroll()
  if y >= top and y + 18 <= top + height then return end
  local max = math.max(0, list.child:GetHeight() - height)
  list:SetVerticalScroll(math.min(max, math.max(0, y - (height - 18) / 2)))
  list:UpdateThumb()
end

-- Folded chapters, per character (each codex opens its own chapters).
local function folded()
  local c = LorekeepersCodexChar
  if not c then return {} end
  c.collapsed = c.collapsed or {}
  return c.collapsed
end

-- The chapters in the list (those with a page found): is any open? Fold or
-- unfold them all.
function ns.anyUnfolded()
  for _, ch in ipairs(C.chapters) do
    if ns.found(ch) > 0 and not folded()[ch.id] then return true end
  end
  return false
end

function ns.foldAll(fold)
  for _, ch in ipairs(C.chapters) do
    if ns.found(ch) > 0 then folded()[ch.id] = fold or nil end
  end
  ns.refresh()
end

local PLUS, MINUS = "Interface\\Buttons\\UI-PlusButton-Up", "Interface\\Buttons\\UI-MinusButton-Up"

-- scrollToCurrent: scroll to the open page (opening the book, a link, the banner).
local function refresh(scrollToCurrent)
  -- Going to a page (a link, the banner) unfolds its chapter.
  local e = scrollToCurrent and current and C.entries[current]
  if e and e.chapter ~= "" then folded()[e.chapter] = nil end
  local currentY
  book.count:SetText(L["%d of %d pages"]:format(ns.count(), ns.knownTotal()))
  book.foldAll:SetNormalTexture(ns.anyUnfolded() and MINUS or PLUS)
  for _, r in ipairs(rows) do
    r:Hide()
  end
  -- The select's kind of page ("": every one).
  local only = ns.filterOf(ns.TAB.pages) or ""
  local function fits(id) return only == "" or C.entries[id].kind == only end
  local i, y = 0, 0
  local function add(kind, text, id, found, total, chapter)
    i = i + 1
    local r = row(i)
    r:ClearAllPoints()
    r:SetPoint("TOPLEFT", 0, -y)
    r.id = id
    r.selected:Hide()
    r.count:SetText(kind == "chapter" and id or "")
    r.bar:SetShown(kind == "chapter")
    r.fold:SetShown(kind == "chapter")
    if kind == "overview" then
      r:SetHeight(22)
      r.text:ClearAllPoints()
      r.text:SetPoint("LEFT", 4, 0)
      r.text:SetPoint("RIGHT", -4, 0)
      r.text:SetFont(TITLE_FONT, 14, "")
      r.text:SetText(text)
      if current == OVERVIEW then
        currentY = y
        r.selected:Show()
        r.text:SetTextColor(1, 1, 1)
      else
        r.text:SetTextColor(unpack(T.gold))
      end
      r:Enable()
      r:SetScript("OnClick", function()
        showOverview()
        ns.refresh()
      end)
      y = y + 24
    elseif kind == "chapter" then
      r:SetHeight(32)
      r.text:ClearAllPoints()
      r.text:SetPoint("TOPLEFT", 18, -3)
      r.text:SetPoint("RIGHT", -4, 0)
      r.text:SetFont(TITLE_FONT, 14, "")
      r.text:SetTextColor(unpack(T.gold))
      r.text:SetText(text)
      r.bar:SetMinMaxValues(0, total)
      r.bar:SetValue(found)
      r.fold:SetTexture(folded()[chapter] and PLUS or MINUS)
      r:Enable()
      r:SetScript("OnClick", function()
        folded()[chapter] = not folded()[chapter] or nil
        ns.refresh()
      end)
      y = y + 34
    else
      r:SetHeight(18)
      r.text:ClearAllPoints()
      r.text:SetPoint("LEFT", 18, 0)
      r.text:SetPoint("RIGHT", -4, 0)
      r.text:SetFont(BODY_FONT, 12, "")
      if id == current then
        currentY = y
        r.selected:Show()
        r.text:SetTextColor(1, 1, 1)
      else
        r.text:SetTextColor(unpack(T.text))
      end
      r.text:SetText((ns.isRead(id) and "" or "|cffffd100•|r ") .. C.entries[id].title)
      r:Enable()
      r:SetScript("OnClick", function()
        showPage(id)
        ns.refresh()
      end)
      y = y + 18
    end
    r:Show()
  end
  local function finish()
    list.child:SetHeight(y + 8)
    list:UpdateThumb()
    if scrollToCurrent and currentY then reveal(currentY) end
  end
  -- While searching, the list is the results.
  local query = book.search and book.search:GetText() or ""
  if query:find("%S") then
    local results = {}
    for _, id in ipairs(ns.search(query)) do
      if fits(id) then table.insert(results, id) end
    end
    for _, id in ipairs(results) do
      add("page", nil, id)
    end
    if #results == 0 then
      i = i + 1
      local r = row(i)
      r:ClearAllPoints()
      r:SetPoint("TOPLEFT", 0, 0)
      r:SetHeight(18)
      r.selected:Hide()
      r.count:SetText("")
      r.bar:Hide()
      r.fold:Hide()
      r.text:ClearAllPoints()
      r.text:SetPoint("LEFT", 8, 0)
      r.text:SetPoint("RIGHT", -4, 0)
      r.text:SetFont(BODY_FONT, 12, "")
      r.text:SetTextColor(unpack(T.soft))
      r.text:SetText(L["No page found."])
      r:Disable()
      r:Show()
      y = 18
    end
    return finish()
  end
  -- The codex at a glance, the loose pages (the foreword), then each chapter.
  add("overview", L["The Codex"])
  for id, entry in pairs(C.entries) do
    if entry.chapter == "" and ns.page(id) and fits(id) then add("page", nil, id) end
  end
  -- A chapter appears once one of its pages is found, with its progress; one
  -- kind chosen, the chapters holding a page of it, open, with those alone.
  for _, ch in ipairs(C.chapters) do
    local found, kept = ns.found(ch), {}
    for _, id in ipairs(ch.entries) do
      if ns.page(id) and fits(id) then table.insert(kept, id) end
    end
    if found > 0 and #kept > 0 then
      y = y + 4
      add("chapter", ch.title, ("%d/%d"):format(found, #ch.entries), found, #ch.entries, ch.id)
      if only ~= "" or not folded()[ch.id] then
        for _, id in ipairs(kept) do
          add("page", nil, id)
        end
      end
    end
  end
  finish()
end

-- ── the tab ──────────────────────────────────────────────────────────────────
local function build(b)
  book = b
  -- Beside the search box, fold or unfold every chapter at once: a minus
  -- while any is open, a plus once all are folded.
  book.foldAll = CreateFrame("Button", "LorekeepersCodexFoldAll", book)
  book.foldAll:SetSize(16, 16)
  book.foldAll:SetPoint("LEFT", book.search, "RIGHT", 6, 0)
  book.foldAll:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
  local function tip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(ns.anyUnfolded() and L["Fold every chapter"] or L["Unfold every chapter"])
    GameTooltip:Show()
  end
  book.foldAll:SetScript("OnClick", function(self)
    ns.foldAll(ns.anyUnfolded())
    if GameTooltip:IsOwned(self) then tip(self) end
  end)
  book.foldAll:SetScript("OnEnter", tip)
  book.foldAll:SetScript("OnLeave", function() GameTooltip:Hide() end)

  list = ui.listArea("LorekeepersCodexList", book, true)
  page = ui.pageArea("LorekeepersCodexPage", book)
end

-- Shown: the open page, or on first opening an unread page, else the codex
-- at a glance.
local function show(n)
  book.foldAll:SetShown(n == ns.TAB.pages)
  list:SetShown(n == ns.TAB.pages)
  page:SetShown(n == ns.TAB.pages)
  if n ~= ns.TAB.pages then return end
  if current ~= OVERVIEW and (not current or not ns.page(current)) then
    current = OVERVIEW
    for id in pairs(C.entries) do
      if ns.page(id) and not ns.isRead(id) then
        current = id
        break
      end
    end
  end
  showPage(current)
end

-- The select's kinds: every one, or a kind of the pages found (with how
-- many), none not yet met.
local PLURAL = {
  place = L["Places"],
  figure = L["Figures"],
  faction = L["Factions and peoples"],
  creature = L["Creatures"],
  history = L["Histories"],
  note = L["Notes"],
  calling = L["Callings"],
}
local ORDER = { "place", "figure", "faction", "creature", "history", "calling", "note" }
local function kinds()
  local count = {}
  for id, e in pairs(C.entries) do
    if ns.page(id) then count[e.kind] = (count[e.kind] or 0) + 1 end
  end
  local out = { { value = "", text = L["Every kind of page"] } }
  for _, k in ipairs(ORDER) do
    if count[k] then table.insert(out, { value = k, text = ("%s (%d)"):format(PLURAL[k], count[k]) }) end
  end
  return out
end

ns.addTab(ns.TAB.pages, {
  build = build,
  show = show,
  refresh = refresh,
  filter = { default = "", options = kinds },
})

-- Open the book at a page (a click on a codex link in chat, the banner).
function ns.open(id)
  if not ns.page(id) then return end
  current = id
  ns.openTab(ns.TAB.pages)
end
