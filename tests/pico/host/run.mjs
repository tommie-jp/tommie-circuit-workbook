#!/usr/bin/env node
/**
 * 層 A: 本文のプログラム (out/pico) を SDK のモックに link して走らせ、cases/*.c の期待値と突き合わせる。
 * cases/<題>.c の 1 行目に `// program: <out/pico からの相対パス>` を書く。
 * 使い方: node tests/pico/host/run.mjs [名前の部分一致 ...]
 */
import { readdirSync, readFileSync, existsSync, mkdirSync } from 'node:fs';
import { join, dirname, basename } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = join(HERE, '..', '..', '..');
const OUT = join(ROOT, 'out', 'pico');
const BUILD = join(ROOT, 'out', 'pico-host');
const RUN_TIMEOUT_MS = 60_000;
mkdirSync(BUILD, { recursive: true });

const filters = process.argv.slice(2);
const cases = readdirSync(join(HERE, 'cases')).filter((f) => f.endsWith('.c') && (!filters.length || filters.some((x) => f.includes(x)))).sort();
let failed = 0;
for (const c of cases) {
  const src = readFileSync(join(HERE, 'cases', c), 'utf8');
  const prog = /^\/\/ program: (\S+)/m.exec(src)?.[1];
  if (!prog || !existsSync(join(OUT, prog))) { console.log(`NG  ${c}: プログラムが無い (${prog})`); failed++; continue; }
  const exe = join(BUILD, basename(c, '.c'));
  const common = ['-std=gnu11', '-O0', '-g', '-Wall', '-Wextra', '-Wno-unused-parameter', '-Wno-unused-function', `-I${join(HERE, 'mock')}`];
  // 本文の main だけ program_main に改名する (case 側の main は本物のまま)
  const objP = `${exe}-prog.o`;
  let cc = spawnSync('gcc', [...common, '-Dmain=program_main', '-c', '-o', objP, join(OUT, prog)], { encoding: 'utf8' });
  if (cc.status === 0) cc = spawnSync('gcc', [...common, '-o', exe, objP, join(HERE, 'cases', c), join(HERE, 'mock', 'mock.c'), '-lm'], { encoding: 'utf8' });
  if (cc.status !== 0) { console.log(`NG  ${c}: コンパイルできない\n${cc.stderr}`); failed++; continue; }
  // 09-24 は手元で約 8 s かかる。CI の機械は遅いので余裕を取る
  const r = spawnSync(exe, [], { encoding: 'utf8', timeout: RUN_TIMEOUT_MS });
  if (r.status !== 0) { console.log(`NG  ${c}${r.error ? ` (${r.error.code})` : ''}\n${r.stderr}${r.stdout}`); failed++; } else console.log(`ok  ${c}`);
}
console.log(failed ? `\n${failed} 件 NG` : `\n全 ${cases.length} 件 ok`);
process.exit(failed ? 1 : 0);
