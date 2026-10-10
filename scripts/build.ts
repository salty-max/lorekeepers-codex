/**
 * content/**\/*.md → addon/LorekeepersCodex/Content_Classic.lua, Content_Forever.lua
 *
 * Each entry is a Markdown file with a small front matter:
 *
 *   ---
 *   id: kharanos
 *   title: Kharanos
 *   kind: place                 # place | figure | faction | creature | history | note | calling
 *   unlock:                     # any one of these unlocks it
 *     - area: Kharanos          # a zone or sub-zone, by its name in the game data
 *     - area: Gnomeregan (Dun Morogh)   # parent zone, when the name is ambiguous
 *     - area: Gnomeregan (zone)         # the top-level area: the dungeon itself
 *     - npc: 2784               # talking to (or targeting) this creature
 *     - kill: 706, 946          # killing one of these creatures
 *     - quest: 1234             # turning in this quest (or having done it)
 *     - reputation: 47 friendly # reaching a standing with a faction
 *     - position: 1455 74 10 6  # within 6 (map %) of x 74 y 10 on uiMap 1455
 *     - people: Dwarf           # a player of this race met (targeted), or one's own
 *     - calling: MAGE           # a player of this class met (targeted), or one's own
 *   also: [war-of-the-three-hammers]
 *   race: Dwarf, Gnome          # only for these races (UnitRace tokens, or
 *                               # "other" for races without a page of their own)
 *   client: forever             # only on this client (forever or classic)
 *   portrait: 2784              # the creature whose still portrait heads the
 *                               # page (figures, creatures, factions: the figure,
 *                               # a typical one, the leader); its display id
 *                               # comes from data/portraits.json (scripts/portraits.py)
 *   ---
 *   Paragraphs, separated by blank lines. A paragraph in *asterisks* is a signature.
 *   A paragraph starting with [forever] or [classic] shows on that client only
 *   (a Forever variant: the [classic] paragraph and its [forever] replacement).
 *   On Forever, which closes the combat log to addons, kill unlocks also fire
 *   on targeting the creature.
 *
 * A chapter is a folder with a _chapter.md (title, order, a one-line summary).
 * Places are resolved to the game's area ids (data/areas.json, from the client's
 * AreaTable), so unlocking works in every client language.
 *
 *   bun scripts/build.ts          write the content files
 *   bun scripts/build.ts --check  fail if one isn't up to date
 */
import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join, relative } from "node:path";

const ROOT = new URL("..", import.meta.url).pathname;
const CONTENT = join(ROOT, "content");

const KINDS = ["place", "figure", "faction", "creature", "history", "note", "calling"] as const;
const CLASSES = ["WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID"];
const RACES = ["Human", "Dwarf", "NightElf", "Gnome", "Orc", "Troll", "Tauren", "Scourge", "Skyborne", "other"];
const STANDINGS: Record<string, number> = { hated: 1, hostile: 2, unfriendly: 3, neutral: 4, friendly: 5, honored: 6, revered: 7, exalted: 8 };

type Area = { id: number; name: string; parent: number };
type Unlock = { always: true } | { area: number } | { npc: number } | { kill: number } | { quest: number } | { faction: number; standing: number } | { map: number; x: number; y: number; r: number } | { people: string } | { calling: string };
type Entry = { id: string; title: string; kind: string; portrait: number; chapter: string; unlock: Unlock[]; also: string[]; race: string[]; client: string; text: Para[]; file: string };
type Para = { italic: boolean; text: string; client: string };
const CLIENTS = ["classic", "forever"];

const classicAreas: Area[] = JSON.parse(readFileSync(join(ROOT, "data/areas.json"), "utf8"));
// Forever's own areas (data/areas-forever.json, scripts/areas.ts): for Forever's pages only.
const foreverAreas: Area[] = JSON.parse(readFileSync(join(ROOT, "data/areas-forever.json"), "utf8"));
const areas = [...classicAreas, ...foreverAreas];
const areaById = new Map(areas.map((a) => [a.id, a]));
const foreverOnly = new Set(foreverAreas.map((a) => a.id));
const portraits: Record<number, { name: string; display: number }> = JSON.parse(readFileSync(join(ROOT, "data/portraits.json"), "utf8"));
const errors: string[] = [];
const fail = (file: string, msg: string) => errors.push(`${relative(ROOT, file)}: ${msg}`);

function frontMatter(file: string, src: string): { meta: Record<string, string | string[]>; body: string } {
  const m = src.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/);
  if (!m) {
    fail(file, "no front matter");
    return { meta: {}, body: src };
  }
  const meta: Record<string, string | string[]> = {};
  let list: string[] | null = null;
  for (const raw of m[1].split("\n")) {
    const line = raw.replace(/\s+#.*$/, "");
    if (!line.trim()) continue;
    const item = line.match(/^\s+-\s+(.*)$/);
    if (item && list) {
      list.push(item[1].trim());
      continue;
    }
    const kv = line.match(/^([a-z]+):\s*(.*)$/);
    if (!kv) {
      fail(file, `can't read "${raw}"`);
      continue;
    }
    if (kv[2] === "") meta[kv[1]] = list = [];
    else {
      meta[kv[1]] = kv[2].trim();
      list = null;
    }
  }
  return { meta, body: m[2] };
}

function resolveArea(file: string, spec: string, client: string): number | null {
  const m = spec.match(/^(.*?)\s*(?:\((.*)\))?$/);
  const name = m?.[1] ?? spec;
  const parent = m?.[2];
  // Some names end with a space in the client data ("Ruins of Eldarath ").
  // (Forever's own places: on Forever's pages only)
  let found = areas.filter((a) => a.name.trim() === name && (client === "forever" || !foreverOnly.has(a.id)));
  // "(zone)" means a top-level area: a zone, or an instance such as a dungeon.
  if (parent === "zone") found = found.filter((a) => a.parent === 0);
  else if (parent) found = found.filter((a) => areaById.get(a.parent)?.name.trim() === parent);
  // Later clients added second copies of some places under the same zone
  // (Twilight Grove 856 and 16160): the addon matches places by name, so any
  // of them will do.
  const parentName = (a: Area) => areaById.get(a.parent)?.name.trim() ?? "";
  if (found.length && found.every((a) => parentName(a) === parentName(found[0]))) return Math.min(...found.map((a) => a.id));
  if (!found.length) fail(file, `no area "${spec}" in data/areas.json`);
  else fail(file, `"${spec}" is ambiguous: ${found.map((a) => `${a.name} (${areaById.get(a.parent)?.name ?? "zone"})`).join(", ")}; add the parent in parentheses`);
  return null;
}

function unlockRule(file: string, rule: string, client: string): Unlock[] {
  // npc and kill take several ids: one rule each.
  const many = rule.match(/^(npc|kill):\s*(.+)$/);
  if (many) {
    const ids = many[2].split(",").map((v) => Number(v.trim()));
    if (!ids.every((id) => Number.isInteger(id) && id > 0)) return fail(file, `${many[1]} needs numeric ids`), [];
    return ids.map((id) => (many[1] === "npc" ? { npc: id } : { kill: id }));
  }
  const one = unlockOne(file, rule, client);
  return one ? [one] : [];
}

function unlockOne(file: string, rule: string, client: string): Unlock | null {
  if (rule === "always") return { always: true };
  const m = rule.match(/^([a-z]+):\s*(.+)$/);
  if (!m) return fail(file, `bad unlock "${rule}"`), null;
  const [, key, value] = m;
  const num = (v: string) => (Number.isInteger(Number(v)) && Number(v) > 0 ? Number(v) : null);
  switch (key) {
    case "area": {
      const id = resolveArea(file, value, client);
      return id == null ? null : { area: id };
    }
    case "quest": {
      const id = num(value);
      if (id == null) return fail(file, "quest needs a numeric id"), null;
      return { quest: id };
    }
    case "reputation": {
      const [faction, standing] = value.split(/\s+/);
      if (num(faction) == null || !STANDINGS[standing?.toLowerCase()]) return fail(file, `reputation: <faction id> <${Object.keys(STANDINGS).join("|")}>`), null;
      return { faction: num(faction)!, standing: STANDINGS[standing.toLowerCase()] };
    }
    case "people": {
      const race = value.trim();
      if (!RACES.includes(race) || race === "other") return fail(file, `people: one of ${RACES.filter((r) => r !== "other").join(", ")}`), null;
      return { people: race };
    }
    case "calling": {
      const cls = value.trim();
      if (!CLASSES.includes(cls)) return fail(file, `calling: one of ${CLASSES.join(", ")}`), null;
      return { calling: cls };
    }
    case "position": {
      const [map, x, y, r] = value.split(/\s+/).map(Number);
      if (![map, x, y, r].every(Number.isFinite)) return fail(file, "position: <uiMapID> <x %> <y %> <radius %>"), null;
      return { map, x, y, r };
    }
  }
  return fail(file, `unknown unlock "${key}"`), null;
}

function paragraphs(body: string) {
  return body
    .trim()
    .split(/\n\s*\n/)
    .map((p) => p.replace(/\s*\n\s*/g, " ").trim())
    .filter(Boolean)
    .map((p): Para => {
      // "[forever] ..." or "[classic] ...": a paragraph for one client only.
      const m = p.match(/^\[(\w+)\]\s+/);
      const client = m ? m[1] : "";
      if (m) p = p.slice(m[0].length);
      const italic = /^\*[^*].*[^*]\*$/.test(p);
      return { italic, text: italic ? p.slice(1, -1) : p, client };
    });
}

const walk = (dir: string): string[] =>
  readdirSync(dir).flatMap((f) => (statSync(join(dir, f)).isDirectory() ? walk(join(dir, f)) : f.endsWith(".md") ? [join(dir, f)] : []));

const chapters = new Map<string, { id: string; title: string; order: number; summary: string; entries: string[] }>();
const entries: Entry[] = [];
for (const file of walk(CONTENT).sort()) {
  const rel = relative(CONTENT, file);
  const chapter = rel.includes("/") ? rel.split("/")[0] : "";
  const source = readFileSync(file, "utf8");
  // Plain ASCII, like the game's own texts: some of its fonts lack curly quotes
  // and dashes, and the book's search matches what players type.
  const odd = source.match(/[^\x00-\x7f]/);
  if (odd) fail(file, `non-ASCII character "${odd[0]}": use ' for apostrophes, plain quotes and dashes`);
  const { meta, body } = frontMatter(file, source);
  if (rel.endsWith("_chapter.md")) {
    chapters.set(chapter, { id: chapter, title: String(meta.title ?? chapter), order: Number(meta.order ?? 99), summary: body.trim(), entries: [] });
    continue;
  }
  const id = String(meta.id ?? "");
  if (!/^[a-z0-9-]+$/.test(id)) fail(file, "id: lowercase words joined by dashes");
  if (!meta.title) fail(file, "no title");
  if (!KINDS.includes(meta.kind as (typeof KINDS)[number])) fail(file, `kind: one of ${KINDS.join(", ")}`);
  const rules = meta.unlock === "always" ? ["always"] : Array.isArray(meta.unlock) ? meta.unlock : [];
  if (!rules.length) fail(file, "no unlock rule");
  const also = typeof meta.also === "string" ? meta.also.replace(/^\[|\]$/g, "").split(",").map((s) => s.trim()).filter(Boolean) : [];
  entries.push({
    id,
    title: String(meta.title ?? id),
    kind: String(meta.kind),
    portrait: Number(meta.portrait ?? 0),
    chapter,
    unlock: rules.flatMap((r) => unlockRule(file, r, typeof meta.client === "string" ? meta.client.trim() : "")),
    also,
    text: paragraphs(body),
    race: typeof meta.race === "string" ? meta.race.split(",").map((r) => r.trim()) : [],
    client: typeof meta.client === "string" ? meta.client.trim() : "",
    file,
  });
}

const ids = new Set<string>();
for (const e of entries) {
  if (ids.has(e.id)) fail(e.file, `duplicate id ${e.id}`);
  ids.add(e.id);
  if (e.portrait && !portraits[e.portrait]?.display) fail(e.file, `portrait: no display for creature ${e.portrait} (run python3 scripts/portraits.py)`);
  if (e.chapter && !chapters.has(e.chapter)) fail(e.file, `chapter folder ${e.chapter} has no _chapter.md`);
  for (const a of e.also) if (!entries.some((o) => o.id === a)) fail(e.file, `also: no entry "${a}"`);
  if (!e.text.length) fail(e.file, "no text");
  for (const r of e.race) if (!RACES.includes(r)) fail(e.file, `race: one of ${RACES.join(", ")}`);
  if (e.client && !CLIENTS.includes(e.client)) fail(e.file, `client: one of ${CLIENTS.join(", ")}`);
  for (const p of e.text) if (p.client && !CLIENTS.includes(p.client)) fail(e.file, `[${p.client}]: one of ${CLIENTS.join(", ")}`);
}
if (errors.length) {
  console.error(errors.map((e) => `✗ ${e}`).join("\n"));
  process.exit(1);
}
for (const e of entries) if (e.chapter) chapters.get(e.chapter)!.entries.push(e.id);
for (const c of chapters.values()) c.entries.sort((a, b) => entries.find((e) => e.id === a)!.title.localeCompare(entries.find((e) => e.id === b)!.title));

// ── Lua ─────────────────────────────────────────────────────────────────────
const q = (s: string) => `"${s.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n")}"`;
const unlockLua = (u: Unlock) =>
  "always" in u
    ? "{ always = true }"
    : "area" in u
      ? `{ area = ${u.area} }`
      : "npc" in u
        ? `{ npc = ${u.npc} }`
        : "kill" in u
          ? `{ kill = ${u.kill} }`
        : "quest" in u
          ? `{ quest = ${u.quest} }`
          : "faction" in u
            ? `{ faction = ${u.faction}, standing = ${u.standing} }`
            : "people" in u
              ? `{ people = ${JSON.stringify(u.people)} }`
              : "calling" in u
                ? `{ calling = ${JSON.stringify(u.calling)} }`
                : `{ map = ${u.map}, x = ${u.x}, y = ${u.y}, r = ${u.r} }`;
// One content file per game: each holds only that game's pages and paragraphs
// (front matter client:, [forever]/[classic] paragraphs), and its links and
// chapters follow. Each game's TOC loads its own.
const GAMES = [
  { client: "classic", out: join(ROOT, "addon/LorekeepersCodex/Content_Classic.lua") },
  { client: "forever", out: join(ROOT, "addon/LorekeepersCodex/Content_Forever.lua") },
];

function luaFor(client: string) {
  const mine = (c: string) => !c || c === client;
  const kept = entries.filter((e) => mine(e.client));
  const keptIds = new Set(kept.map((e) => e.id));
  const usedAreas = [...new Set(kept.flatMap((e) => e.unlock.flatMap((u) => ("area" in u ? [u.area] : []))))].sort((a, b) => a - b);
  const chapterList = [...chapters.values()]
    .sort((a, b) => a.order - b.order)
    .map((c) => ({ ...c, entries: c.entries.filter((id) => keptIds.has(id)) }))
    .filter((c) => c.entries.length);
  const lua = `-- Generated by scripts/build.ts from content/: edit the Markdown, not this file.
local _, ns = ...
ns.content = {
  client = ${q(client)},
  chapters = {
${chapterList.map((c) => `    { id = ${q(c.id)}, title = ${q(c.title)}, summary = ${q(c.summary)}, entries = { ${c.entries.map(q).join(", ")} } },`).join("\n")}
  },
  entries = {
${kept
  .map(
    (e) => `    [${q(e.id)}] = {
      title = ${q(e.title)}, kind = ${q(e.kind)}, chapter = ${q(e.chapter)},${e.portrait ? ` portrait = ${portraits[e.portrait].display},` : ""}
      unlock = { ${e.unlock.map(unlockLua).join(", ")} },
      also = { ${e.also.filter((a) => keptIds.has(a)).map(q).join(", ")} },${e.race.length ? ` race = { ${e.race.map((r) => `${r} = true`).join(", ")} },` : ""}
      text = {
${e.text.filter((p) => mine(p.client)).map((p) => `        { ${p.italic ? "italic = true, " : ""}${q(p.text)} },`).join("\n")}
      },
    },`,
  )
  .join("\n")}
  },
  -- English names of the areas used above (when the client can't name an area id).
  areaNames = { ${usedAreas.map((id) => `[${id}] = ${q(areaById.get(id)!.name)}`).join(", ")} },
}
`;
  return { lua, count: kept.length, chapters: chapterList.length };
}

if (process.argv.includes("--check")) {
  let stale = false;
  for (const g of GAMES) {
    const { lua, count } = luaFor(g.client);
    let current = "";
    try {
      current = readFileSync(g.out, "utf8");
    } catch {}
    if (current !== lua) {
      console.error(`✗ ${relative(ROOT, g.out)} is out of date: run bun scripts/build.ts`);
      stale = true;
    } else console.log(`✓ ${relative(ROOT, g.out)} up to date (${count} entries)`);
  }
  if (stale) process.exit(1);
} else {
  for (const g of GAMES) {
    const { lua, count, chapters: n } = luaFor(g.client);
    writeFileSync(g.out, lua);
    console.log(`✓ ${g.client}: ${count} entries in ${n} chapter(s) → ${relative(ROOT, g.out)}`);
  }
}
