-- The Achievements tab, over both panels: each achievement under its group's
-- heading (Achievements.lua), the title gold once earned, what it asks, and on
-- the right when it was earned, or how far along it is.
local _, ns = ...
local ui = ns.ui
local T, TITLE_FONT, BODY_FONT = ui.T, ui.TITLE_FONT, ui.BODY_FONT
local label, rule, bar = ui.label, ui.rule, ui.bar

local book, achievements

local GROUPS = {
  { "milestone", "Milestones" },
  { "feat", "Feats" },
  { "encounter", "Encounters" },
  { "library", "The Library" },
  { "chapter", "Chapters" },
}
local ROW = 50
local ACH_WIDTH = 700
local achRows, headers = {}, {}
local selected

local function achRow(i)
  local r = achRows[i]
  if r then return r end
  r = CreateFrame("Frame", nil, achievements.child)
  r:SetSize(ACH_WIDTH, ROW - 4)
  r.bg = r:CreateTexture(nil, "BACKGROUND")
  r.bg:SetAllPoints()
  r.title = label(r, TITLE_FONT, 15, T.gold)
  r.title:SetPoint("TOPLEFT", 12, -7)
  r.text = label(r, BODY_FONT, 11, T.soft)
  r.text:SetPoint("TOPLEFT", r.title, "BOTTOMLEFT", 0, -5)
  r.text:SetWidth(500)
  r.status = label(r, BODY_FONT, 11, T.soft)
  r.status:SetPoint("TOPRIGHT", -12, -8)
  r.status:SetJustifyH("RIGHT")
  r.bar = bar(r)
  r.bar:SetSize(150, 5)
  r.bar:SetPoint("TOPRIGHT", r.status, "BOTTOMRIGHT", 0, -7)
  achRows[i] = r
  return r
end

local function header(i)
  local h = headers[i]
  if h then return h end
  h = CreateFrame("Frame", nil, achievements.child)
  h:SetSize(ACH_WIDTH, 26)
  h.text = label(h, TITLE_FONT, 17, T.gold)
  h.text:SetPoint("BOTTOMLEFT", 2, 5)
  h.line = rule(h)
  h.line:SetPoint("BOTTOMLEFT")
  h.line:SetPoint("BOTTOMRIGHT")
  headers[i] = h
  return h
end

local function refresh()
  book.count:SetText(("%d of %d achievements"):format(ns.achievementCount()))
  local i, y, selectedY = 0, 0, nil
  for g, group in ipairs(GROUPS) do
    local h = header(g)
    h:ClearAllPoints()
    h:SetPoint("TOPLEFT", 0, -y)
    h.text:SetText(group[2])
    y = y + 34
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
          r.title:SetTextColor(unpack(T.gold))
          r.text:SetTextColor(unpack(T.text))
          r.status:SetText(("Level %d, %s"):format(earned.level or 0, date("%d %b %Y", earned.at or 0)))
          r.bar:Hide()
        else
          r.title:SetTextColor(unpack(T.dim))
          r.text:SetTextColor(unpack(T.soft))
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
        if a.id == selected then
          r.bg:SetColorTexture(T.gold[1], T.gold[2], T.gold[3], 0.22)
        elseif earned then
          r.bg:SetColorTexture(T.bar[1], T.bar[2], T.bar[3], 0.10)
        else
          r.bg:SetColorTexture(1, 1, 1, 0.03)
        end
        r:Show()
        y = y + ROW
      end
    end
    y = y + 12
  end
  for k = i + 1, #achRows do
    achRows[k]:Hide()
  end
  achievements.child:SetHeight(y)
  achievements:UpdateThumb()
  -- An achievement opened from chat or the banner: bring it into view.
  if selectedY then
    local height = achievements:GetHeight()
    local max = math.max(0, y - height)
    achievements:SetVerticalScroll(math.min(max, math.max(0, selectedY - (height - ROW) / 2)))
    achievements:UpdateThumb()
  end
end

local function build(b)
  book = b
  book.achPanel = ui.panel(book)
  book.achPanel:SetPoint("TOPLEFT", 8, -58)
  book.achPanel:SetPoint("BOTTOMRIGHT", -8, 8)
  achievements = ui.scrollArea(book.achPanel, ACH_WIDTH, "LorekeepersCodexAchievements")
  achievements:SetPoint("TOPLEFT", 22, -18)
  achievements:SetPoint("BOTTOMRIGHT", -22, 14)
end

local function show(n)
  book.achPanel:SetShown(n == ns.TAB.achievements)
  achievements:SetShown(n == ns.TAB.achievements)
end

-- (its tab clicked: none picked out)
local function chosen() selected = nil end

ns.addTab(ns.TAB.achievements, { build = build, show = show, refresh = refresh, chosen = chosen, whole = true })

-- Open the book at the achievements, one of them picked out.
function ns.openAchievements(id)
  selected = id
  ns.openTab(ns.TAB.achievements)
end
