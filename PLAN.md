# The plan

Every page the plan once listed per zone is written: 441 pages in 44 chapters
on Classic Era, 456 in 46 on Forever (the foreword pages included), with the
ones each zone's chapter holds in `content/`. The per-zone tables, the waves
and the review notes of October 2026 (status, unlock, what to check for each
page) were removed on 30 October 2026: every page's front matter holds its
unlock, `git log -- PLAN.md` the rest. The editorial line is in
`docs/writing.md` ("What deserves a page"), the lore still to add under
the loosened rule in `docs/lore-expansion.md`, Forever's own content in
`FOREVER.md`.

Left out on purpose: Season of Discovery additions (creature ids above
200 000, quest ids above 70 000), the Darkmoon Faire and holidays, creatures
Wowhead misfiles in a zone (Hogger in Dun Morogh, level 50 elites in Loch
Modan), class quests, and anything failing the three tests.

## How the codex is laid out

- **One chapter per zone.** A capital is in its home zone's chapter (Stormwind
  with Elwynn, Undercity with Tirisfal, Orgrimmar with Durotar, Thunder Bluff
  with Mulgore, Darnassus with Teldrassil, Ironforge with Dun Morogh).
- **Dungeons, raids and battlegrounds** are in the chapter of the zone where
  their entrance is (the Deadmines in Westfall, Zul'Gurub in Stranglethorn,
  Alterac Valley in the Alterac Mountains). The exception is **Blackrock
  Mountain**, between two zones, which has a chapter of its own.
- **Peoples and Powers**: a last chapter for peoples and factions met in many
  zones (the Defias, kobolds, murlocs, the Scarlet Crusade, centaurs…). One page
  per people, unlocked by any member anywhere. Keeping them out of the zone
  chapters keeps chapters appearing as zones are discovered: a Defias killed in
  Northshire must not reveal a Westfall chapter.
- **Unlocks stay inside their chapter's zone** (and its instances), for the
  same reason. Exceptions: reputations, earned anywhere, and the Peoples and
  Powers chapter.
- **Both factions read the same book.** Its author is Archesonus, Ironforge's
  Royal Historian; Horde lands are written by a scholar who has been there,
  fair to the Horde. A Horde reader's copy comes through Parqual Fintallas of
  the Undercity: the Horde races' forewords are his, and his notes in the
  pages (`[horde]` paragraphs). Faction-only quests are fine as unlocks as long as the page
  also unlocks another way for the other faction, or is that faction's story.
- **Pages unlocked by a quest** use its turn-in (or its having been done before
  the addon, as now).

## Still open

- Forever's 18 tuneless music sets: list them as left out in
  `data/music-left-out.json` and set `complete: true`, or write their tunes.
- The pages' ids are saved ids, but `saved-ids.json` does not list them yet,
  so `bun run ids` cannot refuse a regeneration that drops one.
