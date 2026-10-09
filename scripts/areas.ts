/**
 * data/areas.json: the client's area table (zones and sub-zones: id, name,
 * parent), from wago.tools' export of Classic Era. Content files name places;
 * the build turns names into these ids. Run again when a game version adds areas.
 *
 * data/areas-forever.json: the areas WoW Forever adds (Zephras Isle, the
 * Riverglades, the new dungeons...), from the beta client's table, pinned to
 * one build; only Forever's pages may name them (scripts/build.ts).
 *   bun scripts/areas.ts            both
 *   bun scripts/areas.ts --forever  Forever's only (Classic's file untouched)
 */
import { readFileSync, writeFileSync } from "node:fs";

export const FOREVER_BUILD = "1.60.1.70291";
const foreverOnly = process.argv.includes("--forever");
async function table(query: string) {
  const res = await fetch(`https://wago.tools/db2/AreaTable/csv?${query}`);
  if (!res.ok) throw new Error(`AreaTable: HTTP ${res.status}`);
  return res.text();
}
const res = { ok: true, status: 200, text: () => table("branch=wow_classic_era") };
// A simple CSV reader: area names may be quoted and contain commas.
const parse = (line: string) => line.match(/("([^"]|"")*"|[^,]*)(,|$)/g)!.map((c) => c.replace(/,$/, "").replace(/^"|"$/g, "").replace(/""/g, '"'));
function areasOf(text: string) {
  const [header, ...lines] = text.trim().split("\n");
  const cols = header.split(",");
  const at = (name: string) => cols.indexOf(name);
  return lines
    .map(parse)
    .map((r) => ({ id: Number(r[at("ID")]), name: r[at("AreaName_lang")], parent: Number(r[at("ParentAreaID")] || 0), continent: Number(r[at("ContinentID")] || 0) }))
    .filter((a) => a.name);
}
const classicFile = new URL("../data/areas.json", import.meta.url);
if (!foreverOnly) {
  const areas = areasOf(await res.text());
  writeFileSync(classicFile, JSON.stringify(areas));
  console.log(`✓ ${areas.length} areas → data/areas.json`);
}
// (the original areas keep their ids on Forever: only the new ones, and none of
// the client's placeholders)
const classicIds = new Set((JSON.parse(readFileSync(classicFile, "utf8")) as { id: number }[]).map((a) => a.id));
const added = areasOf(await table(`product=wow_classic_beta&build=${FOREVER_BUILD}`))
  .filter((a) => !classicIds.has(a.id) && !/UNUSED|unused|^zz|TEST|Test/.test(a.name));
writeFileSync(new URL("../data/areas-forever.json", import.meta.url), JSON.stringify(added));
console.log(`✓ ${added.length} areas of Forever's own (build ${FOREVER_BUILD}) → data/areas-forever.json`);
