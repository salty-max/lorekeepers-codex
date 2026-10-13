# Localizing the Codex: the plan

Proposed 13 October 2026, not started. The unlocks already work in every
client language (area ids, creature ids, book titles in every language); the
words do not.

## How the game loads one language

Since retail 11.2.0, a TOC can name a file with the client's language in it:
`Text_Classic_[TextLocale].lua` loads `Text_Classic_frFR.lua` on a French
client and nothing else. Classic Era should have it from 1.15.8 and Forever
too: the wiki's patch tables say those builds carry 11.2.0, though no page
says so outright. A two-line test addon confirms it in each game before
anything is built on it. TBC Anniversary is not known to: its TOC stays
English.

So: **one package, one folder, the client picking its own language file.** No
language packs:

- Packs as sub-addons are what addons did before the TOC could choose: extra
  folders to keep at the same version, extra lines in the addon list, a pack
  forgotten or left stale, code to load them on demand. Shipped in the same
  zip, they are one package anyway, with more ways to break.
- Everything in one file would load eight languages on every client (the
  English text alone is about 500 KB a game).

With `[TextLocale]`, only the client's language loads, and an English client
loads exactly what it does today.

## Layout

- `content/` stays the source of truth, in English. Unlock rules live there
  only.
- `i18n/<locale>/<chapter>/<id>.md`: a translated page, its title and
  paragraphs (`[horde]`, `[forever]` and the rest kept), with the hash of the
  English page it was made from. The build calls a translation **stale**
  when its English page changed since, and `--check` lists them.
- `i18n/<locale>/ui.json`: the interface's words (tabs, buttons, chat lines,
  the welcome, the settings). The code reads every visible string through
  `L[...]`, English by default.
- `scripts/build.ts` writes `Text_<game>_<locale>.lua` per language (titles,
  paragraphs, the interface's words), and a stub for a language not
  translated yet, so the TOC never names a missing file. A page missing from
  a translation shows in English.
- The ASCII rule stays for English; a translation may use its language's
  letters (accents, Cyrillic, CJK) and typography, still never curly quotes
  where the game's fonts lack them. The kit already picks fonts by locale
  (the body font is the game's `STANDARD_TEXT_FONT`, Morpheus for Latin
  languages only).

## Names: what the player sees in their game

A page must call a place, a figure or a book what the player's client calls
it. A glossary per language, from the game's own data: places (AreaTable per
locale, wago.tools), creatures and figures (Wowhead's localized tooltips,
already used for the books' titles), items, factions. Translations use it;
the build warns when a glossary term's English form is left in a translation.

## Who translates

The product is the text, Archesonus's voice and Parqual's. A translation per
language, chapter by chapter, with a voice guide for that language (her warm,
dry court register; his cutting asides) and the glossary. About 55,000 words
and 27 notes per language, plus the interface.

Review: French by the user. Other languages by native readers where any
volunteer (an issue per language, "corrections welcome"); else shipped as a
first translation, said so on the store page.

## Order

1. The test addon (`[TextLocale]` in Classic Era and Forever); then the
   interface's words through `L[...]`, and the pipeline (English only:
   nothing changes for an English client).
2. French (reviewed by the user), German, Spanish (esES, also given to esMX).
3. Russian, Portuguese (ptBR), Italian.
4. Korean, Chinese (zhTW, zhCN): longer to review, their own typography.

Then the same for Yonder and Second Wind. Hearthtale writes its entries from
phrase tables in English grammar: a much bigger job, last.
