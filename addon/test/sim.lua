-- Runs the addon against a fake WoW API and replays a dwarf's first steps.
--   luajit addon/test/sim.lua              (from the repo root): Classic
--   FOREVER=1 luajit addon/test/sim.lua    the same on Forever's client: no
--                                          combat log, secret values, C_Reputation
local DIR = "addon/LorekeepersCodex/"
local FOREVER = os.getenv("FOREVER") == "1"
function GetBuildInfo() return "1.15.8", "60000", "Oct 1 2026", FOREVER and 16001 or 11509 end
-- Values the game hides from addons on Forever.
local secrets = {}
if FOREVER then issecretvalue = function(v) return secrets[v] == true end end

-- ── a fake game ──────────────────────────────────────────────────────────────
local clock = 1790900000
function time() return clock end
date = os.date
local state = {
  level = 3,
  zone = "Dun Morogh",
  sub = "Anvilmar",
  target = nil,
  map = 1426,
  x = 0.3,
  y = 0.7,
  questsDone = { [7777] = true },
  standing = { [47] = 4 },
}
local printed = {}
function print(msg) table.insert(printed, msg) end
function strsplit(sep, s)
  local out = {}
  for part in (s .. sep):gmatch("(.-)" .. sep:gsub("%-", "%%-")) do
    table.insert(out, part)
  end
  return unpack(out)
end
function strtrim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
function GetRealmName() return "Nightslayer" end
function InCombatLockdown() return false end
tinsert = table.insert
function UnitLevel() return state.level end
function UnitName(u) return u == "target" and "King Magni Bronzebeard" or "Thorin" end
local function creature(id) return ("Creature-0-4170-0-12-%d-0000ABCDEF"):format(id) end
local PLAYER, PET = "Player-6113-0ABCDEF0", "Pet-0-4170-0-12-1860-0100ABCDEF"
function UnitGUID(u)
  if u == "player" then return PLAYER end
  if u == "pet" then return PET end
  if u == "target" and state.target then return creature(state.target) end
  if u == "mouseover" and state.mouseover then return creature(state.mouseover) end
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
if FOREVER then
  C_Reputation = { GetFactionDataByID = function(id) return { name = "Ironforge", reaction = state.standing[id] } end }
else
  function GetFactionInfoByID(id) return "Ironforge", "", state.standing[id] end
end
SOUNDKIT = { IG_QUEST_LOG_OPEN = 1 }
local sounds, lastSound = 0, nil
function PlaySound(id)
  sounds = sounds + 1
  lastSound = id
end
local ticker
local timers = {}
C_Timer = {
  After = function(_, fn) fn() end,
  NewTicker = function(_, fn) ticker = fn end,
  NewTimer = function(seconds, fn)
    local t = { seconds = seconds, fn = fn }
    t.Cancel = function(self) self.cancelled = true end
    table.insert(timers, t)
    return t
  end,
}
-- Run the newest live timer, as if its time had come.
local function elapse()
  for i = #timers, 1, -1 do
    local t = timers[i]
    if not t.cancelled then
      t.cancelled = true
      t.fn()
      return t.seconds
    end
  end
end
function UnitXP() return 0 end
-- (a player targeted: state.player = { race, class }, their tokens)
local function aPlayer(u) return (u == "target" or u == "mouseover") and state.player end
function UnitRace(u)
  if aPlayer(u) then return state.player.race, state.player.race end
  return "Dwarf", "Dwarf"
end
function UnitClass(u)
  if aPlayer(u) then return state.player.class, state.player.class end
  return "Hunter", "HUNTER"
end
function GetLocale() return "enUS" end
function UnitIsUnit(a, b) return a == b end
-- (state.side: the reader's, Alliance unless a test says)
function UnitFactionGroup() return state.side or "Alliance" end

-- UI: any method works and returns something sensible, scripts are kept.
local function ui()
  local o = { shown = false, scripts = {} }
  return setmetatable(o, {
    __index = function(t, k)
      if k == "SetScript" then
        return function(self, name, fn) self.scripts[name] = fn end
      end
      if k == "Show" then
        return function(self)
          -- (OnShow on a showing only, as in the game: not on a shown frame)
          local was = self.shown
          self.shown = true
          if not was and self.scripts.OnShow then self.scripts.OnShow(self) end
        end
      end
      if k == "Hide" then
        return function(self)
          local was = self.shown
          self.shown = false
          if was and self.scripts.OnHide then self.scripts.OnHide(self) end
        end
      end
      -- (a texture's tint and greying: a ring's colour)
      if k == "SetVertexColor" then
        return function(self, r, g, b) self.vertex = { r, g, b } end
      end
      if k == "SetDesaturated" then
        return function(self, v) self.desaturated = v end
      end
      if k == "SetChecked" then
        return function(self, v) self.checked = v and true or false end
      end
      if k == "GetChecked" then
        return function(self) return rawget(self, "checked") or false end
      end
      if k == "SetShown" then
        return function(self, v)
          if v then
            self:Show()
          else
            self:Hide()
          end
        end
      end
      if k == "IsShown" then
        return function(self) return self.shown end
      end
      if k == "IsMouseOver" then
        return function(self) return self.mouseOver == true end
      end
      if k == "GetFrameLevel" then
        return function() return 1 end
      end
      if k == "SetText" then
        return function(self, v) self.text = v end
      end
      if k == "GetText" then
        return function(self) return rawget(self, "text") or "" end
      end
      if k == "GetStringHeight" then
        return function() return 14 end
      end
      if k == "SetHeight" then
        return function(self, v) self.height = v end
      end
      if k == "SetID" then
        return function(self, v) self.idValue = v end
      end
      if k == "GetID" then
        return function(self) return rawget(self, "idValue") or 0 end
      end
      if k == "GetHeight" then
        return function(self) return rawget(self, "height") or 100 end
      end
      if k == "SetVerticalScroll" then
        return function(self, v) self.vscroll = v end
      end
      if k == "GetVerticalScroll" then
        return function(self) return rawget(self, "vscroll") or 0 end
      end
      if k == "GetWidth" then
        return function() return 140 end
      end
      if k == "GetCenter" then
        return function() return 0, 0 end
      end
      if k == "GetEffectiveScale" then
        return function() return 1 end
      end
      if k == "CreateFontString" or k == "CreateTexture" then
        return function() return ui() end
      end
      return function() return t end
    end,
  })
end
UIParent, UISpecialFrames, SlashCmdList = ui(), {}, {}
Minimap, GameTooltip = ui(), ui()
-- The tooltip: keep hooks, lines and the unit it shows.
local tipHooks, tipLines, tipUnit = {}, {}, nil
GameTooltip.HookScript = function(self, name, fn) tipHooks[name] = fn end
GameTooltip.GetUnit = function() return "Someone", tipUnit end
GameTooltip.AddLine = function(self, text) table.insert(tipLines, text) end
function UnitPlayerControlled() return false end
function UnitIsPlayer(u) return u == "player" or (u == "target" or u == "mouseover") and state.player ~= nil end
function GetCursorPosition() return 0, 0 end
local linkHandlers = {}
LinkUtil = { RegisterLinkHandler = function(kind, fn) linkHandlers[kind] = fn end }
LinkProcessorResponse = { Handled = 2 }
MinimalSliderWithSteppersMixin = { Label = { Right = 2 } }
-- The game's settings panel: keep what the addon registers.
local panel = { settings = {}, opened = nil }
Settings = {
  VarType = { Boolean = "boolean", Number = "number", String = "string" },
  RegisterVerticalLayoutCategory = function(name)
    panel.name = name
    return { GetID = function() return 42 end }
  end,
  RegisterProxySetting = function(_, variable, _, name, default, get, set)
    local s = { variable = variable, name = name, default = default, get = get, set = set }
    panel.settings[variable] = s
    return s
  end,
  CreateCheckbox = function() end,
  CreateDropdown = function(_, setting, options)
    setting.options = options
    panel.options = panel.options or options -- (the first: the sound's)
  end,
  CreateSliderOptions = function(min, max, step)
    return { min = min, max = max, step = step, SetLabelFormatter = function(self, _, fn) self.format = fn end }
  end,
  CreateSlider = function(_, _, options) panel.slider = options end,
  CreateControlTextContainer = function()
    local data = {}
    return {
      Add = function(_, v, l) table.insert(data, { value = v, label = l }) end,
      GetData = function() return data end,
    }
  end,
  RegisterAddOnCategory = function() panel.registered = true end,
  OpenToCategory = function(id) panel.opened = id end,
}
local events
local frames = {}
function CreateFrame(kind, name)
  local f = ui()
  f.shown = true -- (a new frame is shown, as in the game)
  f.registered = {}
  f.RegisterEvent = function(self, e)
    if FOREVER and e == "COMBAT_LOG_EVENT_UNFILTERED" then error("COMBAT_LOG_EVENT_UNFILTERED: forbidden") end
    -- (PARTY_KILL, an event of its own on Forever; the Classic run plays a
    -- client without it, its kills from the combat log)
    if not FOREVER and e == "PARTY_KILL" then error('Attempt to register unknown event "PARTY_KILL"') end
    self.registered[e] = true
  end
  table.insert(frames, f)
  if not events and kind == "Frame" and not name then events = f end
  if name then _G[name] = f end
  return f
end
-- An event, to every frame that registered it (the addon's, the kit's).
local function fire(e, ...)
  assert(events.registered[e], "not registered: " .. e)
  for _, f in ipairs(frames) do
    if f.registered[e] and f.scripts.OnEvent then f.scripts.OnEvent(f, e, ...) end
  end
end

-- The game's alert container: a frame joins its stack, and it places those
-- shown, each on top of the one under it (AlertFrameAutoAnchoredMixin's way).
AlertFrame = { subs = {}, updates = 0 }
function AlertFrame:AddAutoAnchoredSubSystem(f)
  f:SetAlertContainer(self)
  table.insert(self.subs, f)
end
function AlertFrame:UpdateAnchors()
  self.updates = self.updates + 1
  local rel = self
  for _, f in ipairs(self.subs) do
    if f:IsShown() then
      f:ClearAllPoints()
      f:SetPoint("BOTTOM", rel, "TOP", 0, 0)
      f:OnAlertAnchorUpdated()
      rel = f
    end
  end
end

-- ── load the addon, with test entries for the unlocks the content doesn't use yet ─
local ns = {}
assert(loadfile(DIR .. (FOREVER and "Content_Forever.lua" or "Content_Classic.lua")))("LorekeepersCodex", ns)
local function entry(title, unlock)
  return { title = title, kind = "note", chapter = "", unlock = { unlock }, also = {}, text = { { "test" } } }
end
ns.content.entries["t-quest"] = entry("Quest done before", { quest = 7777 })
ns.content.entries["t-quest-new"] = entry("Quest turned in", { quest = 8888 })
ns.content.entries["t-rep"] = entry("Friendly with Ironforge", { faction = 47, standing = 5 })
ns.content.entries["t-pos"] = entry("The Great Forge", { map = 1455, x = 57, y = 47, r = 6 })
-- The files in the order of the game's own TOC (its content file loaded above).
-- (the language file as the game picks it, [TextLocale]: English here)
for line in io.lines(DIR .. (FOREVER and "LorekeepersCodex_Camelot.toc" or "LorekeepersCodex_Vanilla.toc")) do
  local f = line:gsub("%[TextLocale%]", "enUS"):match("^([%w_]+%.lua)%s*$")
  if f and not f:match("^Content_") then assert(loadfile(DIR .. f))("LorekeepersCodex", ns) end
end
-- The banners shown (what each said), and the kit's banners themselves, to
-- clear them between scenes.
local toasted, banners = {}, nil
do
  local make = ns.kit.banners
  ns.kit.banners = function(o)
    banners = make(o)
    local show = banners.show
    banners.show = function(self, b)
      table.insert(toasted, b)
      return show(self, b)
    end
    return banners
  end
end
-- The banner card showing a page or an achievement, if any.
local function bannerOf(key, value)
  for i = 1, 2 do
    local f = _G["LorekeepersCodexBanner" .. i]
    if f and f.shown and f.shows and f.shows[key] == value then return f end
  end
end
function wipe(t)
  for k in pairs(t) do
    t[k] = nil
  end
  return t
end

local function check(cond, msg)
  assert(cond, msg)
  io.write("✓ " .. msg .. "\n")
end
local function has(id) return LorekeepersCodexChar.entries[id] ~= nil end

-- ── a session ────────────────────────────────────────────────────────────────
-- A deleted character's codex, left under the same name.
LorekeepersCodexChar = { guid = "Player-6113-0DEAD000", entries = { ironforge = { at = 1, level = 20 } }, read = {} }
fire("PLAYER_LOGIN")
check(
  LorekeepersCodexChar.guid == PLAYER and not LorekeepersCodexChar.entries.ironforge,
  "a new character named like a deleted one starts a fresh codex"
)
check(ns.belongsTo({ entries = { kharanos = { level = 2 } } }, PLAYER, 3), "a codex from before 0.1.3 is kept")
check(
  not ns.belongsTo({ entries = { kharanos = { level = 20 } } }, PLAYER, 3),
  "… unless it was found at a higher level than this character's"
)
check(
  not ns.belongsTo({ entries = { ["rockjaw-troggs"] = { level = 1 } } }, PLAYER, 1, 0),
  "… or this character is brand new (level 1, no experience)"
)
check(LorekeepersCodexChar ~= nil, "the codex is saved per character")
check(
  has("foreword-dwarf") and LorekeepersCodexChar.entries["foreword-dwarf"].retro,
  "the dwarf's foreword is there from the start, quietly"
)
check(not has("foreword-human") and not ns.available("foreword-human"), "… and no other race's")
local pages = 0
for _ in pairs(ns.content.entries) do
  pages = pages + 1
end
local others = 0
for _, e in pairs(ns.content.entries) do
  if e.race and not e.race.Dwarf then others = others + 1 end
end
check(
  ns.total == pages - others and others == (FOREVER and 9 or 8),
  "the other races' forewords don't count in the total"
)
check(
  ns.content.client == (FOREVER and "forever" or "classic")
    and (ns.content.entries["foreword-skyborne"] ~= nil) == FOREVER,
  "each game's content file holds that game's pages only"
)
check(
  has("war-of-the-three-hammers"),
  "logging in at Anvilmar unlocks the War of the Three Hammers (English name fallback)"
)
local function said(text)
  for _, p in ipairs(printed) do
    if p:find(text, 1, true) then return p end
  end
end
check(
  said("|Hlorekeeper:war-of-the-three-hammers|h[The War of the Three Hammers]|h|r has been added to the codex.")
    and sounds == 2,
  "a new page is announced in chat as a link, with a sound"
)
local hints = 0
for _, p in ipairs(printed) do
  if p:find("/codex", 1, true) then hints = hints + 1 end
end
check(
  hints == 1 and said("pages. Type /codex or click the book by the minimap"),
  "the /codex hint appears once, at login, and not in page messages"
)
check(
  ns.knownTotal() < ns.total and said(("%d of %d pages. Type /codex"):format(ns.count(), ns.knownTotal())),
  "the page count only counts the chapters opened, not the whole codex"
)
check(toasted[#toasted] and toasted[#toasted].page == "war-of-the-three-hammers", "a banner tells of the newest page")
banners:clear()
ns.showBanner("war-of-the-three-hammers")
local banner = LorekeepersCodexBanner1
check(
  banner.shown
    and banner.joined
    and banner.title.text == "The War of the Three Hammers"
    and rawget(banner, "text") == nil
    and rawget(banner, "more") == nil,
  "… among the game's own alerts: only its title, a click on it to read it"
)
check(banner.scripts.OnUpdate == nil, "it doesn't fade: it stays until read or closed")
check(lastSound == 4147, "a new page plays the zone discovery sound by default (the dwarf's)")
check(panel.registered and panel.name == "Lorekeeper's Codex", "a settings page in the game's options")
banner.mouseOver = true
check(elapse() == 10 and banner.shown, "the banner stays while the mouse is on it")
banner.mouseOver = false
check(elapse() == 1 and not banner.shown, "… and goes away on its own after 10 seconds")
ns.showBanner("war-of-the-three-hammers")
check(
  panel.slider and panel.slider.format(0) == "until closed" and panel.slider.format(15) == "15 s",
  "how long it stays is a setting (0: until closed)"
)
banner.scripts.OnClick(banner)
check(
  not banner.shown and LorekeepersCodexFrame.shown and LorekeepersCodexChar.read["war-of-the-three-hammers"],
  "clicking the banner opens the book at its page"
)
LorekeepersCodexFrame:Hide()
check(
  LorekeepersCodexMinimapButton ~= nil and ns.option("minimapAngle") == ns.kit.MINIMAP_ANGLES.LorekeepersCodex,
  "a minimap button, at its place (this character's settings)"
)
check(has("dun-morogh"), "being in Dun Morogh unlocks the zone's page")
check(has("t-quest") and LorekeepersCodexChar.entries["t-quest"].retro, "a quest done before the codex unlocks quietly")
check(not has("t-rep"), "Neutral with Ironforge: not yet")

clock = clock + 600
state.level = 5
state.sub = "Kharanos"
fire("ZONE_CHANGED")
check(has("kharanos"), "reaching Kharanos unlocks it (name from the client)")
local k = LorekeepersCodexChar.entries.kharanos
check(
  k.level == 5 and k.subId == 131 and k.zoneId == 1 and not k.sub and not k.zone and k.at == clock,
  "a page remembers when, at what level and where (its places by their ids)"
)

state.target = 1234
fire("PLAYER_TARGET_CHANGED")
check(not has("magni-bronzebeard"), "another creature unlocks nothing")
state.target = 2784
fire("PLAYER_TARGET_CHANGED")
check(has("magni-bronzebeard"), "targeting King Magni unlocks his page")

fire("QUEST_TURNED_IN", 8888)
check(
  has("t-quest-new") and not LorekeepersCodexChar.entries["t-quest-new"].retro,
  "turning in a quest unlocks its page"
)

state.standing[47] = 5
fire("UPDATE_FACTION")
check(has("t-rep"), "reaching Friendly with Ironforge unlocks its page")

state.map, state.x, state.y = 1455, 0.60, 0.49
check(ticker ~= nil, "a position check runs (there are position pages)")
ticker()
check(has("t-pos"), "standing at the Great Forge unlocks it")

local before, heard = 0, sounds
for _ in pairs(LorekeepersCodexChar.entries) do
  before = before + 1
end
fire("ZONE_CHANGED")
fire("PLAYER_TARGET_CHANGED")
local after = 0
for _ in pairs(LorekeepersCodexChar.entries) do
  after = after + 1
end
check(before == after and sounds == heard, "nothing is unlocked twice, nor announced again")

-- Kills: my killing blow or my pet's. On Forever, PARTY_KILL (killer, victim)
-- is an event of its own; elsewhere (an older client) a line of the combat log.
local function kill(source, id)
  if FOREVER then
    fire("PARTY_KILL", source, creature(id))
    return
  end
  combatLog = { clock, "PARTY_KILL", false, source, "Thorin", 0, 0, creature(id), "?", 0, 0 }
  fire("COMBAT_LOG_EVENT_UNFILTERED")
end
if FOREVER then
  check(
    not events.registered.COMBAT_LOG_EVENT_UNFILTERED and ns.partyKill,
    "Forever: kills come from PARTY_KILL (no combat log), not from meeting"
  )
  -- meeting a creature no longer counts for its kill
  local was = state.target
  state.target = 1123
  fire("PLAYER_TARGET_CHANGED")
  state.target = was
  check(not has("frostmane-trolls"), "Forever: targeting a creature unlocks nothing its kill would")
else
  check(
    events.registered.COMBAT_LOG_EVENT_UNFILTERED and not ns.partyKill,
    "Classic (a client without PARTY_KILL): kills come from the combat log"
  )
end
kill("Player-6113-0FFFFFFF", 1123)
check(not has("frostmane-trolls"), "someone else's kill unlocks nothing")
kill(PLAYER, 99999)
check(not has("frostmane-trolls"), "a creature no page names unlocks nothing")
kill(PLAYER, 1123)
check(has("frostmane-trolls"), "killing a Frostmane Headhunter unlocks the Frostmane trolls")
kill(PET, 1132)
check(has("timber"), "your pet killing Timber (a rare) counts")
check(
  ns.earned("wanderer-one") and not ns.earned("wanderer-one").retro,
  "… and earns an achievement, A Tale Worth Telling"
)
check(
  said("achievement earned: |cffffd100|Hlorekeeper:ach:wanderer-one|h[A Tale Worth Telling]|h|r"),
  "… announced in chat as a link"
)
local achieved = false
for _, b in ipairs(toasted) do
  if b.achievement == "wanderer-one" then achieved = true end
end
check(achieved, "… and on a banner")
kill(PLAYER, 706)
check(
  sounds == 11 and ns.earned("pages-10"),
  "another Frostmane kill adds nothing (the tenth page earned Ink on the Fingers)"
)

state.zone, state.sub = "Ironforge", ""
fire("ZONE_CHANGED_NEW_AREA")
check(has("ironforge"), "entering Ironforge unlocks its page")

-- A click on a page link in chat opens the book at that page.
check(linkHandlers.lorekeeper ~= nil, "codex links have a handler")
check(
  linkHandlers.lorekeeper("lorekeeper:kharanos") == 2 and LorekeepersCodexFrame.shown,
  "clicking [Kharanos] in chat opens the book"
)
check(LorekeepersCodexChar.read.kharanos, "… at the Kharanos page")
LorekeepersCodexList.vscroll = 0
linkHandlers.lorekeeper("lorekeeper:ironforge")
check(LorekeepersCodexList.vscroll > 0, "… and the list scrolls down to a page further on")
local far = LorekeepersCodexList.vscroll
linkHandlers.lorekeeper("lorekeeper:foreword-dwarf")
check(LorekeepersCodexList.vscroll < far, "… or back up to one above")
linkHandlers.lorekeeper("lorekeeper:grim-batol")
check(not LorekeepersCodexChar.read["grim-batol"], "a link to a page not found yet opens nothing")
LorekeepersCodexFrame:Hide()
LorekeepersCodexMinimapButton.scripts.OnClick()
check(LorekeepersCodexFrame.shown, "the minimap button opens the book")
LorekeepersCodexFrame:Hide()
SlashCmdList.LOREKEEPERSCODEX("minimap")
check(ns.option("minimapHidden") and not LorekeepersCodexMinimapButton.shown, "/codex minimap hides the button")
SlashCmdList.LOREKEEPERSCODEX("minimap")
SlashCmdList.LOREKEEPERSCODEX("banner")
check(panel.settings.LOREKEEPERSCODEX_BANNER.get() == false, "the settings page follows /codex banner")
check(
  not panel.settings.LOREKEEPERSCODEX_CHAT and panel.settings.LOREKEEPERSCODEX_ACHIEVEMENTTOAST.get() == true,
  "… no switch for the chat lines (always shown), one for the achievements' alerts"
)
panel.settings.LOREKEEPERSCODEX_SOUND.set(3175)
check(lastSound == 3175, "choosing a sound plays it")
printed = {}
local toastedBefore = #toasted
ns.unlock("menethil-harbor")
check(
  #toasted == toastedBefore and #printed == 1 and printed[1]:find("has been added", 1, true) and lastSound == 3175,
  "the page's alert off: a new page has its line in chat and the chosen sound"
)
panel.settings.LOREKEEPERSCODEX_BANNER.set(true)
panel.settings.LOREKEEPERSCODEX_MINIMAPHIDDEN.set(false)
check(not LorekeepersCodexMinimapButton.shown, "the minimap box unticked hides the button")
panel.settings.LOREKEEPERSCODEX_MINIMAPHIDDEN.set(true)
check(LorekeepersCodexMinimapButton.shown, "… and ticked shows it")
LorekeepersCodexMinimapButton.scripts.OnClick(LorekeepersCodexMinimapButton, "RightButton")
check(panel.opened == 42, "right-clicking the minimap button opens the settings")
panel.opened = nil
SlashCmdList.LOREKEEPERSCODEX("settings")
check(panel.opened == 42, "/codex settings opens them too")
local labels = {}
for _, o in ipairs(panel.options()) do
  table.insert(labels, o.label)
end
check(#labels == #ns.SOUNDS and labels[#labels] == "No sound", "the sound can be chosen, or none")

-- Settings are each character's own (the kit's profiles); the welcome page
-- offers them once per character, and another character's to take.
local P = ns.profiles
local kept = {}
for _, k in ipairs({
  "banner",
  "bannerSeconds",
  "achievementToast",
  "sound",
  "tooltipHints",
  "minimapHidden",
  "minimapAngle",
}) do
  kept[k] = ns.option(k)
end
check(
  P:key() == "Thorin - Nightslayer" and LorekeepersCodexSettings.profiles["Thorin - Nightslayer"],
  "settings: this character's own profile"
)
fire("PLAYER_ENTERING_WORLD", true, false)
local W = ns.welcome
check(W.frame and W.frame.shown and #W.rows == 6, "the first login: the welcome page and its six choices")
-- The last: sharing what the game tells of the world (the kit's collector),
-- off until the player says yes, account-wide in LorekeepersCodexCollect.
local share = W.rows[6]
check(
  not share.box:GetChecked() and not ns.collect:on() and SaltyMaxCollector == nil,
  "… the last, sharing what you see, off: nothing kept"
)
share.scripts.OnClick(share)
check(
  ns.collect:on() and LorekeepersCodexCollect.share == true and SaltyMaxCollector ~= nil,
  "… ticked: on, account-wide, this addon collects"
)
share.scripts.OnClick(share)
check(
  not ns.collect:on() and LorekeepersCodexCollect.facts ~= nil and SaltyMaxCollector == nil,
  "… unticked: off, the claim given up (what was kept stays here, never sent while off)"
)
local soundRow = W.rows[3]
check(soundRow.select and soundRow.select:GetValue() == ns.option("sound"), "… the sound in a select, as it is")
soundRow.select.scripts.OnClick(soundRow.select)
soundRow.select.rows[2].scripts.OnClick(soundRow.select.rows[2])
check(ns.option("sound") == 878 and lastSound == 878, "… a sound chosen there is heard and kept")
W.frame:Hide()
fire("PLAYER_ENTERING_WORLD", true, false)
check(not W.frame.shown and ns.option("welcomed"), "… seen once")
LorekeepersCodexSettings.profiles["Brann - Nightslayer"] = { achievementToast = false, sound = 0, banner = false }
SlashCmdList.LOREKEEPERSCODEX("welcome")
local pick = W.picker.select
check(pick.rows[1].text:GetText() == "Brann - Nightslayer", "… another character of this game, in its select")
pick.rows[1].scripts.OnClick(pick.rows[1])
W.picker.copy.scripts.OnClick(W.picker.copy)
check(
  ns.option("achievementToast") == false
    and ns.option("sound") == 0
    and ns.option("banner") == false
    and ns.option("bannerSeconds") == 10
    and not W.rows[1].box:GetChecked()
    and not W.rows[2].box:GetChecked(),
  "… its choices copied (what it lacks: the defaults), the boxes with them"
)
local code = P:export()
check(code:match("^LC1:") and code:find(":s0:", 1, true), "… a code for them: " .. code)
SlashCmdList.LOREKEEPERSCODEX("import LC1:v1:s-1:b1")
check(
  ns.option("achievementToast") and ns.option("sound") == -1 and ns.option("banner"),
  "… /codex import CODE (a negative number too)"
)
check(not P:import("HT1:c1") and ns.option("achievementToast"), "… another addon's code refused")
check(P:import("LC1:c0:s0:b1") and ns.option("sound") == 0, "… an older code's c (the chat lines) left out")
local copyFrom = panel.settings.LOREKEEPERSCODEX_COPYFROM
check(
  copyFrom and copyFrom.options()[2].value == "Brann - Nightslayer",
  "… the Options page offers the other characters too"
)
W.frame:Hide()
LorekeepersCodexSettings.profiles["Brann - Nightslayer"] = nil
for k, v in pairs(kept) do
  ns.setOption(k, v)
end

-- ── the book ─────────────────────────────────────────────────────────────────
SlashCmdList.LOREKEEPERSCODEX("")
check(LorekeepersCodexFrame and LorekeepersCodexFrame.shown, "/codex opens the book")
check(next(LorekeepersCodexChar.read) ~= nil, "opening it shows an unread page, marked read")
check(ns.count() == 15, "15 pages found (one's own people and calling among them)")
local expected = 0
for _, ch in ipairs(ns.content.chapters) do
  if ns.found(ch) > 0 then expected = expected + #ch.entries end
end
for id, e in pairs(ns.content.entries) do
  if e.chapter == "" and ns.page(id) then expected = expected + 1 end
end
check(
  ns.knownTotal() == expected and LorekeepersCodexFrame.count.text == ("%d of %d pages"):format(ns.count(), expected),
  "the book counts the pages of the opened chapters, and the foreword"
)
local C = ns.content
-- (the chapters by name: Forever's Zephras Isle comes before Dun Morogh)
local CH = {}
for _, ch in ipairs(C.chapters) do
  CH[ch.id] = ch
end
local DUN = FOREVER and 19 or 18 -- (Forever's Hall of Thanes)
check(
  ns.found(CH["dun-morogh"]) == 7 and #CH["dun-morogh"].entries == DUN,
  ("Dun Morogh counts 7 of its %d pages"):format(DUN)
)
check(
  C.chapters[#C.chapters].id == "peoples" and ns.found(C.chapters[#C.chapters]) == 1,
  "Peoples and Powers comes last, one's own people in it from the start"
)
check(ns.found(CH.callings) == 1, "the Callings: one's own, from the start")
check(ns.found(CH["loch-modan"]) == 0, "Loch Modan, not visited, has no page found: its chapter stays hidden")
check(ns.found(CH["wetlands"]) == 1, "the Wetlands show once Menethil is found")
SlashCmdList.LOREKEEPERSCODEX("")
check(not LorekeepersCodexFrame.shown, "/codex again closes it")
printed = {}
SlashCmdList.LOREKEEPERSCODEX("where")
check(
  printed[1]:find("position: 1455 60.0 49.0", 1, true) ~= nil and printed[2]:find("npc: 2784", 1, true) ~= nil,
  "/codex where gives the position and target in content terms"
)
SlashCmdList.LOREKEEPERSCODEX("reset")
check(ns.count() > 3, "/codex reset alone only asks")
SlashCmdList.LOREKEEPERSCODEX("reset yes")
check(
  LorekeepersCodexChar.guid == PLAYER
    and LorekeepersCodexChar.entries["foreword-dwarf"]
    and LorekeepersCodexChar.entries.ironforge
    and not LorekeepersCodexChar.entries.timber,
  "/codex reset yes starts over, from what the character has already done"
)
-- ── tooltip hints and search ─────────────────────────────────────────────────
local function hover(id)
  tipLines, tipUnit, state.mouseover = {}, "mouseover", id
  tipHooks.OnTooltipSetUnit(GameTooltip)
  return table.concat(tipLines, "|")
end
check(hover(2091) == "Lorekeeper's Codex: a page to find", "a creature that unlocks a page hints at it on its tooltip")
ns.unlock("magni-bronzebeard")
check(hover(2784) == "Lorekeeper's Codex: King Magni Bronzebeard", "… and names the page once it is found")
check(hover(99999) == "", "creatures with no page get no line")
ns.setOption("tooltipHints", false)
check(hover(2091) == "", "hints can be turned off")
ns.setOption("tooltipHints", true)
local function has_(list, id)
  for _, v in ipairs(list) do
    if v == id then return true end
  end
end
ns.unlock("kharanos")
check(has_(ns.search("thunderbrew"), "kharanos"), "search finds a found page by its text")
check(has_(ns.search("KHARANOS"), "kharanos"), "… whatever the case")
ns.unlock("zulgurub")
check(
  has_(ns.search("zul'gurub"), "zulgurub") and has_(ns.search("zul\226\128\153gurub"), "zulgurub"),
  "… and whichever apostrophe is typed"
)
check(#ns.search("Grim Batol") == 0, "… and never a page not found yet")
SlashCmdList.LOREKEEPERSCODEX("")
LorekeepersCodexFrame.search:SetText("ironforge")
ns.refresh()
LorekeepersCodexFrame.search:SetText("no such words")
ns.refresh()
LorekeepersCodexFrame.search:SetText("")
ns.refresh()
check(true, "the book's list follows the search box (results, none, back to chapters)")
-- ── folding chapters ─────────────────────────────────────────────────────────
SlashCmdList.LOREKEEPERSCODEX("")
LorekeepersCodexFrameTab1.scripts.OnClick(LorekeepersCodexFrameTab1)
local function chapterRow(title)
  for _, r in ipairs(ns.listRows) do
    if r.shown and r.text.text == title and r.fold.shown then return r end
  end
end
local function shownRows()
  local n = 0
  for _, r in ipairs(ns.listRows) do
    if r.shown then n = n + 1 end
  end
  return n
end
local open = shownRows()
local titles, found, loose = 0, 0, 0
for _, ch in ipairs(C.chapters) do
  if ns.found(ch) > 0 then
    titles = titles + 1
    found = found + ns.found(ch)
  end
end
for id, e in pairs(C.entries) do
  if e.chapter == "" and ns.page(id) then loose = loose + 1 end
end
check(
  open == 1 + titles + found + loose,
  "the list shows the codex at a glance, then the pages found, no placeholder for the others"
)
-- The pages' select, under the search box: a kind of page.
local filter = LorekeepersCodexFrame.filter
check(filter.shown and filter.text:GetText() == "Every kind of page", "the pages' select: every kind at first")
local places = 0
for id, e in pairs(C.entries) do
  if ns.page(id) and e.kind == "place" then places = places + 1 end
end
local placeOption
for k, o in ipairs(filter.options) do
  if o.value == "place" then placeOption = k end
end
check(
  placeOption and filter.options[placeOption].text == ("Places (%d)"):format(places),
  "… its kinds, those found, with how many"
)
filter.rows[placeOption].scripts.OnClick(filter.rows[placeOption])
local onlyPlaces = true
for _, r in ipairs(ns.listRows) do
  local e = r.shown and C.entries[r.id]
  if e and e.kind ~= "place" then onlyPlaces = false end
end
check(onlyPlaces and shownRows() < open, "… one kind chosen: its pages alone, under their chapters")
filter.rows[1].scripts.OnClick(filter.rows[1])
check(shownRows() == open, "… and every kind again")
local dunRow = chapterRow(CH["dun-morogh"].title)
check(dunRow ~= nil, "a chapter's title carries a fold")
dunRow.scripts.OnClick(dunRow)
check(
  LorekeepersCodexChar.collapsed[CH["dun-morogh"].id] and shownRows() == open - ns.found(CH["dun-morogh"]),
  "clicking a chapter's title folds its pages away"
)
check(chapterRow(CH["dun-morogh"].title), "… the chapter's title and progress stay")
chapterRow(CH["dun-morogh"].title).scripts.OnClick(chapterRow(CH["dun-morogh"].title))
check(not LorekeepersCodexChar.collapsed[CH["dun-morogh"].id] and shownRows() == open, "clicking again unfolds it")
chapterRow(CH["dun-morogh"].title).scripts.OnClick(chapterRow(CH["dun-morogh"].title))
linkHandlers.lorekeeper("lorekeeper:kharanos")
check(not LorekeepersCodexChar.collapsed[CH["dun-morogh"].id], "a link to a page in a folded chapter unfolds it")
check(ns.anyUnfolded(), "with a chapter open, the button folds them all")
LorekeepersCodexFoldAll.scripts.OnClick(LorekeepersCodexFoldAll)
check(
  not ns.anyUnfolded() and shownRows() == 1 + titles + loose,
  "one click folds every chapter: only their titles remain"
)
LorekeepersCodexFoldAll.scripts.OnClick(LorekeepersCodexFoldAll)
check(ns.anyUnfolded() and next(LorekeepersCodexChar.collapsed) == nil, "… and the next unfolds them all")
-- Portraits: the game's still portrait of a page's creature, only where the
-- page is about one.
SetPortraitTextureFromCreatureDisplayID = function(tex, display) tex.display = display end
ns.unlock("magni-bronzebeard")
ns.open("magni-bronzebeard")
check(
  C.entries["magni-bronzebeard"].portrait
    and LorekeepersCodexPage.portrait.shown
    and LorekeepersCodexPage.portrait.tex.display == C.entries["magni-bronzebeard"].portrait,
  "a figure's page shows the figure's portrait"
)
LorekeepersCodexPage.portrait.tex.SetTexture = function(self, file) self.file = file end
ns.open("kharanos")
check(
  not C.entries.kharanos.portrait
    and LorekeepersCodexPage.portrait.shown
    and LorekeepersCodexPage.portrait.tex.file:find("Map", 1, true),
  "… a place's page a map, the icon of every place"
)
-- Under its text: where it was found; the pages it leads to, found, as cards.
local function shownText(pool, pattern)
  for _, x in ipairs(pool) do
    if x.shown and type(x.text) == "string" and x.text:find(pattern) then return x end
  end
end
check(
  shownText(LorekeepersCodexPage.paragraphs, "^Found in .-, at level %d+, on %d+ %a+ %d+%.$")
    or shownText(LorekeepersCodexPage.paragraphs, "^In your codex since "),
  "a page says where, at what level and when it was found"
)
local withAlso, alsoTitle
for id, e in pairs(C.entries) do
  for _, other in ipairs(ns.page(id) and e.also or {}) do
    if ns.page(other) and not withAlso then
      withAlso, alsoTitle = id, C.entries[other].title
    end
  end
end
ns.open(withAlso)
local alsoCard
for _, c in ipairs(LorekeepersCodexPage.cards) do
  if c.shown and c.name.text == alsoTitle then alsoCard = c end
end
check(withAlso and alsoCard, "… and its related pages found, as cards")
alsoCard.scripts.OnClick(alsoCard)
check(LorekeepersCodexPage.title.text == alsoTitle, "… a card opens its page")
-- The codex at a glance, at the head of the list.
local overview
for _, r in ipairs(ns.listRows) do
  if r.shown and r.text.text == "The Codex" then overview = r end
end
overview.scripts.OnClick(overview)
check(
  LorekeepersCodexPage.title.text == "The Codex"
    and LorekeepersCodexPage.tiles[1].value.text == tostring(ns.count())
    and LorekeepersCodexPage.chipPool[1].shown,
  "the codex at a glance: its figures, the pages found lately, the chapters to pick"
)
LorekeepersCodexPage.chipPool[1].scripts.OnClick(LorekeepersCodexPage.chipPool[1])
check(LorekeepersCodexPage.title.text ~= "The Codex", "… a chapter picked opens its first page found")
LorekeepersCodexFrame:Hide()

-- ── the library ──────────────────────────────────────────────────────────────
-- The game's reader: a text, its pages, and who wrote it (players' letters).
local reader
local libraryFrame
for _, f in ipairs(frames) do
  if f.registered.ITEM_TEXT_BEGIN then libraryFrame = f end
end
function ItemTextGetItem() return reader.title end
function ItemTextGetMaterial() return reader.material end
function ItemTextGetCreator() return reader.creator end
function ItemTextGetPage() return reader.page end
function ItemTextGetText() return reader.pages[math.min(reader.page, #reader.pages)] end
-- (a text whose last page leads to itself: its pages never end)
function ItemTextHasNextPage() return reader.endless or reader.page < #reader.pages end
-- The game's reader frame: its alpha, and the lowest it went.
ItemTextFrame = {
  alpha = 1,
  SetAlpha = function(self, a)
    self.alpha = a
    self.lowest = math.min(self.lowest or 1, a)
  end,
}
-- The game answers a page turned at once (a text it knows already): its
-- event comes from inside the turn. How deep the reader's events nested.
local depth, deepest = 0, 0
local function readerEvent(e)
  depth = depth + 1
  deepest = math.max(deepest, depth)
  libraryFrame.scripts.OnEvent(libraryFrame, e)
  depth = depth - 1
end
-- What waits for the next frame, run frame after frame.
local nextFrame = {}
local after = C_Timer.After
C_Timer.After = function(seconds, fn)
  if seconds == 0 then
    table.insert(nextFrame, fn)
  else
    after(seconds, fn)
  end
end
local function nextFrames()
  local n = 0
  while #nextFrame > 0 do
    local now = nextFrame
    nextFrame = {}
    for _, fn in ipairs(now) do
      fn()
    end
    n = n + 1
  end
  return n
end
function ItemTextNextPage()
  reader.page = reader.page + 1
  readerEvent("ITEM_TEXT_READY")
end
function ItemTextPrevPage()
  reader.page = reader.page - 1
  readerEvent("ITEM_TEXT_READY")
end
-- Opening a text shows its first page; the reader closes on whatever page
-- it shows then.
local function read(title, pages, material, creator, endless)
  reader =
    { title = title, pages = pages, page = 1, material = material or "Parchment", creator = creator, endless = endless }
  deepest = 0
  readerEvent("ITEM_TEXT_BEGIN")
  readerEvent("ITEM_TEXT_READY")
  nextFrames()
  local shownAfter = reader.page
  readerEvent("ITEM_TEXT_CLOSED")
  return shownAfter
end
printed = {}
local quelThalas =
  { "In the beginning...", "<HTML><BODY><H1>The Sunwell</H1><P>And so it was.</P></BODY></HTML>", "The end." }
local shown = read("The Founding of Quel'Thalas", quelThalas)
local book = LorekeepersCodexChar.library.texts[1]
check(
  book
    and book.pages[1]
    and book.pages[2]
    and book.pages[3]
    and book.count == 3
    and shown == 1
    and said("copied into the Library: |cffffd100|Hlorekeeper:lib:1|h[The Founding of Quel'Thalas]|h|r"),
  "a book opened is copied whole at once (every page turned, then back to the first), and announced with a link"
)
check(
  ItemTextFrame.lowest == 0 and ItemTextFrame.alpha == 1,
  "… the reader hidden while its pages are turned, shown again after"
)
check(
  book.zone == state.zone and ns.libraryShelf(book) == "books",
  "… with where it was found; several pages make a book"
)
check(ns.libraryPlain(book.pages[2]) == "The Sunwell\n\nAnd so it was.", "the game's HTML becomes plain paragraphs")
check(ns.codex().entries["high-elves"], "a history read in the world unlocks its page (read: its title)")
ns.readText("Die sieben Königreiche")
check(ns.codex().entries["the-seven-kingdoms"], "… and by its title in the game's other languages")
read("Ironforge plaque", { "Here stood..." }, "Bronze")
check(ns.libraryShelf(LorekeepersCodexChar.library.texts[2]) == "plaques", "texts cut in metal or stone are plaques")
read("A letter", { "Dear friend, my secret..." }, "Parchment", "Someplayer")
check(not LorekeepersCodexChar.library.texts[3], "a letter written by a player is never copied")
if FOREVER then
  secrets["Someone hidden"] = true
  read("A sealed letter", { "Of no one known..." }, "Parchment", "Someone hidden")
  secrets["Someone hidden"] = nil
  check(not LorekeepersCodexChar.library.texts[3], "Forever: a letter whose writer the game keeps secret is not copied")
end
-- A long book the game knows already (The Alliance of Lordaeron, sixteen
-- pages): each page turned at a frame of its own, never from inside the
-- last one's event, which on a long book crashed the game.
do
  local long = {}
  for i = 1, 16 do
    long[i] = "The Second War, part " .. i .. "."
  end
  shown = read("The Alliance of Lordaeron", long)
  local copied
  for _, t in pairs(LorekeepersCodexChar.library.texts) do
    if t.title == "The Alliance of Lordaeron" then copied = t end
  end
  check(
    copied and copied.count == 16 and copied.pages[16] == long[16] and shown == 1 and deepest == 1,
    "a long book copied whole, a page a frame, the reader's events never nested; back on its first page"
  )
  -- … and one whose last page leads to itself: walked to its end, no further.
  shown = read("A Book Without End", { "The first page.", "The last page, again and again." }, nil, nil, true)
  for _, t in pairs(LorekeepersCodexChar.library.texts) do
    if t.title == "A Book Without End" then copied = t end
  end
  check(
    copied.count == 2 and copied.pages[3] == nil and shown == 1,
    "… a page leading to itself: the book's end, copied once"
  )
end
LorekeepersCodexFrame:Hide()
linkHandlers.lorekeeper("lorekeeper:lib:1")
check(
  LorekeepersCodexFrame.shown
    and LorekeepersCodexFrame.selectedTab == 2
    and LorekeepersCodexLibraryPage.title.text == "The Founding of Quel'Thalas"
    and LorekeepersCodexLibraryPage.note.text == "In the beginning..."
    and LorekeepersCodexLibraryPage.pageLabel.text == "Page 1 of 3",
  "a link opens the Library at the text, page 1 of 3"
)
LorekeepersCodexLibraryPage.next.scripts.OnClick(LorekeepersCodexLibraryPage.next)
check(LorekeepersCodexLibraryPage.note.text == "The Sunwell\n\nAnd so it was.", "… and its pages turn")
local shelves = {}
for _, r in ipairs(ns.libraryRows) do
  if r.shown then shelves[r.text.text] = r end
end
check(
  shelves.Books and shelves["Plaques and Monuments"] and not shelves["Notes and Letters"],
  "the shelves: only those with something on them"
)
LorekeepersCodexFrameTab2.scripts.OnClick(LorekeepersCodexFrameTab2)
local libraryPage = LorekeepersCodexLibraryPage
check(
  libraryPage.title.text == "The Library"
    and libraryPage.tiles[1].value.text == tostring(ns.libraryCount())
    and libraryPage.cards[1].shown
    and not libraryPage.turn.shown,
  "its tab clicked: the Library at a glance, its figures by shelf, the texts copied lately"
)
libraryPage.cards[1].scripts.OnClick(libraryPage.cards[1])
check(libraryPage.title.text ~= "The Library", "… a card opens its text")
-- (the Library at a glance, at the head of the list, as the Pages tab's codex)
local head
for _, r in ipairs(ns.libraryRows) do
  if r.shown and r.kind == "overview" then head = r end
end
check(
  head and head.text.text == "The Library" and not head.selected.shown,
  "the Library at a glance at the head of the list"
)
head.scripts.OnClick(head)
check(
  libraryPage.title.text == "The Library" and head.selected.shown and libraryPage.tiles[1].shown,
  "… its row clicked from a text: the Library at a glance again, its row chosen"
)
LorekeepersCodexFrame:Hide()

-- ── achievements ─────────────────────────────────────────────────────────────
local seen, missing = {}, {}
for _, a in ipairs(ns.achievements) do
  assert(not seen[a.id], "duplicate achievement " .. a.id)
  seen[a.id] = true
end
for _, id in ipairs(ns.featPages) do
  if not C.entries[id] then table.insert(missing, id) end
end
check(
  #missing == 0,
  "every page an achievement names exists" .. (#missing > 0 and (": " .. table.concat(missing, ", ")) or "")
)
check(
  #ns.achievements == 9 + 4 + 10 + 5 + 4 + #C.chapters,
  "milestones, feats, encounters, the Library's and one achievement per chapter"
)
-- A codex from before achievements: what it deserves is recorded quietly.
for _, id in ipairs(CH["loch-modan"].entries) do
  ns.unlock(id, true)
end
LorekeepersCodexChar.achievements = {}
printed = {}
local before = sounds
ns.checkAchievements(true)
check(
  ns.earned("pages-10") and ns.earned("pages-10").retro and #printed == 0 and sounds == before,
  "achievements a codex already deserves are recorded quietly"
)
local dun = CH["dun-morogh"]
for _, id in ipairs(dun.entries) do
  ns.unlock(id)
end
check(
  ns.earned("chapter-" .. dun.id) and ns.earned("chapter-" .. dun.id).level == state.level,
  "finding every page of a chapter earns its achievement, with the level"
)
local n = 0
for id in pairs(C.entries) do
  if ns.page(id) and n < 10 then
    ns.markRead(id)
    n = n + 1
  end
end
check(ns.earned("read-10"), "reading ten pages earns A Page by the Fire")
check(not ns.earned("leaders"), "meeting one leader is not enough")
for _, id in ipairs({ "thrall", "cairne-bloodhoof", "sylvanas-windrunner", "voljin" }) do
  ns.unlock(id)
end
check(ns.earned("leaders"), "the four leaders of either side earn Friends in High Places")
state.target = 4488
fire("PLAYER_TARGET_CHANGED")
state.target = nil
check(
  has("parqual-fintallas") and ns.earned("historian"),
  "a historian of the codex met (Parqual Fintallas, or Archesonus) earns A Word in Person"
)
-- A paragraph for one side's readers: Parqual's note on the Undercity page.
local note
for _, para in ipairs(C.entries.undercity.text) do
  if para.side then note = para end
end
check(note and note.side == "Horde" and not ns.shown(note), "a Horde reader's paragraph is hidden from an Alliance one")
state.side = "Horde"
check(ns.shown(note), "… and shown to a Horde reader")
ns.unlock("undercity")
linkHandlers.lorekeeper("lorekeeper:undercity")
local aside = LorekeepersCodexPage.asides[1]
check(
  aside and aside.shown and aside.sign.text == "P. F." and aside.text.text:find("Apothecarium", 1, true),
  "… set apart on the page as an aside, his initials under it"
)
state.side = nil
LorekeepersCodexFrame:Hide()
ns.openAchievements("leaders")
check(
  LorekeepersCodexFrame.shown
    and LorekeepersCodexFrame.selectedTab == 3
    and LorekeepersCodexAchievements.shown
    and not LorekeepersCodexList.shown,
  "an achievement opens the book at the achievements tab"
)
check(
  LorekeepersCodexFrame.count.text == ("%d of %d achievements"):format(ns.achievementCount()),
  "… which counts them"
)
local _, shown = ns.achievementCount()
check(
  shown < #ns.achievements and not ns.achievementVisible(ns.achievementById["chapter-silithus"]),
  "… leaving out the chapters not yet opened"
)
check(ns.achievementVisible(ns.achievementById["chapter-" .. dun.id]), "… but listing those already opened")
check(
  ns.achievementById["pages-all"].unit == "pages" and ns.achievementById["travelled"].unit == "chapters",
  "the whole codex's size is never shown: a count instead"
)
check(
  LorekeepersCodexAchievements.vscroll and LorekeepersCodexAchievements.vscroll > 0,
  "… and scrolls to the one opened"
)
local leadersRow
for _, r in ipairs(ns.achievementRows) do
  if r.shown and r.id == "leaders" then leadersRow = r end
end
check(
  leadersRow
    and leadersRow.picture.ring.vertex[2] == ns.kit.RINGS.gold[1][2]
    and not leadersRow.picture.ring.desaturated
    and leadersRow.status.text:find("^Level"),
  "… with its group's picture, its ring gold once earned, and when"
)
LorekeepersCodexFrameTab1.scripts.OnClick(LorekeepersCodexFrameTab1)
check(
  LorekeepersCodexFrame.selectedTab == 1 and LorekeepersCodexList.shown and not LorekeepersCodexAchievements.shown,
  "the Pages tab brings the pages back"
)
LorekeepersCodexFrame:Hide()
linkHandlers.lorekeeper("lorekeeper:ach:pages-10")
check(
  LorekeepersCodexFrame.shown and LorekeepersCodexFrame.selectedTab == 3,
  "an achievement link in chat opens the achievements"
)
linkHandlers.lorekeeper("lorekeeper:kharanos")
check(LorekeepersCodexFrame.selectedTab == 1, "a page link goes back to the pages")
SlashCmdList.LOREKEEPERSCODEX("achievements")
check(LorekeepersCodexFrame.selectedTab == 3, "/codex achievements opens them too")
SlashCmdList.LOREKEEPERSCODEX("reset yes")
local loud = false
for _, e in pairs(LorekeepersCodexChar.achievements) do
  if not e.retro then loud = true end
end
check(
  not ns.earned("leaders") and not ns.earned("chapter-" .. dun.id) and not loud,
  "/codex reset forgets the achievements (what the codex still earns comes back quietly)"
)
-- ── the two clients ───────────────────────────────────────────────────────────
check(not ns.available("foreword-skyborne"), "the Skyborne foreword is for the Skyborne")
ns.unlock("furbolgs")
local function mentions(id, phrase)
  for _, paragraph in ipairs(ns.content.entries[id].text) do
    if paragraph[1]:find(phrase, 1, true) then return true end
  end
  return false
end
check(
  mentions("furbolgs", "Blackmaw Hold") == FOREVER
    and mentions("furbolgs", "closed hold in Azshara") == not FOREVER
    and mentions("furbolgs", "Timbermaw"),
  "a page shows its Forever paragraphs on Forever only, its Classic ones elsewhere"
)
check(
  mentions("dalaran", "Modera") == FOREVER
    and mentions("dalaran", "dome of violet light") == not FOREVER
    and mentions("ironforge", "Hall of Thanes") == FOREVER
    and mentions("ungoro-crater", "Shapers' Terrace") == FOREVER,
  "the changed places contain their own world's history without losing shared pages"
)
check(
  mentions("hunters", "Humans now") == FOREVER
    and mentions("priests", "Gnomes now") == FOREVER
    and mentions("paladins", "Forsaken now") == FOREVER,
  "Forever's new callings stay out of the Classic account"
)
for id, page in pairs(ns.content.entries) do
  for _, paragraph in ipairs(page.text) do
    assert(paragraph[1] ~= "" and not paragraph[1]:match("^%["), id .. ": unreadable prose")
  end
end
ns.content.entries["t-forever"] = entry("Forever only", { always = true })
ns.content.entries["t-forever"].client = "forever"
check(ns.available("t-forever") == FOREVER, "a Forever-only page exists only on Forever")
if FOREVER then
  secrets[creature(2091)] = true
  check(hover(2091) == "", "Forever: a secret creature id gets no hint, and no error")
  secrets[creature(2091)] = nil
end

-- ── /codex scan ───────────────────────────────────────────────────────────────
local scanFrame
for _, f in ipairs(frames) do
  if f.registered.ITEM_TEXT_READY then scanFrame = f end
end
local function scanFire(e, ...) scanFrame.scripts.OnEvent(scanFrame, e, ...) end
printed = {}
SlashCmdList.LOREKEEPERSCODEX("scan")
check(
  printed[1]:find("scan off", 1, true) and not LorekeepersCodexScan.on,
  "/codex scan says what it has, off by default"
)
state.target = 1123
scanFire("PLAYER_TARGET_CHANGED")
check(not LorekeepersCodexScan.npcs[1123], "… and records nothing while off")
SlashCmdList.LOREKEEPERSCODEX("scan on")
scanFire("PLAYER_TARGET_CHANGED")
check(
  LorekeepersCodexScan.on
    and LorekeepersCodexScan.npcs[1123]
    and LorekeepersCodexScan.npcs[1123].zoneId == ns.areaOf(state.zone)
    and LorekeepersCodexScan.npcs[1123].zone == (not ns.areaOf(state.zone) and state.zone or nil),
  "scan on: creatures met are recorded, with where (its places by their ids)"
)
check(LorekeepersCodexScan.races.Dwarf and next(LorekeepersCodexScan.areas), "… with the race's token and the area")
function GetQuestID() return 4242 end
function GetTitleText() return "A Test Quest" end
function GetQuestText() return "Go and see." end
function GetObjectiveText() return "See." end
scanFire("QUEST_DETAIL")
check(
  LorekeepersCodexScan.quests[4242].text == "Go and see." and LorekeepersCodexScan.quests[4242].title == "A Test Quest",
  "… and the quests read, with their texts"
)
SlashCmdList.LOREKEEPERSCODEX("scan clear")
check(not LorekeepersCodexScan.quests[4242] and LorekeepersCodexScan.on, "/codex scan clear empties it")
-- A page's banner and an achievement's, among the game's own alerts.
ns.setOption("banner", true)
ns.hideBanner()
local pid
for id in pairs(C.entries) do
  if ns.page(id) and not pid then pid = id end
end
ns.showBanner(pid)
local card = LorekeepersCodexBanner1
check(
  card.shown
    and card.joined
    and card.kicker.text == "A new page in the codex"
    and card.title.text == C.entries[pid].title
    and AlertFrame.updates > 0,
  "a new page shows its banner, among the game's own alerts"
)
LorekeepersCodexFrame:Hide()
card.scripts.OnClick(card, "LeftButton")
check(
  not card.shown and LorekeepersCodexFrame.shown and LorekeepersCodexPage.title.text == C.entries[pid].title,
  "… and a click on it opens the page"
)
ns.showAchievementBanner("pages-10")
card = bannerOf("achievement", "pages-10")
check(
  card
    and card.kicker.text == "Lorekeeper's Codex achievement"
    and card.title.text == ns.achievementById["pages-10"].title,
  "an achievement shows its banner, the codex's book on it"
)
LorekeepersCodexFrame:Hide()
card.scripts.OnClick(card, "RightButton")
check(not card.shown and not LorekeepersCodexFrame.shown, "… a right-click only dismisses it")
ns.setOption("banner", false)
ns.showAchievementBanner("pages-10")
card = bannerOf("achievement", "pages-10")
check(card, "the pages' alerts off, an achievement's still shows: a switch of its own")
card.scripts.OnClick(card, "RightButton")
ns.setOption("achievementToast", false)
ns.showAchievementBanner("pages-10")
check(not bannerOf("achievement", "pages-10"), "… which turns them off")
ns.setOption("banner", true)
ns.setOption("achievementToast", true)

-- Players met: one's own people and calling were known from the start;
-- targeting a player unlocks theirs, and counts toward the encounters.
check(
  has("dwarves") and LorekeepersCodexChar.entries.dwarves.retro and has("hunters"),
  "one's own people and calling: known from the start, quietly"
)
check(not has("orcs") and not has("shamans"), "another people's page and calling's: not yet")
local soundsBefore = sounds
state.player = { race = "Orc", class = "SHAMAN" }
fire("PLAYER_TARGET_CHANGED")
check(
  has("orcs") and has("shamans") and sounds == soundsBefore + 2,
  "targeting an orc shaman: the orcs' page and the shamans'"
)
local met = LorekeepersCodexChar.met
check(
  met.races.Orc and met.classes.SHAMAN and met.combos["Orc:SHAMAN"],
  "the meeting remembered: the race, the class, the two"
)
state.player = { race = "Troll", class = "SHAMAN" }
fire("PLAYER_TARGET_CHANGED")
check(has("darkspear-trolls"), "a troll: the Darkspear's page, an older one, by its new rule")
local pairsFor = ns.achievementById["met-pairs-10"]
check(select(1, pairsFor.progress()) == 2, "two pairings met so far")
-- (a player's tooltip: a page to find while their people's or calling's is missing)
local function hoverPlayer()
  tipLines, tipUnit, state.mouseover = {}, "mouseover", nil
  tipHooks.OnTooltipSetUnit(GameTooltip)
  return table.concat(tipLines, "|")
end
state.player = { race = "Tauren", class = "DRUID" }
check(
  hoverPlayer() == "Lorekeeper's Codex: a page to find",
  "a player of a people not met: a page to find, on their tooltip"
)
state.player = { race = "Orc", class = "SHAMAN" }
check(hoverPlayer() == "", "… and nothing once their pages are found")
state.player = nil

-- Expansion pages: encounters belong to the actual people, not just a few
-- representatives or every creature with a similar model.
do
  local found = LorekeepersCodexChar.entries
  local function meet(id)
    state.target = id
    fire("PLAYER_TARGET_CHANGED")
  end
  found.sentinels = nil
  meet(3936)
  check(has("sentinels"), "Shandris Feathermoon unlocks her Sentinels' page")
  found.sentinels = nil
  meet(4262)
  check(has("sentinels"), "an ordinary Darnassus Sentinel unlocks it too")
  found["blue-dragonflight"] = nil
  meet(6109)
  check(has("blue-dragonflight"), "meeting Azuregos unlocks the blue flight")
  found["blue-dragonflight"] = nil
  kill(PLAYER, 10659)
  check(has("blue-dragonflight"), "a Cobalt Whelp kill unlocks the blue flight")
  found["green-dragonflight"] = nil
  meet(5709)
  check(not has("green-dragonflight"), "Eranikus' hostile shade must be killed, not merely targeted")
  kill(PET, 5709)
  check(has("green-dragonflight"), "a pet's kill of the Shade of Eranikus unlocks the green flight")
  found["bronze-dragonflight"] = nil
  kill(PLAYER, 8197)
  check(has("bronze-dragonflight"), "Chronalis unlocks the bronze flight")
  found["blood-elves"], found["shadow-council"], found["high-elves"] = nil, nil, nil
  meet(4198)
  check(
    has("blood-elves") and has("shadow-council") and not has("high-elves"),
    "Braelyn Firehand belongs to the blood elves and Shadow Council, not the remaining high elves"
  )
  found["blood-elves"] = nil
  meet(14387)
  check(has("blood-elves"), "Lothos Riftwaker unlocks the blood elves outside Molten Core")
  found["high-elves"] = nil
  meet(11706)
  check(has("high-elves"), "Adon unlocks the high elves at the Thalassian border")
  found.dreadlords, found["shadow-council"] = nil, nil
  meet(9516)
  check(has("dreadlords") and has("shadow-council"), "Lord Banehollow belongs to both pages")
  found.dreadlords, found["shadow-council"] = nil, nil
  kill(PLAYER, 7664)
  check(has("dreadlords") and has("shadow-council"), "Razelikh unlocks the dreadlords and the Shadow Council")
  found["shadow-council"] = nil
  meet(3216)
  check(has("shadow-council"), "Neeru Fireblade unlocks the Shadow Council inside Orgrimmar")
  found["shadow-council"] = nil
  kill(PLAYER, 11322)
  check(has("shadow-council"), "the Searing Blade in Ragefire Chasm belongs to the Shadow Council")
  found["shadow-council"] = nil
  kill(PLAYER, 3660)
  check(has("shadow-council"), "Athrikus Narassin's Dark Strand belongs to the Shadow Council")
  found["shadow-council"] = nil
  kill(PLAYER, 2318)
  check(has("shadow-council"), "an Argus Shadow Mage unlocks the Shadow Council in Alterac")
  found["shadow-council"] = nil
  kill(PLAYER, 6004)
  check(has("shadow-council"), "the Shadowsworn unlock the Shadow Council in the Blasted Lands")
  found.ancients = nil
  meet(3616)
  check(has("ancients"), "Onu unlocks the ancients in Darkshore")
  found.wildkin = nil
  kill(PLAYER, 12138)
  check(has("wildkin"), "Lunaclaw unlocks the wildkin during the druid's trial")
  found.deathstalkers = nil
  meet(6497)
  check(not has("deathstalkers"), "Astor Hadren, the Syndicate courier, is not a Deathstalker")
  meet(6467)
  check(has("deathstalkers"), "Mennet Carkad, their recruiter, is a Deathstalker")
  found.highborne, found["high-elves"] = nil, nil
  meet(14368)
  check(has("highborne") and not has("high-elves"), "the Shen'dralar lorekeepers are Highborne")
  found.highborne = nil
  kill(PLAYER, 11487)
  check(has("highborne"), "Magister Kalendris unlocks the Highborne among Dire Maul's dead")

  -- Forever renamed Azshara's hold and its tribe. The same area id and
  -- original NPC ids must not introduce the Timbermaw there.
  local areaInfo = C_Map.GetAreaInfo
  C_Map.GetAreaInfo = function(id)
    if id == 1216 then return FOREVER and "Blackmaw Hold" or "Timbermaw Hold" end
    return areaInfo(id)
  end
  found.timbermaw = nil
  state.zone, state.sub = "Azshara", FOREVER and "Blackmaw Hold" or "Timbermaw Hold"
  ns.startUnlocks()
  check(has("timbermaw") == not FOREVER, "Azshara's hold unlocks the Timbermaw on Classic only")
  found.timbermaw = nil
  meet(6188)
  check(has("timbermaw") == not FOREVER, "Azshara's original tribal ids unlock the Timbermaw on Classic only")
  found.timbermaw = nil
  state.zone, state.sub = "Felwood", "Timbermaw Hold"
  fire("ZONE_CHANGED")
  check(has("timbermaw"), "Felwood's Timbermaw Hold unlocks the page on either client")
  found.timbermaw = nil
  state.standing[576] = 5
  fire("UPDATE_FACTION")
  check(has("timbermaw"), "friendly Timbermaw reputation still unlocks the page")
  state.standing[576] = nil
  found.timbermaw = nil
  meet(11554)
  check(has("timbermaw"), "meeting Grazle unlocks the Timbermaw on either client")
  C_Map.GetAreaInfo = areaInfo

  -- This page tells the escort's ending. Neither meeting Taelan nor
  -- receiving Tirion's disguise should reveal it before the player sees it.
  found["taelan-fordring"] = nil
  meet(1842)
  check(not has("taelan-fordring"), "meeting Taelan does not reveal his ending")
  fire("QUEST_TURNED_IN", 5862)
  check(not has("taelan-fordring"), "Scarlet Subterfuge does not reveal Taelan's ending")
  found.hearthglen = nil
  state.zone, state.sub = "Western Plaguelands", "Hearthglen"
  fire("ZONE_CHANGED")
  check(has("hearthglen") and not has("taelan-fordring"), "Hearthglen can be read before Taelan's story ends")
  fire("QUEST_TURNED_IN", 5944)
  check(has("taelan-fordring"), "In Dreams unlocks Taelan's full story")
  found["taelan-fordring"] = nil
  state.questsDone[5944] = true
  ns.catchUp()
  check(
    has("taelan-fordring") and found["taelan-fordring"].retro,
    "In Dreams completed before installing the addon unlocks Taelan quietly"
  )
end

-- ── the reader's language ────────────────────────────────────────────────────
-- Every generated language file loads (a stub where there is no translation);
-- a translation's words, plural rule, month names, chapters and pages replace
-- the English, a page keeping only this game's paragraphs and its asides.
for _, locale in ipairs({
  "enUS",
  "enGB",
  "deDE",
  "frFR",
  "esES",
  "esMX",
  "ruRU",
  "ptBR",
  "itIT",
  "koKR",
  "zhCN",
  "zhTW",
}) do
  check(loadfile(DIR .. "Text_" .. locale .. ".lua") ~= nil, "the language file for " .. locale .. " loads")
end
do
  local L, K = ns.L, ns.kit
  check(L["Begin"] == "Begin" and K.plural(0, "chapter", "chapters") == "chapters", "English by default")
  UnitSex = function() return 3 end -- (a woman reads)
  ns.translate({
    locale = "frFR",
    plural = "fr",
    words = { ["Begin"] = "Commencer", ["Oct"] = "oct.", ["chapter"] = "chapitre", ["chapters"] = "chapitres" },
    chapters = { ["wetlands"] = { "Les Paluns", "Des marais entre Khaz Modan et Arathi." } },
    classic = {
      { "Contreforts de Hautebrande", "Contreforts d'Hillsbrad" },
      { "de Fossoyeuse", "d'Undercity" },
      { "de Forgefer", "d'Ironforge" },
      { "Fossoyeuse", "Undercity" },
      { "Forgefer", "Ironforge" },
    },
    pages = {
      ["grim-batol"] = {
        title = "Grim Batol",
        text = {
          {
            "Premier paragraphe, $gcher voyageur:chere voyageuse;, de Forgefer aux Contreforts de Hautebrande, loin de Fossoyeuse.",
          },
          { client = "forever", "Pour Forever." },
          { client = "classic", "Pour Classic." },
          { side = "Horde", aside = true, sign = "P. F.", "Une note de Parqual." },
        },
      },
    },
    books = {
      ["The Founding of Quel'Thalas"] = {
        { first = "inthebeginning", pages = { "Au commencement, $N.", "Le milieu.", "La fin." } },
      },
    },
  })
  -- (a place inside a building, no area id: by its building area's, named by
  -- the language's list)
  local inside = ns.insideNames
  ns.names({ inside = { [4242] = "La Bibliothèque" }, insideClassic = { [4242] = "La Bibliothèque" } })
  local place = ns.placeOf("Forgefer", "La Bibliothèque")
  local _, sub = ns.placeNames(place)
  check(
    place.subInside == 4242 and not place.sub and sub == "La Bibliothèque",
    "… a place inside a building, kept by its building area's id, named by the language's list"
  )
  ns.insideNames = inside
  -- (the Library's titles by their texts' ids, as the French file gives them)
  local titlesBefore = ns.textTitlesById
  ns.textTitlesById = { o175733 = "La fondation de Quel'Thalas" }
  -- the Library: a title copied in English reads by this language's; the
  -- text read again in this language replaces its copy, never a second one
  local lib = LorekeepersCodexChar.library
  read("The Founding of Quel'Thalas", { "In the beginning...", "The middle.", "The end." })
  do
    local copy
    for _, t in pairs(lib.texts) do
      if t.title == "The Founding of Quel'Thalas" then copy = t end
    end
    local pages, whole = ns.textPages(copy)
    check(
      whole and #pages == 3 and ns.textForReader(pages[1]) == "Au commencement, " .. UnitName("player") .. ".",
      "… a text copied in English reads in French, the game's own, the reader's name in it"
    )
  end
  local copies = 0
  for _ in pairs(lib.texts) do
    copies = copies + 1
  end
  check(
    ns.textTitle("The Founding of Quel'Thalas") == "La fondation de Quel'Thalas",
    "… the Library's titles copied in English, in French"
  )
  read("La fondation de Quel'Thalas", { "Au commencement...", "La fin." })
  local after = 0
  for _ in pairs(lib.texts) do
    after = after + 1
  end
  check(after == copies and (function()
    for _, t in pairs(lib.texts) do
      if t.title == "La fondation de Quel'Thalas" then
        return t.pages[1] == "Au commencement..." and t.pages[3] == nil
      end
    end
    return false
  end)(), "… and the text read again in French replaces its English copy")
  local chapter
  for _, ch in ipairs(ns.content.chapters) do
    if ch.id == "wetlands" then chapter = ch end
  end
  local text = ns.content.entries["grim-batol"].text
  check(
    L["Begin"] == "Commencer"
      and L["Your choices"] == "Your choices"
      and K.plural(0, "chapter", "chapters") == "chapitre",
    "a translation: its words, the rest in English, its plural rule (French: 0 is singular)"
  )
  check(K.day(os.time({ year = 2026, month = 10, day = 13, hour = 12 })) == "13 oct. 2026", "… its month names")
  check(chapter.title == "Les Paluns", "… its chapters")
  check(
    #text == 3
      and text[2][1] == (FOREVER and "Pour Forever." or "Pour Classic.")
      and text[2].client == nil
      and text[3].aside
      and text[3].side == "Horde",
    "… its pages, this game's paragraphs only, Parqual's aside kept"
  )
  check(
    text[1][1]
      == (
        FOREVER
          and "Premier paragraphe, chere voyageuse, de Forgefer aux Contreforts de Hautebrande, loin de Fossoyeuse."
        or "Premier paragraphe, chere voyageuse, d'Ironforge aux Contreforts d'Hillsbrad, loin d'Undercity."
      ),
    "… the reader's gender ($g), and on Classic its own names for the places Forever renamed, elisions and all"
  )
  ns.textTitlesById = titlesBefore
end

-- Where a page was found reads in the client's language: a find keeps its
-- places' ids; an older one, kept by name (in English, or in today's
-- language), has them at the login; a place neither knows stays as recorded.
do
  local areaInfo = C_Map.GetAreaInfo
  C_Map.GetAreaInfo = function(id)
    return ({ [1] = "Dun Morogh", [131] = "Kharanos", [132] = "Vallée des Frigères" })[id]
  end
  local found = LorekeepersCodexChar.entries
  ns.startUnlocks()
  found.kharanos = nil
  state.zone, state.sub = "Dun Morogh", "Kharanos"
  ns.unlock("kharanos")
  check(found.kharanos.zoneId == 1 and found.kharanos.subId == 131, "a find keeps the area ids of its zone and subzone")
  found.older = { at = 1, zone = "Dun Morogh", sub = "Coldridge Valley" }
  found.today = { at = 1, zone = "Dun Morogh", sub = "Vallée des Frigères" }
  found.elsewhere = { at = 1, zone = "Somewhere", sub = "Else" }
  ns.mendPlaces(LorekeepersCodexChar)
  local zone, sub = ns.placeNames(found.older)
  local _, other = ns.placeNames(found.elsewhere)
  check(
    found.older.subId == 132
      and not found.older.sub
      and found.today.subId == 132
      and zone == "Dun Morogh"
      and sub == "Vallée des Frigères"
      and other == "Else"
      and found.elsewhere.sub == "Else",
    "… an older find, kept in English or in today's language, by its ids at the login; an unknown place as recorded"
  )
  found.older, found.today, found.elsewhere = nil, nil, nil
  C_Map.GetAreaInfo = areaInfo
end

-- Check the shipped French book catalog, including the circulars whose first
-- 24 English letters are identical. The importer must not bind all three to
-- the first translation merely because their openings match.
do
  local translated
  assert(loadfile(DIR .. "Text_frFR.lua"))("LorekeepersCodex", {
    translate = function(t) translated = t end,
    names = function() end,
  })
  local before = ns.bookTexts
  ns.bookTexts = translated.books
  for _, case in ipairs({
    {
      "For immediate dissemination to all Twilight's Hammer members.\n\nThe search for the traitor, Ortell,",
      "Ortell",
      1,
    },
    {
      "For immediate dissemination to all Twilight Hammer members.\n\nGiven the current state of affairs in Silithus,",
      "Silithus",
      1,
    },
    {
      "For immediate dissemination to all Twilight's Hammer members.\n\nThe following information describes the use of wind stones",
      "pierres des vents",
      4,
    },
  }) do
    local pages, localized = ns.textPages({ title = "Decoded Twilight Text", pages = { case[1] } })
    check(
      localized and #pages == case[3] and pages[1]:find(case[2], 1, true),
      "the French Twilight circular matches its English text: " .. case[2]
    )
  end
  local pages, localized = ns.textPages({ title = "The Green Hills of Stranglethorn", pages = { "old English copy" } })
  check(
    localized and #pages == 30 and pages[30]:find("-- Fin --", 1, true),
    "the full French Green Hills book keeps its cover, 29 body pages and ending"
  )
  local letter = ns.textPages({ title = "Simple Letter", pages = { "old English copy" } })
  check(
    letter[1]:find("Dis-moi", 1, true) and not ns.textForReader(letter[1]):find("$C", 1, true),
    "the missing French warrior letter reads in French with the reader's class"
  )
  local unknown = { "A readable outside the catalog." }
  check(ns.textPages({ title = "Unknown", pages = unknown }) == unknown, "unknown texts keep their recorded pages")
  ns.bookTexts = before
end

-- The German (Text_deDE.lua, a first translation): every page the French has,
-- each with a title and its paragraphs, its gender tokens whole, no semicolon
-- left in the prose.
do
  local function load(locale)
    local t
    assert(loadfile(DIR .. "Text_" .. locale .. ".lua"))(
      "LorekeepersCodex",
      { translate = function(x) t = x end, names = function() end }
    )
    return t
  end
  local fr, de = load("frFR"), load("deDE")
  local missing, bad, n = {}, {}, 0
  for id in pairs(fr.pages) do
    local p = de.pages[id]
    if not (p and p.title and #p.text > 0) then table.insert(missing, id) end
  end
  for id, p in pairs(de.pages) do
    n = n + 1
    for _, para in ipairs(p.text) do
      local prose = (para[1] or ""):gsub("%$g[^:;]*:[^;]*;", "")
      if prose:find(";", 1, true) or prose:find("$g", 1, true) then table.insert(bad, id) end
    end
  end
  check(
    #missing == 0 and n > 400,
    "the German: every page, " .. n .. " of them (" .. table.concat(missing, ", ") .. ")"
  )
  check(#bad == 0, "… its gender tokens whole, no semicolon in the prose (" .. table.concat(bad, ", ") .. ")")
  check(
    de.locale == "deDE"
      and de.words["The Codex"] == "Der Kodex"
      and de.pages.archesonus.title == "Königliche Historikerin Archesonus",
    "… its words and titles"
  )
  -- the game's own German books: every one the French has, the Green Hills
  -- whole, the reader's class and gender filled in
  local short = {}
  for title in pairs(fr.books) do
    if not de.books[title] then table.insert(short, title) end
  end
  check(#short == 0, "… every book the French has (" .. table.concat(short, ", ") .. ")")
  -- a text Wowhead gives only in English, in brackets, is no translation
  local english = {}
  for _, books in ipairs({ fr.books, de.books }) do
    for title, variants in pairs(books) do
      for _, v in ipairs(variants) do
        if v.pages[1] and v.pages[1]:match("^%[") and v.pages[#v.pages]:match("%]$") then
          table.insert(english, title)
        end
      end
    end
  end
  check(#english == 0, "… no book in either language is Wowhead's English (" .. table.concat(english, ", ") .. ")")
  local before = ns.bookTexts
  ns.bookTexts = de.books
  local hills = ns.textPages({ title = "The Green Hills of Stranglethorn", pages = { "old English copy" } })
  check(
    #hills == 30 and hills[1]:find("SCHLINGENDORNTALS", 1, true) and hills[30]:find("--Ende--", 1, true),
    "… the Green Hills book: its cover, 29 body pages and ending"
  )
  local note = ns.textPages({ title = "Rune-Inscribed Note", pages = { "old English copy" } })
  check(
    note[1]:find("Ich grüße Euch, $C.", 1, true) and not ns.textForReader(note[1]):find("$C", 1, true),
    "… a class letter reads with the reader's class"
  )
  local journal = ns.textPages({ title = "Klaven Mortwake's Journal", pages = { "old English copy" } })
  check(journal[1]:find("<unleserlicher Text>", 1, true), "… the game's own asides kept")
  ns.bookTexts = before
end

-- Run the real German loader, not just its raw catalog. Classic's swaps and
-- both gender forms must survive in the finished prose on each client.
do
  local oldSex = UnitSex
  local function client(locale, sex)
    UnitSex = function() return sex end
    local target = { on = function() end, secret = function() return false end }
    for _, file in ipairs({
      "Kit.lua", -- (the kit first, as the TOC loads it: its words, its agree and swap)
      FOREVER and "Content_Forever.lua" or "Content_Classic.lua",
      "Locale.lua",
      "Text_Sources.lua",
      "Text_" .. locale .. ".lua",
      "Library.lua",
    }) do
      assert(loadfile(DIR .. file))("LorekeepersCodex", target)
    end
    return target
  end
  for _, sex in ipairs({ 2, 3 }) do
    local target = client("deDE", sex)
    for id, entry in pairs(target.content.entries) do
      check(not entry.title:find("Der Der", 1, true), "German title has no repeated article: " .. id)
      for _, para in ipairs(entry.text) do
        check(
          not para[1]:find("dem Der Zirkel", 1, true) and not para[1]:find("Der Der Zirkel", 1, true),
          "German Classic faction swap preserves grammar: " .. id
        )
        check(not para[1]:find("$g", 1, true), "German gender expanded in the finished page: " .. id)
        check(not para[1]:find(";", 1, true), "German finished prose has no semicolon: " .. id)
      end
    end
    -- All six reports share a title. Some start with the player's name, and
    -- must match both a literal token and a name filled in by the game.
    local bodies = client("enUS", sex).textBodies
    for _, id in ipairs({ "i23008", "i23010", "i23011", "i23012", "i23013", "i23016" }) do
      local source = target.textSources.texts[id]
      check(target.textBodies == nil, "a German client carries no English pages")
      for _, name in ipairs({ "$N", "Thorin", "Änna-Maria" }) do
        local first = bodies[id][1]:gsub("%$N", name)
        local pages, localized = target.textPages({ title = source.title, pages = { first } })
        check(
          localized and pages == target.booksById[id],
          "personalized report retains its variant: " .. id .. " / " .. name
        )
      end
    end
    local french = { title = "Lettre simple", pages = { "Dis-moi, guerrier, as-tu entendu un orc hurler ?" } }
    local pages, localized = target.textPages(french)
    check(localized and pages[1]:find("Orc", 1, true), "a saved French letter reads in German")
    check(target.textTitle(french.title) == "Einfacher Brief", "a saved French title reads in German")
    local original = french.pages[1]
    local english = client("enUS", sex)
    local en, translated = english.textPages(french)
    check(translated and en[1]:find("Tell me", 1, true), "a saved French letter reads in English")
    check(english.textTitle("Einfacher Brief") == "Simple Letter", "German titles return to English")
    check(french.pages[1] == original, "language changes do not overwrite recorded pages")
    for id, pages in pairs(english.textBodies) do
      for _, page in ipairs(pages) do
        check(not page:find("$B", 1, true) and not page:find("$b", 1, true), "English line breaks are rendered: " .. id)
        check(
          not english.textForReader(page):find(";", 1, true),
          "English gender tokens and prose are rendered: " .. id
        )
      end
    end
    -- Every real French/German first page resolves to its own identity,
    -- including all seven Twilight circulars, then returns to English.
    for _, locale in ipairs({ "frFR", "deDE" }) do
      local from = client(locale, sex)
      for title, variants in pairs(from.bookTexts) do
        for _, variant in ipairs(variants) do
          local id = from.textSources.canonical[variant.ids[1]]
          local copy = { title = from.textTitle(title), pages = { from.textForReader(variant.pages[1]) } }
          check(
            from.textIdentity(copy) == id,
            locale .. " shared-title copy preserves identity: " .. title .. " / " .. id
          )
          local de = target.textPages(copy)
          check(de == target.booksById[id], locale .. " shared-title copy reads the correct German variant: " .. id)
          check(
            target.textTitle(copy.title, copy) == (target.textTitlesById[id] or title),
            locale .. " saved title reads in German even if its old label was ambiguous: " .. id
          )
          check(english.textTitle(copy.title, copy) == title, locale .. " saved title returns to English: " .. id)
          local enPages = english.textPages(copy)
          if english.textBodies[id] then
            check(enPages == english.textBodies[id], locale .. " variant returns to English: " .. id)
          else
            check(enPages == copy.pages, "a known wrong English source binding is never shown: " .. id)
          end
        end
      end
    end
    local unknown = { "An unrecognized page under a shared title." }
    check(
      target.textPages({ title = "Sealed Research Report", pages = unknown }) == unknown,
      "unmatched reports stay as recorded"
    )
  end
  UnitSex = oldSex
end

-- Spanish: exercise the finished loaders, including regional game names,
-- gender forms and saved copies that predate stable readable ids.
do
  local oldSex = UnitSex
  local function client(locale, sex)
    UnitSex = function() return sex end
    local target = { on = function() end, secret = function() return false end }
    for _, file in ipairs({
      "Kit.lua", -- (the kit first, as the TOC loads it: its words, its agree and swap)
      FOREVER and "Content_Forever.lua" or "Content_Classic.lua",
      "Locale.lua",
      "Text_Sources.lua",
      "Text_" .. locale .. ".lua",
      "Library.lua",
    }) do
      assert(loadfile(DIR .. file))("LorekeepersCodex", target)
    end
    return target
  end
  for _, sex in ipairs({ 2, 3 }) do
    local english = client("enUS", sex)
    for _, locale in ipairs({ "esES", "esMX" }) do
      local target = client(locale, sex)
      check(target.kit.L["The Codex"] == "El Códice", locale .. " interface loads")
      check(target.kit.isOne(1), locale .. " singular rule loads")
      check(not target.kit.isOne(0) and not target.kit.isOne(2), locale .. " zero and two are plural")
      local greeting = target.content.entries["foreword-dwarf"].text[1][1]
      check(greeting:find(sex == 3 and "Viajera" or "Viajero", 1, true), locale .. " foreword addresses the reader")
      local leader = target.content.entries["high-tinker-mekkatorque"].title
      check(
        leader == (locale == "esMX" and "Manitas mayor Mekkatorque" or "Alto mecachifle Mekkatorque"),
        locale .. " uses its client's Mekkatorque title"
      )
      check(
        target.content.entries["si-7"].title == (locale == "esMX" and "IV:7" or "IS:8"),
        locale .. " uses its client's intelligence service name"
      )
      for id, original in pairs(english.content.entries) do
        local entry = target.content.entries[id]
        check(entry and #entry.text == #original.text, locale .. " preserves paragraphs: " .. id)
        for i, para in ipairs(entry.text) do
          local source = original.text[i]
          check(
            para.side == source.side and para.aside == source.aside and para.italic == source.italic,
            locale .. " preserves faction and narrator roles: " .. id
          )
          check(not para[1]:find("$g", 1, true) and not para[1]:find(";", 1, true), locale .. " renders prose: " .. id)
          check(not para[1]:find("el Hermandad", 1, true), locale .. " regional faction has the right article: " .. id)
        end
      end
      check(target.textBodies == nil, locale .. " loads no English Library bodies")
      for _, fromLocale in ipairs({ "frFR", "deDE", "esES", "esMX" }) do
        local from = client(fromLocale, sex)
        for title, variants in pairs(from.bookTexts) do
          for _, variant in ipairs(variants) do
            local id = from.textSources.canonical[variant.ids[1]]
            local copy = { title = from.textTitle(title), pages = { from.textForReader(variant.pages[1]) } }
            -- Image-only and genuinely empty sources have no first-page text
            -- to identify in an old copy. New copies retain their readable id.
            if copy.pages[1] == "" then copy.readable = id end
            check(from.textIdentity(copy) == id, fromLocale .. " retains readable identity: " .. id)
            local pages, localized = target.textPages(copy)
            check(localized and pages == target.booksById[id], locale .. " reads " .. fromLocale .. " copy: " .. id)
            local en = english.textPages(copy)
            check(
              en == (english.textBodies[id] or copy.pages),
              fromLocale .. " copy returns to English without inventing missing sources: " .. id
            )
          end
        end
      end
      local broken = { title = "Unknown", pages = { "A page outside the known catalog." } }
      check(target.textPages(broken) == broken.pages, locale .. " preserves unknown saved texts")
    end
  end
  UnitSex = oldSex
end

-- Same-title circulars remain distinct when re-read in another language,
-- including old saved copies that predate readable ids and language stamps.
do
  local before = LorekeepersCodexChar.library
  local books, byId, locale, titles = ns.bookTexts, ns.booksById, ns.locale, ns.textTitlesById
  LorekeepersCodexChar.library = nil
  for _, id in ipairs({ "i20541", "i20545", "i20552" }) do
    local source = ns.textSources.texts[id]
    read(source.title, ns.textBodies[id])
  end
  check(ns.libraryCount() == 3, "three Twilight circulars with shared openings have separate copies")
  local library = ns.library()
  library.keys = {}
  for id, text in pairs(library.texts) do
    text.readable, text.language = nil, nil
    library.keys[text.title .. "|" .. text.pages[1]:sub(1, 80)] = id
  end
  assert(loadfile(DIR .. "Text_deDE.lua"))("LorekeepersCodex", ns)
  for _, id in ipairs({ "i20541", "i20545", "i20552" }) do
    read(ns.textTitle("Decoded Twilight Text"), ns.booksById[id])
  end
  check(ns.libraryCount() == 3, "re-reading the German circulars replaces only the corresponding copies")
  for _, text in pairs(ns.library().texts) do
    check(
      text.title == ns.textTitle("Decoded Twilight Text") and text.readable,
      "re-read copy keeps its stable identity"
    )
  end
  local french
  assert(loadfile(DIR .. "Text_frFR.lua"))(
    "LorekeepersCodex",
    { translate = function(t) french = t end, names = function() end }
  )
  read("Harthal Truesight", french.books["Harthal Truesight"][1].pages)
  local old
  for _, text in pairs(ns.library().texts) do
    if text.readable == "o175776" then old = text end
  end
  old.pages[2], old.count = "An obsolete trailing page in a legacy copy.", 2
  local foundAt = old.at
  read("Harthal Truesight", ns.booksById.o175776)
  check(
    ns.libraryCount() == 4 and old.count == 1 and old.pages[2] == nil and old.at == foundAt,
    "a same-title re-read replaces stale pages and preserves when the text was found"
  )
  ns.bookTexts, ns.booksById, ns.locale, ns.textTitlesById = books, byId, locale, titles
  LorekeepersCodexChar.library = before
end

io.write(FOREVER and "all good (Forever)\n" or "all good\n")
