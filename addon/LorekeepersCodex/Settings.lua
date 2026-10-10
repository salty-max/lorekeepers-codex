-- The addon's settings, each character's own (its profile, "Name - Realm",
-- the kit's: Kit.lua), all kept in LorekeepersCodexSettings so that one
-- character can take another's: chosen among this game's characters, or
-- brought by a code (/codex export, /codex import CODE). Their page in the
-- game's Options (AddOns tab): /codex settings, or a right-click on the
-- minimap button; the welcome page (Welcome.lua) offers them too.
--
--   LorekeepersCodexSettings.profiles["Name - Realm"] = { banner,
--     bannerSeconds, chat, sound, tooltipHints, minimapHidden, minimapAngle,
--     welcomed }
--   (the account-wide values of 0.8.0 and before, at the top of the table:
--   the first profile of a character who kept a codex before takes them)
local _, ns = ...
local K = ns.kit

-- (minimapAngle: the button's place around the minimap, in degrees; 200 is
-- lower left, clear of the game's buttons; welcomed: never copied)
local DEFAULTS = {
  banner = true,
  bannerSeconds = 10,
  chat = true,
  sound = -1,
  minimapHidden = false,
  minimapAngle = 200,
  tooltipHints = true,
  welcomed = false,
}
local SHARED = { "banner", "bannerSeconds", "chat", "sound", "tooltipHints", "minimapHidden", "minimapAngle" }

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

-- The profiles: a code "LC1:b1:d10:c1:s-1:t1:h0:a200" (the alert and its
-- seconds, chat, the sound, tooltip hints, the minimap button hidden, its angle).
local P = K.profiles({
  saved = function()
    if type(LorekeepersCodexSettings) ~= "table" then LorekeepersCodexSettings = {} end
    return LorekeepersCodexSettings
  end,
  defaults = DEFAULTS,
  shared = SHARED,
  letters = {
    banner = "b",
    bannerSeconds = "d",
    chat = "c",
    sound = "s",
    tooltipHints = "t",
    minimapHidden = "h",
    minimapAngle = "a",
  },
  tag = "LC1",
  changed = function(key)
    if key == "banner" and not ns.option("banner") then ns.hideBanner() end
    if key == "minimapHidden" or key == "minimapAngle" then ns.updateMinimapButton() end
  end,
})
ns.profiles = P

-- This character's profile at its login: its own, else a new one (the
-- account's old values for a character who kept a codex before, the
-- defaults for a new one).
function ns.loadProfile(before)
  P:load(function(profile, saved)
    if not before then return end
    for _, k in ipairs(SHARED) do
      profile[k] = saved[k]
    end
  end)
end
function ns.option(key) return P:get(key) end
function ns.setOption(key, value) P:set(key, value) end

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
    "A line on the tooltip of creatures that unlock a page (a page to find, or its title once found), and of "
      .. "players whose people's or calling's page is still to find."
  )

  checkbox(
    "minimapHidden",
    "Minimap button",
    "The book by the minimap: click to open the codex, drag to move it.",
    true
  )

  -- Another character's settings (of this game), for this one.
  K.copySetting(
    category,
    "LOREKEEPERSCODEX_COPYFROM",
    P,
    "Another character's choices, for this one (of this game: Classic and Forever keep their own). From elsewhere: /codex export there, then /codex import CODE here.",
    function(other) print(ns.PREFIX .. ("%s's settings copied."):format(other)) end
  )

  Settings.RegisterAddOnCategory(category)
end

function ns.openSettings()
  if category then Settings.OpenToCategory(category:GetID()) end
  return category ~= nil
end
