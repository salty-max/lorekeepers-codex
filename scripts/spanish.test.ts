import { describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { frontMatter, paragraphs } from "./markdown";

const root = join(import.meta.dir, "..");
const json = (path: string) => JSON.parse(readFileSync(join(root, path), "utf8"));
const read = (path: string) => frontMatter(readFileSync(join(root, path), "utf8"), (why) => { throw new Error(`${path}: ${why}`); });
const pages = (dir: string) => (readdirSync(join(root, dir), { recursive: true }) as string[]).filter((file) => file.endsWith(".md") && !file.endsWith("_chapter.md")).sort();
const prose = (text: string) => text.replace(/\$g[^:;]*:[^;]*;/g, "");
const formats = (text: string) => text.match(/%[-+0-9.]*[sdf]/g) ?? [];

describe("complete Spanish translation", () => {
  test("every source page is current and preserves its paragraph roles", () => {
    const source = pages("content");
    expect(pages("i18n/esES/pages")).toEqual(source);
    for (const file of source) {
      const en = read(`content/${file}`);
      const es = read(`i18n/esES/pages/${file}`);
      expect(es.meta.id).toBe(en.meta.id);
      expect(es.meta.source).toBe(createHash("sha1").update(`${en.meta.title}\n${en.body.trim()}`).digest("hex").slice(0, 12));
      const original = paragraphs(en.body), translated = paragraphs(es.body);
      expect(translated.length).toBe(original.length);
      for (let i = 0; i < original.length; i++) {
        const { client, side, aside, italic, sign } = original[i];
        expect({ client: translated[i].client, side: translated[i].side, aside: translated[i].aside, italic: translated[i].italic, signed: !!translated[i].sign }).toEqual({ client, side, aside, italic, signed: !!sign });
        expect(prose(translated[i].text)).not.toMatch(/[;‘’“”]|\$g/);
        expect(translated[i].text.trim().length).toBeGreaterThan(0);
        expect(translated[i].text).not.toBe(original[i].text);
        expect(translated[i].text).not.toMatch(/\b(?:El El|La La|el Hermandad|del Hermandad|al Hermandad)\b/);
      }
    }
  });

  test("all interface strings retain their formatting arguments", () => {
    const source = json("i18n/words.json"), es = json("i18n/esES/words.json");
    expect(Object.keys(es).sort()).toEqual(Object.keys(source).sort());
    for (const [key, value] of Object.entries(es)) {
      expect(typeof value).toBe("string");
      expect((value as string).length).toBeGreaterThan(0);
      expect(formats(value as string)).toEqual(formats(key));
      expect(prose(value as string)).not.toMatch(/[;‘’“”]|\$g/);
    }
    const chapters = (readdirSync(join(root, "content"), { recursive: true }) as string[]).filter((path) => path.endsWith("/_chapter.md")).map((path) => path.split("/")[0]).sort();
    expect(Object.keys(json("i18n/esES/chapters.json")).sort()).toEqual(chapters);
  });

  test("both Spanish libraries cover every existing French and German readable identity", () => {
    const ids = (catalog: any) => new Set<string>(Object.values(catalog).flatMap((variants: any) => variants.flatMap((variant: any) => variant.ids)));
    const es = ids(json("i18n/esES/books.json")), mx = ids(json("i18n/esMX/books.json"));
    expect(mx).toEqual(es);
    for (const locale of ["frFR", "deDE"]) for (const id of ids(json(`i18n/${locale}/books.json`))) expect(es.has(id)).toBe(true);
    const index = json("i18n/books-index.json");
    for (const locale of ["esES", "esMX"]) {
      const catalog = json(`i18n/${locale}/books.json`), supplement = json(`i18n/${locale}/books-supplement.json`);
      for (const variants of Object.values(catalog) as any[]) for (const variant of variants) {
        for (const id of variant.ids) expect(index.canonical[id]).toBeDefined();
        for (const page of variant.pages) {
          expect(prose(page)).not.toMatch(/[;‘’“”]|\$g/);
          expect(page).not.toMatch(/^\[(?:The |In the |For |You |Dear |To )/);
          const english = page.match(/\b(?:the|and|of|to|you|your|this|with)\b/gi) ?? [];
          const spanish = page.match(/\b(?:el|la|de|que|con|los|las|en)\b/gi) ?? [];
          expect(english.length >= 7 && spanish.length < 3).toBe(false);
        }
      }
      // Authored supplements may not silently drop reader substitutions.
      for (const [id, entry] of Object.entries(supplement.entries) as [string, any][]) {
        if (entry.provenance !== "codex-translation") continue;
        const source = index.texts[index.canonical[id]].pages;
        if (!source.length) continue; // documented wrong source binding
        expect(entry.pages.length).toBe(source.length);
        const tokens = (text: string) => (text.match(/\$[NnCcRr]/g) ?? []).sort();
        for (let i = 0; i < source.length; i++) expect(tokens(entry.pages[i])).toEqual(tokens(source[i]));
      }
    }
  });
});
