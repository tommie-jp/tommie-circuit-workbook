/**
 * 目次を front matter から組み、README の印 (`<!-- toc:start -->` 〜
 * `<!-- toc:end -->`) の間に書き込む。**印の外は手で書いた前書きなので触らない。**
 *
 *   node scripts/toc.mjs          README を書き換える
 *   node scripts/toc.mjs --check  書き換えが要るなら 1 で終わる (CI)
 *
 * 数は**入れ子で数える** — 入門は必須を含み、中級は全部。
 */

import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { BOOKS, TIERS, TIER_NAMES } from './books.mjs';
import { ROOT, readEntries } from './collect.mjs';

const START = '<!-- toc:start -->';
const END = '<!-- toc:end -->';

/** front matter の欄 → 目次の表の見出し。 */
const COLUMN_NAMES = { era: '印', board: '板', device: '機種' };

/** 段ごとの数 (入れ子)。`[必須, 入門, 中級]`。 */
function tierCounts(entries) {
  return TIERS.map((limit) => entries.filter((entry) => entry.tier <= limit).length);
}

const cell = (value) => {
  if (value === null || value === undefined) return '';
  const text = Array.isArray(value) ? value.join(' / ') : String(value);
  return text.replaceAll('|', '\\|');
};

/** 表の 1 行。空の欄は `| |` (空白 1 つ) にする — 2 つだと markdownlint の MD060 に掛かる。 */
const row = (cells) => `|${cells.map((text) => (text === '' ? ' ' : ` ${text} `)).join('|')}|`;

const byNumber = (a, b) => a.chapter.number - b.chapter.number || a.number - b.number;

/** 1 冊の目次。章の一覧 (数) と、題のある章ごとの表。 */
export function bookToc(book, entries) {
  const sorted = [...entries].sort(byNumber);
  const [all50, all100, all200] = tierCounts(sorted);

  const overview = [
    row(['章', '題名', ...TIERS.map((tier) => TIER_NAMES[tier])]),
    row(['---', '---', ...TIERS.map(() => '---')]),
    ...book.chapters.map((chapter) => {
      const counts = tierCounts(sorted.filter((entry) => entry.chapter.number === chapter.number));
      return row([String(chapter.number), chapter.title, ...counts.map(String)]);
    }),
    row(['**計**', '', ...[all50, all100, all200].map((count) => `**${count}**`)]),
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
      ...inChapter.map((entry) => {
        const link = entry.path.slice(book.dir.length + 1);
        const cells = [
          entry.id,
          `[${cell(entry.title)}](${link})`,
          TIER_NAMES[entry.tier],
          ...book.columns.map((column) => cell(entry[column])),
        ];
        return row(cells);
      }),
    ].join('\n'));

  return [
    '数は入れ子で数える (入門は必須を含み、中級は全部)。',
    '',
    overview.join('\n'),
    ...sections.flatMap((section) => ['', section]),
  ].join('\n');
}

/** 直下の README に載せる冊の一覧。 */
export function rootToc(entriesByBook) {
  return [
    row(['冊', '内容', ...TIERS.map((tier) => TIER_NAMES[tier])]),
    row(['---', '---', ...TIERS.map(() => '---')]),
    ...BOOKS.map((book) => {
      const counts = tierCounts(entriesByBook.get(book.dir) ?? []);
      return row([`[${book.title}](${book.dir}/README.md)`, book.summary, ...counts.map(String)]);
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

/** 書き換えるべき README と中身の組。検査を通らなかった題は数えない。 */
export function plannedReadmes(root = ROOT) {
  const entries = readEntries(root).filter((read) => read.entry !== null && read.errors.length === 0);
  const byBook = new Map(BOOKS.map((book) => [
    book.dir,
    entries.filter((read) => read.entry.book.dir === book.dir).map((read) => read.entry),
  ]));

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
