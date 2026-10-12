# Lorekeeper's Codex

A WoW Classic addon (Lua 5.1, TOC `## Interface: 11509, 20506`): a codex of
original lore texts that unlock per character as they play. Sister project of
~/code/wow-addons/wow-locker (same tooling and conventions).

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
- `data/areas.json`: the client's AreaTable (wago.tools, `bun scripts/areas.ts`):
  place names in content resolve to area ids, so unlocks work in every language.
  `data/areas-forever.json`: the areas Forever adds (the beta's table, pinned;
  `bun scripts/areas.ts --forever`): Forever-only pages and `[forever]`
  unlocks may name them.
- `data/texts.json`: the books and plaques pages unlock by being read
  (`read: <title>`): each title's text objects in the pinned CMaNGOS database
  and the title in every client language, from Wowhead Classic's tooltips
  (`python3 scripts/texts.py`, after adding a read: unlock).
- `data/portraits.json`: display ids of the creatures pages name as their
  `portrait:` (figures, creatures, factions only; never a guess), from the
  pinned CMaNGOS database (`python3 scripts/portraits.py`, after adding one).
- `addon/LorekeepersCodex/`: `Core.lua` (the codex's record and its schema,
  the events every file listens to: `ns.on`, `ns.knows`; the login, `/codex`,
  `/codex where`), `Unlocks.lua` (the unlock engine: areas, npcs talked to or
  targeted, players targeted (their race's page and class's: `people:`,
  `calling:`; one's own from the start; `met` for the encounters), kills by
  you or your pet: `PARTY_KILL`, an event of its own on Forever and Classic
  since 1.15.9, else the combat log's line; quests incl. ones done before,
  reputations, map positions, books and plaques read: `ns.readText` from the
  Library, by title in any language, and the Library's titles at the login), `Kit.lua` (a copy of the kit shared with Hearthtale and the Field Journal,
  ~/code/wow-addons/addon-kit: the books' look and windows; never edited here: `bun run
  kit:sync` after changing the kit, `bun run kit:check` to verify; the Codex's
  theme is set at the top of `Book.lua`), `Library.lua` (books, notes, plaques read in the world, copied whole from the
  game's reader: on opening, it turns through every page and back; per character
  in `LorekeepersCodexChar.library`; players' letters never), `Book.lua` (the
  window, its tabs: each a file of its own registered with `ns.addTab`, the
  links in chat, and the kit every tab is made of, `ns.ui`: the look, a list's
  row, a page's header; a tab's own select under the search box, registered
  with its tab, `filter = { default, options() }`, its choice `ns.filterOf(n)`:
  the pages' kind), `PagesBook.lua`, `LibraryBook.lua`,
  `AchievementsBook.lua` (the tabs), `Banner.lua` (the toasts), `Hints.lua`
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

- Voice: an archivist of the Explorers' League, writing from the Hall of
  Explorers in Ironforge; addresses the reader as "traveller"; warm, dry, a
  scholar's asides. Short: two to four paragraphs.
- Plain ASCII text: straight apostrophes and quotes (the build rejects others;
  some game fonts lack them, and the search matches what players type).
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
