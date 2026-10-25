-- The codex as a book: the standard game window (portrait, title bar), its
-- tabs (Pages, the Library, Achievements: each a file of its own, *Book.lua,
-- registered with ns.addTab), the links in chat that open it, and what every
-- tab is made of (ns.ui): the kit's look (Kit.lua) in the Codex's theme, a
-- list's row, the kit's page on the right. /codex opens it.
local _, ns = ...
local L = ns.kit.L

-- ── look ─────────────────────────────────────────────────────────────────────
-- The kit's (Kit.lua), in the Codex's theme: the family's gold, the panels a
-- touch cool, like ink in an archive.
local K = ns.kit
K.theme({
  tint = { 0.88, 0.92, 1.00 },
  shade = { 0.02, 0.025, 0.035, 0.55 },
  aside = { 0.68, 0.78, 0.62 }, -- (Parqual's ink, the Horde's copy)
})
local T = K.T
T.link = T.accent -- (a page's "See also" links)
local BODY_FONT, TITLE_FONT = K.BODY_FONT, K.TITLE_FONT
local label, rule, bar, card, panel, scrollArea, roundIcon =
  K.label, K.rule, K.bar, K.card, K.panel, K.scrollArea, K.roundIcon
local BOOK = "Interface\\AddOns\\LorekeepersCodex\\Media\\Logo"

-- What a page is about, in a word.
local KINDS = {
  place = L["Place"],
  figure = L["Figure"],
  faction = L["Faction"],
  creature = L["Creature"],
  history = L["History"],
  note = L["Note"],
  calling = L["Calling"],
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
-- A page's picture as the kit's pages draw one (a setter given the round
-- picture), nil for a page without one; orBook: the codex's book instead.
function ns.pictureOf(e, orBook)
  local has = (e.portrait and SetPortraitTextureFromCreatureDisplayID)
    or (e.kind == "calling" and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[callingOf(e) or ""])
    or KIND_ICONS[e.kind]
  if has then
    return function(p) ns.showPicture(p.tex, e) end
  end
  return orBook and K.icon(BOOK) or nil
end

-- ── a page's header ──────────────────────────────────────────────────────────
-- The list on the left is the kit's (K.list, each tab its kinds of row).
-- The page on the right: the kit's (a round picture, the title, a line under
-- it, a rule, then its parts), as every book of the family.
local WIDTH, HEADER_H = K.PAGE_WIDTH, K.PAGE_HEADER_H

-- The page, in the book's right panel.
local function pageArea(name, book) return K.page(book.sheet, name) end

-- ── the window ───────────────────────────────────────────────────────────────
-- The kit's book (K.book): the window, its two panels, the search (room
-- beside it for the fold-all button) and under it a tab's own select (the
-- pages' kind), the tabs; each tab a file of its own, registered with
-- ns.addTab: { build(book), show(selected tab), refresh(scroll), chosen(),
-- whole (over both panels), filter = { default, options() } }.
local TAB = { pages = 1, library = 2, achievements = 3 }
ns.TAB = TAB
local B = K.book({
  name = "LorekeepersCodexFrame",
  title = "Lorekeeper's Codex",
  art = "Interface\\AddOns\\LorekeepersCodex\\Media\\Logo",
  titles = { L["Pages"], L["Library"], L["Achievements"] },
  first = TAB.pages,
  search = "LorekeepersCodexSearch",
  searchRight = -34,
  filter = true,
})
ns.kitBook = B -- (for the tests)
function ns.addTab(n, tab) B:add(n, tab) end
function ns.filterOf(n) return B:filterOf(n) end
-- Rewrite what the open tab shows. scroll: bring its picked-out row into view.
function ns.refresh(scroll) B:refresh(scroll) end
function ns.showTab(n) B:show(n) end
function ns.toggle() B:toggle() end
-- The book open at a tab (the page it shows chosen by the caller).
function ns.openTab(n) B:open(n) end

-- ── links in chat ────────────────────────────────────────────────────────────
-- |Hlorekeeper:<what>|h[Title]|h: a page's id, ach:<achievement>, lib:<text>.
-- The game hands links of an unknown type to the handler registered for it.
local function followLink(id)
  local text = tonumber(id:match("^lib:(%d+)$"))
  if text then return ns.openText(text) end
  local achievement = id:match("^ach:(.+)$")
  if achievement then
    ns.openAchievements(achievement)
  else
    ns.open(id)
  end
end
-- (the kit's: the client's link registry, else SetItemRef)
K.links("lorekeeper", followLink)

-- A page found while the book is open shows up at once; so does an
-- achievement, and a text copied into the Library.
local function shown()
  if B.frame and B.frame:IsShown() then ns.refresh() end
end
ns.onUnlock, ns.onAchievement, ns.onLibrary = shown, shown, shown

-- The kit, for the tabs and the banner.
ns.ui = {
  T = T,
  TITLE_FONT = TITLE_FONT,
  BODY_FONT = BODY_FONT,
  WIDTH = WIDTH,
  HEADER_H = HEADER_H,
  label = label,
  rule = rule,
  bar = bar,
  card = card,
  panel = panel,
  scrollArea = scrollArea,
  roundIcon = roundIcon,
  icon = K.icon,
  day = K.day,
  BOOK = BOOK,
  pageArea = pageArea,
  KINDS = KINDS,
}
