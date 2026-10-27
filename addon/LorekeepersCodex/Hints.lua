-- A line on the tooltip of any creature that unlocks a page: "a page to find"
-- until this character has it, then the page's title; on a player's, "a page
-- to find" while their people's page or their calling's is missing (nothing
-- once found: players are everywhere). Off in the settings (tooltipHints).
local _, ns = ...
local L = ns.kit.L
local C = ns.content

local function addHint(tooltip)
  if tooltip ~= GameTooltip or not ns.option("tooltipHints") then return end
  local _, unit = tooltip:GetUnit()
  if not unit or ns.secret(unit) then return end
  local isPlayer = UnitIsPlayer(unit)
  if ns.secret(isPlayer) then return end
  if isPlayer then
    for _, pageId in ipairs(ns.pagesOfPlayer(unit)) do
      if ns.available(pageId) and not ns.page(pageId) then
        ns.kit.tooltipLine(tooltip, L["Lorekeeper's Codex: a page to find"], true)
        return
      end
    end
    return
  end
  local id = ns.npcId(unit)
  if not id then return end
  local missing = false
  for _, pageId in ipairs(ns.pagesOfNpc(id)) do
    if ns.available(pageId) then
      if ns.page(pageId) then
        ns.kit.tooltipLine(tooltip, L["Lorekeeper's Codex: %s"]:format(C.entries[pageId].title), false)
      else
        missing = true
      end
    end
  end
  if missing then ns.kit.tooltipLine(tooltip, L["Lorekeeper's Codex: a page to find"], true) end
end

ns.kit.onUnitTooltip(addHint)
