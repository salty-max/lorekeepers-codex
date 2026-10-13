# The books of the world: what unlocks a page

An audit of every readable thing in the pinned CMaNGOS Classic database
(13 October 2026): text objects (type 9), buttons with a page (type 10) and
items with a page. 208 titles: 80 objects, 103 items, 3 buttons. The Codex
binds 46 titles (`read:` unlocks, `data/texts.json`); every one of them is in
the database. The Library copies every text read, bound or not.

The database misses some objects' places in the world (Uther's tomb, The War
of the Ancients have no spawn there), so this goes by the texts themselves.
Forever's own books are in no database: `/codex scan` records the books read
on the beta (`LorekeepersCodexScan.books`).

Each binding below is a proposal, to check against the text before adding
the `read:` line (then `python3 scripts/texts.py`, `bun run build`).

## Histories (the series of the libraries: Ironforge, Stormwind, Thunder Bluff, Darnassus)

| Book | Pages | Proposed page |
|---|---|---|
| The War of the Ancients | 15 | **a new page** in Ages Past: the war has none of its own (Malfurion, the Ancients, the Five Aspects mention it) |
| The Kaldorei and the Well of Eternity | 12 | the same new page |
| Empires' Fall | 5 | the same new page (the Highborne's empire and its fall) |
| Mount Hyjal and Illidan's Gift | 8 | `felwood/illidan-stormrage` (the second Well) |
| The Betrayer Ascendant | 10 | `felwood/illidan-stormrage` |
| Kel'Thuzad and the Forming of the Scourge | 14 | `ages-past/the-lich-king` |
| The Scourge of Lordaeron | 4 | `tirisfal/fall-of-lordaeron` |
| The Invasion of Draenor | 10 | `blasted-lands/the-dark-portal` |
| Beyond the Dark Portal | 4 | `blasted-lands/the-dark-portal` |
| The New Horde | 9 | `durotar/thrall` (Blackmoore, the camps, the new Horde) |
| Old Hatreds - The Colonization of Kalimdor | 8 | `durotar/durotar` |
| The Twin Empires | 7 | `stranglethorn/gurubashi-empire` |
| Wrath of Soulflayer | 6 | `swamp-of-sorrows/the-temple-of-atalhakkar` |
| Mists of Dawn | 3 | `peoples/tauren` |
| Sorrow of the Earthmother | 3 | `peoples/tauren` |
| The White Stag and the Moon | 4 | `peoples/tauren` |
| Forestlord and the first Druids | 3 | `peoples/cenarius` |
| Hatred of the Centaur | 3 | `peoples/centaurs` |
| The Lay of Ameth'Aran | 3 | `darkshore/highborne-ruins` |
| The Fall of Ameth'Aran | 3 | `darkshore/highborne-ruins` |
| The Green Hills of Stranglethorn | 30 | `stranglethorn/nesingwarys-expedition` (and its four chapters, items) |

## Plaques, tombs and monuments

| Text | Proposed page |
|---|---|
| Uther the Lightbringer (his tomb) | `western-plaguelands/uthers-tomb` |
| Here Lies King Terenas Menethil II | `tirisfal/ruins-of-lordaeron` |
| Monument of Remembrance (Lothar) | `burning-steppes/anduin-lothar` |
| Archbishop Alonsus Faol | `tirisfal/alonsus-faol` |
| Grand Admiral Daelin Proudmoore | `durotar/daelin-proudmoore` |
| King Llane I of the House of Wrynn | `elwynn/stormwind-city` (or the Regency) |
| Lady Mara Fordragon | none fits; check the plaque is in the original world first |
| Harthal Truesight | `tirisfal/the-crusades-fallen` (the Scarlet dead, as its ten others) |
| The Armor of Mannoroth (Orgrimmar) | `ashenvale/grom-hellscream` |
| Altar of Zanza | `stranglethorn/zulgurub` |
| Ancient Inscription (the Shrine of Mel'Thandris) | the Darkshore page that names the shrine, if one does; else none |
| Uldaman Reliefs, Uldaman Relics (Hall of Explorers) | `badlands/platinum-discs` |
| The Skull of Tyrannistrasz (Hall of Explorers) | `wetlands/red-dragonflight` |

Left to the Library on purpose: the Hall of Explorers' other exhibits
(Fossilized Egg, Saurial Egg, Pteradon Skeleton, Roc Talon, Geru Strider,
Highborne Astrolabe, Horde Catapult, Toothgnasher's Skeleton), the military
ranks, the developers' memorials (Decorated Headstone, In Loving Memory,
Horatio Montgomery, Jar of ashes...), notes that belong to a quest (Etched
Note, Baelog's Journal, Shrine of Dath'Remar, Yuriv's Tombstone, Dark Keeper
Nameplate, Missing: Corporal Keeshan).

## Books carried (items)

Most of the 103 are a quest's letters and orders, whose story the quest's own
page tells when the quest is done. The ones with lore of their own:

| Item | Proposed page |
|---|---|
| Mythology of the Titans | `ages-past/the-ordering` |
| Compendium of the Fallen (the Scarlet Monastery's, Parqual's Test of Lore) | `tirisfal/scarlet-monastery` |
| Legends of the Gurubashi, Volume 3; The First, Second and Third Troll Legend | `stranglethorn/gurubashi-empire` |
| The Story of Morgan Ladimore | `duskwood/morladim` |
| Green Hills of Stranglethorn, Chapters I to IV | `stranglethorn/nesingwarys-expedition` |
| Lorgalis Manuscript | the Blackfathom Deeps page, if one names it |
