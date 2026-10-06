/**
 * 図の点検表のうち、機械で当てられる項目 (readable-schematic の #13・#14 など)。
 * check と違い、つながりではなく「読み手が組める・読める図か」を見る。**言うだけで落とさない**
 * (件数の目安を出す。直したら件数が減る)。
 *
 *   node scripts/audit-figures.mjs [--verbose]
 *
 * 1. 部品の値が買える値か: 抵抗は E24、コンデンサ・インダクタは E12 を優先 (電解 `ecap` は E6)。
 * 2. 電源の記号 (`vcc` / `vee`) に符号付きの電圧が書いてあるか。
 * 3. 本文・図の字で IC のピンを「足 14」と書いていないか (`PIN 14` と書く)。
 */
import { readEntries } from './collect.mjs';
import { fencesIn } from './fences.mjs';

const E24 = [1.0, 1.1, 1.2, 1.3, 1.5, 1.6, 1.8, 2.0, 2.2, 2.4, 2.7, 3.0, 3.3, 3.6, 3.9, 4.3, 4.7, 5.1, 5.6, 6.2, 6.8, 7.5, 8.2, 9.1];
const E12 = [1.0, 1.2, 1.5, 1.8, 2.2, 2.7, 3.3, 3.9, 4.7, 5.6, 6.8, 8.2];
const E6 = [1.0, 1.5, 2.2, 3.3, 4.7, 6.8];
const SERIES = { resistor: ['E24', E24], capacitor: ['E12', E12], inductor: ['E12', E12], ecap: ['E6', E6] };
const MULT = { p: 1e-12, n: 1e-9, u: 1e-6, 'µ': 1e-6, m: 1e-3, k: 1e3, K: 1e3, M: 1e6, G: 1e9 };

/** "4k7" "0.33u" "680" "10nF" → 数。読めなければ null。 */
export function parseValue(raw) {
  const text = raw.replace(/(Ω|ohm|F|H)$/i, '');
  const infix = /^(\d+)([pnuµmkKMG])(\d+)$/.exec(text);
  if (infix) return Number(`${infix[1]}.${infix[3]}`) * MULT[infix[2]];
  const plain = /^(\d+(?:\.\d+)?)([pnuµmkKMG]?)$/.exec(text);
  return plain ? Number(plain[1]) * (MULT[plain[2]] ?? 1) : null;
}

export function inSeries(value, series) {
  if (value === 0) return true;
  const mantissa = value / 10 ** Math.floor(Math.log10(value) + 1e-9);
  return series.some((e) => Math.abs(e - mantissa) / e < 0.005);
}

/** 特性インピーダンス・負荷の定格 (50 Ω・75 Ω・8 Ω) と、等価回路・手巻き・2 本で作る旨の書いてある題は、系列の外でよい。 */
const EXEMPT_OHMS = new Set([8, 50, 75]);
const EXEMPT_TEXT = /(2 本|2 個|直列で|並列で|手巻|等価|寄生|浮遊|モデル|巻き数|巻いた|9-\d と同じ)/;

export function auditCircuitText(block, fileText = '') {
  const findings = [];
  for (const [offset, line] of block.entries()) {
    const part = /^\s+(\w+):\s+(resistor|capacitor|inductor|ecap)\s+(.*)$/.exec(line);
    if (part) {
      const [, id, kind, rest] = part;
      const tokens = rest.trim().split(/\s+/);
      const raw = tokens.slice(2).find((t) => parseValue(t) !== null);
      const number = raw === undefined ? null : parseValue(raw);
      const [name, series] = SERIES[kind];
      if (number !== null && !inSeries(number, series) && !(kind === 'resistor' && EXEMPT_OHMS.has(number)) && !/\bl=/.test(rest) && !EXEMPT_TEXT.test(fileText)) findings.push({ offset, kind: 'E系列', message: `${id}: ${kind} ${raw} は ${name} に無い値 ` });
    }
    const power = /^\s+(\w+):\s+(vcc|vee)\s+\S+(.*)$/.exec(line);
    if (power && !/\d/.test(power[3])) findings.push({ offset, kind: '電源記号', message: `${power[1]}: ${power[2]} に電圧が書かれていない` });
  }
  return findings;
}

function main(args) {
  const verbose = args.includes('--verbose');
  const tally = new Map();
  for (const read of readEntries()) {
    const lines = read.text.split('\n');
    const { blocks } = fencesIn(read.text);
    for (const block of blocks) {
      if (block.fence !== 'circuit' || block.close === null) continue;
      for (const f of auditCircuitText(lines.slice(block.open + 1, block.close), read.text)) {
        tally.set(f.kind, (tally.get(f.kind) ?? 0) + 1);
        if (verbose) console.log(`${read.path}:${block.open + 2 + f.offset}: [${f.kind}] ${f.message}`);
      }
    }
    lines.forEach((line, index) => {
      if (/足 ?\d+(?![\d.]*\s*(?:cm|mm|V|Ω))/.test(line) && /(足\s*\d+\s*(番|・|→|と|を|へ|は|が|に))/.test(line)) {
        tally.set('足の番号', (tally.get('足の番号') ?? 0) + 1);
        if (verbose) console.log(`${read.path}:${index + 1}: [足の番号] ${line.trim().slice(0, 80)}`);
      }
    });
  }
  for (const [kind, count] of tally) console.log(`${kind}: ${count} 件`);
  if (tally.size === 0) console.log('指摘なし');
}

if (import.meta.url === `file://${process.argv[1]}`) main(process.argv.slice(2));
