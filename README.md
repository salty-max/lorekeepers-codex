# Lorekeeper's Codex

A World of Warcraft Classic addon: **the lore of Azeroth, written by an
archivist of the Explorers' League, that fills in as you explore.**

Walk into Kharanos, speak with King Magni in the High Seat, kill your first
Frostmane troll or a rare like Timber, finish the right quest chain: "[Kharanos]
has been added to the codex", and the page waits in your book. Each page is a short,
original text in the voice of a scholar of the Hall of Explorers, and it
remembers when, at what level and where your character found it. Pages link
to each other. A chapter lists the pages you have found, with a bar and a count
for the rest.

- **Per character**: each hero writes their own codex.
- **Vanilla-era lore only**: what was known in Classic, no spoilers from
  later expansions.
- **Every client language**: places, creatures and quests are matched by the
  game's ids, not their names.

Written: all of Azeroth's zones of the original game, 335 pages in 42 chapters: every race's starting lands and capital, the lands around them, the middle lands, the high lands (the Hinterlands, the Plaguelands, Blackrock Mountain and the lands around it, the Blasted Lands, Deadwind Pass, Feralas, Tanaris, Un'Goro, Silithus, Azshara, Felwood, Winterspring, Moonglade), and *Peoples and Powers*, the peoples and orders met across many lands. Each race reads its own foreword.

`/codex` or the book by the minimap opens the codex (drag the button to move
it; `/codex minimap` hides or shows it). Each new page is announced in chat as
a link that opens the book at that page, with a sound, and by a slim banner at the
top of the screen with the page's title (click it to read the page; it goes
away after a few seconds). The sound is the zone discovery sting by default.
The banner, the chat line, the sound and the minimap button are set in the
game's Options, AddOns tab (or `/codex settings`, or right-click the minimap
button). A zone's
chapter appears in the book with its first page, with a count of the pages
found there. The book has a search box (it searches the pages you have found), and creatures that unlock a page say so on their tooltip. `/codex reset` starts a character's codex over.

Achievements: a second tab in the book (or `/codex achievements`) lists them,
each character earning its own: milestones for the pages found (10 up to the
whole codex), feats (pages read; the legendary wanderers; the leaders of your
side; dungeons; the great powers at the end of the deepest lairs; a page in
every chapter) and one for each chapter completed, listed once the chapter is
opened. No counter gives away the codex's full size: the book counts the
pages of the chapters you have opened. A click on a chapter's title folds its pages away, or opens them again; the
button beside the search box folds or unfolds them all. Each remembers when and at
what level it was earned, and is announced like a page. A codex from before
they existed earns what it already deserves quietly. `/codex where` prints your position
and target in the terms content files use (for writing new pages).

For Classic Era (Hardcore, Season of Discovery), TBC Anniversary and World of
Warcraft: Forever (in beta; see [FOREVER.md](FOREVER.md)). On Forever, which
closes the combat log to addons, pages that unlock on a kill also unlock when
you target the creature; some pages and paragraphs belong to one game only, and
the Skyborne have their own foreword. `/codex scan on` records the areas,
creatures, quest texts and books you meet, for writing Forever's new chapters
(`scripts/scan-export.lua` turns the saved file into JSON). Not affiliated
with Blizzard Entertainment.

The [Vanilla lore review](docs/lore-review.md) records the entry-by-entry source checks, corrections and source handling and the remaining editorial exception.

## Writing pages

Pages live in `content/<chapter>/<id>.md`:

```markdown
---
id: kharanos
title: Kharanos
kind: place          # place | figure | faction | creature | history | note
unlock:              # any one of these unlocks it
  - area: Kharanos   # zone or sub-zone, by name (data/areas.json)
  - npc: 2784        # talking to (or targeting) this creature
  - kill: 706, 946   # killing one of these creatures (you or your pet; on Forever, targeting it)
  - quest: 1234      # turning in this quest (or having done it)
  - reputation: 47 friendly
  - position: 1455 57 47 6   # uiMap, x %, y %, radius %
also: [war-of-the-three-hammers]
client: forever      # optional: on this game only (forever or classic)
---
Paragraphs separated by blank lines. *A paragraph in asterisks is a signature.*

[forever] A paragraph starting with [forever] or [classic] shows on that game only.
```

`bun scripts/build.ts` checks every page (ids, unlock rules, links, place
names) and writes one content file per game (`Content_Classic.lua`,
`Content_Forever.lua`).

## Develop

```bash
bun run build      # content → Content_Classic.lua, Content_Forever.lua
bun run check      # both up to date + simulation on both games
bun run package    # dist/classic, dist/forever: one installable addon per game, zipped
```

Releases: `scripts/release.sh NOTES.md` bumps the version, checks, tags and
pushes; GitHub Actions publishes both zips, `LorekeepersCodex-classic.zip`
and `LorekeepersCodex-forever.zip` (and uploads them to CurseForge once
configured).

## License

[MIT](LICENSE): code and text. World of Warcraft is a trademark of Blizzard
Entertainment, Inc.

The [voice review](docs/voice-review.md) records the chapter-by-chapter writing pass and the decision for each of the 344 entries.
