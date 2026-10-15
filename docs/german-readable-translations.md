# German readable translations

14 October 2026. The Library's books in German, as the French
(`french-readable-translations.md`): the game's own text where Wowhead's
German Forever pages have it (saved in wow-data as `books-deDE.json`), and
the rest in `i18n/deDE/books-supplement.json`, each entry with the hash of
its English source and its provenance. 391 texts under 372 titles, the same
as the French; 14 source exceptions (the French ones and the placeholder
`i226421`); 39 texts Wowhead has no page for in any language.

## Translations supplied

Our wording, not the German client's (`codex-translation`), in the game's
formal "Ihr", its names from wow-data (the Horde's ranks from the client's
own strings: Zornbringer, Klinge der Horde, Feldherr, Sturmreiter,
Kriegsherr):

- No German page on Wowhead: the five Scarlet Crusade plaques (`o175773`,
  `o175774`, `o175775`, `o175777`, `o175781`), Nostro's Compendium
  (`i18401`), Nefarius's letter (`i21142`).
- Wowhead's German is the English in brackets (no German body in this source,
  which does not establish what the game client contains):
  `o174746`, `o175682`, `o175684`, `o175687`, `o175689`, `o175776`,
  `o179741`, `o179909`, `i939`, `i2006`, `i2008`, `i7266`, `i208205`,
  `i211777`, `i216956`, `i227658`, `i227748`, `i228144`.
- `o175776`, Harthal Truesight: the pinned English page is Fellari
  Swiftarrow's plaque. Harthal's own English (Wowhead's) is translated, its
  opening recorded as `english_first`.

## The game's own German reused

- `o177222`, the second Pteradon Skeleton: the same English text as
  `o175685`, whose German Wowhead gives.
- `o182203`, The Green Hills of Stranglethorn: its 29 body pages are the
  German chapters `i2756`-`i2759` in order, the cover and "--Ende--" ours.
- `i5882`, Captain's Documents: the German manifest and letter, its verified
  English opening recorded (the pinned English points to Spy's Report).
- `i20949`, Magical Ledger: empty in English, empty here.

Rebuild with `python3 scripts/book_texts.py deDE`,
`python3 scripts/text_titles.py deDE`, `python3 scripts/book_index.py` and
`bun run locales`.

15 October review corrections: Torn Letter's competence insult is less
literal. Green Hills page 12 still says "gut gelaunt", despite English
"solemnly", because it reproduces the sourced German chapter. This is a
documented game-text discrepancy, not an addon-authored translation.
