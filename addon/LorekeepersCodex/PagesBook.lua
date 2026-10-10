-- The Pages tab: on the left, the chapters and the pages found in them (a
-- chapter's bar and count tell how many are left; a click on its title folds
-- it away or opens it; a search finds the pages found by their words); on the
-- right, the open page: its title, its chapter and kind, a round picture (for
-- a figure, a creature or a faction, the game's still portrait of it; a
-- calling's class icon; else an icon of its kind), the text, and links to
-- related pages.
local _, ns = ...
local C = ns.content
local ui = ns.ui
local T, TITLE_FONT, BODY_FONT, WIDTH, HEADER_H, KINDS =
  ui.T, ui.TITLE_FONT, ui.BODY_FONT, ui.WIDTH, ui.HEADER_H, ui.KINDS
local label, rule = ui.label, ui.rule

local chapterTitle = {}
for _, ch in ipairs(C.chapters) do
  chapterTitle[ch.id] = ch.title
end

local book, list, page
local current

-- ── the open page ────────────────────────────────────────────────────────────
local function showPage(id)
  current = id
  local e = C.entries[id]
  if not e or not ns.page(id) then return end
  ns.markRead(id)
  local portrait = ns.pagePicture(page.icon, e)
  page.title:ClearAllPoints()
  if portrait then
    page.title:SetPoint("TOPLEFT", page.icon, "TOPRIGHT", 16, -4)
  else
    page.title:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -10)
  end
  page.title:SetWidth(portrait and WIDTH - 78 or WIDTH)
  page.sub:SetWidth(portrait and WIDTH - 78 or WIDTH)
  page.title:SetText(e.title)
  local kind = KINDS[e.kind] or KINDS.note
  local chapter = e.chapter ~= "" and chapterTitle[e.chapter]
  page.sub:SetText(chapter and (chapter .. "  -  " .. kind) or kind)
  local paras = {}
  for _, para in ipairs(e.text) do
    if not para.client or para.client == ns.client then table.insert(paras, para[1]) end
  end
  page.body:SetText(table.concat(paras, "\n\n"))

  -- "See also": the related pages this character has found.
  for _, b in ipairs(page.links) do
    b:Hide()
  end
  local n = 0
  local y = HEADER_H + page.body:GetStringHeight() + 22
  page.seeAlso:ClearAllPoints()
  page.seeAlso:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -y)
  y = y + 32
  for _, other in ipairs(e.also) do
    if ns.page(other) then
      n = n + 1
      local b = page.links[n]
      if not b then
        b = CreateFrame("Button", nil, page.child)
        b:SetSize(WIDTH, 18)
        b.text = label(b, BODY_FONT, 12, T.link)
        b.text:SetPoint("LEFT")
        b:SetScript("OnEnter", function(self) self.text:SetTextColor(1, 1, 1) end)
        b:SetScript("OnLeave", function(self) self.text:SetTextColor(unpack(T.link)) end)
        page.links[n] = b
      end
      b.text:SetText("» " .. C.entries[other].title)
      b.text:SetTextColor(unpack(T.link))
      b:SetScript("OnClick", function()
        showPage(other)
        ns.refresh(true)
      end)
      b:ClearAllPoints()
      b:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -y)
      b:Show()
      y = y + 20
    end
  end
  page.seeAlso:SetShown(n > 0)
  if n == 0 then y = y - 32 end
  page.child:SetHeight(y + 24)
  page:ScrollTo(0)
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
-- A curly apostrophe (typed or pasted) counts as a straight one.
local function plain(s) return (s:lower():gsub("\226\128\153", "'")) end
local haystack = {}
local function matches(id, query)
  if not haystack[id] then
    local e = C.entries[id]
    local parts = { e.title }
    for _, para in ipairs(e.text) do
      if not para.client or para.client == ns.client then table.insert(parts, para[1]) end
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
  book.count:SetText(("%d of %d pages"):format(ns.count(), ns.knownTotal()))
  book.foldAll:SetNormalTexture(ns.anyUnfolded() and MINUS or PLUS)
  for _, r in ipairs(rows) do
    r:Hide()
  end
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
    if kind == "chapter" then
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
    local results = ns.search(query)
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
      r.text:SetText("No page found.")
      r:Disable()
      r:Show()
      y = 18
    end
    return finish()
  end
  -- Loose pages (the foreword) first, then each chapter.
  for id, entry in pairs(C.entries) do
    if entry.chapter == "" and ns.page(id) then add("page", nil, id) end
  end
  -- A chapter appears once one of its pages is found, with its progress.
  for _, ch in ipairs(C.chapters) do
    local found = ns.found(ch)
    if found > 0 then
      y = y + 4
      add("chapter", ch.title, ("%d/%d"):format(found, #ch.entries), found, #ch.entries, ch.id)
      if not folded()[ch.id] then
        for _, id in ipairs(ch.entries) do
          if ns.page(id) then add("page", nil, id) end
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
    GameTooltip:SetText(ns.anyUnfolded() and "Fold every chapter" or "Unfold every chapter")
    GameTooltip:Show()
  end
  book.foldAll:SetScript("OnClick", function(self)
    ns.foldAll(ns.anyUnfolded())
    if GameTooltip:IsOwned(self) then tip(self) end
  end)
  book.foldAll:SetScript("OnEnter", tip)
  book.foldAll:SetScript("OnLeave", function() GameTooltip:Hide() end)

  list = ui.listArea("LorekeepersCodexList", book)
  page = ui.pageArea("LorekeepersCodexPage", book)
  ui.pageHeader(page)

  -- "See also": a heading with a line, then the links.
  page.seeAlso = CreateFrame("Frame", nil, page.child)
  page.seeAlso:SetSize(WIDTH, 24)
  page.seeAlso.text = label(page.seeAlso, TITLE_FONT, 16, T.gold)
  page.seeAlso.text:SetPoint("BOTTOMLEFT", 0, 5)
  page.seeAlso.text:SetText("See also")
  local seeRule = rule(page.seeAlso)
  seeRule:SetPoint("BOTTOMLEFT")
  seeRule:SetPoint("BOTTOMRIGHT")
  page.links = {}
end

-- Shown: the open page, or on first opening an unread page, else this
-- character's foreword.
local function show(n)
  book.foldAll:SetShown(n == ns.TAB.pages)
  list:SetShown(n == ns.TAB.pages)
  page:SetShown(n == ns.TAB.pages)
  if n ~= ns.TAB.pages then return end
  if not current or not ns.page(current) then
    current = nil
    for id in pairs(C.entries) do
      if ns.page(id) and not ns.isRead(id) then
        current = id
        break
      end
    end
    if not current then
      for id, e in pairs(C.entries) do
        if e.chapter == "" and ns.page(id) then
          current = id
          break
        end
      end
    end
  end
  if current then showPage(current) end
end

ns.addTab(ns.TAB.pages, { build = build, show = show, refresh = refresh })

-- Open the book at a page (a click on a codex link in chat, the banner).
function ns.open(id)
  if not ns.page(id) then return end
  current = id
  ns.openTab(ns.TAB.pages)
end
