/**
 * 全部の題の図を SVG に書き出す。書き出し先は `out/` (コミットしない)。
 *
 *   out/<冊>/<NN-章>/<フェンス>/<NN-題>.svg   (1 つのファイルに同じフェンスが 2 枚以上なら -2, -3 …)
 *
 * **フェンスごとに分ける。** 道具はどれも `<ファイル名>.svg` の名前で書くので、
 * 回路図と実体配線図を 1 つのディレクトリに書くと上書きし合う。
 *
 *   node scripts/render.mjs [冊のディレクトリ …]   省けば 3 冊とも
 */

import { spawnSync } from 'node:child_process';
import { join } from 'node:path';
import { ROOT, readEntries } from './collect.mjs';
import { cliPath, fencesIn } from './fences.mjs';

function main(args) {
  const books = new Set(args);
  const reads = readEntries().filter((read) => books.size === 0 || books.has(read.path.split('/')[0]));

  /** 書き出し先ごとの題。`out/<冊>/<章>/<フェンス>` → パスの並び。 */
  const groups = new Map();
  for (const read of reads) {
    const [book, chapter] = read.path.split('/');
    for (const fence of fencesIn(read.text).found) {
      const out = join('out', book, chapter, fence);
      groups.set(out, [...(groups.get(out) ?? []), { fence, path: read.path }]);
    }
  }

  let failed = 0;
  for (const [out, items] of groups) {
    const { fence } = items[0];
    const run = spawnSync(
      process.execPath,
      [cliPath(ROOT, fence), 'render', ...items.map((item) => item.path), '--out', out],
      { cwd: ROOT, encoding: 'utf8' },
    );
    if (run.status !== 0) {
      failed += 1;
      console.error(`--- ${out}\n${run.stderr.trimEnd()}`);
    }
  }

  const pairs = [...groups.values()].reduce((sum, items) => sum + items.length, 0);
  console.log(`${reads.length} 題 (題 × フェンスで ${pairs} 組) の図を ${groups.size} か所に書き出した (out/)`);
  if (failed > 0) process.exit(1);
}

main(process.argv.slice(2));
