/**
 * 全部の題を検査する。CI と手元で同じものを回す。
 *
 *   1. 置き場と front matter と最初の見出し (`entry.mjs`)
 *   2. フェンス名の書き間違い (`fences.mjs`)
 *   3. 3 つのフェンスを道具の `check` に掛ける (読めない行があれば落ちる)
 *   4. 目次が front matter と合っている (`toc.mjs --check` と同じ)
 *
 *   node scripts/check.mjs            落ちた所だけ出す
 *   node scripts/check.mjs --verbose  ネットリストも出す (意図した回路と突き合わせる)
 *
 * **ERC (つながっていない足など) は落とさない。** 道具が終了コードを変えない
 * ものなので、ここでも出すだけにする。承知で残す未接続は本文に理由を書く。
 */

import { spawnSync } from 'node:child_process';
import { ROOT, readEntries } from './collect.mjs';
import { duplicateIds } from './entry.mjs';
import { FENCES, cliPath, fencesIn } from './fences.mjs';
import { plannedReadmes } from './toc.mjs';

const runCheck = (fence, paths) =>
  spawnSync(process.execPath, [cliPath(ROOT, fence), 'check', ...paths], { cwd: ROOT, encoding: 'utf8' });

function main(args) {
  const verbose = args.includes('--verbose');
  const problems = [];
  const reads = readEntries();

  for (const read of reads) {
    for (const error of read.errors) problems.push(`${read.path}: ${error}`);
  }
  const validEntries = reads.filter((read) => read.entry !== null).map((read) => read.entry);
  for (const { book, id, paths } of duplicateIds(validEntries)) {
    problems.push(`${book} の id ${id} を ${paths.length} つのファイルが使っています: ${paths.join(', ')}`);
  }

  const byFence = new Map(FENCES.map((fence) => [fence, []]));
  for (const read of reads) {
    const { found, misspelled } = fencesIn(read.text);
    for (const fence of found) byFence.get(fence).push(read.path);
    for (const { name, line } of misspelled) {
      problems.push(`${read.path}:${line}: フェンス名「${name}」は ${FENCES.join(' / ')} のどれかに直す (道具が黙って素通りする)`);
    }
  }

  for (const [fence, paths] of byFence) {
    if (paths.length === 0) continue;
    const run = runCheck(fence, paths);
    if (verbose && run.stdout.trim() !== '') console.log(`--- ${fence} (${paths.length})\n${run.stdout.trimEnd()}`);
    if (run.status === 0) {
      if (run.stderr.trim() !== '') console.error(`--- ${fence} の言うこと\n${run.stderr.trimEnd()}`);
      continue;
    }
    // 道具はファイル名の末尾 (`01-led`) しか出さず、章をまたぐと見分けられない。
    // 落ちたときだけ 1 つずつ回し直して、どのファイルかを置き場ごと言う。
    for (const path of paths) {
      const one = runCheck(fence, [path]);
      if (one.status === 0) continue;
      console.error(`--- ${fence}: ${path}\n${one.stderr.trimEnd()}`);
      problems.push(`${path}: ${fence} フェンスに読めない行があります (上の出力)`);
    }
  }

  const stale = plannedReadmes().filter(({ current, next }) => current !== next).map(({ path }) => path);
  if (stale.length > 0) problems.push(`目次が古い: ${stale.join(', ')} (npm run toc で書き直す)`);

  const counts = FENCES.map((fence) => `${fence} ${byFence.get(fence).length}`).join(' / ');
  if (problems.length > 0) {
    console.error(`\n${problems.length} 件の問題:\n${problems.map((problem) => `  ${problem}`).join('\n')}`);
    process.exit(1);
  }
  console.log(`${reads.length} 題を検査した (フェンスのあるファイル: ${counts})。問題なし`);
}

main(process.argv.slice(2));
