import { spawnSync } from 'node:child_process';
import { join } from 'node:path';
import { ROOT, readEntries } from './collect.mjs';
import { cliPath, fencesIn } from './fences.mjs';
import { renderPlantuml } from './plantuml.mjs';

function main(args) {
  const embedFonts = args.includes('--embed-fonts');
  const books = new Set(args.filter((arg) => !arg.startsWith('--')));
  const reads = readEntries().filter((read) => books.size === 0 || books.has(read.path.split('/')[0]));

  const groups = new Map();
  for (const read of reads) {
    const [book, chapter] = read.path.split('/');
    for (const fence of fencesIn(read.text).found) {
      const out = join('out', book, chapter, fence);
      groups.set(out, [...(groups.get(out) ?? []), { fence, path: read.path }]);
    }
  }

  let failed = 0;
  for (const [out, items] of groups) {
    const { fence } = items[0];
    if (fence === 'plantuml') {
      for (const item of items) {
        const error = renderPlantuml(item.path, out);
        if (error !== null) {
          failed += 1;
          console.error(`--- ${out}\n${error}`);
        }
      }
      continue;
    }
    const run = spawnSync(
      process.execPath,
      [
        cliPath(ROOT, fence), 'render', ...items.map((item) => item.path), '--out', out,
        ...(embedFonts && fence === 'circuit' ? ['--embed-fonts'] : []),
      ],
      { cwd: ROOT, encoding: 'utf8' },
    );
    if (run.status !== 0) {
      failed += 1;
      console.error(`--- ${out}\n${run.stderr.trimEnd()}`);
    }
  }

  const pairs = [...groups.values()].reduce((sum, items) => sum + items.length, 0);
  console.log(`${reads.length} 題 (題 × フェンスで ${pairs} 組) の図を ${groups.size} か所に書き出した (out/)`);
  if (failed > 0) process.exit(1);
}

main(process.argv.slice(2));
