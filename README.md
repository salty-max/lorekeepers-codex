# Lorekeeper's Codex

A World of Warcraft Classic addon: **the lore of Azeroth, written by an
archivist of the Explorers' League, that fills in as you explore.**

Walk into Kharanos, stand before King Magni in the High Seat, finish the
right quest chain: a new page appears in your codex. Each page is a short,
original text in the voice of a scholar of the Hall of Explorers, and it
remembers when, at what level and where your character found it. Pages link
to each other; locked ones wait as `· · ·`.

- **Per character**: each hero writes their own codex.
- **Vanilla-era lore only**: what was known in Classic, no spoilers from
  later expansions.
- **Every client language**: places, creatures and quests are matched by the
  game's ids, not their names.

First chapter in progress: **Dun Morogh** and the dwarven lands.

`/codex` opens the book. `/codex where` prints your position and target in
the terms content files use (for writing new pages).

For Classic Era (Hardcore, Season of Discovery) and TBC Anniversary. Not
affiliated with Blizzard Entertainment.

## Writing pages

Pages live in `content/<chapter>/<id>.md`:

```markdown
---
id: kharanos
title: Kharanos
kind: place          # place | figure | faction | history | note
unlock:              # any one of these unlocks it
  - area: Kharanos   # zone or sub-zone, by name (data/areas.json)
  - npc: 2784        # targeting or talking to this creature
  - quest: 1234      # turning in this quest (or having done it)
  - reputation: 47 friendly
  - position: 1455 57 47 6   # uiMap, x %, y %, radius %
also: [war-of-the-three-hammers]
---
Paragraphs separated by blank lines. *A paragraph in asterisks is a signature.*
```

`bun scripts/build.ts` checks every page (ids, unlock rules, links, place
names) and writes `addon/LorekeepersCodex/Content.lua`.

## Develop

```bash
bun run build      # content → Content.lua
bun run check      # Content.lua up to date + simulation
luajit addon/test/sim.lua
```

Releases: `scripts/release.sh NOTES.md` bumps the version, checks, tags and
pushes; GitHub Actions publishes the zip (and uploads it to CurseForge once
configured).

## License

[MIT](LICENSE): code and text. World of Warcraft is a trademark of Blizzard
Entertainment, Inc.
