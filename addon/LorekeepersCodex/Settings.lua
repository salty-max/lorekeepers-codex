-- The addon's settings, each character's own (its profile, "Name - Realm",
-- the kit's: Kit.lua), all kept in LorekeepersCodexSettings so that one
-- character can take another's: chosen among this game's characters, or
-- brought by a code (/codex export, /codex import CODE). Their page in the
-- game's Options (AddOns tab): /codex settings, or a right-click on the
-- minimap button; the welcome page (Welcome.lua) offers them too.
--
--   LorekeepersCodexSettings.profiles["Name - Realm"] = { banner,
--     bannerSeconds, achievementToast, sound, tooltipHints, minimapHidden,
--     minimapAngle, welcomed }
--   (banner: a new page's alert; achievementToast: an achievement's. The
--   chat lines have no setting any more, always shown: a profile's old chat
--   value is left unread)
--   (the account-wide values of 0.8.0 and before, at the top of the table:
--   the first profile of a character who kept a codex before takes them)
local _, ns = ...
local L = ns.kit.L
local K = ns.kit

-- (minimapAngle: the button's place around the minimap, in degrees, the
-- family's own for the Codex, K.MINIMAP_ANGLES: below, off Hearthtale's;
-- welcomed: never copied)
local DEFAULTS = {
  banner = true,
  bannerSeconds = 10,
  achievementToast = true,
  sound = -1,
  minimapHidden = false,
  minimapAngle = K.MINIMAP_ANGLES.LorekeepersCodex,
  tooltipHints = true,
  welcomed = false,
}
local SHARED =
  { "banner", "bannerSeconds", "achievementToast", "sound", "tooltipHints", "minimapHidden", "minimapAngle" }

-- Sounds for a new page: the kit's (all from the original game's interface;
-- -1 the sting heard on discovering a new zone, which differs by race),
-- named in the reader's language.
ns.SOUNDS = {}
for i, s in ipairs(K.SOUNDS) do
  ns.SOUNDS[i] = { s[1], L[s[2]] }
end

-- The profiles: a code "LC1:b1:d10:v1:s-1:t1:h0:a200" (a page's alert and its
-- seconds, an achievement's alert, the sound, tooltip hints, the minimap button
-- hidden, its angle; an older code's c, the chat lines, is left out).
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
    achievementToast = "v",
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

-- A sound of the list, the reader's choice by default (the kit's: -1 the
-- race's own discovery sting).
function ns.playSound(id) K.playSound(id or ns.option("sound")) end

-- The opt-in that shares what the game tells of the world with the addons'
-- database (the kit's, K.collect): account-wide, in LorekeepersCodexCollect, which
-- Ravenpost sends; off until the player says yes.
ns.collect = K.collect({
  saved = function()
    if type(LorekeepersCodexCollect) ~= "table" then LorekeepersCodexCollect = {} end
    return LorekeepersCodexCollect
  end,
  prefix = ns.PREFIX,
})

local O

-- The page (the kit's, K.options).
function ns.createSettingsPanel()
  if O then return end
  O = K.options({
    title = "Lorekeeper's Codex",
    key = "LOREKEEPERSCODEX",
    get = ns.option,
    set = ns.setOption,
    defaults = DEFAULTS,
    profiles = P,
    slash = "/codex",
    prefix = ns.PREFIX,
  })
  O:check(
    "banner",
    L["Alert for new pages"],
    L["Show each new page in the game's own alert. A click on it reads the page."]
  )
  O:check(
    "achievementToast",
    L["Alert for achievements"],
    L["Show each achievement earned in the game's achievement alert. A click on it opens the achievements."]
  )
  O:slider(
    "bannerSeconds",
    L["Alert shown for"],
    L["How long the alert stays on screen. At 0 it stays until you read or dismiss it (right-click)."],
    0,
    60,
    5,
    function(value) return value == 0 and L["until closed"] or L["%d s"]:format(value) end
  )
  O:choice("sound", L["Sound for a new page"], L["Played when a page is added to the codex."], function()
    local out = {}
    for _, s in ipairs(ns.SOUNDS) do
      table.insert(out, { s[1], s[2] })
    end
    return out
  end, function(value) ns.playSound(value) end)
  O:check(
    "tooltipHints",
    L["Hints on tooltips"],
    L["A line on the tooltip of creatures that unlock a page (a page to find, or its title once found), and of players whose people's or calling's page is still to find."]
  )
  O:check(
    "minimapHidden",
    L["Minimap button"],
    L["The book by the minimap: click to open the codex, drag to move it."],
    true
  )
  O:collect(ns.collect)
  O:copy()
  O:done()
end

function ns.openSettings() return O ~= nil and O:open() end
