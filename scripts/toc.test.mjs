import { test } from 'node:test';
import assert from 'node:assert/strict';
import { BOOKS } from './books.mjs';
import { bookToc, fillMarkers, rootToc } from './toc.mjs';

const circuits = BOOKS.find((book) => book.slug === 'circuits');
const nanovna = BOOKS.find((book) => book.slug === 'nanovna');

const entry = (book, chapterNumber, number, extra = {}) => ({
  book,
  chapter: book.chapters.find((chapter) => chapter.number === chapterNumber),
  number,
  id: `${chapterNumber}-${number}`,
  title: `題 ${chapterNumber}-${number}`,
  tier: 50,
  board: null,
  device: null,
  era: null,
  path: `${book.dir}/${book.chapters.find((chapter) => chapter.number === chapterNumber).dir}/${String(number).padStart(2, '0')}-x.md`,
  ...extra,
});

test('counts every chapter cumulatively and lists only chapters that have entries', () => {
  const toc = bookToc(circuits, [
    entry(circuits, 1, 2, { tier: 200 }),
    entry(circuits, 1, 1, { tier: 50, era: '古', board: ['BB', 'PF'] }),
    entry(circuits, 3, 1, { tier: 100 }),
  ]);

  // 入れ子で数える: 入門は必須を含み、中級は全部。
  assert.match(toc, /\| 1 \| 基本 — 直流と受動部品 \| 1 \| 1 \| 2 \|/);
  assert.match(toc, /\| 3 \| 発振とタイマー \| 0 \| 1 \| 1 \|/);
  assert.match(toc, /\| 0 \| 測定と道具 \| 0 \| 0 \| 0 \|/);
  assert.match(toc, /\| \*\*計\*\* \| \| \*\*1\*\* \| \*\*2\*\* \| \*\*3\*\* \|/);

  assert.ok(toc.includes('## 第 1 章 基本 — 直流と受動部品'));
  assert.ok(!toc.includes('## 第 0 章'));
  // 章の中は番号の順。書いた順ではない。
  assert.ok(toc.indexOf('[題 1-1]') < toc.indexOf('[題 1-2]'));
  assert.match(toc, /\| 1-1 \| \[題 1-1\]\(01-basics\/01-x\.md\) \| 必須 \| 古 \| BB \/ PF \|/);
});

test('shows the columns each book asks for', () => {
  const toc = bookToc(nanovna, [entry(nanovna, 3, 1, { device: 'V2', board: 'PF' })]);

  assert.match(toc, /\| # \| 題 \| 段 \| 機種 \| 板 \|/);
  assert.match(toc, /\| 3-1 \| .* \| 必須 \| V2 \| PF \|/);
});

test('writes an empty cell with a single space, as markdownlint expects', () => {
  const toc = bookToc(circuits, [entry(circuits, 1, 1, { era: null, board: 'BB' })]);

  assert.match(toc, /\| 必須 \| \| BB \|/);
  assert.ok(!toc.includes('|  |'));
});

test('escapes a pipe in a title', () => {
  const toc = bookToc(circuits, [entry(circuits, 1, 1, { title: '抵抗の |Z|' })]);

  assert.ok(toc.includes('抵抗の \\|Z\\|'));
});

test('summarises the three books at the root', () => {
  const toc = rootToc(new Map([[circuits.dir, [entry(circuits, 1, 1)]]]));

  assert.match(toc, /\| \[回路の教科書\]\(01-circuits\/README\.md\) \| .* \| 1 \| 1 \| 1 \|/);
  assert.match(toc, /\| \[NanoVNA の教科書\]\(03-nanovna\/README\.md\) \| .* \| 0 \| 0 \| 0 \|/);
});

test('replaces only the text between the markers', () => {
  const text = 'head\n<!-- toc:start -->\nold\n<!-- toc:end -->\ntail\n';

  assert.equal(fillMarkers(text, 'new'), 'head\n<!-- toc:start -->\n\nnew\n\n<!-- toc:end -->\ntail\n');
  assert.throws(() => fillMarkers('no markers', 'new'), /toc:start/);
});
