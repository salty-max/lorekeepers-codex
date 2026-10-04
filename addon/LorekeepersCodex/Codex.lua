-- The codex as a book: chapters and pages on the left (locked pages are
-- "· · ·"), the open page on parchment on the right, with links to related
-- pages. /codex opens it.
local _, ns = ...
local C = ns.content

local INK = { 0.22, 0.14, 0.05 } -- dark brown, on parchment

local book, list, page
local current

-- ── the open page ────────────────────────────────────────────────────────────
local function showPage(id)
  current = id
  local e = C.entries[id]
  if not e or not ns.page(id) then return end
  ns.markRead(id)
  page.title:SetText(e.title)
  local paras = {}
  for _, para in ipairs(e.text) do
    table.insert(paras, para.italic and ("|cff6b4a26%s|r"):format(para[1]) or para[1])
  end
  page.body:SetText(table.concat(paras, "\n\n"))

  -- "See also": the related pages this character has found.
  for _, b in ipairs(page.links) do b:Hide() end
  local n = 0
  for _, other in ipairs(e.also) do
    if ns.page(other) then
      n = n + 1
      local b = page.links[n]
      if not b then
        b = CreateFrame("Button", nil, page.child)
        b:SetSize(300, 16)
        b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        b.text:SetPoint("LEFT")
        b.text:SetJustifyH("LEFT")
        b:SetScript("OnEnter", function(self) self.text:SetTextColor(1, 1, 1) end)
        b:SetScript("OnLeave", function(self) self.text:SetTextColor(0.55, 0.22, 0.05) end)
        page.links[n] = b
      end
      b.text:SetText("» " .. C.entries[other].title)
      b.text:SetTextColor(0.55, 0.22, 0.05)
      b:SetScript("OnClick", function() showPage(other); ns.refresh() end)
      b:SetPoint("TOPLEFT", page.seeAlso, "BOTTOMLEFT", 0, -4 - (n - 1) * 18)
      b:Show()
    end
  end
  page.seeAlso:SetShown(n > 0)
  page.scroll:SetVerticalScroll(0)
  page.child:SetHeight(page.title:GetStringHeight() + page.body:GetStringHeight() + 120 + n * 18)
end

-- ── the list of chapters and pages ───────────────────────────────────────────
local rows = {}
local function row(i)
  local r = rows[i]
  if r then return r end
  r = CreateFrame("Button", nil, list.child)
  r:SetSize(196, 18)
  r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  r.text:SetPoint("LEFT", 8, 0)
  r.text:SetPoint("RIGHT", -4, 0)
  r.text:SetJustifyH("LEFT")
  -- A chapter's progress, under its title: a bar, then the pages found.
  r.bar = CreateFrame("StatusBar", nil, r)
  r.bar:SetPoint("TOPLEFT", r, "BOTTOMLEFT", 8, -2)
  r.bar:SetPoint("TOPRIGHT", r, "BOTTOMRIGHT", -44, -2)
  r.bar:SetHeight(5)
  r.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  r.bar:SetStatusBarColor(0.85, 0.65, 0.13)
  local bg = r.bar:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.5)
  r.count = r:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  r.count:SetPoint("LEFT", r.bar, "RIGHT", 6, 0)
  r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  rows[i] = r
  return r
end

-- Pages found in a chapter.
function ns.found(ch)
  local n = 0
  for _, id in ipairs(ch.entries) do
    if ns.page(id) then n = n + 1 end
  end
  return n
end

-- Search: the pages this character has found whose title or text holds the
-- query (never locked ones: no spoilers). Text is lowered once, on first use.
local haystack = {}
local function matches(id, query)
  if not haystack[id] then
    local e = C.entries[id]
    local parts = { e.title }
    for _, para in ipairs(e.text) do table.insert(parts, para[1]) end
    haystack[id] = table.concat(parts, " "):lower()
  end
  return haystack[id]:find(query, 1, true) ~= nil
end

function ns.search(query)
  local out = {}
  query = (query or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  if query == "" then return out end
  for _, ch in ipairs(C.chapters) do
    for _, id in ipairs(ch.entries) do
      if ns.page(id) and matches(id, query) then table.insert(out, id) end
    end
  end
  for id, e in pairs(C.entries) do
    if e.chapter == "" and ns.page(id) and matches(id, query) then table.insert(out, 1, id) end
  end
  return out
end

function ns.refresh()
  if not book then return end
  book.count:SetText(("%d of %d pages"):format(ns.count(), ns.total))
  for _, r in ipairs(rows) do r:Hide() end
  local i, y = 0, 0
  local function add(kind, text, id, found, total)
    i = i + 1
    local r = row(i)
    r:ClearAllPoints()
    r:SetPoint("TOPLEFT", 0, -y)
    r.id = id
    r.count:SetText(kind == "chapter" and id or "")
    r.bar:SetShown(kind == "chapter")
    if kind == "chapter" then
      r.text:SetFontObject("GameFontNormal")
      r.text:SetText(text)
      r.bar:SetMinMaxValues(0, total)
      r.bar:SetValue(found)
      r:Disable()
      y = y + 32
    elseif kind == "locked" then
      r.text:SetFontObject("GameFontDisableSmall")
      r.text:SetText("· · ·")
      r:Disable()
      y = y + 18
    else
      r.text:SetFontObject(id == current and "GameFontNormalSmall" or "GameFontHighlightSmall")
      r.text:SetText((ns.isRead(id) and "" or "|cffffd100•|r ") .. C.entries[id].title)
      r:Enable()
      r:SetScript("OnClick", function() showPage(id); ns.refresh() end)
      y = y + 18
    end
    r:Show()
  end
  -- While searching, the list is the results.
  local query = book.search and book.search:GetText() or ""
  if query:find("%S") then
    local results = ns.search(query)
    for _, id in ipairs(results) do add("page", nil, id) end
    if #results == 0 then
      i = i + 1
      local r = row(i)
      r:ClearAllPoints()
      r:SetPoint("TOPLEFT", 0, 0)
      r.count:SetText("")
      r.bar:Hide()
      r.text:SetFontObject("GameFontDisableSmall")
      r.text:SetText("No page found.")
      r:Disable()
      r:Show()
      y = 18
    end
    list.child:SetHeight(y + 8)
    return
  end
  -- Loose pages (the foreword) first, then each chapter.
  for id, e in pairs(C.entries) do
    if e.chapter == "" and ns.page(id) then add("page", nil, id) end
  end
  -- A chapter appears once one of its pages is found, with its progress.
  for _, ch in ipairs(C.chapters) do
    local found = ns.found(ch)
    if found > 0 then
      y = y + 6
      add("chapter", ch.title, ("%d/%d"):format(found, #ch.entries), found, #ch.entries)
      for _, id in ipairs(ch.entries) do
        if ns.page(id) then add("page", nil, id) else add("locked") end
      end
    end
  end
  list.child:SetHeight(y + 8)
end

-- ── the book ─────────────────────────────────────────────────────────────────
local function build()
  book = CreateFrame("Frame", "LorekeepersCodexFrame", UIParent, "BackdropTemplate")
  book:SetSize(760, 520)
  book:SetPoint("CENTER")
  book:SetFrameStrata("HIGH")
  book:SetToplevel(true)
  book:SetMovable(true)
  book:EnableMouse(true)
  book:SetClampedToScreen(true)
  book:RegisterForDrag("LeftButton")
  book:SetScript("OnDragStart", book.StartMoving)
  book:SetScript("OnDragStop", book.StopMovingOrSizing)
  book:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
  })
  tinsert(UISpecialFrames, "LorekeepersCodexFrame") -- Escape closes it

  local title = book:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -18)
  title:SetText("Lorekeeper's Codex")

  local close = CreateFrame("Button", nil, book, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -6, -6)

  book.count = book:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  book.count:SetPoint("TOPLEFT", 24, -22)

  -- Left: a search box, then the list.
  book.search = CreateFrame("EditBox", "LorekeepersCodexSearch", book, "SearchBoxTemplate")
  book.search:SetSize(196, 20)
  book.search:SetPoint("TOPLEFT", 28, -44)
  book.search:HookScript("OnTextChanged", function() ns.refresh() end)

  list = CreateFrame("ScrollFrame", "LorekeepersCodexList", book, "UIPanelScrollFrameTemplate")
  list:SetPoint("TOPLEFT", 20, -70)
  list:SetPoint("BOTTOMLEFT", 20, 20)
  list:SetWidth(204)
  list.child = CreateFrame("Frame", nil, list)
  list.child:SetSize(204, 10)
  list:SetScrollChild(list.child)

  -- Right: the page, on parchment.
  local sheet = CreateFrame("Frame", nil, book)
  sheet:SetPoint("TOPLEFT", 256, -40)
  sheet:SetPoint("BOTTOMRIGHT", -20, 18)
  local paper = sheet:CreateTexture(nil, "BACKGROUND")
  paper:SetAllPoints()
  -- The parchment of the game's own book reader (ItemTextFrame). It fills the
  -- top-left of a 512×512 texture (about 63% by 70%, measured in game):
  -- that part, stretched over the whole page.
  paper:SetTexture("Interface\\MailFrame\\UI-MailFrameBG")
  paper:SetTexCoord(0, 0.625, 0, 0.70)

  page = CreateFrame("ScrollFrame", "LorekeepersCodexPage", sheet, "UIPanelScrollFrameTemplate")
  page:SetPoint("TOPLEFT", 18, -16)
  page:SetPoint("BOTTOMRIGHT", -32, 14)
  page.scroll = page
  page.child = CreateFrame("Frame", nil, page)
  page.child:SetSize(420, 10)
  page:SetScrollChild(page.child)

  page.title = page.child:CreateFontString(nil, "OVERLAY", "QuestTitleFont")
  page.title:SetPoint("TOPLEFT", 0, 0)
  page.title:SetWidth(420)
  page.title:SetJustifyH("LEFT")
  page.title:SetTextColor(unpack(INK))
  page.title:SetShadowColor(0, 0, 0, 0)

  page.body = page.child:CreateFontString(nil, "OVERLAY", "QuestFont")
  page.body:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, -12)
  page.body:SetWidth(420)
  page.body:SetJustifyH("LEFT")
  page.body:SetSpacing(2)
  page.body:SetTextColor(unpack(INK))
  page.body:SetShadowColor(0, 0, 0, 0)

  page.seeAlso = page.child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  page.seeAlso:SetPoint("TOPLEFT", page.body, "BOTTOMLEFT", 0, -16)
  page.seeAlso:SetText("See also")
  page.seeAlso:SetTextColor(unpack(INK))
  page.seeAlso:SetShadowColor(0, 0, 0, 0)
  page.links = {}

  book:SetScript("OnShow", function()
    if not current or not ns.page(current) then
      -- First opening: an unread page, else this character's foreword.
      for id in pairs(C.entries) do
        if ns.page(id) and not ns.isRead(id) then current = id break end
      end
      if not current then
        for id, e in pairs(C.entries) do
          if e.chapter == "" and ns.page(id) then current = id break end
        end
      end
    end
    showPage(current)
    ns.refresh()
  end)
end

function ns.toggle()
  if not book then build() end
  book:SetShown(not book:IsShown())
end

-- Open the book at a page (a click on a codex link in chat).
function ns.open(id)
  if not ns.page(id) then return end
  if not book then build() end
  current = id
  if book:IsShown() then
    showPage(id)
    ns.refresh()
  else
    book:Show()
  end
end

-- Codex links in chat (|Hlorekeeper:<id>|h[Title]|h): the game hands links of
-- an unknown type to the handler registered for it.
if LinkUtil and LinkUtil.RegisterLinkHandler then
  LinkUtil.RegisterLinkHandler("lorekeeper", function(link)
    ns.open(link:match("^lorekeeper:(.+)$"))
    return LinkProcessorResponse and LinkProcessorResponse.Handled
  end)
end

-- A page found while the book is open shows up in the list at once.
ns.onUnlock = function()
  if book and book:IsShown() then ns.refresh() end
end
