/**
 * 図の崩れ (重なり・横切り・十字・名札の衝突) を、基準 (`fence-check.json`) に無い件だけ赤くする。
 *
 * 道具は tommie-fence の `packages/fence-check`。Release の tgz には出していないので、
 * **公開側の monorepo を教科書の隣に置いたときだけ回る** (`../tommie-fence`、または
 * 環境変数 `FENCE_CHECK` に `dist/cli.cjs` の場所)。無ければ 1 行言って飛ばす —
 * 教科書だけを clone した人の check を赤くしない。
 *
 *   npm run fence-check                 基準に無い件だけを出す (check も同じものを回す)
 *   npm run fence-check -- --write      図を直して消えた件を基準から消す (基準は減るだけ)
 *
 * わざと残す件は `fence-check-allow.json` に理由をつけて書く。新しい検査項目が入って件が
 * 増えたときだけ、`fence-check . --json > fence-check.json` で基準を取り直す。
 */

import { spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT } from './collect.mjs';

export const BASELINE_FILE = 'fence-check.json';
export const ALLOW_FILE = 'fence-check-allow.json';

/** fence-check の CLI の所在。見つからなければ path は null で、理由を 1 行。 */
export function findFenceCheck(root = ROOT, env = process.env) {
  if (env.FENCE_CHECK) {
    return existsSync(env.FENCE_CHECK)
      ? { path: env.FENCE_CHECK, reason: null }
      : { path: null, reason: `FENCE_CHECK の場所に fence-check がありません: ${env.FENCE_CHECK}` };
  }
  const monorepo = resolve(root, '..', 'tommie-fence');
  const cli = join(monorepo, 'packages', 'fence-check', 'dist', 'cli.cjs');
  if (existsSync(cli)) return { path: cli, reason: null };
  if (existsSync(join(monorepo, 'packages', 'fence-check'))) {
    return { path: null, reason: `fence-check を組んでいません (${monorepo} で npm run build -w fence-check)` };
  }
  return { path: null, reason: 'fence-check 無し (公開側の tommie-fence を教科書の隣に置くと回る)' };
}

export const fenceCheckArgs = (extra = []) => ['.', '--baseline', BASELINE_FILE, '--allow', ALLOW_FILE, ...extra];

/** 終了コードを check の問題の文に。0 なら null。 */
export function problemOf(status) {
  if (status === 0) return null;
  if (status === 1) {
    return `${BASELINE_FILE} に無い図の崩れがあります (上の NEW の行)。図を直すか、わざと残すなら ${ALLOW_FILE} に理由を書く`;
  }
  return `fence-check が基準か許す一覧を読めません (上の出力)`;
}

/** 回す。道具が無ければ `skipped` に理由。 */
export function runFenceCheck(extra = [], root = ROOT, env = process.env) {
  const found = findFenceCheck(root, env);
  if (found.path === null) return { skipped: found.reason, status: 0, stdout: '', stderr: '' };
  const run = spawnSync(process.execPath, [found.path, ...fenceCheckArgs(extra)], { cwd: root, encoding: 'utf8' });
  return { skipped: null, status: run.status ?? 2, stdout: run.stdout, stderr: run.stderr };
}

function main(args) {
  const run = runFenceCheck(args);
  if (run.skipped !== null) {
    console.log(run.skipped);
    return;
  }
  process.stdout.write(run.stdout);
  process.stderr.write(run.stderr);
  process.exitCode = run.status;
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) main(process.argv.slice(2));
