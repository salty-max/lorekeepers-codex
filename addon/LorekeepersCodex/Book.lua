-- The codex as a book: the standard game window (portrait, title bar), its
-- tabs (Pages, the Library, Achievements: each a file of its own, *Book.lua,
-- registered with ns.addTab), the links in chat that open it, and the kit
-- every tab is made of (ns.ui): its look, a list's row, a page's header.
-- Light text and gold titles on dark panels: Forever's Professions cards; on
-- Classic, the game's insets and the quest log's dark book behind the list.
-- /codex opens it.
local _, ns = ...

-- ── look ─────────────────────────────────────────────────────────────────────
local T = {
  gold = { 0.85, 0.70, 0.42 },
  text = { 0.93, 0.88, 0.76 },
  soft = { 0.62, 0.57, 0.49 },
  rule = { 0.85, 0.70, 0.42, 0.25 },
  link = { 0.85, 0.70, 0.42 },
  ring = { 0.72, 0.56, 0.24 }, -- (round pictures' rings, the banner's edge)
  bar = { 0.85, 0.65, 0.13 }, -- (progress)
  dim = { 0.55, 0.53, 0.50 }, -- (an achievement not yet earned)
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
  b:SetStatusBarColor(unpack(T.bar))
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
  s.thumb:SetColorTexture(T.gold[1], T.gold[2], T.gold[3], 0.45)
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

-- A round portrait in a ring of the book's gold.
local MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local function roundIcon(parent, size)
  local p = CreateFrame("Frame", nil, parent)
  p:SetSize(size, size)
  p.ring = p:CreateTexture(nil, "BACKGROUND")
  p.ring:SetTexture(MASK)
  p.ring:SetVertexColor(unpack(T.ring))
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
-- A page's picture: the portrait of its creature (a figure, a typical one, a
-- leader), a calling's class icon (the game's round one), else its kind's
-- icon; none for a kind without one.
local CIRCLES = "Interface\\TargetingFrame\\UI-Classes-Circles"
local ICON_CROP = { 0.08, 0.92, 0.08, 0.92 }
local function callingOf(e)
  for _, u in ipairs(e.unlock or {}) do
    if u.calling then return u.calling end
  end
end
-- Shows a page's picture on a texture (the book's round one, the toast's
-- icon); false when it has none.
function ns.showPicture(tex, e)
  if e.portrait and SetPortraitTextureFromCreatureDisplayID then
    tex:SetTexCoord(0, 1, 0, 1)
    SetPortraitTextureFromCreatureDisplayID(tex, e.portrait)
    return true
  end
  local circle = e.kind == "calling" and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[callingOf(e) or ""]
  if circle then
    tex:SetTexture(CIRCLES)
    tex:SetTexCoord(unpack(circle))
    return true
  end
  local icon = KIND_ICONS[e.kind]
  if not icon then return false end
  tex:SetTexture(icon)
  tex:SetTexCoord(unpack(ICON_CROP))
  return true
end
-- The round picture of a page (p: roundIcon), hidden when it has none.
function ns.pagePicture(p, e)
  local shown = ns.showPicture(p.tex, e)
  p:SetShown(shown)
  return shown
end

-- ── a list's row, a page's header ────────────────────────────────────────────
-- A row of a list on the left: its text, a count, a fold mark, its highlight
-- and the mark of the one picked out; each tab places them for its kinds.
local HIGHLIGHT = "Interface\\QuestFrame\\UI-QuestTitleHighlight"
local ROW_WIDTH = 204
local function listRow(parent)
  local r = CreateFrame("Button", nil, parent)
  r:SetSize(ROW_WIDTH, 18)
  r.text = label(r, BODY_FONT, 12, T.text)
  r.text:SetWordWrap(false)
  r.count = label(r, BODY_FONT, 10, T.soft)
  r.fold = r:CreateTexture(nil, "ARTWORK")
  r.fold:SetSize(12, 12)
  r:SetHighlightTexture(HIGHLIGHT, "ADD")
  r.selected = r:CreateTexture(nil, "BACKGROUND")
  r.selected:SetAllPoints()
  r.selected:SetTexture(HIGHLIGHT)
  r.selected:SetBlendMode("ADD")
  r.selected:SetAlpha(0.7)
  return r
end

-- A page on the right, in its scroll area: a round picture, the title, a line
-- under it (what the page is, where it was found), a rule, then the text.
local WIDTH, HEADER_H = 440, 84
local function pageHeader(page)
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
end

-- The list's and the page's scroll areas, in the book's two panels.
local function listArea(name, book)
  local s = scrollArea(name, book.left, ROW_WIDTH)
  s:SetPoint("TOPLEFT", book.left, "TOPLEFT", 12, -40)
  s:SetPoint("BOTTOMRIGHT", book.left, "BOTTOMRIGHT", -18, 12)
  return s
end
local function pageArea(name, book)
  local s = scrollArea(name, book.sheet, WIDTH)
  s:SetPoint("TOPLEFT", book.sheet, "TOPLEFT", 26, -22)
  s:SetPoint("BOTTOMRIGHT", book.sheet, "BOTTOMRIGHT", -22, 14)
  return s
end

-- ── the window ───────────────────────────────────────────────────────────────
local book
local TAB = { pages = 1, library = 2, achievements = 3 }
ns.TAB = TAB
-- tabs[n] = { build(book), show(selected tab), refresh(scroll), whole (over
-- both panels) }
local tabs, TAB_TITLES = {}, { "Pages", "Library", "Achievements" }
function ns.addTab(n, tab) tabs[n] = tab end

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

-- No standard window on this client: a plain dialog frame.
local function dialog()
  local frame = CreateFrame("Frame", "LorekeepersCodexFrame", UIParent, "BackdropTemplate")
  frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
  })
  local title = label(frame, TITLE_FONT, 16, T.gold)
  title:SetPoint("TOP", 0, -16)
  title:SetText(TITLE)
  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -6, -6)
  return frame
end

-- Rewrite what the open tab shows. scroll: bring its picked-out row into view.
function ns.refresh(scroll)
  local tab = book and tabs[book.selectedTab]
  if tab and tab.built then tab.refresh(scroll) end
end

-- The tab n shown (built on first showing).
function ns.showTab(n)
  if not book then return end
  book.selectedTab = n
  if PanelTemplates_SetTab then PanelTemplates_SetTab(book, n) end
  local tab = tabs[n]
  if not tab.built then
    tab.build(book)
    tab.built = true
  end
  book.left:SetShown(not tab.whole)
  book.sheet:SetShown(not tab.whole)
  book.search:SetShown(not tab.whole)
  for _, t in ipairs(tabs) do
    if t.built then t.show(n) end
  end
  ns.refresh(true)
end

-- The tabs, under the window's bottom edge, in the style of the character
-- sheet's (the shared panel tabs where that template doesn't exist: Forever).
local function hasTemplate(name)
  if not (C_XMLUtil and C_XMLUtil.GetTemplateInfo) then return name == "CharacterFrameTabButtonTemplate" end
  return C_XMLUtil.GetTemplateInfo(name) ~= nil
end

local function buildTabs()
  local template = hasTemplate("CharacterFrameTabButtonTemplate") and "CharacterFrameTabButtonTemplate"
    or "PanelTabButtonTemplate"
  for n, text in ipairs(TAB_TITLES) do
    local tab = CreateFrame("Button", "LorekeepersCodexFrameTab" .. n, book, template)
    tab:SetID(n)
    tab:SetText(text)
    if n == 1 then
      tab:SetPoint("TOPLEFT", book, "BOTTOMLEFT", 14, 2)
    else
      tab:SetPoint("LEFT", "LorekeepersCodexFrameTab" .. (n - 1), "RIGHT", -14, 0)
    end
    tab:SetScript("OnClick", function(self)
      local chosen = tabs[self:GetID()].chosen
      if chosen then chosen() end
      ns.showTab(self:GetID())
      if PlaySound and SOUNDKIT and SOUNDKIT.IG_CHARACTER_INFO_TAB then PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB) end
    end)
    tab:SetScript("OnShow", function(self)
      if PanelTemplates_TabResize then PanelTemplates_TabResize(self, 0) end
    end)
    if PanelTemplates_TabResize then PanelTemplates_TabResize(tab, 0) end
  end
  if PanelTemplates_SetNumTabs then PanelTemplates_SetNumTabs(book, #TAB_TITLES) end
end

local function build()
  local window = gameWindow()
  book = window or dialog()
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
  table.insert(UISpecialFrames, "LorekeepersCodexFrame") -- Escape closes it

  -- The count beside the portrait; the list's column below it, the page to
  -- the right, under the title bar; the search box at the top of the list's
  -- column (its left edge holds the glass).
  local edge = window and 8 or 14
  book.count = label(book, BODY_FONT, 11, T.gold)
  book.count:SetPoint("TOPLEFT", 64, -36)
  book.left = panel(book, true)
  book.left:SetPoint("TOPLEFT", edge, -58)
  book.left:SetPoint("BOTTOMLEFT", edge, edge)
  book.left:SetWidth(244)
  book.sheet = panel(book)
  book.sheet:SetPoint("TOPLEFT", book.left, "TOPRIGHT", 4, 32)
  book.sheet:SetPoint("BOTTOMRIGHT", -edge, edge)
  book.search = CreateFrame("EditBox", "LorekeepersCodexSearch", book, "SearchBoxTemplate")
  book.search:SetHeight(20)
  book.search:SetPoint("TOPLEFT", book.left, "TOPLEFT", 18, -10)
  book.search:SetPoint("TOPRIGHT", book.left, "TOPRIGHT", -34, -10)
  book.search:HookScript("OnTextChanged", function() ns.refresh() end)

  book.selectedTab = TAB.pages
  book:SetScript("OnShow", function() ns.showTab(book.selectedTab) end)
  buildTabs()
end

local function window()
  if not book then build() end
  return book
end

function ns.toggle() window():SetShown(not book:IsShown()) end

-- The book open at a tab (the page it shows chosen by the caller).
function ns.openTab(n)
  window()
  book.selectedTab = n
  if book:IsShown() then
    ns.showTab(n)
  else
    book:Show() -- (its OnShow shows the tab)
  end
end

-- ── links in chat ────────────────────────────────────────────────────────────
-- |Hlorekeeper:<what>|h[Title]|h: a page's id, ach:<achievement>, lib:<text>.
-- The game hands links of an unknown type to the handler registered for it.
local function followLink(link)
  local id = link:match("^lorekeeper:(.+)$")
  if not id then return end
  local text = tonumber(id:match("^lib:(%d+)$"))
  if text then return ns.openText(text) end
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

-- A page found while the book is open shows up at once; so does an
-- achievement, and a text copied into the Library.
local function shown()
  if book and book:IsShown() then ns.refresh() end
end
ns.onUnlock, ns.onAchievement, ns.onLibrary = shown, shown, shown

-- The kit, for the tabs and the banner.
ns.ui = {
  T = T,
  TITLE_FONT = TITLE_FONT,
  BODY_FONT = BODY_FONT,
  WIDTH = WIDTH,
  HEADER_H = HEADER_H,
  ROW_WIDTH = ROW_WIDTH,
  label = label,
  rule = rule,
  bar = bar,
  card = card,
  panel = panel,
  scrollArea = scrollArea,
  roundIcon = roundIcon,
  listRow = listRow,
  pageHeader = pageHeader,
  listArea = listArea,
  pageArea = pageArea,
  KINDS = KINDS,
}
