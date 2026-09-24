/**
 * 冊の計画 (`<NN-冊>/plan.yaml`) — 必須 50 ⊂ 入門 100 ⊂ 中級 200 の 200 題の一覧。
 *
 * 目次 (`toc.mjs`) は計画と書いた題 (front matter) を合わせて組む。書いた題は link に
 * なり、まだの題は字だけ。計画に無い題を書いたら、書いた題の title や tier が計画から
 * ずれたら、検査 (`check.mjs`) で言う — 計画が目次の元なので、直すのは計画の側。
 *
 * 1 題は `{ id, tier, title }` に印 (`board` / `device` / `era` / `tools`) を足したもの。
 * 印の決まりは題の front matter と同じ (`entry.mjs`)。
 */

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { parse } from 'yaml';
import { TIERS } from './books.mjs';
import { checkMarks, isText } from './entry.mjs';

export const PLAN_FILE = 'plan.yaml';

const KEYS = new Set(['id', 'title', 'tier', 'board', 'device', 'era', 'tools']);
const ID = /^(\d+)-(\d+)$/;

/**
 * @param {object} book `books.mjs` の冊
 * @param {unknown} data plan.yaml を読んだもの
 * @returns {{ items: object[], errors: string[] }} items は題のファイルと同じ形 (path 無し)
 */
export function validatePlan(book, data) {
  if (!Array.isArray(data)) return { items: [], errors: ['plan.yaml は題の並び (- { id: …, tier: …, title: … }) です'] };

  const items = [];
  const errors = [];
  data.forEach((raw, index) => {
    const label = isText(raw?.id) ? raw.id : `${index + 1} つ目`;
    const result = validateItem(book, raw);
    errors.push(...result.errors.map((error) => `${label}: ${error}`));
    if (result.item !== null) items.push(result.item);
  });

  const seen = new Map();
  for (const item of items) seen.set(item.id, (seen.get(item.id) ?? 0) + 1);
  for (const [id, count] of seen) {
    if (count > 1) errors.push(`${id}: ${count} つの題が同じ id を使っています`);
  }
  return { items, errors };
}

/** 冊の plan.yaml を読む。無ければ空の計画 (題のファイルだけで目次を組む)。 */
export function readPlan(root, book) {
  let text;
  try {
    text = readFileSync(join(root, book.dir, PLAN_FILE), 'utf8');
  } catch (error) {
    if (error.code === 'ENOENT') return { items: [], errors: [] };
    throw error;
  }

  let data;
  try {
    data = parse(text);
  } catch (error) {
    return { items: [], errors: [`plan.yaml が読めません: ${error.message.split('\n')[0]}`] };
  }
  return validatePlan(book, data);
}

/**
 * 計画と書いた題を合わせる。書いた題は印をファイルのもので出し、`path` を持つ。
 * 計画に無い題も落とさず並べる (目次が書いた題を隠さない) が、errors で言う。
 *
 * @param {object[]} items `validatePlan` の items
 * @param {object[]} entries 書いた題 (`entry.mjs` の entry)
 * @returns {{ rows: object[], errors: string[] }} rows は章と番号の順
 */
export function mergePlan(items, entries) {
  const byId = new Map(entries.map((entry) => [entry.id, entry]));
  const planned = new Set(items.map((item) => item.id));
  const errors = [];

  const rows = items.map((item) => {
    const entry = byId.get(item.id);
    if (entry === undefined) return { ...item, path: null };
    if (entry.title !== item.title) errors.push(`${item.id}: title が plan.yaml と違います (plan.yaml を直す)`);
    if (entry.tier !== item.tier) errors.push(`${item.id}: tier が plan.yaml と違います (plan.yaml を直す)`);
    return { ...item, ...entry };
  });
  for (const entry of entries) {
    if (planned.has(entry.id)) continue;
    errors.push(`${entry.id}: plan.yaml に無い題です (計画に足す)`);
    rows.push({ ...entry });
  }

  return { rows: rows.sort(byNumber), errors };
}

const byNumber = (a, b) => a.chapter.number - b.chapter.number || a.number - b.number;

function validateItem(book, raw) {
  if (raw === null || typeof raw !== 'object' || Array.isArray(raw)) {
    return { item: null, errors: ['題は { id: …, tier: …, title: … } の形で書きます'] };
  }
  const errors = Object.keys(raw).filter((key) => !KEYS.has(key)).map((key) => `知らない鍵です: ${key}`);

  const id = typeof raw.id === 'string' ? ID.exec(raw.id) : null;
  if (id === null) return { item: null, errors: [...errors, 'id は「章-番号」で書きます'] };
  const chapterNumber = Number(id[1]);
  const chapter = book.chapters.find((candidate) => candidate.number === chapterNumber) ?? null;
  if (chapter === null) return { item: null, errors: [...errors, `${book.dir} に無い章です: ${chapterNumber}`] };

  if (!isText(raw.title)) errors.push('title を書きます');
  if (!TIERS.includes(raw.tier)) errors.push(`tier は ${TIERS.join(' / ')} のどれかです`);
  errors.push(...checkMarks(raw, book.slug));

  const item = {
    book,
    chapter,
    number: Number(id[2]),
    id: raw.id,
    title: raw.title,
    tier: raw.tier,
    board: raw.board ?? null,
    tools: raw.tools ?? null,
    device: raw.device ?? null,
    era: raw.era ?? null,
  };
  return { item, errors };
}
