-- A banner at the top centre of the screen when a page is found, in the
-- manner of the game's zone text: "A new page for the codex", then the page's
-- title. It fades in, holds, fades out; finds in a row queue up. Click it to
-- open the page. /codex banner turns it off (LorekeepersCodexSettings.banner).
local _, ns = ...
local C = ns.content

local FADE_IN, HOLD, FADE_OUT = 0.4, 4, 1.2
local banner
local queue = {}

local function enabled()
  LorekeepersCodexSettings = LorekeepersCodexSettings or {}
  return LorekeepersCodexSettings.banner ~= false
end

local function build()
  banner = CreateFrame("Button", "LorekeepersCodexBanner", UIParent)
  banner:SetSize(600, 80)
  banner:SetPoint("TOP", 0, -140)
  banner:SetFrameStrata("HIGH")
  banner:Hide()

  banner.line = banner:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  banner.line:SetPoint("TOP", 0, 0)
  banner.line:SetText("A new page for the codex")
  banner.line:SetTextColor(0.8, 0.7, 0.45)

  banner.title = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
  banner.title:SetPoint("TOP", banner.line, "BOTTOM", 0, -6)
  banner.title:SetTextColor(1, 0.82, 0)

  banner:SetScript("OnClick", function(self)
    if self.id then ns.open(self.id) end
  end)
  banner:SetScript("OnUpdate", function(self, elapsed)
    self.t = self.t + elapsed
    local t = self.t
    if t < FADE_IN then
      self:SetAlpha(t / FADE_IN)
    elseif t < FADE_IN + HOLD then
      self:SetAlpha(1)
    elseif t < FADE_IN + HOLD + FADE_OUT then
      self:SetAlpha(1 - (t - FADE_IN - HOLD) / FADE_OUT)
    else
      self:Hide()
      local nextId = table.remove(queue, 1)
      if nextId then ns.showBanner(nextId) end
    end
  end)
end

function ns.showBanner(id)
  if not enabled() or not C.entries[id] then return end
  if not banner then build() end
  if banner:IsShown() then
    table.insert(queue, id)
    return
  end
  banner.id = id
  banner.title:SetText(C.entries[id].title)
  banner.t = 0
  banner:SetAlpha(0)
  banner:Show()
end

-- /codex banner: turn it off or on.
function ns.toggleBanner()
  LorekeepersCodexSettings = LorekeepersCodexSettings or {}
  LorekeepersCodexSettings.banner = not enabled()
  if not LorekeepersCodexSettings.banner and banner then
    wipe(queue)
    banner:Hide()
  end
  return LorekeepersCodexSettings.banner
end
