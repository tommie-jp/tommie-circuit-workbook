import { test } from 'node:test';
import assert from 'node:assert/strict';
import { PAGES_URL, figurePaths, withFigures } from './figures.mjs';
import { FENCES, fencesIn } from './fences.mjs';

const PATH = '01-circuits/01-basics/03-rc-charge.md';

test('names figures the way the fence tools name their output', () => {
  const { blocks } = fencesIn('```circuit\n```\n\n```scope\n```\n\n```scope\n```\n');

  assert.deepEqual(figurePaths(PATH, blocks), [
    '01-circuits/01-basics/circuit/03-rc-charge.svg',
    '01-circuits/01-basics/scope/03-rc-charge-1.svg',
    '01-circuits/01-basics/scope/03-rc-charge-2.svg',
  ]);
});

test('puts an image line right after each fence, skipping other code blocks', () => {
  const text = '# t\n\n```circuit\nparts:\n```\n\n```text\n```\n\n```bread\n```\n\nend\n';

  assert.equal(withFigures(PATH, text), [
    '# t', '', '```circuit', 'parts:', '```', '',
    `![回路図](${PAGES_URL}/01-circuits/01-basics/circuit/03-rc-charge.svg)`, '',
    '```text', '```', '', '```bread', '```', '',
    `![ブレッドボードの実体配線図](${PAGES_URL}/01-circuits/01-basics/breadboard/03-rc-charge.svg)`, '',
    'end', '',
  ].join('\n'));
});

test('rewriting twice changes nothing, and stale lines are replaced', () => {
  const once = withFigures(PATH, '```circuit\n```\n\ntext\n');
  assert.equal(withFigures(PATH, once), once);

  const moved = once.replace('```circuit\n```\n', '```circuit\n```\n\n```circuit\n```\n');
  const fixed = withFigures(PATH, moved);
  assert.match(fixed, /circuit\/03-rc-charge-1\.svg/);
  assert.match(fixed, /circuit\/03-rc-charge-2\.svg/);
  assert.doesNotMatch(fixed, /circuit\/03-rc-charge\.svg/);
});

test('keeps the indent of a fence inside a list, and leaves an unclosed fence alone', () => {
  assert.match(withFigures(PATH, '- a\n\n  ```vna\n  ```\n'), /\n {2}!\[NanoVNA の画面\]/);
  assert.equal(withFigures(PATH, '```circuit\nparts:\n'), '```circuit\nparts:\n');
});

test('gives every fence a label for its image line, so none reads "undefined"', () => {
  for (const fence of FENCES) {
    const text = `# t\n\n\`\`\`${fence}\n\`\`\`\n`;
    const line = withFigures(PATH, text).split('\n').find((row) => row.startsWith('!['));
    assert.ok(line !== undefined, fence);
    assert.doesNotMatch(line, /^!\[(undefined)?\]/, fence);
  }
});

test('labels the copper fence as a dimension drawing', () => {
  const text = '```copper\n```\n';

  assert.equal(withFigures(PATH, text), [
    '```copper', '```', '',
    `![銅張り基板の寸法図](${PAGES_URL}/01-circuits/01-basics/copper/03-rc-charge.svg)`, '',
  ].join('\n'));
});

test('labels the logic fence as a logic analyser screen', () => {
  const text = '```logic\n```\n';

  assert.equal(withFigures(PATH, text), [
    '```logic', '```', '',
    `![ロジックアナライザの画面](${PAGES_URL}/01-circuits/01-basics/logic/03-rc-charge.svg)`, '',
  ].join('\n'));
});
