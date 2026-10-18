import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { ROOT, readEntries } from './collect.mjs';
import { listEnglish } from './en-check.mjs';
import { CJK } from './en.mjs';
import { cliPath, fencesIn } from './fences.mjs';
import { renderPlantuml } from './plantuml.mjs';

const CACHE_DIR = join('out', '.cache');
const CACHE_FILE = join(CACHE_DIR, 'render-manifest.json');

/** `out` の下の SVG で、日本語の字を含む物のファイル名。 */
function japaneseLeft(out) {
  if (!existsSync(out)) return [];
  return readdirSync(out)
    .filter((name) => name.endsWith('.svg') && CJK.test(readFileSync(join(out, name), 'utf8')))
    .sort();
}

function hashText(text) {
  return createHash('sha256').update(text).digest('hex');
}

function loadManifest() {
  if (!existsSync(CACHE_FILE)) return {};
  try {
    return JSON.parse(readFileSync(CACHE_FILE, 'utf8'));
  } catch {
    return {};
  }
}

function saveManifest(manifest) {
  mkdirSync(CACHE_DIR, { recursive: true });
  writeFileSync(CACHE_FILE, JSON.stringify(manifest, null, 2));
}

function groupHash(items) {
  return items.map(({ path }) => {
    const text = readFileSync(join(ROOT, path), 'utf8');
    return `${path}:${hashText(text)}`;
  }).join('\n');
}

function main(args) {
  const embedFonts = args.includes('--embed-fonts');
  const english = args.includes('--en');
  const books = new Set(args.filter((arg) => !arg.startsWith('--')));
  // `--en` は英語版 (`en/`) の図を `out/en/` に書き出す。日本語版と同じ `<冊>/<章>/<フェンス>/<名前>.svg`
  const reads = (english
    ? listEnglish().map((path) => ({ path, text: readFileSync(join(ROOT, path), 'utf8') }))
    : readEntries()
  ).filter((read) => books.size === 0 || books.has(read.path.split('/')[english ? 1 : 0]));
  const manifest = loadManifest();

  const groups = new Map();
  for (const read of reads) {
    const [book, chapter] = read.path.split('/').slice(english ? 1 : 0);
    for (const fence of fencesIn(read.text).found) {
      const out = join('out', ...(english ? ['en'] : []), book, chapter, fence);
      groups.set(out, [...(groups.get(out) ?? []), { fence, path: read.path }]);
    }
  }

  let failed = 0;
  for (const [out, items] of groups) {
    const key = out;
    const nextHash = hashText(groupHash(items));
    const cached = manifest[key];
    if (cached && cached.hash === nextHash) {
      continue;
    }

    const { fence } = items[0];
    if (fence === 'plantuml') {
      for (const item of items) {
        const error = renderPlantuml(item.path, out);
        if (error !== null) {
          failed += 1;
          console.error(`--- ${out}\n${error}`);
        }
      }
      manifest[key] = { hash: nextHash, updatedAt: Date.now() };
      continue;
    }

    const run = spawnSync(
      process.execPath,
      [
        cliPath(ROOT, fence), 'render', ...items.map((item) => item.path), '--out', out,
        ...(embedFonts && fence === 'circuit' ? ['--embed-fonts'] : []),
        ...(english ? ['--lang', 'en'] : []),
      ],
      { cwd: ROOT, encoding: 'utf8' },
    );
    if (run.status !== 0) {
      failed += 1;
      console.error(`--- ${out}\n${run.stderr.trimEnd()}`);
      continue;
    }

    // 英語版の図に日本語が残ってはいけない (フェンスが出す字は `--lang en` で英語になる)
    const leftover = english ? japaneseLeft(out) : [];
    if (leftover.length > 0) {
      failed += 1;
      console.error(`--- ${out}\n英語版の図に日本語が残っています: ${leftover.join(', ')}`);
      continue;
    }

    manifest[key] = { hash: nextHash, updatedAt: Date.now() };
  }

  saveManifest(manifest);

  const pairs = [...groups.values()].reduce((sum, items) => sum + items.length, 0);
  console.log(`${reads.length} 題 (題 × フェンスで ${pairs} 組) の図を ${groups.size} か所に書き出した (out/)`);
  if (failed > 0) process.exit(1);
}

main(process.argv.slice(2));
