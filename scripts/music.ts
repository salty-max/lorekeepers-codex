/**
 * data/music.json: the music of each game, from wow-data's database
 * (../wow-data: music_set, music_track, music_area, built from the client's
 * ZoneMusic, SoundKitEntry and AreaTable at the pinned build). Per game:
 *   sets   { "<ZoneMusic id>": { label, tracks: [[FileDataID, "day"|"night"|"both"], ...] } }
 *   areas  { "<area id>": { parent, sets: [[set id, exact 0|1], ...] } }
 * Only sets some area plays; a game's file ids are its own (Forever's
 * remaster has others). Read by scripts/build.ts (the `music:` unlock and the
 * Content files).
 *   bun scripts/music.ts
 */
import { writeFileSync } from "node:fs";
import type * as WowDb from "../../wow-data/src/db";
import type { Game } from "../../wow-data/src/pins";
import { familyPath } from "./root";

const { openDb } = (await import(familyPath("wow-data", "src", "db.ts"))) as typeof WowDb;

// (the client's placeholders, as scripts/areas.ts leaves them out)
const PLACEHOLDER = /UNUSED|unused|DELETE ME|Programmer|Designer|^zz|TEST|Test/;
type Set = { label: string; tracks: [number, string][] };
type AreaRow = { parent: number; sets: [number, number][] };
function musicOf(game: Game) {
  const db = openDb(game);
  const sets: Record<string, Set> = {};
  const areas: Record<string, AreaRow> = {};
  for (const r of db
    .query(
      `SELECT a.area_id, c.AreaName_lang name, c.ParentAreaID parent, a.set_id, a.exact FROM music_area a JOIN client_AreaTable c ON c.ID = a.area_id
       WHERE c.AreaName_lang <> '' ORDER BY a.area_id, a.set_id`,
    )
    .all() as { area_id: number; name: string; parent: number; set_id: number; exact: number }[]) {
    if (PLACEHOLDER.test(r.name)) continue;
    areas[r.area_id] ??= { parent: Number(r.parent || 0), sets: [] };
    areas[r.area_id].sets.push([r.set_id, r.exact]);
  }
  const used = new globalThis.Set(Object.values(areas).flatMap((a) => a.sets.map((s) => s[0])));
  for (const s of db.query("SELECT id, label FROM music_set ORDER BY id").all() as { id: number; label: string }[]) {
    if (!used.has(s.id)) continue;
    const tracks = db.query("SELECT file_id, period FROM music_track WHERE set_id = ? ORDER BY seq").all(s.id) as { file_id: number; period: string }[];
    sets[s.id] = { label: s.label, tracks: tracks.map((t) => [t.file_id, t.period]) };
  }
  return { sets, areas };
}
const out = { classic: musicOf("classic"), forever: musicOf("forever") };
writeFileSync(new URL("../data/music.json", import.meta.url), JSON.stringify(out));
for (const g of ["classic", "forever"] as const) console.log(`✓ ${g}: ${Object.keys(out[g].sets).length} sets, ${Object.keys(out[g].areas).length} areas → data/music.json`);
