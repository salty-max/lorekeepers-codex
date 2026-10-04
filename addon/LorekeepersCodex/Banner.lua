-- A slim banner at the top centre of the screen when a page is found: the
-- page's title, with a book button (or a click anywhere on it) to read the
-- page and a close button. It goes away on its own after a few seconds
-- (bannerSeconds in the settings, 0 to keep it until read or closed), never
-- while the mouse is on it; a page found meanwhile replaces it. Turned off in
-- the settings or with /codex banner.
local _, ns = ...
local C = ns.content

local WIDTH, HEIGHT = 420, 52
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

local function build()
  banner = CreateFrame("Button", "LorekeepersCodexBanner", UIParent, "BackdropTemplate")
  banner:SetSize(WIDTH, HEIGHT)
  banner:SetPoint("TOP", 0, -36)
  banner:SetFrameStrata("HIGH")
  banner:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
  })
  banner:Hide()

  banner.title = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  banner.title:SetPoint("LEFT", 60, 0)
  banner.title:SetPoint("RIGHT", -60, 0)
  banner.title:SetWordWrap(false)

  local close = CreateFrame("Button", nil, banner, "UIPanelCloseButton")
  close:SetPoint("RIGHT", -8, 0)
  close:SetScript("OnClick", function() ns.hideBanner() end)

  local read = CreateFrame("Button", nil, banner)
  read:SetSize(22, 22)
  read:SetPoint("RIGHT", close, "LEFT", -2, 0)
  read:SetNormalTexture("Interface\\Icons\\INV_Misc_Book_09")
  read:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
  read:SetScript("OnClick", function() banner:Click() end)
  read:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:AddLine("Read this page")
    GameTooltip:Show()
  end)
  read:SetScript("OnLeave", function() GameTooltip:Hide() end)

  banner:SetScript("OnClick", function(self)
    local id = self.id
    ns.hideBanner()
    if id then ns.open(id) end
  end)
end

function ns.showBanner(id)
  if not ns.option("banner") or not C.entries[id] then return end
  if not banner then build() end
  -- A page found while it shows replaces it (the other waits in the book,
  -- marked unread).
  banner.id = id
  banner.title:SetText(C.entries[id].title)
  banner:Show()
  startTimer()
end

function ns.hideBanner()
  stopTimer()
  if banner then banner:Hide() end
end
