# Vanilla lore review

Review date: 5 October 2026. Baseline: `b90f546` on `main`.

Read all **344 entries** (335 chapter pages and nine forewords) and all **42 chapter summaries**. Corrected **145 entries** and one chapter summary. The tables below cover every source file; [the JSON ledger](lore-review.json) records content hashes and the NPC/quest records checked.

This is a complete **entry-level review**, not a claim that every sentence is independently certified. **1 entry has a user-approved editorial exception.** The [follow-up on all fourteen original gaps](lore-gap-follow-up.md) records the web sources and their resolution. The exception is listed first. An unchanged page means no concrete correction was identified in the evidence consulted; it does not mean that a quest about the same place proves every historical or descriptive claim in that page.

The subsequent [voice pass](voice-review.md) reviewed all entries and reworked 161. The findings below describe the preceding factual audit; current content hashes and voice decisions are recorded together in the JSON ledger. The voice pass also aligned two stale cross-references with previously checked evidence: Tirion’s river location in the Eastern Plaguelands overview, and Arugal’s Dalaran summoning context in the worgen entry.

## Scope and source handling

The event boundary is original WoW through patch 1.12, including its dungeon, raid and battleground stories. TBC, Wrath, Cataclysm, retail and Season of Discovery events and later retcons are excluded. An old publication can describe events beyond Vanilla; publication date alone is not enough to admit a claim.

The repository permits the early games, their manuals, Vanilla quest/dialogue/book/item text and named early novels. The anonymous archivist is an editorial device. The narrator’s opinions can provide voice, but invented visits, conversations, deaths, hunter testimony and institutional customs cannot provide lore evidence. Many such passages were removed. The user subsequently approved retaining Timber’s original hunter tale as flavour text without an in-entry label; this exception does not establish canonical support.

The bulk quest and book cross-check used the [CMaNGOS Classic database](https://github.com/cmangos/classic-db/blob/28ef6259c782928b08a8dc9cacf6bc02e64f2b29/Full_DB/ClassicDB_1_12_1_z2815.sql.gz), pinned to commit `28ef6259c782928b08a8dc9cacf6bc02e64f2b29`. This is a community reconstruction, **not an official Blizzard archive**. Tables consulted were `quest_template`, `page_text`, `npc_text`, `script_texts`, `creature_template`, quest relations and readable book objects. Later and unused rows exist in the snapshot: for example, Operation Gnomeregan dialogue and unrelated Hyjal dialogue were excluded. A low numerical ID is not proof that a row belongs to Vanilla.

Quest links in the inventory are convenient **locators for the transcript consulted in that reconstruction**. They are not a claim that every linked Wowhead page was independently fetched. Book references give the readable object’s title where available and its page-table identifier. Similarity search was used to find candidate passages; unrelated matches were discarded and never treated as corroboration.

The [Warcraft II: Battle.net Edition manual scan](https://downloads.war2.ru/war2/Info%20%26%20Media%20content/Documents/War2BNE_Manual_EN.pdf), published by Blizzard in 1999 and mirrored by a third party, was opened directly; page 67 verifies Rend and Maim’s Black Tooth Grin leadership. This does not establish the later flight chronology, which was removed.

Live source checks included [Operation Recombobulation’s quest context](https://www.wowhead.com/classic/quest=412), [The Grand Betrayal](https://www.wowhead.com/classic/quest=2929/the-grand-betrayal), [The Fate of Yenniku](https://www.wowhead.com/classic/quest=588/the-fate-of-yenniku), [The Platinum Discs](https://www.wowhead.com/classic/quest=2278/the-platinum-discs), [Drakefire Amulet](https://www.wowhead.com/classic/quest=6502/drakefire-amulet), and Blizzard’s [Altar of Storms description](https://classic.battle.net/war2/popup/oaltarofstorms.htm). Wiki pages were used for source routing and era checks, including the [Lore Keeper’s dialogue transcript](https://warcraft.wiki.gg/wiki/Lorekeeper_of_Norgannon), [Stormwind Harbor’s introduction](https://warcraft.wiki.gg/wiki/Stormwind_Harbor) and [Varo’then’s changing locations](https://warcraft.wiki.gg/wiki/Captain_Varo%27then). Wiki summaries of novels are not equivalent to checking the novels themselves. The subsequent targeted web review did locate and check the relevant novel passages; see the [gap follow-up](lore-gap-follow-up.md) for chapters, source links and qualifications.

The source policy in `CLAUDE.md` has been corrected: it required publications before Wrath but listed *Night of the Dragon*. The [publisher dates that book to 18 November 2008](https://www.simonandschuster.com/books/World-of-Warcraft-Night-of-the-Dragon/Richard-A-Knaak/WORLD-OF-WARCRAFT/9780743471374), after Wrath’s release. The contradictory listing was removed. This audit did not use it to introduce any lore. The stricter Vanilla event boundary governed the changes.

## Findings that recur across entries

- Radiation failed to eradicate Gnomeregan’s troggs; it did not clear them out. Q412 and Q2929 support the revised account.
- Bloodscalp custody of Yenniku was an initial suspicion. Q588 names Zanzil; Q592 describes freeing Yenniku from his control.
- Celebras calls Zaetar his uncle in Q7046. He is a nephew, not Zaetar’s son.
- Vanilla Q933 says Malfurion’s fate is unknown. A definite present body location in Moonglade was removed from related entries.
- Stromgarde’s surviving defenders, Syndicate and ogres occupy the keep. The Witherbark are elsewhere in Arathi. Q645 locates Trol’kalar in a warded tomb.
- Onyxia’s wards are passed using the Drakefire Amulet. The Emberstrife illusion belongs to a different stage of the Horde chain.
- Taelan dies before Tirion arrives in the *In Dreams* event. His father subsequently holds his body.
- The cauldron chains develop counteragents to weaken the Scourge. **Eight cauldrons** is explicitly stated in Q5215/Q5228 and was retained even though only four western cauldrons are quest objectives.
- **Five years since the last war** appears in Q9033 and was retained rather than normalised against a later timeline.
- **High Thane Falstad** is used in Q1449. It was retained; a differing version of the expedition statue inscription alone would not justify changing it.
- Dire Maul’s northern clan is Gordok; Felpaw are wolves; Timbermaw’s passage connects Felwood, Moonglade and Winterspring, with a separate hold in Azshara.
- Stormwind Harbor, a direct Auberdine–Theramore boat and an inn at Vanilla Sentinel Hill do not belong in the described setting.
- Fixed seasonal durations, invented yearly scout observations, power rankings and narrator eyewitness anecdotes were removed where no source supported them.

## User-approved editorial exception

The user approved retaining Timber’s original flavour text without an in-entry label. Its hunter tale has no canonical support in the sources consulted. The thirteen original source gaps were resolved through the web follow-up. No later retcon was substituted to fill a gap.

| Entry | Approved exception / source limit |
| --- | --- |
| [Timber](../content/dun-morogh/timber.md) | Classic NPC 1132 confirms the named white wolf. Targeted web searches found no canonical backstory; The user explicitly approved retaining the original hunter tale as flavour text without an in-entry label; it is not source-verified lore. |

## Entry-by-entry record

**Corrected** means the listed change was applied. **Reviewed** means read and cross-checked to the extent described above, with no specific change identified. **Editorial exception** marks Timber’s original flavour text, retained at the user’s explicit request. The previous primary-text gaps are resolved in the linked follow-up. **Framing** covers the forewords. References support their own topics, not every sentence. Correction-basis detail and exact IDs are also retained in the JSON ledger.

### alterac

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Alterac Mountains](../content/alterac/alterac-mountains.md) | Reviewed | [Q500: Crushridge Bounty](https://www.wowhead.com/classic/quest=500) | No correction identified. |
| [Alterac Valley](../content/alterac/alterac-valley.md) | Reviewed | [Q7261: The Sovereign Imperative](https://www.wowhead.com/classic/quest=7261); [Q7141: The Battle of Alterac](https://www.wowhead.com/classic/quest=7141) | No correction identified. |
| [Dalaran](../content/alterac/dalaran.md) | Reviewed | [Q602: Magical Analysis](https://www.wowhead.com/classic/quest=602) | No correction identified. |
| [The Frostwolf Clan](../content/alterac/frostwolf-clan.md) | Corrected | The New Horde (page 2034); In-game books: The Dark Portal and the Fall of Stormwind, page 1964; The New Horde, page 2034 | Distinguished refusal of demon blood from the later exile for opposing the warlocks. |
| [Ravenholdt Manor](../content/alterac/ravenholdt-manor.md) | Corrected | [Q8233: A Simple Request](https://www.wowhead.com/classic/quest=8233); Quest 6681 | Removed invented narrator testimony or unsupported universal claims. |
| [The Stormpike Guard](../content/alterac/stormpike-guard.md) | Corrected | [Q7261: The Sovereign Imperative](https://www.wowhead.com/classic/quest=7261); [Q7142: The Battle for Alterac](https://www.wowhead.com/classic/quest=7142); Q7261 The Sovereign Imperative; Q7142 The Battle for Alterac | Removed invented personal acquaintance and retained the two sides’ documented conflict. |
| [The Treason of Alterac](../content/alterac/treason-of-alterac.md) | Corrected | [Q512: Noble Deaths](https://www.wowhead.com/classic/quest=512); [Q506: Blackmoore's Legacy](https://www.wowhead.com/classic/quest=506); [Q507: Lord Aliden Perenolde](https://www.wowhead.com/classic/quest=507); [Q538: Southshore](https://www.wowhead.com/classic/quest=538); [Day of the Dragon, ch. 1–2](https://public.ds003.info/wcbooks/novels/Warcraft%20-%20%282001%29%20Day%20Of%20The%20Dragon%20-%20Richard%20A.%20Knaak.pdf#page=3); Day of the Dragon, chapters 1–2; Q506 Blackmoore’s Legacy; Q512 Noble Deaths | Replaced a completed partition with the documented dispute and martial law; distinguished Aliden’s leadership from an unproved founding claim. |

### arathi

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Arathi Basin](../content/arathi/arathi-basin.md) | Reviewed | [Q8120: The Battle for Arathi Basin!](https://www.wowhead.com/classic/quest=8120) | No correction identified. |
| [Arathi Highlands](../content/arathi/arathi-highlands.md) | Corrected | In-game page 258 (page 258); Vanilla map: Stromgarde Keep; Quest 639 | Corrected the occupants of Stromgarde. |
| [Hammerfall](../content/arathi/hammerfall.md) | Reviewed | [Q655: Hammerfall](https://www.wowhead.com/classic/quest=655) | No correction identified. |
| [Myzrael](../content/arathi/myzrael.md) | Corrected | [Q636: Legends of the Earth](https://www.wowhead.com/classic/quest=636); Quest 636; Quest 656 | Removed conflation of Myzrael’s prison with all four Circles of Binding; attributed the warning to its source. |
| [Refuge Pointe](../content/arathi/refuge-pointe.md) | Reviewed | [Q634: Plea To The Alliance](https://www.wowhead.com/classic/quest=634) | No correction identified. |
| [Stromgarde Keep](../content/arathi/stromgarde-keep.md) | Corrected | [Q639: Sigil of Strom](https://www.wowhead.com/classic/quest=639); Quests 639, 645, 646; Vanilla map: Stromgarde Keep | Corrected occupants and located the protected sword rather than treating it as a rumour. |
| [Thoradin's Wall](../content/arathi/thoradins-wall.md) | Reviewed | Arathor and the Troll Wars (page 1875) | No correction identified. |

### ashenvale

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Ashenvale](../content/ashenvale/ashenvale.md) | Corrected | Archimonde's Return and the Flight to Kalimdor (page 2077); Warcraft III orc campaign: The Hunter of Shadows | Corrected the implication that the Warsong released the invading Legion into Ashenvale. |
| [Astranaar](../content/ashenvale/astranaar.md) | Corrected | [Q1133: Journey to Astranaar](https://www.wowhead.com/classic/quest=1133); Vanilla map: Astranaar | Corrected visible settlement geography. |
| [Blackfathom Deeps](../content/ashenvale/blackfathom-deeps.md) | Reviewed | [Q6563: The Essence of Aku'Mai](https://www.wowhead.com/classic/quest=6563) | No correction identified. |
| [Demon Fall Canyon](../content/ashenvale/demon-fall-canyon.md) | Reviewed | [Q8150: Honoring a Hero](https://www.wowhead.com/classic/quest=8150) | No correction identified. |
| [Splintertree Post](../content/ashenvale/splintertree-post.md) | Reviewed | [Q235: The Ashenvale Hunt](https://www.wowhead.com/classic/quest=235) | No correction identified. |
| [Warsong Gulch](../content/ashenvale/warsong-gulch.md) | Corrected | [Q8372: Fight for Warsong Gulch](https://www.wowhead.com/classic/quest=8372); Quests 8372, 8402 | Removed invented narrator testimony or unsupported universal claims. |
| [The Warsong Lumber Camp](../content/ashenvale/warsong-lumber-camp.md) | Reviewed | Monument to Grom Hellscream (page 2211) | No correction identified. |

### azshara

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Azshara](../content/azshara/azshara.md) | Reviewed | [Q3449: Arcane Runes](https://www.wowhead.com/classic/quest=3449) | No correction identified. |
| [Azuregos](../content/azshara/azuregos.md) | Corrected | [Q8555: The Charge of the Dragonflights](https://www.wowhead.com/classic/quest=8555); [Q8575: Azuregos's Magical Ledger](https://www.wowhead.com/classic/quest=8575); [Q8576: Translating the Ledger](https://www.wowhead.com/classic/quest=8576); [Q8729: The Wrath of Neptulon](https://www.wowhead.com/classic/quest=8729); Quests 8555, 8575, 8576, 8729 | Removed untraced Vials of Eternity speculation and replaced it with the Vanilla blue-shard quest account. |
| [The Hydraxian Waterlords](../content/azshara/hydraxian-waterlords.md) | Reviewed | [Q6823: Agent of Hydraxis](https://www.wowhead.com/classic/quest=6823) | No correction identified. |
| [The Ravencrest Monument](../content/azshara/ravencrest-monument.md) | Corrected | [The Well of Eternity, ch. 18](https://public.ds003.info/wcbooks/novels/Warcraft%20-%20%282004%29%20War%20Of%20The%20Ancients%20Trilogy%20-%2001%20-%20The%20Well%20Of%20Eternity%20-%20Richard%20A.%20Knaak.pdf#page=160); [The Demon Soul, ch. 2](https://public.ds003.info/wcbooks/novels/Warcraft%20-%20%282004%29%20War%20Of%20The%20Ancients%20Trilogy%20-%2002%20-%20The%20Demon%20Soul%20-%20Richard%20A.%20Knaak.PDF#page=10); The Well of Eternity, chapter 18; The Demon Soul, chapter 2; Vanilla area name and visible monument; Varo’then’s Vanilla location is Shadowsong Shrine, not this monument | Removed the unrelated Varo’then trigger; verified Ravencrest’s role without asserting an unproved statue honoree or builder. |
| [The Ruins of Eldarath](../content/azshara/ruins-of-eldarath.md) | Reviewed | [Q3449: Arcane Runes](https://www.wowhead.com/classic/quest=3449) | No correction identified. |
| [The Sundering](../content/azshara/the-sundering.md) | Reviewed | Archimonde's Return and the Flight to Kalimdor (page 2082); [The Sundering, ch. 20–21](https://public.ds003.info/wcbooks/novels/Warcraft%20-%20%282005%29%20War%20Of%20The%20Ancients%20Trilogy%20-%2003%20-%20The%20Sundering%20-%20Richard%20A.%20Knaak.PDF#page=159) | No correction identified. |

### badlands

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Hammertoe's Digsite](../content/badlands/hammertoes-digsite.md) | Reviewed | [Q720: A Sign of Hope](https://www.wowhead.com/classic/quest=720) | No correction identified. |
| [Kargath](../content/badlands/kargath.md) | Reviewed | [Q4081: KILL ON SIGHT: Dark Iron Dwarves](https://www.wowhead.com/classic/quest=4081) | No correction identified. |
| [The Platinum Discs](../content/badlands/platinum-discs.md) | Corrected | [Q2278: The Platinum Discs](https://www.wowhead.com/classic/quest=2278); Quest 2278; Lore Keeper of Norgannon dialogue | Removed invented narrator testimony or unsupported universal claims. |
| [The Badlands](../content/badlands/the-badlands.md) | Reviewed | [Q705: Pearl Diving](https://www.wowhead.com/classic/quest=705); [Q2398: The Lost Dwarves](https://www.wowhead.com/classic/quest=2398) | No correction identified. |
| [Uldaman](../content/badlands/uldaman.md) | Reviewed | [Q2398: The Lost Dwarves](https://www.wowhead.com/classic/quest=2398); [Q2278: The Platinum Discs](https://www.wowhead.com/classic/quest=2278) | No correction identified. |

### barrens

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Agamaggan](../content/barrens/agamaggan.md) | Reviewed | In-game page 431 (page 431) | No correction identified. |
| [Bael Modan](../content/barrens/bael-modan.md) | Corrected | [Q843: Gann's Reclamation](https://www.wowhead.com/classic/quest=843); Quests 843, 849 | Replaced unverified sole-survivor and massacre claims with Gann’s attributed account. |
| [The Oases](../content/barrens/barrens-oases.md) | Reviewed | [Q870: The Forgotten Pools](https://www.wowhead.com/classic/quest=870) | No correction identified. |
| [Camp Taurajo](../content/barrens/camp-taurajo.md) | Reviewed | [Q5052: Blood Shards of Agamaggan](https://www.wowhead.com/classic/quest=5052) | No correction identified. |
| [The Druids of the Fang](../content/barrens/druids-of-the-fang.md) | Reviewed | [Q914: Leaders of the Fang](https://www.wowhead.com/classic/quest=914) | No correction identified. |
| [The Mor'shan Rampart](../content/barrens/morshan-rampart.md) | Corrected | [Q911: Gateway to the Frontier](https://www.wowhead.com/classic/quest=911); Quest 911; Vanilla map: The Mor’shan Rampart | Removed unsupported universal claims about supply and raid routes. |
| [Northwatch Hold](../content/barrens/northwatch-hold.md) | Corrected | [Q891: The Guns of Northwatch](https://www.wowhead.com/classic/quest=891); Quest 891 | Removed unsupported travel duration and attributed accusations about Northwatch’s gunners. |
| [Ratchet](../content/barrens/ratchet.md) | Reviewed | [Q8366: Southsea Shakedown](https://www.wowhead.com/classic/quest=8366) | No correction identified. |
| [Razorfen Downs](../content/barrens/razorfen-downs.md) | Reviewed | [Q3341: Bring the End](https://www.wowhead.com/classic/quest=3341) | No correction identified. |
| [Razorfen Kraul](../content/barrens/razorfen-kraul.md) | Corrected | In-game page 433 (page 433); Quest 1100; Quest 1101; Pages 430–435: Lonebrow’s journal | Corrected invented expedition membership and blanket failure to escape; removed narrator acquaintance. |
| [The Barrens](../content/barrens/the-barrens.md) | Reviewed | [Q886: The Barrens Oases](https://www.wowhead.com/classic/quest=886); [Q5041: Supplies for the Crossroads](https://www.wowhead.com/classic/quest=5041) | No correction identified. |
| [The Crossroads](../content/barrens/the-crossroads.md) | Corrected | [Q844: Plainstrider Menace](https://www.wowhead.com/classic/quest=844); [Q5041: Supplies for the Crossroads](https://www.wowhead.com/classic/quest=5041); Quests 844, 851, 5041; NPC 3338: Sergra Darkthorn | Removed unsupported identification of Sergra as a shaman commanding the settlement. |
| [Wailing Caverns](../content/barrens/wailing-caverns.md) | Corrected | [Q1487: Deviate Eradication](https://www.wowhead.com/classic/quest=1487); [Q914: Leaders of the Fang](https://www.wowhead.com/classic/quest=914); Vanilla dungeon event: Disciple of Naralex | Corrected the disciple’s starting location and escort sequence. |

### blackrock-mountain

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Blackrock Depths](../content/blackrock-mountain/blackrock-depths.md) | Corrected | [Q7201: The Last Element](https://www.wowhead.com/classic/quest=7201); Q7201 The Last Element; Q4241 Marshal Windsor; Q4003 The Royal Rescue | Removed an invented narrator visit. |
| [Blackrock Mountain](../content/blackrock-mountain/blackrock-mountain.md) | Reviewed | War of the Three Hammers (page 1925) | No correction identified. |
| [Blackrock Spire](../content/blackrock-mountain/blackrock-spire.md) | Corrected | [Q4974: For The Horde!](https://www.wowhead.com/classic/quest=4974); Q4974 For The Horde!; Q6502 Drakefire Amulet; visible Vanilla Blackrock Spire | Removed unverified post-war takeover chronology; retained the Vanilla occupants and chain of command. |
| [Blackwing Lair](../content/blackrock-mountain/blackwing-lair.md) | Corrected | [Q8288: Only One May Rise](https://www.wowhead.com/classic/quest=8288); Vanilla raid: Blackwing Lair | Removed the mistaken placement of Vaelastrasz before the first encounter, Razorgore. |
| [Emperor Dagran Thaurissan](../content/blackrock-mountain/dagran-thaurissan.md) | Corrected | [Q4362: The Fate of the Kingdom](https://www.wowhead.com/classic/quest=4362); Vanilla item 11684: Ironfoe | Removed unverified former ownership of Ironfoe. |
| [Princess Moira Bronzebeard](../content/blackrock-mountain/moira-bronzebeard.md) | Corrected | [Q4362: The Fate of the Kingdom](https://www.wowhead.com/classic/quest=4362); Quests 4003, 4362, 4363 | Distinguished Magni’s belief from Moira’s own account without inventing narrator testimony. |
| [Molten Core](../content/blackrock-mountain/molten-core.md) | Reviewed | [Q6822: The Molten Core](https://www.wowhead.com/classic/quest=6822) | No correction identified. |
| [Nefarian](../content/blackrock-mountain/nefarian.md) | Corrected | [Q6502: Drakefire Amulet](https://www.wowhead.com/classic/quest=6502); [Q7783: The Lord of Blackrock](https://www.wowhead.com/classic/quest=7783); Q6502 Drakefire Amulet; Q7783 The Lord of Blackrock; Q4974 For The Horde! | Removed unverified orders from Deathwing, arrival chronology and a universal power comparison. |
| [Ragnaros](../content/blackrock-mountain/ragnaros.md) | Corrected | War of the Three Hammers (page 1924); In-game book: War of the Three Hammers | Removed a date inconsistent with the War of the Three Hammers account. |
| [Warchief Rend Blackhand](../content/blackrock-mountain/rend-blackhand.md) | Corrected | [Q4974: For The Horde!](https://www.wowhead.com/classic/quest=4974); Warcraft II: Battle.net Edition manual, p. 67 (Black Tooth Grin); Q4941 Eitrigg’s Wisdom; Q4974 For The Horde! | Retained manual-attested parentage and clan leadership; removed unverified flight chronology and the novel’s envoy scene. |

### blasted-lands

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Blasted Lands](../content/blasted-lands/blasted-lands.md) | Reviewed | [Q1425: Deliver the Shipment](https://www.wowhead.com/classic/quest=1425); [Q2681: The Stones That Bind Us](https://www.wowhead.com/classic/quest=2681) | No correction identified. |
| [Lord Kazzak](../content/blasted-lands/lord-kazzak.md) | Corrected | NPC 12397; Vanilla encounter: Lord Kazzak | Removed an unsupported universal power ranking. |
| [Nethergarde Keep](../content/blasted-lands/nethergarde-keep.md) | Corrected | [Q1364: Mazen's Behest](https://www.wowhead.com/classic/quest=1364); [Beyond the Dark Portal, ch. 2 — sample](https://www.everand.com/book/224399351/World-of-Warcraft-Beyond-the-Dark-Portal); [Warcraft II expansion manual — Aftermath of the Second War](https://oldgamesdownload.com/manual/warcraft-ii-beyond-the-dark-portal-dos-windows-manual-english/); Beyond the Dark Portal, chapter 2 (Everand sample); Warcraft II expansion manual and Alliance mission 2; Q1477 Vital Supplies; Q1364 Mazen’s Behest | Verified funding and purpose in the novel sample; removed an unsupported first-target ranking. |
| [Razelikh the Defiler](../content/blasted-lands/razelikh-the-defiler.md) | Reviewed | [Q3628: You Are Rakh'likh, Demon](https://www.wowhead.com/classic/quest=3628) | No correction identified. |
| [The Dark Portal](../content/blasted-lands/the-dark-portal.md) | Corrected | The Dark Portal and the Fall of Stormwind (page 1963); Warcraft II: Beyond the Dark Portal ending; Vanilla location: The Dark Portal | Distinguished the destroyed connection from the standing Vanilla structure and avoided asserting future impossibility of return. |

### burning-steppes

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [The Altar of Storms](../content/burning-steppes/altar-of-storms.md) | Reviewed | [Q7562: Mor'zul Bloodbringer](https://www.wowhead.com/classic/quest=7562) | No correction identified. |
| [Burning Steppes](../content/burning-steppes/burning-steppes.md) | Reviewed | [Q4182: Dragonkin Menace](https://www.wowhead.com/classic/quest=4182); [Q3821: Dreadmaul Rock](https://www.wowhead.com/classic/quest=3821) | No correction identified. |
| [Marshal Windsor](../content/burning-steppes/marshal-windsor.md) | Corrected | [Q4241: Marshal Windsor](https://www.wowhead.com/classic/quest=4241); Quests 4241, 4242, 4282 | Removed unverified Ironfoe ownership and capture circumstances. |
| [Morgan's Vigil](../content/burning-steppes/morgans-vigil.md) | Reviewed | [Q4322: Jail Break!](https://www.wowhead.com/classic/quest=4322) | No correction identified. |
| [The Ruins of Thaurissan](../content/burning-steppes/ruins-of-thaurissan.md) | Corrected | [Q4296: Tablet of the Seven](https://www.wowhead.com/classic/quest=4296); In-game book: War of the Three Hammers; Quest 3701 | Removed a date inconsistent with the War of the Three Hammers account. |

### darkshore

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Auberdine](../content/darkshore/auberdine.md) | Corrected | [Q6341: The Bounty of Teldrassil](https://www.wowhead.com/classic/quest=6341); [Q942: The Absent Minded Prospector](https://www.wowhead.com/classic/quest=942); Vanilla transport routes | Removed a nonexistent direct Vanilla Auberdine–Theramore boat. |
| [Darkshore](../content/darkshore/darkshore.md) | Reviewed | [Q3524: Washed Ashore](https://www.wowhead.com/classic/quest=3524); [Q984: How Big a Threat?](https://www.wowhead.com/classic/quest=984) | No correction identified. |
| [The Highborne Ruins](../content/darkshore/highborne-ruins.md) | Reviewed | [Q963: For Love Eternal](https://www.wowhead.com/classic/quest=963) | No correction identified. |
| [The Master's Glaive](../content/darkshore/masters-glaive.md) | Reviewed | [Q944: The Master's Glaive](https://www.wowhead.com/classic/quest=944) | No correction identified. |
| [Onu](../content/darkshore/onu.md) | Corrected | [Q948: Onu](https://www.wowhead.com/classic/quest=948); Quest 944 | Removed unverified age and invented personal conversation; replaced with documented quest actions. |
| [Remtravel's Excavation](../content/darkshore/remtravels-excavation.md) | Corrected | [Q729: The Absent Minded Prospector](https://www.wowhead.com/classic/quest=729); Quests 729, 741, 942 | Removed invented narrator examination and an unsupported age for the fossil. |
| [The Tower of Althalaxx](../content/darkshore/tower-of-althalaxx.md) | Corrected | [Q966: The Tower of Althalaxx](https://www.wowhead.com/classic/quest=966); Quests 965, 966, 967 | Corrected the claim that the watcher disappeared. |

### deadwind-pass

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Deadwind Pass](../content/deadwind-pass/deadwind-pass.md) | Corrected | Vanilla map: Deadwind Pass; In-game book: The Last Guardian | Removed an unsupported causal link between Medivh’s death and the valley’s condition. |
| [Karazhan](../content/deadwind-pass/karazhan.md) | Corrected | Vanilla location: Karazhan; In-game books: The Last Guardian; The New Horde | Removed unverified visions in the Vanilla setting and avoided importing the later raid. |

### desolace

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Desolace](../content/desolace/desolace.md) | Reviewed | [Q1387: Centaur Bounty](https://www.wowhead.com/classic/quest=1387); [Q1385: Brutal Politics](https://www.wowhead.com/classic/quest=1385) | No correction identified. |
| [The Khans of Desolace](../content/desolace/khans-of-desolace.md) | Corrected | [Q1368: Gelkis Alliance](https://www.wowhead.com/classic/quest=1368); Q1367 Magram Alliance; Q1368 Gelkis Alliance | Removed untraced clan-by-clan ancestry and universal hostility; retained the attested rivalry. |
| [The Kodo Graveyard](../content/desolace/kodo-graveyard.md) | Reviewed | [Q5501: Bone Collector](https://www.wowhead.com/classic/quest=5501) | No correction identified. |
| [Mannoroc Coven](../content/desolace/mannoroc-coven.md) | Reviewed | [Q5581: Portals of the Legion](https://www.wowhead.com/classic/quest=5581) | No correction identified. |
| [Maraudon](../content/desolace/maraudon.md) | Corrected | [Q7028: Twisted Evils](https://www.wowhead.com/classic/quest=7028); Quest 7046 | Corrected Celebras’s relationship to Zaetar. |
| [Nijel's Point](../content/desolace/nijels-point.md) | Reviewed | [Q1387: Centaur Bounty](https://www.wowhead.com/classic/quest=1387) | No correction identified. |
| [Shadowprey Village](../content/desolace/shadowprey-village.md) | Reviewed | [Q5581: Portals of the Legion](https://www.wowhead.com/classic/quest=5581); [Q5386: Catch of the Day](https://www.wowhead.com/classic/quest=5386) | No correction identified. |
| [Zaetar and Theradras](../content/desolace/zaetar-and-theradras.md) | Reviewed | [Q7065: Corruption of Earth and Seed](https://www.wowhead.com/classic/quest=7065) | No correction identified. |

### dun-morogh

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Coldridge Valley](../content/dun-morogh/coldridge-valley.md) | Corrected | In-game page 86 (page 86); Quests 170, 182, 218; Vanilla location: Anvilmar | Removed universal recruitment claims and invented trainer motives and assurances of safety. |
| [The Deeprun Tram](../content/dun-morogh/deeprun-tram.md) | Corrected | [Q6662: Me Brother, Nipsy](https://www.wowhead.com/classic/quest=6662); Vanilla location: Deeprun Tram | Removed invented reception and inauguration anecdotes; avoided an unchecked construction date. |
| [Dun Morogh](../content/dun-morogh/dun-morogh.md) | Corrected | In-game page 88 (page 88); Vanilla map: Dun Morogh | Removed unsupported nine-month climate and universal childhood claims. |
| [The Explorers' League](../content/dun-morogh/explorers-league.md) | Reviewed | [Q2439: The Platinum Discs](https://www.wowhead.com/classic/quest=2439); [Q2963: Portents of Uldum](https://www.wowhead.com/classic/quest=2963) | No correction identified. |
| [The Frostmane Trolls](../content/dun-morogh/frostmane-trolls.md) | Corrected | [Q287: Frostmane Hold](https://www.wowhead.com/classic/quest=287); Quest 182; Quest 287; Page 88; NPCs 1121, 1397 | Removed untraced conquest history, seasonal raid claims, and invented tactical advice. |
| [The Gates of Khaz Modan](../content/dun-morogh/gates-of-ironforge.md) | Corrected | [Q267: The Trogg Threat](https://www.wowhead.com/classic/quest=267); Quest 267; Vanilla map: Dun Morogh | Removed invented checkpoint behaviour and claims that the gates defeated every invading army. |
| [The Gnomeregan Exiles](../content/dun-morogh/gnomeregan-exiles.md) | Reviewed | [Q2929: The Grand Betrayal](https://www.wowhead.com/classic/quest=2929); [Q3361: A Refugee's Quandary](https://www.wowhead.com/classic/quest=3361) | No correction identified. |
| [Gnomeregan](../content/dun-morogh/gnomeregan.md) | Corrected | [Q2929: The Grand Betrayal](https://www.wowhead.com/classic/quest=2929); Quest 412; Quest 2929; WoW manual: gnomes | Corrected the false claim that radiation killed the invaders; removed unverified details of Thermaplugg recommending the plan. |
| [High Tinker Mekkatorque](../content/dun-morogh/high-tinker-mekkatorque.md) | Corrected | [Q2929: The Grand Betrayal](https://www.wowhead.com/classic/quest=2929); Quest 412; Quest 2929 | Corrected the claim that radiation drove the troggs out; replaced invented private habits with Mekkatorque’s documented accusation. |
| [Ironforge](../content/dun-morogh/ironforge.md) | Corrected | Visible Vanilla Ironforge city | Qualified unsupported construction history and the forge’s reach; retained the visible Vanilla city and districts. |
| [Kharanos](../content/dun-morogh/kharanos.md) | Reviewed | [Q4128: Ragnar Thunderbrew](https://www.wowhead.com/classic/quest=4128) | No correction identified. |
| [The Leper Gnomes](../content/dun-morogh/leper-gnomes.md) | Reviewed | [Q412: Operation Recombobulation](https://www.wowhead.com/classic/quest=412) | No correction identified. |
| [King Magni Bronzebeard](../content/dun-morogh/magni-bronzebeard.md) | Reviewed | [Q4361: The Bearer of Bad News](https://www.wowhead.com/classic/quest=4361) | No correction identified. |
| [Mekgineer Thermaplugg](../content/dun-morogh/mekgineer-thermaplugg.md) | Corrected | [Q2929: The Grand Betrayal](https://www.wowhead.com/classic/quest=2929); Quest 412; Quest 2929 | Corrected radiation outcome and removed invented narrator testimony and an unverified account of Thermaplugg’s advice. |
| [Timber](../content/dun-morogh/timber.md) | Editorial exception | [Timber, Classic NPC 1132](https://www.wowhead.com/classic/npc=1132/timber) | Classic NPC 1132 confirms the named white wolf. Targeted web searches found no canonical backstory; The user explicitly approved retaining the original hunter tale as flavour text without an in-entry label; it is not source-verified lore. |
| [The War of the Three Hammers](../content/dun-morogh/war-of-the-three-hammers.md) | Reviewed | War of the Three Hammers (page 1927) | No correction identified. |
| [The Wendigos](../content/dun-morogh/wendigos.md) | Corrected | [Q313: The Grizzled Den](https://www.wowhead.com/classic/quest=313); Quest 313; Quest 5541 | Removed unsupported pack tactics, mountaineer customs, and Old Icebeard age and location claims. |

### durotar

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [The Darkspear Trolls](../content/durotar/darkspear-trolls.md) | Corrected | [Q805: Report to Sen'jin Village](https://www.wowhead.com/classic/quest=805); Warcraft III: Exodus of the Horde; Quest 7845; Quest 8182 | Removed a universal claim contradicted by the friendly Revantusk and Zandalar. |
| [Durotar](../content/durotar/durotar.md) | Reviewed | Old Hatreds - The Colonization of Kalimdor (page 2108) | No correction identified. |
| [The Echo Isles](../content/durotar/echo-isles.md) | Reviewed | [Q826: Zalazane](https://www.wowhead.com/classic/quest=826) | No correction identified. |
| [Eitrigg](../content/durotar/eitrigg.md) | Corrected | [Q4941: Eitrigg's Wisdom](https://www.wowhead.com/classic/quest=4941); [Of Blood and Honor, ch. 3, 5, 7](https://public.ds003.info/wcbooks/novels/Warcraft%20-%20%282000%29%20Of%20Blood%20And%20Honor%20-%20Chris%20Metzen.pdf#page=17); Of Blood and Honor, chapters 3, 5 and 7; online text checked directly; Q4941 Eitrigg’s Wisdom | Checked departure, rescue and return against the novella; clarified the quest sender. |
| [Orgrimmar](../content/durotar/orgrimmar.md) | Reviewed | [Q5726: Hidden Enemies](https://www.wowhead.com/classic/quest=5726) | No correction identified. |
| [Ragefire Chasm](../content/durotar/ragefire-chasm.md) | Reviewed | [Q5761: Slaying the Beast](https://www.wowhead.com/classic/quest=5761); [Q5726: Hidden Enemies](https://www.wowhead.com/classic/quest=5726) | No correction identified. |
| [Razor Hill](../content/durotar/razor-hill.md) | Reviewed | [Q830: The Admiral's Orders](https://www.wowhead.com/classic/quest=830) | No correction identified. |
| [Sen'jin Village](../content/durotar/senjin-village.md) | Reviewed | [Q805: Report to Sen'jin Village](https://www.wowhead.com/classic/quest=805) | No correction identified. |
| [Thrall](../content/durotar/thrall.md) | Reviewed | The New Horde (page 2030) | No correction identified. |
| [Tiragarde Keep](../content/durotar/tiragarde-keep.md) | Reviewed | [Q784: Vanquish the Betrayers](https://www.wowhead.com/classic/quest=784) | No correction identified. |
| [The Valley of Trials](../content/durotar/valley-of-trials.md) | Reviewed | [Q805: Report to Sen'jin Village](https://www.wowhead.com/classic/quest=805) | No correction identified. |
| [Vol'jin](../content/durotar/voljin.md) | Reviewed | [Q805: Report to Sen'jin Village](https://www.wowhead.com/classic/quest=805); [Q826: Zalazane](https://www.wowhead.com/classic/quest=826) | No correction identified. |

### duskwood

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Darkshire](../content/duskwood/darkshire.md) | Reviewed | [Q160: Note to the Mayor](https://www.wowhead.com/classic/quest=160) | No correction identified. |
| [Duskwood](../content/duskwood/duskwood.md) | Reviewed | In-game page 195 (page 195) | No correction identified. |
| [Mor'Ladim](../content/duskwood/morladim.md) | Reviewed | [Q228: Mor'Ladim](https://www.wowhead.com/classic/quest=228) | No correction identified. |
| [The Night Watch](../content/duskwood/night-watch.md) | Reviewed | [Q58: The Night Watch](https://www.wowhead.com/classic/quest=58) | No correction identified. |
| [Raven Hill](../content/duskwood/raven-hill.md) | Reviewed | [Q165: The Hermit](https://www.wowhead.com/classic/quest=165) | No correction identified. |
| [Stalvan Mistmantle](../content/duskwood/stalvan-mistmantle.md) | Reviewed | [Q98: The Legend of Stalvan](https://www.wowhead.com/classic/quest=98) | No correction identified. |
| [The Embalmer](../content/duskwood/the-embalmer.md) | Reviewed | [Q253: Bride of the Embalmer](https://www.wowhead.com/classic/quest=253) | No correction identified. |

### dustwallow

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Brackenwall Village](../content/dustwallow/brackenwall-village.md) | Reviewed | [Q1170: The Brood of Onyxia](https://www.wowhead.com/classic/quest=1170) | No correction identified. |
| [Dustwallow Marsh](../content/dustwallow/dustwallow-marsh.md) | Reviewed | [Q1170: The Brood of Onyxia](https://www.wowhead.com/classic/quest=1170); [Q6570: Emberstrife](https://www.wowhead.com/classic/quest=6570) | No correction identified. |
| [Lady Jaina Proudmoore](../content/dustwallow/jaina-proudmoore.md) | Reviewed | Period history / visible Vanilla setting; no independent passage recorded | No correction identified. |
| [Onyxia](../content/dustwallow/onyxia.md) | Corrected | [Q1170: The Brood of Onyxia](https://www.wowhead.com/classic/quest=1170); Vanilla raid: Onyxia’s Lair; Quests 6502, 6602 | Removed raid resets presented as repeated canonical deaths and invented testimony. |
| [Onyxia's Lair](../content/dustwallow/onyxias-lair.md) | Corrected | [Q6502: Drakefire Amulet](https://www.wowhead.com/classic/quest=6502); Quests 6502, 6602; Quest 6568 | Separated Emberstrife’s cave and disguise from Onyxia’s lair and its actual amulet requirement. |
| [The Shady Rest Inn](../content/dustwallow/shady-rest-inn.md) | Reviewed | [Q1268: Suspicious Hoofprints](https://www.wowhead.com/classic/quest=1268) | No correction identified. |
| [Theramore Isle](../content/dustwallow/theramore-isle.md) | Reviewed | Old Hatreds - The Colonization of Kalimdor (page 2107) | No correction identified. |

### eastern-plaguelands

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Balnazzar](../content/eastern-plaguelands/balnazzar.md) | Corrected | [Q5262: The Truth Comes Crashing Down](https://www.wowhead.com/classic/quest=5262); Warcraft III: The Frozen Throne undead campaign; In-game book: Civil War in the Plaguelands | Corrected the simplified cause of Arthas’s departure from Lordaeron. |
| [Baron Rivendare](../content/eastern-plaguelands/baron-rivendare.md) | Reviewed | [Q5263: Above and Beyond](https://www.wowhead.com/classic/quest=5263) | No correction identified. |
| [Darrowshire](../content/eastern-plaguelands/darrowshire.md) | Corrected | [Q5721: The Battle of Darrowshire](https://www.wowhead.com/classic/quest=5721); Quest 5154; Quest 5721; Pages 2375–2376: Annals of Darrowshire | Distinguished the corruption of Redpath’s spirit from an ordinary undead resurrection. |
| [Eastern Plaguelands](../content/eastern-plaguelands/eastern-plaguelands.md) | Reviewed | [Q5090: A Call to Arms: The Plaguelands!](https://www.wowhead.com/classic/quest=5090); [Q5961: The Champion of the Banshee Queen](https://www.wowhead.com/classic/quest=5961) | No correction identified. |
| [Kel'Thuzad](../content/eastern-plaguelands/kelthuzad.md) | Reviewed | Archimonde's Return and the Flight to Kalimdor (page 2072) | No correction identified. |
| [Light's Hope Chapel](../content/eastern-plaguelands/lights-hope-chapel.md) | Corrected | [Q9033: Echoes of War](https://www.wowhead.com/classic/quest=9033); [Q5264: Lord Maxwell Tyrosus](https://www.wowhead.com/classic/quest=5264); Quest 9033; Vanilla location: Light’s Hope Chapel | Removed an unsupported age ranking. |
| [Nathanos Blightcaller](../content/eastern-plaguelands/nathanos-blightcaller.md) | Reviewed | [Q6186: The Blightcaller Cometh](https://www.wowhead.com/classic/quest=6186) | No correction identified. |
| [Naxxramas](../content/eastern-plaguelands/naxxramas.md) | Reviewed | [Q9033: Echoes of War](https://www.wowhead.com/classic/quest=9033) | No correction identified. |
| [Stratholme](../content/eastern-plaguelands/stratholme.md) | Reviewed | [Q5281: The Restless Souls](https://www.wowhead.com/classic/quest=5281) | No correction identified. |
| [Tirion Fordring](../content/eastern-plaguelands/tirion-fordring.md) | Corrected | [Q5781: Of Forgotten Memories](https://www.wowhead.com/classic/quest=5781); [Of Blood and Honor, ch. 4–5](https://public.ds003.info/wcbooks/novels/Warcraft%20-%20%282000%29%20Of%20Blood%20And%20Honor%20-%20Chris%20Metzen.pdf#page=28); Of Blood and Honor, chapters 4–5; online text checked directly; Q5781 Of Forgotten Memories; Q5842 Welcome! | Verified the trial and clarified its location and sentence. |
| [Tyr's Hand](../content/eastern-plaguelands/tyrs-hand.md) | Reviewed | [Q6146: Nathanos' Ruse](https://www.wowhead.com/classic/quest=6146); [Q6148: The Scarlet Oracle, Demetria](https://www.wowhead.com/classic/quest=6148) | No correction identified. |

### elwynn

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [The Church of the Holy Light](../content/elwynn/church-of-the-holy-light.md) | Corrected | Archbishop Alonsus Faol (page 2291); Warcraft I manual: Clerics; Warcraft II manual: Paladins | Removed invented narrator testimony or unsupported universal claims. |
| [Elwynn Forest](../content/elwynn/elwynn-forest.md) | Corrected | In-game page 38 (page 38); Warcraft I ending; Vanilla map: Elwynn Forest | Removed unsupported visible First War catapults. |
| [Goldshire](../content/elwynn/goldshire.md) | Corrected | [Q54: Report to Goldshire](https://www.wowhead.com/classic/quest=54); Visible Vanilla Goldshire; Q54 Report to Goldshire | Qualified unsupported universal statements about roads and travellers. |
| [The Great Masquerade](../content/elwynn/great-masquerade.md) | Reviewed | [Q6403: The Great Masquerade](https://www.wowhead.com/classic/quest=6403) | No correction identified. |
| [Hogger](../content/elwynn/hogger.md) | Corrected | [Q176: Wanted:  "Hogger"](https://www.wowhead.com/classic/quest=176); Quest 176 | Removed fabricated casualties, universal posters, comparative intelligence and leadership claims. |
| [Lady Katrana Prestor](../content/elwynn/katrana-prestor.md) | Reviewed | [Q4185: The True Masters](https://www.wowhead.com/classic/quest=4185) | No correction identified. |
| [The Noble Conspiracy](../content/elwynn/noble-conspiracy.md) | Reviewed | [Q350: Look to an Old Friend](https://www.wowhead.com/classic/quest=350) | No correction identified. |
| [Northshire Abbey](../content/elwynn/northshire-abbey.md) | Corrected | Archbishop Alonsus Faol (page 2291); Warcraft I manual: Clerics; In-game book: The Knights of the Silver Hand, page 2291; Quests 7, 18, 21 | Removed unsupported centuries-old migration and founding history; corrected reforming the Brotherhood and the locations of kobolds and Defias. |
| [The Regency of Stormwind](../content/elwynn/regency-of-stormwind.md) | Corrected | [Q4185: The True Masters](https://www.wowhead.com/classic/quest=4185); Quest 4185 | Removed invented narrator testimony or unsupported universal claims. |
| [SI:7](../content/elwynn/si-7.md) | Corrected | [Q393: Shadow of the Past](https://www.wowhead.com/classic/quest=393); [Q394: The Head of the Beast](https://www.wowhead.com/classic/quest=394); [Q350: Look to an Old Friend](https://www.wowhead.com/classic/quest=350); Quest 350 | Removed an invented statement attributed to Mathias Shaw. |
| [Stormwind City](../content/elwynn/stormwind-city.md) | Corrected | [Q141: The Defias Brotherhood](https://www.wowhead.com/classic/quest=141); Quest 141; Patch 3.0.2 notes: Stormwind Harbor | Removed Stormwind Harbor, which opened with patch 3.0.2 rather than Vanilla. |
| [The Stockade](../content/elwynn/the-stockade.md) | Reviewed | [Q389: Bazil Thredd](https://www.wowhead.com/classic/quest=389) | No correction identified. |

### felwood

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Bloodvenom Post](../content/felwood/bloodvenom-post.md) | Reviewed | [Q6605: A Strange One](https://www.wowhead.com/classic/quest=6605) | No correction identified. |
| [The Emerald Sanctuary](../content/felwood/emerald-sanctuary.md) | Reviewed | [Q4421: The Corruption of the Jadefire](https://www.wowhead.com/classic/quest=4421) | No correction identified. |
| [Felwood](../content/felwood/felwood.md) | Reviewed | [Q4421: The Corruption of the Jadefire](https://www.wowhead.com/classic/quest=4421) | No correction identified. |
| [Jaedenar](../content/felwood/jaedenar.md) | Reviewed | [Q5155: Forces of Jaedenar](https://www.wowhead.com/classic/quest=5155) | No correction identified. |
| [Talonbranch Glade](../content/felwood/talonbranch-glade.md) | Reviewed | [Q1123: Rabine Saturna](https://www.wowhead.com/classic/quest=1123) | No correction identified. |

### feralas

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Camp Mojache](../content/feralas/camp-mojache.md) | Reviewed | [Q7492: Camp Mojache](https://www.wowhead.com/classic/quest=7492) | No correction identified. |
| [Dire Maul](../content/feralas/dire-maul.md) | Corrected | [Q7461: The Madness Within](https://www.wowhead.com/classic/quest=7461); [Q7703: Unfinished Gordok Business](https://www.wowhead.com/classic/quest=7703); Quests 5528, 7703; NPC text 6883 | Corrected the northern wing’s ogre clan. |
| [Feathermoon Stronghold](../content/feralas/feathermoon-stronghold.md) | Corrected | [Q2867: Return to Feathermoon Stronghold](https://www.wowhead.com/classic/quest=2867); Vanilla map: Sardor Isle; Quest 2870 | Removed invented narrator visit. |
| [Feralas](../content/feralas/feralas.md) | Corrected | [Q2975: The Ogres of Feralas](https://www.wowhead.com/classic/quest=2975); Quest 2975 | Removed unsupported annual frequency. |
| [Shandris Feathermoon](../content/feralas/shandris-feathermoon.md) | Corrected | [Q2867: Return to Feathermoon Stronghold](https://www.wowhead.com/classic/quest=2867); [The Demon Soul, ch. 9, 17–18, 23](https://public.ds003.info/wcbooks/novels/Warcraft%20-%20%282004%29%20War%20Of%20The%20Ancients%20Trilogy%20-%2002%20-%20The%20Demon%20Soul%20-%20Richard%20A.%20Knaak.PDF#page=67); The Demon Soul, chapters 9, 17–18 and 23; online text checked directly | Checked childhood and archery against the novel; qualified family certainty. |
| [The Shen'dralar](../content/feralas/shendralar.md) | Corrected | [Q7461: The Madness Within](https://www.wowhead.com/classic/quest=7461); [Q7441: Pusillin and the Elder Azj'Tordin](https://www.wowhead.com/classic/quest=7441); Quest 7461; Quest 7441 | Attributed an actual quest request rather than inventing a personal conversation. |

### forewords

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [A Word from the Archivist](../content/foreword-dwarf.md) | Corrected | Editorial introduction; no canonical narrator | Removed fictional League selection and vault practices from the introductory framing. |
| [A Word to a Child of Gnomeregan](../content/foreword-gnome.md) | Corrected | Quest 2929 | Removed invented League archival practice. |
| [A Word to a Son or Daughter of Stormwind](../content/foreword-human.md) | Framing | Editorial framing and related entries | No correction identified. |
| [A Word to One of the Kaldorei](../content/foreword-nightelf.md) | Framing | Editorial framing and related entries | No correction identified. |
| [A Word to One of the Horde](../content/foreword-orc.md) | Corrected | Warcraft II: Tides of Darkness; Editorial introduction | Removed invented narrator ancestry and an untraced League policy. |
| [A Word from the Archivist](../content/foreword-other.md) | Corrected | Editorial introduction; no canonical narrator | Removed fictional League selection and vault practices from the introductory framing. |
| [A Word to One of the Shu'halo](../content/foreword-tauren.md) | Framing | Editorial framing and related entries | No correction identified. |
| [A Word to One of the Darkspear](../content/foreword-troll.md) | Corrected | In-game books: The Twin Empires; Arathor and the Troll Wars | Removed unsupported comparative dating of Ironforge. |
| [A Word to One of the Forsaken](../content/foreword-undead.md) | Framing | Editorial framing and related entries | No correction identified. |

### hillsbrad

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Dun Garok](../content/hillsbrad/dun-garok.md) | Reviewed | [Q541: Battle of Hillsbrad](https://www.wowhead.com/classic/quest=541) | No correction identified. |
| [Durnholde Keep](../content/hillsbrad/durnholde-keep.md) | Corrected | The New Horde (page 2030); Quests 506, 507, 508 | Separated Aliden’s manor from Durnholde Keep. |
| [Hillsbrad Foothills](../content/hillsbrad/hillsbrad-foothills.md) | Reviewed | [Q528: Battle of Hillsbrad](https://www.wowhead.com/classic/quest=528) | No correction identified. |
| [Southshore](../content/hillsbrad/southshore.md) | Corrected | [Q538: Southshore](https://www.wowhead.com/classic/quest=538); Quest 538 | Removed invented narrator testimony or unsupported universal claims. |
| [Tarren Mill](../content/hillsbrad/tarren-mill.md) | Corrected | [Q527: Battle of Hillsbrad](https://www.wowhead.com/classic/quest=527); Quest 527 | Removed invented narrator testimony or unsupported universal claims. |

### hinterlands

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Aerie Peak](../content/hinterlands/aerie-peak.md) | Reviewed | [Q1449: To The Hinterlands](https://www.wowhead.com/classic/quest=1449) | No correction identified. |
| [Falstad Wildhammer](../content/hinterlands/falstad-wildhammer.md) | Corrected | [Q1449: To The Hinterlands](https://www.wowhead.com/classic/quest=1449); Quest 1449 | Removed invented conversations and narrator acquaintance; retained High Thane, attested in Vanilla quest 1449. |
| [Jintha'Alor](../content/hinterlands/jinthaalor.md) | Reviewed | [Q7845: Kidnapped Elder Torntusk!](https://www.wowhead.com/classic/quest=7845) | No correction identified. |
| [Quel'Danil Lodge](../content/hinterlands/queldanil-lodge.md) | Corrected | [Q7841: Message to the Wildhammer](https://www.wowhead.com/classic/quest=7841); Quest 2995 | Removed invented narrator testimony or unsupported universal claims. |
| [Revantusk Village](../content/hinterlands/revantusk-village.md) | Reviewed | [Q7847: Return to Primal Torntusk](https://www.wowhead.com/classic/quest=7847) | No correction identified. |
| [Shadra](../content/hinterlands/shadra.md) | Reviewed | [Q2937: Summoning Shadra](https://www.wowhead.com/classic/quest=2937) | No correction identified. |
| [The Hinterlands](../content/hinterlands/the-hinterlands.md) | Reviewed | [Q1449: To The Hinterlands](https://www.wowhead.com/classic/quest=1449); [Q7845: Kidnapped Elder Torntusk!](https://www.wowhead.com/classic/quest=7845) | No correction identified. |
| [The Wildhammer Clan](../content/hinterlands/wildhammer-clan.md) | Reviewed | [Q7842: Another Message to the Wildhammer](https://www.wowhead.com/classic/quest=7842) | No correction identified. |

### loch-modan

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Algaz](../content/loch-modan/algaz.md) | Reviewed | [Q455: The Algaz Gauntlet](https://www.wowhead.com/classic/quest=455) | No correction identified. |
| [The Farstrider Lodge](../content/loch-modan/farstrider-lodge.md) | Corrected | [Q385: Crocolisk Hunting](https://www.wowhead.com/classic/quest=385); Quest 385; Quest 258; Quest 271 | Removed unsupported Farstrider affiliation, founding implications, Marek leadership and universal tracking expertise. |
| [Ironband's Excavation Site](../content/loch-modan/ironbands-excavation-site.md) | Reviewed | [Q436: Ironband's Excavation](https://www.wowhead.com/classic/quest=436); [Q298: Excavation Progress Report](https://www.wowhead.com/classic/quest=298) | No correction identified. |
| [Loch Modan](../content/loch-modan/loch-modan.md) | Reviewed | [Q1558: The Stonewrought Dam](https://www.wowhead.com/classic/quest=1558) | No correction identified. |
| [The Mo'grosh Ogres](../content/loch-modan/mogrosh-ogres.md) | Reviewed | [Q255: Mercenaries](https://www.wowhead.com/classic/quest=255); [Q278: A Dark Threat Looms](https://www.wowhead.com/classic/quest=278) | No correction identified. |
| [The Stonewrought Dam](../content/loch-modan/stonewrought-dam.md) | Corrected | [Q1558: The Stonewrought Dam](https://www.wowhead.com/classic/quest=1558); Quest 1558; Quests 250, 278, 283 | Removed unsupported attribution to Franclorn Forgewright and invented League joke and doubled guard. |
| [Thelsamar](../content/loch-modan/thelsamar.md) | Reviewed | [Q6392: Return to Brock](https://www.wowhead.com/classic/quest=6392) | No correction identified. |
| [The Valley of Kings](../content/loch-modan/valley-of-kings.md) | Corrected | War of the Three Hammers (page 1929); Vanilla map: Loch Modan; In-game book: War of the Three Hammers, page 1929 | Corrected road geography. |

### moonglade

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Keeper Remulos](../content/moonglade/keeper-remulos.md) | Corrected | [Q8734: Tyrande and Remulos](https://www.wowhead.com/classic/quest=8734); Quest 8736; Vanilla event: The Nightmare Manifests | Removed the unsupported exact duration of his guardianship and corrected his participation in Nighthaven’s defence. |
| [Moonglade](../content/moonglade/moonglade.md) | Reviewed | [Q1094: Further Instructions](https://www.wowhead.com/classic/quest=1094); [Q8736: The Nightmare Manifests](https://www.wowhead.com/classic/quest=8736) | No correction identified. |
| [The Stormrage Barrow Dens](../content/moonglade/stormrage-barrow-dens.md) | Corrected | [Q933: Crown of the Earth](https://www.wowhead.com/classic/quest=933); Warcraft III night elf campaign; Quest 933 | Avoided conflating Warcraft III barrow dens with Moonglade and removed unsupported body location. |

### mulgore

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Bloodhoof Village](../content/mulgore/bloodhoof-village.md) | Reviewed | [Q763: Rites of the Earthmother](https://www.wowhead.com/classic/quest=763) | No correction identified. |
| [Cairne Bloodhoof](../content/mulgore/cairne-bloodhoof.md) | Reviewed | [Q775: Journey into Thunder Bluff](https://www.wowhead.com/classic/quest=775) | No correction identified. |
| [Camp Narache](../content/mulgore/camp-narache.md) | Reviewed | [Q747: The Hunt Begins](https://www.wowhead.com/classic/quest=747) | No correction identified. |
| [The Earth Mother](../content/mulgore/earth-mother.md) | Corrected | [Q773: Rite of Wisdom](https://www.wowhead.com/classic/quest=773); In-game book: Sorrow of the Earthmother; Quests 753, 757, 776 | Attributed religious tradition rather than presenting cosmology as settled fact; removed invented narrator testimony. |
| [Ghost Howl](../content/mulgore/ghost-howl.md) | Corrected | [Q770: The Demon Scarred Cloak](https://www.wowhead.com/classic/quest=770); Quest 770 | Removed invented timing, tauren alliance, pain-driven hostility and Skorn’s youthful failed hunt. |
| [Arch Druid Hamuul Runetotem](../content/mulgore/hamuul-runetotem.md) | Corrected | [Q1489: Hamuul Runetotem](https://www.wowhead.com/classic/quest=1489); [Q1490: Nara Wildmane](https://www.wowhead.com/classic/quest=1490); Quest 1489; Quest 1490; NPC 5769 | Removed detailed learning biography whose pre-Wrath provenance was not established. |
| [Mulgore](../content/mulgore/mulgore.md) | Reviewed | [Q748: Poison Water](https://www.wowhead.com/classic/quest=748); [Q775: Journey into Thunder Bluff](https://www.wowhead.com/classic/quest=775) | No correction identified. |
| [Red Rocks](../content/mulgore/red-rocks.md) | Reviewed | [Q773: Rite of Wisdom](https://www.wowhead.com/classic/quest=773) | No correction identified. |
| [Thunder Bluff](../content/mulgore/thunder-bluff.md) | Corrected | [Q775: Journey into Thunder Bluff](https://www.wowhead.com/classic/quest=775); NPC 3057 | Removed invented narrator testimony or unsupported universal claims. |

### peoples

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [The Argent Dawn](../content/peoples/argent-dawn.md) | Corrected | [Q5264: Lord Maxwell Tyrosus](https://www.wowhead.com/classic/quest=5264); Quests 5401, 5405 | Removed invented narrator testimony or unsupported universal claims. |
| [The Black Dragonflight](../content/peoples/black-dragonflight.md) | Corrected | [Q1170: The Brood of Onyxia](https://www.wowhead.com/classic/quest=1170); [Q6502: Drakefire Amulet](https://www.wowhead.com/classic/quest=6502); [Day of the Dragon, ch. 2, 12, 21](https://public.ds003.info/wcbooks/novels/Warcraft%20-%20%282001%29%20Day%20Of%20The%20Dragon%20-%20Richard%20A.%20Knaak.pdf#page=12); In-game book: The Sundering; Day of the Dragon; Day of the Dragon, chapters 2, 12 and 21; online text checked directly | Corrected when Neltharion became known as Deathwing. |
| [The Blackrock Clan](../content/peoples/blackrock-clan.md) | Corrected | [Q4974: For The Horde!](https://www.wowhead.com/classic/quest=4974); Quest 4941; NPC 10429: Warchief Rend Blackhand | Removed implication that Maim is alive and ruling in Vanilla. |
| [The Burning Blade](../content/peoples/burning-blade.md) | Reviewed | [Q827: Skull Rock](https://www.wowhead.com/classic/quest=827); [Q832: Burning Shadows](https://www.wowhead.com/classic/quest=832) | No correction identified. |
| [The Burning Legion](../content/peoples/burning-legion.md) | Corrected | The War of the Ancients (page 1807); Warcraft II manual; In-game book: Sargeras and the Betrayal | Removed a false contrast with other enemies originating on Draenor. |
| [The Cenarion Circle](../content/peoples/cenarion-circle.md) | Corrected | [Q1000: The New Frontier](https://www.wowhead.com/classic/quest=1000); [Q933: Crown of the Earth](https://www.wowhead.com/classic/quest=933); [Q1489: Hamuul Runetotem](https://www.wowhead.com/classic/quest=1489); Quest 933; NPC 5769 | Removed unsupported body location and first-ever tauren druid claim. |
| [The Centaurs](../content/peoples/centaurs.md) | Corrected | [Q7065: Corruption of Earth and Seed](https://www.wowhead.com/classic/quest=7065); Q1367 Magram Alliance; Q1368 Gelkis Alliance; Q7067 The Pariah’s Instructions | Removed untraced individual khan lineages and the absolute description of their livelihood. |
| [The Cult of the Damned](../content/peoples/cult-of-the-damned.md) | Reviewed | In-game page 680 (page 680) | No correction identified. |
| [The Dark Iron Dwarves](../content/peoples/dark-iron-dwarves.md) | Reviewed | [Q4003: The Royal Rescue](https://www.wowhead.com/classic/quest=4003) | No correction identified. |
| [The Defias Brotherhood](../content/peoples/defias-brotherhood.md) | Corrected | [Q141: The Defias Brotherhood](https://www.wowhead.com/classic/quest=141); Quest 141; Vanilla Defias Brotherhood quest chain | Removed invented narrator testimony or unsupported universal claims. |
| [The Dragons of Nightmare](../content/peoples/dragons-of-nightmare.md) | Reviewed | [Q8735: The Nightmare's Corruption](https://www.wowhead.com/classic/quest=8735) | No correction identified. |
| [The Forest Trolls](../content/peoples/forest-trolls.md) | Corrected | [Q7844: Cannibalistic Cousins](https://www.wowhead.com/classic/quest=7844); Quest 7845; Vanilla location: Revantusk Village | Removed nonexistent resident orcs at Revantusk Village. |
| [The Furbolgs](../content/peoples/furbolgs.md) | Corrected | [Q8465: Speak to Salfa](https://www.wowhead.com/classic/quest=8465); NPCs 7153–7155: Deadwood; 8959–8961: Felpaw wolves; Vanilla map: Timbermaw Hold | Removed Felpaw wolves from furbolg tribes, corrected Timbermaw geography and qualified the unsupported universal claim. |
| [The Gnolls](../content/peoples/gnolls.md) | Corrected | [Q276: Tramping Paws](https://www.wowhead.com/classic/quest=276); Quests 176, 276, 249, 446, 748; Vanilla NPCs: Woodpaw | Removed unsupported universal behaviour and intelligence claims; used regional quest accounts. |
| [The Grimtotem](../content/peoples/grimtotem.md) | Reviewed | [Q1063: The Elder Crone](https://www.wowhead.com/classic/quest=1063) | No correction identified. |
| [The Harpies](../content/peoples/harpies.md) | Corrected | [Q6282: Harpies Threaten](https://www.wowhead.com/classic/quest=6282); Quest 743; Quest 1057; Vanilla NPCs: Dustwind, Witchwing | Removed an untraced Azshara curse story, first homeland and invented eyewitness testimony. |
| [The Kobolds](../content/peoples/kobolds.md) | Reviewed | [Q60: Kobold Candles](https://www.wowhead.com/classic/quest=60) | No correction identified. |
| [The Murlocs](../content/peoples/murlocs.md) | Corrected | [Q150: Murloc Poachers](https://www.wowhead.com/classic/quest=150); Warcraft III: Exodus of the Horde; Vanilla NPCs: murlocs | Removed unsupported universal lack of communication, exact migration date and insinuated common naga or Old God master. |
| [The Naga](../content/peoples/naga.md) | Corrected | [Q6563: The Essence of Aku'Mai](https://www.wowhead.com/classic/quest=6563); [Q2870: Against Lord Shalzaru](https://www.wowhead.com/classic/quest=2870); Warcraft III: The Frozen Throne; Vanilla coastal naga settlements | Removed unsupported universal power ranking and a synchronised emergence claim. |
| [The Ogres](../content/peoples/ogres.md) | Corrected | [Q2975: The Ogres of Feralas](https://www.wowhead.com/classic/quest=2975); [Q7703: Unfinished Gordok Business](https://www.wowhead.com/classic/quest=7703); Warcraft II manual: Ogre-Mage and Altar of Storms | Distinguished enhancement of ogre magi from the origin of all two-headed ogres; avoided universal internment claim. |
| [The Quilboar](../content/peoples/quilboar.md) | Reviewed | [Q3341: Bring the End](https://www.wowhead.com/classic/quest=3341) | No correction identified. |
| [The Satyrs](../content/peoples/satyrs.md) | Corrected | [Q6441: Satyr Horns](https://www.wowhead.com/classic/quest=6441); [The Demon Soul, ch. 3, 7](https://public.ds003.info/wcbooks/novels/Warcraft%20-%20%282004%29%20War%20Of%20The%20Ancients%20Trilogy%20-%2002%20-%20The%20Demon%20Soul%20-%20Richard%20A.%20Knaak.PDF#page=19); Quests 6441, 4421 | Removed invented narrator testimony or unsupported universal claims. |
| [The Scarlet Crusade](../content/peoples/scarlet-crusade.md) | Corrected | [Q1052: Down the Scarlet Path](https://www.wowhead.com/classic/quest=1052); [Q5262: The Truth Comes Crashing Down](https://www.wowhead.com/classic/quest=5262); [Q9033: Echoes of War](https://www.wowhead.com/classic/quest=9033); Q5262 The Truth Comes Crashing Down; Q1052 Down the Scarlet Path | Removed an unsupported comparative Scourge kill count. |
| [The Scourge](../content/peoples/scourge.md) | Corrected | [Q9033: Echoes of War](https://www.wowhead.com/classic/quest=9033); [Q9120: The Fall of Kel'Thuzad](https://www.wowhead.com/classic/quest=9120); Warcraft III: The Frozen Throne ending; Quest 9033 | Accounted for the Frozen Throne campaign ending and the Vanilla Dawn–Crusade cooperation. |
| [The Silithid](../content/peoples/silithid.md) | Corrected | [Q8742: The Might of Kalimdor](https://www.wowhead.com/classic/quest=8742); Quests 8275, 8276 | Removed invented yearly scout observations. |
| [The Southsea Freebooters](../content/peoples/southsea-freebooters.md) | Reviewed | [Q8366: Southsea Shakedown](https://www.wowhead.com/classic/quest=8366) | No correction identified. |
| [The Steamwheedle Cartel](../content/peoples/steamwheedle-cartel.md) | Corrected | [Q8366: Southsea Shakedown](https://www.wowhead.com/classic/quest=8366); [Q895: WANTED: Baron Longshore](https://www.wowhead.com/classic/quest=895); NPCs 2496, 3391; Quest 891 | Removed untraced attribution of Second War contractors to this cartel and unsupported uniform customs. |
| [The Syndicate](../content/peoples/syndicate.md) | Reviewed | [Q505: Syndicate Assassins](https://www.wowhead.com/classic/quest=505) | No correction identified. |
| [The Troggs](../content/peoples/troggs.md) | Corrected | [Q2398: The Lost Dwarves](https://www.wowhead.com/classic/quest=2398); [Q170: A New Threat](https://www.wowhead.com/classic/quest=170); [Q267: The Trogg Threat](https://www.wowhead.com/classic/quest=267); [Q412: Operation Recombobulation](https://www.wowhead.com/classic/quest=412); [Q2278: The Platinum Discs](https://www.wowhead.com/classic/quest=2278); Quests 170, 267, 412 | Removed invented universal group size and behaviour. |
| [The Twilight's Hammer](../content/peoples/twilights-hammer.md) | Corrected | [Q6565: Allegiance to the Old Gods](https://www.wowhead.com/classic/quest=6565); Warcraft II manual: Twilight’s Hammer clan | Removed invented narrator reading; retained the documented clan ideology. |
| [The Venture Company](../content/peoples/venture-company.md) | Reviewed | [Q600: Venture Company Mining](https://www.wowhead.com/classic/quest=600); [Q1062: Goblin Invaders](https://www.wowhead.com/classic/quest=1062) | No correction identified. |
| [The Worgen](../content/peoples/worgen.md) | Reviewed | [Q1043: The Scythe of Elune](https://www.wowhead.com/classic/quest=1043) | No correction identified. |

### redridge

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Gath'Ilzogg](../content/redridge/gathilzogg.md) | Reviewed | [Q169: Wanted: Gath'Ilzogg](https://www.wowhead.com/classic/quest=169) | No correction identified. |
| [Lakeshire](../content/redridge/lakeshire.md) | Reviewed | [Q89: The Everstill Bridge](https://www.wowhead.com/classic/quest=89) | No correction identified. |
| [Morganth](../content/redridge/morganth.md) | Reviewed | [Q249: Morganth](https://www.wowhead.com/classic/quest=249) | No correction identified. |
| [Redridge Mountains](../content/redridge/redridge-mountains.md) | Reviewed | [Q20: Blackrock Menace](https://www.wowhead.com/classic/quest=20); [Q121: Messenger to Stormwind](https://www.wowhead.com/classic/quest=121) | No correction identified. |
| [Stonewatch Keep](../content/redridge/stonewatch-keep.md) | Reviewed | [Q20: Blackrock Menace](https://www.wowhead.com/classic/quest=20) | No correction identified. |

### searing-gorge

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Searing Gorge](../content/searing-gorge/searing-gorge.md) | Reviewed | [Q3372: Release Them](https://www.wowhead.com/classic/quest=3372) | No correction identified. |
| [The Cauldron](../content/searing-gorge/the-cauldron.md) | Reviewed | [Q7701: WANTED: Overseer Maltorius](https://www.wowhead.com/classic/quest=7701) | No correction identified. |
| [The Thorium Brotherhood](../content/searing-gorge/thorium-brotherhood.md) | Reviewed | [Q7722: What the Flux?](https://www.wowhead.com/classic/quest=7722); [Q7701: WANTED: Overseer Maltorius](https://www.wowhead.com/classic/quest=7701) | No correction identified. |

### silithus

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [The Abyssal Council](../content/silithus/abyssal-council.md) | Reviewed | [Q8341: Lords of the Council](https://www.wowhead.com/classic/quest=8341) | No correction identified. |
| [Cenarion Hold](../content/silithus/cenarion-hold.md) | Reviewed | [Q8276: Taking Back Silithus](https://www.wowhead.com/classic/quest=8276) | No correction identified. |
| [C'Thun](../content/silithus/cthun.md) | Reviewed | [Q8801: C'Thun's Legacy](https://www.wowhead.com/classic/quest=8801) | No correction identified. |
| [Prince Thunderaan](../content/silithus/prince-thunderaan.md) | Reviewed | [Q7786: Thunderaan the Windseeker](https://www.wowhead.com/classic/quest=7786) | No correction identified. |
| [Ruins of Ahn'Qiraj](../content/silithus/ruins-of-ahnqiraj.md) | Reviewed | [Q8791: The Fall of Ossirian](https://www.wowhead.com/classic/quest=8791); [Q8519: A Pawn on the Eternal Board](https://www.wowhead.com/classic/quest=8519) | No correction identified. |
| [Silithus](../content/silithus/silithus.md) | Corrected | [Q8276: Taking Back Silithus](https://www.wowhead.com/classic/quest=8276); [Q8519: A Pawn on the Eternal Board](https://www.wowhead.com/classic/quest=8519); Quests 8275, 8276 | Removed invented narrator testimony or unsupported universal claims. |
| [Temple of Ahn'Qiraj](../content/silithus/temple-of-ahnqiraj.md) | Reviewed | [Q8784: Secrets of the Qiraji](https://www.wowhead.com/classic/quest=8784); [Q8519: A Pawn on the Eternal Board](https://www.wowhead.com/classic/quest=8519) | No correction identified. |
| [The Scarab Wall](../content/silithus/the-scarab-wall.md) | Reviewed | [Q8742: The Might of Kalimdor](https://www.wowhead.com/classic/quest=8742) | No correction identified. |
| [The Scepter of the Shifting Sands](../content/silithus/the-scepter-of-the-shifting-sands.md) | Reviewed | [Q8742: The Might of Kalimdor](https://www.wowhead.com/classic/quest=8742) | No correction identified. |

### silverpine

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Ambermill](../content/silverpine/ambermill.md) | Reviewed | [Q482: Dalaran's Intentions](https://www.wowhead.com/classic/quest=482) | No correction identified. |
| [Archmage Arugal](../content/silverpine/archmage-arugal.md) | Corrected | [Q1014: Arugal Must Die](https://www.wowhead.com/classic/quest=1014); [Original Shadowfang Keep introduction](https://www.wowhead.com/classic/zone=209/shadowfang-keep); Original Shadowfang Keep introduction, reproduced on Wowhead Classic zone 209; Q1014 Arugal Must Die | Confirmed the summoning and retreat in the original dungeon introduction. |
| [The Greymane Wall](../content/silverpine/greymane-wall.md) | Corrected | [Q530: A Husband's Revenge](https://www.wowhead.com/classic/quest=530); Quest 530; In-game book: The Alliance Splinters | Removed an unsupported claim about conditions inside sealed Gilneas. |
| [Pyrewood Village](../content/silverpine/pyrewood-village.md) | Reviewed | [Q452: Pyrewood Ambush](https://www.wowhead.com/classic/quest=452) | No correction identified. |
| [Shadowfang Keep](../content/silverpine/shadowfang-keep.md) | Corrected | [Q1014: Arugal Must Die](https://www.wowhead.com/classic/quest=1014); [Original Shadowfang Keep introduction](https://www.wowhead.com/classic/zone=209/shadowfang-keep); Original Shadowfang Keep introduction, reproduced on Wowhead Classic zone 209; Q1098 Deathstalkers in Shadowfang | Checked the original dungeon introduction; removed unsupported household-wide death and naming agency. |
| [Silverpine Forest](../content/silverpine/silverpine-forest.md) | Reviewed | [Q445: Delivery to Silverpine Forest](https://www.wowhead.com/classic/quest=445) | No correction identified. |
| [The Sepulcher](../content/silverpine/the-sepulcher.md) | Reviewed | [Q421: Prove Your Worth](https://www.wowhead.com/classic/quest=421) | No correction identified. |
| [Thule Ravenclaw](../content/silverpine/thule-ravenclaw.md) | Corrected | [Q446: Thule Ravenclaw](https://www.wowhead.com/classic/quest=446); Vanilla map: Silverpine Forest; Quest 446 | Corrected inland lake geography. |

### stonetalon

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Boulderslide Ravine](../content/stonetalon/boulderslide-ravine.md) | Reviewed | [Q6421: Boulderslide Ravine](https://www.wowhead.com/classic/quest=6421) | No correction identified. |
| [Stonetalon Mountains](../content/stonetalon/stonetalon-mountains.md) | Reviewed | [Q1057: Reclaiming the Charred Vale](https://www.wowhead.com/classic/quest=1057) | No correction identified. |
| [Stonetalon Peak](../content/stonetalon/stonetalon-peak.md) | Reviewed | [Q1089: The Den](https://www.wowhead.com/classic/quest=1089) | No correction identified. |
| [Sun Rock Retreat](../content/stonetalon/sun-rock-retreat.md) | Reviewed | [Q6401: Kaya's Alive](https://www.wowhead.com/classic/quest=6401) | No correction identified. |
| [Windshear Crag](../content/stonetalon/windshear-crag.md) | Reviewed | [Q1068: Shredding Machines](https://www.wowhead.com/classic/quest=1068); [Q1483: Ziz Fizziks](https://www.wowhead.com/classic/quest=1483) | No correction identified. |

### stranglethorn

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [The Bloodsail Buccaneers](../content/stranglethorn/bloodsail-buccaneers.md) | Reviewed | [Q608: The Bloodsail Buccaneers](https://www.wowhead.com/classic/quest=608) | No correction identified. |
| [The Bloodscalp and the Skullsplitter](../content/stranglethorn/bloodscalp-and-skullsplitter.md) | Corrected | Wrath of Soulflayer (page 2208); Quests 581, 588, 592 | Distinguished the initial Bloodscalp suspicion from the revealed captor. |
| [Booty Bay](../content/stranglethorn/booty-bay.md) | Corrected | [Q599: The Bloodsail Buccaneers](https://www.wowhead.com/classic/quest=599); Quests 599, 608 | Removed invented narrator testimony or unsupported universal claims. |
| [Grom'gol Base Camp](../content/stranglethorn/gromgol-base-camp.md) | Corrected | [Q581: Hunt for Yenniku](https://www.wowhead.com/classic/quest=581); Quests 581, 588, 592 | Corrected Yenniku’s captor and quest outcome. |
| [The Gurubashi Arena](../content/stranglethorn/gurubashi-arena.md) | Reviewed | [Q7838: Arena Grandmaster](https://www.wowhead.com/classic/quest=7838) | No correction identified. |
| [The Gurubashi Empire](../content/stranglethorn/gurubashi-empire.md) | Reviewed | Wrath of Soulflayer (page 2208) | No correction identified. |
| [Hakkar the Soulflayer](../content/stranglethorn/hakkar.md) | Reviewed | [Q8183: The Heart of Hakkar](https://www.wowhead.com/classic/quest=8183) | No correction identified. |
| [The Kurzen Rebellion](../content/stranglethorn/kurzen-rebellion.md) | Corrected | [Q203: The Second Rebellion](https://www.wowhead.com/classic/quest=203); Quests 202, 206 | Completed the quest’s explanation instead of leaving the initial hypothesis as its conclusion. |
| [Nesingwary's Expedition](../content/stranglethorn/nesingwarys-expedition.md) | Corrected | [Q338: The Green Hills of Stranglethorn](https://www.wowhead.com/classic/quest=338); Quest 338 | Matched the manuscript incident to Barnil’s quest text. |
| [Stranglethorn Vale](../content/stranglethorn/stranglethorn-vale.md) | Reviewed | In-game page 296 (page 296) | No correction identified. |
| [The Zandalar Tribe](../content/stranglethorn/zandalar-tribe.md) | Reviewed | [Q8182: The Hand of Rastakhan](https://www.wowhead.com/classic/quest=8182) | No correction identified. |
| [Zul'Gurub](../content/stranglethorn/zulgurub.md) | Corrected | Wrath of Soulflayer (page 2204); Vanilla Zul’Gurub introduction; Quest 8182 | Corrected the high priests’ role: sent against Hakkar, subsequently enslaved. |

### swamp-of-sorrows

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Eranikus](../content/swamp-of-sorrows/eranikus.md) | Reviewed | [Q3374: The Essence of Eranikus](https://www.wowhead.com/classic/quest=3374) | No correction identified. |
| [Stonard](../content/swamp-of-sorrows/stonard.md) | Reviewed | [Q1418: Neeka Bloodscar](https://www.wowhead.com/classic/quest=1418) | No correction identified. |
| [Swamp of Sorrows](../content/swamp-of-sorrows/swamp-of-sorrows.md) | Reviewed | [Q1396: Encroaching Wildlife](https://www.wowhead.com/classic/quest=1396); [Q1116: Dream Dust in the Swamp](https://www.wowhead.com/classic/quest=1116) | No correction identified. |
| [The Fallen Hero](../content/swamp-of-sorrows/the-fallen-hero.md) | Reviewed | [Q3626: Return to the Blasted Lands](https://www.wowhead.com/classic/quest=3626) | No correction identified. |
| [The Lost Ones](../content/swamp-of-sorrows/the-lost-ones.md) | Corrected | [Q1389: Draenethyst Crystals](https://www.wowhead.com/classic/quest=1389); Q1389 Draenethyst Crystals | Removed an invented narrator conversation while preserving the period’s limited account. |
| [The Temple of Atal'Hakkar](../content/swamp-of-sorrows/the-temple-of-atalhakkar.md) | Reviewed | [Q1475: Into The Temple of Atal'Hakkar](https://www.wowhead.com/classic/quest=1475) | No correction identified. |

### tanaris

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [The Caverns of Time](../content/tanaris/caverns-of-time.md) | Reviewed | [Q8741: The Champion Returns](https://www.wowhead.com/classic/quest=8741) | No correction identified. |
| [Gadgetzan](../content/tanaris/gadgetzan.md) | Reviewed | [Q1690: Wastewander Justice](https://www.wowhead.com/classic/quest=1690) | No correction identified. |
| [The Sandfury Trolls](../content/tanaris/sandfury-trolls.md) | Reviewed | [Q2770: Gahz'rilla](https://www.wowhead.com/classic/quest=2770) | No correction identified. |
| [Tanaris](../content/tanaris/tanaris.md) | Reviewed | [Q1690: Wastewander Justice](https://www.wowhead.com/classic/quest=1690) | No correction identified. |
| [Uldum](../content/tanaris/uldum.md) | Reviewed | [Q2954: The Stone Watcher](https://www.wowhead.com/classic/quest=2954) | No correction identified. |
| [Zul'Farrak](../content/tanaris/zulfarrak.md) | Reviewed | [Q3527: The Prophecy of Mosh'aru](https://www.wowhead.com/classic/quest=3527) | No correction identified. |

### teldrassil

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Darnassus](../content/teldrassil/darnassus.md) | Corrected | [Q1081: Reception from Tyrande](https://www.wowhead.com/classic/quest=1081); Quests 933, 934; Vanilla city: Darnassus | Removed the false implication that night elves had no earlier cities and invented narrator age. |
| [Dolanaar](../content/teldrassil/dolanaar.md) | Reviewed | [Q2159: Dolanaar Delivery](https://www.wowhead.com/classic/quest=2159) | No correction identified. |
| [Arch Druid Fandral Staghelm](../content/teldrassil/fandral-staghelm.md) | Reviewed | [Q3763: Assisting Arch Druid Staghelm](https://www.wowhead.com/classic/quest=3763) | No correction identified. |
| [Shadowglen](../content/teldrassil/shadowglen.md) | Reviewed | [Q456: The Balance of Nature](https://www.wowhead.com/classic/quest=456) | No correction identified. |
| [The Sickness of Teldrassil](../content/teldrassil/sickness-of-teldrassil.md) | Corrected | [Q476: Gnarlpine Corruption](https://www.wowhead.com/classic/quest=476); Quests 935, 940 | Removed a secrecy claim contradicted by Fandral’s own quest dialogue. |
| [Teldrassil](../content/teldrassil/teldrassil.md) | Corrected | [Q934: Crown of the Earth](https://www.wowhead.com/classic/quest=934); Vanilla transport: Rut’theran Village gateway | Corrected the route into Darnassus. |
| [Tyrande Whisperwind](../content/teldrassil/tyrande-whisperwind.md) | Corrected | Archimonde's Return and the Flight to Kalimdor (page 2079); Quest 933 | Removed unsupported present location of Malfurion’s body and sole rule claim. |

### thousand-needles

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Freewind Post](../content/thousand-needles/freewind-post.md) | Reviewed | [Q4542: Message to Freewind Post](https://www.wowhead.com/classic/quest=4542) | No correction identified. |
| [The Rustmaul Dig Site](../content/thousand-needles/rustmaul-dig-site.md) | Reviewed | [Q1146: The Swarm Grows](https://www.wowhead.com/classic/quest=1146) | No correction identified. |
| [The Shimmering Flats](../content/thousand-needles/shimmering-flats.md) | Corrected | [Q1110: Rocket Car Parts](https://www.wowhead.com/classic/quest=1110); Quests 1110, 1179 | Removed invented attended race, pilot-count inference and details of regulators. |
| [Thousand Needles](../content/thousand-needles/thousand-needles.md) | Corrected | [Q1146: The Swarm Grows](https://www.wowhead.com/classic/quest=1146); Vanilla location: The Shimmering Flats | Removed an unsupported absolute climate claim. |

### tirisfal

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Brill](../content/tirisfal/brill.md) | Reviewed | [Q492: A New Plague](https://www.wowhead.com/classic/quest=492) | No correction identified. |
| [Deathknell](../content/tirisfal/deathknell.md) | Reviewed | [Q363: Rude Awakening](https://www.wowhead.com/classic/quest=363) | No correction identified. |
| [The Fall of Lordaeron](../content/tirisfal/fall-of-lordaeron.md) | Reviewed | The Scourge of Lordaeron (page 2066) | No correction identified. |
| [The Royal Apothecary Society](../content/tirisfal/royal-apothecary-society.md) | Reviewed | [Q367: A New Plague](https://www.wowhead.com/classic/quest=367) | No correction identified. |
| [The Scarlet Monastery](../content/tirisfal/scarlet-monastery.md) | Reviewed | [Q1048: Into The Scarlet Monastery](https://www.wowhead.com/classic/quest=1048) | No correction identified. |
| [Lady Sylvanas Windrunner](../content/tirisfal/sylvanas-windrunner.md) | Reviewed | Sunwell - The Fall of Quel'Thalas (page 2069) | No correction identified. |
| [The Bulwark](../content/tirisfal/the-bulwark.md) | Reviewed | [Q5344: The Last Barov](https://www.wowhead.com/classic/quest=5344) | No correction identified. |
| [The Forsaken](../content/tirisfal/the-forsaken.md) | Reviewed | Civil War in the Plaguelands (page 2099) | No correction identified. |
| [Tirisfal Glades](../content/tirisfal/tirisfal-glades.md) | Reviewed | [Q363: Rude Awakening](https://www.wowhead.com/classic/quest=363); [Q383: Vital Intelligence](https://www.wowhead.com/classic/quest=383) | No correction identified. |
| [Undercity](../content/tirisfal/undercity.md) | Corrected | Civil War in the Plaguelands (page 2099); Visible Vanilla Undercity; Civil War in the Plaguelands | Removed an invented visit under a scholarly truce. |
| [Varimathras](../content/tirisfal/varimathras.md) | Corrected | [Q6144: The Call to Command](https://www.wowhead.com/classic/quest=6144); Warcraft III: The Frozen Throne, Sylvanas/Varimathras bargain | Removed invented reports about Sylvanas’s behaviour. |
| [Whitemane and Mograine](../content/tirisfal/whitemane-and-mograine.md) | Reviewed | [Q1048: Into The Scarlet Monastery](https://www.wowhead.com/classic/quest=1048) | No correction identified. |

### ungoro-crater

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [The Crystal Pylons](../content/ungoro-crater/crystal-pylons.md) | Corrected | [Q4287: The Eastern Pylon](https://www.wowhead.com/classic/quest=4287); Quests 4284, 4285, 4287, 4288, 4321 | Corrected J.D. Collie’s pronoun and removed unproved titan authorship and absolute age claims. |
| [Fire Plume Ridge](../content/ungoro-crater/fire-plume-ridge.md) | Corrected | [Q4492: Lost!](https://www.wowhead.com/classic/quest=4492); Quest 3962; Quest 4492 | Removed unsupported power ranking and crater-wide geological explanation. |
| [Marshal's Refuge](../content/ungoro-crater/marshals-refuge.md) | Reviewed | [Q3884: Williden's Journal](https://www.wowhead.com/classic/quest=3884) | No correction identified. |
| [Un'Goro Crater](../content/ungoro-crater/ungoro-crater.md) | Reviewed | [Q4289: The Apes of Un'Goro](https://www.wowhead.com/classic/quest=4289); [Q4502: Volcanic Activity](https://www.wowhead.com/classic/quest=4502) | No correction identified. |

### western-plaguelands

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Andorhal](../content/western-plaguelands/andorhal.md) | Corrected | [Q211: Alas, Andorhal](https://www.wowhead.com/classic/quest=211); Warcraft III human campaign: The Cult of the Damned | Distinguished Andorhal’s distribution role from the first appearance of the plague. |
| [Caer Darrow](../content/western-plaguelands/caer-darrow.md) | Reviewed | [Q5846: Of Love and Family](https://www.wowhead.com/classic/quest=5846) | No correction identified. |
| [Chillwind Camp](../content/western-plaguelands/chillwind-camp.md) | Reviewed | [Q8415: Chillwind Point](https://www.wowhead.com/classic/quest=8415) | No correction identified. |
| [Hearthglen](../content/western-plaguelands/hearthglen.md) | Corrected | [Q5944: In Dreams](https://www.wowhead.com/classic/quest=5944); Quest 5944; In Dreams event dialogue, script texts -1001090 to -1001102 | Corrected Taelan’s death before Tirion’s arrival. |
| [The House of Barov](../content/western-plaguelands/house-of-barov.md) | Corrected | [Q5341: Barov Family Fortune](https://www.wowhead.com/classic/quest=5341); Quests 5342, 5344 | Removed invented narrator testimony or unsupported universal claims. |
| [The Plague Cauldrons](../content/western-plaguelands/plague-cauldrons.md) | Corrected | [Q5215: The Scourge Cauldrons](https://www.wowhead.com/classic/quest=5215); Quests 5215, 5228, 5217, 5230, 5218 | Restored the purpose and visible result of the cauldron counteragents; retained the eight-cauldron count explicitly given by Vanilla quests. |
| [Scholomance](../content/western-plaguelands/scholomance.md) | Reviewed | [Q838: Scholomance](https://www.wowhead.com/classic/quest=838) | No correction identified. |
| [Uther's Tomb](../content/western-plaguelands/uthers-tomb.md) | Reviewed | [Q8149: Honoring a Hero](https://www.wowhead.com/classic/quest=8149) | No correction identified. |
| [Western Plaguelands](../content/western-plaguelands/western-plaguelands.md) | Corrected | [Q5228: The Scourge Cauldrons](https://www.wowhead.com/classic/quest=5228); Warcraft III human campaign: Ravages of the Plague; The Cult of the Damned | Removed overprecise origin claim. |

### westfall

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Edwin VanCleef](../content/westfall/edwin-vancleef.md) | Reviewed | [Q141: The Defias Brotherhood](https://www.wowhead.com/classic/quest=141) | No correction identified. |
| [Moonbrook](../content/westfall/moonbrook.md) | Reviewed | [Q67: The Legend of Stalvan](https://www.wowhead.com/classic/quest=67) | No correction identified. |
| [The People's Militia](../content/westfall/peoples-militia.md) | Reviewed | [Q14: The People's Militia](https://www.wowhead.com/classic/quest=14) | No correction identified. |
| [Sentinel Hill](../content/westfall/sentinel-hill.md) | Corrected | [Q109: Report to Gryan Stoutmantle](https://www.wowhead.com/classic/quest=109); Vanilla location: Sentinel Hill | Removed an inn from Vanilla Sentinel Hill. |
| [The Deadmines](../content/westfall/the-deadmines.md) | Corrected | [Q2040: Underground Assault](https://www.wowhead.com/classic/quest=2040); Warcraft I human mission 4: The Dead Mines; Vanilla dungeon: The Deadmines | Corrected Lothar’s rescue and removed the later Stormwind harbor reference. |
| [Westfall](../content/westfall/westfall.md) | Corrected | [Q9: The Killing Fields](https://www.wowhead.com/classic/quest=9); Quest 9; Page 38: Wiley’s letter | Removed unsupported farmer ownership of the golems; Wiley’s letter instead describes Defias goblins making metal monsters for the fields. |

### wetlands

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [The Dragonmaw Clan](../content/wetlands/dragonmaw-clan.md) | Reviewed | [Q464: War Banners](https://www.wowhead.com/classic/quest=464) | No correction identified. |
| [Dun Modr](../content/wetlands/dun-modr.md) | Reviewed | [Q472: Fall of Dun Modr](https://www.wowhead.com/classic/quest=472) | No correction identified. |
| [Grim Batol](../content/wetlands/grim-batol.md) | Corrected | War of the Three Hammers (page 1927); [Day of the Dragon, ch. 21](https://public.ds003.info/wcbooks/novels/Warcraft%20-%20%282001%29%20Day%20Of%20The%20Dragon%20-%20Richard%20A.%20Knaak.pdf#page=195); Vanilla NPCs at Grim Batol; In-game book: War of the Three Hammers | Removed invented deaths of League members. |
| [Menethil Harbor](../content/wetlands/menethil-harbor.md) | Corrected | [Q464: War Banners](https://www.wowhead.com/classic/quest=464); [Q474: Defeat Nek'rosh](https://www.wowhead.com/classic/quest=474); Quests 464, 465, 474; Vanilla transport routes | Removed untraced founding and naming history attributed to Daelin Proudmoore and invented sailor testimony. |
| [The Mosshide Gnolls](../content/wetlands/mosshide-gnolls.md) | Corrected | [Q276: Tramping Paws](https://www.wowhead.com/classic/quest=276); Quest 276 | Replaced invented cowardice and tactics with attributed period quest testimony. |
| [Chieftain Nek'rosh](../content/wetlands/nekrosh.md) | Reviewed | [Q474: Defeat Nek'rosh](https://www.wowhead.com/classic/quest=474) | No correction identified. |
| [The Red Dragonflight](../content/wetlands/red-dragonflight.md) | Reviewed | In-game page 452 (page 452); [Day of the Dragon, ch. 21](https://public.ds003.info/wcbooks/novels/Warcraft%20-%20%282001%29%20Day%20Of%20The%20Dragon%20-%20Richard%20A.%20Knaak.pdf#page=195) | No correction identified. |
| [The Thandol Span](../content/wetlands/thandol-span.md) | Corrected | [Q633: The Thandol Span](https://www.wowhead.com/classic/quest=633); Q633 The Thandol Span; visible Vanilla bridges | Removed invented League drawings and a promised future restoration. |
| [The Wetlands](../content/wetlands/wetlands.md) | Reviewed | [Q455: The Algaz Gauntlet](https://www.wowhead.com/classic/quest=455) | No correction identified. |
| [Whelgar's Excavation Site](../content/wetlands/whelgars-excavation-site.md) | Reviewed | [Q294: Ormer's Revenge](https://www.wowhead.com/classic/quest=294); [Q305: In Search of The Excavation Team](https://www.wowhead.com/classic/quest=305) | No correction identified. |

### winterspring

| Entry | Result | Cross-check reference / correction basis | Finding |
| --- | --- | --- | --- |
| [Everlook](../content/winterspring/everlook.md) | Reviewed | [Q6028: The Everlook Report](https://www.wowhead.com/classic/quest=6028) | No correction identified. |
| [Mazthoril](../content/winterspring/mazthoril.md) | Reviewed | [Q5160: The Matron Protectorate](https://www.wowhead.com/classic/quest=5160) | No correction identified. |
| [The Ruins of Kel'Theril](../content/winterspring/ruins-of-keltheril.md) | Reviewed | [Q5244: The Ruins of Kel'Theril](https://www.wowhead.com/classic/quest=5244) | No correction identified. |
| [Starfall Village](../content/winterspring/starfall-village.md) | Reviewed | [Q6604: Enraged Wildkin](https://www.wowhead.com/classic/quest=6604) | No correction identified. |
| [Winterspring](../content/winterspring/winterspring.md) | Reviewed | [Q5083: Winterfall Firewater](https://www.wowhead.com/classic/quest=5083) | No correction identified. |

## Chapter-summary record

| Chapter | Result | Finding |
| --- | --- | --- |
| [Alterac Mountains](../content/alterac/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Arathi Highlands](../content/arathi/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Ashenvale](../content/ashenvale/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Azshara](../content/azshara/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [The Badlands](../content/badlands/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [The Barrens](../content/barrens/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Blackrock Mountain](../content/blackrock-mountain/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Blasted Lands](../content/blasted-lands/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Burning Steppes](../content/burning-steppes/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Darkshore](../content/darkshore/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Deadwind Pass](../content/deadwind-pass/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Desolace](../content/desolace/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Dun Morogh and Ironforge](../content/dun-morogh/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Durotar and Orgrimmar](../content/durotar/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Duskwood](../content/duskwood/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Dustwallow Marsh](../content/dustwallow/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Eastern Plaguelands](../content/eastern-plaguelands/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Elwynn Forest and Stormwind](../content/elwynn/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Felwood](../content/felwood/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Feralas](../content/feralas/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Hillsbrad Foothills](../content/hillsbrad/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [The Hinterlands](../content/hinterlands/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Loch Modan](../content/loch-modan/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Moonglade](../content/moonglade/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Mulgore and Thunder Bluff](../content/mulgore/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Peoples and Powers](../content/peoples/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Redridge Mountains](../content/redridge/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Searing Gorge](../content/searing-gorge/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Silithus](../content/silithus/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Silverpine Forest](../content/silverpine/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Stonetalon Mountains](../content/stonetalon/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Stranglethorn Vale](../content/stranglethorn/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Swamp of Sorrows](../content/swamp-of-sorrows/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Tanaris](../content/tanaris/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Teldrassil and Darnassus](../content/teldrassil/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Thousand Needles](../content/thousand-needles/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Tirisfal Glades and Undercity](../content/tirisfal/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Un'Goro Crater](../content/ungoro-crater/_chapter.md) | Corrected | Removed unproved titan authorship from the chapter summary. |
| [Western Plaguelands](../content/western-plaguelands/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Westfall](../content/westfall/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [The Wetlands](../content/wetlands/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |
| [Winterspring](../content/winterspring/_chapter.md) | Reviewed | Read summary alongside its chapter entries; no separate correction identified. |

## Validation and practical limits

Source IDs and entry IDs were preserved except for the unrelated Varo’then kill trigger on Ravencrest Monument. Existing saved page IDs remain stable. NPC and quest trigger IDs were checked for record existence in the reconstruction; this does not certify the completeness of every faction’s creature list or every spawn location.

`Content.lua` is regenerated from the corrected Markdown. The content builder, repository simulation, whitespace check and ledger coverage/hash comparison passed. These checks validate packaging and review coverage; they do not establish canonical accuracy. No addon behaviour was otherwise changed.
