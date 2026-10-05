# Lorekeeper's Codex on World of Warcraft: Forever

Forever (beta since 17 September 2026, launch 4 November 2026) is the original
Azeroth on the modern Mainline client. The addon must run on both clients from
one package. This plan records the decisions and the work, in two waves.

## Decisions

| Question | Decision |
|---|---|
| Kill unlocks (Forever has no combat log for addons) | **Meeting counts, on Forever only:** targeting a creature, alive or dead, unlocks the pages its kill would. Classic keeps unlocking on the kill. |
| Forever's new content | **Second wave**, after launch, once zones and quest texts settle. |
| Lore sources for Forever-only pages | **Forever's own texts** (quests, NPCs, books), and only Forever readers see those pages. Original pages keep the pre-WotLK rule. |
| Original pages contradicted by Forever | **Forever variants:** Forever-only paragraphs or replacement text; Classic readers see the original. |
| Skyborne | **Their own foreword now**, written during the port from what the beta shows of them and Zephras Isle. |
| Packaging | **One zip, two TOCs**, one version and changelog. |
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

## Wave 1: the port (before launch)

1. **Two TOCs:** `LorekeepersCodex.toc` (Classic Era, TBC) as now, and
   `LorekeepersCodex_Camelot.toc` with `## Interface: 16001` (the beta's
   value; check it at launch). The Forever TOC also loads `Forever.lua`.
2. **Client flag:** `ns.forever`, set by `Forever.lua` (only the Forever TOC
   loads it), so the code never guesses from the build.
3. **Combat log:** registered only on Classic. Registering it on Forever
   throws, and our event loop would stop there.
4. **Meeting counts (Forever):** on target and mouseover, a creature's kill
   pages unlock too. The tooltip hint keeps working (same ids).
5. **Secret values:** `issecretvalue` checks before using a GUID or a name
   (tooltip hint, target, `/codex where`).
6. **Content gating:** front matter `client: forever` (Forever-only pages) and
   `client: classic`; per-paragraph variants (`<!-- forever -->` blocks, or a
   `forever:` replacement for a whole paragraph). The build emits both; the
   addon shows what fits the client. Counts, chapters and achievements follow.
7. **Forever variants of contradicted pages:** at least the Greymane Wall (the
   Ruins of Gilneas are open), the furbolgs (Blackmaw Hold), Stormwind (its
   harbour), Dalaran (the city as a dungeon), and any found in testing.
8. **Skyborne foreword:** their race token (from `UnitRace` on a Skyborne
   character, via `/codex scan`) and a foreword from Forever's texts.
9. **`/codex scan`:** records, per character, every area entered (id and
   name), NPC targeted (id, name, zone) and quest accepted or turned in (id,
   title, text), in a saved table the build can read, for the second wave.
10. **Simulation:** a Forever mode (no combat log, secret values, the
    `_Camelot` TOC's file list) beside the Classic one.
11. **Release:** the release zip holds both TOCs; the README says which
    clients are supported.

## Wave 2: Forever's content (after launch)

New chapters from the scan data and Forever's texts, written like the others:
the Riverglades, Shen'dralas, Mount Hyjal, the Ruins of Gilneas, Zephras Isle,
pages for the nine new dungeons and the raids, and new pages in the old zones
(Stormwind Harbor, Excavation Site: Wetlands, Old Dalaran…). All
`client: forever`. Chapter achievements come with them on their own.

## Open points

- The `_Camelot` TOC suffix and `16001` come from community guides: check
  both on the beta client.
- Whether `UnitGUID` of creatures is secret outside instances (the hint and
  meeting unlocks depend on it): test on the beta.
- `CharacterFrameTabButtonTemplate` on Mainline: if missing, switch the book's
  tabs to `PanelTabButtonTemplate` on Forever.
