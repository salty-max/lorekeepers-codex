/**
 * data/areas.json: the client's area table (zones and sub-zones: id, name,
 * parent), Classic Era's, from wow-data's database (../wow-data: the client's
 * AreaTable at the pinned build). Content files name places; the build turns
 * names into these ids. Run again when the pin moves.
 *
 * data/areas-forever.json: the areas WoW Forever adds (Zephras Isle, the
 * Riverglades, the new dungeons...), from Forever's database the same way;
 * only Forever's pages may name them (scripts/build.ts).
 *   bun scripts/areas.ts            both
 *   bun scripts/areas.ts --forever  Forever's only (Classic's file untouched)
 */
import { readFileSync, writeFileSync } from "node:fs";
import type * as WowDb from "../../wow-data/src/db";
import type * as WowPins from "../../wow-data/src/pins";
import type { Game } from "../../wow-data/src/pins";
import { familyPath } from "./root";

// through the family folder, from a worktree too (scripts/root.ts)
const { openDb } = (await import(familyPath("wow-data", "src", "db.ts"))) as typeof WowDb;
const { PINS } = (await import(familyPath("wow-data", "src", "pins.ts"))) as typeof WowPins;

const foreverOnly = process.argv.includes("--forever");
type Area = { id: number; name: string; parent: number; continent: number };
function areasOf(game: Game): Area[] {
  const rows = openDb(game)
    .query("SELECT ID, AreaName_lang, ParentAreaID, ContinentID FROM client_AreaTable ORDER BY rowid")
    .all() as Record<string, number | string | null>[];
  return rows
    .map((r) => ({ id: Number(r.ID), name: String(r.AreaName_lang ?? ""), parent: Number(r.ParentAreaID || 0), continent: Number(r.ContinentID || 0) }))
    .filter((a) => a.name);
}
const classicFile = new URL("../data/areas.json", import.meta.url);
if (!foreverOnly) {
  const areas = areasOf("classic");
  writeFileSync(classicFile, JSON.stringify(areas));
  console.log(`✓ ${areas.length} areas (build ${PINS.builds.classic.build}) → data/areas.json`);
}
// (the original areas keep their ids on Forever: only the new ones, and none of
// the client's placeholders)
const classicIds = new Set((JSON.parse(readFileSync(classicFile, "utf8")) as { id: number }[]).map((a) => a.id));
const added = areasOf("forever").filter((a) => !classicIds.has(a.id) && !/UNUSED|unused|^zz|TEST|Test/.test(a.name));
writeFileSync(new URL("../data/areas-forever.json", import.meta.url), JSON.stringify(added));
console.log(`✓ ${added.length} areas of Forever's own (build ${PINS.builds.forever.build}) → data/areas-forever.json`);
