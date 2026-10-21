# Lorekeeper's Codex

A World of Warcraft addon (Lua 5.1; Classic Era, TBC Anniversary and Forever,
a TOC each): a codex of original lore texts that unlock per character as they
play. Sister project of Yonder, in ~/code/wow-addons/yonder (same tooling and
conventions); salty-max/lorekeepers-codex. Read the family's CLAUDE.md
(`../CLAUDE.md`) first.

## Where things are

| What | Where |
|---|---|
| The addon file by file: content and build, the package, the game's data files, Core, Unlocks, Library, the book's tabs, languages, scan, the tests, the daily job, releases | `docs/architecture.md` |
| What deserves a page, the two voices (Archesonus, Parqual), the lore scope, unlocks, textures | `docs/writing.md` |
| The pages | `content/<chapter>/<id>.md`, `_chapter.md` per chapter |
| The plan per zone (status, unlock, what to check) | `PLAN.md` |
| Forever's own content | `FOREVER.md` |
| Languages: how translation works, each language's notes | `docs/localization.md`, `docs/spanish-translation.md`, `docs/french-readable-translations.md`, `docs/german-readable-translations.md` |
| The approved voice samples, the entry decisions | `docs/voice-comparison.md`, `docs/voice-review.md` |
| The pages still to add under the lore rule | `docs/lore-expansion.md` |
| The store page | `addon/CURSEFORGE.md` |

A few local review notes in `docs/` are excluded (`.git/info/exclude`):
absent from git and from a worktree. Everything else there is tracked, the
docs above included.

## Commands

```bash
bun run check        # the kit's copies, the saved ids, then check:ci (lint, the build's and languages' checks, the Spanish test, the sim on both games: what CI runs)
bun run ids          # every table saved-ids.json lists keeps the ids it had at the fork point from origin/main (addon-kit's ids.ts)
bun scripts/root.ts --run addon-kit/q.ts check -- bun run check   # the same, quiet, stamping the tree for the push
bun run build        # content -> Content_Classic.lua and Content_Forever.lua, the language files
bun run package      # dist/LorekeepersCodex-<version>.zip for a test in the game
bun run kit:sync     # after a change to the kit (Kit.lua, Media, scripts/root.ts and root.py)
bun run locales      # --keys writes i18n/words.json; --stamp once a translation is read again
bun scripts/areas.ts [--forever]   # the areas; python3 scripts/texts.py, portraits.py after a read: or portrait:
bun run when <page>|--changed|--all  # when each page unlocks and what comes after it: a page unlocks only after the last thing it tells
scripts/release.sh [--version X.Y.Z] [--hold] NOTES.md   # check, tag, push; Actions publish
```

## Hard rules

- A page passes three tests: a story beyond what the game shows, met at a
  clear moment, true to sources of the era. Lore runs from the origin of
  the universe up to the vanilla era, from any source; nothing anachronic
  to vanilla or Forever, period texts win over later retellings. Original
  wording, never copied (`docs/writing.md`).
- The voices: Royal Historian Archesonus (a dwarf, she), and Parqual
  Fintallas's `[horde]` notes only where a Forsaken sees it otherwise.
  Two to four paragraphs. Use full Opus and read `docs/writing.md` before
  writing a page.
- Plain ASCII in the English content (the build rejects others), no
  semicolons in prose in any language (gender tokens' own `;` aside).
- Ids are verified (Wowhead Classic, wow-data's card) before writing,
  never guessed. Textures only those the Classic UI itself uses.
- A regenerated table keeps every id a saved find may hold (`saved-ids.json`,
  `bun run ids` in the check): an id leaves only with the user's go, under
  `removed`.
- Where a page or a text was found is kept by ids only. Every word through
  `L`, the game's names by id in the client's language; a translation names
  what the glossary holds as the game writes it (`scripts/names.ts`).
- The game's data comes from wow-data only (scripts/, through
  `scripts/root.ts` and `root.py`); `Content_*.lua`, `data/*.json` and the
  language files are generated, `--check` fails a stale one. A new
  generator goes into `game-data.yml` too.
- `Kit.lua`, `scripts/root.ts` and `scripts/root.py` are the kit's copies:
  edit addon-kit, then `bun run kit:sync`.
- Conventional Commits, lowercase subjects, no AI trailers. Commit locally;
  ask before any push, release or deploy. The pre-push hook wants a check
  stamp on the tree (q), which `release.sh` makes after the version bump.
