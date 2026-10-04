-- The addon's settings, kept for the whole account in LorekeepersCodexSettings,
-- and their page in the game's Options (AddOns tab). /codex settings opens it;
-- so does a right-click on the minimap button.
local _, ns = ...

local DEFAULTS = { banner = true, chat = true, sound = 878, minimapHidden = false }

-- Sounds for a new page: all from the original game's interface.
ns.SOUNDS = {
  { 878, "Quest complete" },
  { 3175, "Map ping" },
  { 8960, "Ready check" },
  { 836, "Page turn" },
  { 844, "Book opening (quiet)" },
  { 0, "None" },
}

function ns.option(key)
  LorekeepersCodexSettings = LorekeepersCodexSettings or {}
  local v = LorekeepersCodexSettings[key]
  if v == nil then return DEFAULTS[key] end
  return v
end

function ns.setOption(key, value)
  LorekeepersCodexSettings = LorekeepersCodexSettings or {}
  LorekeepersCodexSettings[key] = value
  if key == "banner" and not value then ns.hideBanner() end
  if key == "minimapHidden" then ns.updateMinimapButton() end
end

function ns.playSound(id)
  id = id or ns.option("sound")
  if id and id > 0 and PlaySound then PlaySound(id) end
end

local category

function ns.createSettingsPanel()
  if category or not (Settings and Settings.RegisterVerticalLayoutCategory) then return end
  category = Settings.RegisterVerticalLayoutCategory("Lorekeeper's Codex")

  local function checkbox(key, name, tooltip, invert)
    invert = invert or false
    local setting = Settings.RegisterProxySetting(category, "LOREKEEPERSCODEX_" .. key:upper(), Settings.VarType.Boolean, name,
      not DEFAULTS[key] == invert,
      function() return ns.option(key) ~= invert end,
      function(value) ns.setOption(key, value ~= invert) end)
    Settings.CreateCheckbox(category, setting, tooltip)
  end
  checkbox("banner", "Banner for new pages", "Show each new page at the top of the screen, until you read or close it.")
  checkbox("chat", "Announce new pages in chat", "A line in chat for each new page, with a link to it.")

  local sound = Settings.RegisterProxySetting(category, "LOREKEEPERSCODEX_SOUND", Settings.VarType.Number, "Sound for a new page",
    DEFAULTS.sound,
    function() return ns.option("sound") end,
    function(value) ns.setOption("sound", value); ns.playSound(value) end)
  Settings.CreateDropdown(category, sound, function()
    local options = Settings.CreateControlTextContainer()
    for _, s in ipairs(ns.SOUNDS) do options:Add(s[1], s[2]) end
    return options:GetData()
  end, "Played when a page is added to the codex.")

  checkbox("minimapHidden", "Minimap button", "The book by the minimap: click to open the codex, drag to move it.", true)

  Settings.RegisterAddOnCategory(category)
end

function ns.openSettings()
  if category then Settings.OpenToCategory(category:GetID()) end
  return category ~= nil
end
