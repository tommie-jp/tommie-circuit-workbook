/**
 * 目次を計画 (`plan.yaml`) と書いた題 (front matter) から組み、README の印
 * (`<!-- toc:start -->` 〜 `<!-- toc:end -->`) の間に書き込む。
 * **印の外は手で書いた前書きなので触らない。**
 *
 *   node scripts/toc.mjs          README を書き換える
 *   node scripts/toc.mjs --check  書き換えが要るなら 1 で終わる (CI)
 *
 * 必須・入門・中級は計画の数で、**入れ子で数える** — 入門は必須を含み、中級は全部。
 * 「済」は書いた題の数。書いた題は link になり、まだの題は字だけ。
 */

import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { BOOKS, TIERS, TIER_NAMES } from './books.mjs';
import { ROOT, readEntries } from './collect.mjs';
import { mergePlan, readPlan } from './plan.mjs';

const START = '<!-- toc:start -->';
const END = '<!-- toc:end -->';

/** front matter の欄 → 目次の表の見出し。 */
const COLUMN_NAMES = { era: '印', board: '板', device: '機種' };

const WRITTEN = '済';

/** 段ごとの数 (入れ子) と書いた数。`[必須, 入門, 中級, 済]`。 */
function counts(rows) {
  return [
    ...TIERS.map((limit) => rows.filter((row) => row.tier <= limit).length),
    rows.filter((row) => row.path !== null).length,
  ];
}

const cell = (value) => {
  if (value === null || value === undefined) return '';
  const text = Array.isArray(value) ? value.join(' / ') : String(value);
  return text.replaceAll('|', '\\|');
};

/** 表の 1 行。空の欄は `| |` (空白 1 つ) にする — 2 つだと markdownlint の MD060 に掛かる。 */
const row = (cells) => `|${cells.map((text) => (text === '' ? ' ' : ` ${text} `)).join('|')}|`;

const byNumber = (a, b) => a.chapter.number - b.chapter.number || a.number - b.number;

const COUNT_NAMES = [...TIERS.map((tier) => TIER_NAMES[tier]), WRITTEN];

/** 題の欄。書いた題はファイルへの link、まだの題は字だけ。 */
const titleCell = (book, entry) =>
  (entry.path === null ? cell(entry.title) : `[${cell(entry.title)}](${entry.path.slice(book.dir.length + 1)})`);

/**
 * 1 冊の目次。章の一覧 (数) と、題のある章ごとの表。
 *
 * @param {object} book `books.mjs` の冊
 * @param {object[]} rows `plan.mjs` の `mergePlan` が返す並び (書いた題は `path` を持つ)
 */
export function bookToc(book, rows) {
  const sorted = [...rows].sort(byNumber);

  const overview = [
    row(['章', '題名', ...COUNT_NAMES]),
    row(['---', '---', ...COUNT_NAMES.map(() => '---')]),
    ...book.chapters.map((chapter) => {
      const inChapter = sorted.filter((entry) => entry.chapter.number === chapter.number);
      return row([String(chapter.number), chapter.title, ...counts(inChapter).map(String)]);
    }),
    row(['**計**', '', ...counts(sorted).map((count) => `**${count}**`)]),
  ];

  const header = ['#', '題', '段', ...book.columns.map((column) => COLUMN_NAMES[column])];
  const sections = book.chapters
    .map((chapter) => [chapter, sorted.filter((entry) => entry.chapter.number === chapter.number)])
    .filter(([, inChapter]) => inChapter.length > 0)
    .map(([chapter, inChapter]) => [
      `## 第 ${chapter.number} 章 ${chapter.title}`,
      '',
      row(header),
      row(header.map(() => '---')),
      ...inChapter.map((entry) => row([
        entry.id,
        titleCell(book, entry),
        TIER_NAMES[entry.tier],
        ...book.columns.map((column) => cell(entry[column])),
      ])),
    ].join('\n'));

  return [
    `必須・入門・中級は計画の数で、入れ子で数える (入門は必須を含み、中級は全部)。
${WRITTEN} は書き終えた題の数。書き終えた題は link になっている。`,
    '',
    overview.join('\n'),
    ...sections.flatMap((section) => ['', section]),
  ].join('\n');
}

/** 直下の README に載せる冊の一覧。 */
export function rootToc(rowsByBook) {
  return [
    row(['冊', '内容', ...COUNT_NAMES]),
    row(['---', '---', ...COUNT_NAMES.map(() => '---')]),
    ...BOOKS.map((book) => {
      const inBook = counts(rowsByBook.get(book.dir) ?? []);
      return row([`[${book.title}](${book.dir}/README.md)`, book.summary, ...inBook.map(String)]);
    }),
  ].join('\n');
}

/** 印の間を差し替える。印が無ければ投げる (前書きを消さないため、黙って足さない)。 */
export function fillMarkers(text, content) {
  const start = text.indexOf(START);
  const end = text.indexOf(END);
  if (start === -1 || end === -1 || end < start) {
    throw new Error(`${START} と ${END} の印がありません`);
  }
  return `${text.slice(0, start + START.length)}\n\n${content}\n\n${text.slice(end)}`;
}

/**
 * 冊ごとに計画と書いた題を合わせた並び。検査を通らなかった題は数えない。
 * 計画の側の問題 (読めない・計画に無い題・ずれ) は `check.mjs` が言うので、ここでは集めるだけ。
 */
export function mergedRows(root = ROOT) {
  const entries = readEntries(root).filter((read) => read.entry !== null && read.errors.length === 0);
  return new Map(BOOKS.map((book) => {
    const plan = readPlan(root, book);
    const inBook = entries.filter((read) => read.entry.book.dir === book.dir).map((read) => read.entry);
    const merged = mergePlan(plan.items, inBook);
    return [book.dir, { rows: merged.rows, errors: [...plan.errors, ...merged.errors] }];
  }));
}

/** 書き換えるべき README と中身の組。 */
export function plannedReadmes(root = ROOT) {
  const byBook = new Map([...mergedRows(root)].map(([dir, { rows }]) => [dir, rows]));

  return [
    { path: 'README.md', content: rootToc(byBook) },
    ...BOOKS.map((book) => ({ path: `${book.dir}/README.md`, content: bookToc(book, byBook.get(book.dir)) })),
  ].map(({ path, content }) => {
    const current = readFileSync(join(root, path), 'utf8');
    return { path, current, next: fillMarkers(current, content) };
  });
}

function main(args) {
  const checkOnly = args.includes('--check');
  const stale = [];
  for (const { path, current, next } of plannedReadmes()) {
    if (current === next) continue;
    stale.push(path);
    if (!checkOnly) writeFileSync(join(ROOT, path), next);
  }

  if (checkOnly && stale.length > 0) {
    console.error(`目次が古い: ${stale.join(', ')}\nnpm run toc で書き直してコミットする`);
    process.exit(1);
  }
  if (!checkOnly) console.log(stale.length === 0 ? '目次は最新' : `書き直した: ${stale.join(', ')}`);
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) main(process.argv.slice(2));
