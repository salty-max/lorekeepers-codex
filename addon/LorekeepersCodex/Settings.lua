-- The addon's settings, kept for the whole account in LorekeepersCodexSettings,
-- and their page in the game's Options (AddOns tab). /codex settings opens it;
-- so does a right-click on the minimap button.
local _, ns = ...

local DEFAULTS =
  { banner = true, bannerSeconds = 10, chat = true, sound = -1, minimapHidden = false, tooltipHints = true }

-- Sounds for a new page: all from the original game's interface. -1 is the
-- sting heard on discovering a new zone, which differs by race.
ns.SOUNDS = {
  { -1, "Zone discovery" },
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

-- The exploration sound kit of each race (Undead's token is Scourge).
local DISCOVERY =
  { Human = 4140, Orc = 4141, Scourge = 4142, Tauren = 4143, Troll = 4144, NightElf = 4145, Gnome = 4146, Dwarf = 4147 }

function ns.playSound(id)
  id = id or ns.option("sound")
  if id == -1 then
    local _, race = UnitRace("player")
    id = DISCOVERY[race] or DISCOVERY.Human
  end
  if id and id > 0 and PlaySound then PlaySound(id) end
end

local category

function ns.createSettingsPanel()
  if category or not (Settings and Settings.RegisterVerticalLayoutCategory) then return end
  category = Settings.RegisterVerticalLayoutCategory("Lorekeeper's Codex")

  local function checkbox(key, name, tooltip, invert)
    invert = invert or false
    local setting = Settings.RegisterProxySetting(
      category,
      "LOREKEEPERSCODEX_" .. key:upper(),
      Settings.VarType.Boolean,
      name,
      not DEFAULTS[key] == invert,
      function() return ns.option(key) ~= invert end,
      function(value) ns.setOption(key, value ~= invert) end
    )
    Settings.CreateCheckbox(category, setting, tooltip)
  end
  checkbox(
    "banner",
    "Alert for new pages",
    "Show each new page (and each achievement) in the game's own alert; a click on it reads the page."
  )
  local seconds = Settings.RegisterProxySetting(
    category,
    "LOREKEEPERSCODEX_BANNERSECONDS",
    Settings.VarType.Number,
    "Alert shown for",
    DEFAULTS.bannerSeconds,
    function() return ns.option("bannerSeconds") end,
    function(value) ns.setOption("bannerSeconds", value) end
  )
  local options = Settings.CreateSliderOptions(0, 60, 5)
  options:SetLabelFormatter(
    MinimalSliderWithSteppersMixin.Label.Right,
    function(value) return value == 0 and "until closed" or ("%d s"):format(value) end
  )
  Settings.CreateSlider(
    category,
    seconds,
    options,
    "How long the alert stays on screen. At 0 it stays until you read or dismiss it (right-click)."
  )

  checkbox("chat", "Announce new pages in chat", "A line in chat for each new page, with a link to it.")

  local sound = Settings.RegisterProxySetting(
    category,
    "LOREKEEPERSCODEX_SOUND",
    Settings.VarType.Number,
    "Sound for a new page",
    DEFAULTS.sound,
    function() return ns.option("sound") end,
    function(value)
      ns.setOption("sound", value)
      ns.playSound(value)
    end
  )
  Settings.CreateDropdown(category, sound, function()
    local sounds = Settings.CreateControlTextContainer()
    for _, s in ipairs(ns.SOUNDS) do
      sounds:Add(s[1], s[2])
    end
    return sounds:GetData()
  end, "Played when a page is added to the codex.")

  checkbox(
    "tooltipHints",
    "Hints on tooltips",
    "A line on the tooltip of creatures that unlock a page: a page to find, or the page's title once found."
  )

  checkbox(
    "minimapHidden",
    "Minimap button",
    "The book by the minimap: click to open the codex, drag to move it.",
    true
  )

  Settings.RegisterAddOnCategory(category)
end

function ns.openSettings()
  if category then Settings.OpenToCategory(category:GetID()) end
  return category ~= nil
end
