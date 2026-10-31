-- The reader's language. The client loads its own Text_<locale>.lua (the
-- TOCs name Text_[TextLocale].lua; scripts/locales.ts writes them from
-- i18n/), which hands its words, chapters and pages to ns.translate (English
-- stays wherever it says nothing) and the game's names in its language to
-- ns.names. Loaded before any file reads a word.
local _, ns = ...
local K = ns.kit

-- A sentence's blanks filled in, in the order its language puts them: the
-- blanks are numbered ("%1$s, %2$d") so a translation may move them, which
-- LuaJIT's format can't read (the game's can). Second Wind's ns.fmt.
function ns.fmt(s, ...)
  if not s:find("%%%d%$") then return s:format(...) end
  local args, order = { ... }, {}
  local plain = s:gsub("%%(%d)%$", function(i)
    table.insert(order, args[tonumber(i)])
    return "%"
  end)
  return plain:format(unpack(order))
end

-- The game's names in the client's language (its Text file's, every
-- language's, English one of them): the places inside buildings by their ids,
-- this game's.
function ns.names(t)
  local classic = ns.content.client == "classic"
  ns.insideNames = (classic and t.insideClassic or t.inside) or {}
  -- the Library's titles by their texts' ids, this game's
  ns.textTitlesById = (classic and t.titlesClassic or t.titles) or {}
end

function ns.translate(t)
  ns.locale = t.locale
  local C = ns.content
  -- every translated word passes here (the kit's): the reader's gender (the
  -- game's own token, $gmasculine:feminine;) and, on Classic, its own names
  -- for the places Forever renamed (a translation is written with Forever's),
  -- the longest first
  local swaps = C.client == "classic" and t.classic or nil
  local function words(s) return K.swap(K.agree(s), swaps) end
  -- the game's own texts (a copy made in another language reads in this one),
  -- through the same words: the reader's gender, Classic's own names
  local books = {}
  local byId = {}
  for title, variants in pairs(t.books or {}) do
    local mine = {}
    for i, v in ipairs(variants) do
      local pages = {}
      for p, page in ipairs(v.pages) do
        pages[p] = words(page)
      end
      mine[i] = { ids = v.ids, first = v.first, pages = pages }
      for _, id in ipairs(v.ids or {}) do
        local canonical = ns.textSources and ns.textSources.canonical[id] or id
        byId[canonical] = pages
      end
    end
    books[title] = mine
  end
  ns.bookTexts = books
  ns.booksById = byId
  K.translate(t, { swaps = swaps })
  for _, ch in ipairs(C.chapters) do
    local tr = t.chapters and t.chapters[ch.id]
    if tr then
      ch.title, ch.summary = words(tr[1]) or ch.title, words(tr[2]) or ch.summary
    end
  end
  -- a page: its title, and its paragraphs for this game (a translation
  -- holds both games', as the English source does)
  for id, tr in pairs(t.pages or {}) do
    local e = C.entries[id]
    if e then
      e.title = words(tr.title) or e.title
      if tr.text then
        local text = {}
        for _, para in ipairs(tr.text) do
          if not para.client or para.client == C.client then
            para.client = nil
            para[1] = words(para[1])
            table.insert(text, para)
          end
        end
        e.text = text
      end
    end
  end
end
