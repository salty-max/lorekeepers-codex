-- The book's button on the minimap (the kit's: Kit.lua): click to open the
-- book, right-click for its settings, drag to move it around the minimap.
-- Its place (and whether it shows) is kept with this character's settings
-- (Settings.lua).
local _, ns = ...
local K = ns.kit
local L = K.L

local M

function ns.createMinimapButton()
  if M then return end
  M = K.minimapButton({
    name = "LorekeepersCodexMinimapButton",
    icon = "Interface\\AddOns\\LorekeepersCodex\\Media\\Logo",
    crop = true,
    title = "Lorekeeper's Codex",
    lines = function()
      return {
        L["%d of %d pages"]:format(ns.count(), ns.knownTotal()),
        L["%d of %d achievements"]:format(ns.achievementCount()),
      }
    end,
    click = function() ns.toggle() end,
    rightClick = function() ns.openSettings() end,
    get = ns.option,
    set = ns.setOption,
  })
end

function ns.updateMinimapButton()
  if M then M:update() end
end
