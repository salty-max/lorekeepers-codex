-- The Library's tab: on the left, the texts copied (Library.lua) on their
-- shelves (books, notes and letters, plaques), folded or open, and searched by
-- their words; on the right (the kit's page), a text one page at a time, with
-- where and when it was found; before one is opened, the Library at a glance:
-- its figures by shelf, the texts copied lately.
local _, ns = ...
local L = ns.kit.L
local ui = ns.ui
local store, shelfOf, plain = ns.library, ns.libraryShelf, ns.libraryPlain
local SHELVES = ns.SHELVES

local book, list, page
local currentText, currentPage = nil, 1
local rows = {}
ns.libraryRows = rows -- for the tests

local function folded()
  local c = LorekeepersCodexChar
  if not c then return {} end
  c.libraryFolded = c.libraryFolded or {}
  return c.libraryFolded
end

local function row(i)
  local r = rows[i]
  if r then return r end
  r = ui.listRow(list.child)
  r.count:SetPoint("RIGHT", -4, 0)
  r.count:SetJustifyH("RIGHT")
  r.fold:SetPoint("LEFT", 2, 0)
  rows[i] = r
  return r
end

local function textOf(id) return store().texts[id] end
local function mine() return store().texts end

local function matches(id, query)
  local t = textOf(id)
  if not t then return false end
  if ns.textTitle(t.title):lower():find(query, 1, true) then return true end
  for _, p in pairs(ns.textPages(t)) do
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
      table.sort(ids, function(a, b) return ns.textTitle(textOf(a).title) < ns.textTitle(textOf(b).title) end)
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
          local e = add("text", ns.textTitle(textOf(id).title))
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
  if empty then add("text", searching and L["No text found."] or L["Nothing read yet."]):SetScript("OnClick", nil) end
  list.child:SetHeight(y + 8)
  list:UpdateThumb()
end

-- A text's shelf: { id, name, icon }.
local function shelfFor(t)
  local shelf = shelfOf(t)
  for _, s in ipairs(SHELVES) do
    if s[1] == shelf then return s end
  end
  return SHELVES[1]
end

-- Where and when it was copied.
local function foundAt(t)
  if not t.zone then return L["found"] end
  local zone, sub = ns.placeName(t.zone, t.zoneId), t.sub and t.sub ~= "" and ns.placeName(t.sub, t.subId)
  return L["found in %s, %s"]:format(sub and L["%s: %s"]:format(zone, sub) or zone, ui.day(t.at))
end

-- A text, one page at a time, the arrows that turn them under it.
function showText(id, pageNumber)
  local t = textOf(id)
  if not t then return end
  currentText, currentPage = id, pageNumber or 1
  local shelf = shelfFor(t)
  page:start(ns.textTitle(t.title), ("%s  -  %s"):format(shelf[2], foundAt(t)), ui.icon(shelf[3]))
  -- the pages: those copied, and how many there are once the last was read
  -- (a text copied in another language: the game's own, whole, in this one)
  local pages, whole = ns.textPages(t)
  local last = whole and #pages or t.count
  local highest = 0
  for p in pairs(pages) do
    highest = math.max(highest, p)
  end
  local body = pages[currentPage]
  page:text({
    body and ns.textForReader(plain(body))
      or "|cff9e9178" .. L["This page did not reach the codex. Open the text again in the world to copy it."] .. "|r",
  })
  if (last or highest) > 1 then
    page.pageLabel:SetText(L["Page %d of %d"]:format(currentPage, last or highest))
    page.prev:SetEnabled(currentPage > 1)
    page.next:SetEnabled(currentPage < (last or highest))
    page:place(page.turn, 40)
  else
    page.turn:Hide()
  end
  page:finish()
end
ns.showLibraryText = showText

-- The Library at a glance: its figures by shelf, the texts copied lately.
local LATELY = 5
function showShelf()
  currentText = nil
  page:start(
    L["The Library"],
    L["%d texts copied"]:format(ns.libraryCount()),
    ui.icon("Interface\\Icons\\INV_Misc_Book_09")
  )
  page.turn:Hide()
  local count, recent = {}, {}
  for id, t in pairs(mine()) do
    local shelf = shelfOf(t)
    count[shelf] = (count[shelf] or 0) + 1
    table.insert(recent, { id = id, t = t })
  end
  local figures = { { tostring(ns.libraryCount()), L["texts copied"] } }
  for _, s in ipairs(SHELVES) do
    table.insert(figures, { tostring(count[s[1]] or 0), L[s[1]] }) -- (the shelf's short name: books, notes, plaques)
  end
  page:stats(figures)
  page:paragraph(
    L["Every book, note and plaque you read in the world is copied here whole, so that you can read it again, even a letter long since handed in. Letters written by players are never copied."],
    ui.T.soft
  )
  table.sort(recent, function(a, b)
    if (a.t.at or 0) ~= (b.t.at or 0) then return (a.t.at or 0) > (b.t.at or 0) end
    return ns.textTitle(a.t.title) < ns.textTitle(b.t.title)
  end)
  if #recent > 0 then
    page:section(L["Copied lately"])
    for i = 1, math.min(LATELY, #recent) do
      local r = recent[i]
      local shelf = shelfFor(r.t)
      page:card(ns.textTitle(r.t.title), ("%s  -  %s"):format(shelf[2], foundAt(r.t)), ui.icon(shelf[3]), function()
        showText(r.id)
        refreshList()
      end)
    end
  end
  page:finish()
end

local function refresh()
  book.count:SetText(L["%d texts in the Library"]:format(ns.libraryCount()))
  refreshList()
  if currentText then
    showText(currentText, currentPage)
  else
    showShelf()
  end
end

local function build(b)
  book = b
  list = ui.listArea("LorekeepersCodexLibraryList", book)
  page = ui.pageArea("LorekeepersCodexLibraryPage", book)
  -- Turning pages: the spellbook's arrows, and where you are, under the text.
  page.turn = CreateFrame("Frame", nil, page.child)
  page.turn:SetSize(ui.WIDTH, 30)
  page.pageLabel = ui.label(page.turn, ui.BODY_FONT, 11, ui.T.soft)
  page.pageLabel:SetPoint("TOP", 0, -8)
  local function arrow(dir, x)
    local button = CreateFrame("Button", nil, page.turn)
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

local function show(n)
  list:SetShown(n == ns.TAB.library)
  page:SetShown(n == ns.TAB.library)
end

-- (its tab clicked: the Library at a glance)
local function chosen() currentText = nil end

ns.addTab(ns.TAB.library, { build = build, show = show, refresh = refresh, chosen = chosen })

-- Open the codex at a text of the Library (lorekeeper:lib:<id>: a link in chat).
function ns.openText(id)
  if not mine()[id] then return end
  currentText, currentPage = id, 1
  ns.openTab(ns.TAB.library)
end
