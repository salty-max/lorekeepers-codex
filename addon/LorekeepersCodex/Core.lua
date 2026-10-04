-- Lorekeeper's Codex: the entries in Content.lua (built from content/*.md)
-- unlock as this character explores. Each unlock is a page in its codex, with
-- when, at what level and where it was found.
local _, ns = ...
local C = ns.content
local PREFIX = "|cffc9a227Lorekeeper's Codex:|r "

-- This character's codex (SavedVariablesPerCharacter):
--   entries[id] = { at, level, zone, sub, retro }   unlocked pages
--   read[id] = true                                 pages already opened
local char

-- ── what unlocks what ────────────────────────────────────────────────────────
local byArea, byNpc, byKill, byQuest, byMap, byFaction, always = {}, {}, {}, {}, {}, {}, {}
local function push(t, k, v)
  t[k] = t[k] or {}
  table.insert(t[k], v)
end
for id, e in pairs(C.entries) do
  for _, u in ipairs(e.unlock) do
    if u.always then table.insert(always, id)
    elseif u.area then push(byArea, u.area, id)
    elseif u.npc then push(byNpc, u.npc, id)
    elseif u.kill then push(byKill, u.kill, id)
    elseif u.quest then push(byQuest, u.quest, id)
    elseif u.faction then table.insert(byFaction, { id = id, faction = u.faction, standing = u.standing })
    elseif u.map then push(byMap, u.map, { id = id, x = u.x, y = u.y, r = u.r })
    end
  end
end

-- The pages a creature unlocks (by talking to it or killing it), for the
-- tooltip hint.
function ns.pagesOfNpc(npcId)
  local out, seen = {}, {}
  for _, t in ipairs({ byNpc[npcId] or {}, byKill[npcId] or {} }) do
    for _, id in ipairs(t) do
      if not seen[id] then seen[id] = true; table.insert(out, id) end
    end
  end
  return out
end

-- Areas are matched by name as the client shows it, in its own language: the
-- names of the area ids come from the client (C_Map.GetAreaInfo), English as
-- a fallback.
local areasByName = {}
local function indexAreas()
  for areaId in pairs(byArea) do
    local name = C_Map and C_Map.GetAreaInfo and C_Map.GetAreaInfo(areaId)
    if not name or name == "" then name = C.areaNames[areaId] end
    if name then push(areasByName, name, areaId) end
  end
end

-- ── the codex ────────────────────────────────────────────────────────────────
-- Some pages are for some races only (the forewords): a character neither
-- sees nor counts the others. "other" stands for the races without a page of
-- their own (the Burning Crusade's).
local RACES = { Human = true, Dwarf = true, NightElf = true, Gnome = true, Orc = true, Troll = true, Tauren = true, Scourge = true }
local race
function ns.available(id)
  local e = C.entries[id]
  if not e then return false end
  if not e.race then return true end
  if not race then return false end
  return e.race[race] or (e.race.other and not RACES[race]) or false
end

local function countTotal()
  ns.total = 0
  for id in pairs(C.entries) do
    if ns.available(id) then ns.total = ns.total + 1 end
  end
end
countTotal()

function ns.page(id) return char and ns.available(id) and char.entries[id] or nil end
function ns.isRead(id) return char and char.read[id] end
function ns.markRead(id) if char then char.read[id] = true end end
function ns.count()
  local n = 0
  if char then for id in pairs(char.entries) do if ns.available(id) then n = n + 1 end end end
  return n
end

-- retro: found by looking back (a quest done before the addon, a page given
-- from the start): recorded quietly.
local function unlock(id, retro)
  if not char or char.entries[id] or not ns.available(id) then return end
  char.entries[id] = {
    at = time(),
    level = UnitLevel("player"),
    zone = GetRealZoneText(),
    sub = GetSubZoneText(),
    retro = retro or nil,
  }
  if not retro then
    -- A link: clicking it opens the book at this page (see Codex.lua).
    if ns.option("chat") then
      print(PREFIX .. ("|cffffd100|Hlorekeeper:%s|h[%s]|h|r has been added to the codex."):format(id, C.entries[id].title))
    end
    ns.playSound()
    ns.showBanner(id)
  end
  if ns.onUnlock then ns.onUnlock(id) end
end
ns.unlock = unlock

local function checkArea()
  for _, name in ipairs({ GetRealZoneText() or "", GetSubZoneText() or "" }) do
    for _, areaId in ipairs(areasByName[name] or {}) do
      for _, id in ipairs(byArea[areaId]) do unlock(id) end
    end
  end
end

local function checkPosition()
  local map = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  local spots = map and byMap[map]
  if not spots then return end
  local pos = C_Map.GetPlayerMapPosition(map, "player")
  if not pos then return end
  local x, y = pos.x * 100, pos.y * 100
  for _, s in ipairs(spots) do
    if (x - s.x) ^ 2 + (y - s.y) ^ 2 <= s.r ^ 2 then unlock(s.id) end
  end
end

local function creatureId(guid)
  if not guid then return end
  local kind, _, _, _, _, id = strsplit("-", guid)
  if kind == "Creature" then return tonumber(id) end
end
local function npcId(unit) return creatureId(UnitGUID(unit)) end
ns.npcId = npcId

local function checkNpc(unit)
  local id = npcId(unit)
  for _, entry in ipairs(id and byNpc[id] or {}) do unlock(entry) end
end

local function questDone(id)
  if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then return C_QuestLog.IsQuestFlaggedCompleted(id) end
  return IsQuestFlaggedCompleted and IsQuestFlaggedCompleted(id)
end

local function checkFactions(retro)
  for _, f in ipairs(byFaction) do
    local _, _, standing = GetFactionInfoByID(f.faction)
    if standing and standing >= f.standing then unlock(f.id, retro) end
  end
end

-- ── events ───────────────────────────────────────────────────────────────────
local frame = CreateFrame("Frame")
local handlers = {}

-- The game keeps a character's saved variables under its name, so a new
-- character named like a deleted one inherits its pages. Each codex remembers
-- whose it is (the character's GUID, unique to it). One saved before it did
-- (0.1.2 and earlier) can't say: it's dropped when this character is brand
-- new (level 1, no experience: it can't have found pages yet) or when it holds
-- pages found at a higher level than this character has.
function ns.belongsTo(saved, guid, level, xp)
  if type(saved) ~= "table" then return false end
  if saved.guid then return saved.guid == guid end
  if level <= 1 and (xp or 0) == 0 then return false end
  for _, p in pairs(saved.entries or {}) do
    if (p.level or 0) > level then return false end
  end
  return true
end

-- Pages this character has from the start: the foreword, and what it did
-- before the codex (quests, reputations, where it stands).
local function catchUp()
  for _, id in ipairs(always) do unlock(id, true) end
  for questId, ids in pairs(byQuest) do
    if questDone(questId) then for _, id in ipairs(ids) do unlock(id, true) end end
  end
  checkFactions(true)
  checkArea()
end

local function newCodex(guid)
  LorekeepersCodexChar = { guid = guid, entries = {}, read = {} }
  char = LorekeepersCodexChar
end

function handlers.PLAYER_LOGIN()
  race = select(2, UnitRace("player"))
  countTotal()
  local guid = UnitGUID("player")
  if ns.belongsTo(LorekeepersCodexChar, guid, UnitLevel("player"), UnitXP("player")) then
    char = LorekeepersCodexChar
    char.guid = guid
    char.entries = char.entries or {}
    char.read = char.read or {}
  else
    newCodex(guid)
  end
  indexAreas()
  catchUp()
  if C_Timer and next(byMap) then C_Timer.NewTicker(2, checkPosition) end
  ns.createMinimapButton()
  ns.createSettingsPanel()
  -- The only reminder of how to open the book: once, at login.
  print(PREFIX .. ("%d of %d pages. Type /codex or click the book by the minimap to read them."):format(ns.count(), ns.total))
end

handlers.ZONE_CHANGED = checkArea
handlers.ZONE_CHANGED_INDOORS = checkArea
handlers.ZONE_CHANGED_NEW_AREA = checkArea
handlers.PLAYER_ENTERING_WORLD = checkArea
handlers.PLAYER_TARGET_CHANGED = function() checkNpc("target") end
local function talking() checkNpc("npc") end
handlers.GOSSIP_SHOW = talking
handlers.QUEST_GREETING = talking
handlers.QUEST_DETAIL = talking
handlers.MERCHANT_SHOW = talking
handlers.UPDATE_FACTION = function() checkFactions(false) end
-- Kills: yours or your pet's (the combat log's PARTY_KILL names the killer).
function handlers.COMBAT_LOG_EVENT_UNFILTERED()
  local _, sub, _, source, _, _, _, dest = CombatLogGetCurrentEventInfo()
  if sub ~= "PARTY_KILL" or (source ~= UnitGUID("player") and source ~= UnitGUID("pet")) then return end
  local id = creatureId(dest)
  for _, entry in ipairs(id and byKill[id] or {}) do unlock(entry) end
end

function handlers.QUEST_TURNED_IN(questId)
  for _, id in ipairs(byQuest[questId] or {}) do unlock(id) end
end

frame:SetScript("OnEvent", function(_, event, ...)
  if event ~= "PLAYER_LOGIN" and not char then return end
  handlers[event](...)
end)
for event in pairs(handlers) do frame:RegisterEvent(event) end

-- ── /codex ───────────────────────────────────────────────────────────────────
SLASH_LOREKEEPERSCODEX1 = "/codex"
SLASH_LOREKEEPERSCODEX2 = "/lorekeeper"
SlashCmdList.LOREKEEPERSCODEX = function(msg)
  msg = strtrim((msg or ""):lower())
  if msg == "where" then
    -- For writing content: where am I, in the terms the content files use.
    local map = C_Map.GetBestMapForUnit("player")
    local pos = map and C_Map.GetPlayerMapPosition(map, "player")
    print(PREFIX .. ("%s / %s · uiMap %s · %s"):format(
      GetRealZoneText() or "?", GetSubZoneText() ~= "" and GetSubZoneText() or "-", tostring(map),
      pos and ("position: %d %.1f %.1f"):format(map, pos.x * 100, pos.y * 100) or "no position"))
    local target = npcId("target")
    if target then print(PREFIX .. ("target: npc: %d (%s)"):format(target, UnitName("target") or "?")) end
    return
  end
  if msg == "reset" then
    print(PREFIX .. "this forgets every page this character has found. Type /codex reset yes to do it.")
    return
  end
  if msg == "reset yes" then
    newCodex(char.guid)
    catchUp()
    if ns.refresh then ns.refresh() end
    print(PREFIX .. ("the codex starts afresh: %d of %d pages."):format(ns.count(), ns.total))
    return
  end
  if msg == "banner" then
    ns.setOption("banner", not ns.option("banner"))
    print(PREFIX .. (ns.option("banner") and "banner shown for new pages." or "banner hidden (/codex banner to show it again)."))
    return
  end
  if msg == "minimap" then
    ns.setOption("minimapHidden", not ns.option("minimapHidden"))
    print(PREFIX .. (ns.option("minimapHidden") and "minimap button hidden (/codex minimap to show it again)." or "minimap button shown."))
    return
  end
  if msg == "settings" or msg == "options" then
    if not ns.openSettings() then print(PREFIX .. "no settings page in this client: use /codex banner and /codex minimap.") end
    return
  end
  if ns.toggle then ns.toggle() end
end
