# Lorekeeper's Codex: Lore of Azeroth

Lorekeeper's Codex adds a book of Azeroth's lore that fills in as you explore.
Visit Kharanos, speak with King Magni, defeat a Frostmane troll or finish a
quest, and you might discover a page about the history behind it. Each page
is an original text written as a note from an archivist of the Explorers'
League.

The Codex has **414 pages in 44 chapters**, or **426 pages in 45 chapters on
Forever**. It covers the original world's zones, landmarks, figures, peoples,
classes and history. Each race gets its own foreword.

For Classic Era, Hardcore, Season of Discovery, TBC Anniversary and World of
Warcraft: Forever. One download covers all of them. See
[FOREVER.md](FOREVER.md) for Forever support.

## In game

Type `/codex` or click the minimap button to read. Browse by chapter, search
your discovered pages or filter by type. Related pages link to each other.
Each character keeps a separate codex, with the date, level and location of
every discovery. Undiscovered pages stay hidden.

Pages unlock by exploring, meeting people, defeating creatures, finishing
quests, gaining reputation and reading books or inscriptions. A chat link,
an alert and a sound announce each discovery. Tooltips point out creatures
and players who can unlock a page.

The lore covers the world's past up to the original game, using Warcraft I
to III, WoW's quests and books, and the novels and histories about that
period. Later expansion events and answers to mysteries left open in the
original game are kept out. The text is in English. Most unlocks use game
ids, and reading-based unlocks recognise titles in every client language.

On Forever, kill-based unlocks work in the open world. Creatures inside
dungeons and raids are hidden from addons, so kills there cannot unlock pages.
Some pages, paragraphs and unlocks differ between Classic and Forever.

## Library and achievements

The **Library** saves the books, notes, quest letters and plaques you read
in the world. Texts are copied in full, with where and when you found them,
so you can return to a quest letter after handing it in. Letters written by
players are never copied.

The **Achievements** tab tracks page milestones, completed chapters, Library
progress, notable encounters and feats. Each achievement records the day
and level you earned it. Open the tab with `/codex achievements`.

## Settings and commands

The welcome page appears once per character. Use `/codex welcome` to see it
again. Settings are under **Options > AddOns > Lorekeeper's Codex**, through
`/codex settings` or by right-clicking the minimap button.

Choose alerts, their duration, sounds, chat announcements, tooltip hints
and the minimap button. Each character has its own settings. Copy another
character's settings in the same game, or transfer them with `/codex export`
and `/codex import CODE`.

- `/codex minimap` shows or hides the minimap button. Drag it to move it.
- `/codex banner` toggles page alerts.
- `/codex reset` clears this character's codex after confirmation.
- `/codex where` prints your position and target for writing new pages.
- `/codex scan on` records areas, creatures, quest texts and books to help
  write Forever content. `scripts/scan-export.lua` converts the saved data
  to JSON.

The full store description is in [addon/CURSEFORGE.md](addon/CURSEFORGE.md).
The [Vanilla lore review](docs/lore-review.md) records the source checks and
corrections. The [voice review](docs/voice-review.md) records the writing
review of the original 344 entries.

## Writing pages

Pages live in `content/<chapter>/<id>.md`:

```markdown
---
id: kharanos
title: Kharanos
kind: place          # place | figure | faction | creature | history | note | calling
unlock:              # any one of these unlocks it
  - area: Kharanos   # zone or sub-zone, by name (data/areas.json)
  - npc: 2784        # talking to (or targeting) this creature
  - kill: 706, 946   # killing one of these creatures (your blow or your pet's)
  - quest: 1234      # turning in this quest (or having done it)
  - reputation: 47 friendly
  - position: 1455 57 47 6   # uiMap, x %, y %, radius %
  - people: Dwarf    # a player of this race met (targeted), or one's own
  - calling: MAGE    # a player of this class met (targeted), or one's own
  - read: Aegwynn and the Dragon Hunt   # reading this book or plaque, in any language (data/texts.json)
  - [classic] area: Timbermaw Hold (Azshara)   # an unlock on one game only
also: [war-of-the-three-hammers]
client: forever      # optional: on this game only (forever or classic)
---
Paragraphs separated by blank lines. *A paragraph in asterisks is a signature.*

[forever] A paragraph starting with [forever] or [classic] shows on that game only.
```

`bun scripts/build.ts` checks ids, unlock rules, links and place names, then
writes `Content_Classic.lua` and `Content_Forever.lua`.

After adding a `read:` unlock, run `python3 scripts/texts.py` to update the
book's objects and translated titles in `data/texts.json`. After adding a
portrait, run `python3 scripts/portraits.py`.

## Development

```bash
bun run build      # Build Content_Classic.lua and Content_Forever.lua
bun run check      # Check Lua, generated files and simulations on both games
bun run package    # Create dist/LorekeepersCodex-<version>.zip
```

`scripts/release.sh NOTES.md` runs the release checks, tags and pushes.
GitHub Actions uses the BigWigs packager to publish
`LorekeepersCodex-vX.Y.Z.zip` on GitHub, CurseForge and Wago Addons.

## License

[MIT](LICENSE) for code and text. World of Warcraft is a trademark of
Blizzard Entertainment, Inc. Not affiliated with Blizzard Entertainment.
