/**
 * 進捗の表 (`PROGRESS.md`) を計画 (`plan.yaml`) と題のファイルから組む。
 *
 *   node scripts/progress.mjs          箱の変化を題に書き戻してから、PROGRESS.md を書き直す
 *   node scripts/progress.mjs --check  書き直し (か書き戻し) が要るなら 1 で終わる。題には触らない
 *
 * 章ごとの表で、1 行は 1 題 (計画の全部)。書いた題の「目で確認」の欄が **チェックボックス**:
 *
 *   | 1-1 | [題](path) | ✓ | [x] 2026-11-01 | ✓ 2026-10-30 | ✓ 2026-11-02 |
 *   | 1-2 | [題](path) | ✓ | [ ] | — | — |
 *   | 1-3 | 題 | | | | |                     ← まだの題 (箱なし)
 *
 * - **作成** — 題のファイルがあれば ✓ と link。まだの題は字だけ (手で書かない)
 * - **目で確認** (箱) — front matter の `seen: YYYY-MM-DD` (人が目で確認した日)。
 *   読む人が箱を `[x]` にして (括弧の中に x を打つ) このスクリプトを回すと、題の front matter に
 *   `seen: <今日>` が入る。`[ ]` に戻せば `seen` が消える
 * - **Fable で確認** — front matter の `reviewed: YYYY-MM-DD` (Claude (Fable) で確認した日)
 * - **実測** — front matter の `measured: YYYY-MM-DD` (作者が実機で組んで測った日。手で書く)
 *
 * 冊の表には **1.0 まで** の欄を出す。冊の完成 1.0 = 必須 50 が全部 実測、入門が全部 目で確認、
 * 中級が全部 作成 (README の「完成の基準」)。足りない数を「必須の実測 N・入門の確認 N・中級の執筆 N」で言い、
 * 全部 0 なら「1.0」。必須の無い冊 (番外) は —。
 *
 * 確認した日より後にファイルが変わっていれば (git の最後の commit の日か、作業ツリーで変えた今日が
 * 日付より後なら) ✓ でなく △ で出し、箱を空にして数に入れない — 確認し直す題がひと目で分かるように。
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

const MARK_NAMES = { seen: '目で確認', reviewed: 'Fable で確認', measured: '実測' };
const RELEASE = '1.0 まで';
const WRITTEN = '作成';
const DONE = '✓';
const STALE = '△';
const NONE = '—';

const HEADER = `# 進捗

\`npm run progress\` が計画 (\`plan.yaml\`) と題の front matter から書く。**箱以外は手で直さない。**

- **${WRITTEN}** — 題のファイルがあれば ${DONE} と link。まだの題は字だけ
- **${MARK_NAMES.seen}** (箱) — 題の front matter の \`seen: YYYY-MM-DD\` (人が目で確認した日)。
  **目で確認したら箱を \`[x]\` にして** (括弧の中に x を打つ) \`npm run progress\` を回す。
  題の front matter に \`seen: <今日>\` が入り、日付がここに出る。\`[ ]\` に戻せば \`seen\` が消える
- **${MARK_NAMES.reviewed}** — 題の front matter の \`reviewed: YYYY-MM-DD\` (Claude (Fable) で確認した日。${NONE} はまだ)
- **${MARK_NAMES.measured}** — 題の front matter の \`measured: YYYY-MM-DD\` (作者が実機で組んで測った日。測った値を題に書いてから手で書く。${NONE} はまだ)
- **${RELEASE}** — 冊の完成 1.0 (必須が全部 ${MARK_NAMES.measured}、入門が全部 ${MARK_NAMES.seen}、中級が全部 ${WRITTEN}。README の「完成の基準」) に足りない数。全部そろえば 1.0

確認した日より後に題を書き換えていれば ${DONE} でなく ${STALE} で出し、箱を空にして数に入れない (確認し直して、また箱を付ける)。`;

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
const ROW_NAMES = ['#', '題', ...COUNT_NAMES.slice(1)];

/**
 * 冊の完成 1.0 に足りない数。必須 (tier 50) で実測していない題、入門 (tier 100) で目で確認していない題、
 * 中級 (tier 200) でまだ書いていない題。△ (確認の後に書き換えた) は足りない側に数える。
 * 必須の無い冊 (番外) は 1.0 を持たないので null。
 */
export function releaseGap(rows, changed) {
  const lacks = (tier, done) => rows.filter((entry) => entry.tier === tier && !done(entry)).length;
  if (rows.every((entry) => entry.tier !== 50)) return null;
  return {
    measured: lacks(50, (entry) => entry.path !== null && markState(entry, 'measured', changed).done),
    seen: lacks(100, (entry) => entry.path !== null && markState(entry, 'seen', changed).done),
    written: lacks(200, (entry) => entry.path !== null),
  };
}

/** 1.0 までの欄の字。 */
function releaseCell(rows, changed) {
  const gap = releaseGap(rows, changed);
  if (gap === null) return NONE;
  if (gap.measured + gap.seen + gap.written === 0) return '1.0';
  return `必須の${MARK_NAMES.measured} ${gap.measured}・入門の確認 ${gap.seen}・中級の執筆 ${gap.written}`;
}

/** 目で確認の欄。箱と、確認した日 (△ は確認の後に書き換えた題)。 */
function seenCell(entry, changed) {
  const seen = markState(entry, 'seen', changed);
  if (seen.text === '') return '[ ]';
  return seen.done ? `[x] ${entry.seen}` : `[ ] ${seen.text}`;
}

/** 1 題の行。書いた題は ✓ と link と箱、まだの題は字だけで欄は空。 */
function entryRow(entry, changed) {
  if (entry.path === null) return row([entry.id, cell(entry.title), '', '', '', '']);
  const dated = (mark) => {
    const state = markState(entry, mark, changed);
    return state.text === '' ? NONE : state.text;
  };
  return row([
    entry.id,
    `[${cell(entry.title)}](${entry.path})`,
    DONE,
    seenCell(entry, changed),
    dated('reviewed'),
    dated('measured'),
  ]);
}

function bookSection(book, rows, changed) {
  const sorted = [...rows].sort(byNumber);
  return book.chapters
    .map((chapter) => [chapter, sorted.filter((entry) => entry.chapter.number === chapter.number)])
    .filter(([, inChapter]) => inChapter.length > 0)
    .map(([chapter, inChapter]) => [
      `### 第 ${chapter.number} 章 ${chapter.title}`,
      '',
      row(ROW_NAMES),
      row(ROW_NAMES.map(() => '---')),
      ...inChapter.map((entry) => entryRow(entry, changed)),
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
    row(['冊', ...COUNT_NAMES, RELEASE]),
    row(['---', ...COUNT_NAMES.map(() => '---'), '---']),
    ...BOOKS.map((book) => row([
      `[${book.title}](${book.dir}/README.md)`,
      ...counts(rowsByBook.get(book.dir) ?? [], changed).map(String),
      releaseCell(rowsByBook.get(book.dir) ?? [], changed),
    ])),
    row(['**計**', ...counts(all, changed).map((count) => `**${count}**`), '']),
  ];

  const sections = BOOKS
    .filter((book) => (rowsByBook.get(book.dir) ?? []).length > 0)
    .flatMap((book) => ['', `## ${book.title}`, ...bookSection(book, rowsByBook.get(book.dir), changed).flatMap((section) => ['', section])]);

  return [HEADER, '', summary.join('\n'), ...sections, ''].join('\n');
}

const BOOK_HEADING = /^## (.+)$/;
/** 書いた題の行。`| id | [題](path) | ✓ | [x] 日付 | … |`。箱の後ろは「日付」(✓) か「△ 日付」か空。 */
const BOX_LINE = /^\| (\d+-\d+) \| \[.*?\]\((\S+\.md)\) \| ✓ \| \[([ xX])\]((?: (?:△ )?\d{4}-\d{2}-\d{2})?) \| /;

/**
 * 今の PROGRESS.md で、読む人が前回の書き出しから変えた箱。
 * 書き出した時の箱は「△ でない日付があれば [x]」なので、それと今の箱が違う行だけを返す。
 *
 * @returns {{ book: object, id: string, path: string, checked: boolean }[]}
 */
export function toggledMarks(text) {
  const toggled = [];
  let book = null;
  for (const line of text.split('\n')) {
    const heading = BOOK_HEADING.exec(line);
    if (heading !== null) {
      book = BOOKS.find((candidate) => candidate.title === heading[1]) ?? null;
      continue;
    }
    const box = BOX_LINE.exec(line);
    if (box === null || book === null) continue;
    const checked = box[3] !== ' ';
    const rendered = box[4] !== '' && !box[4].includes(STALE);
    if (checked !== rendered) toggled.push({ book, id: box[1], path: box[2], checked });
  }
  return toggled;
}

const FRONT_MATTER = /^---\n([\s\S]*?)\n---\n/;

/** 題の front matter の `seen:` を日付にする (null なら消す)。他の行はそのまま。 */
export function withSeen(text, date) {
  const matter = FRONT_MATTER.exec(text);
  if (matter === null) throw new Error('front matter (--- で囲んだ YAML) が先頭にありません');
  const kept = matter[1].split('\n').filter((line) => !line.startsWith('seen:'));
  const lines = date === null ? kept : [...kept, `seen: ${date}`];
  return `---\n${lines.join('\n')}\n---\n${text.slice(matter[0].length)}`;
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
export function gitChangeDates(root = ROOT, today = todayString()) {
  const git = (args) => spawnSync('git', args, { cwd: root, encoding: 'utf8' });
  const log = git(['log', '--format=%cs', '--name-only', '--', ...BOOKS.map((book) => book.dir)]);
  const status = git(['status', '--porcelain', '--', ...BOOKS.map((book) => book.dir)]);
  if (log.status !== 0 || status.status !== 0) return new Map();
  const modified = status.stdout.split('\n').filter((line) => line !== '').map((line) => line.slice(3).trim());
  return lastChangeDates({ log: log.stdout, modified, today });
}

const todayString = () => new Date().toISOString().slice(0, 10);

function readProgress(root) {
  try {
    return readFileSync(join(root, PROGRESS_FILE), 'utf8');
  } catch (error) {
    if (error.code === 'ENOENT') return '';
    throw error;
  }
}

/**
 * 箱の変化を題の front matter に書き戻す。書いた題だけ (まだの題には箱が無い)。
 *
 * @returns {string[]} 書き戻した題の報告
 */
export function applyToggles(toggles, rowsByBook, root = ROOT, today = todayString()) {
  const known = new Set(BOOKS.flatMap((book) => (rowsByBook.get(book.dir) ?? []).map((entry) => entry.path)));
  return toggles.map(({ book, id, path, checked }) => {
    if (!known.has(path)) return `${book.dir} ${id}: ${path} は題の一覧に無いので飛ばした`;
    const file = join(root, path);
    writeFileSync(file, withSeen(readFileSync(file, 'utf8'), checked ? today : null));
    return `${path}: ${checked ? `seen: ${today} を書いた` : 'seen を消した'}`;
  });
}

/** 書くべき PROGRESS.md と今の中身。 */
export function plannedProgress(root = ROOT) {
  const byBook = new Map([...mergedRows(root)].map(([dir, { rows }]) => [dir, rows]));
  return { path: PROGRESS_FILE, current: readProgress(root), next: progressTable(byBook, gitChangeDates(root)), byBook };
}

function main(args) {
  const checkOnly = args.includes('--check');
  const first = plannedProgress();
  const toggles = toggledMarks(first.current);

  if (checkOnly) {
    if (toggles.length > 0) {
      console.error(`箱を変えた題が ${toggles.length} 題ある: ${toggles.map((toggle) => `${toggle.book.dir} ${toggle.id}`).join(', ')}\nnpm run progress で題に書き戻す`);
      process.exit(1);
    }
    if (first.current !== first.next) {
      console.error(`進捗の表が古い: ${first.path}\nnpm run progress で書き直す`);
      process.exit(1);
    }
    console.log('進捗の表は最新');
    return;
  }

  for (const report of applyToggles(toggles, first.byBook)) console.log(report);
  const { path, current, next } = toggles.length === 0 ? first : plannedProgress();
  if (current === next) {
    console.log('進捗の表は最新');
    return;
  }
  writeFileSync(join(ROOT, path), next);
  console.log(`書き直した: ${path}`);
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) main(process.argv.slice(2));
