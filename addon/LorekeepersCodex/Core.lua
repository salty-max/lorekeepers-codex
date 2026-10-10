-- Lorekeeper's Codex: this character's codex, the events every file listens
-- to (ns.on) and /codex. The pages unlock in Unlocks.lua, the Library copies
-- texts read in the world (Library.lua), achievements follow (Achievements.lua)
-- and the book shows them (Codex.lua, Library.lua's tab).
--
--   LorekeepersCodexChar (SavedVariablesPerCharacter), whose codex: guid
--     entries[id] = { at, level, zone, sub, retro }   unlocked pages
--     read[id] = true                                 pages already opened
--     achievements[id] = { at, level, retro }         see Achievements.lua
--     met = { races, classes, combos }                players met (targeted): their
--                                                     race and class tokens, and
--                                                     "Race:CLASS", for the encounters
--     library = { texts, keys, nextId }               the texts copied (Library.lua)
--     collapsed[chapterId], libraryFolded[shelf]      the book's folds
local _, ns = ...
local PREFIX = "|cffc9a227Lorekeeper's Codex:|r "
ns.PREFIX = PREFIX

-- Which game: World of Warcraft: Forever (the original world on the modern
-- client, interface 16xxx) or Classic (Era, TBC Anniversary). Some pages and
-- paragraphs are for one client only (see Unlocks.lua's available() and the book).
local interface = select(4, GetBuildInfo()) or 0
ns.forever = interface >= 16000 and interface < 20000
ns.client = ns.forever and "forever" or "classic"

-- Forever hides some values from addons ("secret values", in combat or
-- instances): never compare or print one.
ns.secret = issecretvalue or function() return false end

local char
function ns.codex() return char end

-- ── events ───────────────────────────────────────────────────────────────────
-- Every file listens through ns.on (an event a client doesn't know is never
-- heard). Nothing is heard before the login.
local frame = CreateFrame("Frame")
local listeners = {}

frame:SetScript("OnEvent", function(_, event, ...)
  if event == "PLAYER_LOGIN" then ns.login() end
  if not char then return end
  for _, fn in ipairs(listeners[event] or {}) do
    fn(...)
  end
end)
frame:RegisterEvent("PLAYER_LOGIN")

function ns.on(event, fn)
  if not listeners[event] then
    listeners[event] = {}
    pcall(frame.RegisterEvent, frame, event)
  end
  table.insert(listeners[event], fn)
end

-- Does this client have the event? (registering an unknown one throws)
local probe = CreateFrame("Frame")
function ns.knows(event)
  local ok = pcall(probe.RegisterEvent, probe, event)
  if ok then probe:UnregisterEvent(event) end
  return ok
end

-- ── the login ────────────────────────────────────────────────────────────────
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

local function newCodex(guid)
  char = { guid = guid, entries = {}, read = {}, achievements = {}, met = { races = {}, classes = {}, combos = {} } }
  LorekeepersCodexChar = char
end

-- This character's codex, or a new one; then what it deserves already, found
-- quietly (Unlocks.lua's catch-up), and the book's buttons.
function ns.login()
  local guid = UnitGUID("player")
  if ns.belongsTo(LorekeepersCodexChar, guid, UnitLevel("player"), UnitXP("player")) then
    char = LorekeepersCodexChar
    char.guid = guid
    char.entries = char.entries or {}
    char.read = char.read or {}
    char.achievements = char.achievements or {}
    char.met = char.met or { races = {}, classes = {}, combos = {} }
  else
    newCodex(guid)
  end
  ns.startUnlocks()
  ns.createMinimapButton()
  ns.createSettingsPanel()
  -- The package made for the other game: it works, but says so.
  local made = ns.content.client
  if made and made ~= ns.client then
    local this = ns.forever and "Forever" or "Classic"
    print(
      PREFIX
        .. ("this is the %s package, and this is %s: install the %s package to read this game's pages."):format(
          made == "forever" and "Forever" or "Classic",
          this,
          this
        )
    )
  end
  -- The only reminder of how to open the book: once, at login.
  print(
    PREFIX
      .. ("%d of %d pages. Type /codex or click the book by the minimap to read them."):format(
        ns.count(),
        ns.knownTotal()
      )
  )
end

-- ── /codex ───────────────────────────────────────────────────────────────────
local USAGE = "/codex opens the book; /codex achievements; /codex settings; /codex banner shows or hides the "
  .. "alerts; /codex minimap shows or hides the button; /codex reset starts this character's codex over."

local function where()
  -- For writing content: where am I, in the terms the content files use.
  local map = C_Map.GetBestMapForUnit("player")
  local pos = map and C_Map.GetPlayerMapPosition(map, "player")
  print(
    PREFIX
      .. ("%s / %s · uiMap %s · %s"):format(
        GetRealZoneText() or "?",
        GetSubZoneText() ~= "" and GetSubZoneText() or "-",
        tostring(map),
        pos and ("position: %d %.1f %.1f"):format(map, pos.x * 100, pos.y * 100) or "no position"
      )
  )
  local target = ns.npcId("target")
  local name = UnitName("target")
  if target then
    print(PREFIX .. ("target: npc: %d (%s)"):format(target, (name and not ns.secret(name)) and name or "?"))
  end
end

SLASH_LOREKEEPERSCODEX1 = "/codex"
SLASH_LOREKEEPERSCODEX2 = "/lorekeeper"
SlashCmdList.LOREKEEPERSCODEX = function(msg)
  msg = strtrim((msg or ""):lower())
  local scan = msg:match("^scan%s*(%a*)$")
  if msg == "" then
    ns.toggle()
  elseif msg == "where" then
    where()
  elseif msg == "reset" then
    print(PREFIX .. "this forgets every page and achievement this character has found. Type /codex reset yes to do it.")
  elseif msg == "reset yes" then
    newCodex(char.guid)
    ns.catchUp()
    ns.refresh()
    print(PREFIX .. ("the codex starts afresh: %d of %d pages."):format(ns.count(), ns.knownTotal()))
  elseif msg == "banner" then
    ns.setOption("banner", not ns.option("banner"))
    print(
      PREFIX
        .. (
          ns.option("banner") and "alerts shown for new pages." or "alerts hidden (/codex banner to show them again)."
        )
    )
  elseif msg == "minimap" then
    ns.setOption("minimapHidden", not ns.option("minimapHidden"))
    print(
      PREFIX
        .. (
          ns.option("minimapHidden") and "minimap button hidden (/codex minimap to show it again)."
          or "minimap button shown."
        )
    )
  elseif scan then
    ns.scanCommand(scan)
  elseif msg == "achievements" or msg == "ach" then
    ns.openAchievements()
  elseif msg == "settings" or msg == "options" then
    if not ns.openSettings() then
      print(PREFIX .. "no settings page in this client: use /codex banner and /codex minimap.")
    end
  else
    print(PREFIX .. USAGE)
  end
end
