-- What unlocks a page (Content.lua's unlock rules) and the pages this
-- character has: places entered, creatures talked to or targeted, kills by
-- you or your pet, quests done (before the codex too), reputations reached,
-- spots stood on, players met (their people's page and their calling's, one's
-- own from the start). Each unlock is a page in the codex, with when, at what
-- level and where it was found.
local _, ns = ...
local C = ns.content
local PREFIX, secret = ns.PREFIX, ns.secret

-- ── what unlocks what ────────────────────────────────────────────────────────
local byArea, byNpc, byKill, byQuest, byMap, byFaction, always = {}, {}, {}, {}, {}, {}, {}
local byPeople, byCalling = {}, {} -- (a race's page, a class's: one's own, or a player met)
local function push(t, k, v)
  t[k] = t[k] or {}
  table.insert(t[k], v)
end
for id, e in pairs(C.entries) do
  for _, u in ipairs(e.unlock) do
    if u.always then
      table.insert(always, id)
    elseif u.area then
      push(byArea, u.area, id)
    elseif u.npc then
      push(byNpc, u.npc, id)
    elseif u.kill then
      push(byKill, u.kill, id)
    elseif u.quest then
      push(byQuest, u.quest, id)
    elseif u.faction then
      table.insert(byFaction, { id = id, faction = u.faction, standing = u.standing })
    elseif u.map then
      push(byMap, u.map, { id = id, x = u.x, y = u.y, r = u.r })
    elseif u.people then
      push(byPeople, u.people, id)
    elseif u.calling then
      push(byCalling, u.calling, id)
    end
  end
end

-- The pages a creature unlocks (by talking to it or killing it), for the
-- tooltip hint.
function ns.pagesOfNpc(npcId)
  local out, seen = {}, {}
  for _, t in ipairs({ byNpc[npcId] or {}, byKill[npcId] or {} }) do
    for _, id in ipairs(t) do
      if not seen[id] then
        seen[id] = true
        table.insert(out, id)
      end
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
-- their own (the Burning Crusade's). Forever's Skyborne have their own.
local RACES = {
  Human = true,
  Dwarf = true,
  NightElf = true,
  Gnome = true,
  Orc = true,
  Troll = true,
  Tauren = true,
  Scourge = true,
  Skyborne = true,
}
local race
function ns.available(id)
  local e = C.entries[id]
  if not e then return false end
  if e.client and e.client ~= ns.client then return false end
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

function ns.page(id)
  local char = ns.codex()
  return char and ns.available(id) and char.entries[id] or nil
end
function ns.isRead(id)
  local char = ns.codex()
  return char and char.read[id]
end
function ns.markRead(id)
  local char = ns.codex()
  if not char or char.read[id] then return end
  char.read[id] = true
  ns.checkAchievements()
end
-- The pages a reader may know of: those of the chapters it has opened (one
-- page found) and its foreword. The codex's full size would be a spoiler.
function ns.knownTotal()
  local n = 0
  for id, e in pairs(C.entries) do
    if e.chapter == "" and ns.page(id) then n = n + 1 end
  end
  for _, ch in ipairs(C.chapters) do
    for _, id in ipairs(ch.entries) do
      if ns.page(id) then
        n = n + #ch.entries
        break
      end
    end
  end
  return n
end

function ns.count()
  local char, n = ns.codex(), 0
  for id in pairs(char and char.entries or {}) do
    if ns.available(id) then n = n + 1 end
  end
  return n
end

-- retro: found by looking back (a quest done before the addon, a page given
-- from the start): recorded quietly.
local function unlock(id, retro)
  local char = ns.codex()
  if not char or char.entries[id] or not ns.available(id) then return end
  char.entries[id] = {
    at = time(),
    level = UnitLevel("player"),
    zone = GetRealZoneText(),
    sub = GetSubZoneText(),
    retro = retro or nil,
  }
  if not retro then
    -- A link: clicking it opens the book at this page (see Book.lua).
    if ns.option("chat") then
      print(
        PREFIX .. ("|cffffd100|Hlorekeeper:%s|h[%s]|h|r has been added to the codex."):format(id, C.entries[id].title)
      )
    end
    ns.playSound()
    ns.showBanner(id)
  end
  if ns.onUnlock then ns.onUnlock(id) end
  ns.checkAchievements(retro)
end
ns.unlock = unlock

-- ── what this character does ─────────────────────────────────────────────────
local function checkArea()
  for _, name in ipairs({ GetRealZoneText() or "", GetSubZoneText() or "" }) do
    for _, areaId in ipairs(areasByName[name] or {}) do
      for _, id in ipairs(byArea[areaId]) do
        unlock(id)
      end
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
  if not guid or secret(guid) then return end
  local kind, _, _, _, _, id = strsplit("-", guid)
  if kind == "Creature" then return tonumber(id) end
end
local function npcId(unit) return creatureId(UnitGUID(unit)) end
ns.npcId = npcId

local function checkNpc(unit)
  local id = npcId(unit)
  for _, entry in ipairs(id and byNpc[id] or {}) do
    unlock(entry)
  end
end

-- A player met (targeted): their people's page and their calling's, and the
-- meeting itself, for the encounters (Achievements.lua).
local function checkPlayer(unit)
  if not UnitIsPlayer(unit) or UnitIsUnit(unit, "player") then return end
  local _, people = UnitRace(unit)
  local _, calling = UnitClass(unit)
  if not people or not calling or secret(people) or secret(calling) then return end
  for _, id in ipairs(byPeople[people] or {}) do
    unlock(id)
  end
  for _, id in ipairs(byCalling[calling] or {}) do
    unlock(id)
  end
  local met = ns.codex().met
  local combo = people .. ":" .. calling
  if not met.combos[combo] then
    met.races[people], met.classes[calling], met.combos[combo] = true, true, true
    ns.checkAchievements()
  end
end

local function questDone(id)
  if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then return C_QuestLog.IsQuestFlaggedCompleted(id) end
  return IsQuestFlaggedCompleted and IsQuestFlaggedCompleted(id)
end

-- A faction's standing (1 hated .. 8 exalted): the old function on Classic,
-- C_Reputation on the modern client.
local function standingWith(faction)
  if C_Reputation and C_Reputation.GetFactionDataByID then
    local data = C_Reputation.GetFactionDataByID(faction)
    return data and data.reaction
  end
  if GetFactionInfoByID then return (select(3, GetFactionInfoByID(faction))) end
end

local function checkFactions(retro)
  for _, f in ipairs(byFaction) do
    local standing = standingWith(f.faction)
    if standing and standing >= f.standing then unlock(f.id, retro) end
  end
end

-- Kills: yours or your pet's, however dealt (a DoT, an area spell, a creature
-- never targeted). PARTY_KILL (killer, victim) is an event of its own where the
-- client has it (Forever, Classic since 1.15.9), else a line of the combat
-- log (never on Forever, which forbids it); secret only in a Forever
-- instance, where no creature can be told.
local function killed(attacker, victim)
  if not attacker or secret(attacker) or (attacker ~= UnitGUID("player") and attacker ~= UnitGUID("pet")) then
    return
  end
  local id = creatureId(victim)
  for _, entry in ipairs(id and byKill[id] or {}) do
    unlock(entry)
  end
end
ns.partyKill = ns.knows("PARTY_KILL")
if ns.partyKill then
  ns.on("PARTY_KILL", killed)
elseif not ns.forever then
  ns.on("COMBAT_LOG_EVENT_UNFILTERED", function()
    local _, sub, _, source, _, _, _, dest = CombatLogGetCurrentEventInfo()
    if sub == "PARTY_KILL" then killed(source, dest) end
  end)
end

for _, event in ipairs({ "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD" }) do
  ns.on(event, checkArea)
end
ns.on("PLAYER_TARGET_CHANGED", function()
  checkNpc("target")
  checkPlayer("target")
end)
local function talking() checkNpc("npc") end
for _, event in ipairs({ "GOSSIP_SHOW", "QUEST_GREETING", "QUEST_DETAIL", "MERCHANT_SHOW" }) do
  ns.on(event, talking)
end
ns.on("UPDATE_FACTION", function() checkFactions(false) end)
ns.on("QUEST_TURNED_IN", function(questId)
  for _, id in ipairs(byQuest[questId] or {}) do
    unlock(id)
  end
end)

-- ── the start ────────────────────────────────────────────────────────────────
-- Pages this character has from the start: the foreword, its own people's
-- and calling's, and what it did before the codex (quests, reputations,
-- where it stands); then the achievements it deserves, all quietly.
function ns.catchUp()
  for _, id in ipairs(always) do
    unlock(id, true)
  end
  local calling = select(2, UnitClass("player"))
  for _, id in ipairs(byPeople[race or ""] or {}) do
    unlock(id, true)
  end
  for _, id in ipairs(byCalling[calling or ""] or {}) do
    unlock(id, true)
  end
  for questId, ids in pairs(byQuest) do
    if questDone(questId) then
      for _, id in ipairs(ids) do
        unlock(id, true)
      end
    end
  end
  checkFactions(true)
  checkArea()
  ns.checkAchievements(true)
end

-- At the login (Core.lua): this character's race (some pages are its own),
-- the areas by the client's names, what it deserves already (saved before
-- achievements existed, then what it finds on catching up), and the spots
-- watched while the codex has any.
function ns.startUnlocks()
  race = select(2, UnitRace("player"))
  countTotal()
  indexAreas()
  ns.checkAchievements(true)
  ns.catchUp()
  if C_Timer and next(byMap) then C_Timer.NewTicker(2, checkPosition) end
end
