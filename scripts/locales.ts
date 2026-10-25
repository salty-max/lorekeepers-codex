/**
 * i18n/<locale>/ → addon/LorekeepersCodex/Text_<locale>.lua, one for every
 * language the game has (the game's names in it, and its translation where
 * there is one): each client loads its own, through Text_[TextLocale].lua in
 * the TOCs, and English stays wherever a translation says nothing
 * (Locale.lua).
 *
 *   i18n/<locale>/meta.json       { "plural": "one" | "fr" | "ru" | "none",
 *                                    "flagged": true }  (a first translation,
 *                                    not reviewed by a native reader)
 *   i18n/<locale>/words.json      { "English": "translation" }: the interface's
 *                                  words, every L["..."] of the addon (its
 *                                  kit's included); i18n/words.json lists them
 *   i18n/<locale>/chapters.json   { "<chapter id>": ["title", "summary"] }
 *   i18n/<locale>/subzones.json   the places inside buildings by their ids,
 *                                 { forever, classic }, every language's,
 *                                 English one of them (enGB: enUS's), complete
 *                                 (../addon-kit/subzones.py <locale>); the
 *                                 one file of a language with no translation
 *   i18n/<locale>/books.json      the game's own texts by their English titles
 *                                 (scripts/book_texts.py)
 *   i18n/<locale>/texts.json      the Library's titles by their texts' ids,
 *                                 { forever, classic }, every language's,
 *                                 English one of them (scripts/text_titles.py)
 *   i18n/<locale>/pages/<chapter>/<id>.md
 *                                  a page: front matter id, title and source
 *                                  (the English page's hash, written by
 *                                  --stamp: when the English changes, the
 *                                  translation is stale), then its paragraphs,
 *                                  marked as the English ones ([forever],
 *                                  [horde] > ... -- P. F.)
 *
 * A language without its own words may borrow another's translation (esMX:
 * esES).
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
import { kitKeys, kitWords, ownKeys, problems } from "./locales-lib";
import { misnamed } from "./names";

const ROOT = new URL("..", import.meta.url).pathname;
const CONTENT = join(ROOT, "content");
const I18N = join(ROOT, "i18n");
const ADDON = join(ROOT, "addon/LorekeepersCodex");
const LOCALES = ["enUS", "enGB", "deDE", "frFR", "esES", "esMX", "ruRU", "ptBR", "itIT", "koKR", "zhCN", "zhTW"];
const ENGLISH = new Set(["enUS", "enGB"]);
const BORROWS: Record<string, string> = { esMX: "esES" };
// (the game's names: a language the client names nothing in its own, another's)
const NAMES_OF: Record<string, string> = { enGB: "enUS" };
// (a translation: its words)
const translated = (locale: string) => existsSync(join(I18N, locale, "words.json"));
const PLURALS = ["one", "fr", "ru", "none"];

// Shared prose can still name the people and places as this client does.
// Apply reviewed regional names once, longest first, without cascading a
// replacement into another. English keys and readable identities stay intact.
function regionalWords(locale: string): (text: string) => string {
  const file = join(I18N, locale, "regional.json");
  if (!existsSync(file)) return (text) => text;
  const names: Record<string, string> = JSON.parse(readFileSync(file, "utf8"));
  const replacements = new Map(Object.entries(names).map(([key, value]) => [key.toLowerCase(), value]));
  const esc = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const pattern = new RegExp(`(?<![\\p{L}\\d])(?:${Object.keys(names).sort((a, b) => b.length - a.length).map(esc).join("|")})(?![\\p{L}\\d])`, "giu");
  return (text) => text.replace(pattern, (found) => {
    const replacement = replacements.get(found.toLowerCase())!;
    if (found === found.toUpperCase()) return replacement.toUpperCase();
    return found[0] === found[0].toUpperCase()
      ? replacement[0].toUpperCase() + replacement.slice(1)
      : replacement[0].toLowerCase() + replacement.slice(1);
  });
}

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
// (the codex's own, through the family's core: scripts/locales-lib.ts; the
// kit's words are i18n/kit/'s, translated once for every addon; the
// Library's shelves' short names, read through L by their id, LibraryBook.lua)
const KIT_KEYS = kitKeys(ADDON);
function keys(): string[] {
  const kit = new Set(KIT_KEYS);
  return ownKeys(ADDON, /^(Content|Text)_/, ["books", "notes", "plaques"]).filter((k) => !kit.has(k));
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
  // the game's own texts in this language, by their English titles (a text
  // copied in English reads in this one): scripts/book_texts.py
  const books = json<Record<string, { ids: string[]; first: string; pages: string[] }[]>>("books.json", {});
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
  return { meta, words, chapters, pages, classic, books };
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

// The game's names in a language, every language's: the places inside
// buildings by their ids, each game's.
function namesLua(locale: string): string {
  const titlesFile = join(I18N, NAMES_OF[locale] ?? locale, "texts.json");
  if (!existsSync(titlesFile)) fail(titlesFile, `missing: python3 scripts/text_titles.py ${NAMES_OF[locale] ?? locale}`);
  const titles: { forever?: Record<string, string>; classic?: Record<string, string> } = existsSync(titlesFile)
    ? JSON.parse(readFileSync(titlesFile, "utf8"))
    : {};
  const byText = (names: Record<string, string> = {}) =>
    Object.entries(names)
      .map(([id, n]) => `    [${q(id)}] = ${q(n)},`)
      .join("\n");
  const file = join(I18N, NAMES_OF[locale] ?? locale, "subzones.json");
  if (!existsSync(file)) fail(file, `missing: python3 ../addon-kit/subzones.py ${NAMES_OF[locale] ?? locale}`);
  const t: { forever?: Record<string, string>; classic?: Record<string, string> } = existsSync(file)
    ? JSON.parse(readFileSync(file, "utf8"))
    : {};
  const list = (names: Record<string, string> = {}) =>
    Object.entries(names)
      .sort(([a], [b]) => Number(a) - Number(b))
      .map(([id, n]) => `    [${id}] = ${q(n)},`)
      .join("\n");
  return `-- the game's names in this language: the places inside buildings by their
-- ids (no area id to ask the client), each game's
ns.names({
  inside = {
${list(t.forever)}
  },
  insideClassic = {
${list(t.classic)}
  },
  -- the Library's titles by their texts' ids ("o<object>", "i<item>"), each game's
  titles = {
${byText(titles.forever)}
  },
  titlesClassic = {
${byText(titles.classic)}
  },
})
`;
}

function luaFor(locale: string): string {
  const from = translated(locale) ? locale : BORROWS[locale] && translated(BORROWS[locale]) ? BORROWS[locale] : null;
  if (ENGLISH.has(locale) || !from) {
    return `-- Generated by scripts/locales.ts: no translation for ${locale} (yet), the codex reads in English.
local _, ns = ...
${namesLua(locale)}`;
  }
  const t = read(from);
  if (from !== locale) {
    const words = regionalWords(locale);
    for (const key of Object.keys(t.words)) t.words[key] = words(t.words[key]);
    for (const key of Object.keys(t.chapters)) t.chapters[key] = t.chapters[key].map(words) as [string, string];
    for (const page of t.pages.values()) {
      page.title = words(page.title);
      for (const para of page.text) {
        para.text = words(para.text);
        para.sign = words(para.sign);
      }
    }
    // Regional books retain that client's actual wording. Its tracked
    // supplement fills only missing bodies from the shared Spanish catalog.
    const regional = read(locale);
    t.books = regional.books;
    t.classic = regional.classic;
  }
  const pages = [...t.pages.entries()].sort(([a], [b]) => a.localeCompare(b));
  return `-- Generated by scripts/locales.ts from i18n/${from}/: edit those, not this file.
local _, ns = ...
${namesLua(locale)}ns.translate({
  locale = ${q(locale)},
  plural = ${q(t.meta.plural ?? "one")},
  words = {
${Object.entries({
  ...Object.fromEntries(Object.entries(t.words).filter(([k]) => !KIT_KEYS.includes(k))),
  ...Object.fromEntries(KIT_KEYS.map((k) => [k, kitWords(I18N, from)[k]])),
})
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
  -- the game's own texts, by their English titles: each text's pages, and
  -- the start of its English first page (to tell apart those sharing a title)
  books = {
${Object.entries(t.books)
  .sort(([a], [b]) => a.localeCompare(b))
  .map(([title, vs]) => `    [${q(title)}] = { ${vs.map((v) => `{ ids = { ${v.ids.map(q).join(", ")} }, first = ${q(v.first)}, pages = { ${v.pages.map(q).join(", ")} } }`).join(", ")} },`)
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
// A small shared identity index, plus English bodies, lets an old French or
// German copy follow a later language change. Other clients still load only
// their own translated bodies. Same-title variants keep separate identities.
const index = JSON.parse(readFileSync(join(I18N, "books-index.json"), "utf8")) as {
  canonical: Record<string, string>;
  texts: Record<string, { title: string; pages: string[]; patterns: string[] }>;
  titles: Record<string, Record<string, boolean>>;
};
// A first page is known by its fingerprint (the Library's `sum`: djb2 over its
// letters, and their count) unless a name is inside it (the reader's $N, $C,
// $R: a pattern, matched whole). The English pages go to English clients only
// (Text_enUS, Text_enGB: ns.textBodies), the only ones that read them: every
// client carried them, 420 KB, for a player who changes the game's language.
const sum = (s: string) => {
  let h = 5381;
  for (let i = 0; i < s.length; i++) h = (h * 33 + s.charCodeAt(i)) % 4294967296;
  return `${h.toString(16).padStart(8, "0")}:${s.length}`;
};
const exact = (p: string) => !p.includes("[");
const indexLua = `-- Generated by scripts/locales.ts from i18n/books-index.json (scripts/book_index.py).
local _, ns = ...
ns.textSources = {
  canonical = {
${Object.entries(index.canonical).map(([key, id]) => `    [${q(key)}] = ${q(id)},`).join("\n")}
  },
  texts = {
${Object.entries(index.texts)
  .map(([id, text]) => {
    const sums = text.patterns.filter(exact).map(sum);
    const patterns = text.patterns.filter((p) => !exact(p));
    return `    [${q(id)}] = { title = ${q(text.title)}, sums = { ${sums.map(q).join(", ")} }, patterns = { ${patterns.map(q).join(", ")} } },`;
  })
  .join("\n")}
  },
  titles = {
${Object.entries(index.titles).map(([title, variants]) => `    [${q(title)}] = { ${Object.keys(variants).map((id) => `[${q(id)}] = true`).join(", ")} },`).join("\n")}
  },
}
`;
const indexOut = join(ADDON, "Text_Sources.lua");
if (check) {
  if (!existsSync(indexOut) || readFileSync(indexOut, "utf8") !== indexLua) {
    console.error(`✗ ${relative(ROOT, indexOut)} is out of date: run bun scripts/locales.ts`);
    outdated = true;
  }
} else writeFileSync(indexOut, indexLua);
const englishBodies = `-- The game's English pages of the texts the codex knows in other languages:
-- a copy made in French or German reads in English here (Text_Sources.lua).
ns.textBodies = {
${Object.entries(index.texts)
  .filter(([, text]) => text.pages.length)
  .map(([id, text]) => `  [${q(id)}] = { ${text.pages.map(q).join(", ")} },`)
  .join("\n")}
}
`;
const known = new Set(keys());
for (const locale of LOCALES) {
  const out = join(ADDON, `Text_${locale}.lua`);
  const lua = luaFor(locale) + (ENGLISH.has(locale) ? englishBodies : "");
  if (check) {
    const current = existsSync(out) ? readFileSync(out, "utf8") : "";
    if (current !== lua) {
      console.error(`✗ ${relative(ROOT, out)} is out of date: run bun scripts/locales.ts`);
      outdated = true;
    }
  } else writeFileSync(out, lua);
  if (translated(locale)) {
    const t = read(locale);
    const stale = [...t.pages.entries()].filter(([, p]) => p.stale).map(([id]) => id);
    const missingPages = [...english.keys()].filter((id) => !t.pages.has(id));
    // (the family's checks: every word translated, its blanks kept, no stray %, no semicolon; the kit's too)
    const { missing: missingWords, unused, errors: wordErrors } = problems(t.words, [...known]);
    const kitTr = kitWords(I18N, locale);
    const kitMissing = KIT_KEYS.filter((k) => !kitTr[k]);
    for (const e of [...wordErrors, ...problems(kitTr, KIT_KEYS).errors]) errors.push(`i18n/${locale}: ${e}`);
    if (missingWords.length) errors.push(`i18n/${locale}: no translation for ${missingWords.map((m) => JSON.stringify(m)).join(", ")}`);
    if (kitMissing.length) errors.push(`i18n/kit/${locale}.json lacks ${kitMissing.map((m) => JSON.stringify(m)).join(", ")} (addon-kit/i18n, then kit:sync)`);
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
