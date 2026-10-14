// The names as the game writes them (the same file in the Codex and Yonder):
// a name the glossary holds (i18n/<locale>/glossary.json, wow-data's
// databases' names, ../addon-kit/glossary.py) that an English text names is in
// that text's translation, as the language declines it (an ending, an article
// inside the name: "Araj dem Beschwörer", a title of the other gender:
// "Verzauberkunstfachmann"), accents aside. The exceptions, each with its
// reason, are i18n/<locale>/names-ok.json ({ English name: why }).
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

type Glossary = Record<string, Record<string, { use?: string } | string>>;

const esc = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const plain = (s: string) => s.normalize("NFD").replace(/\p{Mn}/gu, "").replace(/’/g, "'");
const body = (file: string) => readFileSync(file, "utf8").replace(/^---\n[^]*?\n---\n/, "");
const ARTICLE = /^(?:(?:der|die|das|le|la|les)\s+|l')/i;
const INNER = new Set(["der", "die", "das", "dem", "den", "des", "du", "de", "la", "le", "les"]);

function pattern(use: string): RegExp {
  const part = (w: string) =>
    INNER.has(w.toLowerCase())
      ? "(?:der|die|das|dem|den|des|du|de|la|le|les|d')"
      : /(frau|mann)$/.test(w)
        ? `${esc(w.slice(0, -4))}(?:frau|mann)\\p{L}*`
        : `${esc(w.length > 5 ? w.slice(0, -2) : w)}\\p{L}*`;
  const words = plain(use).replace(ARTICLE, "").split(/[\s,-]+/).filter(Boolean);
  return new RegExp(`(?<![\\p{L}\\d])${words.map(part).join("[\\s,-]+")}`, "iu");
}

/** The names a translation writes otherwise: "English -> the game's (files)". */
export function misnamed(i18n: string, locale: string, pairs: [english: string, translation: string][]): string[] {
  const file = join(i18n, locale, "glossary.json");
  if (!existsSync(file)) return [];
  const glossary: Glossary = JSON.parse(readFileSync(file, "utf8"));
  const okFile = join(i18n, locale, "names-ok.json");
  const ok: Record<string, string> = existsSync(okFile) ? JSON.parse(readFileSync(okFile, "utf8")) : {};
  const names = Object.values(glossary)
    .flatMap((kind) => Object.entries(kind))
    .flatMap(([en, e]) => (typeof e === "object" && e.use ? [[en, e.use] as const] : []))
    .sort((a, b) => b[0].length - a[0].length);
  const misses = new Map<string, string[]>();
  for (const [en, tr] of pairs) {
    if (!existsSync(en) || !existsSync(tr)) continue;
    const english = body(en);
    const translation = plain(body(tr));
    const seen: string[] = [];
    for (const [name, use] of names) {
      if (seen.some((s) => s.includes(name))) continue; // (a longer name holds it)
      if (!new RegExp(`(?<![\\p{L}'])${esc(name)}(?!\\p{L})`, "u").test(english)) continue;
      seen.push(name); // (an exception too: it holds its shorter names)
      if (!(name in ok) && !pattern(use).test(translation)) {
        const key = `${name} -> ${use}`;
        misses.set(key, [...(misses.get(key) ?? []), tr.slice(join(i18n, locale).length + 1)]);
      }
    }
  }
  return [...misses.entries()].sort().map(([k, files]) => `${k} (${files.join(", ")})`);
}
