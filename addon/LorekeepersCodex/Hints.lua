-- A line on the tooltip of any creature that unlocks a page: "a page to find"
-- until this character has it, then the page's title. Off in the settings
-- (tooltipHints).
local _, ns = ...
local C = ns.content

local FOUND = { 0.65, 0.58, 0.45 }
local TO_FIND = { 1, 0.82, 0 }

local function addHint(tooltip)
  if tooltip ~= GameTooltip or not ns.option("tooltipHints") then return end
  local _, unit = tooltip:GetUnit()
  if not unit or UnitIsPlayer(unit) then return end
  local id = ns.npcId(unit)
  if not id then return end
  local missing = false
  for _, pageId in ipairs(ns.pagesOfNpc(id)) do
    if ns.available(pageId) then
      if ns.page(pageId) then
        tooltip:AddLine("Lorekeeper's Codex: " .. C.entries[pageId].title, unpack(FOUND))
      else
        missing = true
      end
    end
  end
  if missing then tooltip:AddLine("Lorekeeper's Codex: a page to find", unpack(TO_FIND)) end
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
  TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, addHint)
else
  GameTooltip:HookScript("OnTooltipSetUnit", addHint)
end
