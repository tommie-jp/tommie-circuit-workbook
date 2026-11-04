/**
 * 進捗の表 (`PROGRESS.md`) を計画 (`plan.yaml`) と題のファイルから組む。
 *
 *   node scripts/progress.mjs          PROGRESS.md を書き直す
 *   node scripts/progress.mjs --check  書き直しが要るなら 1 で終わる
 *
 * 1 行は 1 題 (計画の全部)。欄は 3 つ:
 *
 * - **作成** — 題のファイルがあれば ✓ (手で書かない。ファイルの有無がそのまま印)
 * - **目で確認** — front matter の `seen: YYYY-MM-DD` (人が目で確認した日)
 * - **Fable で確認** — front matter の `reviewed: YYYY-MM-DD` (Claude (Fable) で確認した日)
 *
 * 確認した日より後にファイルが変わっていれば (git の最後の commit の日か、作業ツリーで変えた今日が
 * 日付より後なら) ✓ でなく △ で出し、数に入れない — 確認し直す題がひと目で分かるように。
 * git が無い所では △ は出ない。
 */

import { spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { BOOKS } from './books.mjs';
import { ROOT } from './collect.mjs';
import { REVIEW_MARKS } from './entry.mjs';
import { cell, mergedRows, row } from './toc.mjs';

export const PROGRESS_FILE = 'PROGRESS.md';

const MARK_NAMES = { seen: '目で確認', reviewed: 'Fable で確認' };
const WRITTEN = '作成';
const DONE = '✓';
const STALE = '△';

const HEADER = `# 進捗

\`npm run progress\` が計画 (\`plan.yaml\`) と題の front matter から書く。**手で直さない。**

- **${WRITTEN}** — 題のファイルがあれば ${DONE}
- **${MARK_NAMES.seen}** — 題の front matter の \`seen: YYYY-MM-DD\` (人が目で確認した日)
- **${MARK_NAMES.reviewed}** — 題の front matter の \`reviewed: YYYY-MM-DD\` (Claude (Fable) で確認した日)

確認した日より後に題を書き換えていれば ${DONE} でなく ${STALE} で出し、数に入れない (確認し直す)。`;

const byNumber = (a, b) => a.chapter.number - b.chapter.number || a.number - b.number;

/** 確認の印の見え方。日付が無ければ空、ファイルが日付より後に変わっていれば △。 */
function markState(entry, mark, changed) {
  const date = entry[mark] ?? null;
  if (date === null) return { text: '', done: false };
  const changedAt = changed.get(entry.path) ?? null;
  const stale = changedAt !== null && changedAt > date;
  return { text: `${stale ? STALE : DONE} ${date}`, done: !stale };
}

/** `[計画, 作成, 目で確認, Fable で確認]` の数。△ は数えない。 */
function counts(rows, changed) {
  const written = rows.filter((entry) => entry.path !== null);
  return [
    rows.length,
    written.length,
    ...REVIEW_MARKS.map((mark) => written.filter((entry) => markState(entry, mark, changed).done).length),
  ];
}

const COUNT_NAMES = ['計画', WRITTEN, ...REVIEW_MARKS.map((mark) => MARK_NAMES[mark])];

const titleCell = (entry) => (entry.path === null ? cell(entry.title) : `[${cell(entry.title)}](${entry.path})`);

function bookSection(book, rows, changed) {
  const sorted = [...rows].sort(byNumber);
  const header = ['#', '題', ...COUNT_NAMES.slice(1)];
  return book.chapters
    .map((chapter) => [chapter, sorted.filter((entry) => entry.chapter.number === chapter.number)])
    .filter(([, inChapter]) => inChapter.length > 0)
    .map(([chapter, inChapter]) => [
      `### 第 ${chapter.number} 章 ${chapter.title}`,
      '',
      row(header),
      row(header.map(() => '---')),
      ...inChapter.map((entry) => row([
        entry.id,
        titleCell(entry),
        entry.path === null ? '' : DONE,
        ...REVIEW_MARKS.map((mark) => markState(entry, mark, changed).text),
      ])),
    ].join('\n'));
}

/**
 * 進捗の表の全文。
 *
 * @param {Map<string, object[]>} rowsByBook 冊のディレクトリ → `plan.mjs` の `mergePlan` が返す並び
 * @param {Map<string, string>} changed 題のパス → 最後に変わった日 (`lastChangeDates`)
 */
export function progressTable(rowsByBook, changed = new Map()) {
  const all = BOOKS.flatMap((book) => rowsByBook.get(book.dir) ?? []);
  const summary = [
    row(['冊', ...COUNT_NAMES]),
    row(['---', ...COUNT_NAMES.map(() => '---')]),
    ...BOOKS.map((book) => row([
      `[${book.title}](${book.dir}/README.md)`,
      ...counts(rowsByBook.get(book.dir) ?? [], changed).map(String),
    ])),
    row(['**計**', ...counts(all, changed).map((count) => `**${count}**`)]),
  ];

  const sections = BOOKS
    .filter((book) => (rowsByBook.get(book.dir) ?? []).length > 0)
    .flatMap((book) => ['', `## ${book.title}`, ...bookSection(book, rowsByBook.get(book.dir), changed).flatMap((section) => ['', section])]);

  return [HEADER, '', summary.join('\n'), ...sections, ''].join('\n');
}

/**
 * 題のパス → 最後に変わった日 (`YYYY-MM-DD`)。
 * git log の出力 (`--format=%cs --name-only`。新しい commit が先) から最初に出た日を取り、
 * 作業ツリーで変えたファイルは今日とする。
 *
 * @param {{ log: string, modified: string[], today: string }} source
 */
export function lastChangeDates({ log, modified, today }) {
  const dates = new Map();
  let current = null;
  for (const line of log.split('\n')) {
    if (/^\d{4}-\d{2}-\d{2}$/.test(line)) current = line;
    else if (line !== '' && current !== null && !dates.has(line)) dates.set(line, current);
  }
  for (const path of modified) dates.set(path, today);
  return dates;
}

/** git に聞く。git が無い・リポジトリでないときは空 (△ は出ない)。 */
export function gitChangeDates(root = ROOT) {
  const git = (args) => spawnSync('git', args, { cwd: root, encoding: 'utf8' });
  const log = git(['log', '--format=%cs', '--name-only', '--', ...BOOKS.map((book) => book.dir)]);
  const status = git(['status', '--porcelain', '--', ...BOOKS.map((book) => book.dir)]);
  if (log.status !== 0 || status.status !== 0) return new Map();
  const modified = status.stdout.split('\n').filter((line) => line !== '').map((line) => line.slice(3).trim());
  return lastChangeDates({ log: log.stdout, modified, today: new Date().toISOString().slice(0, 10) });
}

/** 書くべき PROGRESS.md と今の中身。 */
export function plannedProgress(root = ROOT) {
  const byBook = new Map([...mergedRows(root)].map(([dir, { rows }]) => [dir, rows]));
  let current = '';
  try {
    current = readFileSync(join(root, PROGRESS_FILE), 'utf8');
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
  }
  return { path: PROGRESS_FILE, current, next: progressTable(byBook, gitChangeDates(root)) };
}

function main(args) {
  const checkOnly = args.includes('--check');
  const { path, current, next } = plannedProgress();
  if (current === next) {
    console.log('進捗の表は最新');
    return;
  }
  if (checkOnly) {
    console.error(`進捗の表が古い: ${path}\nnpm run progress で書き直す`);
    process.exit(1);
  }
  writeFileSync(join(ROOT, path), next);
  console.log(`書き直した: ${path}`);
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) main(process.argv.slice(2));
