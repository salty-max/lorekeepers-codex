# Lorekeeper's Codex

A WoW Classic addon (Lua 5.1, TOC `## Interface: 11509, 20506`): a codex of
original lore texts that unlock per character as they play. Sister project of
~/code/wow-locker (same tooling and conventions).

## Layout

- `content/<chapter>/<id>.md`: the pages (front matter + paragraphs), and
  `_chapter.md` per chapter (title, order, one-line summary). The source of truth.
- `scripts/build.ts`: content → `addon/LorekeepersCodex/Content.lua` (generated,
  committed), with validation. `--check` fails if it's stale.
- `data/areas.json`: the client's AreaTable (wago.tools, `bun scripts/areas.ts`):
  place names in content resolve to area ids, so unlocks work in every language.
- `addon/LorekeepersCodex/`: `Core.lua` (unlock engine: areas, npcs, quests incl.
  ones done before, reputations, map positions; per-character SavedVariables
  `LorekeepersCodexChar`; `/codex`, `/codex where`), `Codex.lua` (the book UI).
- `addon/test/sim.lua`: fake WoW API + a replayed session; the UI runs against a
  permissive stub (catches Lua errors, not layout).

## Writing pages (the product is the text)

- Voice: an archivist of the Explorers' League, writing from the Hall of
  Explorers in Ironforge; addresses the reader as "traveller"; warm, dry, a
  scholar's asides. Short: two to four paragraphs.
- Lore: **vanilla-era only** (what was known in Classic, ~patch 1.12): no later
  expansions, no future fates. Original wording, never copied from wikis or
  game text. Check every fact against the Warcraft Wiki before release; when
  sources disagree or it's uncertain, write around it rather than guess.
- Unlocks: by game ids. Ironforge has no named sub-areas in Classic: city spots
  unlock by `position` (collect them in game with `/codex where`). Verify npc and
  quest ids (Wowhead Classic) before release.
- Textures: only ones the Classic UI itself uses (check Gethe/wow-ui-source,
  branch classic_era); a wrong path silently shows nothing.

## Conventions

Conventional Commits, lowercase subjects, no AI co-author trailers. Before
calling a change done: `bun run check`.
