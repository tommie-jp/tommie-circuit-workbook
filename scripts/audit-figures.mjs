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
 * 4. 実体配線図の線の色: 赤は + だけ・黒は − (GND) だけ (breadboard-wiring)。極性の逆挿しを見せる題は除く。
 * 5. 計器の画面 (instrument-screen): vna / spectrum は本文の数字の所にマーカー、scope はカーソルか Measure。
 *    TDR (`tdr`)・`mark` 注釈・XY 表示 (`view: xy`) は別の手段があるので除く。
 * 6. LTspice での確かめの節: 回路図 (circuit) のある題に `## LTspice での確かめ` があるか。
 *    HDL の冊 (`book: fpga`) は、Verilog のある題に `## シミュレーションでの確かめ` (iverilog・Verilator・Yosys) があるかを見る。見出しに「対象外」とあれば算術で確かめた題として別に数える。無い題は `--verbose` で一覧する。
 * 7. プログラムの確かめの節: Pico のプログラム (C・MicroPython) のある題に `## プログラムでの確かめ` があるか (docs/133)。
 * 8. 1 題の長さ: 本文のフェンスの外の字 (空白を除く) が段の上限 (`LENGTH_LIMITS`、README の「1 題の長さ」) を超えていないか。
 */
import { extractPrograms } from './pico-extract.mjs';
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

const isMinus = (e) => /^-[a-z]/i.test(e) || /\.(GND|V-|1-|2-)$/.test(e);
const isPlus = (e) => /^\+[a-z]/i.test(e) || /\.(V\+|1\+|2\+)$/.test(e);

/** 実体配線図 (breadboard / perfboard) の `wires:` で、赤が − 側・黒が + 側につながっている行。 */
export function auditWireColors(block, fileText = '') {
  if (/逆向き|逆に挿/.test(fileText)) return [];
  const start = block.findIndex((l) => /^wires:/.test(l));
  if (start < 0) return [];
  const findings = [];
  for (let i = start + 1; i < block.length; i += 1) {
    const m = /^\s+-\s+(.+?)\s+(?:--|\|-|-\|)\s+(.+?)\s+(red|black)\s*$/.exec(block[i]);
    if (!m) continue;
    const [, a, c, color] = m;
    if (color === 'red' && (isMinus(a) || isMinus(c))) findings.push({ offset: i, kind: '線の色', message: `赤が − 側につながっている: ${block[i].trim()}` });
    if (color === 'black' && (isPlus(a) || isPlus(c))) findings.push({ offset: i, kind: '線の色', message: `黒が + 側につながっている: ${block[i].trim()}` });
  }
  return findings;
}

/** 計器の画面にマーカーかカーソルがあるか。 */
export function auditInstrument(fence, block) {
  const text = block.join('\n');
  const has = (re) => re.test(text);
  if ((fence === 'vna' || fence === 'spectrum') && !has(/^markers:/m) && !has(/^\s+-\s+mark\s/m) && !has(/\btdr\b/)) {
    return [{ offset: 0, kind: '計器のマーカー', message: `${fence}: markers: が無い` }];
  }
  if (fence === 'scope' && !has(/^(cursors|measure):/m) && !has(/^view:\s*xy/m)) {
    return [{ offset: 0, kind: '計器のカーソル', message: 'scope: cursors: も measure: も無い' }];
  }
  return [];
}

/** 段ごとの本文の字数の上限 (README の「1 題の長さ」)。必須・入門 5,000 字、中級 8,000 字、発展 12,000 字。 */
export const LENGTH_LIMITS = { 50: 5000, 100: 5000, 200: 8000, 300: 12000 };

/** 本文の字数。front matter とフェンス (``` で囲んだ所) と画像の行を除き、空白を数えない。 */
export function proseLength(text) {
  const body = text.replace(/^---\n[\s\S]*?\n---\n/, '');
  const prose = body.replace(/^```[^\n]*\n[\s\S]*?^```\s*$/gm, '').replace(/^!\[.*$/gm, '');
  return prose.replace(/\s/g, '').length;
}

/** 上限を超えていれば `{ length, limit }`、収まっていれば null。段の分からない題は見ない。 */
export function lengthOver(text, tier) {
  const limit = LENGTH_LIMITS[tier];
  if (limit === undefined) return null;
  const length = proseLength(text);
  return length > limit ? { length, limit } : null;
}

/** 回路図のある題の LTspice 節の状態: 'checked' | 'excluded' | 'missing'。回路図が無ければ null。 */
export function ltspiceStatus(text) {
  const isHdl = /^book:\s*fpga\s*$/m.test(text);
  if (isHdl ? !/^```verilog\s*$/m.test(text) : !/^```circuit\s*$/m.test(text)) return null;
  const heading = (isHdl ? /^#{2,3}\s+シミュレーションでの確かめ.*$/m : /^#{2,3}\s+LTspice.*$/m).exec(text);
  if (!heading) return 'missing';
  return /対象外/.test(heading[0]) ? 'excluded' : 'checked';
}

/**
 * Pico のプログラム (C か MicroPython) のある題の確かめの節の状態: 'checked' | 'excluded' | 'missing'。
 * `## プログラムの確かめ` (docs/133)。FPGA の冊は `## シミュレーションでの確かめ` でもよい (Verilator と picoemu で確かめた題)。
 * プログラムが無ければ null。
 */
export function programStatus(text) {
  if (extractPrograms(text).length === 0) return null;
  const isHdl = /^book:\s*fpga\s*$/m.test(text);
  const heading = (isHdl ? /^#{2,3}\s+(?:プログラム|シミュレーション)での確かめ.*$/m : /^#{2,3}\s+プログラムでの確かめ.*$/m).exec(text);
  if (!heading) return 'missing';
  return /対象外/.test(heading[0]) ? 'excluded' : 'checked';
}

function main(args) {
  const verbose = args.includes('--verbose');
  const tally = new Map();
  const ltspice = { checked: 0, excluded: 0, missing: 0 };
  const program = { checked: 0, excluded: 0, missing: 0 };
  for (const read of readEntries()) {
    const status = ltspiceStatus(read.text);
    if (status) {
      ltspice[status] += 1;
      if (verbose && status === 'missing') console.log(`${read.path}: [LTspice 未確認]`);
    }
    const pstatus = programStatus(read.text);
    if (pstatus) {
      program[pstatus] += 1;
      if (verbose && pstatus === 'missing') console.log(`${read.path}: [プログラム未確認]`);
    }
    const over = read.entry ? lengthOver(read.text, read.entry.tier) : null;
    if (over) {
      tally.set('題の長さ', (tally.get('題の長さ') ?? 0) + 1);
      if (verbose) console.log(`${read.path}: [題の長さ] 本文 ${over.length} 字 (上限 ${over.limit} 字)。題を分ける`);
    }
    const lines = read.text.split('\n');
    const { blocks } = fencesIn(read.text);
    for (const block of blocks) {
      if (block.close === null) continue;
      const body = lines.slice(block.open + 1, block.close);
      const found = [
        ...(block.fence === 'circuit' ? auditCircuitText(body, read.text) : []),
        ...(block.fence === 'breadboard' || block.fence === 'perfboard' ? auditWireColors(body, read.text) : []),
        ...auditInstrument(block.fence, body),
      ];
      for (const f of found) {
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
  console.log(`確かめの節 (回路図・Verilog のある題): 確認済み ${ltspice.checked} 題・対象外 ${ltspice.excluded} 題・未確認 ${ltspice.missing} 題`);
  console.log(`プログラムの確かめの節 (Pico のプログラムのある題): 確認済み ${program.checked} 題・対象外 ${program.excluded} 題・未確認 ${program.missing} 題`);
  for (const [kind, count] of tally) console.log(`${kind}: ${count} 件`);
  if (tally.size === 0) console.log('指摘なし');
}

if (import.meta.url === `file://${process.argv[1]}`) main(process.argv.slice(2));
