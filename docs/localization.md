# Localizing the Codex: the plan

Proposed 13 October 2026. Step 1 done the same day (the words through `L`,
`Locale.lua`, `scripts/locales.ts`, the twelve language files as stubs):
English players see no change. The unlocks already work in every
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

A page calls a place or a figure what Forever's client calls it (the user's
rule, 13 October 2026): the game the codex launches with, and what the player
sees on the map, the nameplates and in the search box. Forever's translators
renamed some places ("Forgefer", "Hurlevent", "Fossoyeuse", "Courbenclume")
and kept many English names ("Roi Magni Bronzebeard", "Distillerie
Thunderbrew", "Repaire des Frostmane"); a page keeps them too, even where the
live game has translated them since ("Barbe-de-Bronze").

On Classic Era, whose French client kept the 2005 names ("Ironforge",
"Stormwind", "Mont Blackrock"), Classic's own replace Forever's when the
language file loads (`Locale.lua`, from `i18n/<locale>/classic.json`, French
elisions included: "de Forgefer" is "d'Ironforge" there).

`python3 scripts/glossary.py <locale>` writes `i18n/<locale>/glossary.json`:
every place (zones, the places inside buildings, continents), faction, title
under a creature's name ("Explorers' League"), people and figure the English
pages name, with its name in each game (wow-data's databases, each game at its
pinned build) and `use`, the one to write: Forever's, else Classic's. Names
neither game has (later lore: Deathwing, Ulduar) are kept by hand in
`glossary-by-hand.json`, as the pages write them. And `classic.json`, the
swaps, with `classic-by-hand.json`'s, which
win ("Hurlevent" is "Stormwind" in prose, not the zone's "Cite de
Stormwind"). A name in no data (one only the prose names) follows Forever's
pattern ("Modimus Courbenclume", as Anvilmar is "Courbenclume") and is listed
for the reviewer. `bun scripts/locales.ts --check` lists the English names a
translation left where Forever translates them.

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
   French done 13 October 2026: the 203 words, 45 chapters and all 438
   pages; the user approved the voice on the Dun Morogh pilot. Names with no
   game data to check them against are listed for the reviewer.
3. Russian, Portuguese (ptBR), Italian.
4. Korean, Chinese (zhTW, zhCN): longer to review, their own typography.

Then the same for Yonder and Second Wind. Hearthtale writes its entries from
phrase tables in English grammar: a much bigger job, last.

## Library readable supplements

`python3 scripts/book_texts.py frFR` imports the browser cache, then applies
`i18n/frFR/books-supplement.json`. This tracked file preserves translations
and source corrections across cache refreshes. Each entry records its title,
the SHA-256 of the pinned English HTML page array (compact UTF-8 JSON), its
French pages and provenance. A changed English source stops the import for
review. `codex-translation` means a faithful translation written for this
addon, **not verified wording from the French game client**. `client-text-reuse`
means previously collected French pages, with any authored portions noted.

The supplement also documents source exceptions. A deprecated/test entry or
a title pointing to an unrelated page chain stays out of the catalog until
its actual text can be verified. Its recorded in-game copy remains readable.
These exceptions do not establish whether an item is obtainable on Forever.
The current decisions are in [french-readable-translations.md](french-readable-translations.md).

The complete Green Hills book reuses the four French quest chapters in order,
with a translated cover and ending. The catalog retains page boundaries and
reader tokens. Prose semicolons become commas and curly quotes become straight
quotes during import. The semicolon terminating a `$gmale:female;` token stays.

Texts sharing a title use enough letters of their English first page to tell
their openings apart. Identical English page chains share one translation.
`bun run check` verifies that the supplement's pages are shipped, rejects
bracketed English fallback bodies in the French catalog, and exercises the
three similar Twilight circulars against the generated French addon file.
