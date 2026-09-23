/**
 * 題のファイルが使うフェンスと、それを描く道具の所在。
 *
 * **フェンス名の書き間違いはここで拾う。** `bread` や `perf` と書くと、
 * 3 つの道具はどれも黙って素通りし、検査が「通った」ことになるため。
 */

import { existsSync } from 'node:fs';
import { join } from 'node:path';

export const FENCES = ['circuit', 'breadboard', 'perfboard'];

/** フェンスの道具 (`dist/cli.cjs`)。依存に入れた tgz の中にある。 */
export function cliPath(root, fence) {
  const path = join(root, 'node_modules', `${fence}-fence`, 'dist', 'cli.cjs');
  if (!existsSync(path)) throw new Error(`${fence}-fence が入っていません (npm ci を回す)`);
  return path;
}

/** 2 つの綴りの編集距離 (1 文字の足し・消し・置き換えを 1 と数える)。 */
function distance(a, b) {
  let previous = Array.from({ length: b.length + 1 }, (_, index) => index);
  for (let i = 1; i <= a.length; i += 1) {
    const current = [i];
    for (let j = 1; j <= b.length; j += 1) {
      current[j] = Math.min(previous[j] + 1, current[j - 1] + 1, previous[j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1));
    }
    previous = current;
  }
  return previous[b.length];
}

/**
 * 3 つのどれかを書こうとした名前。**頭の 4 文字以上が合う** (`bread` `perf`) か、
 * **2 文字以内の違い** (`breadbord` `Circuit`)。`circuitikz` のような別の言語は外れる。
 */
const MIN_PREFIX = 4;
const MAX_DISTANCE = 2;
const looksLikeFence = (name) => {
  const lower = name.toLowerCase();
  return FENCES.some((fence) =>
    (lower.length >= MIN_PREFIX && fence.startsWith(lower)) || distance(lower, fence) <= MAX_DISTANCE);
};

/**
 * フェンスの開き・閉じ。**道具と同じく CommonMark の規則で数える** — 行頭 3 字までの
 * 字下げ、3 本以上のバッククォートかチルダ、言語名の後ろの語。これより狭く拾うと、
 * 道具が図にするフェンスを検査に回し損ね、壊れた図が CI を通る。
 */
const FENCE_LINE = /^ {0,3}(`{3,}|~{3,})(.*)$/;

/**
 * @returns {{ found: Set<string>, misspelled: { name: string, line: number }[] }}
 */
export function fencesIn(text) {
  const found = new Set();
  const misspelled = [];
  /** 開いているフェンスの字と本数。閉じるのは同じ字で同じ本数以上、後ろに何も無い行。 */
  let open = null;

  text.split('\n').forEach((line, index) => {
    const match = FENCE_LINE.exec(line);
    if (open !== null) {
      if (match !== null && match[1][0] === open.char && match[1].length >= open.length && match[2].trim() === '') {
        open = null;
      }
      return;
    }
    if (match === null) return;

    const info = match[2].trim();
    // バッククォートのフェンスは、言語名の欄にバッククォートを含めない (CommonMark)。
    if (match[1][0] === '`' && info.includes('`')) return;
    open = { char: match[1][0], length: match[1].length };

    const name = info.split(/\s+/)[0];
    if (FENCES.includes(name)) found.add(name);
    else if (name !== '' && looksLikeFence(name)) misspelled.push({ name, line: index + 1 });
  });

  return { found, misspelled };
}
