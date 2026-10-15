import { test } from 'node:test';
import assert from 'node:assert/strict';
import { blocks, extractPrograms } from './pico-extract.mjs';

const md = (s) => s.replaceAll("'''", '```');

test('Pico SDK の C と machine の MicroPython を取り出す', () => {
  const text = md(`
'''c
#include "pico/stdlib.h"
int main(void) { return 0; }
'''

'''python
from machine import Pin
'''
`);
  const got = extractPrograms(text);
  assert.deepEqual(got.map((p) => `${p.n}.${p.ext}`), ['1.c', '1.py']);
});

test('Pico の include の無い C・PC 用の cpp は取り出さない', () => {
  const text = md(`
'''c
#include <stdio.h>
int main(void) { return 0; }
'''
`);
  assert.equal(extractPrograms(text).length, 0);
});

test('program: skip の印のブロックは取り出さない', () => {
  const text = md(`
<!-- program: skip -->
'''c
#include "pico/stdlib.h"
int main(void) { return 0; }
'''
`);
  assert.equal(extractPrograms(text).length, 0);
  assert.equal(blocks(text).length, 1);
});

test('machine を使わない python は取り出さない', () => {
  assert.equal(extractPrograms(md("'''python\nprint(1)\n'''\n")).length, 0);
});
