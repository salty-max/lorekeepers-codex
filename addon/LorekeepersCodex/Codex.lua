-- The codex as a book, in a standard game window (portrait, title bar), as
-- Explorer's Field Journal. On the left, the chapters and the pages found in
-- them (a chapter's bar and count tell how many are left; a click on its title
-- folds it away or opens it); on the right, the open page: its title, its
-- chapter and kind, a round picture (for a figure, a creature or a faction,
-- the game's still portrait of it; else an icon of its kind), the text, and
-- links to related pages. A second
-- tab lists the achievements. Light text and gold titles on dark panels:
-- Forever's Professions cards; on Classic, the game's insets and the quest
-- log's dark book behind the list. /codex opens it.
local _, ns = ...
local C = ns.content

-- ── look ─────────────────────────────────────────────────────────────────────
local T = {
  gold = { 0.85, 0.70, 0.42 },
  text = { 0.93, 0.88, 0.76 },
  soft = { 0.62, 0.57, 0.49 },
  rule = { 0.85, 0.70, 0.42, 0.25 },
  link = { 0.85, 0.70, 0.42 },
}
local LATIN = { enUS = true, enGB = true, frFR = true, deDE = true, esES = true, esMX = true, itIT = true, ptBR = true }
local BODY_FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local TITLE_FONT = (not GetLocale or LATIN[GetLocale()]) and "Fonts\\MORPHEUS.TTF" or BODY_FONT

local function label(parent, font, size, color)
  local fs = parent:CreateFontString(nil, "OVERLAY")
  fs:SetFont(font, size, "")
  fs:SetTextColor(unpack(color))
  fs:SetShadowOffset(1, -1)
  fs:SetJustifyH("LEFT")
  return fs
end

local function rule(parent)
  local t = parent:CreateTexture(nil, "ARTWORK")
  t:SetColorTexture(unpack(T.rule))
  t:SetHeight(1)
  return t
end

local function bar(parent)
  local b = CreateFrame("StatusBar", nil, parent)
  b:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  b:SetStatusBarColor(0.85, 0.65, 0.13)
  local bg = b:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.5)
  return b
end

-- Forever's Professions card (a dark rounded panel), cut in nine so it
-- stretches to any size without bending its corners.
local CARD_FILE, CARD_W, CARD_H = 8164414, 1024, 512
local CARD = { 1, 665, 1, 143 } -- the generic card, in the texture's pixels
local CORNER = 16
local function card(parent)
  local f = CreateFrame("Frame", nil, parent)
  local xs = { CARD[1], CARD[1] + CORNER, CARD[2] - CORNER, CARD[2] }
  local ys = { CARD[3], CARD[3] + CORNER, CARD[4] - CORNER, CARD[4] }
  for i = 1, 3 do
    for j = 1, 3 do
      local tex = f:CreateTexture(nil, "BACKGROUND")
      tex:SetTexture(CARD_FILE)
      tex:SetTexCoord(xs[j] / CARD_W, xs[j + 1] / CARD_W, ys[i] / CARD_H, ys[i + 1] / CARD_H)
      if j ~= 2 then tex:SetWidth(CORNER) end
      if i ~= 2 then tex:SetHeight(CORNER) end
      -- Corners pinned to the frame's edges; edges and centre between them.
      if j == 1 then tex:SetPoint("LEFT", f, "LEFT", 0, 0) end
      if j == 2 then
        tex:SetPoint("LEFT", f, "LEFT", CORNER, 0)
        tex:SetPoint("RIGHT", f, "RIGHT", -CORNER, 0)
      end
      if j == 3 then tex:SetPoint("RIGHT", f, "RIGHT", 0, 0) end
      if i == 1 then tex:SetPoint("TOP", f, "TOP", 0, 0) end
      if i == 2 then
        tex:SetPoint("TOP", f, "TOP", 0, -CORNER)
        tex:SetPoint("BOTTOM", f, "BOTTOM", 0, CORNER)
      end
      if i == 3 then tex:SetPoint("BOTTOM", f, "BOTTOM", 0, 0) end
    end
  end
  return f
end

-- Classic's panels: the game's inset, darkened a little for the text; behind
-- the list, the quest log's dark book (TBC's two-pane log, where the game has it).
local function inset(parent, book)
  local ok, f = pcall(CreateFrame, "Frame", nil, parent, "InsetFrameTemplate")
  if not (ok and f) then f = CreateFrame("Frame", nil, parent) end
  local shade = f:CreateTexture(nil, "BACKGROUND", nil, 1)
  shade:SetPoint("TOPLEFT", 3, -3)
  shade:SetPoint("BOTTOMRIGHT", -3, 3)
  shade:SetColorTexture(0.03, 0.025, 0.02, 0.55)
  if not book then return f end
  local art = f:CreateTexture(nil, "BACKGROUND", nil, 2)
  art:SetPoint("TOPLEFT", 3, -3)
  art:SetPoint("BOTTOMRIGHT", -3, 3)
  if art:SetTexture("Interface\\QuestFrame\\UI-QuestLogDualPane-Left") == false then
    art:Hide()
  else
    art:SetTexCoord(20 / 512, 318 / 512, 74 / 512, 406 / 512)
  end
  return f
end

local function panel(parent, book)
  if ns.forever then return card(parent) end
  return inset(parent, book)
end

-- A scroll area moved by the mouse wheel, with a thin gold thumb.
local function scrollArea(name, parent, width)
  local s = CreateFrame("ScrollFrame", name, parent)
  local c = CreateFrame("Frame", nil, s)
  c:SetSize(width, 1)
  s:SetScrollChild(c)
  s.child = c
  s.thumb = s:CreateTexture(nil, "OVERLAY")
  s.thumb:SetColorTexture(0.85, 0.70, 0.42, 0.45)
  s.thumb:SetWidth(3)
  function s:Range() return math.max(0, self.child:GetHeight() - self:GetHeight()) end
  function s:UpdateThumb()
    local range, height = self:Range(), self:GetHeight()
    if range <= 0 then
      self.thumb:Hide()
      return
    end
    local size = math.max(24, height * height / (height + range))
    self.thumb:SetHeight(size)
    self.thumb:ClearAllPoints()
    self.thumb:SetPoint(
      "TOPRIGHT",
      self,
      "TOPRIGHT",
      8,
      -(height - size) * math.min(1, self:GetVerticalScroll() / range)
    )
    self.thumb:Show()
  end
  function s:ScrollTo(y)
    self:SetVerticalScroll(math.max(0, math.min(y, self:Range())))
    self:UpdateThumb()
  end
  s:EnableMouseWheel(true)
  s:SetScript("OnMouseWheel", function(self, delta) self:ScrollTo(self:GetVerticalScroll() - delta * 40) end)
  return s
end

-- A round portrait in a gold ring.
local MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local function roundIcon(parent, size)
  local p = CreateFrame("Frame", nil, parent)
  p:SetSize(size, size)
  p.ring = p:CreateTexture(nil, "BACKGROUND")
  p.ring:SetTexture(MASK)
  p.ring:SetVertexColor(0.72, 0.56, 0.24)
  p.ring:SetPoint("CENTER")
  p.ring:SetSize(size + 4, size + 4)
  p.tex = p:CreateTexture(nil, "ARTWORK")
  p.tex:SetAllPoints()
  local mask = p:CreateMaskTexture()
  mask:SetTexture(MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
  mask:SetAllPoints(p.tex)
  p.tex:AddMaskTexture(mask)
  return p
end

-- What a page is about, in a word.
local KINDS = {
  place = "Place",
  figure = "Figure",
  faction = "Faction",
  creature = "Creature",
  history = "History",
  note = "Note",
  calling = "Calling",
}
-- Pages about no one creature get one icon per kind, true of any of them: a
-- map for a place, an old book for history, a note for the League's notes.
local KIND_ICONS = {
  place = "Interface\\Icons\\INV_Misc_Map_01",
  history = "Interface\\Icons\\INV_Misc_Book_11",
  note = "Interface\\Icons\\INV_Misc_Note_01",
}
-- A page's round picture: the portrait of its creature (a figure, a typical
-- one, a leader), else its kind's icon. Returns false when it has none (the
-- picture is then hidden). Also used by the banner.
function ns.kindIcon(kind) return KIND_ICONS[kind] end

-- (a calling's page: the class's own round icon, as the game's portraits show it)
local CIRCLES = "Interface\\TargetingFrame\\UI-Classes-Circles"
local function callingOf(e)
  for _, u in ipairs(e.unlock or {}) do
    if u.calling then return u.calling end
  end
end
function ns.pagePicture(p, e)
  local creature = e.portrait and SetPortraitTextureFromCreatureDisplayID
  local circle = not creature and e.kind == "calling" and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[callingOf(e) or ""]
  local icon = not creature and not circle and KIND_ICONS[e.kind]
  p:SetShown((creature or circle or icon) and true or false)
  if creature then
    p.tex:SetTexCoord(0, 1, 0, 1)
    SetPortraitTextureFromCreatureDisplayID(p.tex, e.portrait)
  elseif circle then
    p.tex:SetTexture(CIRCLES)
    p.tex:SetTexCoord(unpack(circle))
  elseif icon then
    p.tex:SetTexture(icon)
    p.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  end
  return (creature or circle or icon) and true or false
end
ns.roundIcon, ns.label, ns.look =
  roundIcon, label, { T = T, TITLE_FONT = TITLE_FONT, BODY_FONT = BODY_FONT, card = card }

local chapterTitle = {}
for _, ch in ipairs(C.chapters) do
  chapterTitle[ch.id] = ch.title
end

local book, list, page, achievements
local build -- the book, made on first opening (below)
local current
local WIDTH = 440
local HEADER_H = 84

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
local ROW_WIDTH = 204
local rows = {}
ns.listRows = rows -- for the tests
local function row(i)
  local r = rows[i]
  if r then return r end
  r = CreateFrame("Button", nil, list.child)
  r:SetSize(ROW_WIDTH, 18)
  r.text = label(r, BODY_FONT, 12, T.text)
  r.text:SetPoint("RIGHT", -4, 0)
  r.text:SetWordWrap(false)
  -- A chapter's fold: the plus and minus of the game's own lists.
  r.fold = r:CreateTexture(nil, "ARTWORK")
  r.fold:SetSize(12, 12)
  r.fold:SetPoint("TOPLEFT", 2, -4)
  -- A chapter's progress, under its title: a bar, then the pages found.
  r.bar = bar(r)
  r.bar:SetPoint("BOTTOMLEFT", 18, 4)
  r.bar:SetPoint("BOTTOMRIGHT", -44, 4)
  r.bar:SetHeight(4)
  r.count = label(r, BODY_FONT, 10, T.soft)
  r.count:SetPoint("LEFT", r.bar, "RIGHT", 6, 0)
  r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  r.selected = r:CreateTexture(nil, "BACKGROUND")
  r.selected:SetAllPoints()
  r.selected:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
  r.selected:SetBlendMode("ADD")
  r.selected:SetAlpha(0.7)
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
function ns.refresh(scrollToCurrent)
  if not book then return end
  if book.selectedTab == 3 then return ns.refreshAchievements() end
  if book.selectedTab == 2 then return ns.refreshLibrary and ns.refreshLibrary() end
  -- Going to a page (a link, the banner) unfolds its chapter.
  local e = scrollToCurrent and current and C.entries[current]
  if e and e.chapter ~= "" then folded()[e.chapter] = nil end
  local currentY
  book.count:SetText(("%d of %d pages"):format(ns.count(), ns.knownTotal()))
  if book.foldAll then book.foldAll:SetNormalTexture(ns.anyUnfolded() and MINUS or PLUS) end
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

-- ── the achievements ──────────────────────────────────────────────────────────
-- One row each, under its group's heading: the title (gold once earned), what
-- it asks, and on the right when it was earned, or how far along it is.
local GROUPS = {
  { "milestone", "Milestones" },
  { "feat", "Feats" },
  { "encounter", "Encounters" },
  { "library", "The Library" },
  { "chapter", "Chapters" },
}
local ROW = 50
local ACH_WIDTH = 700
local achRows, headers = {}, {}
local selected

local function achRow(i)
  local r = achRows[i]
  if r then return r end
  r = CreateFrame("Frame", nil, achievements.child)
  r:SetSize(ACH_WIDTH, ROW - 4)
  r.bg = r:CreateTexture(nil, "BACKGROUND")
  r.bg:SetAllPoints()
  r.title = label(r, TITLE_FONT, 15, T.gold)
  r.title:SetPoint("TOPLEFT", 12, -7)
  r.text = label(r, BODY_FONT, 11, T.soft)
  r.text:SetPoint("TOPLEFT", r.title, "BOTTOMLEFT", 0, -5)
  r.text:SetWidth(500)
  r.status = label(r, BODY_FONT, 11, T.soft)
  r.status:SetPoint("TOPRIGHT", -12, -8)
  r.status:SetJustifyH("RIGHT")
  r.bar = bar(r)
  r.bar:SetSize(150, 5)
  r.bar:SetPoint("TOPRIGHT", r.status, "BOTTOMRIGHT", 0, -7)
  achRows[i] = r
  return r
end

local function header(i)
  local h = headers[i]
  if h then return h end
  h = CreateFrame("Frame", nil, achievements.child)
  h:SetSize(ACH_WIDTH, 26)
  h.text = label(h, TITLE_FONT, 17, T.gold)
  h.text:SetPoint("BOTTOMLEFT", 2, 5)
  h.line = rule(h)
  h.line:SetPoint("BOTTOMLEFT")
  h.line:SetPoint("BOTTOMRIGHT")
  headers[i] = h
  return h
end

function ns.refreshAchievements()
  if not achievements then return end
  book.count:SetText(("%d of %d achievements"):format(ns.achievementCount()))
  local i, y, selectedY = 0, 0, nil
  for g, group in ipairs(GROUPS) do
    local h = header(g)
    h:ClearAllPoints()
    h:SetPoint("TOPLEFT", 0, -y)
    h.text:SetText(group[2])
    y = y + 34
    for _, a in ipairs(ns.achievements) do
      if a.group == group[1] and ns.achievementVisible(a) then
        i = i + 1
        local r = achRow(i)
        r:ClearAllPoints()
        r:SetPoint("TOPLEFT", 0, -y)
        if a.id == selected then selectedY = y end
        local earned = ns.earned(a.id)
        local done, need = a.progress()
        r.title:SetText(a.title)
        r.text:SetText(a.text)
        if earned then
          r.title:SetTextColor(unpack(T.gold))
          r.text:SetTextColor(unpack(T.text))
          r.status:SetText(("Level %d, %s"):format(earned.level or 0, date("%d %b %Y", earned.at or 0)))
          r.bar:Hide()
        else
          r.title:SetTextColor(0.55, 0.53, 0.50)
          r.text:SetTextColor(unpack(T.soft))
          if a.unit then
            r.status:SetText(("%d %s"):format(done, a.unit))
            r.bar:Hide()
          else
            r.status:SetText(("%d/%d"):format(math.min(done, need), need))
            r.bar:SetMinMaxValues(0, math.max(need, 1))
            r.bar:SetValue(math.min(done, need))
            r.bar:SetShown(need > 1)
          end
        end
        if a.id == selected then
          r.bg:SetColorTexture(0.85, 0.70, 0.42, 0.22)
        elseif earned then
          r.bg:SetColorTexture(0.85, 0.65, 0.13, 0.10)
        else
          r.bg:SetColorTexture(1, 1, 1, 0.03)
        end
        r:Show()
        y = y + ROW
      end
    end
    y = y + 12
  end
  for k = i + 1, #achRows do
    achRows[k]:Hide()
  end
  achievements.child:SetHeight(y)
  achievements:UpdateThumb()
  -- An achievement opened from chat or the banner: bring it into view.
  if selectedY then
    local height = achievements:GetHeight()
    local max = math.max(0, y - height)
    achievements:SetVerticalScroll(math.min(max, math.max(0, selectedY - (height - ROW) / 2)))
    achievements:UpdateThumb()
  end
end

local function buildAchievements()
  book.achPanel = panel(book)
  book.achPanel:SetPoint("TOPLEFT", 8, -58)
  book.achPanel:SetPoint("BOTTOMRIGHT", -8, 8)
  achievements = scrollArea("LorekeepersCodexAchievements", book.achPanel, ACH_WIDTH)
  achievements:SetPoint("TOPLEFT", 22, -18)
  achievements:SetPoint("BOTTOMRIGHT", -22, 14)
  book.achPanel:Hide()
  achievements:Hide()
end

-- The book's two tabs, under its bottom edge, in the style of the character
-- sheet's.
-- The tabs: 1 the pages, 2 the Library (Library.lua: its own list and page
-- in the same panels), 3 the achievements.
function ns.showTab(n)
  if not book then return end
  book.selectedTab = n
  if PanelTemplates_SetTab then PanelTemplates_SetTab(book, n) end
  if n == 2 and not rawget(book, "libraryList") and ns.buildLibrary then ns.buildLibrary(book) end
  book.left:SetShown(n ~= 3)
  book.sheet:SetShown(n ~= 3)
  book.search:SetShown(n ~= 3)
  book.foldAll:SetShown(n == 1)
  list:SetShown(n == 1)
  page:SetShown(n == 1)
  if rawget(book, "libraryList") then
    book.libraryList:SetShown(n == 2)
    book.libraryPage:SetShown(n == 2)
  end
  book.achPanel:SetShown(n == 3)
  achievements:SetShown(n == 3)
  if n == 3 then
    ns.refreshAchievements()
  else
    ns.refresh(true)
  end
end

-- The character sheet's tabs on Classic; the shared panel tabs where that
-- template doesn't exist (the modern client of Forever).
local function hasTemplate(name)
  if not (C_XMLUtil and C_XMLUtil.GetTemplateInfo) then return name == "CharacterFrameTabButtonTemplate" end
  return C_XMLUtil.GetTemplateInfo(name) ~= nil
end

local function buildTabs()
  local template = hasTemplate("CharacterFrameTabButtonTemplate") and "CharacterFrameTabButtonTemplate"
    or "PanelTabButtonTemplate"
  for n, text in ipairs({ "Pages", "Library", "Achievements" }) do
    local tab = CreateFrame("Button", "LorekeepersCodexFrameTab" .. n, book, template)
    tab:SetID(n)
    tab:SetText(text)
    if n == 1 then
      tab:SetPoint("TOPLEFT", book, "BOTTOMLEFT", 14, 2)
    else
      tab:SetPoint("LEFT", "LorekeepersCodexFrameTab" .. (n - 1), "RIGHT", -14, 0)
    end
    tab:SetScript("OnClick", function(self)
      selected = nil
      ns.showTab(self:GetID())
      if PlaySound and SOUNDKIT and SOUNDKIT.IG_CHARACTER_INFO_TAB then PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB) end
    end)
    tab:SetScript("OnShow", function(self)
      if PanelTemplates_TabResize then PanelTemplates_TabResize(self, 0) end
    end)
    if PanelTemplates_TabResize then PanelTemplates_TabResize(tab, 0) end
  end
  if PanelTemplates_SetNumTabs then PanelTemplates_SetNumTabs(book, 3) end
  book.selectedTab = 1
  if PanelTemplates_SetTab then PanelTemplates_SetTab(book, 1) end
end

-- Open the book at the achievements, one of them picked out.
function ns.openAchievements(id)
  if not book then build() end
  selected = id
  if not book:IsShown() then book:Show() end
  ns.showTab(3)
end

-- ── the book ─────────────────────────────────────────────────────────────────
-- The standard game window (portrait, title bar), its inset removed.
local TITLE = "Lorekeeper's Codex"
local function gameWindow()
  local ok, frame = pcall(CreateFrame, "Frame", "LorekeepersCodexFrame", UIParent, "ButtonFrameTemplate")
  if not ok or not frame then return nil end
  if ButtonFrameTemplate_HideButtonBar then ButtonFrameTemplate_HideButtonBar(frame) end
  if type(frame.Inset) == "table" then frame.Inset:Hide() end
  local art = "Interface\\Icons\\INV_Misc_Book_09"
  if frame.SetPortraitToAsset then
    frame:SetPortraitToAsset(art)
  elseif type(frame.portrait) == "table" then
    frame.portrait:SetTexture(art)
  end
  if frame.SetTitle then
    frame:SetTitle(TITLE)
  elseif type(frame.TitleText) == "table" then
    frame.TitleText:SetText(TITLE)
  end
  return frame
end

function build()
  local window = gameWindow()
  book = window or CreateFrame("Frame", "LorekeepersCodexFrame", UIParent, "BackdropTemplate")
  book:SetSize(780, 560)
  book:SetPoint("CENTER")
  book:SetFrameStrata("HIGH")
  book:SetToplevel(true)
  book:SetMovable(true)
  book:EnableMouse(true)
  book:SetClampedToScreen(true)
  book:RegisterForDrag("LeftButton")
  book:SetScript("OnDragStart", book.StartMoving)
  book:SetScript("OnDragStop", book.StopMovingOrSizing)
  tinsert(UISpecialFrames, "LorekeepersCodexFrame") -- Escape closes it
  if not window then
    -- No standard window on this client: a plain dialog frame.
    book:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
      tile = true,
      tileSize = 32,
      edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    local title = label(book, TITLE_FONT, 16, T.gold)
    title:SetPoint("TOP", 0, -16)
    title:SetText(TITLE)
    local close = CreateFrame("Button", nil, book, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -6, -6)
  end
  local edge = window and 8 or 14

  -- The count beside the portrait.
  book.count = label(book, BODY_FONT, 11, T.gold)
  book.count:SetPoint("TOPLEFT", 64, -36)

  -- Left: a search box and the fold-all button, then the list.
  local left = panel(book, true)
  book.left = left
  left:SetPoint("TOPLEFT", edge, -58)
  left:SetPoint("BOTTOMLEFT", edge, edge)
  left:SetWidth(244)
  book.search = CreateFrame("EditBox", "LorekeepersCodexSearch", book, "SearchBoxTemplate")
  book.search:SetHeight(20)
  book.search:SetPoint("TOPLEFT", left, "TOPLEFT", 18, -10)
  book.search:SetPoint("TOPRIGHT", left, "TOPRIGHT", -34, -10)
  book.search:HookScript("OnTextChanged", function() ns.refresh() end)

  -- Beside it, fold or unfold every chapter at once: a minus while any is
  -- open, a plus once all are folded.
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

  list = scrollArea("LorekeepersCodexList", left, ROW_WIDTH)
  list:SetPoint("TOPLEFT", left, "TOPLEFT", 12, -40)
  list:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -18, 12)

  -- Right: the page.
  local sheet = panel(book)
  book.sheet = sheet
  sheet:SetPoint("TOPLEFT", left, "TOPRIGHT", 4, 32)
  sheet:SetPoint("BOTTOMRIGHT", -edge, edge)

  page = scrollArea("LorekeepersCodexPage", sheet, WIDTH)
  page:SetPoint("TOPLEFT", sheet, "TOPLEFT", 26, -22)
  page:SetPoint("BOTTOMRIGHT", sheet, "BOTTOMRIGHT", -22, 14)
  page.scroll = page

  -- The header: a portrait (some pages), the title, the chapter and kind; a line.
  page.icon = roundIcon(page.child, 56)
  page.icon:SetPoint("TOPLEFT", 2, -2)
  page.title = label(page.child, TITLE_FONT, 24, T.gold)
  page.title:SetPoint("TOPLEFT", page.icon, "TOPRIGHT", 16, -4)
  page.title:SetWidth(WIDTH - 78)
  page.title:SetWordWrap(false)
  page.sub = label(page.child, BODY_FONT, 12, T.soft)
  page.sub:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, -7)
  page.sub:SetWidth(WIDTH - 78)
  local headerRule = rule(page.child)
  headerRule:SetPoint("TOPLEFT", 0, -70)
  headerRule:SetPoint("TOPRIGHT", 0, -70)

  page.body = label(page.child, BODY_FONT, 13, T.text)
  page.body:SetPoint("TOPLEFT", 0, -HEADER_H)
  page.body:SetWidth(WIDTH)
  page.body:SetSpacing(4)

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

  book:SetScript("OnShow", function()
    if not current or not ns.page(current) then
      -- First opening: an unread page, else this character's foreword.
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
    showPage(current)
    ns.refresh(true)
  end)

  buildAchievements()
  buildTabs()
end

function ns.toggle()
  if not book then build() end
  book:SetShown(not book:IsShown())
end

-- Open the book at a page (a click on a codex link in chat).
function ns.open(id)
  if not ns.page(id) then return end
  if not book then build() end
  current = id
  ns.showTab(1)
  if book:IsShown() then
    showPage(id)
    ns.refresh(true)
  else
    book:Show()
  end
end

-- Codex links in chat (|Hlorekeeper:<id>|h[Title]|h): the game hands links of
-- an unknown type to the handler registered for it.
local function followLink(link)
  local id = link:match("^lorekeeper:(.+)$")
  if not id then return end
  local text = tonumber(id:match("^lib:(%d+)$"))
  if text then return ns.openText and ns.openText(text) end
  local achievement = id:match("^ach:(.+)$")
  if achievement then
    ns.openAchievements(achievement)
  else
    ns.open(id)
  end
end
if LinkUtil and LinkUtil.RegisterLinkHandler then
  LinkUtil.RegisterLinkHandler("lorekeeper", function(link)
    followLink(link)
    return LinkProcessorResponse and LinkProcessorResponse.Handled
  end)
elseif hooksecurefunc and SetItemRef then
  -- Clients without the link registry still pass every click to SetItemRef.
  hooksecurefunc("SetItemRef", function(link) followLink(link) end)
end

-- A page found while the book is open shows up in the list at once; so does
-- an achievement.
ns.onUnlock = function()
  if book and book:IsShown() then ns.refresh() end
end
ns.onAchievement = ns.onUnlock

-- The book's look, for the Library's pages (Library.lua).
ns.ui = {
  T = T,
  TITLE_FONT = TITLE_FONT,
  BODY_FONT = BODY_FONT,
  WIDTH = WIDTH,
  HEADER_H = HEADER_H,
  label = label,
  rule = rule,
  roundIcon = roundIcon,
  scrollArea = scrollArea,
  book = function() return book end,
  build = function()
    if not book then build() end
    return book
  end,
}
