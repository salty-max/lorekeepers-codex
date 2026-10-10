# Lorekeeper's Codex

A WoW Classic addon (Lua 5.1, TOC `## Interface: 11509, 20506`): a codex of
original lore texts that unlock per character as they play. Sister project of
~/code/wow-locker (same tooling and conventions).

## Layout

- `content/<chapter>/<id>.md`: the pages (front matter + paragraphs), and
  `_chapter.md` per chapter (title, order, one-line summary). The source of truth.
- `scripts/build.ts`: content → `addon/LorekeepersCodex/Content_Classic.lua`
  and `Content_Forever.lua` (generated, committed: each holds its game's pages
  and paragraphs only), with validation. `--check` fails if one is stale.
- `scripts/package.ts` (`bun run package`): one package per game in `dist/`
  (folder + zip), its content file as `Content.lua` and a TOC with its game's
  interface versions (the source TOC has an `@INTERFACE@` placeholder: the
  source folder is not installable). Releases attach both zips.
- `data/areas.json`: the client's AreaTable (wago.tools, `bun scripts/areas.ts`):
  place names in content resolve to area ids, so unlocks work in every language.
  `data/areas-forever.json`: the areas Forever adds (the beta's table, pinned;
  `bun scripts/areas.ts --forever`): only Forever's pages may name them.
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
  reputations, map positions), `Kit.lua` (a copy of the kit shared with Hearthtale and the Field Journal,
  ~/code/addon-kit: the books' look and windows; never edited here: `bun run
  kit:sync` after changing the kit, `bun run kit:check` to verify; the Codex's
  theme is set at the top of `Book.lua`), `Library.lua` (books, notes, plaques read in the world, copied whole from the
  game's reader: on opening, it turns through every page and back; per character
  in `LorekeepersCodexChar.library`; players' letters never), `Book.lua` (the
  window, its tabs: each a file of its own registered with `ns.addTab`, the
  links in chat, and the kit every tab is made of, `ns.ui`: the look, a list's
  row, a page's header), `PagesBook.lua`, `LibraryBook.lua`,
  `AchievementsBook.lua` (the tabs), `Banner.lua` (the toasts), `Hints.lua`
  (tooltips), `Scan.lua` (`/codex scan`, for writing Forever's pages).
- `addon/test/sim.lua`: fake WoW API + a replayed session; the UI runs against a
  permissive stub (catches Lua errors, not layout).

## What deserves a page (the user's editorial line)

Three tests, all required: (1) there's a story beyond what the game shows;
(2) the player meets it at a clear moment (arriving, talking, killing,
finishing a story); lore never met directly hangs on a place or person that
evokes it (the War of the Three Hammers unlocks at Anvilmar); (3) it holds up
in sources from before Wrath of the Lich King (see Lore below).

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
  paragraphs). Forever-only content may use Forever's own texts (quests, NPCs,
  books); everything else keeps the pre-WotLK rule below. See FOREVER.md.

- Voice: an archivist of the Explorers' League, writing from the Hall of
  Explorers in Ironforge; addresses the reader as "traveller"; warm, dry, a
  scholar's asides. Short: two to four paragraphs.
- Plain ASCII text: straight apostrophes and quotes (the build rejects others;
  some game fonts lack them, and the search matches what players type).
- The approved voice samples are in `docs/voice-comparison.md`. Prefer concrete
  details and natural flow; keep dry asides sparse, vary openings and endings,
  and do not turn an entry into an audit note or append advice by habit. The
  completed entry decisions are recorded in `docs/voice-review.md`.
- Lore (the user's scope): **everything from the origin of the universe up to
  the vanilla era**, as told by sources published before Wrath of the Lich King
  (13 Nov 2008): Warcraft I, II and III (with their manuals), World of Warcraft up
  to patch 1.12 (its quests, books and item texts), and the novels of that time
  (Of Blood and Honor, Day of the Dragon, Lord of the Clans, The Last Guardian,
  the War of the Ancients trilogy, Cycle of Hatred, Rise of the Horde, Tides of
  Darkness, Beyond the Dark Portal). A permitted publication may still describe
  later events: only its history through Vanilla belongs here. Nothing from later
  expansions, novels or retcons (Chronicle, Arthas, Stormrage, Warlords' Draenor
  …), and no future fates. Original wording, never copied from wikis or game
  text. Research each page: the Warcraft Wiki (`?action=raw` gives the source),
  checked against the period sources above (vanilla quest texts on Wowhead);
  the wiki mixes eras, so date every claim. When sources disagree or it's
  uncertain, write around it rather than guess.
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
- Release: `scripts/release.sh [--version X.Y.Z] NOTES.md` (main pushed
  first); GitHub Actions publishes both zips and uploads them to CurseForge.
