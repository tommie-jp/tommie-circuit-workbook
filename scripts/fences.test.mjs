import { test } from 'node:test';
import assert from 'node:assert/strict';
import { fencesIn } from './fences.mjs';

test('finds the three fences a file uses', () => {
  const { found, misspelled } = fencesIn('# t\n\n```circuit\nparts:\n```\n\n```breadboard\n```\n\n```text\n```\n');

  assert.deepEqual([...found].sort(), ['breadboard', 'circuit']);
  assert.deepEqual(misspelled, []);
});

test('flags names the command line tools would silently skip', () => {
  const { found, misspelled } = fencesIn('```bread\n```\n```perf\n```\n```Circuit\n```\n```yaml\n```\n```circuitikz\n```\n```breadbord\n```\n');

  assert.deepEqual([...found], []);
  assert.deepEqual(misspelled.map((fence) => fence.name), ['bread', 'perf', 'Circuit', 'breadbord']);
  assert.deepEqual(misspelled.map((fence) => fence.line), [1, 3, 5, 11]);
});

test('reads every fence form the command line tools read', () => {
  const text = [
    '```c++',
    'int main() {}',
    '```',
    '~~~circuit',
    'parts:',
    '~~~',
    '   ```breadboard title',
    '```',
    '````perfboard',
    '```',
    'still inside',
    '````',
  ].join('\n');

  assert.deepEqual([...fencesIn(text).found].sort(), ['breadboard', 'circuit', 'perfboard']);
});

test('does not close a fence with a shorter or different run', () => {
  const text = ['````text', '```', '```bread', '~~~~', '````'].join('\n');

  assert.deepEqual(fencesIn(text).misspelled, []);
});

test('finds the vna fence (the NanoVNA screen)', () => {
  const { found, misspelled } = fencesIn('```vna\nsweep: 1M-300M\n```\n');

  assert.deepEqual([...found], ['vna']);
  assert.deepEqual(misspelled, []);
});

test('flags a near miss of vna, but not short names of other languages', () => {
  // 3 字の vna に 2 字違いまでを許すと、ini や png まで書き間違いに見える。
  const text = ['```VNA', '```', '```vnaa', '```', '```ini', '```', '```png', '```', '```lua', '```', '```vue', '```'].join('\n');

  assert.deepEqual(fencesIn(text).misspelled.map((fence) => fence.name), ['VNA', 'vnaa']);
});
