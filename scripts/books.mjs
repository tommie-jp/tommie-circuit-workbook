/**
 * 3 冊の冊と章の表。**ディレクトリ名・目次・front matter の検査がここを見る。**
 *
 * 冊のディレクトリも章のディレクトリも `NN-slug` (2 桁の番号 + 英語の短い名前)。
 * front matter には番号を書かず、冊は `book: <slug>`、章は `chapter: <番号>` で書く。
 * 章を足すときはここに 1 行足す (ディレクトリは題を置いたときに作る)。
 *
 * `columns` は目次の表に出す front matter の欄。冊ごとに意味のある欄だけ出す。
 */

/** `NN-slug`。冊と章のディレクトリ名。 */
function numbered(number, slug) {
  return `${String(number).padStart(2, '0')}-${slug}`;
}

export const TIERS = /** @type {const} */ ([50, 100, 200]);

/** 段の呼び名。目次と本文で同じ字を使う。 */
export const TIER_NAMES = { 50: '必須', 100: '入門', 200: '中級' };

export const BOOKS = [
  {
    number: 1,
    slug: 'circuits',
    title: '回路の教科書',
    summary: '直流の基本から実用回路まで。回路図と実体配線図を並べて組む',
    columns: ['era', 'board'],
    chapters: [
      [0, 'measure', '測定と道具'],
      [1, 'basics', '基本 — 直流と受動部品'],
      [2, 'transistors', 'トランジスタ — BJT と FET'],
      [3, 'oscillators', '発振とタイマー'],
      [4, 'opamps', 'OP アンプ'],
      [5, 'power-supplies', '電源'],
      [6, 'transformers', 'トランスとコイル'],
      [7, 'power', 'パワー'],
      [8, 'sensors', 'センサー'],
      [9, 'rf', 'RF — ラジオと送信'],
      [10, 'logic', 'ロジック'],
      [11, 'microcontrollers', 'マイコンと現代の定番'],
      [12, 'projects', '実用回路 — 作品'],
    ],
  },
  {
    number: 2,
    slug: 'analog-discovery',
    title: 'Analog Discovery の教科書',
    summary: 'Analog Discovery 2 / 3 と WaveForms で DC〜10 MHz を測る',
    columns: ['board', 'device'],
    chapters: [
      [0, 'tools', '道具と安全'],
      [1, 'waveforms', 'WaveForms の基本'],
      [2, 'oscilloscope', 'オシロスコープ'],
      [3, 'wavegen', '波形発生器'],
      [4, 'spectrum', 'FFT とスペクトラム'],
      [5, 'network', 'ネットワークアナライザ'],
      [6, 'impedance', 'インピーダンス測定'],
      [7, 'logic', 'ロジックとプロトコル'],
      [8, 'breadboard-limits', 'ブレッドボードの限界と perfboard'],
      [9, 'amplifiers', 'アンプの特性'],
      [10, 'power-noise', '電源と雑音'],
      [11, 'automation', '自動化'],
      [12, 'mixed-signal', 'デジタルと混合信号'],
    ],
  },
  {
    number: 3,
    slug: 'nanovna',
    title: 'NanoVNA の教科書',
    summary: 'NanoVNA-H4 / V2 で 10 kHz〜4.4 GHz を測る。治具・部品・フィルタ・アンテナ・GHz 帯',
    columns: ['device', 'board'],
    chapters: [
      [0, 'tools', '道具と安全'],
      [1, 'calibration', '校正'],
      [2, 'display', '画面と PC ソフト'],
      [3, 'fixtures', '治具'],
      [4, 'components', '部品の周波数特性'],
      [5, 'transmission-lines', '伝送線路'],
      [6, 'filters', 'フィルタ'],
      [7, 'antennas', 'アンテナ'],
      [8, 'amplifiers', 'アンプと能動回路の S パラメータ'],
      [9, 'ghz', 'GHz 帯の作法'],
      [10, 'automation', '自動化'],
    ],
  },
].map((book) => ({
  ...book,
  dir: numbered(book.number, book.slug),
  chapters: book.chapters.map(([number, slug, title]) => ({
    number,
    slug,
    title,
    dir: numbered(number, slug),
  })),
}));

export const findBook = (dir) => BOOKS.find((book) => book.dir === dir) ?? null;

export const findChapter = (book, dir) => book.chapters.find((chapter) => chapter.dir === dir) ?? null;
