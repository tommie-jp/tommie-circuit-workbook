import assert from 'node:assert/strict';
import { test } from 'node:test';
import { auditCircuitText, inSeries, parseValue } from './audit-figures.mjs';

test('parses engineering suffixes and infix notation', () => {
  assert.equal(parseValue('4k7'), 4700);
  assert.equal(parseValue('0.33u'), 0.33e-6);
  assert.equal(parseValue('680'), 680);
  assert.equal(parseValue('abc'), null);
});

test('E24 membership', () => {
  assert.equal(inSeries(4700, [4.7]), true);
  assert.equal(inSeries(400, [1.0, 4.7]), false);
});

test('flags a vcc symbol without voltage and a value outside E24', () => {
  const found = auditCircuitText(['  VCC: vcc a1', '  R1: resistor a1 a3 400', '  R2: resistor a1 a3 4.7k']);
  assert.deepEqual(found.map((f) => f.kind), ['電源記号', 'E系列']);
});

test('does not flag 50 ohm or documented two-part values', () => {
  assert.equal(auditCircuitText(['  R1: resistor a1 a3 50']).length, 0);
  assert.equal(auditCircuitText(['  R1: resistor a1 a3 400'], '200 Ω を 2 本直列').length, 0);
});
