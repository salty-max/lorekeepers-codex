# The account-wide library (plan, 13 November 2026)

Answers two CurseForge comments: copy one character's pages to another, and
one library for every character, with a way to see what is missing. The
user's decision: account-wide, Hardcore characters apart (a Hardcore
character's finds neither feed nor read the shared library).

## Where things live now

- `LorekeepersCodexChar` (per character): `entries[id]` (pages found, each
  `{ at, level, zoneId, subId, retro }`), `read[id]`, `tunes[id]`,
  `achievements[id]`, `met`, `library` (the texts copied), the book's folds.
- `LorekeepersCodexSettings` (account): profiles per "Name - Realm", the
  minimap place. `LorekeepersCodexCollect`, `LorekeepersCodexScan`: account.
- Everything reads a page through `ns.page(id)` (= `char.entries[id]`), and
  counts through `ns.count()`, `ns.found(ch)`, `ns.knownTotal()`.
  Direct `char.entries` users: `unlock()` and `ns.count()` and
  `ns.mendPlaces()` (Unlocks.lua), `ns.tune()` and `find()` (Soundtrack.lua).

## The data model

A new account table, `LorekeepersCodexAccount` (SavedVariables in both TOCs,
one per game, so Classic Era's and Forever's never mix):

```
LorekeepersCodexAccount = {
  entries[id] = { at, level, zoneId, subId, retro },  -- the pages any normal character found
  tunes[id]   = { at, level, zoneId, subId },
  read[id]    = true,                                 -- opened by any normal character
}
```

- `char.entries`, `char.tunes`, `char.read` stay exactly as they are and keep
  meaning "what this character earned itself". Nothing is ever removed from
  them, so a rollback to the old version loses nothing.
- A normal character reads the union: `ns.page(id)` is `char.entries[id]`
  or, if absent, `account.entries[id]`. Same for `ns.tune(id)` and
  `ns.isRead(id)`. Every count, list, search, chapter bar, achievement
  progress and link goes through those, so they follow without further change.
- A Hardcore character's `ns.page`, `ns.tune` and `ns.isRead` read only its
  own tables, and it never writes the account's.
- Writes: an unlock a normal character earns is written to both its own
  `entries` and the account's (the earliest record wins, a non-retro find
  beats a retro one). Same for tunes and for `read`.
- Migration (never drops): on every login of a normal character,
  `ns.mergeAccount()` copies each of its `entries`, `tunes` and `read` into
  the account where the account lacks them (the earlier or non-retro record
  wins, records copied, never shared tables). It is idempotent, so it runs
  every login instead of once: a character that was offline, a restored
  save, a first install, all end in the same place. The character's own
  tables are left untouched. A Hardcore character is skipped. A later
  version may stop keeping the copy once the user is sure.
- A save whose GUID is not the character's (`ns.belongsTo`, a deleted
  character's name reused) is dropped as today and never merged.
- `/codex reset yes` forgets this character's own record and achievements as
  today. The shared codex keeps every page, so they stay readable (the
  wording says so, and the found line names no finder, since after a reset
  the character's own finds read as the account's). No account-wide reset command (not asked for).

Saved ids: nothing in this change removes a table or an id. The page ids are
saved ids that `saved-ids.json` does not list yet (the open item in PLAN.md).
Stage 2 lists the pages and tunes of both games (`Content_*.lua`'s entries) so
`bun run ids` refuses a regeneration that drops one, if `ids.ts` can read
that table (checked first, else left as the PLAN.md item and said so).

## Hardcore

Same approach as Hearthtale (`Record.lua`'s `hardcore()`), never its code:
`C_GameRules.IsHardcoreActive()` through `pcall`, a secret value never
compared. Both pinned clients have it (checked with `wow-data/bin/ui.ts`:
Classic Era 1.15.9 and Forever 1.60.1 both call it in their own UI, Hardcore
realms and the seasonal Hardcore ruleset are what it answers). On Classic
Era I add one second test, `C_Seasons.GetActiveSeason() == Enum.SeasonID.Hardcore`
(the client's own Hardcore realm test, Classic Era only: Forever has no
`C_Seasons`). Either says Hardcore.

- Once a character is told Hardcore it stays Hardcore (`char.hardcore =
  true`, kept): a dead Hardcore character, or a call that fails later, never
  moves it into the shared library.
- Not told yet (no API, an error, a secret): **not Hardcore**, with the
  risk named here: a Hardcore character's first login would merge into the
  shared table if the call failed then. Both pinned clients have the call,
  so this stays a note, not a setting. If Forever's Hardcore turns out to
  answer differently when it opens, the fix is one function.
- Decided at login before anything is merged, in `ns.login()`.

## A page another character unlocked

- It is in the library and readable at once.
- No toast, chat line, sound or banner for a character that did not earn
  it. Those fire only for a page found by this character for the first time
  anywhere on the account (so a second character walking into a place whose
  page the account already holds is quiet, which also keeps a new alt from
  a flood at 400 pages).
- When this character meets the condition for such a page (it arrives at the
  place, kills the creature), the page is written to its own `entries`
  quietly, which also removes its mark (below).
- "Unlock after the last event a page tells" is unchanged: it governs when a
  page first goes into the account. The library never unlocks earlier.
- The "new" dot (unread) follows `read`, which is the account's: a page read
  on any character is not new on the others. A page nobody opened still shows
  the dot, on whichever character.
- Achievements stay per character, counted from what the character holds
  (the library included), so an alt gets the milestone ones at its first
  login quietly (retro, as a reset does today). Not made account-wide: not
  asked for.

## What am I missing

The book never says how many pages there are in all (no spoilers), and a
chapter shows only once a page of it is found, with its `found/total` bar.
That stays, and it is already the answer for what nobody found.

What the comments ask is what *this* character lacks of the account's, and
for the other direction (what is held here that the library lacks, which the
merge settles by itself). The smallest addition, in the existing look:

1. A mark in the Pages list for a page this character has not earned
   itself: the row's title in the soft colour (`T.soft`, already in the
   kit), and the page's found line reads "Found by another of your
   characters, on %s." instead of "Found in ..., at level ...".
2. One more choice in the Pages tab's existing kind select (`filter`):
   "Not found by this character yet (N)", listing exactly the pages this
   character holds only through the account, in their chapters. It answers
   "what am I missing here" without a new tab, window or term. Hidden when
   N is 0.
3. The overview's figures gain one: "found elsewhere" (the count).

Words: in the Codex "the Library" already means the texts copied from the
world, so the account-wide set is **not called "library" in the
interface**. It is "your other characters" everywhere (my title says library
because the user's word did).

## Settings

None. The behaviour is the user's decision. The Welcome page's line "Each
character keeps its own codex" is rewritten ("Your characters share one
codex, a Hardcore character keeps its own") and the store page and README
mention it.

## The Library tab (the texts copied from the world)

Shared too (the user's call at the plan's approval): `library` in the account
table, the same shape as a character's (`texts`, `keys`, `nextId`).
`ns.library()` is the account's alone for a normal character, its own for a
Hardcore one. A character's own copies are merged at each login by the key
each was copied under (or a copy of the same text in another language), pages
filled in only from a copy in the same language, the earlier reading giving the
date and place; any other text is added under a new id. The character's own
`library` is kept as it was (no new copies go to it), so the saved variables
hold the old texts twice until a later version drops the copy. The read-unlocks
at catch-up use the character's own copies only, so an alt never earns a page
for a book it did not read (it has the page through the account).

## Tests

`addon/test/sim.lua` (both games, in `check:ci`) gets a migration case:

- Two normal characters, A and B, in one fake account: A has pages and a
  tune and read marks, B different ones with an overlap (earlier timestamp
  on one side, a retro one on the other). After A's login, then B's, the
  account table holds the union with the winning records, and each
  character's own tables are byte for byte what they were.
- B reads A's page: `ns.page` returns it, `ns.count()` counts it, the
  page's found line is the other-character one, no toast, sound or banner
  fires when B meets its condition, B's own `entries` then holds it.
- A Hardcore character C (`C_GameRules.IsHardcoreActive` true, and on Classic
  the season test): not merged, `ns.page` of A's page is nil for C, C's own
  find is not in the account, and a normal D afterwards sees none of C's.
- The API missing, erroring, or a secret value: not Hardcore.
- Idempotence: a second login changes nothing. A reset on A leaves the
  library's pages readable and A's achievements gone.
- The filter's option lists exactly the pages this character has not
  earned, the counts agree.

Plus the paper-look run (`PAPER=1`) and `RENDER` for the filter's and the
mark's look, `bun run locales` / the English and French words, `bun run
check` through q.

## What stays unverified without the game

Whether `IsHardcoreActive` answers at the moment of login on both clients
(the one risk of a Hardcore character leaking), the Forever Hardcore
ruleset's answer once it opens, and how the soft-coloured rows read in the
real book.

## Missing pages (added the same day, the user's call)

An opt-in choice in the Options (`missingPages`, off by default, in the
settings' code as `k`): the Pages list also shows a greyed row for each page
this character has not found, and the chapters not started as a bare name with
`0/total`. Each chapter header already shows found/total.

- A locked row is `"???"` and nothing else: no id, title, text, kind or place
  anywhere (not in a row, a tooltip, a link, the search, the saved variables).
  It cannot be opened.
- Order: the found pages in the chapter's usual order, then the locked rows as
  one block of identical rows. A locked row never sits where its page would,
  because the position in a chapter would give away the order the pages come
  in, and the titles. The number of rows is `total - found`.
- Counts follow the account rule through `ns.page`: the union for a normal
  character, only its own pages for a Hardcore one. A search or a chosen kind
  shows no locked row. Off is today's list exactly.
- While on, the header's "N of M pages" counts every chapter (`ns.knownTotal`),
  so it agrees with the rows.
