import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { test } from 'node:test';
import { parse } from 'yaml';
import { CJK, blobHash, compareFence, compareLines, compareYaml, parseBlocks, splitFrontMatter, unitProblems } from './en.mjs';

test('blobHash is the same as git hash-object', () => {
  const text = '---\nid: 1-1\n---\n# 1-1 LED と抵抗\n';
  const git = execFileSync('git', ['hash-object', '--stdin'], { input: text }).toString().trim();
  assert.equal(blobHash(text), git);
});

test('compareYaml lets a Japanese string become English but nothing else change', () => {
  const ja = parse('title: 図1 LED と抵抗\nparts:\n  R1: resistor 1,1 3,1 330\n');
  assert.deepEqual(compareYaml(ja, parse('title: Fig. 1 LED and resistor\nparts:\n  R1: resistor 1,1 3,1 330\n')), []);
  assert.match(compareYaml(ja, parse('title: Fig. 1 LED and resistor\nparts:\n  R1: resistor 1,1 3,1 470\n'))[0], /値が違います|日本語の題と値が違います/);
  assert.match(compareYaml(ja, parse('title: 図1 LED\nparts:\n  R1: resistor 1,1 3,1 330\n'))[0], /日本語が残っています/);
});

test('compareYaml checks notes: the key stays, only the text changes', () => {
  const ja = parse('notes:\n  - text a5: 抵抗にかかる電圧\n  - circle R1 red\n');
  assert.deepEqual(compareYaml(ja, parse('notes:\n  - text a5: voltage across the resistor\n  - circle R1 red\n')), []);
  assert.ok(compareYaml(ja, parse('notes:\n  - text a6: voltage\n  - circle R1 red\n')).length > 0);
});

test('compareLines ignores comments and lets Japanese lines change', () => {
  const ja = 'int x = 1; // カウンタ\n// 説明\nvoid f() {}\n';
  assert.deepEqual(compareLines('cpp', ja, 'int x = 1; // counter\nvoid f() {}\n'), []);
  assert.ok(compareLines('cpp', ja, 'int x = 2;\nvoid f() {}\n').length > 0);
});

test('compareLines lets a plantuml label with Japanese become English', () => {
  const ja = 'rectangle "電源" as P\nP --> Q\n';
  assert.deepEqual(compareLines('plantuml', ja, 'rectangle "Power supply" as P\nP --> Q\n'), []);
  assert.ok(compareLines('plantuml', ja, 'rectangle "電源" as P\nP --> Q\n').length > 0);
});

test('compareFence refuses a different language', () => {
  assert.match(compareFence({ lang: 'circuit', body: '' }, { lang: 'scope', body: '' })[0], /言語が違います/);
});

test('parseBlocks separates fences from prose', () => {
  const { fences, prose } = parseBlocks('a\n```circuit\nparts:\n```\nb\n');
  assert.equal(fences.length, 1);
  assert.equal(fences[0].lang, 'circuit');
  assert.deepEqual(prose.map((p) => p.text).filter(Boolean), ['a', 'b']);
});

test('unitProblems flags the unit rules and ignores inline code', () => {
  assert.deepEqual(unitProblems('Use a 10 kΩ resistor at 25 °C and 100 kHz.'), []);
  assert.ok(unitProblems('Use a 10kΩ resistor.').length > 0);
  assert.ok(unitProblems('about 25℃').length > 0);
  assert.ok(unitProblems('2 V<sub>pp</sub>').length > 0);
  assert.ok(unitProblems('a 1 V (peak) wave').length > 0);
  assert.deepEqual(unitProblems('write `10kHz` in the fence'), []);
});

test('splitFrontMatter reads the keys', () => {
  assert.equal(splitFrontMatter('---\nid: 1-1\n---\nbody\n').data.id, '1-1');
  assert.equal(splitFrontMatter('no matter'), null);
});

test('CJK finds Japanese text only', () => {
  assert.ok(CJK.test('あ'));
  assert.ok(CJK.test('、'));
  assert.ok(!CJK.test('Ω µ − °C'));
});
