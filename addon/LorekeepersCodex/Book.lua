-- The codex as a book: the standard game window (portrait, title bar), its
-- tabs (Pages, the Library, Achievements: each a file of its own, *Book.lua,
-- registered with ns.addTab), the links in chat that open it, and the kit
-- every tab is made of (ns.ui): the kit's look (Kit.lua) in the Codex's
-- theme, a list's row, a page's header. /codex opens it.
local _, ns = ...

-- ── look ─────────────────────────────────────────────────────────────────────
-- The kit's (Kit.lua), in the Codex's theme: the family's gold, the panels a
-- touch cool, like ink in an archive.
local K = ns.kit
K.theme({
  tint = { 0.88, 0.92, 1.00 },
  shade = { 0.02, 0.025, 0.035, 0.55 },
})
local T = K.T
T.link = T.accent -- (a page's "See also" links)
local BODY_FONT, TITLE_FONT = K.BODY_FONT, K.TITLE_FONT
local label, rule, bar, card, panel, scrollArea, roundIcon =
  K.label, K.rule, K.bar, K.card, K.panel, K.scrollArea, K.roundIcon

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
local ROW_WIDTH = 204
local function listRow(parent)
  local r = CreateFrame("Button", nil, parent)
  r:SetSize(ROW_WIDTH, 18)
  r.text = label(r, BODY_FONT, 12, T.text)
  r.text:SetWordWrap(false)
  r.count = label(r, BODY_FONT, 10, T.soft)
  r.fold = r:CreateTexture(nil, "ARTWORK")
  r.fold:SetSize(12, 12)
  r.selected = K.highlight(r)
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

-- The list's and the page's scroll areas, in the book's two panels
-- (filtered: the list under the select of a tab with a filter).
local function listArea(name, book, filtered)
  local s = scrollArea(book.left, ROW_WIDTH, name)
  s:SetPoint("TOPLEFT", book.left, "TOPLEFT", 12, filtered and -70 or -40)
  s:SetPoint("BOTTOMRIGHT", book.left, "BOTTOMRIGHT", -18, 12)
  return s
end
local function pageArea(name, book)
  local s = scrollArea(book.sheet, WIDTH, name)
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

-- A tab's choice in its select (the kit's, under the search box: filter =
-- { default, options() } in its registration), else its default; kept for
-- the session.
function ns.filterOf(n)
  local tab = tabs[n]
  if not (tab and tab.filter) then return nil end
  if tab.filterValue == nil then return tab.filter.default end
  return tab.filterValue
end

-- The standard game window (portrait: the codex's book; title bar), else a
-- plain dialog where the client has no such template (Kit.lua).
local TITLE = "Lorekeeper's Codex"

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
  if tab.filter and not tab.whole then
    book.filter:SetOptions(tab.filter.options())
    book.filter:SetValue(ns.filterOf(n))
    book.filter:Show()
  else
    book.filter:Hide()
  end
  for _, t in ipairs(tabs) do
    if t.built then t.show(n) end
  end
  ns.refresh(true)
end

local function build()
  local window = K.gameWindow("LorekeepersCodexFrame", TITLE, "Interface\\Icons\\INV_Misc_Book_09")
  book = window or K.dialog("LorekeepersCodexFrame", TITLE)
  K.movable(book, 780, 560)

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
  -- Under it, the open tab's own select (the pages' kind), if it has one.
  book.filter = K.select(book.left, 220, "")
  book.filter:SetPoint("TOPLEFT", book.left, "TOPLEFT", 12, -38)
  book.filter.onChange = function(value)
    tabs[book.selectedTab].filterValue = value
    ns.refresh(true)
  end
  book.filter:Hide()

  book.selectedTab = TAB.pages
  book:SetScript("OnShow", function() ns.showTab(book.selectedTab) end)
  K.tabs(book, TAB_TITLES, function(n)
    local chosen = tabs[n].chosen
    if chosen then chosen() end
    ns.showTab(n)
  end)
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
