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
    '# t', '', '```circuit', '# 回路図 (tommie-fence の circuit フェンス)', 'parts:', '```', '',
    `![回路図](${PAGES_URL}/01-circuits/01-basics/circuit/03-rc-charge.svg)`, '',
    '```text', '```', '', '```bread', '# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)', '```', '',
    `![ブレッドボードの実体配線図](${PAGES_URL}/01-circuits/01-basics/breadboard/03-rc-charge.svg)`, '',
    'end', '',
  ].join('\n'));
});

test('rewriting twice changes nothing, and stale lines are replaced', () => {
  const once = withFigures(PATH, '```circuit\n```\n\ntext\n');
  assert.equal(withFigures(PATH, once), once);

  const moved = `${once}\n\`\`\`circuit\n\`\`\`\n`;
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
    '```copper', '# 銅張り基板の寸法図 (tommie-fence の copper フェンス)', '```', '',
    `![銅張り基板の寸法図](${PAGES_URL}/01-circuits/01-basics/copper/03-rc-charge.svg)`, '',
  ].join('\n'));
});

test('labels the logic fence as a logic analyser screen', () => {
  const text = '```logic\n```\n';

  assert.equal(withFigures(PATH, text), [
    '```logic', '# ロジックアナライザの画面 (tommie-fence の logic フェンス)', '```', '',
    `![ロジックアナライザの画面](${PAGES_URL}/01-circuits/01-basics/logic/03-rc-charge.svg)`, '',
  ].join('\n'));
});

test('writes a name comment on the first line of each fence, in the spelling the fence uses', () => {
  const once = withFigures(PATH, '```bread\ntitle: a\n```\n\n- x\n\n  ```circuit\n  title: b\n  ```\n');

  assert.match(once, /```bread\n# ブレッドボードの実体配線図 \(tommie-fence の bread フェンス\)\ntitle: a/);
  assert.match(once, /  ```circuit\n  # 回路図 \(tommie-fence の circuit フェンス\)\n  title: b/);
  assert.equal(withFigures(PATH, once), once);
});

test('rewrites a stale name comment, keeps the author comment, and skips plantuml', () => {
  const stale = '```scope\n# 古い名 (tommie-fence の scope フェンス)\n# 書き手の注\ntitle: a\n```\n';
  const fixed = withFigures(PATH, stale);

  assert.match(fixed, /```scope\n# オシロスコープの画面 \(tommie-fence の scope フェンス\)\n# 書き手の注\ntitle: a/);
  assert.doesNotMatch(fixed, /古い名/);
  assert.doesNotMatch(withFigures(PATH, '```plantuml\n@startuml\n```\n'), /tommie-fence の/);
});

test('English entries get English labels and figures under en/', () => {
  const path = `en/${PATH}`;
  const text = '# t\n\n```circuit\nparts:\n```\n\n```scope\n```\n';

  const written = withFigures(path, text);

  assert.equal(written, [
    '# t', '', '```circuit', '# Schematic (tommie-fence circuit fence)', 'parts:', '```', '',
    `![Schematic](${PAGES_URL}/en/01-circuits/01-basics/circuit/03-rc-charge.svg)`, '',
    '```scope', '# Oscilloscope screen (tommie-fence scope fence)', '```', '',
    `![Oscilloscope screen](${PAGES_URL}/en/01-circuits/01-basics/scope/03-rc-charge.svg)`, '',
  ].join('\n'));
  assert.equal(withFigures(path, written), written);
});
