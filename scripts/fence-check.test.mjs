import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fenceCheckArgs, findFenceCheck, problemOf } from './fence-check.mjs';

/** 教科書と、隣に置いた公開側の monorepo を作る。`built` なら dist まで。 */
function sideBySide(built) {
  const top = mkdtempSync(join(tmpdir(), 'fence-check-'));
  const book = join(top, 'tommie-circuit-workbook');
  mkdirSync(book);
  const dist = join(top, 'tommie-fence', 'packages', 'fence-check', 'dist');
  mkdirSync(dist, { recursive: true });
  if (built) writeFileSync(join(dist, 'cli.cjs'), '');
  return { book, cli: join(dist, 'cli.cjs') };
}

test('finds fence-check in the monorepo next to the book', () => {
  const { book, cli } = sideBySide(true);
  assert.deepEqual(findFenceCheck(book, {}), { path: cli, reason: null });
});

test('FENCE_CHECK wins over the monorepo next to the book', () => {
  const { book } = sideBySide(true);
  const other = join(mkdtempSync(join(tmpdir(), 'fence-check-')), 'cli.cjs');
  writeFileSync(other, '');
  assert.deepEqual(findFenceCheck(book, { FENCE_CHECK: other }), { path: other, reason: null });
});

test('skips with a reason when there is no monorepo, no build, or a wrong FENCE_CHECK', () => {
  const alone = mkdtempSync(join(tmpdir(), 'fence-check-'));
  assert.match(findFenceCheck(alone, {}).reason, /隣に置く/);
  assert.match(findFenceCheck(sideBySide(false).book, {}).reason, /npm run build -w fence-check/);
  assert.match(findFenceCheck(alone, { FENCE_CHECK: join(alone, 'no.cjs') }).reason, /FENCE_CHECK/);
});

test('runs over the whole book against the baseline and the allow list, passing extra arguments on', () => {
  assert.deepEqual(fenceCheckArgs(['--write']), ['.', '--baseline', 'fence-check.json', '--allow', 'fence-check-allow.json', '--write']);
});

test('only new findings (1) and broken files (2) are problems', () => {
  assert.equal(problemOf(0), null);
  assert.match(problemOf(1), /fence-check-allow\.json/);
  assert.match(problemOf(2), /読めません/);
});
