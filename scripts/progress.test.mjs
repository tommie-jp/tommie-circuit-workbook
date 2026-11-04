import { test } from 'node:test';
import assert from 'node:assert/strict';
import { BOOKS } from './books.mjs';
import { lastChangeDates, progressTable, toggledMarks, withSeen } from './progress.mjs';

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

test('lists each entry as a checkbox for 目で確認, links the written ones, and counts each book', () => {
  const text = table([[circuits.dir, [
    written(circuits, 1, 1, { seen: '2026-11-01', reviewed: '2026-10-30' }),
    written(circuits, 1, 2),
    written(circuits, 1, 3, { reviewed: '2026-10-30' }),
    row(circuits, 1, 4, { tier: 200 }),
  ]]]);

  assert.match(text, /\| 冊 \| 計画 \| 作成 \| 目で確認 \| Fable で確認 \|/);
  assert.match(text, /\| \[回路の教科書\]\(01-circuits\/README\.md\) \| 4 \| 3 \| 1 \| 2 \|/);
  assert.match(text, /\| \[NanoVNA の教科書\]\(03-nanovna\/README\.md\) \| 0 \| 0 \| 0 \| 0 \|/);
  assert.match(text, /\| \*\*計\*\* \| \*\*4\*\* \| \*\*3\*\* \| \*\*1\*\* \| \*\*2\*\* \|/);

  assert.ok(text.includes('## 回路の教科書'));
  assert.ok(text.includes('### 第 1 章 基本 — 直流と受動部品'));
  assert.ok(!text.includes('### 第 0 章'));
  assert.ok(text.includes('- [x] 1-1 [題 1-1](01-circuits/01-basics/01-x.md) ✓ 2026-11-01 · Fable ✓ 2026-10-30\n'));
  // Fable の欄は印が無くても出す (— はまだ)。
  assert.ok(text.includes('- [ ] 1-2 [題 1-2](01-circuits/01-basics/02-x.md) · Fable —\n'));
  assert.ok(text.includes('- [ ] 1-3 [題 1-3](01-circuits/01-basics/03-x.md) · Fable ✓ 2026-10-30\n'));
  // まだの題は箱なし (押しても作成にはならない)。
  assert.ok(text.includes('- 1-4 題 1-4 (まだ)\n'));
});

test('unchecks a stale review (△) when the file changed after the date', () => {
  const entry = written(circuits, 1, 1, { seen: '2026-10-20', reviewed: '2026-10-25' });
  const text = table([[circuits.dir, [entry]]], new Map([[entry.path, '2026-10-25']]));

  // 確認した日より後に書き換えた → △ で箱は空。同じ日なら ✓。
  assert.ok(text.includes('- [ ] 1-1 [題 1-1](01-circuits/01-basics/01-x.md) △ 2026-10-20 · Fable ✓ 2026-10-25\n'));
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

test('finds the boxes the reader toggled since the last run, by book and id', () => {
  const text = `# 進捗

## 回路の教科書

### 第 1 章

- [x] 1-1 [題 1-1](01-circuits/01-basics/01-x.md) ✓ 2026-11-01 · Fable ✓ 2026-10-30
- [x] 1-2 [題 1-2](01-circuits/01-basics/02-x.md) · Fable —
- [ ] 1-3 [題 1-3](01-circuits/01-basics/03-x.md) ✓ 2026-11-01
- [X] 1-4 [題 1-4](01-circuits/01-basics/04-x.md) △ 2026-10-20 · Fable ✓ 2026-10-25
- [ ] 1-5 [題 1-5](01-circuits/01-basics/05-x.md) · Fable ✓ 2026-10-25
- 1-6 題 1-6 (まだ)

## NanoVNA の教科書

### 第 3 章

- [x] 1-2 [題 1-2](03-nanovna/03-fixtures/02-x.md)
`;
  assert.deepEqual(toggledMarks(text), [
    { book: circuits, id: '1-2', path: '01-circuits/01-basics/02-x.md', checked: true },
    { book: circuits, id: '1-3', path: '01-circuits/01-basics/03-x.md', checked: false },
    { book: circuits, id: '1-4', path: '01-circuits/01-basics/04-x.md', checked: true },
    { book: nanovna, id: '1-2', path: '03-nanovna/03-fixtures/02-x.md', checked: true },
  ]);
  assert.deepEqual(toggledMarks(''), []);
});

test('withSeen writes or removes the seen date in the front matter and keeps the rest', () => {
  const text = '---\nid: 1-1\nboard: BB\n---\n\n# 1-1 題\n';

  assert.equal(withSeen(text, '2026-11-04'), '---\nid: 1-1\nboard: BB\nseen: 2026-11-04\n---\n\n# 1-1 題\n');
  assert.equal(withSeen('---\nid: 1-1\nseen: 2026-10-01\nboard: BB\n---\n# x\n', '2026-11-04'), '---\nid: 1-1\nboard: BB\nseen: 2026-11-04\n---\n# x\n');
  assert.equal(withSeen('---\nid: 1-1\nseen: 2026-10-01\n---\n# x\n', null), '---\nid: 1-1\n---\n# x\n');
  assert.equal(withSeen(text, null), text);
  assert.throws(() => withSeen('# no front matter\n', '2026-11-04'), /front matter/);
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
