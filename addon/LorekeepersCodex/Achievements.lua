-- Achievements: milestones (pages found), feats (pages read, sets of pages
-- worth seeking out), encounters (players met: every race, every class, their
-- pairings) and one per chapter, completed. Each character earns its
-- own, from its own codex, and each remembers when and at what level:
--   LorekeepersCodexChar.achievements[id] = { at, level, retro }
-- Earned at once when the codex reaches them; those reached before the addon
-- knew about them (a codex from 0.3.0, a reset) are recorded quietly.
local _, ns = ...
local L = ns.kit.L
local C = ns.content
local PREFIX = ns.PREFIX

-- How many of these pages this character has found.
local function found(ids)
  local n = 0
  for _, id in ipairs(ids) do
    if ns.page(id) then n = n + 1 end
  end
  return n
end

local function readCount()
  local n = 0
  for id in pairs(C.entries) do
    if ns.page(id) and ns.isRead(id) then n = n + 1 end
  end
  return n
end

-- ── the achievements ─────────────────────────────────────────────────────────
-- progress() returns what is done and what is needed. No spoilers: the size
-- of the whole codex is never shown (unit: the progress shows as a count of
-- pages or chapters instead), and a chapter's achievement stays out of the
-- list until the chapter has been opened (visible()).
-- (the kit's: K.deeds; earned as the game's own are, the fanfare, the
-- codex's alert behind its switch, Banner.lua)
local deeds = ns.kit.deeds({
  saved = function()
    local c = LorekeepersCodexChar
    if not c then return nil end
    c.achievements = c.achievements or {}
    return c.achievements
  end,
  name = "Lorekeeper's Codex",
  prefix = PREFIX,
  link = function(a) return ("|cffffd100|Hlorekeeper:ach:%s|h[%s]|h|r"):format(a.id, a.title) end,
  sound = function() return ns.option("achievementSound") end,
  show = function(a) ns.showAchievementBanner(a.id) end,
  earnHidden = true,
  -- (Book.lua's, set once the book is made)
  onEarned = function(a)
    if ns.onAchievement then ns.onAchievement(a.id) end
  end,
})
ns.deeds = deeds
ns.achievements = deeds.list
ns.achievementById = deeds.byId
local function add(group, id, title, text, progress, extra)
  local a = deeds:add(group, id, title, text, progress, extra and extra.visible)
  a.unit = extra and extra.unit
end

function ns.achievementVisible(a) return deeds:visible(a) end

-- The pages a feat names, for the tests: all must exist.
ns.featPages = {}
local function pages(ids)
  for _, id in ipairs(ids) do
    table.insert(ns.featPages, id)
  end
  return ids
end

-- Milestones: pages found, up to the whole codex.
for _, m in ipairs({
  { 10, L["Ink on the Fingers"] },
  { 25, L["A Growing Ledger"] },
  { 50, L["Half a Hundred"] },
  { 100, L["A Hundred Pages"] },
  { 150, L["Seasoned Traveller"] },
  { 200, L["Two Hundred Pages"] },
  { 250, L["Loremaster in the Making"] },
  { 300, L["Three Hundred Pages"] },
}) do
  add("milestone", "pages-" .. m[1], m[2], L["Find %d pages."]:format(m[1]), function() return ns.count(), m[1] end)
end
add(
  "milestone",
  "pages-all",
  L["The Complete Codex"],
  L["Find every page of the codex."],
  function() return ns.count(), ns.total end,
  { unit = "pages" }
)

-- Feats.
for _, r in ipairs({
  { 10, L["A Page by the Fire"] },
  { 50, L["Bookworm"] },
  { 150, L["Well Read"] },
  { 300, L["The Historian's Equal"] },
}) do
  add(
    "feat",
    "read-" .. r[1],
    r[2],
    L["Read %d pages of your codex."]:format(r[1]),
    function() return readCount(), r[1] end
  )
end

local WANDERERS = pages({ "timber", "ghost-howl", "morladim", "thule-ravenclaw" })
add(
  "feat",
  "wanderer-one",
  L["A Tale Worth Telling"],
  L["Find the page of a legendary wanderer: Timber, Ghost Howl, Mor'Ladim or Thule Ravenclaw."],
  function() return math.min(found(WANDERERS), 1), 1 end
)
add(
  "feat",
  "wanderer-all",
  L["Legends of the Wild"],
  L["Find the pages of all four legendary wanderers."],
  function() return found(WANDERERS), #WANDERERS end
)

-- The leaders of the reader's own side: either set counts.
local ALLIANCE =
  pages({ "magni-bronzebeard", "high-tinker-mekkatorque", "regency-of-stormwind", "tyrande-whisperwind" })
local HORDE = pages({ "thrall", "cairne-bloodhoof", "sylvanas-windrunner", "voljin" })
add(
  "feat",
  "leaders",
  L["Friends in High Places"],
  L["Find the pages of the four leaders of the Alliance, or of the Horde, by meeting them."],
  function() return math.max(found(ALLIANCE), found(HORDE)), 4 end
)

-- The codex's historians: Archesonus, who wrote it, and Parqual Fintallas, who
-- sends it on to the Horde. Either one met counts.
local HISTORIANS = pages({ "archesonus", "parqual-fintallas" })
add(
  "feat",
  "historian",
  L["A Word in Person"],
  L["Meet the historian behind your codex: Archesonus in Ironforge's High Seat, or Parqual Fintallas in the Undercity."],
  function() return math.min(found(HISTORIANS), 1), 1 end
)

local DUNGEONS = pages({
  "ragefire-chasm",
  "the-deadmines",
  "wailing-caverns",
  "shadowfang-keep",
  "the-stockade",
  "blackfathom-deeps",
  "gnomeregan",
  "razorfen-kraul",
  "scarlet-monastery",
  "razorfen-downs",
  "uldaman",
  "zulfarrak",
  "maraudon",
  "the-temple-of-atalhakkar",
  "blackrock-depths",
  "blackrock-spire",
  "dire-maul",
  "scholomance",
  "stratholme",
})
add(
  "feat",
  "dungeons-5",
  L["Into the Deep"],
  L["Find the pages of five dungeons."],
  function() return math.min(found(DUNGEONS), 5), 5 end
)
add(
  "feat",
  "dungeons-all",
  L["Delver of the Deep"],
  L["Find the pages of every dungeon."],
  function() return found(DUNGEONS), #DUNGEONS end
)

local LEGENDS = pages({ "onyxia", "ragnaros", "nefarian", "hakkar", "cthun", "kelthuzad" })
add(
  "feat",
  "legends-one",
  L["Where Legends Fall"],
  L["Find the page of one of the great powers that wait at the end of the deepest lairs."],
  function() return math.min(found(LEGENDS), 1), 1 end
)
add(
  "feat",
  "legends-all",
  L["Slayer of Legends"],
  L["Find the pages of Onyxia, Ragnaros, Nefarian, Hakkar, C'Thun and Kel'Thuzad."],
  function() return found(LEGENDS), #LEGENDS end
)

local TERRORS = pages({ "lord-kazzak", "azuregos", "dragons-of-nightmare" })
add(
  "feat",
  "terrors",
  L["Terrors of the Wild"],
  L["Find the pages of Lord Kazzak, Azuregos and the Dragons of Nightmare."],
  function() return found(TERRORS), #TERRORS end
)

add("feat", "travelled", L["Well Travelled"], L["Find a page in every chapter of the codex."], function()
  local n = 0
  for _, ch in ipairs(C.chapters) do
    if ns.found(ch) > 0 then n = n + 1 end
  end
  return n, #C.chapters
end, { unit = "chapters" })

-- Encounters: players met (targeted, Core.lua's met), every race and every
-- class this game has, and the pairings of the two it allows.
local PEOPLES = { "Human", "Dwarf", "NightElf", "Gnome", "Orc", "Troll", "Tauren", "Scourge" }
local PAIRINGS = {
  Human = { "WARRIOR", "PALADIN", "ROGUE", "PRIEST", "MAGE", "WARLOCK" },
  Dwarf = { "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST" },
  NightElf = { "WARRIOR", "HUNTER", "ROGUE", "PRIEST", "DRUID" },
  Gnome = { "WARRIOR", "ROGUE", "MAGE", "WARLOCK" },
  Orc = { "WARRIOR", "HUNTER", "ROGUE", "SHAMAN", "WARLOCK" },
  Troll = { "WARRIOR", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE" },
  Tauren = { "WARRIOR", "HUNTER", "SHAMAN", "DRUID" },
  Scourge = { "WARRIOR", "ROGUE", "PRIEST", "MAGE", "WARLOCK" },
}
-- (Forever: the Skyborne, and the old races' new classes, as its client lists them)
if ns.forever then
  table.insert(PEOPLES, "Skyborne")
  PAIRINGS.Skyborne = { "WARRIOR", "HUNTER", "ROGUE", "SHAMAN", "MAGE", "DRUID" }
  for people, calling in pairs({
    Human = "HUNTER",
    Dwarf = "SHAMAN",
    Gnome = "PRIEST",
    Orc = "MAGE",
    Troll = "WARLOCK",
    Scourge = "PALADIN",
  }) do
    table.insert(PAIRINGS[people], calling)
  end
end
local CALLINGS = { "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }
local function met(kind, tokens)
  local seen, n = (LorekeepersCodexChar and LorekeepersCodexChar.met or {})[kind] or {}, 0
  for _, k in ipairs(tokens) do
    if seen[k] then n = n + 1 end
  end
  return n
end
local PAIRS = {}
for people, callings in pairs(PAIRINGS) do
  for _, calling in ipairs(callings) do
    table.insert(PAIRS, people .. ":" .. calling)
  end
end
ns.pairings = PAIRS -- (for the tests)
add(
  "encounter",
  "met-peoples",
  L["Faces of Azeroth"],
  L["Meet a player of every race."],
  function() return met("races", PEOPLES), #PEOPLES end
)
add(
  "encounter",
  "met-callings",
  L["Every Calling"],
  L["Meet a player of every class."],
  function() return met("classes", CALLINGS), #CALLINGS end
)
for _, m in ipairs({ { 10, L["A Mixed Company"] }, { 25, L["A Crowded Road"] } }) do
  add(
    "encounter",
    "met-pairs-" .. m[1],
    m[2],
    L["Meet players of %d different pairings of race and class."]:format(m[1]),
    function() return met("combos", PAIRS), m[1] end
  )
end
add(
  "encounter",
  "met-pairs-all",
  L["All Walks of Life"],
  L["Meet a player of every pairing of race and class there is."],
  function() return met("combos", PAIRS), #PAIRS end
)

-- The Library: texts read in the world, copied into the codex.
for _, t in ipairs({
  { 5, L["A Shelf Begun"] },
  { 25, L["Collector of Words"] },
  { 50, L["The Librarian's Apprentice"] },
  { 100, L["A Library of One's Own"] },
}) do
  add(
    "library",
    "library-" .. t[1],
    t[2],
    L["Copy %d texts into the Library: books, notes, letters or plaques read in the world."]:format(t[1]),
    function() return ns.libraryCount and ns.libraryCount() or 0, t[1] end
  )
end

-- One per chapter.
for _, ch in ipairs(C.chapters) do
  add(
    "chapter",
    "chapter-" .. ch.id,
    ch.title,
    L["Find every page of this chapter."],
    function() return ns.found(ch), #ch.entries end,
    { visible = function() return ns.found(ch) > 0 end }
  )
end

-- ── earning ──────────────────────────────────────────────────────────────────
function ns.earned(id) return deeds:earned(id) end

-- Earned, and listed (what the reader may know of).
function ns.achievementCount() return deeds:count() end

-- quiet: record without a word (reached before the addon looked).
function ns.checkAchievements(quiet) deeds:check(quiet) end
