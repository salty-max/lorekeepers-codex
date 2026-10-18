# Spanish translation review

Completed 18 October 2026. First translation, not yet reviewed by a native
Spanish reader. The store description and locale flag state this explicitly.

## Coverage

| Part | Coverage |
|---|---|
| Authored pages, including race forewords | 438 of 438 |
| Chapter titles and summaries | 45 of 45 |
| Interface strings | 209 of 209 |
| Library, each Spanish catalog | 433 variants under 411 English titles |
| Library readable object/item ids, each catalog | 437 |

Every translated page records the current English source hash. The Classic
build retains its 425 entries, including nine race forewords. Forever retains
438 entries, including ten forewords. IDs, unlocks, faction restrictions,
paragraph roles and game restrictions are unchanged. English, French, German,
the kit and the UI layout are unchanged. The shared Library identity index
adds Spanish templates and the newly covered English readable bodies.

## Voice and names

Archesonus remains a female dwarf historian, warm and dry, addressing the
reader with tú and viajero or viajera. Parqual keeps his terse, cutting Horde
asides. Gender tokens preserve the reader's form without rewriting saved
content. Translations retain the source's claims and uncertainty, with no new
lore or narrator experiences added.

Names follow the pinned Forever client, with Classic substitutions loaded by
the existing locale engine. The glossary records data-backed terms and
hand-reviewed lore terms separately. Documented name-check exceptions are in
`i18n/esES/names-ok.json`. A generic word such as "mine" or "timber" must not
be replaced with an unrelated named location or creature.

Latin American Spanish shares authored prose with esES. Reviewed substitutions
in `i18n/esMX/regional.json` preserve regional client names, including titles,
places and factions. They apply once, longest match first, to translated
values only. English lookup keys and readable identities are unchanged.
The esMX Library uses its own collected wording where available. Where it is
missing, the supplement explicitly records shared Spanish wording rather
than claiming it is verified esMX client text.

All authored prose uses straight quotes and no semicolons. The semicolon
closing a game gender token is preserved. Page breaks and reader tokens
`$N`, `$C` and `$R` remain intact in readable translations.

## Library sources

Both Spanish catalogs cover every readable id in the existing French and
German catalogs. Collected client wording takes precedence where usable.
Missing or partly English bodies are supplemented from the pinned English
pages, with tracked source hashes and provenance in
`i18n/esES/books-supplement.json` and `i18n/esMX/books-supplement.json`.

| Supplement provenance | esES entries | esMX entries |
|---|---:|---:|
| Authored Spanish translation | 92 | 92 |
| Spanish client text reused, with any authored portions documented | 11 | 219 |
| Collected client text corrected | 2 | 2 |
| Image-only source | 1 | 1 |
| Empty source | 1 | 1 |

These are supplement records, not additional books on top of the catalog.
The two corrected client texts are Kravel's Scheme (`i5826`) and the
Collector's Schedule (`i2223`), whose source gender tokens were malformed.
Kravel's source also had an unmatched parenthesis.

Senir's Report (`i2628`) combines the four original Spanish pages with the
two inserted Gretchen pages translated from their separate English chain
(`i280430`). Both source hashes are checked. It is documented as a composite,
not six verified client pages. The complete Green Hills keeps its original
page order, reusing existing Spanish chapter pages where the English matches.
Partly English pages in Memories of Valor, Raven Hill Tome and Valory Family
Crest have Spanish replacements while retaining the collected Spanish pages.

The Magical Ledger (`i20949`) has a genuinely empty source. The Crude Map
(`i21037`) contains an image without text. Neither receives invented prose.
The binary on the Yellow Punch Card remains exactly as encoded.

The 14 existing source exclusions remain documented in each supplement.
They cover test/deprecated records and incorrect page bindings. They do not
establish what is obtainable in Forever. Unknown or unresolved saved copies
remain readable as recorded, rather than being replaced with guessed text.

## Source gaps

The following 39 readable item records have no English page body in either
pinned database. They therefore have no body to translate. This is a source
gap, not a list of 39 confirmed obtainable books. Some explicitly identify
test records, others need collection or investigation. If found in game,
the Library still records what the client displays.

| Readable id | English source title |
|---|---|
| `i1164` | Sam's Tome |
| `i2755` | Green Hills of Stranglethorn |
| `i2891` | Letter to the City Architect |
| `i5041` | TEST Translation: Taurahe |
| `i6276` | Musty Note |
| `i6277` | Musty Parchment |
| `i6278` | Musty Scroll |
| `i6279` | Musty Letter |
| `i6489` | Weatherworn Parchment |
| `i6490` | Dark Parchment |
| `i6491` | Heavy Parchment |
| `i6492` | Sooty Parchment |
| `i6493` | Tattered Parchment |
| `i6494` | Scrawled Parchment |
| `i6495` | Weatherbeaten Parchment |
| `i6496` | Detailed Parchment |
| `i6497` | Simple Parchment |
| `i6498` | Inscribed Kodo Leather |
| `i6499` | Inscribed Kodo Leather |
| `i6500` | Inscribed Kodo Leather |
| `i6501` | Inscribed Kodo Leather |
| `i6620` | Elaborate Parchment |
| `i12762` | Secrecy of Plans |
| `i22765` | Mildewed Letter |
| `i213421` | Singed Note |
| `i217017` | Fishing Tournament! |
| `i221192` | Dream Journal |
| `i227549` | Scrap of Parchment |
| `i228680` | Nostro's Compendium of Dragon Slaying |
| `i231882` | Suppression Device Receipt |
| `i234181` | Twilight Cultist's Journal |
| `i237143` | Orders from the Commander |
| `i242258` | Research Notes |
| `i242425` | Torn Diary Page - Page 1 |
| `i242426` | Torn Diary Page - Page 2 |
| `i242428` | Torn Diary Page - Page 3 |
| `i242430` | Torn Diary Page - Page 4 |
| `i242431` | Torn Diary Page - Page 5 |
| `i242433` | Torn Diary Page - Page 6 |

## Validation

`bun run check` covers Lua formatting and lint, generated content and locale
freshness, Spanish source coverage and both game simulations. The Spanish
checks verify paragraph roles, source hashes, formatting arguments, reader
tokens, catalog parity and mixed-English fallback pages. The actual loaders
are exercised for male and female readers, both Spanish clients and both game
builds. They check regional titles, rendered gender forms and saved copies
moving between English, French, German and Spanish. Unknown copies stay as
recorded. Package checks verify all three TOCs and their referenced files.

These checks establish structural and runtime consistency. They do not replace
a native Spanish editorial review or a live in-game test. The next reader
review should focus on natural phrasing and the first-translation wording,
particularly the longer Library texts and regional client names.
