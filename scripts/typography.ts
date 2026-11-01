/**
 * French typography in the Codex's French (decision Q1, 31 October 2026, as
 * the client writes it): a no-break space (U+00A0) before : ? ! and a
 * percent sign, and inside « ». Over the authored French: the pages,
 * chapters.json and the values of words.json (terms.ts checks those too).
 * Not the Library's translations (books-supplement.json): every text the
 * Library shows goes through book_texts.py's plain(), plain spaces, the
 * game's own and ours alike. Idempotent.
 *
 *   bun scripts/typography.ts           fix them
 *   bun scripts/typography.ts --check   fail if one is left (the check runs it)
 */
import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join, relative } from "node:path";

const ROOT = new URL("..", import.meta.url).pathname;
const FR = join(ROOT, "i18n/frFR");
const NBSP = " ";

/** One string's French typography (a format blank's "%s" is no percent sign). */
export function typeset(s: string): string {
  return s
    .replace(/[ \t]+([:?!])(?![\p{L}\d])/gmu, `${NBSP}$1`)
    .replace(/([\p{L}\d)%])([:?!])(?=\s|$|\\n)/gmu, `$1${NBSP}$2`)
    .replace(/(\d)[ \t]*%(?![sdif%$\d])/g, `$1${NBSP}%`)
    .replace(/[ \t]+%%/g, `${NBSP}%%`)
    .replace(/«[ \t ]*/g, `«${NBSP}`)
    .replace(/[ \t ]*»/g, `${NBSP}»`);
}

const pages = (dir: string): string[] =>
  readdirSync(dir).flatMap((f) => {
    const p = join(dir, f);
    return statSync(p).isDirectory() ? pages(p) : f.endsWith(".md") ? [p] : [];
  });

/** Each file's new text: a page's title and body, a JSON file's string
 * values (never its keys, which are English: written back as it reads them). */
function fixed(file: string): string {
  const text = readFileSync(file, "utf8");
  if (!file.endsWith(".md")) {
    const walk = (v: unknown): unknown =>
      typeof v === "string"
        ? typeset(v)
        : Array.isArray(v)
          ? v.map(walk)
          : v && typeof v === "object"
            ? Object.fromEntries(Object.entries(v).map(([k, x]) => [k, walk(x)]))
            : v;
    return `${JSON.stringify(walk(JSON.parse(text)), null, 2)}\n`;
  }
  const [, head, body] = text.match(/^(---\n[^]*?\n---\n)([^]*)$/) ?? ["", "", text];
  return head.replace(/^(title:\s*)(.*)$/m, (_, k, v) => k + typeset(v)) + typeset(body);
}

const files = [...pages(join(FR, "pages")), ...["chapters.json", "words.json"].map((f) => join(FR, f))];
const check = process.argv.includes("--check");
const left = files.filter((f) => fixed(f) !== readFileSync(f, "utf8"));
if (check) {
  if (left.length) {
    console.error(`✗ French typography (a no-break space before : ? ! %, inside « »): run bun scripts/typography.ts\n  ${left.map((f) => relative(ROOT, f)).join("\n  ")}`);
    process.exit(1);
  }
} else {
  for (const f of left) writeFileSync(f, fixed(f));
  console.log(`✓ French typography: ${left.length} files fixed of ${files.length}`);
}
