import { test } from 'node:test';
import assert from 'node:assert/strict';
import { BOOKS } from './books.mjs';
import { bookToc, fillMarkers, rootToc } from './toc.mjs';

const circuits = BOOKS.find((book) => book.slug === 'circuits');
const nanovna = BOOKS.find((book) => book.slug === 'nanovna');

/** 目次の 1 行 (計画と題のファイルを合わせたもの)。`path` があれば書いた題。 */
const row = (book, chapterNumber, number, extra = {}) => {
  const chapter = book.chapters.find((candidate) => candidate.number === chapterNumber);
  return {
    book,
    chapter,
    number,
    id: `${chapterNumber}-${number}`,
    title: `題 ${chapterNumber}-${number}`,
    tier: 50,
    board: null,
    device: null,
    era: null,
    path: null,
    ...extra,
  };
};

const written = (book, chapterNumber, number, extra = {}) => {
  const chapter = book.chapters.find((candidate) => candidate.number === chapterNumber);
  const path = `${book.dir}/${chapter.dir}/${String(number).padStart(2, '0')}-x.md`;
  return row(book, chapterNumber, number, { path, ...extra });
};

test('counts the plan cumulatively, counts the written ones, and lists only chapters that have rows', () => {
  const toc = bookToc(circuits, [
    row(circuits, 1, 2, { tier: 200 }),
    written(circuits, 1, 1, { tier: 50, era: '古', board: ['BB', 'PF'] }),
    row(circuits, 3, 1, { tier: 100 }),
  ]);

  // 必須・入門・中級は計画の数 (入れ子)。済 は書いた題の数。
  assert.match(toc, /\| 章 \| 題名 \| 必須 \| 入門 \| 中級 \| 済 \|/);
  assert.match(toc, /\| 1 \| 基本 — 直流と受動部品 \| 1 \| 1 \| 2 \| 1 \|/);
  assert.match(toc, /\| 3 \| 発振とタイマー \| 0 \| 1 \| 1 \| 0 \|/);
  assert.match(toc, /\| 0 \| 測定と道具 \| 0 \| 0 \| 0 \| 0 \|/);
  assert.match(toc, /\| \*\*計\*\* \| \| \*\*1\*\* \| \*\*2\*\* \| \*\*3\*\* \| \*\*1\*\* \|/);

  assert.ok(toc.includes('## 第 1 章 基本 — 直流と受動部品'));
  assert.ok(!toc.includes('## 第 0 章'));
  // 章の中は番号の順。渡した順ではない。
  assert.ok(toc.indexOf('題 1-1') < toc.indexOf('題 1-2'));
  // 書いた題は link、まだの題は字だけ。
  assert.match(toc, /\| 1-1 \| \[題 1-1\]\(01-basics\/01-x\.md\) \| 必須 \| 古 \| BB \/ PF \|/);
  assert.match(toc, /\| 1-2 \| 題 1-2 \| 中級 \| \| \|/);
});

test('shows the columns each book asks for', () => {
  const toc = bookToc(nanovna, [written(nanovna, 3, 1, { device: 'V2', board: 'PF' })]);

  assert.match(toc, /\| # \| 題 \| 段 \| 機種 \| 板 \|/);
  assert.match(toc, /\| 3-1 \| .* \| 必須 \| V2 \| PF \|/);
});

test('writes an empty cell with a single space, as markdownlint expects', () => {
  const toc = bookToc(circuits, [written(circuits, 1, 1, { era: null, board: 'BB' })]);

  assert.match(toc, /\| 必須 \| \| BB \|/);
  assert.ok(!toc.includes('|  |'));
});

test('escapes a pipe in a title', () => {
  const toc = bookToc(circuits, [row(circuits, 1, 1, { title: '抵抗の |Z|' })]);

  assert.ok(toc.includes('抵抗の \\|Z\\|'));
});

test('summarises every book at the root', () => {
  const toc = rootToc(new Map([[circuits.dir, [written(circuits, 1, 1), row(circuits, 1, 2, { tier: 200 })]]]));

  assert.match(toc, /\| 冊 \| 内容 \| 必須 \| 入門 \| 中級 \| 済 \|/);
  assert.match(toc, /\| \[回路の教科書\]\(01-circuits\/README\.md\) \| .* \| 1 \| 1 \| 2 \| 1 \|/);
  assert.match(toc, /\| \[NanoVNA の教科書\]\(03-nanovna\/README\.md\) \| .* \| 0 \| 0 \| 0 \| 0 \|/);
});

test('replaces only the text between the markers', () => {
  const text = 'head\n<!-- toc:start -->\nold\n<!-- toc:end -->\ntail\n';

  assert.equal(fillMarkers(text, 'new'), 'head\n<!-- toc:start -->\n\nnew\n\n<!-- toc:end -->\ntail\n');
  assert.throws(() => fillMarkers('no markers', 'new'), /toc:start/);
});
