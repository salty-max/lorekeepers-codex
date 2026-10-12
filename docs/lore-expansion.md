# Lore to add (12 October 2026)

The user's decision: the codex loosens its sources like the Field Journal's
expeditions. Any source may tell the world's past up to the vanilla era
(games, novels, short stories, comics, RPG books, Chronicle), so long as
nothing in it is anachronic to vanilla or Forever (CLAUDE.md, "Lore"). The
goal: a substantial amount of new lore to find.

**65 new pages** in three waves (31, 19, 15), one new chapter, one new kind
of unlock, and eight existing pages to deepen. The codex has 371 entries
today; this adds about a sixth.

How to read the tables: **Unlock** gives the anchors, each checked against
the pinned classic-db dump and `data/areas.json` (area ids, creature and quest
ids); ❓ marks what to settle before writing. `read:` needs Wave 0. **Keep out**
lists what the page must not import: a later fate, a later answer to a mystery
vanilla leaves open, another continuity. Each page still goes through the
usual steps: ids checked on Wowhead Classic, sources read in full, the pages
it overlaps reread, `bun run check`.

## Wave 0: reading unlocks the old histories (done, 12 October 2026)

The original game put some forty history books in its libraries, inns and
dungeons (gameobjects 175724-175763, 21581-21583: *The Old Gods and the
Ordering of Azeroth*, *The Seven Kingdoms*, *The War of the Spider*…), plus
plaques and graves: the five Valley of Heroes plaques (25329-25333), the Rock
of Durotan (179909), the Monument to Grom Hellscream (21004), the Scarlet
Monastery's tombs (175771-175781). Few players open them. A page that unlocks
when its book is read is the clearest moment of meeting the codex can offer,
and makes the libraries worth exploring.

- **`read: <title>`**: the Library (Library.lua) already copies every text
  read, by title; an unlock fires when a text of that title is copied. The
  build checks the title against the dump's gameobject names.
- Titles are the English client's: until the source object can be told
  (research: whether Classic 1.15 and Forever give the object's GUID on
  `ITEM_TEXT_BEGIN`, as the Field Journal's expeditions need too), every page
  with a `read:` keeps another route, an area or a creature.
- A `read:` unlock may only reveal a page of a chapter the reader can reach
  from where the book stands: the new chapter below (global, like Peoples and
  Powers) or the book's own zone.

## A new chapter: Ages Past

`content/ages-past/` (order 97, before the Callings): the world's history in
the order it happened, each page unlocked by its period book wherever a copy
stands, or by a place that evokes it. The zone chapters keep their local
histories; this holds what belongs to no single land.

## Wave 1: 31 pages (written, 12 October 2026)

### Ages Past (11)

| Page | Unlock | The story | Sources · keep out |
|---|---|---|---|
| The Ordering of Azeroth | read *The Old Gods and the Ordering of Azeroth* (175725); area The Maker's Terrace (1897, Badlands) | The Titans found a world ruled by the Old Gods and their elementals, chained the gods beneath the earth, banished the Elemental Lords and left keepers behind: the root of Uldaman, Ragnaros, Thunderaan and Ahn'Qiraj | The book; WC3 manual; Chronicle I. Out: the Curse of Flesh, world-souls, the Light and the Void, Old Gods named after vanilla (Yogg-Saron, N'Zoth, Y'Shaarj) |
| The Five Aspects | read *Charge of the Dragonflights* (175726); npc Haleh 10929, Itharius 5353, Anachronos 15192, Chromie 10667 | The Titans' charges to Alexstrasza, Ysera, Malygos, Nozdormu and Neltharion; the Demon Soul and the flights broken by Neltharion's betrayal | The book; *Day of the Dragon*; the War of the Ancients trilogy. Out: the Nexus War, the Cataclysm, Dragonflight's proto-dragon origins |
| The Seven Kingdoms | read *The Seven Kingdoms* (175737, Stratholme and Scholomance); area Ruins of Alterac (281) ❓ | Arathor's heirs become Gilneas, Alterac, Dalaran, Kul Tiras, Lordaeron, Azeroth and Stromgarde; their rivalries, and why a Trollbane still claims the oldest crown | The book; WC2 manual; Chronicle II. Out: Gilneas' worgen revolt, Kul Tiras after vanilla |
| The Guardians of Tirisfal | read *The Guardians of Tirisfal* (175735), *Aegwynn and the Dragon Hunt* (175738), *The Last Guardian* (175740); area Karazhan (2562), The Master's Cellar (2837) | A secret council of human and elven magi that put immense power in one champion; Aegwynn's defiance, and how her son inherited what she hid | The books; *The Last Guardian* (2001). Out: later Guardians and councils (research doc, page 6) |
| Draenor | read *Rise of the Horde* (175742); area The Dark Portal (72) | The orcs' green world before the Portal: the clans and their shamans, the draenei refugees, Kil'jaeden's deceit through Ner'zhul, a people turned to the warlocks' path | *Rise of the Horde* (2006); the book; WC2 manual. Out: Warlords' alternate Draenor, Outland's present |
| The First War | read *The Dark Portal and the Fall of Stormwind* (175745); area Stormwind City ❓ | Medivh opens the Portal; Stormwind stands, then falls; King Llane dies by Garona's hand; Lothar leads the survivors across the sea | WC1 and its manual; *The Last Guardian*; *Tides of Darkness*. Out: the Warcraft film and its novel |
| The Second War | read *The Alliance of Lordaeron* (175746); area Blackrock Spire (1583) | Lothar's Alliance of Lordaeron; the Horde through Khaz Modan, Hillsbrad and the burning forests of Quel'Thalas; Gul'dan's betrayal; Lothar falls at Blackrock Spire, Turalyon breaks the Horde | The book; WC2; *Tides of Darkness*. Out: Turalyon's later fate |
| The Lich King | read *The Birth of the Lich King* (175748), *Icecrown and the Frozen Throne* (175749), *The Lich King Triumphant* (175762) | Ner'zhul's punishment: a spirit in a block of ice at the roof of the world, the plague he planned, and the prince who climbed to his throne | The books; WC3 and The Frozen Throne. Out: the Jailer, Bolvar, anything in Northrend after The Frozen Throne |
| The War of the Spider | read *War of the Spider* (175753); kill Crypt Fiend 8555, Crypt Walker 8556, Crypt Horror 8557, Crypt Crawler 10412, Nerub'enkan 10437 | Azjol-Nerub, the spider kingdom that fought the Lich King and lost; why its dead now serve him in the Plaguelands | The book; The Frozen Throne (Anub'arak). Out: Wrath's Azjol-Nerub, what lies beneath it |
| The Fall of Quel'Thalas | read *Sunwell - The Fall of Quel'Thalas* (175757); area Quel'Lithien Lodge (2276) | Arthas at the elven gates, Sylvanas' rangers, King Anasterian slain, the Sunwell defiled to raise Kel'Thuzad | The book; WC3. Out: the Sunwell restored, Silvermoon after vanilla |
| The Battle of Mount Hyjal | read *Archimonde's Return and the Flight to Kalimdor* (175758); area Darkwhisper Gorge (2256) ❓ | The Prophet sends humans and orcs west; Jaina, Thrall, Tyrande and Malfurion hold the mountain; Archimonde falls at the World Tree and the night elves lose their immortality | The book; WC3. Out: the Caverns of Time raid, the Firelands |

### Peoples and Powers (11)

| Page | Kind | Unlock | The story | Sources · keep out |
|---|---|---|---|---|
| The High Elves | faction | kill Highvale Outrunner 2691, Scout 2692, Marksman 2693, Ranger 2694; npc Quel'Lithien Protector 12322; read *Exile of the High Elves* (175731), *The Founding of Quel'Thalas* (175733) | Dath'Remar's exile, the Sunwell and Quel'Thalas, the old alliance with Arathor, and the survivors scattered in Hinterlands lodges | The books; WC2, WC3. Out: the Silver Covenant, Kith'ix, one allegiance for every elf (research doc, page 5) |
| The Blood Elves | faction | kill Blood Elf Surveyor 6198, Reclaimer 6199 ❓ (the dump's spawns fall in Winterspring's box: check Wowhead); area Thalassian Base Camp (1220, Azshara); read *Rise of the Blood Elves* (175760) | Kael'thas renamed his people for their dead; a hunger for magic; what their surveyors want in Azshara | The book; The Frozen Throne. Out: TBC's Silvermoon, playable blood elves, Kael's fall |
| The Timbermaw | faction | reputation 576 friendly; area Timbermaw Hold (1769, 1216) | The furbolgs who kept their minds when their kin went mad, and who decide whom to trust | Quests 8460, 8461, 8481, 8484, 8485. Out: claiming the corruption cured (research doc, page 4) |
| The Sentinels | faction | npc Sentinel Kyra Starsong 2081, Shayla Nightbreeze 2155, Arynia Cloudsbreak 3519 (Teldrassil), Elissa Starbreeze 3657 ❓; read *The Sentinels and the Long Vigil* (175732) | Ten thousand years of watch while the druids slept; the priestesses who became an army | The book; WC3. Out: the Watchers folded in |
| The Shadow Council | faction | kill Jaedenar Cultist 7112, Guardian 7113, Enforcer 7114, Adept 7115, Darkweaver 7118, Warlock 7120, Hunter 7126, Legionnaire 9862, Shadow Lord Fel'dan 9517, Darbel Montrose 2598 (Hillsbrad); read *Kil'jaeden and the Shadow Pact* (175741) | Gul'dan's hidden government of the old Horde, and the cult that outlived him | The book; WC2; quest 5242. Out: Outland, the warlock class quests (research doc, page 9) |
| The Blue Dragonflight | faction | npc Haleh 10929 (Winterspring); kill Blue Scalebane 6130 (Azshara) | Malygos' flight, keepers of magic, nearly wiped out by Neltharion's betrayal; why Azuregos searches | *Day of the Dragon*; the War of the Ancients trilogy; quests 5160-5162. Out: the Nexus War, Kalecgos |
| The Green Dragonflight | faction | npc Itharius 5353; area Seradane (356), Dream Bough (1111), Twilight Grove (856), Bough Shadow (438) | Ysera's flight, guardians of the Dream and of the four great trees; what Eranikus' fall did to it | Books 175726, 175730; quests 3374, 3512. Out: the Nightmare's master, *Stormrage* |
| The Bronze Dragonflight | faction | npc Anachronos 15192, Chromie 10667 | Nozdormu's charge over time; Anachronos at the Scarab Wall, Chromie in Andorhal and the battle of Darrowshire | Quests 4971-4973, 5154, 5721, 5941; the Scepter chain. Overlap: Darrowshire. Out: the Infinite Dragonflight, Murozond |
| The Dreadlords | creature | kill Balnazzar 10813, Dreadlord 8716 ❓ (an event's? the dump puts it in Stranglethorn); npc Varimathras 2425 | The nathrezim: the Lich King's jailers, Tichondrius, Mal'Ganis, Anetheron, and their bid for Lordaeron | WC3, *Civil War in the Plaguelands* (175761). Out: Revendreth, Denathrius |
| Cenarius | figure | npc Keeper Ordanus 4273, Keeper Albagorm 3994, Son of Cenarius 4057, Daughter of Cenarius 4053, Remulos 11832 | The forest demigod who taught Malfurion, his children the keepers and dryads, his death at Grom's hands | WC3; War of the Ancients trilogy. Out: his return, the Cataclysm's Hyjal |
| Elune | faction | npc Priestess A'moora 7313, Moon Priestess Amara 2151 ❓ | The moon goddess the kaldorei serve: the moonwells, the Sisterhood, what her blessing gave Tyrande | WC3; War of the Ancients trilogy. Out: Elune's later cosmic role (Chronicle's Light and Void, the Shadowlands) |

### The lands (9)

| Page | Chapter / kind | Unlock | The story | Sources · keep out |
|---|---|---|---|---|
| The Scythe of Elune | Duskwood / history | area Roland's Doom (2161); quest 1043 | Velinde, the Scythe and the worgen of Duskwood: an old mystery left open (research doc, page 1) | Quests 1037-1044, both journals. Out: Goldrinn, the Legion artifact |
| The Third Fleet | Wetlands / history | area The Lost Fleet (1039); quests 288, 289, 292 | The Intrepid, Captain Halyndor's cursed crew and the Eye of Paleth (page 2) | Quests 288-293. Out: the Cataclysm rewrite |
| The Sons of Lothar | Elwynn / history | area Valley of Heroes (1617); read the five plaques (25329-25333) | The five who crossed the Portal and were "presumed deceased" (page 3) | Plaques; WC2: Beyond the Dark Portal; *Beyond the Dark Portal* (2008). Out: their later return |
| The Emerald Dream | Moonglade / history | area Shrine of Remulos (2362); npc Remulos 11832; quest 8447 | The pact of Nordrassil and the Dream; why the druids sleep (page 8) | Book 175730. Out: the Nightmare's author, Ardenweald |
| Malfurion Stormrage | Moonglade / figure | area Stormrage Barrow Dens (2363); npc Remulos 11832 | The first druid: the Sundering, Nordrassil, the long sleep, the waking in the Third War, lost again in the Dream | WotA trilogy; WC3; book 175729. Out: where his spirit is, his return |
| Illidan Stormrage | Felwood / figure | area Felwood (361), Shatter Scar Vale (1766) ❓ | The vials of the Well, ten thousand years in the barrows, the Skull of Gul'dan in these woods, his banishment | Books 175729, 175759 (*The Betrayer Ascendant*, read in Darnassus: no unlock there); WC3. Out: the Black Temple, his death and return |
| Queen Azshara | Azshara / figure | area Temple of Zin-Malor (1223) | The Light of Lights, her Highborne court, the pact with Sargeras, the sea that took her | Book 21583; WotA trilogy. Out: Nazjatar, her bargain with N'Zoth |
| Rexxar | Desolace or Feralas / figure ❓ | npc Rexxar 10182, Misha 10204 (he walks the road between them; the dump spawns him in Feralas) | The half-ogre who helped found Durotar and chose the wild (page 3) | The Frozen Throne; *Cycle of Hatred*; quests 6567, 6568. Out: TBC's Rexxar |
| Durotan and Draka | Alterac / figure | read *Rock of Durotan* (179909, in Alterac Valley); npc Drek'Thar 11946 | The Frostwolf chieftain who refused Gul'dan, his exile in Alterac, the murder, and the child found beside them | *Rise of the Horde*; *Lord of the Clans*. Out: the film, Warlords' Durotan |

## Wave 2: 19 pages (written, 12 October 2026: 18; The Broken Alliance folded into Anduin Lothar, the plagued farms narrowed to Dalson's Tears, Lothar unlocked by the Burning Steppes where he fell, the Ashbringer by Fairbanks and Renault in the Monastery)

| Page | Chapter / kind | Unlock | The story | Sources · keep out |
|---|---|---|---|---|
| The Broken Alliance | Ages Past / history | read *Aftermath of the Second War* (21581); area Nethergarde Keep (1438) | After victory: Gilneas walls itself in, Stromgarde and Quel'Thalas leave, the camps' cost, Nethergarde watching the Portal | The book. Out: Gilneas after vanilla |
| The Highborne | Peoples / faction | kill Cursed 2176, Writhing 2177, Wailing 2178 Highborne, Highborne Apparition 6116, Lichling 6117, Suffering 7523, Anguished 7524 | Azshara's caste: the exiles who became high elves, the Shen'dralar, and the restless dead of Darkshore, Azshara and Winterspring | WotA trilogy. Out: the Nightborne |
| The Earthen | Peoples / creature | kill Earthen Rocksmasher 7011, Sculptor 7012, Guardian 7076, Hallshaper 7077, Custodian 7309, Stonebreaker 7396, Stonecarver 7397 | The Titans' stone workers, asleep in Uldaman, and their kinship with the dwarves | Book 175736; Uldaman's discs. Out: the Curse of Flesh. Overlap: Platinum Discs |
| The Deathstalkers | Peoples / faction | npc Rane Yorick 1950, Quinn Yorick 1951, Erland 1978, Faerleia 2058, Lesh 2214, Adamant 3849, Vincent 4444, Zraedus 5418 | Sylvanas' rangers in death: the Forsaken's eyes in Silverpine and beyond | Vanilla quests. Out: later Forsaken intelligence |
| Grom Hellscream | Ashenvale / figure | read *Monument to Grom Hellscream* (21004) | The Warsong chief who drank first and paid last: Draenor, the camps, Kalimdor | *Rise of the Horde*; *Lord of the Clans*; WC3. Overlap: Demon Fall Canyon tells his end |
| Daelin Proudmoore | Durotar / figure | area Tiragarde Keep (372) (his sailors and marines stand at Northwatch, in the Barrens: no unlock there) | The Lord Admiral who followed his daughter west and could not make peace with the Horde | The Frozen Throne; *Cycle of Hatred*; book 175763. Out: Kul Tiras after vanilla. Overlap: Tiragarde Keep, Jaina |
| Anduin Lothar | Burning Steppes / figure | area The Pillar of Ash (253) ❓ (no memorial known: perhaps Blackrock Mountain's chapter) | The last Arathi heir, Llane's champion, the Alliance's commander, killed at Blackrock Spire | WC1, WC2; *Tides of Darkness*. Out: the film |
| Orgrim Doomhammer | Arathi / figure | area Hammerfall (321) | Durotan's friend, Blackhand's killer, Warchief of the Second War, Thrall's teacher | *Rise of the Horde*; *Lord of the Clans*. Overlap: Hammerfall |
| Arthas Menethil | Tirisfal / figure ❓ | area Ruins of Lordaeron (153) | Only if it adds the prince's earlier life (Muradin, Jaina, the hunt for the plague) without retelling The Fall of Lordaeron | *Arthas: Rise of the Lich King* (2009), WC3. Out: Icecrown after 2004 |
| Ras Frostwhisper | Western Plaguelands / figure | kill 10508; quests 5461, 5462, 5466 | The lich of Scholomance, and the man he was | The quests |
| Franclorn Forgewright | Blackrock Mountain / figure | npc 8888; quests 3801, 3802 | The ghost of the Dark Iron architect of Shadowforge City | The quests |
| Loramus Thalipedes | Azshara / figure | npc 7783; quest 3141 | The demon hunter on Azshara's shore, his tale, and the beast whose name he seeks | Quests 2744, 3141, 3508, 3509, 3602, 3621 |
| Captain Varo'then | Azshara / figure | kill Varo'then's Ghost 6118; area Shadowsong Shrine (1235) | Azshara's captain of the guard, still on watch | WotA trilogy |
| Alonsus Faol | Tirisfal / figure | area Faol's Rest (173) | The archbishop who founded the Knights of the Silver Hand, and where he lies | WC2 manual; *Tides of Darkness*. Out: the Legion's Faol |
| The Agamand Family | Tirisfal / history | area Agamand Mills (157); kill Gregor 1654, Nissa 1655, Thurman 1656, Devlin 1657; quests 354, 1821 | A family of millers who rose with the plague, and the heirlooms left behind | The quests |
| The Internment Camps | Alterac / history | area Lordamere Internment Camp (278) | The orcs' lethargy behind the walls, Blackmoore's camps, the jailbreaks | Books 175751, 175752; *Lord of the Clans*. Overlap: Durnholde, Thrall |
| The Plagued Farms | Western Plaguelands / history | area Felstone Field (199), Dalson's Tears (200), Gahrron's Withering (201), The Writhing Haunt (202); npc Janice Felstone 10778; quest 5058 | The families of four farms: Mrs. Dalson's diary, the Felstones' girl | The quests. Overlap: Plague Cauldrons |
| The Ashbringer | Eastern Plaguelands / history ❓ | kill Highlord Mograine 16062 (Naxxramas) ❓ | The blade, Alexandros Mograine and his son's betrayal | The Scarlet Monastery event (1.11), the Corrupted Ashbringer's texts; the *Ashbringer* comic (2008) where they are silent (research doc, reserves) |
| Vaelastrasz | Blackrock Mountain / figure | kill Vaelastrasz the Corrupt 13020 (Blackwing Lair); npc 10340 ❓ (the Spire's, spawned by its event) | The red dragon who helped mortals in the Spire and was enslaved in the Lair | UBRS and BWL texts. Overlap: Blackwing Lair |

## Wave 3: 15 pages (written, 12 October 2026: 11; Morbent Fel left to Raven Hill, Taelan to Tirion, Bolvar and the Druids of the Talon for want of what the game says of them)

| Page | Chapter / kind | Unlock | The story | Sources · keep out |
|---|---|---|---|---|
| Sargeras and the Betrayal | Ages Past / history | read *Sargeras and the Betrayal* (175724) | The Titan who fell, and why his Legion keeps coming back | The book; Chronicle I. Out: Legion's Argus. Overlap: The Burning Legion |
| The Wildkin | Peoples / creature | kill Moonkin Oracle 10157, Moonkin 10158, Young 10159, Raging 10160 (Felwood) | The owl-bears of the night elves' forests, and what the corruption did to them | Chronicle I ❓ |
| The Ancients | Peoples / creature | npc Ancient Protector 2041, Ancient of Lore 3468, Ancient of War 3469; area Grove of the Ancients (448) | The living trees that fought for the kaldorei | WC3; WotA trilogy. Overlap: Onu |
| The Wintersaber Trainers | Peoples / faction | reputation 589 friendly; area Frostsaber Rock (2241) | The Sentinels who raise the white sabers of Winterspring | Their quests |
| The Earthen Ring | Peoples / faction | npc Je'neu Sancrea 12736 (Zoram'gar), Rimblat Earthshatter 16134 (Light's Hope) | The shamans' circle that keeps the elements in balance | Their quests. Out: the Cataclysm's Ring |
| Atiesh | Tanaris / history | quest 9251, 9257 | The Guardian's staff, broken and corrupted, cleansed again | The quests; *The Last Guardian* (research doc, reserves) |
| Linken | Un'Goro / figure | npc 8737; quests 3845, 3908, 3914, 3942, 3961, 3962 | A newcomer to Marshal's Refuge with a bumped head and a strange sword, remembering his adventure piece by piece | The quests (research doc, reserves) |
| Helcular | Alterac / figure | area Growless Cave (1683); quests 552, 553 | A wizard Southshore's mob killed on the edge of lichdom, and the apprentice who wants the town to pay | The quests |
| Morbent Fel | Duskwood / figure | kill 1200; quest 55 | The sorcerer in the house above Raven Hill's cemetery, and the revenge sought on him | The quests. Overlap: Raven Hill |
| Kirith the Damned | Blasted Lands / figure | npc 7728; area Serpent's Coil (1440); quest 2721 | A lieutenant tortured by Archmage Allistarj until his will broke, and what he became | The quests |
| Bolvar Fordragon | Elwynn / figure | npc 1748 | Stormwind's Highlord, regent's protector while the king is missing | Vanilla texts only. Out: everything from Wrath on |
| Stonefields and Maclures | Elwynn / history | area The Stonefield Farm (63), The Maclure Vineyards (64); npc Tommy Joe Stonefield 252, Maybell Maclure 251 | Two farming families' feud, and the young lovers caught in it | The quests |
| The Crusade's Fallen | Tirisfal / history | read the Scarlet Monastery tombs (175771-175781) | Who the Crusade buried: elves of Quel'Thalas, a lord of Alterac's Red Caverns, the first Chief Assassin | The tombs' texts |
| Taelan Fordring | Western Plaguelands / figure ❓ | npc 1842; quest 5944 | Tirion's son, Highlord of the Crusade, and what happened in Hearthglen | Quest 5944 *In Dreams*. Overlap: Tirion, Hearthglen |
| The Druids of the Talon | Stonetalon / faction ❓ | area The Talon Den (468) | Malfurion's orders of the storm crow and the bear | WC3 ❓ (check the den's creatures) |

## Pages to deepen (no new page)

| Page | With |
|---|---|
| The Burning Blade | *Cycle of Hatred* (2006) |
| Kel'Thuzad | *Road to Damnation* (2006) |
| Fandral Staghelm | *The War of the Shifting Sands* (2006): Valstann at the Scarab Wall. Out: his later fall |
| Jaina Proudmoore | *Cycle of Hatred* |
| Sylvanas Windrunner | WC3; *Arthas* (2009): the defence of Quel'Thalas |
| Stratholme, Uther's Tomb | *Arthas* (2009): the Culling, Uther's death |
| The Sundering, Tyrande Whisperwind | the War of the Ancients trilogy |
| The Scarlet Crusade, Whitemane and Mograine | the Scarlet Monastery event; *Ashbringer* where it is silent |

## Kept out on purpose

A later answer to a mystery the original game left open stays out even under
the new rule: Varian's absence (the 2007 comic's Lo'Gosh), who made the Scythe,
what ails Teldrassil, where Malfurion wanders, how the earthen became
dwarves. So does any later life of a figure above.

Forever's own lore is a separate wave after launch (FOREVER.md; the research
doc's "Forever" section). When the first of these pages ships, the store page's
sentence on sources (`addon/CURSEFORGE.md`, "Lore true to the era") changes with it.
