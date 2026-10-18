/**
 * 英語版 (`en/`) の検査。日本語の題が原本で、英語は訳。
 *
 *   node scripts/en-check.mjs                 en/ の題を全部検査する (エラーがあれば 1 で終わる)
 *   node scripts/en-check.mjs <path> …        指した題だけ
 *   node scripts/en-check.mjs --stale         訳が古い題と、まだ訳していない題の一覧 (落とさない)
 *
 * 見るもの (決めは en/GLOSSARY.md):
 * - 日本語の題が同じ置き場にある。front matter の鍵と値は `title` と `ja` 以外が同じ
 * - `ja:` が日本語の題の今の blob hash と合う (違えば **警告**。落とさない)
 * - 本文の最初の見出しが `# <id> <title>`。英語の題に日本語の字が無い
 * - フェンスの並びと中身 (部品・値・番地・コード) が日本語と同じ。訳してよいのは題・注釈・コメントだけ
 * - 本文に日本語の字が残っていない (「Sources」の節は書名のために許す)
 * - 単位の書き方 (README の「単位の書き方」)
 * - 題どうしのリンクの先がある (英語か、無ければ日本語の題)
 * - 図のフェンスを各フェンスの CLI の `check` に掛ける (`title:` の長さ・綴りなど。日本語の題と同じ検査)
 */

import { spawnSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { dirname, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { BOOKS } from './books.mjs';
import { FENCES, cliPath, fencesIn } from './fences.mjs';
import { CJK, blobHash, compareFence, parseBlocks, splitFrontMatter, unitProblems } from './en.mjs';

const ROOT = fileURLToPath(new URL('..', import.meta.url));
const EN = 'en';
/** 訳さない冊 (docs/134)。 */
const SKIPPED_BOOKS = new Set(['04-denken']);
/** 本文に日本語を残してよい節の見出し (書名・出典)。 */
const JAPANESE_OK_SECTIONS = new Set(['Sources']);

function walk(dir) {
  let names;
  try {
    names = readdirSync(dir);
  } catch {
    return [];
  }
  return names.flatMap((name) => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? walk(path) : [path];
  });
}

const isEntry = (path) => path.endsWith('.md') && !/\/(README|GLOSSARY)\.md$/.test(path);

/** `en/` の題のパス (リポジトリ直下から)。 */
export function listEnglish(root = ROOT) {
  return walk(join(root, EN)).map((path) => relative(root, path).split(sep).join('/')).filter(isEntry).sort();
}

/** 訳す対象の日本語の題のパス。 */
export function listJapanese(root = ROOT) {
  return BOOKS.filter((book) => !SKIPPED_BOOKS.has(book.dir))
    .flatMap((book) => walk(join(root, book.dir)))
    .map((path) => relative(root, path).split(sep).join('/'))
    .filter(isEntry)
    .sort();
}

const jaPathOf = (enPath) => enPath.slice(EN.length + 1);

/** 1 題の検査。`{ errors, warnings }`。 */
export function checkEntry(enPath, root = ROOT) {
  const errors = [];
  const warnings = [];
  const jaPath = jaPathOf(enPath);
  if (!existsSync(join(root, jaPath))) return { errors: [`日本語の題 ${jaPath} がありません`], warnings };

  const jaText = readFileSync(join(root, jaPath), 'utf8');
  const enText = readFileSync(join(root, enPath), 'utf8');
  const ja = splitFrontMatter(jaText);
  const en = splitFrontMatter(enText);
  if (ja === null || ja.data === null) return { errors: ['日本語の題の front matter が読めません'], warnings };
  if (en === null) return { errors: ['front matter (--- で囲んだ YAML) が先頭にありません'], warnings };
  if (en.data === null) return { errors: [`front matter の YAML が読めません: ${en.error}`], warnings };

  checkFrontMatter(ja.data, en.data, jaText, errors, warnings);
  checkBody(ja.body, en.body, en.data, errors, root, enPath);
  return { errors, warnings };
}

function checkFrontMatter(ja, en, jaText, errors, warnings) {
  const keys = new Set([...Object.keys(ja), 'ja']);
  for (const key of Object.keys(en)) if (!keys.has(key)) errors.push(`front matter に日本語の題に無い鍵があります: ${key}`);
  for (const key of Object.keys(ja)) {
    if (key === 'title') continue;
    if (JSON.stringify(ja[key]) !== JSON.stringify(en[key])) errors.push(`front matter の ${key} が日本語の題と違います (${JSON.stringify(ja[key])} / ${JSON.stringify(en[key])})`);
  }
  if (typeof en.title !== 'string' || en.title.trim() === '') errors.push('title (英語) を書きます');
  else if (CJK.test(en.title)) errors.push('title に日本語が残っています');

  if (typeof en.ja !== 'string') errors.push('ja: <日本語の題の blob hash> を書きます (git hash-object <日本語の題>)');
  else if (en.ja !== blobHash(jaText)) warnings.push('日本語の題が訳したあとに変わっています (ja: の hash が古い)');
}

function checkBody(jaBody, enBody, data, errors, root, enPath) {
  const first = enBody.split('\n').find((line) => line.trim() !== '');
  const expected = `# ${data.id} ${data.title}`;
  if (first !== expected) errors.push(`本文の最初の見出しは「${expected}」にします`);

  const ja = parseBlocks(jaBody);
  const en = parseBlocks(enBody);
  if (ja.fences.length !== en.fences.length) {
    errors.push(`フェンスの数が違います (日本語 ${ja.fences.length} / 英語 ${en.fences.length})`);
  } else {
    ja.fences.forEach((fence, index) => {
      for (const problem of compareFence(fence, en.fences[index])) errors.push(`${en.fences[index].line} 行目のフェンス (${fence.lang}): ${problem}`);
    });
  }

  // 本文: 日本語の字・単位の書き方・リンク
  let section = '';
  for (const { text, line } of en.prose) {
    const heading = /^#{2,6}\s+(.*)$/.exec(text);
    if (heading) section = heading[1].trim();
    if (CJK.test(text) && !JAPANESE_OK_SECTIONS.has(section)) errors.push(`${line} 行目: 日本語が残っています (${text.trim().slice(0, 40)})`);
    for (const problem of unitProblems(text)) errors.push(`${line} 行目: ${problem}`);
    for (const link of text.matchAll(/\]\(([^)\s#]+\.md)(?:#[^)]*)?\)/g)) {
      if (/^https?:/.test(link[1])) continue;
      const target = resolve(root, dirname(enPath), link[1]);
      const jaTarget = resolve(root, jaPathOf(relative(root, target)));
      if (!existsSync(target) && !existsSync(jaTarget)) errors.push(`${line} 行目: リンク先がありません (${link[1]})`);
    }
  }
}

/** 一覧 (--stale): 古い訳・まだの題。 */
export function staleReport(root = ROOT) {
  const english = new Set(listEnglish(root));
  const missing = listJapanese(root).filter((path) => !english.has(`${EN}/${path}`));
  const stale = [];
  for (const path of english) {
    const jaPath = jaPathOf(path);
    if (!existsSync(join(root, jaPath))) continue;
    const en = splitFrontMatter(readFileSync(join(root, path), 'utf8'));
    if (en === null || en.data === null || en.data.ja !== blobHash(readFileSync(join(root, jaPath), 'utf8'))) stale.push(path);
  }
  return { missing, stale, translated: english.size };
}

/** 英語の題の図のフェンスを、日本語の題と同じ CLI の `check` に掛ける。落ちた CLI の出力を返す。 */
export function fenceProblems(paths) {
  const byFence = new Map();
  for (const path of paths) {
    const text = readFileSync(join(ROOT, path), 'utf8');
    for (const fence of fencesIn(text).found) {
      if (fence === 'plantuml' || !FENCES.includes(fence)) continue;
      byFence.set(fence, [...(byFence.get(fence) ?? []), path]);
    }
  }
  const problems = [];
  for (const [fence, files] of byFence) {
    const run = spawnSync(process.execPath, [cliPath(ROOT, fence), 'check', ...files], { cwd: ROOT, encoding: 'utf8' });
    if (run.status !== 0) problems.push(`${fence} フェンスの check が落ちました:\n${(run.stderr || run.stdout).trimEnd()}`);
  }
  return problems;
}

function main(args) {
  if (args.includes('--stale')) {
    const { missing, stale, translated } = staleReport();
    console.log(`訳した題 ${translated} / 古い訳 ${stale.length} / まだ ${missing.length}`);
    for (const path of stale) console.log(`  古い: ${path}`);
    const byBook = new Map();
    for (const path of missing) byBook.set(path.split('/')[0], (byBook.get(path.split('/')[0]) ?? 0) + 1);
    for (const [book, count] of byBook) console.log(`  まだ: ${book} ${count} 題`);
    return;
  }
  const paths = args.length > 0 ? args : listEnglish();
  let failed = 0;
  let warned = 0;
  for (const path of paths) {
    const { errors, warnings } = checkEntry(path);
    for (const warning of warnings) { console.warn(`警告 ${path}: ${warning}`); warned += 1; }
    if (errors.length > 0) {
      failed += 1;
      console.error(`${path}:\n${errors.map((error) => `  ${error}`).join('\n')}`);
    }
  }
  if (paths.length > 0) {
    for (const problem of fenceProblems(paths)) {
      failed += 1;
      console.error(problem);
    }
  }
  console.log(`${paths.length} 題を検査した (エラー ${failed} 件 / 警告 ${warned})`);
  if (failed > 0) process.exit(1);
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) main(process.argv.slice(2));
