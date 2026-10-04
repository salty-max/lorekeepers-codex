-- The codex as a book: chapters and pages on the left (locked pages are
-- "· · ·"), the open page on parchment on the right, with when and where this
-- character found it and links to related pages. /codex opens it.
local _, ns = ...
local C = ns.content

local INK = { 0.22, 0.14, 0.05 } -- dark brown, on parchment
local INK_SOFT = { 0.42, 0.30, 0.16 }
local KIND = { place = "A place", figure = "A figure", faction = "A people", creature = "A creature", history = "History", note = "" }

local book, list, page
local current

local function when(t)
  return date("%d %b %Y", t)
end

-- "Found on 3 Oct 2026, at level 17, in Kharanos (Dun Morogh)."
local function foundLine(p)
  if p.retro then return ("Known to you before this ledger, at level %d."):format(p.level or 0) end
  local where = p.sub and p.sub ~= "" and p.sub ~= p.zone and ("%s (%s)"):format(p.sub, p.zone) or p.zone or "?"
  return ("Found on %s, at level %d, in %s."):format(when(p.at), p.level or 0, where)
end

-- ── the open page ────────────────────────────────────────────────────────────
local function showPage(id)
  current = id
  local e, p = C.entries[id], ns.page(id)
  if not e or not p then return end
  ns.markRead(id)
  page.title:SetText(e.title)
  page.kind:SetText(KIND[e.kind] or "")
  local paras = {}
  for _, para in ipairs(e.text) do
    table.insert(paras, para.italic and ("|cff6b4a26%s|r"):format(para[1]) or para[1])
  end
  page.body:SetText(table.concat(paras, "\n\n"))
  page.found:SetText(foundLine(p))

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
  r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  rows[i] = r
  return r
end

function ns.refresh()
  if not book then return end
  book.count:SetText(("%d of %d pages"):format(ns.count(), ns.total))
  for _, r in ipairs(rows) do r:Hide() end
  local i, y = 0, 0
  local function add(kind, text, id)
    i = i + 1
    local r = row(i)
    r:ClearAllPoints()
    r:SetPoint("TOPLEFT", 0, -y)
    r.id = id
    if kind == "chapter" then
      r.text:SetFontObject("GameFontNormal")
      r.text:SetText(text)
      r:Disable()
      y = y + 24
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
  -- Loose pages (the foreword) first, then each chapter.
  for id, e in pairs(C.entries) do
    if e.chapter == "" and ns.page(id) then add("page", nil, id) end
  end
  for _, ch in ipairs(C.chapters) do
    y = y + 6
    add("chapter", ch.title)
    for _, id in ipairs(ch.entries) do
      if ns.page(id) then add("page", nil, id) else add("locked") end
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

  -- Left: the list.
  list = CreateFrame("ScrollFrame", "LorekeepersCodexList", book, "UIPanelScrollFrameTemplate")
  list:SetPoint("TOPLEFT", 20, -44)
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
  -- The parchment of the game's own book reader (ItemTextFrame), shown at its
  -- real scale from the top left, as that frame does.
  paper:SetTexture("Interface\\MailFrame\\UI-MailFrameBG")
  sheet:SetScript("OnSizeChanged", function(_, w, h) paper:SetTexCoord(0, math.min(1, w / 512), 0, math.min(1, h / 512)) end)

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

  page.kind = page.child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  page.kind:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, -2)
  page.kind:SetTextColor(unpack(INK_SOFT))
  page.kind:SetShadowColor(0, 0, 0, 0)

  page.body = page.child:CreateFontString(nil, "OVERLAY", "QuestFont")
  page.body:SetPoint("TOPLEFT", page.kind, "BOTTOMLEFT", 0, -10)
  page.body:SetWidth(420)
  page.body:SetJustifyH("LEFT")
  page.body:SetSpacing(2)
  page.body:SetTextColor(unpack(INK))
  page.body:SetShadowColor(0, 0, 0, 0)

  page.found = page.child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  page.found:SetPoint("TOPLEFT", page.body, "BOTTOMLEFT", 0, -14)
  page.found:SetWidth(420)
  page.found:SetJustifyH("LEFT")
  page.found:SetTextColor(unpack(INK_SOFT))
  page.found:SetShadowColor(0, 0, 0, 0)

  page.seeAlso = page.child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  page.seeAlso:SetPoint("TOPLEFT", page.found, "BOTTOMLEFT", 0, -12)
  page.seeAlso:SetText("See also")
  page.seeAlso:SetTextColor(unpack(INK))
  page.seeAlso:SetShadowColor(0, 0, 0, 0)
  page.links = {}

  book:SetScript("OnShow", function()
    if not current or not ns.page(current) then
      -- First opening: the newest unread page, else the foreword.
      for id in pairs(C.entries) do
        if ns.page(id) and not ns.isRead(id) then current = id break end
      end
      current = current or "foreword"
    end
    showPage(current)
    ns.refresh()
  end)
end

function ns.toggle()
  if not book then build() end
  book:SetShown(not book:IsShown())
end

-- A page found while the book is open shows up in the list at once.
ns.onUnlock = function()
  if book and book:IsShown() then ns.refresh() end
end
