import { expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const ROOT = join(import.meta.dir, "..");
const check = (index: string) =>
  Bun.spawnSync(["python3", join(ROOT, "scripts", "book_index.py"), "--check", "--index", index], { stderr: "pipe", stdout: "pipe" });

test("the saved books index is what book_index.py writes now", () => {
  const run = check(join(ROOT, "i18n", "books-index.json"));
  expect(run.stderr.toString().split("\n").filter((l) => l.startsWith("  "))).toEqual([]);
  expect(run.exitCode).toBe(0);
});

test("a stale books index fails and names the book", () => {
  const index = JSON.parse(readFileSync(join(ROOT, "i18n", "books-index.json"), "utf8"));
  const [id, text] = Object.entries<{ title: string; patterns: string[] }>(index.texts)[0];
  text.patterns.pop();
  const dir = mkdtempSync(join(tmpdir(), "book-index-"));
  const stale = join(dir, "books-index.json");
  writeFileSync(stale, JSON.stringify(index, null, 1) + "\n");
  const run = check(stale);
  rmSync(dir, { recursive: true });
  expect(run.exitCode).toBe(1);
  expect(run.stderr.toString()).toContain(`${id} (${text.title})`);
});
