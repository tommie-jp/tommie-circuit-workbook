# tommie-circuit-workbook

回路・Analog Discovery・NanoVNA の 3 冊の実験帳。回路図と実体配線図は
[tommie-fence](https://github.com/tommie-jp/tommie-fence) の Markdown フェンス
(` ```circuit ` / ` ```breadboard ` / ` ```perfboard `) で書く。

## 3 冊

<!-- toc:start -->

| 冊 | 内容 | 必須 | 入門 | 中級 |
| --- | --- | --- | --- | --- |
| [回路の教科書](circuits/README.md) | 直流の基本から実用回路まで。回路図と実体配線図を並べて組む | 1 | 1 | 1 |
| [Analog Discovery の教科書](analog-discovery/README.md) | Analog Discovery 2 / 3 と WaveForms で DC〜10 MHz を測る | 1 | 1 | 1 |
| [NanoVNA の教科書](nanovna/README.md) | NanoVNA-H4 / V2 で 10 kHz〜4.4 GHz を測る。治具・部品・フィルタ・アンテナ・GHz 帯 | 1 | 1 | 1 |

<!-- toc:end -->

どの冊も **必須 50 ⊂ 入門 100 ⊂ 中級 200** の 3 段。段は入れ子で、
「必須だけ」「入門まで」で止めても一通りになるように並べる。
上の数は書き終えた題の数 (入れ子で数える)。

## 読み方

- GitHub ではフェンスは YAML の字のまま見える。**図にして読むには** VS Code 拡張
  tommie-fence ([Release](https://github.com/tommie-jp/tommie-fence/releases) の
  `.vsix`) を入れて Markdown のプレビューを開く
- 手元で SVG に書き出すなら `npm ci && npm run render` (`out/` に出る。コミットしない)

## 書き方

1 題 1 ファイル。置き場は `<冊>/<NN-章>/<NN-題>.md` (章と題の番号は 2 桁、
名前は英小文字とハイフン)。頭に front matter を書き、本文の最初の見出しは
`# <id> <title>` にする。

```yaml
---
book: circuits          # circuits / analog-discovery / nanovna (置き場の冊と同じ)
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
計器の設定 → 見るべき値 → 出典** の順。

## 検査

```bash
npm ci
npm run all    # 試験・Markdown の lint・全題の検査 (CI と同じ)
npm run toc    # 題を足したら目次を書き直す (README の印の間だけ)
npm run check -- --verbose   # ネットリストも出す。意図した回路と突き合わせる
```

`check` は置き場と front matter の食い違い、フェンス名の書き間違い、フェンスの
読めない行、古い目次で落ちる。ERC (つながっていない足など) は出すだけで落とさない。

## ライセンス

本文と図は [CC BY 4.0](LICENSE)。借りた回路は front matter の `source` と本文の
出典に出所を書く。フェンスを描く道具 (tommie-fence) は MIT で、このリポジトリは
その Release を使うだけ。
