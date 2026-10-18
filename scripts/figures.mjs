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

import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, readEntries } from './collect.mjs';
import { listEnglish } from './en-check.mjs';
import { fencesIn } from './fences.mjs';

export const PAGES_URL = 'https://tommie-jp.github.io/tommie-circuit-workbook';

const LABELS = {
  circuit: '回路図',
  breadboard: 'ブレッドボードの実体配線図',
  perfboard: 'ユニバーサル基板の実体配線図',
  copper: '銅張り基板の寸法図',
  vna: 'NanoVNA の画面',
  scope: 'オシロスコープの画面',
  spectrum: 'スペクトラムアナライザの画面',
  graph: 'グラフ',
  logic: 'ロジックアナライザの画面',
  plantuml: 'ブロック図',
};

/** 英語版 (`en/`) の名札と画像の alt。決めは en/GLOSSARY.md の「Figures」。 */
const LABELS_EN = {
  circuit: 'Schematic',
  breadboard: 'Breadboard wiring diagram',
  perfboard: 'Perfboard wiring diagram',
  copper: 'Copper-clad board dimension drawing',
  vna: 'NanoVNA screen',
  scope: 'Oscilloscope screen',
  spectrum: 'Spectrum analyzer screen',
  graph: 'Graph',
  logic: 'Logic analyzer screen',
  plantuml: 'Block diagram',
};

const isEnglish = (path) => path.startsWith('en/');

const CACHE_DIR = join('out', '.cache');
const CACHE_FILE = join(CACHE_DIR, 'render-manifest.json');

/** このスクリプトが書いた画像の行。Pages の URL を指す画像だけの行。 */
const FIGURE_LINE = new RegExp(`^ {0,3}!\\[[^\\]]*\\]\\(${PAGES_URL.replace(/[.]/g, '\\.')}/[^)\\s]+\\)$`);

/**
 * フェンスの 1 行目に置く名札のコメント。GitHub は言語名を出さないので、字の側でも何の図か分かるようにする。
 * この行も `npm run figures` が書く。手で直さない。plantuml は名の知れた言語なので付けない。
 */
const LABEL_LINE = /^ *# .+ \((?:tommie-fence の \S+ フェンス|tommie-fence \S+ fence)\)$/;

function labelLine(indent, spelling, fence, english = false) {
  return english
    ? `${indent}# ${LABELS_EN[fence]} (tommie-fence ${spelling} fence)`
    : `${indent}# ${LABELS[fence]} (tommie-fence の ${spelling} フェンス)`;
}

function loadManifest() {
  if (!existsSync(CACHE_FILE)) return {};
  try {
    return JSON.parse(readFileSync(CACHE_FILE, 'utf8'));
  } catch {
    return {};
  }
}

/**
 * 題の各フェンスの図の置き場 (`<冊>/<章>/<フェンス>/<名前>.svg`)。道具の名付けに合わせる —
 * 1 つのファイルに同じフェンスが 1 枚ならファイル名のまま、2 枚以上なら `-1` `-2` … を付ける。
 */
export function figurePaths(path, blocks) {
  // 英語版は `en/<冊>/<章>/<題>.md`。図も `en/<冊>/<章>/<フェンス>/<名前>.svg` に置く
  const parts = path.split('/');
  const [prefix, book, chapter, file] = isEnglish(path) ? ['en/', ...parts.slice(1)] : ['', ...parts];
  const base = file.replace(/\.md$/, '');
  const totals = new Map();
  for (const { fence } of blocks) totals.set(fence, (totals.get(fence) ?? 0) + 1);
  const seen = new Map();
  return blocks.map(({ fence }) => {
    const nth = (seen.get(fence) ?? 0) + 1;
    seen.set(fence, nth);
    const name = totals.get(fence) === 1 ? base : `${base}-${nth}`;
    return `${prefix}${book}/${chapter}/${fence}/${name}.svg`;
  });
}

/** 前に書いた画像の行を (前の空行ごと) 除く。 */
function withoutFigures(lines) {
  return lines.filter((line, index) => {
    if (FIGURE_LINE.test(line) || LABEL_LINE.test(line)) return false;
    return !(line === '' && FIGURE_LINE.test(lines[index + 1] ?? ''));
  });
}

/** 画像の行を書き直した本文。書いてあるものは消してから、フェンスの閉じの直後に置き直す。 */
export function withFigures(path, text) {
  const lines = withoutFigures(text.split('\n'));
  const { blocks } = fencesIn(lines.join('\n'));
  const figures = figurePaths(path, blocks);
  const english = isEnglish(path);
  const labelsOf = english ? LABELS_EN : LABELS;
  const after = new Map();
  const labels = new Map();
  blocks.forEach((block, index) => {
    if (block.close === null) return;
    const indent = /^ */.exec(lines[block.open])[0];
    after.set(block.close, `${indent}![${labelsOf[block.fence]}](${PAGES_URL}/${figures[index]})`);
    const spelling = /^ *(?:`{3,}|~{3,}) *(\S+)/.exec(lines[block.open])?.[1];
    if (block.fence !== 'plantuml' && spelling) labels.set(block.open, labelLine(indent, spelling, block.fence, english));
  });
  return lines.flatMap((line, index) => {
    const out = labels.has(index) ? [line, labels.get(index)] : [line];
    return after.has(index) ? [...out, '', after.get(index)] : out;
  }).join('\n');
}

/** 日本語の題と、英語版の題 (`en/`)。英語版は front matter の検査をここでは掛けない (en-check.mjs が見る)。 */
function allEntries() {
  const english = listEnglish().map((path) => ({ path, text: readFileSync(join(ROOT, path), 'utf8') }));
  return [...readEntries(), ...english];
}

function main(args) {
  const reads = allEntries();
  const manifest = loadManifest();

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

  const stale = reads.filter((read) => {
    const key = `${read.path}`;
    const current = withFigures(read.path, read.text);
    const cached = manifest[key];
    if (cached && cached.text === current) return false;
    return current !== read.text;
  });

  if (args.includes('--check')) {
    if (stale.length > 0) {
      console.error(`画像の行が古い: ${stale.map((read) => read.path).join(', ')} (npm run figures で書き直す)`);
      process.exit(1);
    }
    return;
  }

  for (const read of stale) {
    const nextText = withFigures(read.path, read.text);
    manifest[read.path] = { text: nextText, updatedAt: Date.now() };
    writeFileSync(join(ROOT, read.path), nextText);
  }

  writeFileSync(CACHE_FILE, JSON.stringify(manifest, null, 2));
  console.log(`${reads.length} 題のうち ${stale.length} 題の画像の行を書き直した`);
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) main(process.argv.slice(2));
