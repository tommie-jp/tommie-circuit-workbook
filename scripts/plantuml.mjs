/**
 * ` ```plantuml ` フェンスの検査と書き出し。他のフェンスは tommie-fence の道具 (`dist/cli.cjs`) が
 * やるが、PlantUML は手元の `plantuml` コマンド (Java) に任せる。
 *
 * 1 つのファイルに同じフェンスが 2 枚以上なら `-1` `-2` … を付ける (`figures.mjs` の置き場と同じ)。
 */

import { spawnSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { basename, join } from 'node:path';
import { ROOT } from './collect.mjs';

/** 本文から ` ```plantuml ` の中身を出てくる順に取り出す。 */
export function plantumlSources(text) {
  return [...text.matchAll(/^ {0,3}```plantuml[^\n]*\n([\s\S]*?)^ {0,3}```[ \t]*$/gm)].map((match) => match[1]);
}

const stem = (path) => basename(path).replace(/\.md$/, '');

/** 図 1 枚ごとの `{ name, source }`。名前は拡張子なしの SVG のファイル名。 */
function diagrams(path, text) {
  const sources = plantumlSources(text);
  return sources.map((source, index) => ({
    name: sources.length === 1 ? stem(path) : `${stem(path)}-${index + 1}`,
    source,
  }));
}

function run(args) {
  const result = spawnSync('plantuml', args, { cwd: ROOT, encoding: 'utf8' });
  if (result.error?.code === 'ENOENT') {
    return { status: 1, stderr: 'plantuml コマンドがありません (apt install plantuml graphviz)' };
  }
  return result;
}

/** `paths` の PlantUML を全部描いてみて、読めない図の置き場を返す。 */
export function checkPlantuml(paths) {
  const dir = mkdtempSync(join(tmpdir(), 'plantuml-check-'));
  try {
    return paths.flatMap((path) => diagrams(path, readFileSync(join(ROOT, path), 'utf8')).flatMap(({ name, source }) => {
      const file = join(dir, `${name}.puml`);
      writeFileSync(file, source);
      const result = run(['-checkonly', file]);
      return result.status === 0 ? [] : [{ path, message: `${result.stderr ?? ''}${result.stdout ?? ''}`.trim() }];
    }));
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

/** `path` の PlantUML を `out` に SVG で書き出す。失敗は文字列で返す。 */
export function renderPlantuml(path, out) {
  const outDir = join(ROOT, out);
  mkdirSync(outDir, { recursive: true });
  const dir = mkdtempSync(join(tmpdir(), 'plantuml-render-'));
  try {
    for (const { name, source } of diagrams(path, readFileSync(join(ROOT, path), 'utf8'))) {
      const file = join(dir, `${name}.puml`);
      writeFileSync(file, source);
      const result = run(['-tsvg', '-charset', 'UTF-8', '-o', outDir, file]);
      if (result.status !== 0) return `${path}: ${`${result.stderr ?? ''}${result.stdout ?? ''}`.trim()}`;
    }
    return null;
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}
