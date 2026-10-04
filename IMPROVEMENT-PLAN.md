# 優先度が高の改善計画

## 概要

tommie-circuit-workbook の保守性と開発速度向上のための 2 つの改善：

1. **スキーマ定義と front matter 検証** — 新題の品質保証
2. **rendering のキャッシュ化** — 開発速度向上（300+ 題の差分 render）

---

## 1. スキーマ定義と front matter 検証

### 目標

- front matter の構造を明確に定義
- 新題・修正題で必須フィールドの落とし忘れを防止
- `check.mjs` で型チェック、許可値チェックを実施
- 各冊のスキーマ差分（例：`device` は nanovna 冊で必須）を管理

### 成果物

#### 1-1. `schemas/entry.schema.json` — 共通スキーマ

```json
{
  "$schema": "http://json-schema.org/draft-2020-12",
  "title": "Entry Front Matter",
  "type": "object",
  "required": ["book", "chapter", "id", "title", "tier"],
  "additionalProperties": false,
  "properties": {
    "book": {
      "type": "string",
      "enum": ["circuits", "analog-discovery", "nanovna", "denken"]
    },
    "chapter": {
      "type": "integer",
      "minimum": 0,
      "maximum": 13
    },
    "id": {
      "type": "string",
      "pattern": "^[0-9]+-[0-9]+$",
      "description": "形式: <章>-<題>。例: 1-1, 3-15"
    },
    "title": {
      "type": "string",
      "minLength": 1,
      "description": "日本語タイトル。plan.yaml と一致が必須"
    },
    "tier": {
      "type": "integer",
      "enum": [50, 100, 200],
      "description": "50=必須, 100=入門, 200=中級"
    },
    "source": {
      "type": "string",
      "description": "出典。借りた回路の場合は出所を書く"
    },
    "era": {
      "type": "string",
      "enum": ["古", "今", "古/今"],
      "description": "古典 / 現代の標準。circuits 冊のみ使用"
    },
    "board": {
      "oneOf": [
        {
          "type": "string",
          "enum": ["BB", "PF", "CB", "—"]
        },
        {
          "type": "array",
          "items": {
            "type": "string",
            "enum": ["BB", "PF", "CB", "—"]
          },
          "minItems": 1
        }
      ],
      "description": "BB=ブレッドボード, PF=perfboard, CB=銅張り基板, —=基板なし"
    },
    "device": {
      "type": "string",
      "enum": ["AD3", "LV64", "H4", "V2"],
      "description": "nanovna 冊のみ。計器の機種"
    },
    "tools": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": ["AD", "VNA", "SA", "scope", "logic"]
      },
      "description": "2 つ以上の計器を使う題のみ。省略可"
    },
    "style": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "standard": {
          "type": "string",
          "enum": ["jis"],
          "description": "denken 冊のみ。JIS C 0617 記号を使う"
        }
      }
    }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "book": { "const": "circuits" }
        },
        "required": ["book"]
      },
      "then": {
        "properties": {
          "board": { "type": ["string", "array"] }
        }
      }
    },
    {
      "if": {
        "properties": {
          "book": { "const": "nanovna" }
        },
        "required": ["book"]
      },
      "then": {
        "required": ["device"],
        "properties": {
          "device": {
            "type": "string"
          }
        }
      }
    },
    {
      "if": {
        "properties": {
          "book": { "const": "denken" }
        },
        "required": ["book"]
      },
      "then": {
        "required": ["style"],
        "properties": {
          "style": {
            "type": "object",
            "required": ["standard"]
          }
        }
      }
    }
  ]
}
```

#### 1-2. `scripts/validate-entry.mjs` — 新規スクリプト

```javascript
/**
 * Front matter スキーマの検証。
 * - check.mjs から呼ぶ
 * - new-entry.mjs（題作成テンプレート）から参照してテンプレートを生成
 *
 *   node scripts/validate-entry.mjs <file.md>
 */

import Ajv from 'ajv';
import fs from 'node:fs';
import YAML from 'yaml';

const schema = JSON.parse(fs.readFileSync('schemas/entry.schema.json', 'utf8'));
const ajv = new Ajv({ useDefaults: true });
const validate = ajv.compile(schema);

export function validateEntry(frontMatter, path) {
  const valid = validate(frontMatter);
  if (!valid) {
    return validate.errors.map((err) => ({
      path,
      field: err.instancePath || '(全体)',
      message: `${err.keyword}: ${err.message}`,
    }));
  }
  return [];
}

function main(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) {
    console.error(`${filePath}: front matter が見つかりません`);
    process.exit(1);
  }

  const frontMatter = YAML.parse(match[1]);
  const errors = validateEntry(frontMatter, filePath);

  if (errors.length > 0) {
    for (const { path, field, message } of errors) {
      console.error(`${path} ${field}: ${message}`);
    }
    process.exit(1);
  }

  console.log(`${filePath}: OK`);
}

main(process.argv[2]);
```

#### 1-3. `scripts/check.mjs` への統合

```javascript
// 既存の check.mjs に追加

import { validateEntry } from './validate-entry.mjs';

// readEntries() ループ内に追加
for (const read of reads) {
  if (read.entry !== null) {
    const errors = validateEntry(read.entry, read.path);
    for (const { field, message } of errors) {
      problems.push(`${read.path} ${field}: ${message}`);
    }
  }
}

// plan.yaml の検証
for (const [dir, { entries }] of mergedRows()) {
  for (const entry of entries) {
    const errors = validateEntry(entry, `${dir}/plan.yaml`);
    for (const { field, message } of errors) {
      problems.push(`${dir}/plan.yaml id=${entry.id} ${field}: ${message}`);
    }
  }
}
```

#### 1-4. `scripts/new-entry.mjs` — 新規スクリプト（テンプレート生成）

```javascript
/**
 * 新題のテンプレートを生成。スキーマと plan.yaml から front matter を構築。
 *
 *   node scripts/new-entry.mjs circuits 1 "LED を点ける — 抵抗で電流を決める" 50
 *   → 01-circuits/01-basics/01-led.md を作成（front matter テンプレート付き）
 */

import fs from 'node:fs';
import YAML from 'yaml';
import { spawnSync } from 'node:child_process';

function slugify(title) {
  // 日本語を簡易的に slug 化（実装は省略、例：「LED を点ける」→ led）
  return title.toLowerCase().replace(/[^a-z0-9]/g, '').substring(0, 20);
}

function main(book, chapterNum, title, tier) {
  const chapterDir = `0${chapterNum}-${book}`;
  const slug = slugify(title);
  const filePath = `${chapterDir}/${String(chapterNum).padStart(2, '0')}-${slug}.md`;

  const frontMatter = {
    book,
    chapter: parseInt(chapterNum),
    id: `${chapterNum}-??`, // 手動で番号を決める
    title,
    tier: parseInt(tier),
    source: '自作',
    // board, device, era は冊に応じて comment で提示
  };

  const template = `---
${YAML.stringify(frontMatter)}---

# ${frontMatter.id} ${title}

## 説明

（説明を書く）

## 回路図

\`\`\`circuit

\`\`\`

## 実体配線図

\`\`\`breadboard

\`\`\`

## 計器の設定

（設定を書く）

## 見るべき値

（測定値を書く）

## 出典

（出典を書く）
`;

  if (fs.existsSync(filePath)) {
    console.error(`${filePath}: ファイルが既に存在します`);
    process.exit(1);
  }

  fs.writeFileSync(filePath, template);
  console.log(`作成しました: ${filePath}`);
  console.log('front matter id を決めて埋めてください（plan.yaml も合わせる）');
}

main(process.argv[2], process.argv[3], process.argv[4], process.argv[5]);
```

#### 1-5. `package.json` への追加

```json
{
  "devDependencies": {
    "ajv": "^8.14.0"
  },
  "scripts": {
    "validate-entry": "node scripts/validate-entry.mjs",
    "new-entry": "node scripts/new-entry.mjs"
  }
}
```

### 実装手順

| Step | 作業 | 見積 | 依存 |
| ------ | ------ | ------ | ------ |
| 1-A | `schemas/entry.schema.json` を作成 | 2h | なし |
| 1-B | `ajv` を package.json に追加、`npm install` | 0.5h | 1-A |
| 1-C | `scripts/validate-entry.mjs` を実装 | 1.5h | 1-B |
| 1-D | `check.mjs` に検証ロジックを統合 | 1h | 1-C |
| 1-E | `scripts/new-entry.mjs` を実装 | 1.5h | 1-C |
| 1-F | 既存 300 題に対して `npm run check` を実行、問題があれば修正 | 3h | 1-D |
| 1-G | テストと CI に統合 | 1h | 1-F |
| **計** | | **10h** | |

### テスト方法

```bash
# 新スキーマで既存題を検証
npm run check

# 新題テンプレートを作成
node scripts/new-entry.mjs circuits 1 "LED を点ける" 50

# 手作業で front matter を埋める

# スキーマ検証
node scripts/validate-entry.mjs 01-circuits/01-basics/01-led.md

# 不正な front matter でテスト
# → エラーメッセージが出ることを確認
```

---

## 2. rendering のキャッシュ化

### 目標

- フェンスの内容が変わらなければ SVG を再生成しない
- 300+ 題のうち差分のみを render して時間短縮
- GitHub Actions での Pages 生成時間を 5 分以内に抑える（現状で数分だが、フェンス増加時に悪化を防ぐ）

### 背景

- `npm run render` は全フェンスを subprocess で処理（各フェンス道具を CLI で実行）
- 現在、push 時に毎回全題を再計算
- 新題追加が増えると処理時間が線形増加

### 成果物

#### 2-1. `out/.cache/` — キャッシュディレクトリ構造

```text
out/.cache/
  manifest.json          全題と hash のマニフェスト
  circuits/
    01-01.json          { hash, mtime, outFile }
    01-02.json
    ...
  analog-discovery/
    ...
```

#### 2-2. `scripts/render.mjs` の改造

```javascript
/**
 * 既存の render.mjs を改造。
 * - キャッシュ マニフェスト を読み込み
 * - フェンスの hash を計算
 * - hash が一致 → skip、mismatch → render
 * - マニフェストに記録して保存
 */

import { createHash } from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import YAML from 'yaml';

const CACHE_DIR = 'out/.cache';
const MANIFEST_FILE = path.join(CACHE_DIR, 'manifest.json');

function mkdirp(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function loadManifest() {
  if (!fs.existsSync(MANIFEST_FILE)) return {};
  return JSON.parse(fs.readFileSync(MANIFEST_FILE, 'utf8'));
}

function saveManifest(manifest) {
  mkdirp(CACHE_DIR);
  fs.writeFileSync(MANIFEST_FILE, JSON.stringify(manifest, null, 2));
}

function hashContent(content) {
  return createHash('sha256').update(content).digest('hex');
}

function getCacheKey(entry) {
  // 形式: "circuits/01-01"
  return `${entry.book}/${entry.id}`;
}

/**
 * entry に含まれるすべてのフェンスを抽出し、内容を hash
 */
function hashEntry(entry, text) {
  const fences = extractFences(text); // 既存ロジック
  const combined = fences
    .map((f) => `${f.name}:${f.content}`)
    .join('\n---\n');
  return hashContent(combined);
}

export function renderWithCache(entries, verbose = false) {
  const manifest = loadManifest();
  const updated = {};
  let skipped = 0,
    rendered = 0;

  for (const entry of entries) {
    const key = getCacheKey(entry);
    const text = fs.readFileSync(entry.path, 'utf8');
    const currentHash = hashEntry(entry, text);
    const cached = manifest[key];

    if (cached && cached.hash === currentHash && fs.existsSync(cached.outFile)) {
      if (verbose) console.log(`  ${key}: キャッシュ（スキップ）`);
      updated[key] = cached; // manifest に保持
      skipped++;
      continue;
    }

    if (verbose) console.log(`  ${key}: render 中...`);

    // 既存の render() を呼ぶ（各フェンスを SVG に）
    const outFiles = renderEntry(entry, text);

    updated[key] = {
      hash: currentHash,
      mtime: new Date().toISOString(),
      outFiles: outFiles, // 生成した SVG パスの配列
    };
    rendered++;
  }

  saveManifest(updated);
  console.log(`\nrender 完了: ${skipped} 題（キャッシュ）, ${rendered} 題（新規・更新）`);
  return { skipped, rendered };
}

function renderEntry(entry, text) {
  // 既存の render ロジック（省略）
  // fences を抽出して各道具で render
  const fences = extractFences(text);
  const outFiles = [];

  for (const fence of fences) {
    const outFile = `out/${entry.book}/${entry.id}-${fence.name}.svg`;
    mkdirp(path.dirname(outFile));

    const result = spawnSync(
      process.execPath,
      ['scripts/fence-render.mjs', fence.name, fence.content, outFile],
      { encoding: 'utf8', cwd: ROOT }
    );

    if (result.status !== 0) {
      console.error(`${entry.id}/${fence.name}: ${result.stderr}`);
      process.exit(1);
    }
    outFiles.push(outFile);
  }

  return outFiles;
}

// main
async function main(args) {
  const entries = readEntries().filter((r) => r.entry).map((r) => r.entry);
  const { skipped, rendered } = renderWithCache(entries, args.includes('--verbose'));
}

main(process.argv.slice(2));
```

#### 2-3. `scripts/fence-render.mjs` — 新規スクリプト（fence 1 個の render）

```javascript
/**
 * 単一フェンスをファイルから SVG に出力。
 * renderWithCache() から呼ばれる。
 *
 *   node scripts/fence-render.mjs circuit "<content>" out/circuits/01-01-circuit.svg
 */

import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

const fenceName = process.argv[2];
const content = process.argv[3];
const outFile = process.argv[4];

// 各フェンス道具のパスと CLI を定義
const FENCE_TOOLS = {
  circuit: 'circuit-fence',
  breadboard: 'breadboard-fence',
  perfboard: 'perfboard-fence',
  copper: 'copper-fence',
  scope: 'scope-fence',
  vna: 'vna-fence',
  spectrum: 'spectrum-fence',
  graph: 'graph-fence',
  logic: 'logic-fence',
};

const toolName = FENCE_TOOLS[fenceName];
if (!toolName) {
  console.error(`不明なフェンス: ${fenceName}`);
  process.exit(1);
}

const toolPath = `./node_modules/.bin/${toolName}`;
if (!fs.existsSync(toolPath)) {
  console.error(`道具がない: ${toolName} (npm ci 後？)`);
  process.exit(1);
}

// 仮ファイルに content を書き込んで render
const tmpFile = `/tmp/fence-${fenceName}-${Date.now()}.md`;
fs.writeFileSync(tmpFile, `\`\`\`${fenceName}\n${content}\n\`\`\``);

const result = spawnSync(toolName, ['check', tmpFile, '--embed-fonts'], {
  encoding: 'utf8',
  cwd: process.cwd(),
  stdio: ['pipe', 'pipe', 'pipe'],
});

// 実際には各道具の render オプションに応じて調整
// ここでは概略のみ示す

fs.unlinkSync(tmpFile);

if (result.status !== 0) {
  console.error(`render 失敗: ${fenceName}\n${result.stderr}`);
  process.exit(1);
}

// SVG をファイルに書き込む（各道具の出力方法に応じて）
// fs.writeFileSync(outFile, result.stdout);

console.log(`render: ${outFile}`);
```

#### 2-4. `scripts/figures.mjs` への統合

```javascript
/**
 * 既存の figures.mjs。キャッシュからの out ファイル一覧を使う。
 */

import fs from 'node:fs';
import path from 'node:path';

export function withFigures(filePath, text, cacheManifest = null) {
  // キャッシュマニフェストがあれば、それから outFiles を取得
  // なければ out/ をスキャン（既存ロジック）

  if (cacheManifest) {
    const entry = extractEntry(filePath);
    const key = `${entry.book}/${entry.id}`;
    const cached = cacheManifest[key];

    if (cached && cached.outFiles) {
      // outFiles から画像参照行を生成して本文に挿入
      return insertFigureLines(text, cached.outFiles);
    }
  }

  // フォールバック：既存ロジック
  return insertFigureLines(text, scanOutDir(filePath));
}

function insertFigureLines(text, outFiles) {
  // outFiles から ![...](URL) 行を生成、本文に挿入
  // 既存の withFigures ロジックを流用
}
```

#### 2-5. `.gitignore` への追加

```text
# キャッシュ（git に含めない）
out/.cache/
out/**/*.svg
out/**/*.tex
out/**/*.png
```

### 実装手順

| Step | 作業 | 見積 | 依存 |
| ------ | ------ | ------ | ------ |
| 2-A | `scripts/fence-render.mjs` を実装（単一フェンス render） | 1.5h | なし |
| 2-B | `scripts/render.mjs` を改造、キャッシュ logic を追加 | 2.5h | 2-A |
| 2-C | マニフェスト format と load/save を実装 | 1h | 2-B |
| 2-D | `scripts/figures.mjs` をキャッシュ対応に改造 | 1.5h | 2-C |
| 2-E | `.gitignore` に cache エントリを追加 | 0.5h | 2-C |
| 2-F | 既存 SVG を削除して初回 render（フル） | 1h | 2-E |
| 2-G | 差分修正（例：1 題のみ修正）して `npm run render` を実行、差分のみ render されることを確認 | 1.5h | 2-F |
| 2-H | `npm run figures` でマニフェストを使用して画像行を更新 | 1h | 2-D |
| 2-I | GitHub Actions の pages.yml で `npm run render` の時間を計測、改善率を検証 | 1h | 2-H |
| **計** | | **12h** | |

### パフォーマンス目標

- **フル render（初回）** — 現状のまま（全 300 題、数分）
- **差分 render（1 題修正）** — キャッシュなし 数分 → キャッシュ あり <30s
- **300 題のうち 10 題修正** — <1 分（hash 比較 + 10 題の render）

### テスト方法

```bash
# 初回：キャッシュを削除して full render
rm -rf out/.cache out/**/*.svg
npm run render --verbose
# out/.cache/manifest.json が生成される

# 1 題を修正
echo "# 修正" >> 01-circuits/01-basics/01-led.md

# 差分 render（ほぼ瞬時）
npm run render --verbose
# "01-led: キャッシュ（スキップ）" が出る
# マニフェストが更新されない

# 回復
git checkout 01-circuits/01-basics/01-led.md
```

---

## 統合スケジュール

| Phase | 内容 | Duration | Start | End |
| ------- | ------ | ---------- | ------- | ----- |
| **Phase 1** | スキーマ検証（1-A 〜 1-G） | 10h | Week 1 Mon | Week 1 Fri |
| **Phase 2** | キャッシュ化（2-A 〜 2-I） | 12h | Week 2 Mon | Week 2 Fri |
| **Phase 3** | 統合テスト・CI 更新 | 3h | Week 3 Mon | Week 3 Tue |
| **総計** | | **25h** | | |

### マイルストーン

1. **Week 1 Fri** — `npm run check` で 300 題をスキーマ検証。既存題の問題を修正。
2. **Week 2 Fri** — `npm run render --verbose` で差分 render を実装。ベンチマーク取得。
3. **Week 3 Tue** — GitHub Actions で新しい pages.yml をテスト。本番導入。

---

## リスク・mitigations

| Risk | Impact | Mitigation |
| ------ | -------- | ----------- |
| スキーマが冊のニーズに合わない | 新題で検証エラーが多発 | schema の `allOf` で冊別条件を先に検証。trial run で 5 題ずつ確認 |
| キャッシュの hash ズレ（内容が変わったのに見落とし） | SVG が古いまま Pages に載る | manifest に mtime も記録。スクリプト修正時は `--clear-cache` フラグで強制更新 |
| 既存題の front matter が多数不正 | Phase 1 で大量の修正作業 | 最初に全題を scan、问题数を把握。多ければ自動修正 script を用意 |
| fence 道具のバージョンアップで render 結果が変わる | キャッシュが無効化される | package.json に hash を埋め込み（tool version の part）。version 変更時は自動 cache clear |

---

## 次のステップ

1. **Week 1 Mon** — このプランで team review
2. **Week 1 Mon 午後** — スキーマ JSON と validate-entry.mjs の実装開始
3. **Week 1 Thu** — 既存題の schema 検証実行、問題集計
4. **Week 2 Mon** — キャッシュ実装開始
5. **Week 3** — 統合テストと本番導入

---

## 参考：既存スクリプトの依存関係

```text
check.mjs
  ├→ entry.mjs (front matter 解析)
  ├→ fences.mjs (フェンス名検証)
  └→ 各 fence CLI (circuit, breadboard, ...)

render.mjs
  └→ 各 fence CLI (circuit, breadboard, ...)

toc.mjs
  └→ plan.mjs (plan.yaml 読み込み)

figures.mjs
  └→ out/ スキャン
```

**新スクリプト追加後の依存：**

```text
check.mjs
  ├→ entry.mjs
  ├→ fences.mjs
  ├→ validate-entry.mjs ✨ (新規)
  └→ 各 fence CLI

render.mjs ✨ (改造)
  ├→ fence-render.mjs ✨ (新規、フェンス 1 個 render)
  └→ 各 fence CLI

figures.mjs ✨ (改造)
  └→ manifest.json キャッシュ ✨
```
