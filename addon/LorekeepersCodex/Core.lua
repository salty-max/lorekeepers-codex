-- Lorekeeper's Codex: this character's codex, the events every file listens
-- to (ns.on) and /codex. The pages unlock in Unlocks.lua, the Library copies
-- texts read in the world (Library.lua), achievements follow (Achievements.lua)
-- and the book shows them (Book.lua and its tabs, *Book.lua).
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
local L = ns.kit.L
local PREFIX = "|cffc9a227Lorekeeper's Codex:|r "
ns.PREFIX = PREFIX
-- Every word shown goes through L (the kit's, English by default; the
-- client's language file, Text_<locale>.lua, fills it).
ns.L = ns.kit.L

-- Which game (ns.forever: World of Warcraft: Forever, the original world on
-- the modern client) the kit says. Some pages and paragraphs are for one
-- client only (see Unlocks.lua's available() and the book).
ns.client = ns.forever and "forever" or "classic"

-- The reader's side: Archesonus of Ironforge writes the codex; a Horde
-- reader's copy comes through Parqual Fintallas of the Undercity, with his
-- word in it (paragraphs for one side only). Any other side reads hers.
function ns.side() return UnitFactionGroup("player") == "Horde" and "Horde" or "Alliance" end

-- Does a page's paragraph show to this reader: its client's, its side's?
function ns.shown(para)
  return (not para.client or para.client == ns.client) and (not para.side or para.side == ns.side())
end

-- Forever hides some values from addons ("secret values", in combat or
-- instances): never compare or print one.
ns.secret = ns.kit.secret

local char
function ns.codex() return char end

-- ── events ───────────────────────────────────────────────────────────────────
-- Every file listens through ns.on (the kit's events: each listener on its
-- own, so one's error never silences the others, the login too; an event a
-- client doesn't know never heard), ns.knows whether the client has one.
-- Nothing is heard before the login.
local events = ns.kit.events({ login = function() ns.login() end, ready = function() return char ~= nil end })
ns.on, ns.knows = events.on, events.knows

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
  local before = ns.belongsTo(LorekeepersCodexChar, guid, UnitLevel("player"), UnitXP("player"))
  if before then
    char = LorekeepersCodexChar
    char.guid = guid
    char.entries = char.entries or {}
    char.read = char.read or {}
    char.achievements = char.achievements or {}
    char.met = char.met or { races = {}, classes = {}, combos = {} }
  else
    newCodex(guid)
  end
  ns.loadProfile(before)
  ns.collect:start()
  ns.startUnlocks()
  ns.createMinimapButton()
  ns.createSettingsPanel()
  -- The package made for the other game: it works, but says so.
  local made = ns.content.client
  if made and made ~= ns.client then
    local this = ns.forever and "Forever" or "Classic"
    print(
      PREFIX
        .. L["This is the %s package, and this is %s: install the %s package to read this game's pages."]:format(
          made == "forever" and "Forever" or "Classic",
          this,
          this
        )
    )
  end
  -- The only reminder of how to open the book: once, at login.
  print(
    PREFIX
      .. L["%d of %d pages. Type /codex or click the book by the minimap to read them."]:format(
        ns.count(),
        ns.knownTotal()
      )
  )
end

-- ── /codex ───────────────────────────────────────────────────────────────────

local function where()
  -- For writing content: where am I, in the terms the content files use
  -- (none of what Forever keeps secret in an instance compared or printed).
  local secret = ns.secret
  local map = C_Map.GetBestMapForUnit("player")
  if secret(map) then map = nil end
  local pos = map and C_Map.GetPlayerMapPosition(map, "player")
  if pos and (secret(pos.x) or secret(pos.y)) then pos = nil end
  local zone, sub = GetRealZoneText(), GetSubZoneText()
  if secret(zone) then zone = nil end
  if secret(sub) then sub = nil end
  print(
    PREFIX
      .. ("%s / %s · uiMap %s · %s"):format(
        zone or "?",
        sub and sub ~= "" and sub or "-",
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

local USAGE =
  L["/codex opens the book, /codex achievements its achievements and /codex settings its settings. /codex banner shows or hides the alerts, /codex minimap the button. /codex welcome shows the welcome page again. /codex export gives this character's settings as a code, and /codex import CODE takes them. /codex reset starts this character's codex over."]

-- The kit's command (K.commands): alone it opens the book, an unknown word
-- prints the usage.
ns.kit.commands({
  names = { "/codex", "/lorekeeper" },
  key = "LOREKEEPERSCODEX",
  name = "Lorekeeper's Codex",
  prefix = PREFIX,
  profiles = function() return ns.profiles end,
  open = function() ns.toggle() end,
  usage = USAGE,
  settings = function() return ns.openSettings() end,
  welcome = function(mode) ns.showWelcome(mode) end,
  minimap = { get = function(k) return ns.option(k) end, set = function(k, v) ns.setOption(k, v) end },
  commands = {
    where = where,
    reset = function()
      print(
        PREFIX .. L["This forgets every page and achievement this character has found. Type /codex reset yes to do it."]
      )
    end,
    ["reset yes"] = function()
      newCodex(char.guid)
      ns.catchUp()
      ns.refresh()
      print(PREFIX .. L["The codex starts afresh: %d of %d pages."]:format(ns.count(), ns.knownTotal()))
    end,
    banner = function()
      ns.setOption("banner", not ns.option("banner"))
      print(
        PREFIX
          .. (
            ns.option("banner") and L["Alerts shown for new pages."]
            or L["Alerts hidden (/codex banner shows them again)."]
          )
      )
    end,
    achievements = function() ns.openAchievements() end,
    ach = function() ns.openAchievements() end,
  },
  -- (/codex scan, on, off or clear: what the game shows, for writing content)
  match = function(msg)
    local scan = msg:match("^scan%s*(%a*)$")
    if not scan then return false end
    ns.scanCommand(scan)
    return true
  end,
})
