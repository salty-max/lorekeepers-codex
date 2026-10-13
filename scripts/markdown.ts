/**
 * The Markdown of a page, English or translated: its front matter and its
 * paragraphs (with their client, side, aside and signature). Shared by
 * scripts/build.ts (content/) and scripts/locales.ts (i18n/).
 */
export type Para = { italic: boolean; text: string; client: string; side: string; aside: boolean; sign: string };
export const SIDES = ["alliance", "horde"];

export function frontMatter(src: string, fail: (msg: string) => void): { meta: Record<string, string | string[]>; body: string } {
  const m = src.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/);
  if (!m) {
    fail("no front matter");
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
      fail(`can't read "${raw}"`);
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

export function paragraphs(body: string) {
  return body
    .trim()
    .split(/\n\s*\n/)
    .map((p) => p.replace(/\s*\n\s*/g, " ").trim())
    .filter(Boolean)
    .map((p): Para => {
      // "[forever] ..." or "[classic] ...": a paragraph for one client only;
      // "[alliance] ..." or "[horde] ...": for one side's readers only.
      let client = "";
      let side = "";
      for (let m = p.match(/^\[(\w+)\]\s+/); m; m = p.match(/^\[(\w+)\]\s+/)) {
        if (SIDES.includes(m[1])) side = m[1];
        else client = m[1];
        p = p.slice(m[0].length);
      }
      // "> ... -- P. F.": an aside, and its signature.
      let aside = false;
      let sign = "";
      if (p.startsWith("> ")) {
        aside = true;
        p = p.slice(2).replace(/\s+>\s+/g, " ");
        const m = p.match(/\s+--\s+([^-]+)$/);
        if (m) {
          sign = m[1].trim();
          p = p.slice(0, m.index);
        }
      }
      const italic = !aside && /^\*[^*].*[^*]\*$/.test(p);
      return { italic, text: italic ? p.slice(1, -1) : p, client, side, aside, sign };
    });
}

