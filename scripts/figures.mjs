/**
 * GitHub で図を見せるための画像の行。
 *
 * GitHub はフェンスを図にしないので、図になるフェンスの閉じの直後に、GitHub Pages に
 * 置いた SVG への画像の行を 1 行ずつ置く。**この行は `npm run figures` が書く。手で直さない。**
 * 図そのものは `.github/workflows/pages.yml` が main の push ごとに描いて Pages に載せる
 * (置き方は `out/` と同じ `<NN-冊>/<NN-章>/<フェンス>/<NN-題>.svg`)。
 *
 * **図をコミットしない理由:** circuit はフォントを埋め込むと 1 枚 120〜200 KB、全部で 45 MB ほどあり、
 * フェンスの版を上げるたびに全部の図が変わる (右下の刻印)。コミットするとリポジトリが版上げごとに太る。
 *
 *   node scripts/figures.mjs                 画像の行を書き直す
 *   node scripts/figures.mjs --check         古い題を言って 1 で終わる (check.mjs と同じ)
 *   node scripts/figures.mjs --verify <dir>  書き出した図 (<dir>) に、画像の行の指す SVG が全部あるか
 */

import { existsSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, readEntries } from './collect.mjs';
import { fencesIn } from './fences.mjs';

export const PAGES_URL = 'https://tommie-jp.github.io/tommie-circuit-workbook';

const LABELS = {
  circuit: '回路図',
  breadboard: 'ブレッドボードの実体配線図',
  perfboard: 'ユニバーサル基板の実体配線図',
  vna: 'NanoVNA の画面',
  scope: 'オシロスコープの画面',
};

/** このスクリプトが書いた画像の行。Pages の URL を指す画像だけの行。 */
const FIGURE_LINE = new RegExp(`^ {0,3}!\\[[^\\]]*\\]\\(${PAGES_URL.replace(/[.]/g, '\\.')}/[^)\\s]+\\)$`);

/**
 * 題の各フェンスの図の置き場 (`<冊>/<章>/<フェンス>/<名前>.svg`)。道具の名付けに合わせる —
 * 1 つのファイルに同じフェンスが 1 枚ならファイル名のまま、2 枚以上なら `-1` `-2` … を付ける。
 */
export function figurePaths(path, blocks) {
  const [book, chapter, file] = path.split('/');
  const base = file.replace(/\.md$/, '');
  const totals = new Map();
  for (const { fence } of blocks) totals.set(fence, (totals.get(fence) ?? 0) + 1);
  const seen = new Map();
  return blocks.map(({ fence }) => {
    const nth = (seen.get(fence) ?? 0) + 1;
    seen.set(fence, nth);
    const name = totals.get(fence) === 1 ? base : `${base}-${nth}`;
    return `${book}/${chapter}/${fence}/${name}.svg`;
  });
}

/** 前に書いた画像の行を (前の空行ごと) 除く。 */
function withoutFigures(lines) {
  return lines.filter((line, index) => {
    if (FIGURE_LINE.test(line)) return false;
    return !(line === '' && FIGURE_LINE.test(lines[index + 1] ?? ''));
  });
}

/** 画像の行を書き直した本文。書いてあるものは消してから、フェンスの閉じの直後に置き直す。 */
export function withFigures(path, text) {
  const lines = withoutFigures(text.split('\n'));
  const { blocks } = fencesIn(lines.join('\n'));
  const figures = figurePaths(path, blocks);
  const after = new Map();
  blocks.forEach((block, index) => {
    if (block.close === null) return;
    const indent = /^ */.exec(lines[block.open])[0];
    after.set(block.close, `${indent}![${LABELS[block.fence]}](${PAGES_URL}/${figures[index]})`);
  });
  return lines.flatMap((line, index) => (after.has(index) ? [line, '', after.get(index)] : [line])).join('\n');
}

function main(args) {
  const reads = readEntries();

  if (args[0] === '--verify') {
    const dir = args[1] ?? 'out';
    const missing = reads.flatMap((read) => figurePaths(read.path, fencesIn(read.text).blocks))
      .filter((figure) => !existsSync(join(ROOT, dir, figure)));
    if (missing.length > 0) {
      console.error(`${dir}/ に無い図が ${missing.length} 枚:\n${missing.map((figure) => `  ${figure}`).join('\n')}`);
      process.exit(1);
    }
    console.log(`${dir}/ に画像の行の指す図が全部ある`);
    return;
  }

  const stale = reads.filter((read) => withFigures(read.path, read.text) !== read.text);
  if (args.includes('--check')) {
    if (stale.length > 0) {
      console.error(`画像の行が古い: ${stale.map((read) => read.path).join(', ')} (npm run figures で書き直す)`);
      process.exit(1);
    }
    return;
  }
  for (const read of stale) writeFileSync(join(ROOT, read.path), withFigures(read.path, read.text));
  console.log(`${reads.length} 題のうち ${stale.length} 題の画像の行を書き直した`);
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) main(process.argv.slice(2));
