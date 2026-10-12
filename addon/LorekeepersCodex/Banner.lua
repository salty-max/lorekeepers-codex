-- When a page is found, a banner (the kit's: a card in the book's look, which
-- the game's alert stack places with its own): the page's round picture, "A
-- new page in the codex" and its title; a click reads the page. An
-- achievement earned: the game's own achievement alert (the kit's: the
-- banner where the client has none), the codex's book and "Lorekeeper's
-- Codex achievement"; a click opens the achievements. Two at a time, the others wait their turn; each
-- goes after a few seconds (bannerSeconds in the settings, 0 to keep it until
-- read or closed), never while the mouse is on it; a right-click or its cross
-- dismisses it. Turned off in the settings or with /codex banner.
local _, ns = ...
local C = ns.content

local banners, achievements
local function seconds() return ns.option("bannerSeconds") or 10 end
local function made()
  banners = banners or ns.kit.banners({ name = "LorekeepersCodexBanner", art = ns.ui.BOOK, seconds = seconds })
  achievements = achievements
    or ns.kit.achievements({ banners = banners, art = ns.ui.BOOK, say = function(m) print(ns.PREFIX .. m) end })
end
local function shown(b)
  made()
  banners:show(b)
end

function ns.showBanner(id)
  local e = C.entries[id]
  if not ns.option("banner") or not e then return end
  shown({
    picture = ns.pictureOf(e, true),
    kicker = "A new page in the codex",
    title = e.title,
    tip = "Click to read this page",
    click = function() ns.open(id) end,
    page = id,
  })
end

function ns.showAchievementBanner(id)
  local a = ns.achievementById[id]
  if not ns.option("banner") or not a then return end
  made()
  achievements:show({
    picture = ns.ui.BOOK,
    kicker = "Lorekeeper's Codex achievement",
    title = a.title,
    tip = "Click to see your achievements",
    click = function() ns.openAchievements(id) end,
    achievement = id,
  })
end

-- Every banner closed, those waiting with them.
function ns.hideBanner()
  if banners then banners:clear() end
end
