-- The Library: every book, note, letter and plaque this character reads in the
-- world is copied into its codex, whole, to be read again; each character its
-- own (an orc's library is not a dwarf's):
--   LorekeepersCodexChar.library = { texts[id] = { title, material, pages, count,
--                                    at, level, zone, sub }, keys[key] = id, nextId }
-- On opening a text, the addon turns through every page at once and back to
-- the first, so a quest letter read once and handed in is copied whole.
-- Letters written by players are never copied. No spoilers: the Library never
-- says how much there is to find. Its tab is LibraryBook.lua.
local _, ns = ...
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
  { "books", "Books", "Interface\\Icons\\INV_Misc_Book_11" },
  { "notes", "Notes and Letters", "Interface\\Icons\\INV_Misc_Note_01" },
  { "plaques", "Plaques and Monuments", "Interface\\Icons\\INV_Misc_Map_01" },
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

local function here() return GetRealZoneText and GetRealZoneText() or nil, GetSubZoneText and GetSubZoneText() or nil end

-- Copies what has been read so far into the Library (a text is known by its
-- title and the start of its first page).
local function copy()
  if not (reading and reading.pages[1]) or reading.skip then return end
  local s = store()
  local key = reading.title .. "|" .. reading.pages[1]:sub(1, 80)
  local id = s.keys[key]
  if not id then
    id = s.nextId
    s.nextId = id + 1
    s.keys[key] = id
    s.texts[id] = { title = reading.title, material = reading.material, pages = {} }
  end
  local text = s.texts[id]
  local new = not text.at
  for p, page in pairs(reading.pages) do
    text.pages[p] = page
  end
  if reading.last then text.count = reading.last end
  if new then
    local zone, sub = here()
    text.at, text.level, text.zone, text.sub = time(), UnitLevel("player"), zone, sub ~= zone and sub or nil
    if ns.option("chat") then
      print(PREFIX .. ("copied into the Library: |cffffd100|Hlorekeeper:lib:%d|h[%s]|h|r"):format(id, text.title))
    end
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
  elseif event == "ITEM_TEXT_READY" and reading then
    -- (a player's letter, or one whose writer the game keeps secret: never copied)
    local creator = ItemTextGetCreator and ItemTextGetCreator()
    if secret(creator) or (creator and creator ~= "") then
      reading.skip = true
      return
    end
    local page, text = ItemTextGetPage(), ItemTextGetText()
    if secret(page) or secret(text) or not text then return end
    reading.pages[page] = text
    local more = ItemTextHasNextPage()
    if secret(more) then more = false end
    if not more then reading.last = page end
    if reading.walking == "back" then
      -- turning back to the first page for the reader: nothing to copy
      if page > 1 then
        ItemTextPrevPage()
      else
        reading.walking = nil
        showReader()
      end
      return
    end
    copy()
    -- On opening a text, turn through every page at once, then back.
    if page == 1 and more and not reading.walking and ItemTextNextPage then
      reading.walking = "forward"
      hideReader()
      ItemTextNextPage()
    elseif reading.walking == "forward" then
      if more then
        ItemTextNextPage()
      else
        reading.walking = "back"
        if page > 1 then
          ItemTextPrevPage()
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
