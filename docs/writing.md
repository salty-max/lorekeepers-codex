# Writing the Codex

What deserves a page and how a page is written (moved from CLAUDE.md on 20
October 2026). Forever's own content: `FOREVER.md`. The plan per zone: `PLAN.md`.

## What deserves a page (the user's editorial line)

Three tests, all required: (1) there's a story beyond what the game shows;
(2) the player meets it at a clear moment (arriving, talking, killing,
finishing a story); lore never met directly hangs on a place or person that
evokes it (the War of the Three Hammers unlocks at Anvilmar); (3) it holds up
in sources true to the era (see Lore below).

- Zones: every zone gets one page.
- Places: towns, capitals (one page each, no districts), landmarks with a
  story. Not generic camps or quest caves.
- Figures: lore figures and storyline leads only (rulers, leaders, the heart
  of a quest chain). Not vendors, trainers, one-off quest givers or locals.
- Peoples/factions: one page per people, unlocked by any member; the playable
  peoples by a player of them (`people:`), one's own from the start.
- Callings: one page per class (`kind: calling`, chapter `callings`), unlocked
  by a player of it (`calling:`), one's own from the start; a class a game
  adds (Forever's) in a `[forever]` paragraph.
- Creatures: only rares with a story and identity (Timber); not every rare,
  not ordinary wildlife.
- History: regional events, hung on a related place or quest.
- As many pages as the zone has stories: a small zone 8–10, a large one like
  the Barrens 30+. Every page still earns its place. The plan per zone is
  PLAN.md (status, unlock, what to check): update it as pages land.

Timber is an explicit user-approved exception: preserve its hunter tale
as flavour text without an in-entry label. This does not permit unsupported
historical claims in other entries.

## Writing pages (the product is the text)

- Two games read the codex: Classic and Forever (the original world on the
  modern client, with new zones, quests and the Skyborne). A page or paragraph
  for one only says so (`client:` front matter, `[forever]`/`[classic]`
  paragraphs). An unlock may also start with `[classic]` or `[forever]` when
  its place or creature belongs to that game alone; the build keeps that rule
  only in its game's content. Forever-only content may use Forever's own texts
  (quests, NPCs, books); everything else keeps the Lore rule below. See FOREVER.md.

- Voice: Royal Historian Archesonus (a dwarf; she), writing from the High
  Seat in Ironforge, a few steps from King Magni's throne; the Explorers'
  League is the city's and her help, not her order (never "we" for it);
  addresses the reader as "traveller"; warm, dry, a scholar's asides. Short:
  two to four paragraphs. A Horde reader's copy comes through Parqual
  Fintallas (the Apothecarium, Undercity; Lordaeron's historian before the
  plague): the Horde races' forewords are his, and his notes in the pages are
  `[horde]` paragraphs (`[alliance]`: the other side's only).
- The two voices. Archesonus: a dwarf of the court, warm and dry, proud of
  Ironforge and honest about it; the Dark Irons are her subject, Magni's house
  her charge, and she tells a story at length; she knows the Horde's lands from
  others' accounts. Parqual's notes: only where a Forsaken who was Lordaeron's
  historian sees it otherwise (Lordaeron and the plague, the Scarlet Crusade,
  the camps, the Horde's own), never by habit (some 25 pages); one to three
  sentences, "[horde] > ... -- P. F." at the page's end (an aside: the kit's
  page sets it apart in his ink, the initials under it; no "in another hand"
  in the words); precise
  and cutting, a dead man's dry humour, knowledge over strength, a teacher who
  sets tests, contempt for the Crusade; his point of view only, no new facts of
  his life beyond the sources (Lordaeron's historian before the plague, the
  Test of Lore, its book from the Scarlet Monastery), not even a small one
  ("mine among them"). Vary the endings and openings: most end plainly, on a
  disagreement or an open question; a sharp last line only where it is the
  point (a handful), else the notes become a formula.
- Plain ASCII text: straight apostrophes and quotes (the build rejects others;
  some game fonts lack them, and the search matches what players type).
- No semicolons in prose, English or French (the user's rule, 14 October
  2026): two sentences, or a comma, or a rewrite for a list. The gender
  tokens' own `;` stay.
- The approved voice samples are in `docs/voice-comparison.md`. Prefer concrete
  details and natural flow; keep dry asides sparse, vary openings and endings,
  and do not turn an entry into an audit note or append advice by habit. The
  completed entry decisions are recorded in `docs/voice-review.md`.
- Lore (the user's scope; loosened on 12 October 2026 to match the Field
  Journal's): **everything from the origin of the universe up to the vanilla
  era**, from any source: the games (Warcraft I, II and III with their manuals,
  World of Warcraft to patch 1.12 with its quests, books and item texts, and a
  later game's look back at that past), the novels and short stories, the
  comics and manga, the RPG books, Chronicle. Nothing anachronic to vanilla or
  Forever: no event after the vanilla era (a later fate, a return, a death to
  come), and no later answer to a mystery vanilla leaves open (who made the
  Scythe of Elune, what ails Teldrassil, where Malfurion's spirit wanders,
  how the earthen became dwarves). When a later retelling contradicts the
  period texts (Warcraft I-III and the original game, with their manuals and
  books), the period texts win; where they are silent and the later account
  disputed, write around it. Other continuities stay out: the Warcraft film
  with its novel and comic, Warlords' alternate Draenor. Note each source's
  publication and the time of what it tells, separately. Original wording,
  never copied from wikis or game text. Research each page: the Warcraft Wiki
  (`?action=raw` gives the source), checked against the source itself
  (vanilla quest texts on Wowhead); the wiki mixes eras, so date every claim.
  When sources disagree or it's uncertain, write around it rather than guess.
  The pages to add under this rule: `docs/lore-expansion.md`.
- Unlocks fire on sight (an npc targeted, not only talked to, a creature
  killed, an area entered, a text read) or on a quest turned in: a page
  unlocks only after the last thing it tells (Kalaran's on the torch's
  quests, not on meeting him). `bun run when --changed` before a commit
  prints each new page's earliest moment and what comes after it.
- Unlocks (the user's rules): places when discovered; figures when talked to;
  mobs and rares when killed (a people's page lists every creature id of it);
  capitals get one page for the whole city (no per-district pages). Ids are
  verified on Wowhead Classic (`/classic/npcs/name:X` embeds the data,
  `nether.wowhead.com/classic/tooltip/npc/ID` gives the creature type) before
  writing; never guess one.
- Textures: only ones the Classic UI itself uses (check Gethe/wow-ui-source,
  branch classic_era); a wrong path silently shows nothing.
