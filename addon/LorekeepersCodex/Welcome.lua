-- The welcome (the kit's, Kit.lua): once per character, a few seconds after
-- its first login (out of combat; /codex welcome shows it again), laid out as
-- the codex's window: on the left the logo and what the codex is; on the
-- right this character's choices (Settings.lua: the alert for a new page,
-- the chat line, its sound, the tooltip hints, the minimap button), then
-- another character's to take, chosen among this game's or brought by a code
-- (/codex export there). Closing it, however, is enough to have seen it.
local _, ns = ...
local L = ns.kit.L
local K = ns.kit

local W = K.welcome({
  name = "LorekeepersCodexWelcome",
  title = L["Welcome to Lorekeeper's Codex"],
  art = "Interface\\AddOns\\LorekeepersCodex\\Media\\Logo",
  logo = "Interface\\AddOns\\LorekeepersCodex\\Media\\Logo",
  heading = "Lorekeeper's Codex",
  tagline = L["The lore of Azeroth, written for you as you explore."],
  -- (the ledger's sender, the reader's side's: Core.lua's ns.side)
  intro = function()
    return (
      ns.side() == "Horde" and L["Parqual Fintallas, a historian of the Undercity, has sent you a ledger."]
      or L["Archesonus, Royal Historian of Ironforge, has left you a ledger."]
    )
      .. " "
      .. L["Walk into a land, meet a figure of legend, defeat a people's warriors or finish the right quest, and a page of history is added."]
      .. "\n\n"
      .. L["Each character keeps its own codex, with the day and the place each page was found. The Library copies every book, note and plaque you read, and achievements mark the way."]
  end,
  profiles = ns.profiles,
  choices = function()
    local sounds = {}
    for _, s in ipairs(ns.SOUNDS) do
      table.insert(sounds, { value = s[1], text = s[2] })
    end
    return {
      {
        text = L["An alert for each new page"],
        hint = L["The game's own alert, with the page's picture. A click on it reads the page."],
        get = function() return ns.option("banner") end,
        set = function(v) ns.setOption("banner", v) end,
      },
      {
        text = L["An alert for each achievement"],
        hint = L["The game's achievement alert. A click on it opens the achievements."],
        get = function() return ns.option("achievementToast") end,
        set = function(v) ns.setOption("achievementToast", v) end,
      },
      {
        text = L["Sound for a new page"],
        hint = L["Heard with each page found."],
        options = sounds,
        get = function() return ns.option("sound") end,
        set = function(v)
          ns.setOption("sound", v)
          ns.playSound(v)
        end,
      },
      {
        text = L["Hints on tooltips"],
        hint = L["On a creature or a player with a page for you to find."],
        get = function() return ns.option("tooltipHints") end,
        set = function(v) ns.setOption("tooltipHints", v) end,
      },
      {
        text = L["The book by the minimap"],
        hint = L["Click it to open the codex, or drag it around the minimap."],
        get = function() return not ns.option("minimapHidden") end,
        set = function(v) ns.setOption("minimapHidden", not v) end,
      },
      K.collectChoice(ns.collect),
    }
  end,
  footnote = L["Change them any time: /codex settings, or a right-click on the minimap button. /codex opens the book."],
  open = { text = L["Open the codex"], click = function() ns.toggle() end },
  exportHint = L["Copy it (Ctrl+C), then on another character: Use a code, or /codex import CODE."],
  importHint = L["Paste the code (/codex export on the other character), then press Enter."],
  refused = L["That isn't a Lorekeeper's Codex settings code."],
})

-- The welcome; "export": with this character's code ready to copy.
ns.welcome = W -- (its frame, rows, picker and code: for the tests)
function ns.showWelcome(mode) W:Show(mode) end

K.welcomeOnce(W, ns.profiles, function() return ns.codex() ~= nil end)
