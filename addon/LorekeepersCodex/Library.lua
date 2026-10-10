-- The Library: every book, note, letter and plaque this character reads in the
-- world is copied into its codex, whole, to be read again; each character its
-- own (an orc's library is not a dwarf's):
--   LorekeepersCodexChar.library = { texts[id] = { title, material, pages, count,
--                                    at, level, zone, sub }, keys[key] = id, nextId }
-- On opening a text, the addon turns through every page at once and back to
-- the first, so a quest letter read once and handed in is copied whole.
-- Letters written by players are never copied. No spoilers: the Library never
-- says how much there is to find.
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

local frame = CreateFrame("Frame")
frame:RegisterEvent("ITEM_TEXT_BEGIN")
frame:RegisterEvent("ITEM_TEXT_READY")
frame:RegisterEvent("ITEM_TEXT_CLOSED")
frame:SetScript("OnEvent", function(_, event)
  if not LorekeepersCodexChar then return end
  if event == "ITEM_TEXT_BEGIN" then
    local title, material = ItemTextGetItem(), ItemTextGetMaterial()
    if secret(title) then
      reading = nil
      return
    end
    reading = { title = title or "?", material = (not secret(material) and material) or "Parchment", pages = {} }
  elseif event == "ITEM_TEXT_READY" and reading then
    local creator = ItemTextGetCreator and ItemTextGetCreator()
    if creator and creator ~= "" then
      reading.skip = true
      return
    end -- a player's letter
    local page, text = ItemTextGetPage(), ItemTextGetText()
    if secret(page) or secret(text) or not text then return end
    reading.pages[page] = text
    local more = ItemTextHasNextPage()
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
end)

-- ── the tab ──────────────────────────────────────────────────────────────────
local ui, book, list, page
local currentText, currentPage = nil, 1
local rows = {}
ns.libraryRows = rows -- for the tests
local ROW_WIDTH = 204

local function folded()
  local c = LorekeepersCodexChar
  if not c then return {} end
  c.libraryFolded = c.libraryFolded or {}
  return c.libraryFolded
end

local function row(i)
  local r = rows[i]
  if r then return r end
  r = CreateFrame("Button", nil, list.child)
  r:SetSize(ROW_WIDTH, 18)
  r.text = ui.label(r, ui.BODY_FONT, 12, ui.T.text)
  r.text:SetWordWrap(false)
  r.count = ui.label(r, ui.BODY_FONT, 10, ui.T.soft)
  r.count:SetPoint("RIGHT", -4, 0)
  r.count:SetJustifyH("RIGHT")
  r.fold = r:CreateTexture(nil, "ARTWORK")
  r.fold:SetSize(12, 12)
  r.fold:SetPoint("LEFT", 2, 0)
  r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  r.selected = r:CreateTexture(nil, "BACKGROUND")
  r.selected:SetAllPoints()
  r.selected:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
  r.selected:SetBlendMode("ADD")
  r.selected:SetAlpha(0.7)
  rows[i] = r
  return r
end

local function textOf(id) return store().texts[id] end
local function mine() return store().texts end

local function matches(id, query)
  local t = textOf(id)
  if not t then return false end
  if t.title:lower():find(query, 1, true) then return true end
  for _, p in pairs(t.pages) do
    if p:lower():find(query, 1, true) then return true end
  end
  return false
end

local showText, showShelf

local function refreshList()
  for _, r in ipairs(rows) do
    r:Hide()
  end
  local query = (book.search:GetText() or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  local searching = query ~= ""
  local by = {}
  for id in pairs(mine()) do
    local t = textOf(id)
    if t and (not searching or matches(id, query)) then
      local shelf = shelfOf(t)
      by[shelf] = by[shelf] or {}
      table.insert(by[shelf], id)
    end
  end
  local i, y = 0, 0
  local function add(kind, text)
    i = i + 1
    local r = row(i)
    r:ClearAllPoints()
    r:SetPoint("TOPLEFT", 0, -y)
    r.kind, r.id = kind, nil
    r.text:SetText(text)
    r.text:ClearAllPoints()
    r.selected:Hide()
    r.count:SetText("")
    if kind == "shelf" then
      r.fold:Show()
      r.text:SetPoint("LEFT", 18, 0)
      r.text:SetPoint("RIGHT", -30, 0)
      r.text:SetFont(ui.TITLE_FONT, 14, "")
      r.text:SetTextColor(unpack(ui.T.gold))
      r:SetHeight(22)
      y = y + 22
    else
      r.fold:Hide()
      r.text:SetPoint("LEFT", 18, 0)
      r.text:SetPoint("RIGHT", -4, 0)
      r.text:SetFont(ui.BODY_FONT, 12, "")
      r.text:SetTextColor(unpack(ui.T.text))
      r:SetHeight(18)
      y = y + 18
    end
    r:Show()
    return r
  end
  local empty = true
  for _, shelf in ipairs(SHELVES) do
    local ids = by[shelf[1]]
    if ids then
      empty = false
      table.sort(ids, function(a, b) return textOf(a).title < textOf(b).title end)
      y = y + 4
      local r = add("shelf", shelf[2])
      r.count:SetText(#ids)
      local open = searching or not folded()[shelf[1]]
      r.fold:SetTexture(open and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
      r:SetScript("OnClick", function()
        folded()[shelf[1]] = not folded()[shelf[1]] or nil
        refreshList()
      end)
      if open then
        for _, id in ipairs(ids) do
          local e = add("text", textOf(id).title)
          e.id = id
          e:SetScript("OnClick", function()
            showText(id)
            refreshList()
          end)
          if id == currentText then
            e.selected:Show()
            e.text:SetTextColor(1, 1, 1)
          end
        end
      end
    end
  end
  if empty then add("text", searching and "No text found." or "Nothing read yet."):SetScript("OnClick", nil) end
  list.child:SetHeight(y + 8)
  list:UpdateThumb()
end

local function day(at) return date("%d %b %Y", at or 0) end

-- A text, one page at a time.
function showText(id, pageNumber)
  local t = textOf(id)
  if not t then return end
  currentText, currentPage = id, pageNumber or 1
  local found = t
  local shelf = shelfOf(t)
  for _, s in ipairs(SHELVES) do
    if s[1] == shelf then
      page.icon.tex:SetTexture(s[3])
      page.icon.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
      page.sub:SetText(
        ("%s  -  %s"):format(
          s[2],
          found.zone
              and ("found in %s%s, %s"):format(found.zone, found.sub and (": " .. found.sub) or "", day(found.at))
            or "found"
        )
      )
    end
  end
  page.icon:Show()
  page.title:SetText(t.title)
  -- the pages: those copied, and how many there are once the last was read
  local last = t.count
  local highest = 0
  for p in pairs(t.pages) do
    highest = math.max(highest, p)
  end
  local body = t.pages[currentPage]
  page.body:SetText(
    body and plain(body)
      or "|cff9e9178This page did not reach the codex; open the text again in the world to copy it.|r"
  )
  page.pageLabel:SetText(("Page %d of %d"):format(currentPage, last or highest))
  page.prev:SetEnabled(currentPage > 1)
  page.next:SetEnabled(currentPage < (last or highest))
  local multi = (last or highest) > 1
  page.prev:SetShown(multi)
  page.next:SetShown(multi)
  page.pageLabel:SetShown(multi)
  page.child:SetHeight(ui.HEADER_H + page.body:GetStringHeight() + 60)
  page:ScrollTo(0)
end
ns.showLibraryText = showText

function showShelf()
  currentText = nil
  page.icon.tex:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
  page.icon.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  page.icon:Show()
  page.title:SetText("The Library")
  page.sub:SetText(("%d texts copied"):format(ns.libraryCount()))
  page.body:SetText(
    "Every book, note and plaque you read in the world is copied here whole, so that you can read it again, even a letter long since handed in. Letters written by players are never copied."
  )
  page.prev:Hide()
  page.next:Hide()
  page.pageLabel:Hide()
  page.child:SetHeight(ui.HEADER_H + page.body:GetStringHeight() + 30)
  page:ScrollTo(0)
end

function ns.refreshLibrary()
  if not list then return end
  book.count:SetText(("%d texts in the Library"):format(ns.libraryCount()))
  refreshList()
  if currentText then
    showText(currentText, currentPage)
  else
    showShelf()
  end
end

function ns.buildLibrary(b)
  ui, book = ns.ui, b
  local WIDTH = ui.WIDTH
  list = ui.scrollArea("LorekeepersCodexLibraryList", book.left, ROW_WIDTH)
  list:SetPoint("TOPLEFT", book.left, "TOPLEFT", 12, -40)
  list:SetPoint("BOTTOMRIGHT", book.left, "BOTTOMRIGHT", -18, 12)
  page = ui.scrollArea("LorekeepersCodexLibraryPage", book.sheet, WIDTH)
  page:SetPoint("TOPLEFT", book.sheet, "TOPLEFT", 26, -22)
  page:SetPoint("BOTTOMRIGHT", book.sheet, "BOTTOMRIGHT", -22, 14)
  book.libraryList, book.libraryPage = list, page

  page.icon = ui.roundIcon(page.child, 56)
  page.icon:SetPoint("TOPLEFT", 2, -2)
  page.title = ui.label(page.child, ui.TITLE_FONT, 24, ui.T.gold)
  page.title:SetPoint("TOPLEFT", page.icon, "TOPRIGHT", 16, -4)
  page.title:SetWidth(WIDTH - 78)
  page.title:SetWordWrap(false)
  page.sub = ui.label(page.child, ui.BODY_FONT, 12, ui.T.soft)
  page.sub:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, -7)
  page.sub:SetWidth(WIDTH - 78)
  local headerRule = ui.rule(page.child)
  headerRule:SetPoint("TOPLEFT", 0, -70)
  headerRule:SetPoint("TOPRIGHT", 0, -70)
  page.body = ui.label(page.child, ui.BODY_FONT, 13, ui.T.text)
  page.body:SetPoint("TOPLEFT", 0, -ui.HEADER_H)
  page.body:SetWidth(WIDTH)
  page.body:SetSpacing(4)

  -- Turning pages: the spellbook's arrows, and where you are, under the text.
  page.pageLabel = ui.label(page.child, ui.BODY_FONT, 11, ui.T.soft)
  page.pageLabel:SetPoint("TOP", page.body, "BOTTOM", 0, -18)
  local function arrow(dir, x)
    local button = CreateFrame("Button", nil, page.child)
    button:SetSize(26, 26)
    button:SetPoint("CENTER", page.pageLabel, "CENTER", x, 0)
    button:SetNormalTexture(("Interface\\Buttons\\UI-SpellbookIcon-%sPage-Up"):format(dir))
    button:SetPushedTexture(("Interface\\Buttons\\UI-SpellbookIcon-%sPage-Down"):format(dir))
    button:SetDisabledTexture(("Interface\\Buttons\\UI-SpellbookIcon-%sPage-Disabled"):format(dir))
    button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    return button
  end
  page.prev = arrow("Prev", -150)
  page.next = arrow("Next", 150)
  page.prev:SetScript("OnClick", function()
    if currentText then showText(currentText, currentPage - 1) end
  end)
  page.next:SetScript("OnClick", function()
    if currentText then showText(currentText, currentPage + 1) end
  end)
end

-- Open the codex at a text of the Library (lorekeeper:lib:<id>: a link in chat).
function ns.openText(id)
  if not mine()[id] then return end
  local b = ns.ui.build()
  currentText, currentPage = id, 1
  if not b:IsShown() then b:Show() end
  ns.showTab(2)
end

-- A text copied while the Library is open shows up at once.
ns.onLibrary = function()
  local b = ns.ui and ns.ui.book()
  if b and b:IsShown() and b.selectedTab == 2 then ns.refreshLibrary() end
end
