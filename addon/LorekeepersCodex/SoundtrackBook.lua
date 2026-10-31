-- The Soundtrack's tab: on the left the tunes (Soundtrack.lua) under their
-- groups, a tune not yet found as "???"; on the right (the kit's page) a found
-- tune: its line of lore, where and when it was found, and its tracks, each
-- with a button that plays it (PlayMusic loops until Stop). Before one is
-- picked, the soundtrack at a glance. A tune is found by standing where it
-- plays with the music on, not by hearing it: the page says so.
local _, ns = ...
local L = ns.kit.L
local C = ns.content
local ui = ns.ui

local book, list, page
local current -- a tune's id, or nil: the soundtrack at a glance
local rows = {}
ns.soundtrackRows = rows -- for the tests

local ICON = "Interface\\Icons\\INV_Misc_Horn_01"
local GROUPS = {
  { "lands", L["The Lands"] },
  { "cities", L["Cities and Taverns"] },
  { "moments", L["Moments"] },
  { "depths", L["Dungeons and Raids"] },
}

local function folded()
  local c = ns.codex()
  if not c then return {} end
  c.soundtrackFolded = c.soundtrackFolded or {}
  return c.soundtrackFolded
end

local function style(r, kind)
  r:Enable()
  if kind == "overview" then
    r.text:SetPoint("LEFT", 4, 0)
    r.text:SetPoint("RIGHT", -4, 0)
    r.text:SetFont(ui.TITLE_FONT, 14, "")
    r.text:SetTextColor(unpack(ui.T.gold))
    return 22
  elseif kind == "group" then
    r.fold:SetPoint("LEFT", 2, 0)
    r.fold:Show()
    r.count:SetPoint("RIGHT", -4, 0)
    r.count:SetJustifyH("RIGHT")
    r.text:SetPoint("LEFT", 18, 0)
    r.text:SetPoint("RIGHT", -40, 0)
    r.text:SetFont(ui.TITLE_FONT, 14, "")
    r.text:SetTextColor(unpack(ui.T.gold))
    return 22
  end
  r.text:SetPoint("LEFT", 18, 0)
  r.text:SetPoint("RIGHT", -4, 0)
  r.text:SetFont(ui.BODY_FONT, 12, "")
  r.text:SetTextColor(unpack(ui.T.text))
  return 18
end

local function groupOf(id) return C.entries[id].group or "lands" end
local function titleOf(id) return ns.tune(id) and C.entries[id].title or L["???"] end

local function foundLine(rec)
  local zone, sub = ns.placeNames(rec)
  local where = zone or "?"
  if sub then where = sub .. ", " .. where end
  return ns.fmt(L["Tune found in %1$s, at level %2$d, on %3$s."], where, rec.level or 0, ui.day(rec.at))
end

local function groupName(key)
  for _, g in ipairs(GROUPS) do
    if g[1] == key then return g[2] end
  end
  return ""
end

local showTune, showOverview, refreshList

-- the tune's tracks as the buttons that play them, and the one that stops
local function playButtons(id)
  local out, day, night, arrival = {}, 0, 0, 0
  for _, t in ipairs(ns.tracksOf(id)) do
    local label
    if t[2] == "arrival" then
      arrival = arrival + 1
      label = L["Arrival %d"]:format(arrival)
    elseif t[2] == "night" then
      night = night + 1
      label = L["Night %d"]:format(night)
    elseif t[2] == "day" then
      day = day + 1
      label = L["Day %d"]:format(day)
    else
      day = day + 1
      label = L["Track %d"]:format(day)
    end
    local file = t[1]
    table.insert(out, { label, function() ns.playTrack(id, file) end })
  end
  table.insert(out, { L["Stop"], function() ns.stopMusic() end })
  return out
end

function showTune(id)
  current = id
  local e = C.entries[id]
  if not e then return end
  if not ns.tune(id) then
    page:start(L["???"], L["Not found yet"], ui.icon(ICON))
    page:paragraph(
      L["A tune of the game's music. Stand where it plays, with the music on, and it is yours to play again."],
      ui.T.soft
    )
    page:finish()
    return
  end
  page:start(e.title, groupName(groupOf(id)), ui.icon(ICON))
  local paras = {}
  for _, para in ipairs(e.text) do
    if ns.shown(para) then table.insert(paras, para[1]) end
  end
  page:text(paras)
  page:section(L["Play it again"])
  if not ns.musicOn() then page:paragraph(L["The game's music is switched off in your sound options."], ui.T.soft) end
  page:buttons(playButtons(id))
  page:paragraph(foundLine(ns.tune(id)), ui.T.soft)
  page:finish()
end

function showOverview()
  current = nil
  page:start(L["The Soundtrack"], L["%d of %d tunes found"]:format(ns.tuneCount(), #ns.tunes), ui.icon(ICON))
  page:stats({ { tostring(ns.tuneCount()), L["tunes found"] }, { tostring(#ns.tunes), L["tunes in all"] } })
  page:paragraph(
    L["The tunes of the game's music, found by standing where they play with the music on. The game never tells which track is playing, so a tune is found, not heard: stay a little while, and it is written here. Found, a tune plays again from this page."],
    ui.T.soft
  )
  local recent = {}
  for _, id in ipairs(ns.tunes) do
    local rec = ns.tune(id)
    if rec then table.insert(recent, { id = id, at = rec.at or 0 }) end
  end
  table.sort(recent, function(a, b) return a.at > b.at end)
  if #recent > 0 then
    page:section(L["Tunes found lately"])
    for i = 1, math.min(5, #recent) do
      local id = recent[i].id
      page:card(C.entries[id].title, groupName(groupOf(id)), ui.icon(ICON), function()
        showTune(id)
        refreshList()
      end)
    end
  end
  local now = ns.nowPlaying()
  if now then
    page:section(L["Playing"])
    page:buttons({ { L["Stop"], function() ns.stopMusic() end } })
  end
  page:finish()
end

function refreshList()
  list:begin()
  local query = ns.kit.query(book.search)
  local searching = query ~= ""
  if not searching then
    local r = list:add("overview", L["The Soundtrack"])
    if current == nil then list:pick(r) end
    r:SetScript("OnClick", function()
      showOverview()
      refreshList()
    end)
    list:gap(2)
  end
  local any = false
  for _, g in ipairs(GROUPS) do
    local ids, found = {}, 0
    for _, id in ipairs(ns.tunes) do
      if groupOf(id) == g[1] then
        if ns.tune(id) then found = found + 1 end
        -- (a search matches the tunes found only: the others are not named)
        if not searching or (ns.tune(id) and ns.kit.plain(C.entries[id].title):find(query, 1, true)) then
          table.insert(ids, id)
        end
      end
    end
    if #ids > 0 then
      any = true
      local r = list:add("group", g[2], ("%d/%d"):format(found, #ids))
      local open = searching or not folded()[g[1]]
      ns.kit.fold(r, open)
      r:SetScript("OnClick", function()
        folded()[g[1]] = not folded()[g[1]] or nil
        refreshList()
      end)
      if open then
        for _, id in ipairs(ids) do
          local e = list:add("tune", titleOf(id))
          e.id = id
          e:SetScript("OnClick", function()
            showTune(id)
            refreshList()
          end)
          if id == current then list:pick(e) end
        end
      end
    end
  end
  if not any then list:add("tune", L["No tune found."]):SetScript("OnClick", nil) end
  list:finish(false)
end

local function refresh()
  book.count:SetText(L["%d of %d tunes"]:format(ns.tuneCount(), #ns.tunes))
  refreshList()
  if current then
    showTune(current)
  else
    showOverview()
  end
end

local function build(b)
  book = b
  list = ns.kit.list(book.left, style, rows, false, "LorekeepersCodexSoundtrackList")
  page = ui.pageArea("LorekeepersCodexSoundtrackPage", book)
end

local function show(n)
  list:SetShown(n == ns.TAB.soundtrack)
  page:SetShown(n == ns.TAB.soundtrack)
end

-- (its tab clicked: the soundtrack at a glance)
local function chosen() current = nil end

-- the link in chat opens the book at a tune
function ns.openTune(id)
  current = id
  ns.openTab(ns.TAB.soundtrack)
end

ns.addTab(ns.TAB.soundtrack, { build = build, show = show, refresh = refresh, chosen = chosen })
