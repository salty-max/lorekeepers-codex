-- The welcome (the kit's, Kit.lua): once per character, a few seconds after
-- its first login (out of combat; /codex welcome shows it again), laid out as
-- the codex's window: on the left the logo and what the codex is; on the
-- right this character's choices (Settings.lua: the alert for a new page,
-- the chat line, its sound, the tooltip hints, the minimap button), then
-- another character's to take, chosen among this game's or brought by a code
-- (/codex export there). Closing it, however, is enough to have seen it.
local _, ns = ...
local K = ns.kit

local W = K.welcome({
  name = "LorekeepersCodexWelcome",
  title = "Welcome to Lorekeeper's Codex",
  art = "Interface\\Icons\\INV_Misc_Book_09",
  logo = "Interface\\AddOns\\LorekeepersCodex\\Media\\Logo",
  heading = "Lorekeeper's Codex",
  tagline = "The lore of Azeroth, written for you as you explore.",
  intro = "An archivist of the Explorers' League has left you a ledger. Walk into a land, meet a figure of "
    .. "legend, defeat a people's warriors or finish the right quest, and a page of history is added.\n\n"
    .. "Each character keeps its own codex, with the day and the place each page was found. The Library "
    .. "copies every book, note and plaque you read, and achievements mark the way.",
  profiles = ns.profiles,
  choices = function()
    local sounds = {}
    for _, s in ipairs(ns.SOUNDS) do
      table.insert(sounds, { value = s[1], text = s[2] })
    end
    return {
      {
        text = "An alert for each new page",
        hint = "The game's own alert, with the page's picture; a click on it reads the page.",
        get = function() return ns.option("banner") end,
        set = function(v) ns.setOption("banner", v) end,
      },
      {
        text = "A line in chat for each new page",
        hint = "With a link that opens it.",
        get = function() return ns.option("chat") end,
        set = function(v) ns.setOption("chat", v) end,
      },
      {
        text = "Sound for a new page",
        hint = "Heard with each page found.",
        options = sounds,
        get = function() return ns.option("sound") end,
        set = function(v)
          ns.setOption("sound", v)
          ns.playSound(v)
        end,
      },
      {
        text = "Hints on tooltips",
        hint = "On a creature or a player with a page for you to find.",
        get = function() return ns.option("tooltipHints") end,
        set = function(v) ns.setOption("tooltipHints", v) end,
      },
      {
        text = "The book by the minimap",
        hint = "Click it to open the codex; drag it around the minimap.",
        get = function() return not ns.option("minimapHidden") end,
        set = function(v) ns.setOption("minimapHidden", not v) end,
      },
    }
  end,
  footnote = "Change them any time: /codex settings, or a right-click on the minimap button. /codex opens the book.",
  open = { text = "Open the codex", click = function() ns.toggle() end },
  exportHint = "Copy it (Ctrl+C), then on another character: Use a code, or /codex import CODE.",
  importHint = "Paste the code (/codex export on the other character), then press Enter.",
  refused = "That isn't a Lorekeeper's Codex settings code.",
})

-- The welcome; "export": with this character's code ready to copy.
ns.welcome = W -- (its frame, rows, picker and code: for the tests)
function ns.showWelcome(mode) W:Show(mode) end

K.welcomeOnce(W, ns.profiles, function() return ns.codex() ~= nil end)
