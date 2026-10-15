# German translation corrections

15 October 2026. Follow-up to the [full German review](german-translation-review.md).
44 of its 45 findings are addressed. One sourced game-text discrepancy is
deliberately retained. The original review and quotes remain in place, with a
resolution attached to each finding in `german-translation-review.json`.

## German wording

Corrected 33 authored pages, five UI findings (six strings), and Torn Letter's
competence insult. The corrections fix grammar, meanings obscured by English
constructions, ambiguous references, and literal idioms. Excavation workers
are now `Ausgräber`, while actual graves remain `Gräber`.

Orman's location follows the German plaque, which says "Am Zugang zum
Eiskrone-Gletscher verschollen". The authored page now says "am Zugang zum
Eiskronengletscher", rather than guessing a glacier tongue or using a river's
`Mündung`.

English content, translation source stamps, paragraph boundaries, client
markers and narrator asides are preserved. The German still uses `Ihr` in
the books and `du` in the interface. Existing Classic/Forever names remain.
German is still flagged as a first translation awaiting a native reader.

## Language changes and Library variants

The generated catalog now records readable object/item ids. A shared index
resolves titles and first-page templates from the shipped English, French
and German sources. Templates accept a character's name, race and class in
the original language, and both gender forms. This fixes all six Sealed
Research Report variants, including those beginning with the player's name.

Known saved French and German copies can now read in German, French or
English, with the matching title. The reader, search, lists and cards use
the resolved identity when localized titles are ambiguous. Language changes
leave the saved original pages intact. Unknown or unresolved variants retain
their copied pages.

Re-reading uses that identity too. Different books with the same title stay
distinct, and a German re-read replaces the
corresponding copy rather than a different circular. New copies retain their
identity and source language. A changed first page clears stale trailing
pages even when both languages use the same title.

The index includes English bodies to support a return to English. Two known
wrong source bindings, Captain's Documents and Harthal Truesight, are withheld
in English. Their recorded pages remain available instead of showing the
unrelated Spy's Report or Fellari plaque. The translated bodies remain usable.

Classic's article-only Cenarion Circle swap is overridden in
`i18n/deDE/classic-by-hand.json`. Rebuilding no longer produces `dem Der Zirkel`
or `Der Der Zirkel` in eight paragraphs and the title. Forever is unaffected.

## Sources and rebuilding

The store description now distinguishes sourced game translations from
addon-authored supplements. The readable documentation no longer treats a
missing Wowhead translation as proof that the game client has none.

DE-028 is retained: Green Hills page 12's sourced German says `gut gelaunt`
where English says `solemnly`. This records the German chapter as found,
rather than silently rewriting a client transcript. The discrepancy is noted
in `german-readable-translations.md` and the review ledger.

After rebuilding each locale's books, run `python3 scripts/book_index.py`,
then `bun run build`. The game-data workflow includes this step. The generated
`Text_Sources.lua` is loaded by all three client TOCs.

## Verification

`bun run check` runs Lua lint, generated-content checks and simulated sessions
for Classic and Forever. The additional runtime checks load the real locale
files and exercise both gender forms, every one of the 391 French and German
readable variants, return to English, ambiguous French titles, personalized
reports, unknown-copy fallback, and re-reading shared-opening Twilight texts.
Legacy copies without ids migrate on re-reading, and same-title re-reads
discard obsolete trailing pages without changing the original discovery date.
They also check the finished German paragraphs for repeated faction articles,
unexpanded gender tokens and prose semicolons.

Packaging validation checks all three TOCs. Simulations verify behavior, not
font rendering or layout in a running WoW client. Native German sign-off and
a live client layout check remain separate from these corrections.
