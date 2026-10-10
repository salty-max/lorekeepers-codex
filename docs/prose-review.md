# Prose and timeline follow-up, 10 October 2026

Reviewed against `bb81853`. Revised 29 entries and the Alterac chapter summary;
this is a targeted follow-up, not a second certification of all 371 entries.
The earlier lore and voice ledgers remain historical records of their own pass.

## Editorial decisions

Keep the archivist's warmth, doubts and loyalties, but let them emerge from the
subject. Remove habitual instructions to the reader and comments about why a
page deserves to exist. Uncertainty belongs in an account when it changes the
story, rather than in a closing disclaimer on every page.

Gath'Ilzogg, before:

> There is no long account of his earlier life in these pages, traveller. His
> place here is earned by the trouble he is causing now.

After:

> For Lakeshire, a fortress on the skyline has become a measure of how much of
> its own country the town can no longer reach.

The Royal Apothecary Society, before:

> The stated enemy and the people made to suffer in the experiments deserve
> separate lines in the record.

After:

> The Forsaken know better than most what it means to have a plague take one's
> home. That knowledge has not made all of their apothecaries reluctant to
> visit the same misery on someone else's.

The second reaction rests on the contrast already present in the quests. It
does not borrow the Wrathgate or the Forsaken's later history. Stalvan's account
also now makes clear that the imagined romance and sense of betrayal were his.

## Two worlds

Use the existing build-time paragraph selection, retaining shared history.
The installed package contains only its own account, without editorial tags.

| Entry | Treatment |
| --- | --- |
| Alterac Mountains; Dalaran | Classic's dome and Forever's current crisis have separate paragraphs. |
| Azshara; Furbolgs | Separate accounts of the northern hold; Blackmaw is not a renamed Timbermaw tribe. |
| Ironforge | Forever adds the Hall of Thanes beneath the older city. |
| Un'Goro | Forever adds the Shapers' Terrace without inventing its revelations. |
| Hunters, druids, priests, mages, warlocks, paladins | Keep new combinations in Forever paragraphs; add human hunters and remove invented cultural reactions. |
| Alterac chapter summary | Shared wording no longer calls Dalaran sealed in both games. |

The warlock introduction now describes Gul'dan's corruption of the orcish
Horde, rather than claiming that fel magic first reached Azeroth with it. The
Silver Hand was shattered in the Third War; its surviving knights and Tirion's
Vanilla story make saying it did not survive too absolute.

## Sources consulted for this follow-up

Read quest descriptions and completion text, not player-comment speculation.
Wowhead and ClassicDB are mirrors of game text, not Blizzard publications.
The Warcraft Wiki is a route to period sources, not permission to import later
retcons. Existing historical material still follows the pre-Wrath boundary in
CLAUDE.md and the period sources in `lore-review.json`.

### Forever

- [An Alarming Request, quest 92432](https://www.wowhead.com/forever/quest=92432/an-alarming-request): Modera's appeal.
- [Old Ironforge Incursion, quest 96393](https://www.wowhead.com/forever/quest=96393/old-ironforge-incursion): the Hall of Thanes conflict.
- [Blizzard's what's-next recap](https://news.blizzard.com/en-us/article/24303862/world-of-warcraft-forever-whats-next-panel-recap): the announced Shapers' Terrace.
- [Blizzard's class roster](https://news.blizzard.com/en-us/article/24304075/create-the-hero-you-want-to-be-in-world-of-warcraft-forever): the new playable combinations.
- [Blizzard's Skyborne introduction](https://news.blizzard.com/en-us/article/24302071/wow-forever-meet-the-new-skyborne): the High Order's purpose.
- [Developer interview quotations about Blackmaw](https://www.icy-veins.com/wow-forever/news/everything-we-know-about-blackmaw-hold-in-wow-forever/): explicitly distinguishes the tribes. This is a secondary publication quoting the developer; the linked video was not independently viewed.

### Original-world quests

| Subject | Period game text checked online |
| --- | --- |
| Gath'Ilzogg | [Wanted: Gath'Ilzogg, 169](https://www.wowhead.com/classic/quest=169/wanted-gathilzogg) |
| Myzrael | [Legends of the Earth, 636](https://classicdb.ch/?quest=636); [Summoning the Princess, 656](https://www.wowhead.com/classic/quest=656/summoning-the-princess) |
| Azuregos | [Azuregos's Magical Ledger, 8575](https://www.wowhead.com/classic/quest=8575/azuregoss-magical-ledger); [The Wrath of Neptulon, 8729](https://www.wowhead.com/classic/quest=8729/the-wrath-of-neptulon) |
| Bael Modan | [Gann's Reclamation, 843](https://www.wowhead.com/classic/quest=843/ganns-reclamation) |
| Remtravel | [The Absent Minded Prospector, 729](https://www.wowhead.com/classic/quest=729/the-absent-minded-prospector) |
| Stalvan | [The Legend of Stalvan, 98](https://www.wowhead.com/classic/quest=98/the-legend-of-stalvan); [Muddy Journal Pages, original item text](https://warcraft.wiki.gg/wiki/Muddy_Journal_Pages) |
| SI:7 | [The Shadow of the Past, 393](https://www.wowhead.com/classic/quest=393/shadow-of-the-past) |
| Apothecaries | [A New Plague, 367](https://www.wowhead.com/classic/quest=367/a-new-plague); [Elixir of Pain, 501](https://www.wowhead.com/classic/quest=501/elixir-of-pain) |
| Collie's research | [The Eastern Pylon, 4287](https://www.wowhead.com/classic/quest=4287/the-eastern-pylon) |
| Mosshide | [Tramping Paws, 276](https://www.wowhead.com/classic/quest=276/tramping-paws) |

The Frostmane entry keeps the conflict visible in the original quests without
inventing treaties. Karazhan, the satyrs, the black flight, Arugal and
Varimathras retain the historical claims supported by the previous audit's
period sources; this pass rewrites their framing, not their later fates.

## Limits and validation

Map names alone do not establish that Gilneas has reopened. No such change has
been written. Neither an announced Titan site nor a new dungeon name supplies
an ending to its story. No later expansion has been used to fill those gaps.

Both generated books were rebuilt. Client simulations now check the changed
places and new class combinations, including the absence of the other world's
paragraphs. `bun run check` passes for both games. A separate comparison of the
compiled tables against the baseline found every non-prose value unchanged:
IDs, unlocks, links, portraits, ordering and page membership. Only text and the
one chapter summary differ.
