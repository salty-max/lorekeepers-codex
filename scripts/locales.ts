/**
 * i18n/<locale>/ → addon/LorekeepersCodex/Text_<locale>.lua, one for every
 * language the game has (a stub where there is no translation yet, so the
 * TOC never names a missing file): each client loads its own, through
 * Text_[TextLocale].lua in the TOCs, and English stays wherever a
 * translation says nothing (Locale.lua).
 *
 *   i18n/<locale>/meta.json       { "plural": "one" | "fr" | "ru" | "none",
 *                                    "flagged": true }  (a first translation,
 *                                    not reviewed by a native reader)
 *   i18n/<locale>/words.json      { "English": "translation" }: the interface's
 *                                  words, every L["..."] of the addon (its
 *                                  kit's included); i18n/words.json lists them
 *   i18n/<locale>/chapters.json   { "<chapter id>": ["title", "summary"] }
 *   i18n/<locale>/subzones.json   the places inside buildings, by their English
 *                                 names (../addon-kit/subzones.py)
 *   i18n/<locale>/books.json      the game's own texts by their English titles
 *                                 (scripts/book_texts.py)
 *   i18n/<locale>/texts.json      the Library's titles by their English ones,
 *                                 { forever, classic } (scripts/text_titles.py)
 *   i18n/<locale>/pages/<chapter>/<id>.md
 *                                  a page: front matter id, title and source
 *                                  (the English page's hash, written by
 *                                  --stamp: when the English changes, the
 *                                  translation is stale), then its paragraphs,
 *                                  marked as the English ones ([forever],
 *                                  [horde] > ... -- P. F.)
 *
 * A language not given its own folder may borrow another's (esMX: esES).
 *
 *   bun scripts/locales.ts             write the Text files
 *   (i18n/<locale>/names-ok.json: the names a translation writes otherwise
 *   than the game, and why: scripts/names.ts)
 *
 *   bun scripts/locales.ts --check     fail if one isn't up to date; say what
 *                                      is stale or missing (never a failure)
 *   bun scripts/locales.ts --keys      write i18n/words.json, every word to translate
 *   bun scripts/locales.ts --stamp frFR <chapter>/<id> ...
 *                                      record the English pages' hashes in
 *                                      those translations (once translated)
 */
import { createHash } from "node:crypto";
import { existsSync, readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join, relative } from "node:path";
import { frontMatter, paragraphs, type Para } from "./markdown";
import { misnamed } from "./names";

const ROOT = new URL("..", import.meta.url).pathname;
const CONTENT = join(ROOT, "content");
const I18N = join(ROOT, "i18n");
const ADDON = join(ROOT, "addon/LorekeepersCodex");
const LOCALES = ["enUS", "enGB", "deDE", "frFR", "esES", "esMX", "ruRU", "ptBR", "itIT", "koKR", "zhCN", "zhTW"];
const ENGLISH = new Set(["enUS", "enGB"]);
const BORROWS: Record<string, string> = { esMX: "esES" };
const PLURALS = ["one", "fr", "ru", "none"];

const errors: string[] = [];
const fail = (file: string, msg: string) => errors.push(`${relative(ROOT, file)}: ${msg}`);
const walk = (dir: string): string[] =>
  existsSync(dir)
    ? readdirSync(dir).flatMap((f) => (statSync(join(dir, f)).isDirectory() ? walk(join(dir, f)) : f.endsWith(".md") ? [join(dir, f)] : []))
    : [];

// ── English: each page's hash, each chapter ─────────────────────────────────
const hashOf = (title: string, body: string) => createHash("sha1").update(`${title}\n${body.trim()}`).digest("hex").slice(0, 12);
const english = new Map<string, { hash: string; chapter: string }>();
const chapterIds = new Set<string>();
for (const file of walk(CONTENT)) {
  const rel = relative(CONTENT, file);
  const chapter = rel.includes("/") ? rel.split("/")[0] : "";
  const { meta, body } = frontMatter(readFileSync(file, "utf8"), (m) => fail(file, m));
  if (rel.endsWith("_chapter.md")) {
    chapterIds.add(chapter);
    continue;
  }
  english.set(String(meta.id), { hash: hashOf(String(meta.title), body), chapter });
}

// ── the interface's words: every L["..."] and plural("one", "many") ─────────
function keys(): string[] {
  const found = new Set<string>();
  for (const f of readdirSync(ADDON)) {
    if (!f.endsWith(".lua") || /^(Content|Text)_/.test(f)) continue;
    const src = readFileSync(join(ADDON, f), "utf8");
    for (const m of src.matchAll(/\bL\["((?:[^"\\]|\\.)*)"\]/g)) found.add(m[1].replace(/\\"/g, '"').replace(/\\n/g, "\n"));
    for (const m of src.matchAll(/plural\([^,]+,\s*"((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)"\)/g)) {
      found.add(m[1]);
      found.add(m[2]);
    }
  }
  // the kit's month names, read through L by K.day; the Library's shelves'
  // short names, read through L by their id (LibraryBook.lua)
  for (const m of ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]) found.add(m);
  for (const shelf of ["books", "notes", "plaques"]) found.add(shelf);
  return [...found].sort();
}

// ── a language's folder ──────────────────────────────────────────────────────
// (straight quotes: the game's fonts lack the curly ones)
const CURLY = /[‘’“”]/;
type Page = { title: string; text: Para[]; stale: boolean };
function read(locale: string) {
  const dir = join(I18N, locale);
  const json = <T>(f: string, empty: T): T => (existsSync(join(dir, f)) ? JSON.parse(readFileSync(join(dir, f), "utf8")) : empty);
  const meta = json<{ plural?: string; flagged?: boolean }>("meta.json", {});
  if (meta.plural && !PLURALS.includes(meta.plural)) fail(join(dir, "meta.json"), `plural: one of ${PLURALS.join(", ")}`);
  const words = json<Record<string, string>>("words.json", {});
  const chapters = json<Record<string, [string, string]>>("chapters.json", {});
  // Forever's names Classic writes otherwise (scripts/glossary.py)
  const classic = json<Record<string, string>>("classic.json", {});
  // the Library's titles in this language, by their English ones, each game's
  // (scripts/text_titles.py; Classic's only where they differ)
  const titles = json<{ forever?: Record<string, string>; classic?: Record<string, string> }>("texts.json", {});
  // the places inside buildings, which have no area id (../addon-kit/subzones.py)
  const subzones = json<{ forever?: Record<string, string>; classic?: Record<string, string> }>("subzones.json", {});
  // the game's own texts in this language, by their English titles (a text
  // copied in English reads in this one): scripts/book_texts.py
  const books = json<Record<string, { first: string; pages: string[] }[]>>("books.json", {});
  // Supplements are tracked sources, not disposable browser cache. A rebuild
  // must retain each translated chain and its page boundaries.
  const supplement = json<{ entries?: Record<string, { title: string; pages: string[] }> }>("books-supplement.json", {});
  for (const [id, entry] of Object.entries(supplement.entries ?? {})) {
    if (!books[entry.title]?.some((v) => JSON.stringify(v.pages) === JSON.stringify(entry.pages))) {
      fail(join(dir, "books.json"), `${id} ${entry.title}: supplement missing or stale, run scripts/book_texts.py ${locale}`);
    }
  }
  for (const [title, variants] of Object.entries(books)) {
    for (const variant of variants) {
      for (const page of variant.pages) {
        if (CURLY.test(page)) fail(join(dir, "books.json"), `${title}: use straight quotes`);
        if (page.replace(/\$g[^;]+;/g, "").includes(";")) fail(join(dir, "books.json"), `${title}: semicolon in prose`);
        if (locale === "frFR" && /^\[[\s\S]*\]$/.test(page.trim()) && (page.match(/\b(?:the|and|of|to)\b/gi)?.length ?? 0) >= 4) {
          fail(join(dir, "books.json"), `${title}: bracketed English fallback in French text`);
        }
      }
    }
  }
  for (const id of Object.keys(chapters)) if (!chapterIds.has(id)) fail(join(dir, "chapters.json"), `no chapter "${id}"`);
  const pages = new Map<string, Page>();
  for (const file of walk(join(dir, "pages"))) {
    const src = readFileSync(file, "utf8");
    const odd = src.match(CURLY);
    if (odd) fail(file, `curly quote "${odd[0]}": use straight quotes`);
    const { meta: m, body } = frontMatter(src, (msg) => fail(file, msg));
    const id = String(m.id);
    const en = english.get(id);
    if (!en) {
      fail(file, `no English page "${id}"`);
      continue;
    }
    pages.set(id, { title: String(m.title), text: paragraphs(body), stale: m.source !== en.hash });
  }
  return { meta, words, chapters, pages, classic, titles, subzones, books };
}

// The names are Forever's (docs/localization.md): the English names the
// glossary translates ("Ironforge": "Forgefer"), and the capitalized words of
// them it leaves out ("Anvilmar" from "Modimus Anvilmar"), left in the
// translation; never one some name keeps, whatever its case ("Bronzebeard",
// "Centaure galak").
function untranslated(locale: string, t: ReturnType<typeof read>): string[] {
  const file = join(I18N, locale, "glossary.json");
  if (!existsSync(file)) return [];
  const glossary: Record<string, Record<string, { use?: string }>> = JSON.parse(readFileSync(file, "utf8"));
  const names = new Set<string>();
  const kept = Object.values(glossary)
    .flatMap((kind) => Object.values(kind).map((e) => e.use ?? ""))
    .join("\n");
  const esc = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  // (a whole word, French elisions included: "d'Elwynn")
  const word = (n: string, flags = "u") => new RegExp(`(?<!\\p{L})${esc(n)}(?!\\p{L})`, flags);
  for (const kind of Object.values(glossary))
    for (const [en, e] of Object.entries(kind)) {
      if (!e.use) continue;
      for (const n of [en, ...en.split(/[\s-]+/).filter((w) => /^[A-Z][a-z']{4,}$/.test(w))])
        if (!word(n, "iu").test(kept)) names.add(n);
    }
  const prose = [
    ...Object.values(t.words),
    ...Object.values(t.chapters).flat(),
    ...[...t.pages.values()].flatMap((p) => [p.title, ...p.text.map((x) => x.text)]),
  ]
    .join("\n")
    .replaceAll("Lorekeeper's Codex", ""); // (the addon's own name)
  return [...names].filter((n) => word(n).test(prose)).sort();
}

// ── Lua ─────────────────────────────────────────────────────────────────────
const q = (s: string) => `"${s.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n")}"`;
const paraLua = (p: Para) =>
  `{ ${p.italic ? "italic = true, " : ""}${p.client ? `client = ${q(p.client)}, ` : ""}${p.side ? `side = ${q(p.side === "horde" ? "Horde" : "Alliance")}, ` : ""}${p.aside ? "aside = true, " : ""}${p.sign ? `sign = ${q(p.sign)}, ` : ""}${q(p.text)} }`;

function luaFor(locale: string): string {
  const from = existsSync(join(I18N, locale)) ? locale : BORROWS[locale];
  if (ENGLISH.has(locale) || !from || !existsSync(join(I18N, from))) {
    return `-- Generated by scripts/locales.ts: no translation for ${locale} (yet), the codex reads in English.\n`;
  }
  const t = read(from);
  const pages = [...t.pages.entries()].sort(([a], [b]) => a.localeCompare(b));
  return `-- Generated by scripts/locales.ts from i18n/${from}/: edit those, not this file.
local _, ns = ...
ns.translate({
  locale = ${q(locale)},
  plural = ${q(t.meta.plural ?? "one")},
  words = {
${Object.entries(t.words)
  .filter(([, v]) => v)
  .sort(([a], [b]) => a.localeCompare(b))
  .map(([k, v]) => `    [${q(k)}] = ${q(v)},`)
  .join("\n")}
  },
  chapters = {
${Object.entries(t.chapters)
  .sort(([a], [b]) => a.localeCompare(b))
  .map(([id, [title, summary]]) => `    [${q(id)}] = { ${q(title)}, ${q(summary)} },`)
  .join("\n")}
  },
  -- the Library's titles by their English ones (a text copied in English
  -- reads by this language's title); Classic's own where they differ
  titles = {
${Object.entries(t.titles.forever ?? {})
  .sort(([a], [b]) => a.localeCompare(b))
  .map(([en, tr]) => `    [${q(en)}] = ${q(tr)},`)
  .join("\n")}
  },
  -- the places inside buildings, by their English names (no area id to ask
  -- the client); Classic's own where they differ
  subzones = {
${Object.entries(t.subzones.forever ?? {})
  .sort(([a], [b]) => a.localeCompare(b))
  .map(([en, tr]) => `    [${q(en)}] = ${q(tr)},`)
  .join("\n")}
  },
  subzonesClassic = {
${Object.entries(t.subzones.classic ?? {})
  .sort(([a], [b]) => a.localeCompare(b))
  .map(([en, tr]) => `    [${q(en)}] = ${q(tr)},`)
  .join("\n")}
  },
  -- the game's own texts, by their English titles: each text's pages, and
  -- the start of its English first page (to tell apart those sharing a title)
  books = {
${Object.entries(t.books)
  .sort(([a], [b]) => a.localeCompare(b))
  .map(([title, vs]) => `    [${q(title)}] = { ${vs.map((v) => `{ first = ${q(v.first)}, pages = { ${v.pages.map(q).join(", ")} } }`).join(", ")} },`)
  .join("\n")}
  },
  titlesClassic = {
${Object.entries(t.titles.classic ?? {})
  .sort(([a], [b]) => a.localeCompare(b))
  .map(([en, tr]) => `    [${q(en)}] = ${q(tr)},`)
  .join("\n")}
  },
  -- on Classic, its own names for the places Forever renamed (the longest first)
  classic = {
${Object.entries(t.classic)
  .sort(([a], [b]) => b.length - a.length || a.localeCompare(b))
  .map(([fv, cl]) => `    { ${q(fv)}, ${q(cl)} },`)
  .join("\n")}
  },
  pages = {
${pages
  .map(
    ([id, p]) => `    [${q(id)}] = {
      title = ${q(p.title)},
      text = {
${p.text.map((para) => `        ${paraLua(para)},`).join("\n")}
      },
    },`,
  )
  .join("\n")}
  },
})
`;
}

// ── commands ─────────────────────────────────────────────────────────────────
const args = process.argv.slice(2);
if (args[0] === "--keys") {
  const all = keys();
  writeFileSync(join(I18N, "words.json"), `${JSON.stringify(Object.fromEntries(all.map((k) => [k, ""])), null, 2)}\n`);
  console.log(`✓ i18n/words.json: ${all.length} words to translate`);
  process.exit(0);
}
if (args[0] === "--stamp") {
  const [, locale, ...ids] = args;
  for (const rel of ids) {
    const file = join(I18N, locale, "pages", `${rel.replace(/\.md$/, "")}.md`);
    const src = readFileSync(file, "utf8");
    const id = src.match(/^id:\s*(.+)$/m)?.[1].trim() ?? "";
    const en = english.get(id);
    if (!en) {
      console.error(`✗ ${rel}: no English page "${id}"`);
      continue;
    }
    const stamped = /^source:/m.test(src) ? src.replace(/^source:.*$/m, `source: ${en.hash}`) : src.replace(/^(id:.*)$/m, `$1\nsource: ${en.hash}`);
    writeFileSync(file, stamped);
    console.log(`✓ ${rel}: source ${en.hash}`);
  }
  process.exit(0);
}

const check = args.includes("--check");
let outdated = false;
const known = new Set(keys());
for (const locale of LOCALES) {
  const out = join(ADDON, `Text_${locale}.lua`);
  const lua = luaFor(locale);
  if (check) {
    const current = existsSync(out) ? readFileSync(out, "utf8") : "";
    if (current !== lua) {
      console.error(`✗ ${relative(ROOT, out)} is out of date: run bun scripts/locales.ts`);
      outdated = true;
    }
  } else writeFileSync(out, lua);
  if (existsSync(join(I18N, locale))) {
    const t = read(locale);
    const stale = [...t.pages.entries()].filter(([, p]) => p.stale).map(([id]) => id);
    const missingPages = [...english.keys()].filter((id) => !t.pages.has(id));
    const missingWords = [...known].filter((k) => !t.words[k]);
    const unused = Object.keys(t.words).filter((k) => !known.has(k));
    console.log(
      `${locale}: ${t.pages.size}/${english.size} pages (${stale.length} stale), ${known.size - missingWords.length}/${known.size} words, ${Object.keys(t.chapters).length}/${chapterIds.size} chapters${t.meta.flagged ? ", flagged" : ""}`,
    );
    if (stale.length) console.log(`  stale (the English changed): ${stale.join(", ")}`);
    if (unused.length) console.log(`  words no longer used: ${unused.join(" | ")}`);
    if (missingPages.length && missingPages.length < 20) console.log(`  pages still in English: ${missingPages.join(", ")}`);
    const left = untranslated(locale, t);
    if (left.length) console.log(`  English names left (the glossary's: python3 scripts/glossary.py ${locale}): ${left.join(" | ")}`);
    // (every page and foreword with its translation)
    const pairs = (readdirSync(CONTENT, { recursive: true }) as string[])
      .filter((f) => f.endsWith(".md") && !f.endsWith("_chapter.md"))
      .map((f) => [join(CONTENT, f), join(I18N, locale, "pages", f)] as [string, string]);
    for (const m of misnamed(I18N, locale, pairs))
      errors.push(`i18n/${locale}: a name not as the game writes it (or i18n/${locale}/names-ok.json says why): ${m}`);
    // (a chapter named after a place is titled as the game names it)
    const glossaryFile = join(I18N, locale, "glossary.json");
    const okFile = join(I18N, locale, "names-ok.json");
    if (existsSync(glossaryFile)) {
      const places: Record<string, { use?: string }> = JSON.parse(readFileSync(glossaryFile, "utf8")).places ?? {};
      const ok: Record<string, string> = existsSync(okFile) ? JSON.parse(readFileSync(okFile, "utf8")) : {};
      const plain = (s: string) => s.normalize("NFD").replace(/\p{Mn}/gu, "").replace(/\u2019/g, "'").toLowerCase();
      for (const [id, [title]] of Object.entries(t.chapters)) {
        const chapterFile = join(CONTENT, id, "_chapter.md");
        const en = frontMatter(readFileSync(chapterFile, "utf8"), (msg) => fail(chapterFile, msg)).meta.title as string;
        const use = places[en]?.use;
        if (use && !(en in ok) && plain(title) !== plain(use))
          errors.push(`i18n/${locale}/chapters.json: ${id}: "${title}", the game's "${use}" (or names-ok.json says why)`);
      }
    }
  }
}
if (errors.length) {
  for (const e of errors) console.error(`✗ ${e}`);
  process.exit(1);
}
if (outdated) process.exit(1);
if (!check) console.log(`✓ Text_<locale>.lua for ${LOCALES.length} languages`);
