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
function PlaySound(id) sounds = sounds + 1; lastSound = id end
local ticker
local timers = {}
C_Timer = {
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
    if not t.cancelled then t.cancelled = true; t.fn(); return t.seconds end
  end
end
function UnitXP() return 0 end
function UnitRace() return "Dwarf", "Dwarf" end

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
      if k == "IsMouseOver" then return function(self) return self.mouseOver == true end end
      if k == "SetText" then return function(self, v) self.text = v end end
      if k == "GetText" then return function(self) return rawget(self, "text") or "" end end
      if k == "GetStringHeight" then return function() return 14 end end
      if k == "SetHeight" then return function(self, v) self.height = v end end
      if k == "SetID" then return function(self, v) self.idValue = v end end
      if k == "GetID" then return function(self) return rawget(self, "idValue") or 0 end end
      if k == "GetHeight" then return function(self) return rawget(self, "height") or 100 end end
      if k == "SetVerticalScroll" then return function(self, v) self.vscroll = v end end
      if k == "GetVerticalScroll" then return function(self) return rawget(self, "vscroll") or 0 end end
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
-- The tooltip: keep hooks, lines and the unit it shows.
local tipHooks, tipLines, tipUnit = {}, {}, nil
GameTooltip.HookScript = function(self, name, fn) tipHooks[name] = fn end
GameTooltip.GetUnit = function() return "Someone", tipUnit end
GameTooltip.AddLine = function(self, text) table.insert(tipLines, text) end
function UnitIsPlayer(u) return u == "player" end
function GetCursorPosition() return 0, 0 end
local linkHandlers = {}
LinkUtil = { RegisterLinkHandler = function(kind, fn) linkHandlers[kind] = fn end }
LinkProcessorResponse = { Handled = 2 }
MinimalSliderWithSteppersMixin = { Label = { Right = 2 } }
-- The game's settings panel: keep what the addon registers.
local panel = { settings = {}, opened = nil }
Settings = {
  VarType = { Boolean = "boolean", Number = "number" },
  RegisterVerticalLayoutCategory = function(name) panel.name = name; return { GetID = function() return 42 end } end,
  RegisterProxySetting = function(_, variable, _, name, default, get, set)
    local s = { variable = variable, name = name, default = default, get = get, set = set }
    panel.settings[variable] = s
    return s
  end,
  CreateCheckbox = function() end,
  CreateDropdown = function(_, _, options) panel.options = options end,
  CreateSliderOptions = function(min, max, step) return { min = min, max = max, step = step, SetLabelFormatter = function(self, _, fn) self.format = fn end } end,
  CreateSlider = function(_, _, options) panel.slider = options end,
  CreateControlTextContainer = function()
    local data = {}
    return { Add = function(_, v, l) table.insert(data, { value = v, label = l }) end, GetData = function() return data end }
  end,
  RegisterAddOnCategory = function() panel.registered = true end,
  OpenToCategory = function(id) panel.opened = id end,
}
local events
local frames = {}
function CreateFrame(kind, name)
  local f = ui()
  f.registered = {}
  f.RegisterEvent = function(self, e)
    if FOREVER and e == "COMBAT_LOG_EVENT_UNFILTERED" then error("COMBAT_LOG_EVENT_UNFILTERED: forbidden") end
    self.registered[e] = true
  end
  table.insert(frames, f)
  if not events and kind == "Frame" and not name then events = f end
  if name then _G[name] = f end
  return f
end
local function fire(e, ...)
  assert(events.registered[e], "not registered: " .. e)
  events.scripts.OnEvent(events, e, ...)
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
assert(loadfile(DIR .. "Core.lua"))("LorekeepersCodex", ns)
assert(loadfile(DIR .. "Achievements.lua"))("LorekeepersCodex", ns)
assert(loadfile(DIR .. "Codex.lua"))("LorekeepersCodex", ns)
assert(loadfile(DIR .. "Library.lua"))("LorekeepersCodex", ns)
assert(loadfile(DIR .. "Minimap.lua"))("LorekeepersCodex", ns)
assert(loadfile(DIR .. "Banner.lua"))("LorekeepersCodex", ns)
assert(loadfile(DIR .. "Settings.lua"))("LorekeepersCodex", ns)
assert(loadfile(DIR .. "Hints.lua"))("LorekeepersCodex", ns)
assert(loadfile(DIR .. "Scan.lua"))("LorekeepersCodex", ns)
function wipe(t) for k in pairs(t) do t[k] = nil end return t end

local function check(cond, msg) assert(cond, msg); io.write("✓ " .. msg .. "\n") end
local function has(id) return LorekeepersCodexChar.entries[id] ~= nil end

-- ── a session ────────────────────────────────────────────────────────────────
-- A deleted character's codex, left under the same name.
LorekeepersCodexChar = { guid = "Player-6113-0DEAD000", entries = { ironforge = { at = 1, level = 20 } }, read = {} }
fire("PLAYER_LOGIN")
check(LorekeepersCodexChar.guid == PLAYER and not LorekeepersCodexChar.entries.ironforge, "a new character named like a deleted one starts a fresh codex")
check(ns.belongsTo({ entries = { kharanos = { level = 2 } } }, PLAYER, 3), "a codex from before 0.1.3 is kept")
check(not ns.belongsTo({ entries = { kharanos = { level = 20 } } }, PLAYER, 3), "… unless it was found at a higher level than this character's")
check(not ns.belongsTo({ entries = { ["rockjaw-troggs"] = { level = 1 } } }, PLAYER, 1, 0), "… or this character is brand new (level 1, no experience)")
check(LorekeepersCodexChar ~= nil, "the codex is saved per character")
check(has("foreword-dwarf") and LorekeepersCodexChar.entries["foreword-dwarf"].retro, "the dwarf's foreword is there from the start, quietly")
check(not has("foreword-human") and not ns.available("foreword-human"), "… and no other race's")
local pages = 0
for _ in pairs(ns.content.entries) do pages = pages + 1 end
local others = 0
for _, e in pairs(ns.content.entries) do if e.race and not e.race.Dwarf then others = others + 1 end end
check(ns.total == pages - others and others == (FOREVER and 9 or 8), "the other races' forewords don't count in the total")
check(ns.content.client == (FOREVER and "forever" or "classic") and (ns.content.entries["foreword-skyborne"] ~= nil) == FOREVER, "each game's content file holds that game's pages only")
check(has("war-of-the-three-hammers"), "logging in at Anvilmar unlocks the War of the Three Hammers (English name fallback)")
local function said(text) for _, p in ipairs(printed) do if p:find(text, 1, true) then return p end end end
check(said("|Hlorekeeper:war-of-the-three-hammers|h[The War of the Three Hammers]|h|r has been added to the codex.") and sounds == 2, "a new page is announced in chat as a link, with a sound")
local hints = 0
for _, p in ipairs(printed) do if p:find("/codex", 1, true) then hints = hints + 1 end end
check(hints == 1 and said("pages. Type /codex or click the book by the minimap"), "the /codex hint appears once, at login, and not in page messages")
check(ns.knownTotal() < ns.total and said(("%d of %d pages. Type /codex"):format(ns.count(), ns.knownTotal())), "the page count only counts the chapters opened, not the whole codex")
local banner = LorekeepersCodexBanner
check(banner and banner.shown and banner.id == "war-of-the-three-hammers", "a banner shows the newest page at the top of the screen")
check(banner.title.text == "The War of the Three Hammers" and rawget(banner, "text") == nil and rawget(banner, "more") == nil, "… only its title, a click on it to read it")
check(banner.scripts.OnUpdate == nil, "it doesn't fade: it stays until read or closed")
check(lastSound == 4147, "a new page plays the zone discovery sound by default (the dwarf's)")
check(panel.registered and panel.name == "Lorekeeper's Codex", "a settings page in the game's options")
banner.mouseOver = true
check(elapse() == 10 and banner.shown, "the banner stays while the mouse is on it")
banner.mouseOver = false
check(elapse() == 1 and not banner.shown, "… and goes away on its own after 10 seconds")
ns.showBanner("war-of-the-three-hammers")
check(panel.slider and panel.slider.format(0) == "until closed" and panel.slider.format(15) == "15 s", "how long it stays is a setting (0: until closed)")
banner.scripts.OnClick(banner)
check(not banner.shown and LorekeepersCodexFrame.shown and LorekeepersCodexChar.read["war-of-the-three-hammers"], "clicking the banner opens the book at its page")
LorekeepersCodexFrame:Hide()
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

-- Kills: the killer is in the combat log's PARTY_KILL. On Forever, which has
-- no combat log for addons, meeting the creature (targeting it) counts.
local function kill(source, id)
  if FOREVER then
    if source ~= PLAYER and source ~= PET then return end
    local was = state.target
    state.target = id
    fire("PLAYER_TARGET_CHANGED")
    state.target = was
    return
  end
  combatLog = { clock, "PARTY_KILL", false, source, "Thorin", 0, 0, creature(id), "?", 0, 0 }
  fire("COMBAT_LOG_EVENT_UNFILTERED")
end
if FOREVER then
  check(not events.registered.COMBAT_LOG_EVENT_UNFILTERED and ns.meetKills and ns.forever, "Forever: the combat log isn't registered, meeting a creature counts instead")
else
  check(events.registered.COMBAT_LOG_EVENT_UNFILTERED and not ns.meetKills, "Classic: kills come from the combat log")
end
kill("Player-6113-0FFFFFFF", 1123)
check(not has("frostmane-trolls"), "someone else's kill unlocks nothing")
kill(PLAYER, 99999)
check(not has("frostmane-trolls"), "a creature no page names unlocks nothing")
kill(PLAYER, 1123)
check(has("frostmane-trolls"), "killing a Frostmane Headhunter unlocks the Frostmane trolls")
kill(PET, 1132)
check(has("timber"), "your pet killing Timber (a rare) counts")
check(ns.earned("wanderer-one") and not ns.earned("wanderer-one").retro, "… and earns an achievement, A Tale Worth Telling")
check(said("achievement earned: |cffffd100|Hlorekeeper:ach:wanderer-one|h[A Tale Worth Telling]|h|r"), "… announced in chat as a link")
check(LorekeepersCodexBanner.achievement == "wanderer-one", "… and on the banner")
kill(PLAYER, 706)
check(sounds == 11 and ns.earned("pages-10"), "another Frostmane kill adds nothing (the tenth page earned Ink on the Fingers)")

state.zone, state.sub = "Ironforge", ""
fire("ZONE_CHANGED_NEW_AREA")
check(has("ironforge"), "entering Ironforge unlocks its page")

-- A click on a page link in chat opens the book at that page.
check(linkHandlers.lorekeeper ~= nil, "codex links have a handler")
check(linkHandlers.lorekeeper("lorekeeper:kharanos") == 2 and LorekeepersCodexFrame.shown, "clicking [Kharanos] in chat opens the book")
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
check(LorekeepersCodexSettings.minimapHidden and not LorekeepersCodexMinimapButton.shown, "/codex minimap hides the button")
SlashCmdList.LOREKEEPERSCODEX("minimap")
SlashCmdList.LOREKEEPERSCODEX("banner")
check(panel.settings.LOREKEEPERSCODEX_BANNER.get() == false, "the settings page follows /codex banner")
panel.settings.LOREKEEPERSCODEX_CHAT.set(false)
panel.settings.LOREKEEPERSCODEX_SOUND.set(3175)
check(lastSound == 3175, "choosing a sound plays it")
printed = {}
ns.unlock("menethil-harbor")
check(not LorekeepersCodexBanner.shown and #printed == 0 and lastSound == 3175, "banner and chat off: a new page only plays the chosen sound")
panel.settings.LOREKEEPERSCODEX_BANNER.set(true)
panel.settings.LOREKEEPERSCODEX_CHAT.set(true)
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
for _, o in ipairs(panel.options()) do table.insert(labels, o.label) end
check(#labels == #ns.SOUNDS and labels[#labels] == "None", "the sound can be chosen, or none")

-- ── the book ─────────────────────────────────────────────────────────────────
SlashCmdList.LOREKEEPERSCODEX("")
check(LorekeepersCodexFrame and LorekeepersCodexFrame.shown, "/codex opens the book")
check(next(LorekeepersCodexChar.read) ~= nil, "opening it shows an unread page, marked read")
check(ns.count() == 13, "13 pages found")
local expected = 0
for _, ch in ipairs(ns.content.chapters) do if ns.found(ch) > 0 then expected = expected + #ch.entries end end
for id, e in pairs(ns.content.entries) do if e.chapter == "" and ns.page(id) then expected = expected + 1 end end
check(ns.knownTotal() == expected and LorekeepersCodexFrame.count.text == ("%d of %d pages"):format(ns.count(), expected), "the book counts the pages of the opened chapters, and the foreword")
local C = ns.content
check(ns.found(C.chapters[1]) == 7 and #C.chapters[1].entries == 17, "Dun Morogh counts 7 of its 17 pages")
check(C.chapters[#C.chapters].id == "peoples" and ns.found(C.chapters[#C.chapters]) == 0, "Peoples and Powers comes last, hidden until a people is met")
check(ns.found(C.chapters[2]) == 0, "Loch Modan, not visited, has no page found: its chapter stays hidden")
check(ns.found(C.chapters[3]) == 1, "the Wetlands show once Menethil is found")
SlashCmdList.LOREKEEPERSCODEX("")
check(not LorekeepersCodexFrame.shown, "/codex again closes it")
printed = {}
SlashCmdList.LOREKEEPERSCODEX("where")
check(printed[1]:find("position: 1455 60.0 49.0", 1, true) ~= nil and printed[2]:find("npc: 2784", 1, true) ~= nil, "/codex where gives the position and target in content terms")
SlashCmdList.LOREKEEPERSCODEX("reset")
check(ns.count() > 3, "/codex reset alone only asks")
SlashCmdList.LOREKEEPERSCODEX("reset yes")
check(LorekeepersCodexChar.guid == PLAYER and LorekeepersCodexChar.entries["foreword-dwarf"] and LorekeepersCodexChar.entries.ironforge and not LorekeepersCodexChar.entries.timber, "/codex reset yes starts over, from what the character has already done")
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
LorekeepersCodexSettings.tooltipHints = false
check(hover(2091) == "", "hints can be turned off")
LorekeepersCodexSettings.tooltipHints = true
local function has_(list, id) for _, v in ipairs(list) do if v == id then return true end end end
ns.unlock("kharanos")
check(has_(ns.search("thunderbrew"), "kharanos"), "search finds a found page by its text")
check(has_(ns.search("KHARANOS"), "kharanos"), "… whatever the case")
ns.unlock("zulgurub")
check(has_(ns.search("zul'gurub"), "zulgurub") and has_(ns.search("zul\226\128\153gurub"), "zulgurub"), "… and whichever apostrophe is typed")
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
  for _, r in ipairs(ns.listRows) do if r.shown then n = n + 1 end end
  return n
end
local open = shownRows()
local titles, found, loose = 0, 0, 0
for _, ch in ipairs(C.chapters) do if ns.found(ch) > 0 then titles = titles + 1; found = found + ns.found(ch) end end
for id, e in pairs(C.entries) do if e.chapter == "" and ns.page(id) then loose = loose + 1 end end
check(open == titles + found + loose, "the list shows the pages found, no placeholder for the others")
local dunRow = chapterRow(C.chapters[1].title)
check(dunRow ~= nil, "a chapter's title carries a fold")
dunRow.scripts.OnClick(dunRow)
check(LorekeepersCodexChar.collapsed[C.chapters[1].id] and shownRows() == open - ns.found(C.chapters[1]), "clicking a chapter's title folds its pages away")
check(chapterRow(C.chapters[1].title), "… the chapter's title and progress stay")
chapterRow(C.chapters[1].title).scripts.OnClick(chapterRow(C.chapters[1].title))
check(not LorekeepersCodexChar.collapsed[C.chapters[1].id] and shownRows() == open, "clicking again unfolds it")
chapterRow(C.chapters[1].title).scripts.OnClick(chapterRow(C.chapters[1].title))
linkHandlers.lorekeeper("lorekeeper:kharanos")
check(not LorekeepersCodexChar.collapsed[C.chapters[1].id], "a link to a page in a folded chapter unfolds it")
check(ns.anyUnfolded(), "with a chapter open, the button folds them all")
LorekeepersCodexFoldAll.scripts.OnClick(LorekeepersCodexFoldAll)
check(not ns.anyUnfolded() and shownRows() == titles + loose, "one click folds every chapter: only their titles remain")
LorekeepersCodexFoldAll.scripts.OnClick(LorekeepersCodexFoldAll)
check(ns.anyUnfolded() and next(LorekeepersCodexChar.collapsed) == nil, "… and the next unfolds them all")
-- Portraits: the game's still portrait of a page's creature, only where the
-- page is about one.
SetPortraitTextureFromCreatureDisplayID = function(tex, display) tex.display = display end
ns.unlock("magni-bronzebeard")
ns.open("magni-bronzebeard")
check(C.entries["magni-bronzebeard"].portrait and LorekeepersCodexPage.icon.shown
  and LorekeepersCodexPage.icon.tex.display == C.entries["magni-bronzebeard"].portrait, "a figure's page shows the figure's portrait")
LorekeepersCodexPage.icon.tex.SetTexture = function(self, file) self.file = file end
ns.open("kharanos")
check(not C.entries.kharanos.portrait and LorekeepersCodexPage.icon.shown and LorekeepersCodexPage.icon.tex.file:find("Map", 1, true),
  "… a place's page a map, the icon of every place")
LorekeepersCodexFrame:Hide()

-- ── the library ──────────────────────────────────────────────────────────────
-- The game's reader: a text, its pages, and who wrote it (players' letters).
local reader
local libraryFrame
for _, f in ipairs(frames) do if f.registered.ITEM_TEXT_BEGIN then libraryFrame = f end end
function ItemTextGetItem() return reader.title end
function ItemTextGetMaterial() return reader.material end
function ItemTextGetCreator() return reader.creator end
function ItemTextGetPage() return reader.page end
function ItemTextGetText() return reader.pages[reader.page] end
function ItemTextHasNextPage() return reader.page < #reader.pages end
local function readerEvent(e) libraryFrame.scripts.OnEvent(libraryFrame, e) end
function ItemTextNextPage() reader.page = reader.page + 1; readerEvent("ITEM_TEXT_READY") end
function ItemTextPrevPage() reader.page = reader.page - 1; readerEvent("ITEM_TEXT_READY") end
-- Opening a text shows its first page; the reader closes on whatever page
-- it shows then.
local function read(title, pages, material, creator)
  reader = { title = title, pages = pages, page = 1, material = material or "Parchment", creator = creator }
  readerEvent("ITEM_TEXT_BEGIN")
  readerEvent("ITEM_TEXT_READY")
  local shownAfter = reader.page
  readerEvent("ITEM_TEXT_CLOSED")
  return shownAfter
end
printed = {}
local quelThalas = { "In the beginning...", "<HTML><BODY><H1>The Sunwell</H1><P>And so it was.</P></BODY></HTML>", "The end." }
local shown = read("The Founding of Quel'Thalas", quelThalas)
local book = LorekeepersCodexChar.library.texts[1]
check(book and book.pages[1] and book.pages[2] and book.pages[3] and book.count == 3 and shown == 1
  and said("copied into the Library: |cffffd100|Hlorekeeper:lib:1|h[The Founding of Quel'Thalas]|h|r"),
  "a book opened is copied whole at once (every page turned, then back to the first), and announced with a link")
check(book.zone == state.zone and ns.libraryShelf(book) == "books", "… with where it was found; several pages make a book")
check(ns.libraryPlain(book.pages[2]) == "The Sunwell\n\nAnd so it was.", "the game's HTML becomes plain paragraphs")
read("Ironforge plaque", { "Here stood..." }, "Bronze")
check(ns.libraryShelf(LorekeepersCodexChar.library.texts[2]) == "plaques", "texts cut in metal or stone are plaques")
read("A letter", { "Dear friend, my secret..." }, "Parchment", "Someplayer")
check(not LorekeepersCodexChar.library.texts[3], "a letter written by a player is never copied")
LorekeepersCodexFrame:Hide()
linkHandlers.lorekeeper("lorekeeper:lib:1")
check(LorekeepersCodexFrame.shown and LorekeepersCodexFrame.selectedTab == 2 and LorekeepersCodexLibraryPage.title.text == "The Founding of Quel'Thalas"
  and LorekeepersCodexLibraryPage.body.text == "In the beginning..." and LorekeepersCodexLibraryPage.pageLabel.text == "Page 1 of 3", "a link opens the Library at the text, page 1 of 3")
LorekeepersCodexLibraryPage.next.scripts.OnClick(LorekeepersCodexLibraryPage.next)
check(LorekeepersCodexLibraryPage.body.text == "The Sunwell\n\nAnd so it was.", "… and its pages turn")
local shelves = {}
for _, r in ipairs(ns.libraryRows) do if r.shown then shelves[r.text.text] = r end end
check(shelves.Books and shelves["Plaques and Monuments"] and not shelves["Notes and Letters"], "the shelves: only those with something on them")
LorekeepersCodexFrame:Hide()

-- ── achievements ─────────────────────────────────────────────────────────────
local seen, missing = {}, {}
for _, a in ipairs(ns.achievements) do
  assert(not seen[a.id], "duplicate achievement " .. a.id); seen[a.id] = true
end
for _, id in ipairs(ns.featPages) do if not C.entries[id] then table.insert(missing, id) end end
check(#missing == 0, "every page an achievement names exists" .. (#missing > 0 and (": " .. table.concat(missing, ", ")) or ""))
check(#ns.achievements == 9 + 4 + 9 + 4 + #C.chapters, "milestones, feats, the Library's and one achievement per chapter")
-- A codex from before achievements: what it deserves is recorded quietly.
for _, id in ipairs(C.chapters[2].entries) do ns.unlock(id, true) end
LorekeepersCodexChar.achievements = {}
printed = {}
local before = sounds
ns.checkAchievements(true)
check(ns.earned("pages-10") and ns.earned("pages-10").retro and #printed == 0 and sounds == before, "achievements a codex already deserves are recorded quietly")
local dun = C.chapters[1]
for _, id in ipairs(dun.entries) do ns.unlock(id) end
check(ns.earned("chapter-" .. dun.id) and ns.earned("chapter-" .. dun.id).level == state.level, "finding every page of a chapter earns its achievement, with the level")
local n = 0
for id in pairs(C.entries) do if ns.page(id) and n < 10 then ns.markRead(id); n = n + 1 end end
check(ns.earned("read-10"), "reading ten pages earns A Page by the Fire")
check(not ns.earned("leaders"), "meeting one leader is not enough")
for _, id in ipairs({ "thrall", "cairne-bloodhoof", "sylvanas-windrunner", "voljin" }) do ns.unlock(id) end
check(ns.earned("leaders"), "the four leaders of either side earn Friends in High Places")
LorekeepersCodexFrame:Hide()
ns.openAchievements("leaders")
check(LorekeepersCodexFrame.shown and LorekeepersCodexFrame.selectedTab == 3 and LorekeepersCodexAchievements.shown and not LorekeepersCodexList.shown, "an achievement opens the book at the achievements tab")
check(LorekeepersCodexFrame.count.text == ("%d of %d achievements"):format(ns.achievementCount()), "… which counts them")
local _, shown = ns.achievementCount()
check(shown < #ns.achievements and not ns.achievementVisible(ns.achievementById["chapter-silithus"]), "… leaving out the chapters not yet opened")
check(ns.achievementVisible(ns.achievementById["chapter-" .. dun.id]), "… but listing those already opened")
check(ns.achievementById["pages-all"].unit == "pages" and ns.achievementById["travelled"].unit == "chapters", "the whole codex's size is never shown: a count instead")
check(LorekeepersCodexAchievements.vscroll and LorekeepersCodexAchievements.vscroll > 0, "… and scrolls to the one opened")
LorekeepersCodexFrameTab1.scripts.OnClick(LorekeepersCodexFrameTab1)
check(LorekeepersCodexFrame.selectedTab == 1 and LorekeepersCodexList.shown and not LorekeepersCodexAchievements.shown, "the Pages tab brings the pages back")
LorekeepersCodexFrame:Hide()
linkHandlers.lorekeeper("lorekeeper:ach:pages-10")
check(LorekeepersCodexFrame.shown and LorekeepersCodexFrame.selectedTab == 3, "an achievement link in chat opens the achievements")
linkHandlers.lorekeeper("lorekeeper:kharanos")
check(LorekeepersCodexFrame.selectedTab == 1, "a page link goes back to the pages")
SlashCmdList.LOREKEEPERSCODEX("achievements")
check(LorekeepersCodexFrame.selectedTab == 3, "/codex achievements opens them too")
SlashCmdList.LOREKEEPERSCODEX("reset yes")
local loud = false
for _, e in pairs(LorekeepersCodexChar.achievements) do if not e.retro then loud = true end end
check(not ns.earned("leaders") and not ns.earned("chapter-" .. dun.id) and not loud, "/codex reset forgets the achievements (what the codex still earns comes back quietly)")
-- ── the two clients ───────────────────────────────────────────────────────────
check(not ns.available("foreword-skyborne"), "the Skyborne foreword is for the Skyborne")
ns.unlock("furbolgs")
check((#ns.search("blackmaw") > 0) == FOREVER and (#ns.search("another hold in azshara") > 0) == not FOREVER,
  "a page shows its Forever paragraphs on Forever only, its Classic ones elsewhere")
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
for _, f in ipairs(frames) do if f.registered.ITEM_TEXT_READY then scanFrame = f end end
local function scanFire(e, ...) scanFrame.scripts.OnEvent(scanFrame, e, ...) end
printed = {}
SlashCmdList.LOREKEEPERSCODEX("scan")
check(printed[1]:find("scan off", 1, true) and not LorekeepersCodexScan.on, "/codex scan says what it has, off by default")
state.target = 1123
scanFire("PLAYER_TARGET_CHANGED")
check(not LorekeepersCodexScan.npcs[1123], "… and records nothing while off")
SlashCmdList.LOREKEEPERSCODEX("scan on")
scanFire("PLAYER_TARGET_CHANGED")
check(LorekeepersCodexScan.on and LorekeepersCodexScan.npcs[1123] and LorekeepersCodexScan.npcs[1123].zone == state.zone, "scan on: creatures met are recorded, with where")
check(LorekeepersCodexScan.races.Dwarf and next(LorekeepersCodexScan.areas), "… with the race's token and the area")
function GetQuestID() return 4242 end
function GetTitleText() return "A Test Quest" end
function GetQuestText() return "Go and see." end
function GetObjectiveText() return "See." end
scanFire("QUEST_DETAIL")
check(LorekeepersCodexScan.quests[4242].text == "Go and see." and LorekeepersCodexScan.quests[4242].title == "A Test Quest", "… and the quests read, with their texts")
SlashCmdList.LOREKEEPERSCODEX("scan clear")
check(not LorekeepersCodexScan.quests[4242] and LorekeepersCodexScan.on, "/codex scan clear empties it")
-- The game's own toasts, where the client has them (both do: this is the
-- path the game takes; the banner above is the fallback).
local toasts = {}
AlertFrame = { AddQueuedAlertFrameSubSystem = function(_, template, setUp)
  local system = { shown = {} }
  function system:AddAlert(...)
    local f = ui()
    f.Icon, f.Title, f.Name, f.Unlocked, f.Shield = ui(), ui(), ui(), ui(), ui()
    f.Icon.Texture = ui()
    -- Forever: a texture given Texture:SetMask can't take new tex coords.
    f.Icon.SetMask = function(self) self.masked = true end
    f.Icon.SetTexCoord = function(self) assert(not rawget(self, "masked"), "Cannot set tex coords when texture has mask") end
    setUp(f, ...)
    table.insert(self.shown, f)
    return true
  end
  toasts[template] = system
  return system
end }
C_XMLUtil = { GetTemplateInfo = function() return {} end }
local durations = {}
AlertFrame_SetDuration = function(frame, seconds) durations[frame] = seconds end
AlertFrame_OnClick = function(_, button) return button == "RightButton" end
-- The shield's OnLoad lives in the game's achievement window, loaded on demand.
local loaded = {}
C_AddOns = { LoadAddOn = function(name) loaded[name] = true; AchievementShield_OnLoad = function() end end }
LorekeepersCodexSettings.banner = true
ns.hideBanner()
local pid
for id in pairs(C.entries) do if ns.page(id) and not pid then pid = id end end
ns.showBanner(pid)
local toast = toasts.NewRecipeLearnedAlertFrameTemplate and toasts.NewRecipeLearnedAlertFrameTemplate.shown[1]
check(toast and toast.Title.text == "A new page in the codex" and toast.Name.text == C.entries[pid].title
  and not LorekeepersCodexBanner.shown, "a new page shows the game's own toast, not our banner")
check(durations[toast] == ns.option("bannerSeconds"), "… for as long as the banner setting says")
LorekeepersCodexFrame:Hide()
toast.scripts.OnClick(toast, "LeftButton")
check(LorekeepersCodexFrame.shown and LorekeepersCodexPage.title.text == C.entries[pid].title, "… and a click on it opens the page")
ns.showAchievementBanner("pages-10")
local ach = toasts.AchievementAlertFrameTemplate.shown[1]
check(ach and ach.Name.text == ns.achievementById["pages-10"].title and ach.Unlocked.text == "Codex achievement" and not ach.Shield.shown,
  "an achievement shows the game's achievement toast, with no points")
check(loaded.Blizzard_AchievementUI, "… having loaded the game's achievement window first (its shield needs it)")
AlertFrame, C_XMLUtil = nil, nil

io.write(FOREVER and "all good (Forever)\n" or "all good\n")
