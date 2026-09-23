import { test } from 'node:test';
import assert from 'node:assert/strict';
import { duplicateIds, validateEntry } from './entry.mjs';

const LED = `---
book: circuits
chapter: 1
id: 1-1
title: LED を点ける — 抵抗で電流を決める
tier: 50
source: 自作
board: BB
---

# 1-1 LED を点ける — 抵抗で電流を決める

本文。
`;

const check = (path, text) => validateEntry({ path, text });

test('accepts a well-formed entry and returns its fields', () => {
  const { entry, errors } = check('circuits/01-basics/01-led.md', LED);

  assert.deepEqual(errors, []);
  assert.equal(entry.id, '1-1');
  assert.equal(entry.tier, 50);
  assert.equal(entry.chapter.title, '基本 — 直流と受動部品');
});

test('rejects a file outside the book and chapter layout', () => {
  assert.match(check('circuits/01-led.md', LED).errors[0], /置き場/);
  assert.match(check('novels/01-basics/01-led.md', LED).errors[0], /冊/);
  assert.match(check('circuits/99-nowhere/01-led.md', LED).errors[0], /章/);
  assert.match(check('circuits/01-basics/1-led.md', LED).errors[0], /ファイル名/);
});

test('rejects a missing or broken front matter', () => {
  assert.match(check('circuits/01-basics/01-led.md', '# 1-1 LED\n').errors[0], /front matter/);
  assert.match(check('circuits/01-basics/01-led.md', '---\n: [\n---\n# x\n').errors[0], /YAML/);
});

test('requires the book, chapter and id to agree with the path', () => {
  const moved = check('circuits/02-transistors/01-led.md', LED).errors;
  assert.ok(moved.some((error) => /chapter/.test(error)));
  assert.ok(moved.some((error) => /id/.test(error)));

  const renumbered = check('circuits/01-basics/02-led.md', LED).errors;
  assert.ok(renumbered.some((error) => /id/.test(error)));

  const wrongBook = check('nanovna/01-calibration/01-led.md', LED.replace('chapter: 1', 'chapter: 1\ndevice: H4')).errors;
  assert.ok(wrongBook.some((error) => /book/.test(error)));
});

test('rejects unknown keys and values outside the tables', () => {
  const errors = check('circuits/01-basics/01-led.md', LED
    .replace('tier: 50', 'tier: 75')
    .replace('board: BB', 'board: XX\ncolour: red')).errors;

  assert.ok(errors.some((error) => /tier/.test(error)));
  assert.ok(errors.some((error) => /board/.test(error)));
  assert.ok(errors.some((error) => /colour/.test(error)));
});

test('asks each book for the device it needs', () => {
  const vna = (extra) => check('nanovna/03-fixtures/01-series.md', `---
book: nanovna
chapter: 3
id: 3-1
title: 直列治具
tier: 50
source: 自作
${extra}---

# 3-1 直列治具
`).errors;

  assert.ok(vna('').some((error) => /device/.test(error)));
  assert.deepEqual(vna('device: V2\n'), []);
  assert.ok(vna('device: AD3\n').some((error) => /device/.test(error)));
  assert.ok(check('circuits/01-basics/01-led.md', LED.replace('board: BB', 'device: H4')).errors
    .some((error) => /device/.test(error)));
});

test('requires the first heading to be the id and the title', () => {
  const errors = check('circuits/01-basics/01-led.md', LED.replace('# 1-1 LED を点ける', '# LED を点ける')).errors;

  assert.ok(errors.some((error) => /見出し/.test(error)));
});

test('finds ids used by more than one file in the same book', () => {
  const entries = [
    { path: 'circuits/01-basics/03-led.md', book: { dir: 'circuits' }, id: '1-3' },
    { path: 'circuits/01-basics/03-ohm.md', book: { dir: 'circuits' }, id: '1-3' },
    { path: 'nanovna/01-calibration/03-solt.md', book: { dir: 'nanovna' }, id: '1-3' },
  ];

  assert.deepEqual(duplicateIds(entries), [
    { book: 'circuits', id: '1-3', paths: ['circuits/01-basics/03-led.md', 'circuits/01-basics/03-ohm.md'] },
  ]);
});
