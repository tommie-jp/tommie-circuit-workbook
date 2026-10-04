import fs from 'node:fs';
import { parse } from 'yaml';

const REQUIRED = ['book', 'chapter', 'id', 'title', 'tier', 'source'];

export function validateFrontMatter(data) {
  const errors = [];

  if (!data || typeof data !== 'object' || Array.isArray(data)) {
    return ['front matter はオブジェクトである必要があります'];
  }

  for (const key of REQUIRED) {
    if (data[key] === undefined || data[key] === null || data[key] === '') {
      errors.push(`${key} が未設定です`);
    }
  }

  if (!['circuits', 'analog-discovery', 'nanovna', 'denken', 'etc', 'fpga'].includes(data.book)) {
    errors.push(`book は未定義の値です: ${data.book}`);
  }

  if (!Number.isInteger(data.chapter)) {
    errors.push('chapter は整数である必要があります');
  }

  if (typeof data.id !== 'string' || !/^[0-9]+-[0-9]+$/.test(data.id)) {
    errors.push(`id は 章-番号 形式で書いてください: ${data.id}`);
  }

  if (typeof data.title !== 'string' || data.title.trim() === '') {
    errors.push('title は空にできません');
  }

  if (![50, 100, 200].includes(data.tier)) {
    errors.push('tier は 50 / 100 / 200 のどれかにしてください');
  }

  if (typeof data.source !== 'string' || data.source.trim() === '') {
    errors.push('source は必須です');
  }

  if (data.board !== undefined) {
    const allowed = ['BB', 'PF', 'CB', '—'];
    const boards = Array.isArray(data.board) ? data.board : [data.board];
    for (const b of boards) {
      if (!allowed.includes(b)) {
        errors.push(`board は ${allowed.join(' / ')} のどれかにしてください`);
      }
    }
  }

  if (data.device !== undefined) {
    const allowed = ['AD2', 'AD3', 'LV64', 'H4', 'V2', 'SA'];
    if (!allowed.includes(data.device)) {
      errors.push(`device は ${allowed.join(' / ')} のどれかにしてください`);
    }
  }

  if (data.tools !== undefined) {
    const allowed = ['AD', 'VNA', 'SA', 'scope', 'logic'];
    const tools = Array.isArray(data.tools) ? data.tools : [data.tools];
    for (const t of tools) {
      if (!allowed.includes(t)) {
        errors.push(`tools は ${allowed.join(' / ')} のどれかにしてください`);
      }
    }
  }

  if (data.era !== undefined) {
    const allowed = ['古', '今', '古/今'];
    if (!allowed.includes(data.era)) {
      errors.push(`era は ${allowed.join(' / ')} のどれかにしてください`);
    }
  }

  return errors;
}

export function readFrontMatter(text) {
  const match = text.match(/^---\n([\s\S]*?)\n---\n/);
  if (!match) {
    return { data: null, errors: ['front matter が見つかりません'] };
  }

  try {
    const data = parse(match[1]);
    return { data, errors: validateFrontMatter(data) };
  } catch (error) {
    return { data: null, errors: [`front matter の YAML が読めません: ${error.message}`] };
  }
}

function main() {
  const files = process.argv.slice(2);
  if (files.length === 0) {
    console.error('使い方: node scripts/validate-entry.mjs <file.md> [<file2.md> ...]');
    process.exit(1);
  }

  let hasError = false;
  for (const file of files) {
    const text = fs.readFileSync(file, 'utf8');
    const { data, errors } = readFrontMatter(text);

    if (data === null) {
      console.error(`${file}: ${errors.join(', ')}`);
      hasError = true;
      continue;
    }

    const problems = validateFrontMatter(data);
    if (problems.length > 0) {
      console.error(`${file}: ${problems.join(', ')}`);
      hasError = true;
    } else {
      console.log(`${file}: OK`);
    }
  }

  process.exit(hasError ? 1 : 0);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
