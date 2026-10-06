# tommie-circuit-workbook

> [!WARNING]
> この本は AI (Claude) が書いたもので、人間の専門家の校正を受けていない。
> 回路・数値・手順が間違っている可能性がある。組む前に自分で確かめてほしい。

回路・Analog Discovery・NanoVNA・電験三種・FPGA の 5 冊と番外の工作の実験帳。回路図と実体配線図は
[tommie-fence](https://github.com/tommie-jp/tommie-fence) の Markdown フェンス
(` ```circuit ` / ` ```breadboard ` / ` ```perfboard `)、銅張り基板の寸法図は ` ```copper `、NanoVNA の画面は ` ```vna `、オシロスコープの画面は ` ```scope `、ロジックアナライザの画面は ` ```logic `、
周波数特性や特性曲線のグラフは ` ```graph ` で書く。

標準の計器は Analog Discovery 3・LiteVNA64・tinySA Ultra ZS405、マイコンは Raspberry Pi Pico 2
(プログラムは C / C++ が第 1、MicroPython が第 2 で併記)。一覧は [回路の教科書](01-circuits/README.md) にある。

## 冊

<!-- toc:start -->

| 冊 | 内容 | 必須 | 入門 | 中級 | 済 |
| --- | --- | --- | --- | --- | --- |
| [回路の教科書](01-circuits/README.md) | 直流の基本から実用回路まで。回路図と実体配線図を並べて組む | 50 | 104 | 216 | 119 |
| [Analog Discovery の教科書](02-analog-discovery/README.md) | Analog Discovery 3 と WaveForms で DC〜10 MHz を測る | 50 | 100 | 200 | 100 |
| [NanoVNA の教科書](03-nanovna/README.md) | LiteVNA64 で 50 kHz〜6.3 GHz を測る (NanoVNA-H4 / V2 は比較用)。治具・部品・フィルタ・アンテナ・GHz 帯。第 11 章でスペクトラムアナライザ (tinySA など) | 50 | 105 | 214 | 106 |
| [電験三種の教科書](04-denken/README.md) | 理論・機械・電力・法規の範囲を、低い電圧の実験で測って式を確かめる | 50 | 100 | 200 | 100 |
| [番外の工作](05-etc/README.md) | 4 冊の部品を組み合わせて作る工作。CPU もどき、中波ラジオの時報で動く時計、デュアルゲート FET ミキサー、2SC1815 のミキサー | 0 | 0 | 12 | 12 |
| [FPGA の教科書](06-fpga/README.md) | 1 本の Verilog をブラウザ・Raspberry Pi Pico 2 (Soft-FPGA)・実物の FPGA で動かし、Analog Discovery 3 の Logic で測って比べる | 50 | 100 | 200 | 28 |

<!-- toc:end -->

どの冊も **必須 50 ⊂ 入門 100 ⊂ 中級 200** の 3 段。段は入れ子で、
「必須だけ」「入門まで」で止めても一通りになるように並べる。
必須・入門・中級は計画 (各冊の `plan.yaml`) の数で入れ子で数え、済 は書き終えた
題の数。各冊の README に 200 題の目次があり、書き終えた題は link になっている。

## 読み方

- 部品の型番のデータシートは [部品のデータシート (リンク集)](datasheets.md)

- GitHub では、各フェンス (YAML の字) の直後に、その図が画像で出る。図は main に push するたびに
  [GitHub Pages](https://tommie-jp.github.io/tommie-circuit-workbook/) へ描き直して載せる
  (`.github/workflows/pages.yml`)。push の直後の数分は前の図が出る
- 書きながら図を見るには VS Code 拡張 tommie-fence
  ([Release](https://github.com/tommie-jp/tommie-fence/releases) の `.vsix`) を入れて
  Markdown のプレビューを開く (プレビューでは画像の行を `.vscode/hide-github-figures.css` で隠す)
- 手元で SVG に書き出すなら `npm ci && npm run render` (`out/` に出る。コミットしない)

## 書き方

1 題 1 ファイル。置き場は `<NN-冊>/<NN-章>/<NN-題>.md` (冊・章・題の番号は 2 桁、
名前は英小文字とハイフン)。頭に front matter を書き、本文の最初の見出しは
`# <id> <title>` にする。

```yaml
---
book: circuits          # circuits / analog-discovery / nanovna / denken / fpga (置き場の冊から番号を除いた名前)
chapter: 1              # 置き場の章の番号
id: 1-1                 # 章-番号 (ファイル名の番号と同じ)
title: LED を点ける — 抵抗で電流を決める
tier: 50                # 50 = 必須 / 100 = 入門 / 200 = 中級
source: 自作            # 出典。借りた回路なら出所 (例: Lessons in Electric Circuits Vol. VI ch.5)
board: BB               # 任意。BB = ブレッドボード / PF = perfboard / CB = 銅張り基板 (copper board) / — = 基板なし
device: LV64            # nanovna は必須 (LV64 標準 / H4・V2 は歴史的)。analog-discovery は AD3 でしかできない題だけ AD3
era: 古                 # circuits だけ、任意。古 = 知っておきたい古典 / 今 = 今の定番 / 古/今
tools: [AD, VNA]        # 任意。2 つの計器を両方使う題
---
```

本文は **説明 → 回路図 (circuit) → 実体配線図 (breadboard / perfboard)・銅張り基板の寸法図 (copper) →
計器の設定 (NanoVNA の本は画面の図 `vna`、オシロで波形を見る題は `scope` も) → 見るべき値
(計算した特性は `graph` のグラフも) → 出典** の順。

**どの題にも、特に理由がなければ次の 3 つを入れる** (読んだ回路をそのまま組んで、計器で確かめられるように):

- **実体配線図** — 基板の範囲 (各冊の README) に収まればブレッドボード、超えれば perfboard か copper
- **Analog Discovery 3** — 基板の外の機器 (`type: device`) で描き、電源 (Supplies) と信号 (Wavegen) とオシロ (Scope) の線をピンの名前で配線する
- **オシロスコープの図** (`scope`) — 計器の設定の下に、見えるはずの波形。「見るべき値」は `cursors:` と `measure:` で図にも出す

入れないときは、その理由を題に 1 行書く。理由になるのは次のときだけ:

| 入れないもの | 理由になること |
| --- | --- |
| 実体配線図 | 組まない題 (計算・理論だけ)。商用電源に繋ぐ回路。どの基板の範囲にも収まらない回路 |
| Analog Discovery 3 | 計器の範囲の外 (10 MHz を超える信号、S パラメータは VNA、スペクトルは tinySA)。組まない題。電源装置そのものが題材の題 (01-circuits の第 13 章。AD3 の Supplies は 250 mW までなので、定電圧・定電流の実験は電源装置で行い、出力は AD3 の Scope で見る) |
| オシロの図 | 時間で変わらない量 (直流の電圧・電流・抵抗) だけを見る題。10 MHz を超えてオシロで見えない題 (spectrum か vna の図にする)。S パラメータを見る題 (vna の図)。組まない題 |

**段と周波数**: 必須・入門の題は、回路が働く周波数を **3 MHz 以下**に絞る (ブレッドボードの範囲と
Analog Discovery 3 のオシロの帯域の内側で、組んだとおりに測れる)。3 MHz を超える題は中級に置く。
必須・入門に置くときは、超える理由を題に 1 行書く (FM 放送帯が題材で銅張り基板に組む、など)。
NanoVNA の冊は測る帯域が題材なので、この絞りを課さない。手順は `.claude/skills/workbook-writing/SKILL.md`。

**用語の統一**: 「ひずみ」は漢字で書く (歪み・歪み率)。「センサー」は長音を付ける。
計器の信号源は「信号発生器」(AD3 の Wavegen、NanoVNA の出力など)、回路として発振するものは「発振回路」と書き分け、
「発振器」は部品としての発振子 (水晶発振器など) に使う。

回路例の電源は**既定で 5 V** にする。必要があれば 9 V や 12 V にする。5 V は
USB アダプタやモバイルバッテリー、単 3 電池 3 本で用意できて簡単だから。
両電源が要る題は **±5 V** (Analog Discovery の Supplies)。5 V で成り立たない題
(リレーやモータの定格、トランスの 12 V AC アダプタ、レギュレータや降圧の入力など) は、
部品表の電源の行に**理由を書く** (例: 「12 V — リレーのコイル電圧」)。理由の無い 9 V は使わない。

**部品の値は E24** から選ぶ。コンデンサとインダクタは E12 に入る値を優先する (電解は E6)。
系列に無い値は E24 の 2 本の直列か並列で作ってよく、そのときは部品表に
「R1 400 Ω — 200 Ω を 2 本直列」のように書き、ブレッドボード図・基板図には実物の 2 本を描く。
どちらでも作れない値は最寄りの E24 に丸め、期待値を丸めた値で計算し直す。可変抵抗は市販の値
(B5K など) でよい。等価回路・寄生分の図は題か本文に「等価回路」と書き、手巻きのコイルは
部品表に巻き数と線径を書く。読者が買える部品で組めるようにするため
(流儀の本体は [electronics-drawing-skills](https://github.com/tommie-jp/electronics-drawing-skills) の readable-schematic §1 #13)。

200 題の計画は各冊の `plan.yaml` (1 行 1 題: `id` `tier` `title` と印)。題を書くときは
計画の `id` と `title` と `tier` をそのまま front matter に写す。題を書き換えたら
`plan.yaml` も直す (計画が目次の元。ずれると `check` が言う)。

## 検査

```bash
npm ci
npm run all    # 試験・Markdown の lint・全題の検査 (CI と同じ)
npm run toc    # 題を足したら目次を書き直す (README の印の間だけ)
npm run figures   # フェンスを足した・消した・動かしたら、GitHub で見せる画像の行を書き直す
npm run check -- --verbose   # ネットリストも出す。意図した回路と突き合わせる
```

`check` は置き場と front matter の食い違い、フェンス名の書き間違い、フェンスの
読めない行、`plan.yaml` とのずれ (計画に無い題、違う title や tier)、古い目次、
フェンスの並びと合わない画像の行で落ちる。画像の行 (Pages の図を指す `![…](https://tommie-jp.github.io/…)`) は
`npm run figures` が書くので手で直さない。ERC (つながっていないピンなど) は出すだけで落とさない。

## ライセンス

本文と図は [CC BY 4.0](LICENSE)。借りた回路は front matter の `source` と本文の
出典に出所を書く。借りた写真は元のライセンスのままで、作者とライセンスを写真の下に書く。
フェンスを描く道具 (tommie-fence) は MIT で、このリポジトリは
その Release を使うだけ。
