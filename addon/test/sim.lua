-- Runs the addon against a fake WoW API and replays a dwarf's first steps.
--   luajit addon/test/sim.lua      (from the repo root)
local DIR = "addon/LorekeepersCodex/"

-- ── a fake game ──────────────────────────────────────────────────────────────
local clock = 1790900000
function time() return clock end
date = os.date
local state = {
  level = 3, zone = "Dun Morogh", sub = "Anvilmar", target = nil,
  map = 1426, x = 0.3, y = 0.7,
  questsDone = { [7777] = true },
  standing = { [47] = 4 },
}
local printed = {}
function print(msg) table.insert(printed, msg) end
function strsplit(sep, s)
  local out = {}
  for part in (s .. sep):gmatch("(.-)" .. sep:gsub("%-", "%%-")) do table.insert(out, part) end
  return unpack(out)
end
function strtrim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
tinsert = table.insert
function UnitLevel() return state.level end
function UnitName(u) return u == "target" and "King Magni Bronzebeard" or "Thorin" end
local function creature(id) return ("Creature-0-4170-0-12-%d-0000ABCDEF"):format(id) end
local PLAYER, PET = "Player-6113-0ABCDEF0", "Pet-0-4170-0-12-1860-0100ABCDEF"
function UnitGUID(u)
  if u == "player" then return PLAYER end
  if u == "pet" then return PET end
  if u == "target" and state.target then return creature(state.target) end
end
local combatLog
function CombatLogGetCurrentEventInfo() return unpack(combatLog) end
function GetRealZoneText() return state.zone end
function GetSubZoneText() return state.sub end
C_Map = {
  -- A French client would answer "Kharanos" too; Anvilmar stays unnamed here,
  -- to check the English fallback.
  GetAreaInfo = function(id) return ({ [131] = "Kharanos", [1] = "Dun Morogh" })[id] end,
  GetBestMapForUnit = function() return state.map end,
  GetPlayerMapPosition = function() return { x = state.x, y = state.y } end,
}
C_QuestLog = { IsQuestFlaggedCompleted = function(id) return state.questsDone[id] == true end }
function GetFactionInfoByID(id) return "Ironforge", "", state.standing[id] end
SOUNDKIT = { IG_QUEST_LOG_OPEN = 1 }
local sounds = 0
function PlaySound() sounds = sounds + 1 end
local ticker
C_Timer = { NewTicker = function(_, fn) ticker = fn end }

-- UI: any method works and returns something sensible, scripts are kept.
local function ui()
  local o = { shown = false, scripts = {} }
  return setmetatable(o, {
    __index = function(t, k)
      if k == "SetScript" then return function(self, name, fn) self.scripts[name] = fn end end
      if k == "Show" then return function(self) self.shown = true; if self.scripts.OnShow then self.scripts.OnShow(self) end end end
      if k == "Hide" then return function(self) self.shown = false end end
      if k == "SetShown" then return function(self, v) if v then self:Show() else self:Hide() end end end
      if k == "IsShown" then return function(self) return self.shown end end
      if k == "SetText" then return function(self, v) self.text = v end end
      if k == "GetStringHeight" then return function() return 14 end end
      if k == "GetWidth" then return function() return 140 end end
      if k == "GetCenter" then return function() return 0, 0 end end
      if k == "GetEffectiveScale" then return function() return 1 end end
      if k == "CreateFontString" or k == "CreateTexture" then return function() return ui() end end
      return function() return t end
    end,
  })
end
UIParent, UISpecialFrames, SlashCmdList = ui(), {}, {}
Minimap, GameTooltip = ui(), ui()
function GetCursorPosition() return 0, 0 end
local linkHandlers = {}
LinkUtil = { RegisterLinkHandler = function(kind, fn) linkHandlers[kind] = fn end }
LinkProcessorResponse = { Handled = 2 }
local events
function CreateFrame(kind, name)
  local f = ui()
  if not events and kind == "Frame" and not name then
    events = f
    f.registered = {}
    f.RegisterEvent = function(self, e) self.registered[e] = true end
  end
  if name then _G[name] = f end
  return f
end
local function fire(e, ...)
  assert(events.registered[e], "not registered: " .. e)
  events.scripts.OnEvent(events, e, ...)
end

-- ── load the addon, with test entries for the unlocks the content doesn't use yet ─
local ns = {}
assert(loadfile(DIR .. "Content.lua"))("LorekeepersCodex", ns)
local function entry(title, unlock)
  return { title = title, kind = "note", chapter = "", unlock = { unlock }, also = {}, text = { { "test" } } }
end
ns.content.entries["t-quest"] = entry("Quest done before", { quest = 7777 })
ns.content.entries["t-quest-new"] = entry("Quest turned in", { quest = 8888 })
ns.content.entries["t-rep"] = entry("Friendly with Ironforge", { faction = 47, standing = 5 })
ns.content.entries["t-pos"] = entry("The Great Forge", { map = 1455, x = 57, y = 47, r = 6 })
assert(loadfile(DIR .. "Core.lua"))("LorekeepersCodex", ns)
assert(loadfile(DIR .. "Codex.lua"))("LorekeepersCodex", ns)
assert(loadfile(DIR .. "Minimap.lua"))("LorekeepersCodex", ns)
assert(loadfile(DIR .. "Banner.lua"))("LorekeepersCodex", ns)
function wipe(t) for k in pairs(t) do t[k] = nil end return t end

local function check(cond, msg) assert(cond, msg); io.write("✓ " .. msg .. "\n") end
local function has(id) return LorekeepersCodexChar.entries[id] ~= nil end

-- ── a session ────────────────────────────────────────────────────────────────
fire("PLAYER_LOGIN")
check(LorekeepersCodexChar ~= nil, "the codex is saved per character")
check(has("foreword") and LorekeepersCodexChar.entries.foreword.retro, "the foreword is there from the start, quietly")
check(has("war-of-the-three-hammers"), "logging in at Anvilmar unlocks the War of the Three Hammers (English name fallback)")
local function said(text) for _, p in ipairs(printed) do if p:find(text, 1, true) then return p end end end
check(said("|Hlorekeeper:war-of-the-three-hammers|h[The War of the Three Hammers]|h|r has been added to the codex.") and sounds == 2, "a new page is announced in chat as a link, with a sound")
local hints = 0
for _, p in ipairs(printed) do if p:find("/codex", 1, true) then hints = hints + 1 end end
check(hints == 1 and said("pages. Type /codex or click the book by the minimap"), "the /codex hint appears once, at login, and not in page messages")
check(LorekeepersCodexBanner and LorekeepersCodexBanner.shown and LorekeepersCodexBanner.id == "dun-morogh", "a banner shows the first new page at the top of the screen")
LorekeepersCodexBanner.scripts.OnUpdate(LorekeepersCodexBanner, 10)
check(LorekeepersCodexBanner.shown and LorekeepersCodexBanner.id == "war-of-the-three-hammers", "the next page found waits its turn")
LorekeepersCodexBanner.scripts.OnUpdate(LorekeepersCodexBanner, 10)
check(not LorekeepersCodexBanner.shown, "then the banner fades away")
check(LorekeepersCodexMinimapButton ~= nil and LorekeepersCodexSettings.minimapAngle ~= nil, "a minimap button, its place saved for the account")
check(has("dun-morogh"), "being in Dun Morogh unlocks the zone's page")
check(has("t-quest") and LorekeepersCodexChar.entries["t-quest"].retro, "a quest done before the codex unlocks quietly")
check(not has("t-rep"), "Neutral with Ironforge: not yet")

clock = clock + 600; state.level = 5; state.sub = "Kharanos"
fire("ZONE_CHANGED")
check(has("kharanos"), "reaching Kharanos unlocks it (name from the client)")
local k = LorekeepersCodexChar.entries.kharanos
check(k.level == 5 and k.sub == "Kharanos" and k.zone == "Dun Morogh" and k.at == clock, "a page remembers when, at what level and where")

state.target = 1234
fire("PLAYER_TARGET_CHANGED")
check(not has("magni-bronzebeard"), "another creature unlocks nothing")
state.target = 2784
fire("PLAYER_TARGET_CHANGED")
check(has("magni-bronzebeard"), "targeting King Magni unlocks his page")

fire("QUEST_TURNED_IN", 8888)
check(has("t-quest-new") and not LorekeepersCodexChar.entries["t-quest-new"].retro, "turning in a quest unlocks its page")

state.standing[47] = 5
fire("UPDATE_FACTION")
check(has("t-rep"), "reaching Friendly with Ironforge unlocks its page")

state.map, state.x, state.y = 1455, 0.60, 0.49
check(ticker ~= nil, "a position check runs (there are position pages)")
ticker()
check(has("t-pos"), "standing at the Great Forge unlocks it")

local before = 0
for _ in pairs(LorekeepersCodexChar.entries) do before = before + 1 end
fire("ZONE_CHANGED")
fire("PLAYER_TARGET_CHANGED")
local after = 0
for _ in pairs(LorekeepersCodexChar.entries) do after = after + 1 end
check(before == after and sounds == 7, "nothing is unlocked twice (7 pages announced)")

-- Kills: the killer is in the combat log's PARTY_KILL.
local function kill(source, id)
  combatLog = { clock, "PARTY_KILL", false, source, "Thorin", 0, 0, creature(id), "?", 0, 0 }
  fire("COMBAT_LOG_EVENT_UNFILTERED")
end
kill("Player-6113-0FFFFFFF", 1123)
check(not has("frostmane-trolls"), "someone else's kill unlocks nothing")
kill(PLAYER, 99999)
check(not has("frostmane-trolls"), "a creature no page names unlocks nothing")
kill(PLAYER, 1123)
check(has("frostmane-trolls"), "killing a Frostmane Headhunter unlocks the Frostmane trolls")
kill(PET, 1132)
check(has("timber"), "your pet killing Timber (a rare) counts")
kill(PLAYER, 706)
check(sounds == 9, "another Frostmane kill adds nothing")

state.zone, state.sub = "Ironforge", ""
fire("ZONE_CHANGED_NEW_AREA")
check(has("ironforge"), "entering Ironforge unlocks its page")

-- A click on a page link in chat opens the book at that page.
check(linkHandlers.lorekeeper ~= nil, "codex links have a handler")
check(linkHandlers.lorekeeper("lorekeeper:kharanos") == 2 and LorekeepersCodexFrame.shown, "clicking [Kharanos] in chat opens the book")
check(LorekeepersCodexChar.read.kharanos, "… at the Kharanos page")
linkHandlers.lorekeeper("lorekeeper:grim-batol")
check(not LorekeepersCodexChar.read["grim-batol"], "a link to a page not found yet opens nothing")
LorekeepersCodexFrame:Hide()
LorekeepersCodexMinimapButton.scripts.OnClick()
check(LorekeepersCodexFrame.shown, "the minimap button opens the book")
LorekeepersCodexFrame:Hide()
SlashCmdList.LOREKEEPERSCODEX("minimap")
check(LorekeepersCodexSettings.minimapHidden and not LorekeepersCodexMinimapButton.shown, "/codex minimap hides the button")
SlashCmdList.LOREKEEPERSCODEX("minimap")
SlashCmdList.LOREKEEPERSCODEX("banner")
ns.unlock("menethil-harbor")
check(LorekeepersCodexSettings.banner == false and not LorekeepersCodexBanner.shown, "/codex banner turns the banner off")
SlashCmdList.LOREKEEPERSCODEX("banner")

-- ── the book ─────────────────────────────────────────────────────────────────
SlashCmdList.LOREKEEPERSCODEX("")
check(LorekeepersCodexFrame and LorekeepersCodexFrame.shown, "/codex opens the book")
check(next(LorekeepersCodexChar.read) ~= nil, "opening it shows an unread page, marked read")
check(ns.count() == 13, "13 pages found")
local C = ns.content
check(ns.found(C.chapters[1]) == 7 and #C.chapters[1].entries == 18, "Dun Morogh counts 7 of its 18 pages")
check(ns.found(C.chapters[2]) == 0, "Loch Modan, not visited, has no page found: its chapter stays hidden")
check(ns.found(C.chapters[3]) == 1, "the Wetlands show once Menethil is found")
SlashCmdList.LOREKEEPERSCODEX("")
check(not LorekeepersCodexFrame.shown, "/codex again closes it")
printed = {}
SlashCmdList.LOREKEEPERSCODEX("where")
check(printed[1]:find("position: 1455 60.0 49.0", 1, true) ~= nil and printed[2]:find("npc: 2784", 1, true) ~= nil, "/codex where gives the position and target in content terms")
io.write("all good\n")
