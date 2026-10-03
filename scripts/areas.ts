/**
 * data/areas.json: the client's area table (zones and sub-zones: id, name,
 * parent), from wago.tools' export of Classic Era. Content files name places;
 * the build turns names into these ids. Run again when a game version adds areas.
 */
import { writeFileSync } from "node:fs";

const res = await fetch("https://wago.tools/db2/AreaTable/csv?branch=wow_classic_era");
if (!res.ok) throw new Error(`AreaTable: HTTP ${res.status}`);
const [header, ...lines] = (await res.text()).trim().split("\n");
const cols = header.split(",");
const at = (name: string) => cols.indexOf(name);
// A simple CSV reader: area names may be quoted and contain commas.
const parse = (line: string) => line.match(/("([^"]|"")*"|[^,]*)(,|$)/g)!.map((c) => c.replace(/,$/, "").replace(/^"|"$/g, "").replace(/""/g, '"'));
const areas = lines
  .map(parse)
  .map((r) => ({ id: Number(r[at("ID")]), name: r[at("AreaName_lang")], parent: Number(r[at("ParentAreaID")] || 0), continent: Number(r[at("ContinentID")] || 0) }))
  .filter((a) => a.name);
writeFileSync(new URL("../data/areas.json", import.meta.url), JSON.stringify(areas));
console.log(`✓ ${areas.length} areas → data/areas.json`);
