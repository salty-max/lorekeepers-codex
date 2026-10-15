-- The Library: every book, note, letter and plaque this character reads in the
-- world is copied into its codex, whole, to be read again; each character its
-- own (an orc's library is not a dwarf's):
--   LorekeepersCodexChar.library = { texts[id] = { title, material, pages, count,
--                                    at, level, zone, sub }, keys[key] = id, nextId }
-- On opening a text, the addon turns through every page and back to the
-- first, so a quest letter read once and handed in is copied whole: a page
-- a frame, never from inside the reader's own event (the game may answer a
-- turn at once, for a text it knows already, and turning from there nested
-- every page in the last: deep enough on a long book to crash the game).
-- Letters written by players are never copied. No spoilers: the Library never
-- says how much there is to find. Its tab is LibraryBook.lua.
local _, ns = ...
local L = ns.kit.L
local PREFIX = "|cffc9a227Lorekeeper's Codex:|r "
local secret = ns.secret

local function store()
  local c = LorekeepersCodexChar
  if not c then return { texts = {}, keys = {}, nextId = 1 } end
  c.library = c.library or {}
  local s = c.library
  s.texts, s.keys, s.nextId = s.texts or {}, s.keys or {}, s.nextId or 1
  return s
end
ns.library = store

function ns.libraryCount()
  local n = 0
  for _ in pairs(store().texts) do
    n = n + 1
  end
  return n
end

-- ── shelves ──────────────────────────────────────────────────────────────────
-- Plaques are cut in stone or metal; a text of several pages is a book; the
-- rest are notes and letters.
local CARVED = { Stone = true, Marble = true, Bronze = true, Silver = true }
local SHELVES = {
  { "books", L["Books"], "Interface\\Icons\\INV_Misc_Book_11" },
  { "notes", L["Notes and Letters"], "Interface\\Icons\\INV_Misc_Note_01" },
  { "plaques", L["Plaques and Monuments"], "Interface\\Icons\\INV_Misc_Map_01" },
}
ns.SHELVES = SHELVES
local function shelfOf(text)
  if CARVED[text.material or ""] then return "plaques" end
  local n = text.count or 0
  for p in pairs(text.pages) do
    n = math.max(n, p)
  end
  return n > 1 and "books" or "notes"
end
ns.libraryShelf = shelfOf

-- Some texts are written in the game's HTML (headings, paragraphs): plain
-- paragraphs for the codex.
local function plain(text)
  if not text:find("<[Hh][Tt][Mm][Ll]>") then return text end
  text = text:gsub("<[Bb][Rr]%s*/?>", "\n")
  text = text:gsub("</[Pp]>", "\n\n"):gsub("</[Hh]%d>", "\n\n")
  text = text:gsub("<[^>]+>", "")
  text = text:gsub("\n\n\n+", "\n\n")
  return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end
ns.libraryPlain = plain

-- ── copying ──────────────────────────────────────────────────────────────────
local reading -- the text open in the game's reader: { title, material, pages, last, walking }
local LONGEST = 100 -- pages walked at most (a text whose pages never end)

-- A page turned at the next frame, if the text is still open.
local function turn(r, fn)
  C_Timer.After(0, function()
    if reading == r then fn() end
  end)
end

local function here() return GetRealZoneText and GetRealZoneText() or nil, GetSubZoneText and GetSubZoneText() or nil end

-- A copy's title in the client's language, by its text's id (its identity:
-- the language's list, ns.textTitlesById); a copy not identified, by the one
-- text its title names, or the title all the texts it names share in this
-- language; else as copied (a bare title cannot tell apart books named alike).
function ns.textTitle(title, copy)
  local byId = ns.textTitlesById or {}
  local identity = copy and ns.textIdentity(copy)
  if identity then return byId[identity] or title end
  local named
  for id in pairs(ns.textSources and ns.textSources.titles[title] or {}) do
    local own = byId[id]
    if not own or (named and named ~= own) then return title end
    named = own
  end
  return named or title
end

local function letters(s) return (s:lower():gsub("[^a-z]", "")) end
-- (a first page's fingerprint: djb2 over its letters, and their count, as
-- scripts/locales.ts writes Text_Sources.lua's sums)
local function sum(s)
  local h = 5381
  for i = 1, #s do
    h = (h * 33 + s:byte(i)) % 4294967296
  end
  return ("%08x:%d"):format(h, #s)
end

-- Match a saved first page against source templates in every shipped language.
-- The templates wildcard $N/$C/$R, including names filled in by a previous
-- client. Multiple matches remain ambiguous, so the original copy is kept.
local function identify(t)
  local source = ns.textSources
  if not source then return nil end
  local variants = source.titles[t.title]
  if not variants then return t.readable and source.texts[t.readable] and t.readable or nil end
  local only, count = nil, 0
  for id in pairs(variants) do
    only, count = id, count + 1
  end
  local first = t.pages[1] and letters(plain(t.pages[1])) or ""
  local fingerprint = sum(first)
  local found
  for id in pairs(variants) do
    local text, hit = source.texts[id], false
    for _, s in ipairs(text.sums) do
      if s == fingerprint then hit = true end
    end
    for _, pattern in ipairs(text.patterns) do
      if not hit and first:match("^" .. pattern .. "$") then hit = true end
    end
    if hit then
      if found and found ~= id then return nil end
      found = id
    end
  end
  if found then return found, true end
  if t.readable and source.texts[t.readable] then return t.readable end
  if count == 1 then return only end
end

-- (each copy's identity worked out once: the Library's sorts and searches ask
-- for it over and over, and matching a whole first page is not cheap; worked
-- out again only when the copy's title, first page or readable id change)
local identities = setmetatable({}, { __mode = "k" })
function ns.textIdentity(t)
  local c = identities[t]
  if c and c.title == t.title and c.first == t.pages[1] and c.readable == t.readable then return c.id, c.matched end
  local id, matched = identify(t)
  identities[t] = { title = t.title, first = t.pages[1], readable = t.readable, id = id, matched = matched }
  return id, matched
end

-- Known copies follow the client's language without rewriting saved pages.
-- Missing bodies and ambiguous matches remain exactly as copied.
function ns.textPages(t)
  local id, matched = ns.textIdentity(t)
  if id then
    local pages = ns.booksById and ns.booksById[id]
    if not pages and (not ns.locale or ns.locale == "enUS" or ns.locale == "enGB") then
      local source = ns.textSources.texts[id]
      -- A legacy English copy outside the cached templates stays as copied.
      -- This also preserves custom/test text that happens to share a title.
      if matched or t.title ~= source.title or (t.language and t.language ~= "enUS" and t.language ~= "enGB") then
        pages = ns.textBodies and ns.textBodies[id]
      end
    end
    if pages then return pages, true end
  end
  local variants = ns.bookTexts and ns.bookTexts[t.title]
  if not variants then return t.pages end
  if #variants == 1 then return variants[1].pages, true end
  local first = t.pages[1] and letters(plain(t.pages[1])) or ""
  for _, v in ipairs(variants) do
    if v.first ~= "" and first:sub(1, #v.first) == v.first then return v.pages, true end
  end
  return t.pages
end

-- The reader's own name, class and race in a text the game writes to them
-- ($N, $C, $R: the game fills them in as it shows the text).
function ns.textForReader(s)
  local name = UnitName and UnitName("player") or ""
  local class = UnitClass and UnitClass("player") or ""
  local race = UnitRace and UnitRace("player") or ""
  local female = UnitSex and UnitSex("player") == 3
  s = s:gsub("%$g([^:;]*):([^;]*);", function(m, f) return female and f or m end)
  return (
    s:gsub("%$([NnCcRr])", function(k)
      k = k:upper()
      return k == "N" and name or k == "C" and class or race
    end)
  )
end

-- Re-reading another language replaces only the same readable identity,
-- never an unrelated variant with the same localized title.
local function copyInAnother(s, readable)
  if not readable then return nil end
  local found
  for id, t in pairs(s.texts) do
    if ns.textIdentity(t) == readable then
      if found then return nil end
      found = id
    end
  end
  return found
end

-- Copies what has been read so far into the Library (a text is known by its
-- title and the start of its first page). A text copied in another language
-- and read again in this one replaces its copy: the same text, in the
-- client's words, never twice.
local function copy()
  if not (reading and reading.pages[1]) or reading.skip then return end
  local s = store()
  local readable = ns.textIdentity(reading)
  local key = readable and ("readable:" .. readable) or (reading.title .. "|" .. reading.pages[1]:sub(1, 80))
  local id = s.keys[key]
  if not id then
    id = copyInAnother(s, readable)
    if id then s.keys[key] = id end
  end
  if not id then
    id = s.nextId
    s.nextId = id + 1
    s.keys[key] = id
    s.texts[id] = { title = reading.title, material = reading.material, pages = {} }
  end
  local text = s.texts[id]
  if text.title ~= reading.title or (readable and text.pages[1] ~= reading.pages[1]) then
    text.title, text.pages, text.count = reading.title, {}, nil
  end
  text.readable = readable
  text.language = ns.locale or GetLocale()
  local new = not text.at
  for p, page in pairs(reading.pages) do
    text.pages[p] = page
  end
  if reading.last then text.count = reading.last end
  if new then
    text.at, text.level = time(), UnitLevel("player")
    for k, v in pairs(ns.placeOf(here())) do
      text[k] = v
    end
    local link = ("|cffffd100|Hlorekeeper:lib:%d|h[%s]|h|r"):format(id, text.title)
    print(PREFIX .. L["copied into the Library: %s"]:format(link))
    if ns.checkAchievements then ns.checkAchievements() end
  end
  if ns.onLibrary then ns.onLibrary(id) end
end

-- The game's reader is hidden while the addon turns its pages, so they don't
-- flash past; it shows again on the first page, or after two seconds whatever
-- happens.
local function hideReader()
  if ItemTextFrame and ItemTextFrame.SetAlpha then ItemTextFrame:SetAlpha(0) end
  if C_Timer and C_Timer.After then
    C_Timer.After(2, function()
      if ItemTextFrame and ItemTextFrame.SetAlpha then ItemTextFrame:SetAlpha(1) end
    end)
  end
end
local function showReader()
  if ItemTextFrame and ItemTextFrame.SetAlpha then ItemTextFrame:SetAlpha(1) end
end

local function onText(event)
  if event == "ITEM_TEXT_BEGIN" then
    local title, material = ItemTextGetItem(), ItemTextGetMaterial()
    if secret(title) then
      reading = nil
      return
    end
    reading = { title = title or "?", material = (not secret(material) and material) or "Parchment", pages = {} }
    if title and ns.readText then ns.readText(title) end
  elseif event == "ITEM_TEXT_READY" and reading then
    -- (a player's letter, or one whose writer the game keeps secret: never copied)
    local creator = ItemTextGetCreator and ItemTextGetCreator()
    if secret(creator) or (creator and creator ~= "") then
      reading.skip = true
      return
    end
    local page, text = ItemTextGetPage(), ItemTextGetText()
    if secret(page) or secret(text) or not text then return end
    -- (a page that only repeats the one before leads to itself: the text's end)
    local again = reading.walking == "forward" and page > 1 and reading.pages[page - 1] == text
    if not again then reading.pages[page] = text end
    local more = ItemTextHasNextPage()
    if secret(more) then more = false end
    more = more and not again and page < LONGEST
    if not more then reading.last = again and page - 1 or page end
    if reading.walking == "back" then
      -- turning back to the first page for the reader: nothing to copy
      if page > 1 then
        turn(reading, ItemTextPrevPage)
      else
        reading.walking = nil
        showReader()
      end
      return
    end
    copy()
    -- On opening a text, turn through every page, then back.
    if page == 1 and more and not reading.walking and ItemTextNextPage then
      reading.walking = "forward"
      hideReader()
      turn(reading, ItemTextNextPage)
    elseif reading.walking == "forward" then
      if more then
        turn(reading, ItemTextNextPage)
      else
        reading.walking = "back"
        if page > 1 then
          turn(reading, ItemTextPrevPage)
        else
          reading.walking = nil
          showReader()
        end
      end
    end
  elseif event == "ITEM_TEXT_CLOSED" then
    reading = nil
    showReader()
  end
end
for _, event in ipairs({ "ITEM_TEXT_BEGIN", "ITEM_TEXT_READY", "ITEM_TEXT_CLOSED" }) do
  ns.on(event, function() onText(event) end)
end
