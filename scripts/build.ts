/**
 * content/**\/*.md → addon/LorekeepersCodex/Content.lua
 *
 * Each entry is a Markdown file with a small front matter:
 *
 *   ---
 *   id: kharanos
 *   title: Kharanos
 *   kind: place                 # place | figure | faction | creature | history | note
 *   unlock:                     # any one of these unlocks it
 *     - area: Kharanos          # a zone or sub-zone, by its name in the game data
 *     - area: Gnomeregan (Dun Morogh)   # parent zone, when the name is ambiguous
 *     - npc: 2784               # talking to (or targeting) this creature
 *     - kill: 706, 946          # killing one of these creatures
 *     - quest: 1234             # turning in this quest (or having done it)
 *     - reputation: 47 friendly # reaching a standing with a faction
 *     - position: 1455 74 10 6  # within 6 (map %) of x 74 y 10 on uiMap 1455
 *   also: [war-of-the-three-hammers]
 *   excerpt: ...                # the banner's text; default: the first sentence
 *   ---
 *   Paragraphs, separated by blank lines. A paragraph in *asterisks* is a signature.
 *
 * A chapter is a folder with a _chapter.md (title, order, a one-line summary).
 * Places are resolved to the game's area ids (data/areas.json, from the client's
 * AreaTable), so unlocking works in every client language.
 *
 *   bun scripts/build.ts          write Content.lua
 *   bun scripts/build.ts --check  fail if Content.lua isn't up to date
 */
import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join, relative } from "node:path";

const ROOT = new URL("..", import.meta.url).pathname;
const CONTENT = join(ROOT, "content");
const OUT = join(ROOT, "addon/LorekeepersCodex/Content.lua");

const KINDS = ["place", "figure", "faction", "creature", "history", "note"] as const;
const STANDINGS: Record<string, number> = { hated: 1, hostile: 2, unfriendly: 3, neutral: 4, friendly: 5, honored: 6, revered: 7, exalted: 8 };

type Area = { id: number; name: string; parent: number };
type Unlock = { always: true } | { area: number } | { npc: number } | { kill: number } | { quest: number } | { faction: number; standing: number } | { map: number; x: number; y: number; r: number };
type Entry = { id: string; title: string; kind: string; chapter: string; unlock: Unlock[]; also: string[]; excerpt: string; text: { italic: boolean; text: string }[]; file: string };

const areas: Area[] = JSON.parse(readFileSync(join(ROOT, "data/areas.json"), "utf8"));
const areaById = new Map(areas.map((a) => [a.id, a]));
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

function resolveArea(file: string, spec: string): number | null {
  const m = spec.match(/^(.*?)\s*(?:\((.*)\))?$/);
  const name = m?.[1] ?? spec;
  const parent = m?.[2];
  let found = areas.filter((a) => a.name === name);
  if (parent) found = found.filter((a) => areaById.get(a.parent)?.name === parent);
  if (found.length === 1) return found[0].id;
  if (!found.length) fail(file, `no area "${spec}" in data/areas.json`);
  else fail(file, `"${spec}" is ambiguous: ${found.map((a) => `${a.name} (${areaById.get(a.parent)?.name ?? "zone"})`).join(", ")}; add the parent in parentheses`);
  return null;
}

function unlockRule(file: string, rule: string): Unlock[] {
  // npc and kill take several ids: one rule each.
  const many = rule.match(/^(npc|kill):\s*(.+)$/);
  if (many) {
    const ids = many[2].split(",").map((v) => Number(v.trim()));
    if (!ids.every((id) => Number.isInteger(id) && id > 0)) return fail(file, `${many[1]} needs numeric ids`), [];
    return ids.map((id) => (many[1] === "npc" ? { npc: id } : { kill: id }));
  }
  const one = unlockOne(file, rule);
  return one ? [one] : [];
}

function unlockOne(file: string, rule: string): Unlock | null {
  if (rule === "always") return { always: true };
  const m = rule.match(/^([a-z]+):\s*(.+)$/);
  if (!m) return fail(file, `bad unlock "${rule}"`), null;
  const [, key, value] = m;
  const num = (v: string) => (Number.isInteger(Number(v)) && Number(v) > 0 ? Number(v) : null);
  switch (key) {
    case "area": {
      const id = resolveArea(file, value);
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
    .map((p) => {
      const italic = /^\*[^*].*[^*]\*$/.test(p);
      return { italic, text: italic ? p.slice(1, -1) : p };
    });
}

// The banner shows a page's first sentence, cut at a word under 280 characters.
function excerpt(text: { italic: boolean; text: string }[]) {
  const first = text.find((p) => !p.italic)?.text ?? "";
  const sentence = first.match(/^(.+?[.!?])(\s|$)/)?.[1] ?? first;
  return sentence.length <= 280 ? sentence : `${sentence.slice(0, 280).replace(/[\s,;:]+\S*$/, "")}…`;
}

const walk = (dir: string): string[] =>
  readdirSync(dir).flatMap((f) => (statSync(join(dir, f)).isDirectory() ? walk(join(dir, f)) : f.endsWith(".md") ? [join(dir, f)] : []));

const chapters = new Map<string, { id: string; title: string; order: number; summary: string; entries: string[] }>();
const entries: Entry[] = [];
for (const file of walk(CONTENT).sort()) {
  const rel = relative(CONTENT, file);
  const chapter = rel.includes("/") ? rel.split("/")[0] : "";
  const { meta, body } = frontMatter(file, readFileSync(file, "utf8"));
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
    chapter,
    unlock: rules.flatMap((r) => unlockRule(file, r)),
    also,
    text: paragraphs(body),
    excerpt: typeof meta.excerpt === "string" ? meta.excerpt : excerpt(paragraphs(body)),
    file,
  });
}

const ids = new Set<string>();
for (const e of entries) {
  if (ids.has(e.id)) fail(e.file, `duplicate id ${e.id}`);
  ids.add(e.id);
  if (e.chapter && !chapters.has(e.chapter)) fail(e.file, `chapter folder ${e.chapter} has no _chapter.md`);
  for (const a of e.also) if (!entries.some((o) => o.id === a)) fail(e.file, `also: no entry "${a}"`);
  if (!e.text.length) fail(e.file, "no text");
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
            : `{ map = ${u.map}, x = ${u.x}, y = ${u.y}, r = ${u.r} }`;
const usedAreas = [...new Set(entries.flatMap((e) => e.unlock.flatMap((u) => ("area" in u ? [u.area] : []))))].sort((a, b) => a - b);

const lua = `-- Generated by scripts/build.ts from content/: edit the Markdown, not this file.
local _, ns = ...
ns.content = {
  chapters = {
${[...chapters.values()]
  .sort((a, b) => a.order - b.order)
  .map((c) => `    { id = ${q(c.id)}, title = ${q(c.title)}, summary = ${q(c.summary)}, entries = { ${c.entries.map(q).join(", ")} } },`)
  .join("\n")}
  },
  entries = {
${entries
  .map(
    (e) => `    [${q(e.id)}] = {
      title = ${q(e.title)}, kind = ${q(e.kind)}, chapter = ${q(e.chapter)},
      unlock = { ${e.unlock.map(unlockLua).join(", ")} },
      also = { ${e.also.map(q).join(", ")} },
      excerpt = ${q(e.excerpt)},
      text = {
${e.text.map((p) => `        { ${p.italic ? "italic = true, " : ""}${q(p.text)} },`).join("\n")}
      },
    },`,
  )
  .join("\n")}
  },
  -- English names of the areas used above (when the client can't name an area id).
  areaNames = { ${usedAreas.map((id) => `[${id}] = ${q(areaById.get(id)!.name)}`).join(", ")} },
}
`;

if (process.argv.includes("--check")) {
  const current = (() => {
    try {
      return readFileSync(OUT, "utf8");
    } catch {
      return "";
    }
  })();
  if (current !== lua) {
    console.error("✗ Content.lua is out of date: run bun scripts/build.ts");
    process.exit(1);
  }
  console.log(`✓ Content.lua up to date (${entries.length} entries)`);
} else {
  writeFileSync(OUT, lua);
  console.log(`✓ ${entries.length} entries in ${chapters.size} chapter(s) → ${relative(ROOT, OUT)}`);
}
