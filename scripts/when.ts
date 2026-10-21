/**
 * When a page unlocks, in plain words: each of its unlock rules, the earliest
 * moment one of them can fire, and what comes after that moment (a quest's
 * later steps in its chain, the quests an npc gives), so a page is checked
 * against telling more than the player has seen. Unlocks fire on sight (an
 * npc targeted, a creature killed, an area entered, a text read) or on a
 * quest turned in (addon/LorekeepersCodex/Unlocks.lua): a page that tells a
 * chain's ending unlocks on its last quest, not on meeting its giver.
 *
 *   bun scripts/when.ts <page id or chapter/id>...   those pages
 *   bun scripts/when.ts --changed                    the pages changed since origin/main
 *   bun scripts/when.ts --all                        every page
 * Read-only: wow-data's databases (Forever's for a Forever-only page).
 */
import { execSync } from "node:child_process";
import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import type * as WowDb from "../../wow-data/src/db";
import type { Game } from "../../wow-data/src/pins";
import { frontMatter } from "./markdown";
import { familyPath } from "./root";

const { openDb } = (await import(familyPath("wow-data", "src", "db.ts"))) as typeof WowDb;
const ROOT = new URL("..", import.meta.url).pathname;
const CONTENT = join(ROOT, "content");
const dbs = { classic: openDb("classic"), forever: openDb("forever") } as const;
type Row = Record<string, string | number | null>;

const pages = new Map<string, string>(); // id -> chapter/id
for (const chapter of readdirSync(CONTENT, { withFileTypes: true })) {
  if (!chapter.isDirectory()) continue;
  for (const f of readdirSync(join(CONTENT, chapter.name))) if (f.endsWith(".md") && !f.startsWith("_")) pages.set(f.slice(0, -3), `${chapter.name}/${f.slice(0, -3)}`);
}

const args = process.argv.slice(2);
let wanted: string[];
if (args.includes("--all")) wanted = [...pages.values()];
else if (args.includes("--changed"))
  wanted = execSync("git diff --name-only origin/main -- content", { cwd: ROOT, encoding: "utf8" })
    .split("\n")
    .filter((f) => f.endsWith(".md") && !f.split("/").pop()!.startsWith("_"))
    .map((f) => f.replace(/^content\//, "").replace(/\.md$/, ""));
else wanted = args.map((a) => pages.get(a) ?? a.replace(/\.md$/, "").replace(/^content\//, ""));
if (!wanted.length) {
  console.error("usage: bun scripts/when.ts <page id or chapter/id>... | --changed | --all");
  process.exit(1);
}

const name = (game: Game, kind: string, id: number) =>
  ((dbs[game].query("SELECT name FROM name WHERE kind = ? AND id = ? AND locale = 'enUS'").get(kind, id) as Row | null)?.name as string) ?? `${kind} ${id}`;
const zoneOf = (game: Game, npc: number) => {
  const r = dbs[game].query("SELECT area_id FROM spawn WHERE kind = 'creature' AND entity_id = ? AND area_id IS NOT NULL LIMIT 1").get(npc) as Row | null;
  return r ? name(game, "area", Number(r.area_id)) : null;
};
// a quest's chain in order: from its root along next_in_chain, or the quest whose prev_id
// is the one before; the chain's other quests after them, by id
function chain(game: Game, quest: number): number[] {
  const db = dbs[game];
  const root = Number((db.query("SELECT chain_root FROM quest WHERE id = ?").get(quest) as Row | null)?.chain_root ?? quest);
  const all = (db.query("SELECT id, next_in_chain, prev_id FROM quest WHERE chain_root = ? ORDER BY id").all(root) as Row[]).map((r) => ({
    id: Number(r.id),
    next: Number(r.next_in_chain || 0),
    prev: Number(r.prev_id || 0),
  }));
  if (!all.length) return [quest];
  const order: number[] = [];
  let at: number | undefined = root;
  while (at && !order.includes(at)) {
    order.push(at);
    const here = all.find((q) => q.id === at);
    at = here?.next || all.find((q) => Math.abs(q.prev) === at && !order.includes(q.id))?.id;
  }
  for (const q of all) if (!order.includes(q.id)) order.push(q.id);
  return order;
}
const quests = (game: Game, ids: number[]) => ids.map((q) => `${q} ${name(game, "quest", q)}`).join(", ");
function npcQuests(game: Game, npc: number) {
  const rows = dbs[game].query("SELECT DISTINCT quest_id, role FROM quest_relation WHERE kind = 'creature' AND entity_id = ? ORDER BY quest_id").all(npc) as Row[];
  const gives = [...new Set(rows.filter((r) => r.role === "start").map((r) => Number(r.quest_id)))];
  const takes = [...new Set(rows.filter((r) => r.role === "end").map((r) => Number(r.quest_id)))].filter((q) => !gives.includes(q));
  return { gives, takes };
}

const SIGHT = 0,
  QUEST = 1,
  LATER = 2;
for (const rel of wanted) {
  let src: string;
  try {
    src = readFileSync(join(CONTENT, `${rel}.md`), "utf8");
  } catch {
    console.log(`${rel}: no such page\n`);
    continue;
  }
  const { meta } = frontMatter(src, () => {});
  const game: Game = meta.client === "forever" ? "forever" : "classic";
  const rules = ([] as string[]).concat(meta.unlock ?? []);
  console.log(`${meta.id} · ${meta.title} (${rel.split("/")[0]}, ${meta.kind}${meta.client ? `, ${meta.client} only` : ""})`);
  const moments: { when: number; step: number; what: string }[] = [];
  // (an npc or kill list spread over several lines is one list)
  const lists = new Map<string, { game: Game; tag: string; key: string; ids: number[] }>();
  for (const raw of rules) {
    const scoped = raw.match(/^\[(\w+)\]\s+(.*)$/);
    const g: Game = scoped?.[1] === "forever" ? "forever" : game;
    const rule = scoped ? scoped[2] : raw;
    const tag = scoped ? `[${scoped[1]}] ` : "";
    const [key, value = ""] = [rule.slice(0, rule.indexOf(":")), rule.slice(rule.indexOf(":") + 1).trim()];
    if (rule === "always") moments.push({ when: SIGHT, step: 0, what: "from the start" });
    else if (key === "area") {
      console.log(`  ${tag}area ${value}: on entering it`);
      moments.push({ when: SIGHT, step: 0, what: `entering ${value}` });
    } else if (key === "read") {
      console.log(`  ${tag}read "${value}": on reading it`);
      moments.push({ when: SIGHT, step: 0, what: `reading "${value}"` });
    } else if (key === "npc" || key === "kill") {
      const list = lists.get(tag + key) ?? { game: g, tag, key, ids: [] };
      list.ids.push(...value.split(",").map((v) => Number(v.trim())));
      lists.set(tag + key, list);
    } else if (key === "quest") {
      const q = Number(value);
      const order = chain(g, q);
      const at = order.indexOf(q);
      console.log(`  ${tag}quest ${q} ${name(g, "quest", q)}: on turning it in, step ${at + 1} of ${order.length} of its chain`);
      if (at < order.length - 1) console.log(`      after it: ${quests(g, order.slice(at + 1))}: does the page tell any of these?`);
      moments.push({ when: QUEST, step: at + 1, what: `turning in ${q} ${name(g, "quest", q)} (step ${at + 1} of ${order.length})` });
    } else if (key === "reputation") {
      const [faction, standing] = value.split(/\s+/);
      console.log(`  ${tag}reputation: at ${standing} with ${name(g, "faction", Number(faction))}`);
      moments.push({ when: LATER, step: 0, what: `${standing} with ${name(g, "faction", Number(faction))}` });
    } else if (key === "people" || key === "calling") {
      console.log(`  ${tag}${key} ${value}: on meeting a player of it, or being one`);
      moments.push({ when: SIGHT, step: 0, what: `meeting a ${value}` });
    } else if (key === "position") {
      console.log(`  ${tag}position ${value}: on standing there`);
      moments.push({ when: SIGHT, step: 0, what: "standing at a position" });
    } else console.log(`  ${tag}${rule}: ?`);
  }
  for (const { game: g, tag, key, ids } of lists.values()) {
    const verb = key === "npc" ? "targeting (or talking to)" : "killing";
    if (ids.length > 6) console.log(`  ${tag}${key}: on ${verb} any of ${ids.length} creatures (${ids.slice(0, 4).map((i) => name(g, "creature", i)).join(", ")}...)`);
    else
      for (const id of ids) {
        const { gives, takes } = npcQuests(g, id);
        const where = zoneOf(g, id);
        console.log(`  ${tag}${key} ${id} ${name(g, "creature", id)}${where ? ` (${where})` : ""}: on ${verb}, before any of its quests`);
        if (gives.length) console.log(`      it gives ${quests(g, gives)}: does the page tell their outcome?`);
        if (takes.length) console.log(`      it takes ${quests(g, takes)}`);
      }
    moments.push({ when: SIGHT, step: 0, what: `${verb} ${ids.length > 1 ? `one of ${ids.length} creatures` : name(g, "creature", ids[0])}` });
  }
  moments.sort((a, b) => a.when - b.when || a.step - b.step);
  if (moments.length) console.log(`  earliest: ${moments[0].what}`);
  const quest = moments.find((m) => m.when === QUEST);
  if (quest && moments[0].when === SIGHT) console.log(`  ! on sight before any quest: ${moments[0].what} comes before ${quest.what} (fine if the page tells nothing of the chain)`);
  console.log("");
}
