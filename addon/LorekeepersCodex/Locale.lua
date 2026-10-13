-- The reader's language. The client loads its own Text_<locale>.lua (the
-- TOCs name Text_[TextLocale].lua; scripts/locales.ts writes them from
-- i18n/), which hands its words, chapters and pages to ns.translate; English
-- stays wherever it says nothing. Loaded before any file reads a word.
local _, ns = ...
local K = ns.kit

-- (is n the "one" form? English, German, Spanish, Italian: 1; French and
-- Brazilian Portuguese: 0 and 1; Russian: 1, 21, 31... but not 11; Korean
-- and Chinese have one form)
local PLURALS = {
  one = function(n) return n == 1 end,
  fr = function(n) return n == 0 or n == 1 end,
  ru = function(n) return n % 10 == 1 and n % 100 ~= 11 end,
  none = function() return false end,
}

-- A plain replacement (names hold the pattern characters: "Comte-du-Lac").
local function replace(s, from, to)
  local out, i = {}, 1
  while true do
    local a, b = s:find(from, i, true)
    if not a then break end
    out[#out + 1] = s:sub(i, a - 1)
    out[#out + 1] = to
    i = b + 1
  end
  out[#out + 1] = s:sub(i)
  return table.concat(out)
end

function ns.translate(t)
  ns.locale = t.locale
  K.isOne = PLURALS[t.plural] or K.isOne
  local C = ns.content
  -- every translated word passes here: the reader's gender (the game's own
  -- token, $gmasculine:feminine;) and, on Classic, its own names for the
  -- places Forever renamed (a translation is written with Forever's)
  local female = UnitSex and UnitSex("player") == 3
  local swaps = C.client == "classic" and t.classic or nil
  local function words(s)
    if type(s) ~= "string" then return s end
    s = s:gsub("%$g([^:;]*):([^;]*);", function(m, f) return female and f or m end)
    for _, pair in ipairs(swaps or {}) do
      if s:find(pair[1], 1, true) then s = replace(s, pair[1], pair[2]) end
    end
    return s
  end
  local L = K.L
  for english, word in pairs(t.words or {}) do
    L[english] = words(word)
  end
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
