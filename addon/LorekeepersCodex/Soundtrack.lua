-- The soundtrack: the tunes of the game's music (kind "tune" in the content,
-- each one a ZoneMusic set), found by standing where they play with the
-- music on, and played again from the Soundtrack tab (SoundtrackBook.lua).
-- The client tells nothing of the music playing now (no event, no call), so
-- the signal is the place: the zone's or subzone's area (the content's
-- music.areas, the client's AreaTable with the parents' music resolved), kept
-- for DWELL seconds with music enabled. A tune is found, never "heard".
-- A find: char.tunes[id] = { at, level, zoneId, subId } (the pages' record).
local _, ns = ...
local L = ns.kit.L
local C = ns.content
local M = C.music
local secret = ns.secret

local DWELL, TICK = 45, 5
ns.SOUNDTRACK_DWELL = DWELL

-- the tune of each set
local tuneOfSet, tunes = {}, {}
for id, e in pairs(C.entries) do
  if e.kind == "tune" then
    table.insert(tunes, id)
    for _, u in ipairs(e.unlock) do
      if u.music then tuneOfSet[u.music] = id end
    end
  end
end
table.sort(tunes, function(a, b) return C.entries[a].title < C.entries[b].title end)
ns.tunes = tunes

function ns.tune(id)
  local char = ns.codex()
  return char and char.tunes and char.tunes[id] or nil
end
function ns.tuneCount()
  local char, n = ns.codex(), 0
  for id in pairs(char and char.tunes or {}) do
    if C.entries[id] then n = n + 1 end
  end
  return n
end
-- A tune's tracks: { { file, period } }, in the client's order.
function ns.tracksOf(id)
  local e = C.entries[id]
  for _, u in ipairs(e and e.unlock or {}) do
    if u.music then return M.sets[u.music] or {} end
  end
  return {}
end

-- ── where the player stands ──────────────────────────────────────────────────
-- area ids by the client's name for them, built when first wanted (the client
-- names them once the world is loaded)
local byName
local function indexAreas()
  byName = {}
  for areaId in pairs(M.areas) do
    local name = C_Map and C_Map.GetAreaInfo and C_Map.GetAreaInfo(areaId)
    if not name or name == "" then name = C.areaNames[areaId] end
    if name then
      byName[name] = byName[name] or {}
      table.insert(byName[name], areaId)
    end
  end
end
local function nameOf(areaId)
  local name = C_Map and C_Map.GetAreaInfo and C_Map.GetAreaInfo(areaId)
  if not name or name == "" then name = C.areaNames[areaId] end
  return name
end
-- an area is within a zone of this name when its parent chain names it
local function within(areaId, zone)
  for _ = 1, 6 do
    local row = M.areas[areaId]
    local parent = row and row[1]
    if not parent or parent == 0 then return false end
    if nameOf(parent) == zone then return true end
    areaId = parent
  end
  return false
end

-- The sets the player's place plays: the subzone's if the music data has it
-- (within the zone named), else the zone's. A building pinned to a whole city
-- (inexact) plays "somewhere in it": all of those count.
local function setsHere()
  if not byName then indexAreas() end
  local zone, sub = GetRealZoneText(), GetSubZoneText()
  if type(zone) ~= "string" or secret(zone) then return {} end
  if type(sub) ~= "string" or secret(sub) or sub == "" then sub = nil end
  local out = {}
  -- the sets of the areas of this name (within the zone), and whether any of them plays music
  local function take(ids, narrow)
    local matched = false
    for _, areaId in ipairs(ids or {}) do
      if not narrow or within(areaId, zone) or nameOf(areaId) == zone then
        matched = true
        local row = M.areas[areaId]
        for i = 2, #row do
          out[row[i][1]] = true
        end
      end
    end
    return matched
  end
  -- a subzone with music of its own (a set no tune names too) is never taken for its zone
  local matched = sub and sub ~= zone and take(byName[sub], true)
  if not matched then take(byName[zone], false) end
  return out
end

local function musicOn()
  if not GetCVar then return true end
  local all, music, volume = GetCVar("Sound_EnableAllSound"), GetCVar("Sound_EnableMusic"), GetCVar("Sound_MusicVolume")
  return all ~= "0" and music ~= "0" and (tonumber(volume) or 1) > 0
end
ns.musicOn = musicOn

-- ── finding a tune ───────────────────────────────────────────────────────────
local function find(id)
  local char = ns.codex()
  if not char or not C.entries[id] then return end
  char.tunes = char.tunes or {}
  if char.tunes[id] then return end
  local rec = ns.placeOf(GetRealZoneText(), GetSubZoneText())
  rec.at, rec.level = time(), UnitLevel("player")
  char.tunes[id] = rec
  local link = ("|cffffd100|Hlorekeeper:tune:%s|h[%s]|h|r"):format(id, C.entries[id].title)
  print(ns.PREFIX .. L["%s has been added to the soundtrack."]:format(link))
  ns.playSound()
  if ns.showTuneBanner then ns.showTuneBanner(id) end
  if ns.onTune then ns.onTune(id) end
  if ns.checkAchievements then ns.checkAchievements() end
end
ns.findTune = find

local key, seconds = "", 0
local function tick()
  if not ns.codex() then return end
  if UnitOnTaxi and UnitOnTaxi("player") then return end
  local sets, ids = setsHere(), {}
  for set in pairs(sets) do
    if tuneOfSet[set] then table.insert(ids, set) end
  end
  table.sort(ids)
  local now = table.concat(ids, ",")
  if now ~= key then
    key, seconds = now, 0
  end
  if #ids == 0 or not musicOn() then return end
  seconds = seconds + TICK
  if seconds < DWELL then return end
  for _, set in ipairs(ids) do
    find(tuneOfSet[set])
  end
end
ns.soundtrackTick = tick

-- a tick was missed on a flight or a loading screen: the place starts afresh
for _, event in ipairs({ "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD" }) do
  ns.on(event, function() seconds = 0 end)
end
ns.on("PLAYER_ENTERING_WORLD", function()
  if not ns.soundtrackTicker and C_Timer and C_Timer.NewTicker then
    ns.soundtrackTicker = C_Timer.NewTicker(TICK, tick)
  end
end)

-- ── playing one again ────────────────────────────────────────────────────────
-- PlayMusic(fileDataID) loops until StopMusic: one track at a time. It says
-- true even for an id it can't play, so nothing here claims it sounded.
local playing
function ns.playTrack(id, file)
  if not ns.tune(id) or not PlayMusic then return end
  playing = { id = id, file = file }
  PlayMusic(file)
  if ns.onPlaying then ns.onPlaying() end
end
function ns.stopMusic()
  if not playing then return end
  playing = nil
  if StopMusic then StopMusic() end
  if ns.onPlaying then ns.onPlaying() end
end
function ns.nowPlaying() return playing end
ns.on("PLAYER_LOGOUT", function()
  if playing and StopMusic then StopMusic() end
end)
