/**
 * 1 題のファイル (`<NN-冊>/<NN-章>/<NN-題>.md`) を読み、front matter を検査する。
 *
 * **置き場と front matter と見出しが食い違わないこと**を見る。ファイルを別の章へ
 * 動かしたのに `chapter` を直し忘れる、番号を振り直したのに `id` が古い、
 * といったずれは目次を黙って狂わせるので、ここで止める。
 */

import { parse } from 'yaml';
import { TIERS, findBook, findChapter } from './books.mjs';

/** front matter に書ける鍵。ここに無い鍵は書き間違いとして断る。 */
const KEYS = new Set(['book', 'chapter', 'id', 'title', 'tier', 'source', 'board', 'tools', 'device', 'era']);

/** 板の印。BB = ブレッドボード、PF = perfboard、銅 = 銅張り基板、— = 板を使わない。 */
const BOARDS = new Set(['BB', 'PF', '銅', '—']);
const TOOLS = new Set(['AD', 'VNA']);
const ERAS = new Set(['古', '今', '古/今']);

/**
 * 冊ごとの機種 (`device`)。鍵は冊の slug。NanoVNA は必ず書く (1.5 GHz より上は V2 が要る)。
 * Analog Discovery は AD3 でしかできない題にだけ書く。回路の冊には無い。
 */
const DEVICES = {
  circuits: { required: false, values: new Set() },
  'analog-discovery': { required: false, values: new Set(['AD2', 'AD3']) },
  nanovna: { required: true, values: new Set(['H4', 'V2']) },
};

const FILE_NAME = /^(\d{2})-[a-z0-9]+(?:-[a-z0-9]+)*\.md$/;
const ID = /^(\d+)-(\d+)$/;
const FRONT_MATTER = /^---\n([\s\S]*?)\n---\n/;

/**
 * @param {{ path: string, text: string }} file `path` はリポジトリ直下からの相対 (区切りは `/`)
 * @returns {{ entry: object | null, errors: string[] }}
 */
export function validateEntry({ path, text }) {
  const place = locate(path);
  if (typeof place === 'string') return { entry: null, errors: [place] };

  const matter = FRONT_MATTER.exec(text);
  if (matter === null) return { entry: null, errors: ['front matter (--- で囲んだ YAML) が先頭にありません'] };

  let data;
  try {
    data = parse(matter[1]);
  } catch (error) {
    return { entry: null, errors: [`front matter の YAML が読めません: ${error.message.split('\n')[0]}`] };
  }
  if (data === null || typeof data !== 'object' || Array.isArray(data)) {
    return { entry: null, errors: ['front matter は「鍵: 値」の並びで書きます'] };
  }

  const errors = [
    ...checkKeys(data),
    ...checkPlace(data, place),
    ...checkValues(data, place.book.slug),
    ...checkHeading(text.slice(matter[0].length), data),
  ];
  const entry = {
    path,
    book: place.book,
    chapter: place.chapter,
    number: place.number,
    id: data.id,
    title: data.title,
    tier: data.tier,
    source: data.source,
    board: data.board ?? null,
    tools: data.tools ?? null,
    device: data.device ?? null,
    era: data.era ?? null,
  };
  return { entry, errors };
}

/**
 * 冊の中で 2 つ以上のファイルが使っている id。1 つのファイルだけを見る
 * `validateEntry` では分からない (`03-led.md` と `03-ohm.md` はどちらも 1-3 として通る)。
 */
export function duplicateIds(entries) {
  const groups = new Map();
  for (const entry of entries) {
    const key = `${entry.book.dir} ${entry.id}`;
    groups.set(key, [...(groups.get(key) ?? []), entry]);
  }
  return [...groups.values()]
    .filter((group) => group.length > 1)
    .map((group) => ({ book: group[0].book.dir, id: group[0].id, paths: group.map((entry) => entry.path).sort() }));
}

/** 置き場から冊・章・番号を読む。読めなければ理由の文字列。 */
function locate(path) {
  const parts = path.split('/');
  if (parts.length !== 3) return `置き場は <NN-冊>/<NN-章>/<NN-題>.md です (${path})`;

  const [bookDir, chapterDir, fileName] = parts;
  const book = findBook(bookDir);
  if (book === null) return `知らない冊です: ${bookDir} (scripts/books.mjs の表を見る)`;
  const chapter = findChapter(book, chapterDir);
  if (chapter === null) return `${book.dir} に無い章です: ${chapterDir} (scripts/books.mjs の表を見る)`;
  const name = FILE_NAME.exec(fileName);
  if (name === null) return `ファイル名は NN-英小文字.md です (${fileName})`;

  return { book, chapter, number: Number(name[1]) };
}

function checkKeys(data) {
  return Object.keys(data).filter((key) => !KEYS.has(key)).map((key) => `知らない鍵です: ${key}`);
}

function checkPlace(data, place) {
  const errors = [];
  if (data.book !== place.book.slug) errors.push(`book は置き場の冊の番号を除いた名前 (${place.book.slug}) にします`);
  if (data.chapter !== place.chapter.number) {
    errors.push(`chapter は置き場の章 (${place.chapter.number}) と同じにします`);
  }

  const expected = `${place.chapter.number}-${place.number}`;
  if (typeof data.id !== 'string' || !ID.test(data.id)) {
    errors.push(`id は「章-番号」で書きます (この置き場なら ${expected})`);
  } else if (data.id !== expected) {
    errors.push(`id は置き場の章とファイル名の番号から ${expected} です (今は ${data.id})`);
  }
  return errors;
}

function checkValues(data, bookSlug) {
  const errors = [];
  if (!isText(data.title)) errors.push('title を書きます');
  if (!TIERS.includes(data.tier)) errors.push(`tier は ${TIERS.join(' / ')} のどれかです`);
  if (!isText(data.source)) errors.push('source (出典。自分で起こしたなら「自作」) を書きます');

  if (data.board !== undefined && !listOf(data.board).every((board) => BOARDS.has(board))) {
    errors.push(`board は ${[...BOARDS].join(' / ')} (並べるなら [BB, PF]) です`);
  }
  if (data.tools !== undefined && !(Array.isArray(data.tools) && data.tools.every((tool) => TOOLS.has(tool)))) {
    errors.push(`tools は [${[...TOOLS].join(', ')}] から選んだ並びです`);
  }
  if (data.era !== undefined && (bookSlug !== 'circuits' || !ERAS.has(data.era))) {
    errors.push(`era は回路の冊だけに書き、${[...ERAS].join(' / ')} のどれかです`);
  }

  const device = DEVICES[bookSlug];
  if (data.device === undefined) {
    if (device.required) errors.push(`device (${[...device.values].join(' / ')}) を書きます`);
  } else if (!device.values.has(data.device)) {
    errors.push(device.values.size === 0
      ? `device はこの冊には書きません`
      : `device は ${[...device.values].join(' / ')} のどれかです`);
  }
  return errors;
}

/** 本文の最初の行が `# <id> <title>`。GitHub で開いたときの題と目次の題を揃える。 */
function checkHeading(body, data) {
  const first = body.split('\n').find((line) => line.trim() !== '');
  const expected = `# ${data.id} ${data.title}`;
  return first === expected ? [] : [`本文の最初の見出しは「${expected}」にします`];
}

const isText = (value) => typeof value === 'string' && value.trim() !== '';

const listOf = (value) => (Array.isArray(value) ? value : [value]);
