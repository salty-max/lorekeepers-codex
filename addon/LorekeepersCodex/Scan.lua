-- /codex scan: while on, records what writing new pages needs, for the whole
-- account (LorekeepersCodexScan): the areas entered, the creatures met (id,
-- name, where), the quests read (id, title and texts), what NPCs say and the
-- books read. Off by default. Made for Forever's new content, whose ids and
-- texts no database has yet; scripts/scan-export.lua turns it into JSON.
local _, ns = ...
local PREFIX = "|cffc9a227Lorekeeper's Codex:|r "

local function db()
  LorekeepersCodexScan = LorekeepersCodexScan or {}
  local s = LorekeepersCodexScan
  s.areas = s.areas or {}
  s.npcs = s.npcs or {}
  s.quests = s.quests or {}
  s.gossip = s.gossip or {}
  s.books = s.books or {}
  return s
end

local function clean(v)
  if v == nil or ns.secret(v) then return nil end
  return v
end

-- Where the player stands: zone, subzone, map and position.
local function here()
  local map = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  local pos = map and C_Map.GetPlayerMapPosition(map, "player")
  return {
    zone = GetRealZoneText(),
    sub = GetSubZoneText(),
    map = map,
    x = pos and math.floor(pos.x * 1000 + 0.5) / 10,
    y = pos and math.floor(pos.y * 1000 + 0.5) / 10,
  }
end

local function area()
  local h = here()
  local key = (h.zone or "?") .. " / " .. (h.sub ~= "" and h.sub or "-")
  local a = db().areas
  if not a[key] then
    h.seen = time()
    a[key] = h
  end
end

local function creature(unit)
  local id = ns.npcId(unit)
  if not id then return end
  local n = db().npcs
  local h = here()
  local entry = n[id] or { name = clean(UnitName(unit)), level = clean(UnitLevel(unit)), seen = time() }
  entry.zone, entry.sub, entry.map, entry.x, entry.y = h.zone, h.sub, h.map, h.x, h.y
  entry.count = (entry.count or 0) + 1
  n[id] = entry
end

local function quest(field, text)
  local id = GetQuestID and GetQuestID()
  if not id or id == 0 then return end
  local q = db().quests
  q[id] = q[id] or { title = GetTitleText and GetTitleText(), seen = time() }
  q[id][field] = text
  if field == "text" then
    q[id].objective = GetObjectiveText and GetObjectiveText()
    q[id].giver = clean(UnitName("npc"))
    q[id].giverId = ns.npcId("npc")
    local h = here()
    q[id].zone, q[id].sub = h.zone, h.sub
  end
end

local frame = CreateFrame("Frame")
local handlers = {
  ZONE_CHANGED = area,
  ZONE_CHANGED_INDOORS = area,
  ZONE_CHANGED_NEW_AREA = area,
  PLAYER_TARGET_CHANGED = function() creature("target") end,
  UPDATE_MOUSEOVER_UNIT = function() creature("mouseover") end,
  QUEST_DETAIL = function() quest("text", GetQuestText and GetQuestText()) end,
  QUEST_PROGRESS = function() quest("progress", GetProgressText and GetProgressText()) end,
  QUEST_COMPLETE = function() quest("completion", GetRewardText and GetRewardText()) end,
  GOSSIP_SHOW = function()
    local id = ns.npcId("npc")
    local text = C_GossipInfo and C_GossipInfo.GetText and C_GossipInfo.GetText() or (GetGossipText and GetGossipText())
    if id and text and text ~= "" then db().gossip[id] = { name = clean(UnitName("npc")), text = text } end
  end,
  ITEM_TEXT_READY = function()
    local title = ItemTextGetItem and ItemTextGetItem()
    if not title then return end
    local b = db().books
    b[title] = b[title] or { pages = {} }
    b[title].pages[ItemTextGetPage and ItemTextGetPage() or 1] = ItemTextGetText and ItemTextGetText()
  end,
}
frame:SetScript("OnEvent", function(_, event, ...)
  if LorekeepersCodexScan and LorekeepersCodexScan.on and handlers[event] then handlers[event](...) end
end)
for event in pairs(handlers) do
  frame:RegisterEvent(event)
end

local function count(t)
  local n = 0
  for _ in pairs(t) do
    n = n + 1
  end
  return n
end

function ns.scanCommand(arg)
  local s = db()
  if arg == "on" then
    s.on = true
    local _, token = UnitRace("player")
    s.races = s.races or {}
    s.races[token or "?"] = (UnitRace("player"))
    s.client = ns.client
    area()
  elseif arg == "off" then
    s.on = false
  elseif arg == "clear" then
    LorekeepersCodexScan = { on = s.on }
    s = db()
  end
  print(
    PREFIX
      .. ("scan %s: %d areas, %d creatures, %d quests, %d NPC texts, %d books. /codex scan on|off|clear; saved on logout."):format(
        s.on and "on" or "off",
        count(s.areas),
        count(s.npcs),
        count(s.quests),
        count(s.gossip),
        count(s.books)
      )
  )
end
