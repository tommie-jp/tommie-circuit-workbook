import { test } from 'node:test';
import assert from 'node:assert/strict';
import { BOOKS } from './books.mjs';
import { mergePlan, validatePlan } from './plan.mjs';

const ad = BOOKS.find((book) => book.slug === 'analog-discovery');
const nanovna = BOOKS.find((book) => book.slug === 'nanovna');

const item = (extra = {}) => ({ id: '1-1', tier: 50, board: 'BB', title: 'Supplies', ...extra });

const errorsOf = (book, data) => validatePlan(book, data).errors;

test('accepts a plan and places each item in its chapter', () => {
  const { items, errors } = validatePlan(ad, [item(), item({ id: '2-3', tier: 200, device: 'AD3', board: '—' })]);

  assert.deepEqual(errors, []);
  assert.equal(items[0].chapter.title, 'WaveForms の基本');
  assert.equal(items[0].number, 1);
  assert.equal(items[1].chapter.number, 2);
  assert.equal(items[1].device, 'AD3');
  // 書いていない印は null (題のファイルと同じ形にして、目次が同じ手で出せるように)。
  assert.equal(items[0].device, null);
  assert.equal(items[0].era, null);
});

test('rejects a plan that is not a list of maps', () => {
  assert.match(errorsOf(ad, { id: '1-1' })[0], /並び/);
  assert.match(errorsOf(ad, ['1-1'])[0], /1 つ目/);
});

test('rejects an item whose id, title or tier is missing or off the tables', () => {
  assert.ok(errorsOf(ad, [item({ id: 'one' })]).some((error) => /id/.test(error)));
  assert.ok(errorsOf(ad, [item({ id: '99-1' })]).some((error) => /章/.test(error)));
  assert.ok(errorsOf(ad, [item({ title: '' })]).some((error) => /title/.test(error)));
  assert.ok(errorsOf(ad, [item({ tier: 75 })]).some((error) => /tier/.test(error)));
  assert.ok(errorsOf(ad, [item({ board: 'XX' })]).some((error) => /board/.test(error)));
  assert.ok(errorsOf(ad, [item({ device: 'H4' })]).some((error) => /device/.test(error)));
  assert.ok(errorsOf(ad, [item({ era: '古' })]).some((error) => /era/.test(error)));
  assert.ok(errorsOf(ad, [item({ source: '自作' })]).some((error) => /知らない鍵/.test(error)));
  // NanoVNA は機種が必ず要る (題のファイルと同じ決まり)。
  assert.ok(errorsOf(nanovna, [item({ board: 'PF' })]).some((error) => /device/.test(error)));
});

test('names the item in every error and rejects an id used twice', () => {
  const errors = errorsOf(ad, [item({ tier: 75 }), item({ title: 'again' })]);

  assert.match(errors[0], /^1-1: /);
  assert.ok(errors.some((error) => /1-1.*2 つ/.test(error)));
});

test('merges written entries into the plan and keeps their marks', () => {
  const { items } = validatePlan(ad, [item(), item({ id: '1-2', tier: 100, board: '—', title: 'Wavegen' })]);
  const written = { ...items[0], board: ['BB', 'PF'], path: '02-analog-discovery/01-waveforms/01-supplies.md' };

  const { rows, errors } = mergePlan(items, [written]);

  assert.deepEqual(errors, []);
  assert.deepEqual(rows.map((row) => [row.id, row.path]), [
    ['1-1', '02-analog-discovery/01-waveforms/01-supplies.md'],
    ['1-2', null],
  ]);
  // 書いた題の印はファイルのものを出す (計画より詳しくなっている)。
  assert.deepEqual(rows[0].board, ['BB', 'PF']);
});

test('keeps an entry the plan does not know, sorted into place, and says so', () => {
  const { items } = validatePlan(ad, [item({ id: '1-2', title: 'Wavegen' })]);
  const stray = { ...items[0], id: '1-1', number: 1, title: 'Supplies', path: '02-analog-discovery/01-waveforms/01-supplies.md' };

  const { rows, errors } = mergePlan(items, [stray]);

  assert.deepEqual(rows.map((row) => row.id), ['1-1', '1-2']);
  assert.match(errors[0], /1-1.*plan\.yaml/);
});

test('reports a written entry whose title or tier drifted from the plan', () => {
  const { items } = validatePlan(ad, [item()]);
  const drifted = { ...items[0], title: 'Supplies (改)', tier: 100, path: 'x.md' };

  const { rows, errors } = mergePlan(items, [drifted]);

  assert.ok(errors.some((error) => /1-1.*title/.test(error)));
  assert.ok(errors.some((error) => /1-1.*tier/.test(error)));
  // 目次はファイルの言い分で出す (直すのは plan.yaml の側)。
  assert.equal(rows[0].title, 'Supplies (改)');
});
