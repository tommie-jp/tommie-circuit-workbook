# tommie-circuit-workbook

> [!WARNING]
> この 4 冊は AI (Claude) が書いたもので、人間の専門家の校正を受けていない。
> 回路・数値・手順が間違っている可能性がある。組む前に自分で確かめてほしい。

回路・Analog Discovery・NanoVNA・電験三種の 4 冊の実験帳。回路図と実体配線図は
[tommie-fence](https://github.com/tommie-jp/tommie-fence) の Markdown フェンス
(` ```circuit ` / ` ```breadboard ` / ` ```perfboard `)、NanoVNA の画面は ` ```vna ` で書く。

## 4 冊

<!-- toc:start -->

| 冊 | 内容 | 必須 | 入門 | 中級 | 済 |
| --- | --- | --- | --- | --- | --- |
| [回路の教科書](01-circuits/README.md) | 直流の基本から実用回路まで。回路図と実体配線図を並べて組む | 50 | 100 | 200 | 1 |
| [Analog Discovery の教科書](02-analog-discovery/README.md) | Analog Discovery 2 / 3 と WaveForms で DC〜10 MHz を測る | 50 | 100 | 200 | 50 |
| [NanoVNA の教科書](03-nanovna/README.md) | NanoVNA-H4 / V2 で 10 kHz〜4.4 GHz を測る。治具・部品・フィルタ・アンテナ・GHz 帯 | 50 | 100 | 200 | 50 |
| [電験三種の教科書](04-denken/README.md) | 理論・機械・電力・法規の範囲を、低い電圧の実験で測って式を確かめる | 50 | 100 | 200 | 1 |

<!-- toc:end -->

どの冊も **必須 50 ⊂ 入門 100 ⊂ 中級 200** の 3 段。段は入れ子で、
「必須だけ」「入門まで」で止めても一通りになるように並べる。
必須・入門・中級は計画 (各冊の `plan.yaml`) の数で入れ子で数え、済 は書き終えた
題の数。各冊の README に 200 題の目次があり、書き終えた題は link になっている。

## 読み方

- GitHub ではフェンスは YAML の字のまま見える。**図にして読むには** VS Code 拡張
  tommie-fence ([Release](https://github.com/tommie-jp/tommie-fence/releases) の
  `.vsix`) を入れて Markdown のプレビューを開く
- 手元で SVG に書き出すなら `npm ci && npm run render` (`out/` に出る。コミットしない)

## 書き方

1 題 1 ファイル。置き場は `<NN-冊>/<NN-章>/<NN-題>.md` (冊・章・題の番号は 2 桁、
名前は英小文字とハイフン)。頭に front matter を書き、本文の最初の見出しは
`# <id> <title>` にする。

```yaml
---
book: circuits          # circuits / analog-discovery / nanovna / denken (置き場の冊から番号を除いた名前)
chapter: 1              # 置き場の章の番号
id: 1-1                 # 章-番号 (ファイル名の番号と同じ)
title: LED を点ける — 抵抗で電流を決める
tier: 50                # 50 = 必須 / 100 = 入門 / 200 = 中級
source: 自作            # 出典。借りた回路なら出所 (例: Lessons in Electric Circuits Vol. VI ch.5)
board: BB               # 任意。BB = ブレッドボード / PF = perfboard / 銅 = 銅張り基板 / — = 板なし
device: H4              # nanovna は必須 (H4 / V2)。analog-discovery は AD3 でしかできない題だけ AD3
era: 古                 # circuits だけ、任意。古 = 知っておきたい古典 / 今 = 今の定番 / 古/今
tools: [AD, VNA]        # 任意。2 つの計器を両方使う題
---
```

本文は **説明 → 回路図 (circuit) → 実体配線図 (breadboard / perfboard) →
計器の設定 (NanoVNA の本は画面の図 `vna` も) → 見るべき値 → 出典** の順。

200 題の計画は各冊の `plan.yaml` (1 行 1 題: `id` `tier` `title` と印)。題を書くときは
計画の `id` と `title` と `tier` をそのまま front matter に写す。題を書き換えたら
`plan.yaml` も直す (計画が目次の元。ずれると `check` が言う)。

## 検査

```bash
npm ci
npm run all    # 試験・Markdown の lint・全題の検査 (CI と同じ)
npm run toc    # 題を足したら目次を書き直す (README の印の間だけ)
npm run check -- --verbose   # ネットリストも出す。意図した回路と突き合わせる
```

`check` は置き場と front matter の食い違い、フェンス名の書き間違い、フェンスの
読めない行、`plan.yaml` とのずれ (計画に無い題、違う title や tier)、古い目次で落ちる。ERC (つながっていない足など) は出すだけで落とさない。

## ライセンス

本文と図は [CC BY 4.0](LICENSE)。借りた回路は front matter の `source` と本文の
出典に出所を書く。フェンスを描く道具 (tommie-fence) は MIT で、このリポジトリは
その Release を使うだけ。
