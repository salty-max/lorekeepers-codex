-- The Achievements tab, over both panels: the kit's board (the figures on
-- top; each achievement under its group's heading with how many of it are
-- earned: its group's picture, a medal on it once earned, the title, what it
-- asks, when it was earned or how far along it is). Achievements.lua.
local _, ns = ...
local ui = ns.ui

local book, board
ns.achievementRows = {} -- for the tests

-- (each group: its id, its heading, its picture, the figure it counts in)
local GROUPS = {
  { "milestone", "Milestones", "Interface\\Icons\\INV_Misc_Book_09", "deeds" },
  { "feat", "Feats", "Interface\\Icons\\INV_Misc_Note_01", "deeds" },
  -- (the players met: the reader's own crest, read when drawn)
  {
    "encounter",
    "Encounters",
    function(p) ns.kit.crest(select(2, UnitClass("player")), "Interface\\Icons\\INV_Misc_Note_01")(p) end,
    "encounters",
  },
  { "library", "The Library", "Interface\\Icons\\INV_Misc_Book_11", "reading" },
  { "chapter", "Chapters", "Interface\\Icons\\INV_Misc_Map_01", "reading" },
}
local FIGURES = {
  { "all", "earned" },
  { "deeds", "of the deeds" },
  { "encounters", "of the encounters" },
  { "reading", "of the reading" },
}
local selected

-- The achievements shown (no chapter's before it is opened: no spoilers).
local function items()
  local out = {}
  for _, a in ipairs(ns.achievements) do
    if ns.achievementVisible(a) then
      table.insert(out, {
        id = a.id,
        group = a.group,
        title = a.title,
        text = a.text,
        earned = ns.earned(a.id),
        progress = a.progress,
        unit = a.unit,
      })
    end
  end
  return out
end

local function refresh()
  book.count:SetText(("%d of %d achievements"):format(ns.achievementCount()))
  board:refresh(selected)
end

local function build(b)
  book = b
  book.achPanel = ui.panel(book)
  book.achPanel:SetPoint("TOPLEFT", 8, -58)
  book.achPanel:SetPoint("BOTTOMRIGHT", -8, 8)
  board = ns.kit.board({
    parent = book.achPanel,
    name = "LorekeepersCodexAchievements",
    groups = GROUPS,
    figures = FIGURES,
    items = items,
    rows = ns.achievementRows,
  })
end

local function show(n)
  book.achPanel:SetShown(n == ns.TAB.achievements)
  board.scroll:SetShown(n == ns.TAB.achievements)
end

-- (its tab clicked: none picked out)
local function chosen() selected = nil end

ns.addTab(ns.TAB.achievements, { build = build, show = show, refresh = refresh, chosen = chosen, whole = true })

-- Open the book at the achievements, one of them picked out.
function ns.openAchievements(id)
  selected = id
  ns.openTab(ns.TAB.achievements)
end
