# Lorekeeper's Codex's architecture

The addon file by file (moved from CLAUDE.md on 20 October 2026; the map
stays there). What a page is and how it is written: `docs/writing.md`.

## The files

- `content/<chapter>/<id>.md`: the pages (front matter + paragraphs), and
  `_chapter.md` per chapter (title, order, one-line summary). The source of truth.
- `scripts/build.ts`: content → `addon/LorekeepersCodex/Content_Classic.lua`
  and `Content_Forever.lua` (generated, committed: each holds its game's pages
  and paragraphs only), with validation. `--check` fails if one is stale.
- `addon/LorekeepersCodex` is one package for every game, installable as is: each game
  loads its own TOC (`LorekeepersCodex_Vanilla.toc`: Classic Era, 11509; `_Camelot.toc`:
  Forever, 16001; a `_TBC.toc` is left over from the dropped TBC Anniversary
  and goes after the launch), the same but for
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
- `scripts/when.ts` (`bun run when <page>|--changed|--all`): when each page
  unlocks, in plain words, from wow-data (read-only): every rule, the earliest
  moment one fires, the quests after a quest unlock in its chain and the
  quests an npc gives, and a `!` when a page unlocks on sight before its
  quests. A writer's check against a page telling more than the player has
  seen.
- `data/texts.json`: the books and plaques pages unlock by being read
  (`read: <title>`): each title's text objects and the title in every client
  language (`python3 scripts/texts.py`, after adding a read: unlock).
- `data/portraits.json`: display ids of the creatures pages name as their
  `portrait:` (figures, creatures, factions only; never a guess), from the
  Classic database's models (`python3 scripts/portraits.py`, after adding one).
- `addon/LorekeepersCodex/`: `Core.lua` (the codex's record and its schema,
  the events every file listens to: `ns.on`, `ns.knows`; the login, `/codex`
  (the kit's command, `K.commands`: alone it opens the book, an unknown word
  prints the usage, the replies capitalised), `/codex where`),
  `Achievements.lua` (the achievements on the kit's `K.deeds`: earned with
  the achievement sound the player picks (the game's fanfare by default, Quest
  complete where a client lacks it), a chat line
  with its link and the codex's alert behind its switch; a chapter's listed
  once the chapter is opened, earned quietly before), `Unlocks.lua` (the unlock engine: areas, npcs talked to or
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
  window, the kit's `K.book`, its tabs: each a file of its own registered
  with `ns.addTab`, the links in chat, and what every tab is made of,
  `ns.ui`: the look, the kit's list (`K.list`, each tab its kinds of row),
  the kit's page (`K.page`: a header, sections, cards, figures, ...); a
  page's picture, `ns.pictureOf`; a tab's own select under the search box,
  registered with its tab, `filter = { default, options() }`, its choice
  `ns.filterOf(n)`: the pages' kind), `PagesBook.lua` (the codex at a glance
  at the head of the list: figures, the pages found lately, the chapters to
  pick; a page: its text, where and when it was found, its related pages as
  cards), `LibraryBook.lua` (the Library at a glance when its tab is clicked or its
  row at the head of the list, as the Pages tab's codex:
  figures by shelf, the texts copied lately; a text a page at a time),
  `AchievementsBook.lua` (the kit's tab, `K.deedsTab`: its board over both
  panels), `Banner.lua` (the kit's banners,
  among the game's alerts: a page found, an achievement), `Hints.lua`
  (tooltips), `Scan.lua` (`/codex scan`, for writing Forever's pages),
  `Settings.lua` (each character's settings, the kit's profiles: a profile
  "Name - Realm" in LorekeepersCodexSettings, the minimap button's place among
  them; copied from another character of this game or from a code `LC1:...`,
  `/codex export` and `/codex import CODE`; a character who kept a codex before
  starts from the account's old values; the Options page, the kit's
  `K.options`, its "Copy settings from"), `Welcome.lua` (the kit's welcome page, once per character, `/codex
  welcome`: the logo, `Media/Logo.tga` from `assets/logo.png` with magick,
  what the codex is, the choices and another character's; the packages carry
  `Media/`).
- The Soundtrack tab (added 29 October 2026, `ideas/soundtrack.md`): the
  tunes of the game's music, one entry per `ZoneMusic` set, as
  `content/soundtrack/<id>.md` (kind `tune`, `group:` lands | cities |
  moments | depths, `unlock: - music: <set id>`). `scripts/music.ts` writes
  `data/music.json` from wow-data's `music_*` tables (a game's file ids are
  its own: Forever ships other recordings); the build puts each game's sets'
  tracks and the areas that play them into `Content_*.lua` (`music`, only the
  sets a tune names). A tune is no page: the soundtrack chapter is left out of
  `chapters`, `ns.total` skips kind `tune`, and a find goes in
  `char.tunes[id]`, not `char.entries`. `Soundtrack.lua` finds a tune after 45
  seconds in an area that plays it with the music on (the client has no event
  or call for the music playing: the place is the only signal, so it says
  "found", never "heard"; a building row the client pins to a whole city is
  inexact: the tune plays somewhere in it), and plays a found one again with
  `PlayMusic(fileDataID)` (always true, even for a bad id) until `StopMusic`.
  A tune may name several sets (one `music:` rule each: found by any, its tracks all of
  theirs) and carry `arrival:` stingers (`ZoneIntroMusicTable` ids, `music.intros`, listed
  after the tracks). `data/music-left-out.json` (by hand, per game) lists the reachable sets
  deliberately without a tune: the build counts the rest, and fails on one once `complete` is
  true, and on a set two tunes name. `SoundtrackBook.lua` is the tab (the kit's list and page: groups, "???" for
  a tune not found, one button a track). Every tune is translated like a page
  (French, German and Spanish pages are tested complete).
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
  English page's hash in `source:`, `--stamp` writes it; a language without
  words reads in English, the game's names in its own all the same; esMX
  borrows esES's translation, with reviewed regional substitutions from
  `i18n/esMX/regional.json` (game names from wow-data, words by hand; `regional.resolved.json` is generated by addon-kit/regional.ts), its own books and its own Classic swaps);
  `--keys` writes `i18n/words.json`, the
  words to translate; `--check` says which pages are stale (their English
  changed) and which words are missing. A translation keeps the English
  page's paragraph marks; its own letters are fine, curly quotes are not.
  A name the glossary holds (`i18n/<locale>/glossary.json`, wow-data's names;
  `glossary-by-hand.json`'s where no table has one) that an English page
  names is in its translation as the game writes it (`scripts/names.ts`, in
  `--check`; the exceptions, with their reason, in `names-ok.json`).
  The Library's titles read in the client's language by their texts' ids, a copy's identity (`i18n/<locale>/texts.json`, `python3 scripts/text_titles.py <locale>`: every text of each game's database by its id, "o<object>", "i<item>", every language's, English one of them, in its Text file by `ns.names`; `ns.textTitle`), and a text read again in the client's language replaces its copy. Known copies made in English, French, German or Spanish follow the client's language, using readable identities and first-page templates (`i18n/books-index.json`, `python3 scripts/book_index.py` after the locale imports, generated as shared `Text_Sources.lua`: a plain first page known by its fingerprint, a pattern only where a name is inside; the English pages in `Text_enUS`/`Text_enGB` alone, `ns.textBodies`). A re-read uses that identity, keeping same-title variants distinct. Sourced game text and documented addon translations ship in each language (`i18n/<locale>/books.json`, `python3 scripts/book_texts.py <locale>` from wow-data's pages: Wowhead's, saved from a browser, which Wowhead serves only to one; `ns.textPages`, the reader's $N/$C/$R filled in by `ns.textForReader`): the user's call, 14 October 2026, so a quest item handed in still reads in French. Where a page or a text was found is kept by ids only, never a name (the family's rule, 15 October 2026; a name only where the client's gave no id): the zone's and subzone's areas (`zoneId`, `subId`, from the client's names of every area, `ns.areaOf`) or, inside a building, its building area (`subInside`, `ns.insideOf`, by the language's list: `i18n/<locale>/subzones.json`, `../addon-kit/subzones.py <locale>`, every language's, English one of them, loaded by `ns.names`); `ns.placeOf(zone, sub)` makes the record, `ns.placeNames(rec)` reads it in the client's language. An older find kept its names: turned into ids at the login (`ns.mendPlaces`), an English one by the codex's own (`C.areaNames`), today's language's by the client's; another language's waits for a client of its own.
- `/codex scan` keeps its places by their ids (`ns.placeOf`) and a quest's giver by its creature's id; the names and texts no database has yet as the game gave them (what it is for).
- The opt-in that shares what the game tells of the world (the kit's
  `K.collect`: quests' texts, creatures' facts, NPCs' lines, loot by source;
  off until the player ticks it on the welcome page or the Options page)
  keeps it account-wide in `LorekeepersCodexCollect`, which Ravenpost sends
  to the addons' database.
- `addon/test/sim.lua`: fake WoW API + a replayed session; the UI runs against a
  permissive stub (catches Lua errors, not layout).

## The daily game data

- `.github/workflows/game-data.yml`: daily and by hand, wow-data's
  `addon-data.yml` builds the game data again from wow-data's pins (the areas, the texts, the portraits, the places inside buildings in every language, a translation's titles, texts and glossary, then `bun run build`);
  a pull request when a generated file changes, the checks run on it, then
  rebased onto main by itself and told to the owner's phone in words
  (Ravenpost's inbox). The generators' list lives there: a new one goes in too.

## Lua tools and releases

- Lua: `bun run format:lua` (StyLua, `stylua.toml`) and `bun run lint:lua`
  (selene, `selene.toml`; the game's globals in `wow.yml`, the kit's copy: a
  new game function goes into addon-kit's `wow.yml`, then `bun run kit:sync`;
  the addon's own globals in `codex.yml`). Both run in `bun run check` and CI.
- Release: `scripts/release.sh --version X.Y.Z [--hold] NOTES.md` (main
  pushed first); GitHub Actions runs the BigWigs packager (`.pkgmeta`):
  the zip on GitHub, CurseForge (the TOCs' `X-Curse-Project-ID`, secret
  `CURSEFORGE_TOKEN`) and Wago Addons (`X-Wago-ID`, secret
  `WAGO_API_TOKEN`). `--hold`: GitHub alone (variable `HOLD_STORES`); the
  stores later: `gh workflow run release.yml -f tag=vX.Y.Z`.
