# Lorekeeper's Codex

A World of Warcraft addon (Lua 5.1; Classic Era, TBC Anniversary and Forever,
a TOC each): a codex of original lore texts that unlock per character as they
play. Sister project of Yonder, in ~/code/wow-addons/yonder (same tooling and
conventions).

## Layout

- `content/<chapter>/<id>.md`: the pages (front matter + paragraphs), and
  `_chapter.md` per chapter (title, order, one-line summary). The source of truth.
- `scripts/build.ts`: content → `addon/LorekeepersCodex/Content_Classic.lua`
  and `Content_Forever.lua` (generated, committed: each holds its game's pages
  and paragraphs only), with validation. `--check` fails if one is stale.
- `addon/LorekeepersCodex` is one package for every game, installable as is: each game
  loads its own TOC (`LorekeepersCodex_Vanilla.toc`: Classic Era, 11509; `_TBC.toc`:
  TBC Anniversary, 20506; `_Camelot.toc`: Forever, 16001), the same but for
  the interface and the game's data (`Content_Classic.lua` or
  `Content_Forever.lua`). `scripts/package.ts` (`bun run package`) checks they
  agree and zips `dist/LorekeepersCodex-<version>.zip` for a test in the game
  (`git describe`: the tag, or v0.9.2-2-g1234abc between two, -dirty if
  changed); a release's is `LorekeepersCodex-vX.Y.Z.zip`.
- The game's data comes from wow-data's databases (`../wow-data`, beside
  this folder: the pinned client builds and databases; the scripts import
  `../../wow-data/src/db` or, in Python, `../wow-data/py/wowdata.py`).
- `data/areas.json`: the client's AreaTable (`bun scripts/areas.ts`):
  place names in content resolve to area ids, so unlocks work in every language.
  `data/areas-forever.json`: the areas Forever adds (Forever's table;
  `bun scripts/areas.ts --forever`): Forever-only pages and `[forever]`
  unlocks may name them.
- `data/texts.json`: the books and plaques pages unlock by being read
  (`read: <title>`): each title's text objects and the title in every client
  language (`python3 scripts/texts.py`, after adding a read: unlock).
- `data/portraits.json`: display ids of the creatures pages name as their
  `portrait:` (figures, creatures, factions only; never a guess), from the
  Classic database's models (`python3 scripts/portraits.py`, after adding one).
- `addon/LorekeepersCodex/`: `Core.lua` (the codex's record and its schema,
  the events every file listens to: `ns.on`, `ns.knows`; the login, `/codex`,
  `/codex where`), `Unlocks.lua` (the unlock engine: areas, npcs talked to or
  targeted, players targeted (their race's page and class's: `people:`,
  `calling:`; one's own from the start; `met` for the encounters), kills by
  you or your pet: `PARTY_KILL`, an event of its own on Forever and Classic
  since 1.15.9, else the combat log's line; quests incl. ones done before,
  reputations, map positions, books and plaques read: `ns.readText` from the
  Library, by title in any language, and the Library's titles at the login), `Kit.lua` (a copy of the kit shared with Hearthtale, Yonder and
  Second Wind, ~/code/wow-addons/addon-kit: the books' look and windows, the
  page and every part of one, the board, the banners; never edited here: `bun run
  kit:sync` after changing the kit, `bun run kit:check` to verify; the Codex's
  theme is set at the top of `Book.lua`), `Library.lua` (books, notes, plaques read in the world, copied whole from the
  game's reader: on opening, it turns through every page and back, a page a frame (never
  from inside the reader's event: turns nested there crashed the game on a
  long book); per character
  in `LorekeepersCodexChar.library`; players' letters never), `Book.lua` (the
  window, its tabs: each a file of its own registered with `ns.addTab`, the
  links in chat, and what every tab is made of, `ns.ui`: the look, a list's
  row, the kit's page (`K.page`: a header, sections, cards, figures, ...); a
  page's picture, `ns.pictureOf`; a tab's own select under the search box,
  registered with its tab, `filter = { default, options() }`, its choice
  `ns.filterOf(n)`: the pages' kind), `PagesBook.lua` (the codex at a glance
  at the head of the list: figures, the pages found lately, the chapters to
  pick; a page: its text, where and when it was found, its related pages as
  cards), `LibraryBook.lua` (the Library at a glance when its tab is clicked:
  figures by shelf, the texts copied lately; a text a page at a time),
  `AchievementsBook.lua` (the kit's board), `Banner.lua` (the kit's banners,
  among the game's alerts: a page found, an achievement), `Hints.lua`
  (tooltips), `Scan.lua` (`/codex scan`, for writing Forever's pages),
  `Settings.lua` (each character's settings, the kit's profiles: a profile
  "Name - Realm" in LorekeepersCodexSettings, the minimap button's place among
  them; copied from another character of this game or from a code `LC1:...`,
  `/codex export` and `/codex import CODE`; a character who kept a codex before
  starts from the account's old values; the Options page, its "Copy settings
  from"), `Welcome.lua` (the kit's welcome page, once per character, `/codex
  welcome`: the logo, `Media/Logo.tga` from `assets/logo.png` with magick,
  what the codex is, the choices and another character's; the packages carry
  `Media/`).
- Languages (docs/localization.md): every word the addon shows goes through
  `L["..."]` (`ns.L`, the kit's `K.L`: English by default, a missing word is
  its own English; plurals through `ns.kit.plural(n, "one", "many")`, dates
  through the kit's `K.day`); link and colour codes stay outside the words.
  The TOCs load `Locale.lua` (`ns.translate`) and `Text_[TextLocale].lua`
  right after the content, before any file reads a word: the client loads
  its own language's file. `scripts/locales.ts` (`bun run locales`, in
  `build` and `check`) writes `Text_<locale>.lua` for the game's twelve
  languages from `i18n/<locale>/` (`meta.json`: plural rule, flagged;
  `words.json`; `chapters.json`; `pages/<chapter>/<id>.md`, each with the
  English page's hash in `source:`, `--stamp` writes it, a stub where there's
  no translation; esMX borrows esES); `--keys` writes `i18n/words.json`, the
  words to translate; `--check` says which pages are stale (their English
  changed) and which words are missing. A translation keeps the English
  page's paragraph marks; its own letters are fine, curly quotes are not.
  A name the glossary holds (`i18n/<locale>/glossary.json`, wow-data's names;
  `glossary-by-hand.json`'s where no table has one) that an English page
  names is in its translation as the game writes it (`scripts/names.ts`, in
  `--check`; the exceptions, with their reason, in `names-ok.json`).
  The Library's titles copied in another language read by the client's (`i18n/<locale>/texts.json`, `python3 scripts/text_titles.py <locale>`: every text object and item with a page, each game's titles), and a text read again in the client's language replaces its copy (`ns.textTitle`). Known copies made in English, French or German follow the client's language, using readable identities and first-page templates (`i18n/books-index.json`, `python3 scripts/book_index.py` after the locale imports, generated as shared `Text_Sources.lua`: a plain first page known by its fingerprint, a pattern only where a name is inside; the English pages in `Text_enUS`/`Text_enGB` alone, `ns.textBodies`). A re-read uses that identity, keeping same-title variants distinct. Sourced game text and documented addon translations ship in each language (`i18n/<locale>/books.json`, `python3 scripts/book_texts.py <locale>` from wow-data's pages: Wowhead's, saved from a browser, which Wowhead serves only to one; `ns.textPages`, the reader's $N/$C/$R filled in by `ns.textForReader`): the user's call, 14 October 2026, so a quest item handed in still reads in French. Places inside buildings, which have no area id, read by `i18n/<locale>/subzones.json` (`../addon-kit/subzones.py`). Where a page or a text was found keeps the area ids of the zone and
  subzone (`zoneId`, `subId`, by the client's names of the codex's areas,
  `ns.areaOf`) and reads in the client's language (`ns.placeName`: an older
  find, kept only by name, by its English one in `C.areaNames`).
- The opt-in that shares what the game tells of the world (the kit's
  `K.collect`: quests' texts, creatures' facts, NPCs' lines, loot by source;
  off until the player ticks it on the welcome page or the Options page)
  keeps it account-wide in `LorekeepersCodexCollect`, which Ravenpost sends
  to the addons' database.
- `addon/test/sim.lua`: fake WoW API + a replayed session; the UI runs against a
  permissive stub (catches Lua errors, not layout).

## What deserves a page (the user's editorial line)

Three tests, all required: (1) there's a story beyond what the game shows;
(2) the player meets it at a clear moment (arriving, talking, killing,
finishing a story); lore never met directly hangs on a place or person that
evokes it (the War of the Three Hammers unlocks at Anvilmar); (3) it holds up
in sources true to the era (see Lore below).

- Zones: every zone gets one page.
- Places: towns, capitals (one page each, no districts), landmarks with a
  story. Not generic camps or quest caves.
- Figures: lore figures and storyline leads only (rulers, leaders, the heart
  of a quest chain). Not vendors, trainers, one-off quest givers or locals.
- Peoples/factions: one page per people, unlocked by any member; the playable
  peoples by a player of them (`people:`), one's own from the start.
- Callings: one page per class (`kind: calling`, chapter `callings`), unlocked
  by a player of it (`calling:`), one's own from the start; a class a game
  adds (Forever's) in a `[forever]` paragraph.
- Creatures: only rares with a story and identity (Timber); not every rare,
  not ordinary wildlife.
- History: regional events, hung on a related place or quest.
- As many pages as the zone has stories: a small zone 8–10, a large one like
  the Barrens 30+. Every page still earns its place. The plan per zone is
  PLAN.md (status, unlock, what to check): update it as pages land.

Timber is an explicit user-approved exception: preserve its hunter tale
as flavour text without an in-entry label. This does not permit unsupported
historical claims in other entries.

## Writing pages (the product is the text)

- Two games read the codex: Classic and Forever (the original world on the
  modern client, with new zones, quests and the Skyborne). A page or paragraph
  for one only says so (`client:` front matter, `[forever]`/`[classic]`
  paragraphs). An unlock may also start with `[classic]` or `[forever]` when
  its place or creature belongs to that game alone; the build keeps that rule
  only in its game's content. Forever-only content may use Forever's own texts
  (quests, NPCs, books); everything else keeps the Lore rule below. See FOREVER.md.

- Voice: Royal Historian Archesonus (a dwarf; she), writing from the High
  Seat in Ironforge, a few steps from King Magni's throne; the Explorers'
  League is the city's and her help, not her order (never "we" for it);
  addresses the reader as "traveller"; warm, dry, a scholar's asides. Short:
  two to four paragraphs. A Horde reader's copy comes through Parqual
  Fintallas (the Apothecarium, Undercity; Lordaeron's historian before the
  plague): the Horde races' forewords are his, and his notes in the pages are
  `[horde]` paragraphs (`[alliance]`: the other side's only).
- The two voices. Archesonus: a dwarf of the court, warm and dry, proud of
  Ironforge and honest about it; the Dark Irons are her subject, Magni's house
  her charge, and she tells a story at length; she knows the Horde's lands from
  others' accounts. Parqual's notes: only where a Forsaken who was Lordaeron's
  historian sees it otherwise (Lordaeron and the plague, the Scarlet Crusade,
  the camps, the Horde's own), never by habit (some 25 pages); one to three
  sentences, "[horde] > ... -- P. F." at the page's end (an aside: the kit's
  page sets it apart in his ink, the initials under it; no "in another hand"
  in the words); precise
  and cutting, a dead man's dry humour, knowledge over strength, a teacher who
  sets tests, contempt for the Crusade; his point of view only, no new facts of
  his life beyond the sources (Lordaeron's historian before the plague, the
  Test of Lore, its book from the Scarlet Monastery), not even a small one
  ("mine among them"). Vary the endings and openings: most end plainly, on a
  disagreement or an open question; a sharp last line only where it is the
  point (a handful), else the notes become a formula.
- Plain ASCII text: straight apostrophes and quotes (the build rejects others;
  some game fonts lack them, and the search matches what players type).
- No semicolons in prose, English or French (the user's rule, 14 October
  2026): two sentences, or a comma, or a rewrite for a list. The gender
  tokens' own `;` stay.
- The approved voice samples are in `docs/voice-comparison.md`. Prefer concrete
  details and natural flow; keep dry asides sparse, vary openings and endings,
  and do not turn an entry into an audit note or append advice by habit. The
  completed entry decisions are recorded in `docs/voice-review.md`.
- Lore (the user's scope; loosened on 12 October 2026 to match the Field
  Journal's): **everything from the origin of the universe up to the vanilla
  era**, from any source: the games (Warcraft I, II and III with their manuals,
  World of Warcraft to patch 1.12 with its quests, books and item texts, and a
  later game's look back at that past), the novels and short stories, the
  comics and manga, the RPG books, Chronicle. Nothing anachronic to vanilla or
  Forever: no event after the vanilla era (a later fate, a return, a death to
  come), and no later answer to a mystery vanilla leaves open (who made the
  Scythe of Elune, what ails Teldrassil, where Malfurion's spirit wanders,
  how the earthen became dwarves). When a later retelling contradicts the
  period texts (Warcraft I-III and the original game, with their manuals and
  books), the period texts win; where they are silent and the later account
  disputed, write around it. Other continuities stay out: the Warcraft film
  with its novel and comic, Warlords' alternate Draenor. Note each source's
  publication and the time of what it tells, separately. Original wording,
  never copied from wikis or game text. Research each page: the Warcraft Wiki
  (`?action=raw` gives the source), checked against the source itself
  (vanilla quest texts on Wowhead); the wiki mixes eras, so date every claim.
  When sources disagree or it's uncertain, write around it rather than guess.
  The pages to add under this rule: `docs/lore-expansion.md`.
- Unlocks (the user's rules): places when discovered; figures when talked to;
  mobs and rares when killed (a people's page lists every creature id of it);
  capitals get one page for the whole city (no per-district pages). Ids are
  verified on Wowhead Classic (`/classic/npcs/name:X` embeds the data,
  `nether.wowhead.com/classic/tooltip/npc/ID` gives the creature type) before
  writing; never guess one.
- Textures: only ones the Classic UI itself uses (check Gethe/wow-ui-source,
  branch classic_era); a wrong path silently shows nothing.

- `.github/workflows/game-data.yml`: daily and by hand, wow-data's
  `addon-data.yml` builds the game data again from wow-data's pins (the areas, the texts and their titles, the portraits, the glossaries and the places inside buildings in every language, then `bun run build`);
  a pull request when a generated file changes, the checks run on it, then
  rebased onto main by itself and told to the owner's phone in words
  (Ravenpost's inbox). The generators' list lives there: a new one goes in too.

## Conventions

- Conventional Commits, lowercase subjects; no AI co-author trailers.
- Commit locally; ask before any push, release or deploy.
- Lua: `bun run format:lua` (StyLua, `stylua.toml`) and `bun run lint:lua`
  (selene, `selene.toml`; the game's globals in `wow.yml`: add one there when
  the addon calls a new game function). Both run in `bun run check` and CI.
- Before calling a change done: `bun run check`.
- Release: `scripts/release.sh [--version X.Y.Z] [--hold] NOTES.md` (main
  pushed first); GitHub Actions runs the BigWigs packager (`.pkgmeta`):
  the zip on GitHub, CurseForge (the TOCs' `X-Curse-Project-ID`, secret
  `CURSEFORGE_TOKEN`) and Wago Addons (`X-Wago-ID`, secret
  `WAGO_API_TOKEN`). `--hold`: GitHub alone (variable `HOLD_STORES`); the
  stores later: `gh workflow run release.yml -f tag=vX.Y.Z`.
