# Lorekeeper's Codex on World of Warcraft: Forever

Forever (beta since 17 September 2026, launch 4 November 2026) is the original
Azeroth on the modern Mainline client. The addon must run on both clients from
one package. This plan records the decisions and the work, in two waves.

## Decisions

| Question | Decision |
|---|---|
| Kill unlocks (Forever has no combat log for addons) | **The kill, as on Classic** (7 October 2026): `PARTY_KILL` (killer, victim) is an event of its own on Forever (and Classic since 1.15.9). Before: meeting counted on Forever. Inside a Forever instance creature GUIDs are secret: kills there unlock nothing. |
| Forever's new content | **Second wave**, after launch, once zones and quest texts settle. |
| Lore sources for Forever-only pages | **Forever's own texts** (quests, NPCs, books), and only Forever readers see those pages. Original pages keep the pre-WotLK rule. |
| Original pages contradicted by Forever | **Forever variants:** Forever-only paragraphs or replacement text; Classic readers see the original. |
| Skyborne | **Their own foreword now**, written during the port from what the beta shows of them and Zephras Isle. |
| Packaging | **One source, two packages:** one version and changelog, a zip per game (`LorekeepersCodex-classic.zip`, `LorekeepersCodex-forever.zip`), each with only its game's content and interface versions. |
| Testing | **On the beta, by the user**, with a `/codex scan` command that records ids for the second wave. |

## What Forever changes (from the beta's AreaTable, wago.tools `wow_classic_beta`)

- 159 new areas, 6 renamed, none removed. Ids of the original areas are kept,
  so our unlocks still resolve (matched by the name the client shows).
- New zones: the Riverglades (Eastern Kingdoms, 30–45: Farholde Keep,
  Krol'dok Stronghold, Powderfuse Port, Terral's Watch…), Shen'dralas
  (Kalimdor: Magram Front, Bristleback Retreat, Outcast Hideaway…), Mount Hyjal
  (Shrine of Aviana, Summit of Eternity, Malorne's Retreat…), the Ruins of
  Gilneas (Gilneas City, the Blackwald, Emberstone Village…), Zephras Isle
  (Skyborne start).
- New places in old zones: Stormwind Harbor, Excavation Site: Wetlands,
  Dragonmaw Retreat, Old Dalaran Ruins, Bandarion Keep (Tirisfal), the Shaper's
  Terrace (Un'Goro), the Ironforge Submarine Facility, Poacher's Den (Burning
  Steppes), Camp Gev'rek (Thousand Needles)…
- Renamed: Timbermaw Hold (Azshara, 1216) → **Blackmaw Hold** (a dungeon);
  Legash Encampment → Legashi Encampment; Hunter Rise (unused) → Galak Camp.
- Nine new dungeons (Hall of Thanes, Ruins of Lordaeron, Excavation Site:
  Wetlands, City of Dalaran, Drowned City, Krol'dok Stronghold, Alcaz Island
  Prison, Blackmaw Hold, Shaper's Terrace), new raids (Barrow Deeps, Hyjal
  Summit), about 1,000 new quests, the Skyborne race.
- Wowhead knows few Forever quests and nothing in the new zones: their ids
  come from the client.

## Wave 1: the port (done, to test on the beta)

1. ✅ **Two packages from one source:** the build writes
   `Content_Classic.lua` and `Content_Forever.lua` (each with its game's
   pages and paragraphs only); `bun run package` assembles `dist/classic` and
   `dist/forever`, each with its content file and a TOC for its game (`11509,
   20506` / `16001`). The addon also asks the client which game it is
   (`GetBuildInfo`, interface 16xxx is Forever: `ns.forever`, `ns.client`),
   for the combat log and the API; a package installed on the other game
   still works and says so at login.
2. ✅ **Combat log:** not registered on Forever (it throws there); if any
   client refuses it, meeting counts instead.
3. ✅ **Kills (Forever):** `PARTY_KILL`, an event of its own, as on Classic
   (meeting counted until 7 October; it still does on a client with neither
   that event nor the combat log). The tooltip hint is unchanged.
4. ✅ **Secret values:** `ns.secret()` (`issecretvalue`) before using a GUID,
   a name or a boolean (creature ids, tooltip hint, `/codex where`, scan).
5. ✅ **Modern API:** reputations through `C_Reputation.GetFactionDataByID`
   when the old `GetFactionInfoByID` is gone; the book's tabs fall back to
   `PanelTabButtonTemplate` when the character sheet's template is missing;
   chat links fall back to `SetItemRef` without `LinkUtil`.
6. ✅ **Content gating:** `client: forever|classic` front matter;
   `[forever]` / `[classic]` paragraphs. Counts, chapters, search and
   achievements follow the reader's game.
7. ✅ **Forever variants:** the furbolgs (Azshara's hold is Blackmaw Hold) and
   Stormwind (its harbour). **Waiting for Forever's texts (scan):** the
   Greymane Wall (the Ruins of Gilneas), Dalaran (the city as a dungeon), the
   Shen'dralar (the Shal'nan's rebellion, told in Forever's books), Moonglade
   and Mount Hyjal, and any found in testing.
8. ✅ **Skyborne foreword** (`foreword-skyborne`, race token `Skyborne`, from
   the beta's ChrRaces; lore from Forever's Skyborne texts as the Warcraft
   Wiki reports them).
9. ✅ **`/codex scan on|off|clear`:** account-wide (`LorekeepersCodexScan`):
   areas, creatures (id, name, level, where), quests (id, title, texts,
   giver), NPC gossip, books, race tokens. `scripts/scan-export.lua` turns the
   SavedVariables file into JSON.
10. ✅ **Simulation:** `FOREVER=1 luajit addon/test/sim.lua` (no combat log,
    secret values, `C_Reputation`), in `bun run check`, CI and releases.
11. ✅ **Release:** both zips attached to each GitHub release (and uploaded to
    CurseForge per game once the project exists).

### To test on the beta

Install `dist/forever/LorekeepersCodex` (after `bun run package`) into
`World of Warcraft/_classic_beta_/Interface/AddOns/`.


- The addon loads without "out of date" or Lua errors.
- Targeting a creature unlocks its people's page (a Frostmane troll, say).
- A reputation page (Ironforge friendly) and a quest page unlock.
- Tooltip hints appear in the open world, and nothing errors in a dungeon.
- The book opens, both tabs work, links in chat open the book.
- A Skyborne character gets the Skyborne foreword.
- `/codex scan on`, play a while, log out: the SavedVariables file holds data.

## Wave 2: Forever's content

New chapters from Forever's texts, written like the others: the Riverglades,
Shen'dralas, Mount Hyjal, the Ruins of Gilneas, Zephras Isle, pages for the
nine new dungeons and the raids, and new pages in the old zones (Stormwind
Harbor, Excavation Site: Wetlands, Old Dalaran…). All `client: forever`.
Chapter achievements come with them on their own.

**Started 9 October 2026, on the beta's playable content** (the user's
decision: what the data allows now, the high-level zones after launch). The
texts are Forever's quest texts, NPC dialogue and in-game crystals as the
Warcraft Wiki and Wowhead's Forever database report them, with Blizzard's own
articles; ids from AllTheThings' Forever database and QuestieDB's traces of
the beta. Forever's areas: `data/areas-forever.json` (`bun scripts/areas.ts
--forever`, the beta build pinned, only Forever's pages may name them).

- ✅ **Zephras Isle** (chapter `zephras-isle`, order 0): the isle, Valanaar,
  High Elder Talaanis Shadowsong, the High Order, the Windshapers, the
  Al'Aketh, the Shrine of Akir, the Shal'nan, the Silence of the Winds.
- ✅ **The Ruins of Lordaeron** (Tirisfal) and **the Hall of Thanes** (Dun
  Morogh): pages of their own.
- ✅ **Dalaran**: a `[forever]` paragraph (the city as a dungeon, the
  disruption, the High Order's appeal).
- **Waiting for texts:** Excavation Site: Wetlands (only its objectives are
  known), the Riverglades, Shen'dralas, Mount Hyjal, Gilneas, the other new
  dungeons and the raids; and, on Zephras Isle, the cutscenes (Rohash and
  Lorthuna on the spires), the crystals' full texts and the Nightclaw druids.

## Open points

- `16001` comes from community guides: check the client accepts it (no "out
  of date" warning).
- Whether creature GUIDs are secret outside instances (the hint and meeting
  unlocks depend on them): the addon copes either way, but unlocks would only
  happen where they are not.
