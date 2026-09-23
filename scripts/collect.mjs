/**
 * 3 冊の題のファイルを集めて読む。`README.md` (目次) は題ではないので外す。
 *
 * 目次 (`toc.mjs`)・検査 (`check.mjs`)・図 (`render.mjs`) が同じ集め方をする。
 * 集め方が食い違うと「検査は通ったのに目次に無い」題が出るため、1 か所に置く。
 */

import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { BOOKS } from './books.mjs';
import { validateEntry } from './entry.mjs';

export const ROOT = fileURLToPath(new URL('..', import.meta.url));

/** 冊のディレクトリの下の .md を全部 (深さを問わず)。README.md は除く。 */
export function listEntryPaths(root = ROOT) {
  return BOOKS.flatMap((book) => walk(join(root, book.dir)))
    .filter((path) => path.endsWith('.md') && !path.endsWith(`${sep}README.md`))
    .map((path) => relative(root, path).split(sep).join('/'))
    .sort();
}

/** 題を読んで検査する。`errors` が空でない題も返す (呼ぶ側が言う)。 */
export function readEntries(root = ROOT) {
  return listEntryPaths(root).map((path) => {
    const text = readFileSync(join(root, path), 'utf8');
    return { path, text, ...validateEntry({ path, text }) };
  });
}

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
