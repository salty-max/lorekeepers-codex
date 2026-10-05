-- Achievements: milestones (pages found), feats (pages read, sets of pages
-- worth seeking out) and one per chapter, completed. Each character earns its
-- own, from its own codex, and each remembers when and at what level:
--   LorekeepersCodexChar.achievements[id] = { at, level, retro }
-- Earned at once when the codex reaches them; those reached before the addon
-- knew about them (a codex from 0.3.0, a reset) are recorded quietly.
local _, ns = ...
local C = ns.content
local PREFIX = "|cffc9a227Lorekeeper's Codex:|r "

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
local list = {}
ns.achievements = list
ns.achievementById = {}
local function add(group, id, title, text, progress, extra)
  local a = { group = group, id = id, title = title, text = text, progress = progress }
  for k, v in pairs(extra or {}) do a[k] = v end
  table.insert(list, a)
  ns.achievementById[id] = a
end

function ns.achievementVisible(a)
  return not a.visible or a.visible() or ns.earned(a.id) ~= nil
end

-- The pages a feat names, for the tests: all must exist.
ns.featPages = {}
local function pages(ids)
  for _, id in ipairs(ids) do table.insert(ns.featPages, id) end
  return ids
end

-- Milestones: pages found, up to the whole codex.
for _, m in ipairs({
  { 10, "Ink on the Fingers" }, { 25, "A Growing Ledger" }, { 50, "Half a Hundred" },
  { 100, "A Hundred Pages" }, { 150, "Seasoned Traveller" }, { 200, "Two Hundred Pages" },
  { 250, "Loremaster in the Making" }, { 300, "Three Hundred Pages" },
}) do
  add("milestone", "pages-" .. m[1], m[2], ("Find %d pages."):format(m[1]),
    function() return ns.count(), m[1] end)
end
add("milestone", "pages-all", "The Complete Codex", "Find every page of the codex.",
  function() return ns.count(), ns.total end, { unit = "pages" })

-- Feats.
for _, r in ipairs({
  { 10, "A Page by the Fire" }, { 50, "Bookworm" }, { 150, "Well Read" }, { 300, "The Archivist's Equal" },
}) do
  add("feat", "read-" .. r[1], r[2], ("Read %d pages of your codex."):format(r[1]),
    function() return readCount(), r[1] end)
end

local WANDERERS = pages({ "timber", "ghost-howl", "morladim", "thule-ravenclaw" })
add("feat", "wanderer-one", "A Tale Worth Telling",
  "Find the page of a legendary wanderer: Timber, Ghost Howl, Mor'Ladim or Thule Ravenclaw.",
  function() return math.min(found(WANDERERS), 1), 1 end)
add("feat", "wanderer-all", "Legends of the Wild", "Find the pages of all four legendary wanderers.",
  function() return found(WANDERERS), #WANDERERS end)

-- The leaders of the reader's own side: either set counts.
local ALLIANCE = pages({ "magni-bronzebeard", "high-tinker-mekkatorque", "regency-of-stormwind", "tyrande-whisperwind" })
local HORDE = pages({ "thrall", "cairne-bloodhoof", "sylvanas-windrunner", "voljin" })
add("feat", "leaders", "Friends in High Places",
  "Find the pages of the four leaders of the Alliance, or of the Horde, by meeting them.",
  function() return math.max(found(ALLIANCE), found(HORDE)), 4 end)

local DUNGEONS = pages({
  "ragefire-chasm", "the-deadmines", "wailing-caverns", "shadowfang-keep", "the-stockade",
  "blackfathom-deeps", "gnomeregan", "razorfen-kraul", "scarlet-monastery", "razorfen-downs",
  "uldaman", "zulfarrak", "maraudon", "the-temple-of-atalhakkar", "blackrock-depths",
  "blackrock-spire", "dire-maul", "scholomance", "stratholme",
})
add("feat", "dungeons-5", "Into the Deep", "Find the pages of five dungeons.",
  function() return math.min(found(DUNGEONS), 5), 5 end)
add("feat", "dungeons-all", "Delver of the Deep", "Find the pages of every dungeon.",
  function() return found(DUNGEONS), #DUNGEONS end)

local LEGENDS = pages({ "onyxia", "ragnaros", "nefarian", "hakkar", "cthun", "kelthuzad" })
add("feat", "legends-one", "Where Legends Fall",
  "Find the page of one of the great powers that wait at the end of the deepest lairs.",
  function() return math.min(found(LEGENDS), 1), 1 end)
add("feat", "legends-all", "Slayer of Legends",
  "Find the pages of Onyxia, Ragnaros, Nefarian, Hakkar, C'Thun and Kel'Thuzad.",
  function() return found(LEGENDS), #LEGENDS end)

local TERRORS = pages({ "lord-kazzak", "azuregos", "dragons-of-nightmare" })
add("feat", "terrors", "Terrors of the Wild",
  "Find the pages of Lord Kazzak, Azuregos and the Dragons of Nightmare.",
  function() return found(TERRORS), #TERRORS end)

add("feat", "travelled", "Well Travelled", "Find a page in every chapter of the codex.",
  function()
    local n = 0
    for _, ch in ipairs(C.chapters) do
      if ns.found(ch) > 0 then n = n + 1 end
    end
    return n, #C.chapters
  end, { unit = "chapters" })

-- The Library: texts read in the world, copied into the codex.
for _, t in ipairs({ { 5, "A Shelf Begun" }, { 25, "Collector of Words" }, { 50, "The Librarian's Apprentice" }, { 100, "A Library of One's Own" } }) do
  add("library", "library-" .. t[1], t[2], ("Copy %d texts into the Library: books, notes, letters or plaques read in the world."):format(t[1]),
    function() return ns.libraryCount and ns.libraryCount() or 0, t[1] end)
end

-- One per chapter.
for _, ch in ipairs(C.chapters) do
  add("chapter", "chapter-" .. ch.id, ch.title, "Find every page of this chapter.",
    function() return ns.found(ch), #ch.entries end,
    { visible = function() return ns.found(ch) > 0 end })
end

-- ── earning ──────────────────────────────────────────────────────────────────
local function char() return LorekeepersCodexChar end

function ns.earned(id)
  local c = char()
  return c and c.achievements and c.achievements[id]
end

-- Earned, and listed (what the reader may know of).
function ns.achievementCount()
  local n, shown = 0, 0
  for _, a in ipairs(list) do
    if ns.earned(a.id) then n = n + 1 end
    if ns.achievementVisible(a) then shown = shown + 1 end
  end
  return n, shown
end

-- quiet: record without a word (reached before the addon looked).
function ns.checkAchievements(quiet)
  local c = char()
  if not c then return end
  c.achievements = c.achievements or {}
  for _, a in ipairs(list) do
    if not c.achievements[a.id] then
      local done, need = a.progress()
      if need > 0 and done >= need then
        c.achievements[a.id] = { at = time(), level = UnitLevel("player"), retro = quiet or nil }
        if not quiet then
          if ns.option("chat") then
            print(PREFIX .. ("achievement earned: |cffffd100|Hlorekeeper:ach:%s|h[%s]|h|r"):format(a.id, a.title))
          end
          ns.playSound()
          ns.showAchievementBanner(a.id)
        end
        if ns.onAchievement then ns.onAchievement(a.id) end
      end
    end
  end
end
