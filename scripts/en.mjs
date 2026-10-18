/**
 * 英語版 (`en/`) の検査の部品。`en-check.mjs` が使う。
 *
 * 日本語の題が原本で、英語は訳。**訳しても変わってはいけない物** (front matter の鍵と値・フェンスの
 * 部品と値と番地・コード) と、**訳すと変わる物** (題・図の題と注釈・コメント・本文) を分けて見る。
 */

import { createHash } from 'node:crypto';
import { parse } from 'yaml';

/** 日本語の字 (かな・漢字・全角の記号と英数)。英語版の本文に残ってはいけない。 */
export const CJK = /[　-ヿ㐀-鿿＀-￯]/;

const FRONT_MATTER = /^---\n([\s\S]*?)\n---\n/;

/** 図になるフェンス。中身は YAML で、訳すのは題・注釈などの文字だけ。 */
export const YAML_FENCES = new Set(['circuit', 'breadboard', 'bread', 'perfboard', 'perf', 'copper', 'vna', 'scope', 'spectrum', 'graph', 'logic']);

/** git の blob の hash (`git hash-object <file>` と同じ)。`ja:` に書く。 */
export function blobHash(text) {
  const body = Buffer.from(text, 'utf8');
  return createHash('sha1').update(`blob ${body.length}\0`).update(body).digest('hex');
}

/** front matter と本文に分ける。無ければ null。 */
export function splitFrontMatter(text) {
  const matter = FRONT_MATTER.exec(text);
  if (matter === null) return null;
  let data;
  try {
    data = parse(matter[1]);
  } catch (error) {
    return { data: null, body: text.slice(matter[0].length), error: error.message.split('\n')[0] };
  }
  return { data, body: text.slice(matter[0].length), error: null };
}

/**
 * 本文のフェンスを全部。`{ lang, body, line }` (line は開きの行番号、1 始まり)。
 * フェンスの外の行は `prose` に (行番号つき)。
 */
export function parseBlocks(text) {
  const lines = text.split('\n');
  const fences = [];
  const prose = [];
  let open = null;
  lines.forEach((line, index) => {
    const marker = /^ {0,3}(`{3,}|~{3,}) *([\w+-]*)/.exec(line);
    if (open === null) {
      if (marker) open = { char: marker[1][0], size: marker[1].length, lang: marker[2], body: [], line: index + 1 };
      else prose.push({ text: line, line: index + 1 });
      return;
    }
    if (marker && marker[1][0] === open.char && marker[1].length >= open.size && marker[2] === '') {
      fences.push({ lang: open.lang, body: open.body.join('\n'), line: open.line });
      open = null;
    } else {
      open.body.push(line);
    }
  });
  if (open !== null) fences.push({ lang: open.lang, body: open.body.join('\n'), line: open.line, unclosed: true });
  return { fences, prose };
}

/** コメントを落とす。言語ごとの綴り。文字列の中の `//` までは見ない (近似)。 */
export function stripComments(lang, body) {
  const slash = ['verilog', 'systemverilog', 'v', 'sv', 'c', 'cpp', 'c++', 'h', 'hpp', 'java', 'js', 'javascript', 'ts', 'typescript', 'rust'];
  const hash = ['python', 'py', 'bash', 'sh', 'shell', 'yaml', 'yml', 'cmake', 'make', 'toml'];
  let text = body;
  if (slash.includes(lang)) text = text.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/.*$/gm, '');
  else if (hash.includes(lang)) text = text.replace(/(^|\s)#.*$/gm, '$1');
  return text.split('\n').map((line) => line.trimEnd()).filter((line) => line.trim() !== '');
}

/**
 * 日本語と英語の YAML を並べて見る。日本語の側で字が日本語の文字列は英語に置き換わってよい
 * (ただし日本語の字は残さない)。それ以外の値は同じでなければならない。
 * @returns {string[]} 食い違い (空なら同じ)
 */
export function compareYaml(ja, en, path = '') {
  const errors = [];
  const here = path === '' ? '(top)' : path;
  if (typeof ja === 'string') {
    if (typeof en !== 'string') return [`${here}: 文字列でなければなりません`];
    if (CJK.test(ja)) {
      if (CJK.test(en)) errors.push(`${here}: 日本語が残っています (${en.slice(0, 40)})`);
    } else if (ja !== en) {
      errors.push(`${here}: 日本語の題と値が違います (日本語 "${ja}" / 英語 "${en}")`);
    }
    return errors;
  }
  if (Array.isArray(ja)) {
    if (!Array.isArray(en) || ja.length !== en.length) return [`${here}: 並びの長さが違います`];
    ja.forEach((item, index) => errors.push(...compareYaml(item, en[index], `${path}[${index}]`)));
    return errors;
  }
  if (ja !== null && typeof ja === 'object') {
    if (en === null || typeof en !== 'object' || Array.isArray(en)) return [`${here}: 鍵と値の並びでなければなりません`];
    const jaKeys = Object.keys(ja);
    const enKeys = Object.keys(en);
    if (jaKeys.length !== enKeys.length) return [`${here}: 鍵の数が違います (${jaKeys.join(', ')} / ${enKeys.join(', ')})`];
    jaKeys.forEach((key, index) => {
      const enKey = enKeys[index];
      if (CJK.test(key)) {
        if (CJK.test(enKey)) errors.push(`${here}: 鍵に日本語が残っています (${enKey})`);
      } else if (key !== enKey) {
        errors.push(`${here}: 鍵が違います (${key} / ${enKey})`);
      }
      errors.push(...compareYaml(ja[key], en[enKey], `${path}.${key}`));
    });
    return errors;
  }
  return ja === en ? [] : [`${here}: 値が違います (${String(ja)} / ${String(en)})`];
}

/**
 * 図以外のフェンス (コード・出力・plantuml) を行ごとに並べて見る。コメントは落とす。
 * 日本語の字を含む行は、英語の側で別の字に替わってよい (日本語は残さない)。
 */
export function compareLines(lang, ja, en) {
  const a = stripComments(lang, ja);
  const b = stripComments(lang, en);
  if (a.length !== b.length) return [`行の数が違います (日本語 ${a.length} 行 / 英語 ${b.length} 行。コメントを除く)`];
  const errors = [];
  a.forEach((line, index) => {
    if (CJK.test(line)) {
      if (CJK.test(b[index])) errors.push(`日本語が残っています: ${b[index].trim().slice(0, 50)}`);
    } else if (line.trim() !== b[index].trim()) {
      errors.push(`コードが違います: "${line.trim().slice(0, 50)}" / "${b[index].trim().slice(0, 50)}"`);
    }
  });
  return errors;
}

/** 1 組のフェンス (日本語・英語) の食い違い。 */
export function compareFence(ja, en) {
  if (ja.lang !== en.lang) return [`フェンスの言語が違います (${ja.lang} / ${en.lang})`];
  if (YAML_FENCES.has(ja.lang)) {
    let a;
    let b;
    try {
      a = parse(ja.body);
      b = parse(en.body);
    } catch (error) {
      return [`YAML が読めません: ${error.message.split('\n')[0]}`];
    }
    return compareYaml(a, b);
  }
  return compareLines(ja.lang, ja.body, en.body);
}

const UNIT = String.raw`(?:[kMGmµnp]?Ω|[kMG]?Hz|[mkµ]?V(?:pp|rms)?|[mµ]A|[pnµm]F|[nµm]H|[mµn]?s|[mµnk]?W|dBm?)`;
const NO_SPACE = new RegExp(String.raw`(?<![\w.])\d+(?:\.\d+)?${UNIT}(?![A-Za-z<µ\d])`);

/** 単位の書き方 (README の「単位の書き方」)。インラインコードとリンク先は見ない。 */
export function unitProblems(line) {
  const text = line.replace(/`[^`]*`/g, '').replace(/\]\([^)]*\)/g, '');
  const found = [];
  if (NO_SPACE.test(text)) found.push('数と単位の間に空白を 1 つ (10 kΩ)');
  if (/μ/.test(text)) found.push('μ (U+03BC) でなく µ (U+00B5)');
  if (/℃/.test(text)) found.push('℃ でなく °C');
  if (/V<sub>pp<\/sub>/.test(text)) found.push('V<sub>pp</sub> でなく Vpp');
  if (/\d ?us\b/.test(text)) found.push('us でなく µs');
  if (/\d ?m?V ?\((?:0-)?peak\)|\d ?m?V peak\b/.test(text)) found.push('(peak) でなく V<sub>p</sub>');
  return found;
}
