-- A banner at the top centre of the screen when a page is found: the page's
-- title and its opening lines, with a book button (or a click anywhere on it)
-- to read the page and a close button. It goes away on its own after a few
-- seconds (bannerSeconds in the settings, 0 to keep it until read or closed),
-- never while the mouse is on it; pages found meanwhile replace it, and it
-- counts them. Turned off in the settings or with /codex banner.
local _, ns = ...
local C = ns.content

local WIDTH = 640
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
  banner:SetWidth(WIDTH)
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
  banner.title:SetPoint("TOP", 0, -20)
  banner.title:SetPoint("LEFT", 70, 0)
  banner.title:SetPoint("RIGHT", -70, 0)

  banner.text = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  banner.text:SetPoint("TOPLEFT", banner.title, "BOTTOMLEFT", -50, -8)
  banner.text:SetPoint("RIGHT", -20, 0)
  banner.text:SetJustifyH("LEFT")
  banner.text:SetSpacing(2)
  banner.text:SetMaxLines(3)

  banner.more = banner:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  banner.more:SetPoint("BOTTOMRIGHT", -20, 16)

  local close = CreateFrame("Button", nil, banner, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -6, -6)
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
  -- Pages found while it shows: the newest replaces it, the others are counted
  -- (they wait in the book, marked unread).
  banner.others = banner:IsShown() and (banner.others or 0) + 1 or 0
  banner.id = id
  banner.title:SetText(C.entries[id].title)
  banner.text:SetText(C.entries[id].excerpt or "")
  banner.more:SetText(banner.others == 0 and ""
    or banner.others == 1 and "and one more page in the codex"
    or ("and %d more pages in the codex"):format(banner.others))
  banner:SetHeight(20 + banner.title:GetStringHeight() + 8 + banner.text:GetStringHeight() + 32)
  banner:Show()
  startTimer()
end

function ns.hideBanner()
  stopTimer()
  if banner then banner:Hide() end
end
