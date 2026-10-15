#!/usr/bin/env node
/**
 * 題の本文から Pico 2 のプログラムを取り出す (docs/133 の標準テスト)。
 * 本文のコードブロックが唯一の原本で、写しは out/pico/ にだけ作る (コミットしない)。
 *
 * - ```c / ```cpp で `int main(` と `pico/` `hardware/` の include を含むブロック → <題>-<n>.c (.cpp)
 * - ```python で `machine` を使うブロック → <題>-<n>.py
 * - 直前の行が `<!-- program: skip -->` のブロックは取り出さない (断片・別の機種向け)
 *
 * 使い方: node scripts/pico-extract.mjs [out-dir]   (既定 out/pico)
 */
import { readFileSync, writeFileSync, mkdirSync, readdirSync, rmSync } from 'node:fs';
import { join, dirname, basename } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const BOOKS = /^\d\d-/;

function* mdFiles(dir) {
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    if (e.name === 'node_modules' || e.name === 'out' || e.name.startsWith('.')) continue;
    const p = join(dir, e.name);
    if (e.isDirectory()) yield* mdFiles(p);
    else if (e.name.endsWith('.md') && /^\d\d-/.test(e.name)) yield p;
  }
}

/** Markdown から [{lang, body, skip}] を順に返す。 */
export function blocks(text) {
  const out = [];
  const lines = text.split('\n');
  for (let i = 0; i < lines.length; i += 1) {
    const m = /^ {0,3}(`{3,})(\w*)\s*$/.exec(lines[i]);
    if (!m) continue;
    const fence = m[1];
    const body = [];
    let j = i + 1;
    while (j < lines.length && !new RegExp(`^ {0,3}\`{${fence.length},}\\s*$`).test(lines[j])) body.push(lines[j++]);
    out.push({ lang: m[2], body: body.join('\n') + '\n', skip: /<!--\s*program:\s*skip\s*-->/.test(lines[i - 1] ?? '') });
    i = j;
  }
  return out;
}

export function extractPrograms(text) {
  const found = [];
  let c = 0;
  let py = 0;
  for (const b of blocks(text)) {
    if (b.skip) continue;
    if ((b.lang === 'c' || b.lang === 'cpp') && /\bint\s+main\s*\(/.test(b.body) && /#include\s+"(pico|hardware)\//.test(b.body)) {
      c += 1;
      found.push({ ext: b.lang === 'cpp' ? 'cpp' : 'c', n: c, body: b.body });
    } else if (b.lang === 'python' && /\bmachine\b|\brp2\b/.test(b.body)) {
      py += 1;
      found.push({ ext: 'py', n: py, body: b.body });
    }
  }
  return found;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const outDir = process.argv[2] ?? join(ROOT, 'out', 'pico');
  rmSync(outDir, { recursive: true, force: true });
  let total = 0;
  for (const dir of readdirSync(ROOT).filter((d) => BOOKS.test(d))) {
    for (const file of mdFiles(join(ROOT, dir))) {
      const stem = basename(file, '.md');
      const chapter = basename(dirname(file));
      for (const p of extractPrograms(readFileSync(file, 'utf8'))) {
        const d = join(outDir, dir, chapter);
        mkdirSync(d, { recursive: true });
        writeFileSync(join(d, `${stem}-${p.n}.${p.ext}`), p.body);
        total += 1;
      }
    }
  }
  console.log(`取り出したプログラム: ${total} 本 → ${outDir}`);
}
