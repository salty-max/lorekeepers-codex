-- The codex as a book: chapters and pages on the left (locked pages are
-- "· · ·"; a click on a chapter's title folds it away or opens it), the open page on parchment on the right, with links to related
-- pages. A second tab lists the achievements. /codex opens it.
local _, ns = ...
local C = ns.content

local INK = { 0.22, 0.14, 0.05 } -- dark brown, on parchment

local book, list, page, achievements
local build -- the book, made on first opening (below)
local current

-- ── the open page ────────────────────────────────────────────────────────────
local function showPage(id)
  current = id
  local e = C.entries[id]
  if not e or not ns.page(id) then return end
  ns.markRead(id)
  page.title:SetText(e.title)
  -- All in the same ink: the signature (an italic paragraph) used to be a
  -- lighter brown, which read as faded on the parchment.
  local paras = {}
  for _, para in ipairs(e.text) do
    if not para.client or para.client == ns.client then table.insert(paras, para[1]) end
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
      b:SetScript("OnClick", function() showPage(other); ns.refresh(true) end)
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
ns.listRows = rows -- for the tests
local function row(i)
  local r = rows[i]
  if r then return r end
  r = CreateFrame("Button", nil, list.child)
  r:SetSize(196, 18)
  r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  r.text:SetPoint("LEFT", 8, 0)
  r.text:SetPoint("RIGHT", -4, 0)
  r.text:SetJustifyH("LEFT")
  -- A chapter's fold: the plus and minus of the game's own lists.
  r.fold = r:CreateTexture(nil, "ARTWORK")
  r.fold:SetSize(16, 16)
  r.fold:SetPoint("LEFT", 2, 0)
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
-- A curly apostrophe (typed or pasted) counts as a straight one.
local function plain(s) return (s:lower():gsub("\226\128\153", "'")) end
local haystack = {}
local function matches(id, query)
  if not haystack[id] then
    local e = C.entries[id]
    local parts = { e.title }
    for _, para in ipairs(e.text) do
      if not para.client or para.client == ns.client then table.insert(parts, para[1]) end
    end
    haystack[id] = plain(table.concat(parts, " "))
  end
  return haystack[id]:find(query, 1, true) ~= nil
end

function ns.search(query)
  local out = {}
  query = plain(query or ""):gsub("^%s+", ""):gsub("%s+$", "")
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

-- Scroll the list so the open page's row shows, in the middle if it was out
-- of sight. The scroll range is worked out here: the frame's own may not have
-- caught up with the list's new height yet.
local function reveal(y)
  local height = list:GetHeight()
  local top = list:GetVerticalScroll()
  if y >= top and y + 18 <= top + height then return end
  local max = math.max(0, list.child:GetHeight() - height)
  list:SetVerticalScroll(math.min(max, math.max(0, y - (height - 18) / 2)))
end

-- reveal: scroll to the open page (opening the book, a link, the banner).
-- Folded chapters, per character (each codex opens its own chapters).
local function folded()
  local c = LorekeepersCodexChar
  if not c then return {} end
  c.collapsed = c.collapsed or {}
  return c.collapsed
end

-- The chapters in the list (those with a page found): is any open? Fold or
-- unfold them all.
function ns.anyUnfolded()
  for _, ch in ipairs(C.chapters) do
    if ns.found(ch) > 0 and not folded()[ch.id] then return true end
  end
  return false
end

function ns.foldAll(fold)
  for _, ch in ipairs(C.chapters) do
    if ns.found(ch) > 0 then folded()[ch.id] = fold or nil end
  end
  ns.refresh()
end

function ns.refresh(scrollToCurrent)
  if not book then return end
  if book.selectedTab == 2 then return ns.refreshAchievements() end
  -- Going to a page (a link, the banner) unfolds its chapter.
  local e = scrollToCurrent and current and C.entries[current]
  if e and e.chapter ~= "" then folded()[e.chapter] = nil end
  local currentY
  book.count:SetText(("%d of %d pages"):format(ns.count(), ns.knownTotal()))
  if book.foldAll then book.foldAll:SetNormalTexture(ns.anyUnfolded() and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up") end
  for _, r in ipairs(rows) do r:Hide() end
  local i, y = 0, 0
  local function add(kind, text, id, found, total, chapter)
    i = i + 1
    local r = row(i)
    r:ClearAllPoints()
    r:SetPoint("TOPLEFT", 0, -y)
    r.id = id
    if kind == "page" and id == current then currentY = y end
    r.count:SetText(kind == "chapter" and id or "")
    r.bar:SetShown(kind == "chapter")
    r.fold:SetShown(kind == "chapter")
    r.text:SetPoint("LEFT", kind == "chapter" and 20 or 8, 0)
    if kind == "chapter" then
      r.text:SetFontObject("GameFontNormal")
      r.text:SetText(text)
      r.bar:SetMinMaxValues(0, total)
      r.bar:SetValue(found)
      r.fold:SetTexture(folded()[chapter] and "Interface\\Buttons\\UI-PlusButton-Up" or "Interface\\Buttons\\UI-MinusButton-Up")
      r:Enable()
      r:SetScript("OnClick", function()
        folded()[chapter] = not folded()[chapter] or nil
        ns.refresh()
      end)
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
      r.fold:Hide()
      r.text:SetPoint("LEFT", 8, 0)
      r.text:SetFontObject("GameFontDisableSmall")
      r.text:SetText("No page found.")
      r:Disable()
      r:Show()
      y = 18
    end
    list.child:SetHeight(y + 8)
    if scrollToCurrent and currentY then reveal(currentY) end
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
      add("chapter", ch.title, ("%d/%d"):format(found, #ch.entries), found, #ch.entries, ch.id)
      if not folded()[ch.id] then
        for _, id in ipairs(ch.entries) do
          if ns.page(id) then add("page", nil, id) else add("locked") end
        end
      end
    end
  end
  list.child:SetHeight(y + 8)
  if scrollToCurrent and currentY then reveal(currentY) end
end

-- ── the achievements ──────────────────────────────────────────────────────────
-- One row each, under its group's heading: the title (gold once earned), what
-- it asks, and on the right when it was earned, or how far along it is.
local GROUPS = { { "milestone", "Milestones" }, { "feat", "Feats" }, { "chapter", "Chapters" } }
local ROW = 46
local achRows, headers = {}, {}
local selected

local function achRow(i)
  local r = achRows[i]
  if r then return r end
  r = CreateFrame("Frame", nil, achievements.child)
  r:SetSize(680, ROW - 4)
  r.bg = r:CreateTexture(nil, "BACKGROUND")
  r.bg:SetAllPoints()
  r.title = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  r.title:SetPoint("TOPLEFT", 10, -6)
  r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  r.text:SetPoint("TOPLEFT", r.title, "BOTTOMLEFT", 0, -4)
  r.text:SetWidth(480)
  r.text:SetJustifyH("LEFT")
  r.status = r:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  r.status:SetPoint("TOPRIGHT", -10, -7)
  r.bar = CreateFrame("StatusBar", nil, r)
  r.bar:SetSize(150, 6)
  r.bar:SetPoint("TOPRIGHT", r.status, "BOTTOMRIGHT", 0, -6)
  r.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  r.bar:SetStatusBarColor(0.85, 0.65, 0.13)
  local bg = r.bar:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.5)
  achRows[i] = r
  return r
end

local function header(i)
  local h = headers[i]
  if h then return h end
  h = achievements.child:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  headers[i] = h
  return h
end

function ns.refreshAchievements()
  if not achievements then return end
  book.count:SetText(("%d of %d achievements"):format(ns.achievementCount()))
  local i, y, selectedY = 0, 0, nil
  for g, group in ipairs(GROUPS) do
    local h = header(g)
    h:ClearAllPoints()
    h:SetPoint("TOPLEFT", 4, -y - 4)
    h:SetText(group[2])
    y = y + 28
    for _, a in ipairs(ns.achievements) do
      if a.group == group[1] and ns.achievementVisible(a) then
        i = i + 1
        local r = achRow(i)
        r:ClearAllPoints()
        r:SetPoint("TOPLEFT", 0, -y)
        if a.id == selected then selectedY = y end
        local earned = ns.earned(a.id)
        local done, need = a.progress()
        r.title:SetText(a.title)
        r.text:SetText(a.text)
        if earned then
          r.title:SetTextColor(1, 0.82, 0)
          r.status:SetText(("Level %d, %s"):format(earned.level or 0, date("%d %b %Y", earned.at or 0)))
          r.bar:Hide()
        else
          r.title:SetTextColor(0.6, 0.6, 0.6)
          if a.unit then
            r.status:SetText(("%d %s"):format(done, a.unit))
            r.bar:Hide()
          else
            r.status:SetText(("%d/%d"):format(math.min(done, need), need))
            r.bar:SetMinMaxValues(0, math.max(need, 1))
            r.bar:SetValue(math.min(done, need))
            r.bar:SetShown(need > 1)
          end
        end
        if a.id == selected then r.bg:SetColorTexture(1, 0.82, 0, 0.22)
        elseif earned then r.bg:SetColorTexture(0.85, 0.65, 0.13, 0.10)
        else r.bg:SetColorTexture(1, 1, 1, 0.03) end
        r:Show()
        y = y + ROW
      end
    end
    y = y + 8
  end
  for k = i + 1, #achRows do achRows[k]:Hide() end
  achievements.child:SetHeight(y)
  -- An achievement opened from chat or the banner: bring it into view.
  if selectedY then
    local height = achievements:GetHeight()
    local max = math.max(0, y - height)
    achievements:SetVerticalScroll(math.min(max, math.max(0, selectedY - (height - ROW) / 2)))
  end
end

local function buildAchievements()
  achievements = CreateFrame("ScrollFrame", "LorekeepersCodexAchievements", book, "UIPanelScrollFrameTemplate")
  achievements:SetPoint("TOPLEFT", 24, -44)
  achievements:SetPoint("BOTTOMRIGHT", -40, 20)
  achievements.child = CreateFrame("Frame", nil, achievements)
  achievements.child:SetSize(680, 10)
  achievements:SetScrollChild(achievements.child)
  achievements:Hide()
end

-- The book's two tabs, under its bottom edge, in the style of the character
-- sheet's.
function ns.showTab(n)
  if not book then return end
  book.selectedTab = n
  if PanelTemplates_SetTab then PanelTemplates_SetTab(book, n) end
  book.search:SetShown(n == 1)
  book.foldAll:SetShown(n == 1)
  list:SetShown(n == 1)
  book.sheet:SetShown(n == 1)
  achievements:SetShown(n == 2)
  if n == 2 then ns.refreshAchievements() else ns.refresh(true) end
end

-- The character sheet's tabs on Classic; the shared panel tabs where that
-- template doesn't exist (the modern client of Forever).
local function hasTemplate(name)
  if not (C_XMLUtil and C_XMLUtil.GetTemplateInfo) then return name == "CharacterFrameTabButtonTemplate" end
  return C_XMLUtil.GetTemplateInfo(name) ~= nil
end

local function buildTabs()
  local template = hasTemplate("CharacterFrameTabButtonTemplate") and "CharacterFrameTabButtonTemplate" or "PanelTabButtonTemplate"
  for n, label in ipairs({ "Pages", "Achievements" }) do
    local tab = CreateFrame("Button", "LorekeepersCodexFrameTab" .. n, book, template)
    tab:SetID(n)
    tab:SetText(label)
    if n == 1 then tab:SetPoint("TOPLEFT", book, "BOTTOMLEFT", 14, 8)
    else tab:SetPoint("LEFT", "LorekeepersCodexFrameTab" .. (n - 1), "RIGHT", -14, 0) end
    tab:SetScript("OnClick", function(self)
      selected = nil
      ns.showTab(self:GetID())
      if PlaySound and SOUNDKIT and SOUNDKIT.IG_CHARACTER_INFO_TAB then PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB) end
    end)
    tab:SetScript("OnShow", function(self)
      if PanelTemplates_TabResize then PanelTemplates_TabResize(self, 0) end
    end)
    if PanelTemplates_TabResize then PanelTemplates_TabResize(tab, 0) end
  end
  if PanelTemplates_SetNumTabs then PanelTemplates_SetNumTabs(book, 2) end
  book.selectedTab = 1
  if PanelTemplates_SetTab then PanelTemplates_SetTab(book, 1) end
end

-- Open the book at the achievements, one of them picked out.
function ns.openAchievements(id)
  if not book then build() end
  selected = id
  if not book:IsShown() then book:Show() end
  ns.showTab(2)
end

-- ── the book ─────────────────────────────────────────────────────────────────
function build()
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
  book.search:SetSize(172, 20)
  book.search:SetPoint("TOPLEFT", 28, -44)
  book.search:HookScript("OnTextChanged", function() ns.refresh() end)

  -- Beside it, fold or unfold every chapter at once: a minus while any is
  -- open, a plus once all are folded.
  book.foldAll = CreateFrame("Button", "LorekeepersCodexFoldAll", book)
  book.foldAll:SetSize(16, 16)
  book.foldAll:SetPoint("LEFT", book.search, "RIGHT", 6, 0)
  book.foldAll:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
  local function tip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(ns.anyUnfolded() and "Fold every chapter" or "Unfold every chapter")
    GameTooltip:Show()
  end
  book.foldAll:SetScript("OnClick", function(self)
    ns.foldAll(ns.anyUnfolded())
    if GameTooltip:IsOwned(self) then tip(self) end
  end)
  book.foldAll:SetScript("OnEnter", tip)
  book.foldAll:SetScript("OnLeave", function() GameTooltip:Hide() end)

  list = CreateFrame("ScrollFrame", "LorekeepersCodexList", book, "UIPanelScrollFrameTemplate")
  list:SetPoint("TOPLEFT", 20, -70)
  list:SetPoint("BOTTOMLEFT", 20, 20)
  list:SetWidth(204)
  list.child = CreateFrame("Frame", nil, list)
  list.child:SetSize(204, 10)
  list:SetScrollChild(list.child)

  -- Right: the page, on parchment.
  local sheet = CreateFrame("Frame", nil, book)
  book.sheet = sheet
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
    ns.refresh(true)
  end)

  buildAchievements()
  buildTabs()
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
  ns.showTab(1)
  if book:IsShown() then
    showPage(id)
    ns.refresh(true)
  else
    book:Show()
  end
end

-- Codex links in chat (|Hlorekeeper:<id>|h[Title]|h): the game hands links of
-- an unknown type to the handler registered for it.
local function followLink(link)
  local id = link:match("^lorekeeper:(.+)$")
  if not id then return end
  local achievement = id:match("^ach:(.+)$")
  if achievement then ns.openAchievements(achievement) else ns.open(id) end
end
if LinkUtil and LinkUtil.RegisterLinkHandler then
  LinkUtil.RegisterLinkHandler("lorekeeper", function(link)
    followLink(link)
    return LinkProcessorResponse and LinkProcessorResponse.Handled
  end)
elseif hooksecurefunc and SetItemRef then
  -- Clients without the link registry still pass every click to SetItemRef.
  hooksecurefunc("SetItemRef", function(link) followLink(link) end)
end

-- A page found while the book is open shows up in the list at once; so does
-- an achievement.
ns.onUnlock = function()
  if book and book:IsShown() then ns.refresh() end
end
ns.onAchievement = ns.onUnlock
