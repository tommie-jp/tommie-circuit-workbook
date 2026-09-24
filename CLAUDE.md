# tommie-circuit-workbook

回路・Analog Discovery・NanoVNA・電験三種の 4 冊の実験帳。本文は日本語、ライセンスは
CC BY 4.0。回路図と実体配線図は tommie-fence のフェンス
(` ```circuit ` / ` ```breadboard ` / ` ```perfboard `)、NanoVNA の画面は ` ```vna ` で書く。

## 置き場と書き方

- 1 題 1 ファイル: `<NN-冊>/<NN-章>/<NN-題>.md` (冊は 01-circuits / 02-analog-discovery /
  03-nanovna / 04-denken)。冊と章の表は `scripts/books.mjs`。front matter の `book` は番号を除いた名前
- 頭に front matter (鍵と値の決まりは README の「書き方」と `scripts/entry.mjs`)。
  本文の最初の見出しは `# <id> <title>`
- 本文の順: 説明 → 回路図 → 実体配線図 → 計器の設定 → 見るべき値 → 出典
- 各冊の 200 題の計画は `<NN-冊>/plan.yaml` (1 行 1 題)。題を書くときは計画の `id` `title`
  `tier` を front matter に写し、題を書き換えたら計画も直す (ずれは `check` が言う)
- 各冊の `README.md` の `<!-- toc:start -->` 〜 `<!-- toc:end -->` の間は
  `npm run toc` が `plan.yaml` と front matter から書く。**手で直さない**
  (印の外の前書きは手で書く)。書いた題は link、まだの題は字だけ
- 借りた回路は `source` と本文の出典に出所を書く。図と文は写さず描き直す
- 扱わないもの: 真空管、商用電源 (AC 100 V) に直に繋ぐ回路
- 電験三種の冊は過去問を写さない (問題文・数値・図とも)。試験の範囲の単元から実験を起こす。
  回路図は `style:` に `standard: european` (試験の図と同じ四角い抵抗)

## フェンスを書くとき

- 文法は tommie-fence の `packages/<x>-fence/docs/02-cheatsheet.md` と `01-syntax.md`。
  3 つは似ているが同じではない (番地、`board:`、注釈の種類、DIP の書き方)
- 書いたら `npm run check -- --verbose` でネットリストを出し、意図した回路と突き合わせる
- 字の重なりや配線の見え方は check では分からない。`npm run render` の SVG か、
  VS Code 拡張のプレビューで見る
- Analog Discovery と NanoVNA は板の外の機器 (`type: device`) で描き、足の名前で配線する
- NanoVNA の本の題は、計器の設定の下に ` ```vna ` で**見えるはずの画面** (`dut:` の理想の模型) を
  描く。測ったら Touchstone を題のファイルの隣に置いて `data:` で重ねる (`.s2p` はコミットする)

## コミットの前に

```bash
npm run toc   # 題を足した・動かしたら
npm run all   # 試験・lint・全題の検査 (CI と同じ)
```

- `out/` (図) はコミットしない。測った値 (Touchstone・CSV) はコミットする
- コミットは conventional commits (`docs:` が中心、スクリプトは `feat:` / `fix:`)。
  マージは fast-forward のみ
- フェンスの版は `package.json` の Release の URL で固定している。上げるときは
  URL を書き換えて `npm install` し、`npm run all` が通ることを確かめる
