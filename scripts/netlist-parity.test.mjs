import { test } from 'node:test';
import assert from 'node:assert/strict';
import { compareDiagrams, judge, parseCheckOutput, pairBoards } from './netlist-parity.mjs';

/** check の出力から図を 1 枚作る (ネットの行だけ見る)。 */
const diagram = (kind, title, lines) => ({ kind, title, ...parseCheckOutput(`x (1 行目)\n  ネットリスト:\n${lines.map((l) => `    ${l}`).join('\n')}\n`)[0] });

// 912008b^ の 05-etc/03-mixer-dual-gate-fet/01-mixer.md から抜いた、取り違えのある組。
const MIXER_CIRCUIT = diagram('circuit', '図1 ミキサ', [
  'VDD : VDD, C6.1, C7.1, R4.1, R2.1, L1.1, C3.1',
  'GND : C6.2, C7.2, R5.2, R3.2, R1.2, VR1.2, R7.2, C5.2, G1, FL1.GND, U1.source',
  'N1  : R4.2, R5.1, C2.2, U1.G2',
  'LO  : LO, R3.1, C2.1',
  'RF  : RF, R1.1, C1.1',
  'N2  : C1.2, R2.2, R6.1, U1.G1',
  'N3  : R6.2, VR1.1',
  'N4  : L1.2, C3.2, C4.1, U1.drain',
  'N5  : C4.2, R7.1, FL1.IN',
  'N6  : C5.1, L2.1, FL1.OUT',
  'IF  : L2.2, IF',
]);
const MIXER_BOARD = diagram('breadboard', '図2 ブレッドボード', [
  'N1    : U1.G1, R2.1, R6.1, C1.2',
  'N2    : U1.G2, R4.2, R5.1, C2.2',
  'N3    : U1.D, C3.1, L1.1, C4.1',
  '-t/-b : U1.S, VR1.1, VR1.2, R1.2, R7.2, FL1.OUT, C5.2, R8.2, R5.2, R3.2, C6.2, C7.2, AD.GND',
  '+t/+b : R2.2, C3.2, L1.2, R4.1, C6.1, C7.1, AD.V+',
  'N4    : R6.2, VR1.3',
  'N5    : C1.1, R1.1, AD.W1',
  'N6    : C4.2, R7.1, FL1.IN',
  'N7    : FL1.GND',
  'N8    : C5.1, L2.1',
  'N9    : L2.2, R8.1, AD.1+',
  'N10   : C2.1, R3.1, AD.W2, AD.2+',
]);

test('reads each fence of the check output with its line', () => {
  const out = 'a (3 行目): 読めました\n  ネットリスト:\n    N1 : R1.1, C1.2, AD.W1\n    GND : R1.2\nb (9 行目)\n  ネットリスト:\n    N1 : U1.1\n';

  const read = parseCheckOutput(out);

  assert.deepEqual(read.map((d) => d.line), [3, 9]);
  assert.deepEqual(read[0].nets, [['R1', 'C1', 'AD'], ['R1']]);
});

test('a matching pair has no difference', () => {
  const circuit = diagram('circuit', 'c', ['IN : W1, R1.1', 'OUT : R1.2, C1.1', 'GND : C1.2, GND']);
  const board = diagram('breadboard', 'b', ['N1 : R1.2, C1.1, AD.1+', 'N2 : C1.2, AD.GND', 'N3 : R1.1, AD.W1']);

  const { onlyCircuit, onlyBoard } = compareDiagrams(circuit, board);

  assert.deepEqual([onlyCircuit, onlyBoard], [[], []]);
});

test('finds the swapped SIP3 legs of the mixer', () => {
  const { onlyCircuit, onlyBoard } = compareDiagrams(MIXER_CIRCUIT, MIXER_BOARD);

  assert.deepEqual(onlyCircuit, ['C5,FL1,L2']);
  assert.deepEqual(onlyBoard, ['C5,L2']);
});

test('ignores supply pins that only one drawing gives an IC', () => {
  const circuit = diagram('circuit', 'c', ['IN : U1.in+, R1.1', 'OUT : U1.out, U1.in-, R2.1', 'GND : R1.2, R2.2, GND']);
  const board = diagram('breadboard', 'b', [
    'N1 : U1.3, R1.1', 'N2 : U1.1, U1.2, R2.1', 'GND : R1.2, R2.2, U1.4', 'VCC : U1.8, C1.1', 'N3 : C1.2',
  ]);

  const { onlyCircuit, onlyBoard } = compareDiagrams(circuit, board);

  assert.deepEqual([onlyCircuit, onlyBoard], [[], []]);
});

test('pairs a board with the circuit sharing most parts, then most matching nets', () => {
  const near = diagram('circuit', 'near', ['A : R1.2, C1.1', 'B : C1.2, R2.1', 'C : R2.2, R3.1']);
  const far = diagram('circuit', 'far', ['A : R1.2, R2.1', 'B : R2.2, C1.1', 'C : C1.2, R3.1']);
  const board = diagram('breadboard', 'b', ['N1 : R1.2, C1.1', 'N2 : C1.2, R2.1', 'N3 : R2.2, R3.1']);

  const [pair] = pairBoards([far, near, board]);

  assert.equal(pair.circuit.title, 'near');
});

test('allowed mismatches pass, new ones fail, stale permits are reported', () => {
  const results = [
    { file: 'a.md', board: '図2', circuit: '図1', onlyCircuit: ['R1,R2'], onlyBoard: [] },
    { file: 'b.md', board: '図2', circuit: '図1', onlyCircuit: [], onlyBoard: [] },
    { file: 'c.md', board: '図3', circuit: '図1', onlyCircuit: [], onlyBoard: ['C1,U1'] },
  ];
  const allow = [
    { file: 'a.md', board: '図2', reason: '電流計の隙間' },
    { file: 'b.md', board: '図2', reason: 'もう直った' },
    { file: 'gone.md', board: '図9', reason: '消えた題' },
  ];

  const { failures, stale } = judge(results, allow);

  assert.deepEqual(failures.map((r) => r.file), ['c.md']);
  assert.deepEqual(stale.map((a) => a.file), ['b.md', 'gone.md']);
});

test('treats an ammeter drawn only in the circuit as a wire', () => {
  const circuit = diagram('circuit', 'c', ['N1 : E1.1, R1.1', 'N2 : R1.2, A1.1', 'N3 : A1.2, R2.1', 'GND : R2.2, E1.2']);
  const board = diagram('breadboard', 'b', ['N1 : E1.1, R1.1', 'N2 : R1.2, R2.1', 'N3 : R2.2, E1.2']);

  const { onlyCircuit, onlyBoard } = compareDiagrams(circuit, board);

  assert.deepEqual([onlyCircuit, onlyBoard], [[], []]);
});
