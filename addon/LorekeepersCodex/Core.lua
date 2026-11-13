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
--     tunes[id] = { at, level, zoneId, subId }        the soundtrack's finds (Soundtrack.lua)
--     collapsed[chapterId], libraryFolded[shelf],
--     soundtrackFolded[group]                         the book's folds
--     hardcore = true                                 told Hardcore once, kept
--   LorekeepersCodexAccount (SavedVariables), the codex every normal character
--   shares (a Hardcore one never reads or writes it, docs/account-library.md):
--     entries[id], tunes[id], read[id]                as the character's own
--     achievements[id] = { at, level, retro }         the first record on the account
--     library = { texts, keys, nextId }               the texts copied, all characters'
--   A character's own tables stay what it earned itself; it reads its own and
--   the account's together (ns.page, ns.tune, ns.isRead); ns.library() is the
--   account's Library alone (a Hardcore character's: its own).
local _, ns = ...
local K = ns.kit
local L = K.L

-- The kit's (Kit.lua), in the Codex's theme: the family's gold, the panels a
-- touch cool, like ink in an archive.
K.theme({
  tint = { 0.88, 0.92, 1.00 },
  shade = { 0.02, 0.025, 0.035, 0.55 },
  aside = { 0.68, 0.78, 0.62 }, -- (Parqual's ink, the Horde's copy)
})

local PREFIX = K.prefix("Lorekeeper's Codex")
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

-- ── the account's codex ──────────────────────────────────────────────────────
-- Every normal character reads and writes it; a Hardcore character's finds
-- neither feed nor read it. The game says whether a character is Hardcore
-- (Classic Era's Hardcore realms and season, Forever's Hardcore ruleset):
-- C_GameRules.IsHardcoreActive on both, and on Classic Era the season too
-- (the client's own Hardcore test). Not told (no call, an error, a secret
-- value): not Hardcore. Once told, kept on the character, so a call that
-- fails later never moves it into the shared codex.
function ns.detectHardcore()
  local rules = C_GameRules
  if rules and rules.IsHardcoreActive then
    local ok, on = pcall(rules.IsHardcoreActive)
    if ok and not ns.secret(on) and on == true then return true end
  end
  local seasons = C_Seasons
  local hardcore = Enum and Enum.SeasonID and Enum.SeasonID.Hardcore
  if seasons and seasons.GetActiveSeason and hardcore then
    local ok, season = pcall(seasons.GetActiveSeason)
    if ok and not ns.secret(season) and season == hardcore then return true end
  end
  return false
end

function ns.account()
  if type(LorekeepersCodexAccount) ~= "table" then LorekeepersCodexAccount = {} end
  local a = LorekeepersCodexAccount
  a.entries, a.tunes, a.read = a.entries or {}, a.tunes or {}, a.read or {}
  a.achievements = a.achievements or {}
  a.library = a.library or {}
  a.library.texts, a.library.keys, a.library.nextId = a.library.texts or {}, a.library.keys or {}, a.library.nextId or 1
  return a
end

-- The account's codex for this character, nil for a Hardcore one (and before
-- the login).
function ns.shared()
  if not char or char.hardcore then return nil end
  return ns.account()
end

-- A flat record (a find) copied: the account never shares a table with a character.
local function copied(rec)
  local out = {}
  for k, v in pairs(rec) do
    out[k] = v
  end
  return out
end
ns.copied = copied

-- Does a find beat another: one found for real beats one looked back on, then
-- the earlier.
local function better(a, b)
  if (a.retro and true or false) ~= (b.retro and true or false) then return not a.retro end
  return (a.at or math.huge) < (b.at or math.huge)
end
ns.better = better

-- What a normal character holds goes into the account where the account lacks
-- it (the better record wins). Nothing in the character is touched or dropped,
-- and nothing in the account: run at every login, it is the same each time.
function ns.mergeAccount()
  local a = ns.shared()
  if not a then return end
  for _, name in ipairs({ "entries", "tunes", "achievements" }) do
    for id, rec in pairs(char[name] or {}) do
      local held = a[name][id]
      if type(rec) == "table" and (not held or better(rec, held)) then a[name][id] = copied(rec) end
    end
  end
  for id in pairs(char.read or {}) do
    a.read[id] = true
  end
  if ns.mergeLibrary then ns.mergeLibrary(a.library, char.library) end
end

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

local function newCodex(guid, hardcore)
  char = {
    guid = guid,
    hardcore = hardcore or nil,
    entries = {},
    read = {},
    achievements = {},
    tunes = {},
    met = { races = {}, classes = {}, combos = {} },
  }
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
    char.tunes = char.tunes or {}
    char.met = char.met or { races = {}, classes = {}, combos = {} }
  else
    newCodex(guid)
  end
  -- (told Hardcore before anything is merged: such a character stays apart)
  if not char.hardcore and ns.detectHardcore() then char.hardcore = true end
  ns.loadProfile(before)
  -- (the options first: they tell the kit the look before any window is built)
  ns.createSettingsPanel()
  ns.collect:start()
  ns.startUnlocks()
  ns.createMinimapButton()
  -- The package made for the other game: it works, but says so.
  local made = ns.content.client
  if made and made ~= ns.client then
    local this = ns.forever and "Forever" or "Classic"
    print(
      PREFIX
        .. ns.fmt(
          L["This is the %1$s package, and this is %2$s: install the %3$s package to read this game's pages."],
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
  L["/codex opens the codex, /codex achievements its achievements and /codex settings its settings. /codex banner shows or hides the alerts, /codex minimap the button. /codex welcome shows the welcome page again. /codex export gives this character's settings as a code, and /codex import CODE takes them. /codex reset starts this character's codex over."]

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
        PREFIX
          .. (
            char
              and char.hardcore
              and L["This forgets every page and achievement this character has found. Type /codex reset yes to do it."]
            or L["This forgets what this character found itself. The shared codex keeps every page and achievement, so they stay. Type /codex reset yes to do it."]
          )
      )
    end,
    ["reset yes"] = function()
      newCodex(char.guid, char.hardcore)
      ns.catchUp()
      ns.refresh()
      print(PREFIX .. L["The codex starts afresh: %d of %d pages."]:format(ns.count(), ns.knownTotal()))
    end,
    -- (English only, like where: a support line for finding out why another
    -- character's pages are missing. A character's own pages reach the
    -- account only when it logs in on this version. Pages counted as the book
    -- counts them, those this package has.)
    account = function()
      local own, held, deeds, ownDeeds = 0, 0, 0, 0
      for _ in pairs(ns.account().achievements) do
        deeds = deeds + 1
      end
      for _ in pairs(char and char.achievements or {}) do
        ownDeeds = ownDeeds + 1
      end
      for id in pairs(char and char.entries or {}) do
        if ns.available(id) then own = own + 1 end
      end
      for id in pairs(ns.account().entries) do
        if ns.available(id) then held = held + 1 end
      end
      local apart = char and char.hardcore
      print(
        PREFIX
          .. ("account: %s · this character found %d page(s), the account holds %d, %s · achievements: %d here, %d on the account · %s"):format(
            apart and "Hardcore, apart from the account" or "shared with the account",
            own,
            held,
            apart and "none read here" or ns.othersCount() .. " of them from others",
            ownDeeds,
            deeds,
            ns.forever and "Forever" or "Classic"
          )
      )
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
