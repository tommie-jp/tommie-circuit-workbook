import { test } from 'node:test';
import assert from 'node:assert/strict';
import { BOOKS } from './books.mjs';
import { lastChangeDates, progressTable } from './progress.mjs';

const circuits = BOOKS.find((book) => book.slug === 'circuits');
const nanovna = BOOKS.find((book) => book.slug === 'nanovna');

/** 計画の 1 行。`path` があれば書いた題、`seen` / `reviewed` は確認した日。 */
const row = (book, chapterNumber, number, extra = {}) => {
  const chapter = book.chapters.find((candidate) => candidate.number === chapterNumber);
  return {
    book,
    chapter,
    number,
    id: `${chapterNumber}-${number}`,
    title: `題 ${chapterNumber}-${number}`,
    tier: 50,
    path: null,
    seen: null,
    reviewed: null,
    ...extra,
  };
};

const written = (book, chapterNumber, number, extra = {}) => {
  const chapter = book.chapters.find((candidate) => candidate.number === chapterNumber);
  const path = `${book.dir}/${chapter.dir}/${String(number).padStart(2, '0')}-x.md`;
  return row(book, chapterNumber, number, { path, ...extra });
};

const table = (rowsByBook, changed = new Map()) => progressTable(new Map(rowsByBook), changed);

test('ticks 作成 from the file, shows the review dates, and counts each book', () => {
  const text = table([[circuits.dir, [
    written(circuits, 1, 1, { seen: '2026-11-01', reviewed: '2026-10-30' }),
    written(circuits, 1, 2),
    row(circuits, 1, 3, { tier: 200 }),
  ]]]);

  assert.match(text, /\| 冊 \| 計画 \| 作成 \| 目で確認 \| Fable で確認 \|/);
  assert.match(text, /\| \[回路の教科書\]\(01-circuits\/README\.md\) \| 3 \| 2 \| 1 \| 1 \|/);
  assert.match(text, /\| \[NanoVNA の教科書\]\(03-nanovna\/README\.md\) \| 0 \| 0 \| 0 \| 0 \|/);
  assert.match(text, /\| \*\*計\*\* \| \*\*3\*\* \| \*\*2\*\* \| \*\*1\*\* \| \*\*1\*\* \|/);

  assert.ok(text.includes('## 回路の教科書'));
  assert.ok(text.includes('### 第 1 章 基本 — 直流と受動部品'));
  assert.ok(!text.includes('### 第 0 章'));
  assert.match(text, /\| # \| 題 \| 作成 \| 目で確認 \| Fable で確認 \|/);
  assert.match(text, /\| 1-1 \| \[題 1-1\]\(01-circuits\/01-basics\/01-x\.md\) \| ✓ \| ✓ 2026-11-01 \| ✓ 2026-10-30 \|/);
  assert.match(text, /\| 1-2 \| \[題 1-2\]\(01-circuits\/01-basics\/02-x\.md\) \| ✓ \| \| \|/);
  // まだの題は字だけで、どの欄も空。
  assert.match(text, /\| 1-3 \| 題 1-3 \| \| \| \|/);
  assert.ok(!text.includes('|  |'));
});

test('marks a review as stale (△) when the file changed after the date', () => {
  const entry = written(circuits, 1, 1, { seen: '2026-10-20', reviewed: '2026-10-25' });
  const text = table([[circuits.dir, [entry]]], new Map([[entry.path, '2026-10-25']]));

  // 確認した日より後に書き換えた → △。同じ日なら ✓。
  assert.match(text, /\| 1-1 \| .* \| ✓ \| △ 2026-10-20 \| ✓ 2026-10-25 \|/);
  // △ は数に入れない。
  assert.match(text, /\| \[回路の教科書\]\(01-circuits\/README\.md\) \| 1 \| 1 \| 0 \| 1 \|/);
});

test('escapes a pipe in a title and lists the books in order', () => {
  const text = table([
    [nanovna.dir, [written(nanovna, 3, 1, { title: '|Z| を測る' })]],
    [circuits.dir, [written(circuits, 1, 1)]],
  ]);

  assert.ok(text.includes('[\\|Z\\| を測る]'));
  assert.ok(text.indexOf('## 回路の教科書') < text.indexOf('## NanoVNA の教科書'));
});

test('reads the last change of each file from git log, and counts a modified file as changed today', () => {
  const log = `2026-10-25
01-circuits/01-basics/01-led.md
01-circuits/01-basics/02-x.md

2026-10-20
01-circuits/01-basics/01-led.md
`;
  const dates = lastChangeDates({ log, modified: ['01-circuits/01-basics/02-x.md', '03-nanovna/03-fixtures/01-y.md'], today: '2026-11-01' });

  assert.equal(dates.get('01-circuits/01-basics/01-led.md'), '2026-10-25');
  assert.equal(dates.get('01-circuits/01-basics/02-x.md'), '2026-11-01');
  assert.equal(dates.get('03-nanovna/03-fixtures/01-y.md'), '2026-11-01');
  assert.equal(dates.get('nowhere.md'), undefined);
});
