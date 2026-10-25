-- The Achievements tab, over both panels: the kit's board (the figures on
-- top; each achievement under its group's heading with how many of it are
-- earned: its group's picture, a medal on it once earned, the title, what it
-- asks, when it was earned or how far along it is). Achievements.lua.
local _, ns = ...
local L = ns.kit.L
ns.achievementRows = {} -- for the tests

-- (each group: its id, its heading, its picture, the figure it counts in)
local GROUPS = {
  { "milestone", L["Milestones"], "Interface\\Icons\\INV_Misc_Book_09", "deeds" },
  { "feat", L["Feats"], "Interface\\Icons\\INV_Misc_Note_01", "deeds" },
  -- (the players met: the reader's own crest, read when drawn)
  {
    "encounter",
    L["Encounters"],
    function(p) ns.kit.crest(select(2, UnitClass("player")), "Interface\\Icons\\INV_Misc_Note_01")(p) end,
    "encounters",
  },
  { "library", L["The Library"], "Interface\\Icons\\INV_Misc_Book_11", "reading" },
  { "chapter", L["Chapters"], "Interface\\Icons\\INV_Misc_Map_01", "reading" },
}
local FIGURES = {
  { "all", L["earned"] },
  { "deeds", L["of the deeds"] },
  { "encounters", L["of the encounters"] },
  { "reading", L["of the reading"] },
}
-- (the kit's tab, K.deedsTab: its board over both panels and the count)
local tab = ns.kit.deedsTab(ns.deeds, {
  name = "LorekeepersCodexAchievements",
  groups = GROUPS,
  figures = FIGURES,
  rows = ns.achievementRows,
  n = ns.TAB.achievements,
})
ns.addTab(ns.TAB.achievements, tab.tab)

-- Open the book at the achievements, one of them picked out.
function ns.openAchievements(id)
  tab:pick(id)
  ns.openTab(ns.TAB.achievements)
end
