-- When a page is found, the game's own toast (its alert system, the one of
-- "New Recipe Learned"): the page's round picture, "A new page in the codex"
-- and its title; a click reads the page, a right-click dismisses it. An
-- achievement earned gets the game's achievement toast, with the codex's book.
-- Where the client lacks those, a slim banner of our own at the top centre of
-- the screen, in the book's look, with a close button. It goes away on its own after a few seconds
-- (bannerSeconds in the settings, 0 to keep it until read or closed), never
-- while the mouse is on it; a page found meanwhile replaces it. An achievement
-- earned shows the same way, and opens the book at the achievements. Turned
-- off in the settings or with /codex banner.
local _, ns = ...
local C = ns.content

local WIDTH, HEIGHT = 380, 66
local banner, timer

local function stopTimer()
  if timer then timer:Cancel() end
  timer = nil
end

-- When time is up with the mouse on the banner, look again a second later.
local function startTimer(seconds)
  stopTimer()
  seconds = seconds or ns.option("bannerSeconds")
  if not (seconds and seconds > 0 and C_Timer) then return end
  timer = C_Timer.NewTimer(seconds, function()
    if banner:IsMouseOver() then startTimer(1) else ns.hideBanner() end
  end)
end

-- The book's look: a dark panel (Forever: its Professions card; Classic: the
-- tooltip's dark box with a gold edge), the page's round picture, a short
-- line in soft gold, the title in the title font.
local function build()
  local L = ns.look
  banner = CreateFrame("Button", "LorekeepersCodexBanner", UIParent, "BackdropTemplate")
  banner:SetSize(WIDTH, HEIGHT)
  banner:SetPoint("TOP", 0, -36)
  banner:SetFrameStrata("HIGH")
  if ns.forever then
    local art = L.card(banner)
    art:SetAllPoints()
  else
    banner:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 16, edgeSize = 16,
      insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    banner:SetBackdropColor(0.05, 0.045, 0.04, 0.95)
    banner:SetBackdropBorderColor(0.72, 0.56, 0.24)
  end
  banner:Hide()

  banner.picture = ns.roundIcon(banner, 42)
  banner.picture:SetPoint("LEFT", 14, 0)
  banner.kicker = ns.label(banner, L.BODY_FONT, 11, L.T.soft)
  banner.title = ns.label(banner, L.TITLE_FONT, 18, L.T.gold)
  banner.title:SetWordWrap(false)

  local close = CreateFrame("Button", nil, banner, "UIPanelCloseButton")
  close:SetSize(24, 24)
  close:SetPoint("TOPRIGHT", -4, -4)
  close:SetScript("OnClick", function() ns.hideBanner() end)

  -- A click anywhere reads the page (or opens the achievements).
  banner:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  banner:GetHighlightTexture():SetAlpha(0.25)
  banner:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:AddLine(self.achievement and "Click to see your achievements" or "Click to read this page")
    GameTooltip:Show()
  end)
  banner:SetScript("OnLeave", function() GameTooltip:Hide() end)
  banner:SetScript("OnClick", function(self)
    local id, achievement = self.id, self.achievement
    ns.hideBanner()
    if achievement then ns.openAchievements(achievement)
    elseif id then ns.open(id) end
  end)
end

-- Lays out the text beside the picture, or from the edge without one.
local function fill(kicker, title, hasPicture)
  banner.kicker:ClearAllPoints()
  banner.title:ClearAllPoints()
  local left = hasPicture and 70 or 18
  banner.kicker:SetPoint("TOPLEFT", left, -15)
  banner.title:SetPoint("TOPLEFT", banner.kicker, "BOTTOMLEFT", 0, -4)
  banner.title:SetPoint("RIGHT", -34, 0)
  banner.kicker:SetText(kicker)
  banner.title:SetText(title)
  banner:Show()
  startTimer()
end

-- ── the game's toasts ─────────────────────────────────────────────────────────
local PAGE_TOAST, ACHIEVEMENT_TOAST = "NewRecipeLearnedAlertFrameTemplate", "AchievementAlertFrameTemplate"
local BOOK = "Interface\\Icons\\INV_Misc_Book_09"
local pageToasts, achievementToasts

-- How long a toast stays: the banner's setting (0: until read or dismissed).
local function duration()
  local seconds = ns.option("bannerSeconds") or 10
  return seconds > 0 and seconds or 3600
end

local function onToastClick(self, button, down)
  if AlertFrame_OnClick and AlertFrame_OnClick(self, button, down) then return end -- right-click: dismissed
  if self.codexAchievement then ns.openAchievements(self.codexAchievement)
  elseif self.codexPage then ns.open(self.codexPage) end
end

local function setUpPage(frame, id)
  local e = C.entries[id]
  frame.codexPage, frame.codexAchievement = id, nil
  -- Round, as the book's pictures: a mask texture (Texture:SetMask, the
  -- recipe toast's own way, forbids changing the crop afterwards on Forever).
  if not frame.codexMask and frame.CreateMaskTexture then
    frame.codexMask = frame:CreateMaskTexture()
    frame.codexMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    frame.codexMask:SetAllPoints(frame.Icon)
    frame.Icon:AddMaskTexture(frame.codexMask)
  end
  if e.portrait and SetPortraitTextureFromCreatureDisplayID then
    frame.Icon:SetTexCoord(0, 1, 0, 1)
    SetPortraitTextureFromCreatureDisplayID(frame.Icon, e.portrait)
  else
    frame.Icon:SetTexture(ns.kindIcon(e.kind) or BOOK)
    frame.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  end
  frame.Title:SetText("A new page in the codex")
  frame.Name:SetText(e.title)
  if AlertFrame_SetDuration then AlertFrame_SetDuration(frame, duration()) end
  frame:SetScript("OnClick", onToastClick)
end

local function setUpAchievement(frame, id)
  local a = ns.achievementById[id]
  frame.codexPage, frame.codexAchievement = nil, id
  frame.Icon.Texture:SetTexture(BOOK)
  frame.Unlocked:SetText("Codex achievement")
  frame.Name:SetText(a.title)
  frame.Shield:Hide() -- no points
  if AlertFrame_SetDuration then AlertFrame_SetDuration(frame, duration()) end
  frame:SetScript("OnClick", onToastClick)
end

-- The toast systems, made on first use, where the client has them.
-- The achievement toast's points shield runs AchievementShield_OnLoad, from
-- the game's achievement window, which the game loads only when first opened:
-- load it (as the game does before its own toasts), or use our banner.
local function shieldReady()
  if AchievementShield_OnLoad then return true end
  local load = (C_AddOns and C_AddOns.LoadAddOn) or LoadAddOn
  if load then pcall(load, "Blizzard_AchievementUI") end
  return AchievementShield_OnLoad ~= nil
end

local function toasts()
  if pageToasts then return true end
  if not (AlertFrame and AlertFrame.AddQueuedAlertFrameSubSystem and C_XMLUtil and C_XMLUtil.GetTemplateInfo) then return false end
  if not C_XMLUtil.GetTemplateInfo(PAGE_TOAST) then return false end
  pageToasts = AlertFrame:AddQueuedAlertFrameSubSystem(PAGE_TOAST, setUpPage, 2, 6)
  if C_XMLUtil.GetTemplateInfo(ACHIEVEMENT_TOAST) and shieldReady() then
    achievementToasts = AlertFrame:AddQueuedAlertFrameSubSystem(ACHIEVEMENT_TOAST, setUpAchievement, 2, 6)
  end
  return true
end

-- ── showing ──────────────────────────────────────────────────────────────────
function ns.showBanner(id)
  if not ns.option("banner") or not C.entries[id] then return end
  if toasts() then
    pageToasts:AddAlert(id)
    return
  end
  if not banner then build() end
  -- A page found while it shows replaces it (the other waits in the book,
  -- marked unread).
  banner.id, banner.achievement = id, false
  fill("A new page in the codex", C.entries[id].title, ns.pagePicture(banner.picture, C.entries[id]))
end

function ns.showAchievementBanner(id)
  local a = ns.achievementById[id]
  if not ns.option("banner") or not a then return end
  if toasts() and achievementToasts then
    achievementToasts:AddAlert(id)
    return
  end
  if not banner then build() end
  banner.id, banner.achievement = false, id
  banner.picture:Show()
  banner.picture.tex:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
  banner.picture.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  fill("Achievement earned", a.title, true)
end

function ns.hideBanner()
  stopTimer()
  if banner then banner:Hide() end
end
