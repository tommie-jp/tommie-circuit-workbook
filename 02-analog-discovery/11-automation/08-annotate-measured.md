---
book: analog-discovery
chapter: 11
id: 11-8
title: 測った値を tommie-fence の図に注釈で載せる
tier: 200
source: 自作 (図は tommie-fence の graph・scope フェンス)
board: —
---

# 11-8 測った値を tommie-fence の図に注釈で載せる

この教科書の図は、どれも「見えるはずの画面」(理想) で描いてある。組んで測ったら、**測った値を同じ図に重ね**、本文の表の数を**注釈で図にも書く**。
理想の線と測った点が 1 枚に並ぶと、どこが合ってどこがずれたかが文より先に目に入る。この題は、11-1 の掃引の表を例に、その手順を通す。

1. 測った値を CSV にして、題の `.md` と同じ場所に置く (`data:` は同じ場所のファイルだけを読む)
2. 図のフェンスに `data: <ファイル名>` を足す (graph は ○ の点、scope・spectrum は実線で重なり、理想は破線になる)
3. `notes:` の `mark` `text` で、本文の「見るべき値」の数を図の上に書く
4. `check` の読み値を本文の表と突き合わせ、合わなければ本文を実測に合わせて、差の理由を 1 行書く
5. front matter に `measured: <測った日>` を書く (README の「書き方」)。測った CSV はコミットする

この題は基板を使わない (組まない題。手順と図の書き方だけを扱い、測る回路は 11-1 の図1・図2)。

## 計器の設定

計器は使わない。11-1 の Script の出力 (タブ区切りの表) を、graph フェンスの読める CSV に直す。graph の `data:` は
**1 列めが x、見出しの括弧の中が単位** (`周波数 (Hz)`) で、単位と名前の合う線 (`理論 dB`) に当たる。

```python
import csv
import sys

# 11-1 の Script の表 (タブ区切り) を、graph フェンスの data: が読む CSV に直す
src, dst = sys.argv[1], sys.argv[2]
with open(src, encoding="utf-8") as fin, open(dst, "w", newline="", encoding="utf-8") as fout:
    w = csv.writer(fout)
    w.writerow(["周波数 (Hz)", "利得 (dB)"])      # 見出しの括弧の中が単位。線のキー「理論 dB」と単位で当たる
    for row in csv.reader(fin, delimiter="\t"):
        if row and row[0][0].isdigit():
            w.writerow([row[0], row[3]])
```

`python tsv2csv.py sweep.tsv 11-1-sweep.csv` でできる CSV の頭は次のとおり。

```text
周波数 (Hz),利得 (dB)
100,-0.02
300,-0.15
1000,-1.45
```

11-1 の図4 のフェンスに、`data:` の 1 行と注釈を足す (`text` は「番地: 字」の形で、番地は x と単位つきの y)。

```yaml
x: 周波数 Hz log 100..300k
y: 利得 dB -50..0
lines:
  理論 dB: -10*log10(1+(x/1.5915k)^2)
data: 11-1-sweep.csv
notes:
  - level -3dB
  - mark 3k
  - text 60k -14dB: 3 kHz で −6.58 dB (表の値)
```

測る前の今は CSV が無いので、`data:` を除いて描くと図1 になる。`text` の字は本文の表の数を写し、表が変われば図も直す。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図1 注釈を足した 11-1 の図 — 測ったら data の 1 行で ○ が重なる
x: 周波数 Hz log 100..300k
y: 利得 dB -50..0
lines:
  理論 dB: -10*log10(1+(x/1.5915k)^2)
notes:
  - level -3dB
  - mark 3k
  - text 60k -14dB: 3 kHz で −6.58 dB (表の値)
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/graph/08-annotate-measured.svg)

scope・spectrum も同じ流れで、WaveForms の Scope の書き出し (Export の CSV) と Spectrum の 2 列の CSV は、そのまま `data:` で読める
(フェンスの文法の「測った値」の節)。scope では、本文の数を `cursors:` と `measure:` で出し、`notes:` の `text` は**時刻 電圧**の番地で書く。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図2 11-1 の 3 kHz の画面に、表の数を注釈で書いた形
time: 100us/div
trigger: ch1 rising 0V
ch1: {wave: sine 3kHz 1V, range: 500mV/div}
ch2: {wave: ch1 | rc 100us, range: 500mV/div}
measure: [vpp]
notes:
  - text ch2 141us 0.469V: CH2 0.469 V (−6.58 dB)
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/scope/08-annotate-measured.svg)

測ったら `data: 11-1-3k.csv` の 1 行を足す。計算で作った CSV を重ねるときは、ファイル名の後ろに `計算` と書き (`data: x.csv 計算`)、
凡例が「実測」にならないようにする。NanoVNA の教科書の 10-8 は、同じ手順を Touchstone (`.s2p`) と vna フェンスで行う。

この節の Python は、11-1 の表 (理論の 8 点) を入れた `sweep.tsv` で PC で動かし、できた CSV を `data:` に渡した graph フェンスが 8 つの ○ を
理論の線の上に打つこと (3 kHz の読み値 −6.58 dB) を確かめた。AD3 で測った表ではまだ動かしていない (実機は未確認)。

## 見るべき値

計算値。図1・図2 の読み値 (`check`) と本文の数の突き合わせ。

| 図 | `check` の読み値 | 本文の数 | 合わないとき |
| --- | --- | --- | --- |
| 図1 (mark 3k) | −6.58 dB | 11-1 の表 −6.58 dB | 線の式か mark の周波数を直す |
| 図2 (Vpp) | CH2 0.94 Vpp (0.469 V の 2 倍) | 0.469 V | `rc` の時定数 (R × C = 100 µs (マイクロ秒)) を直す |
| data を足した後 | 「実測 (11-1-sweep.csv)」の列が増える | 測った値 | 測った値が正しいなら本文の表を実測に合わせ、差の理由を 1 行書く |

- `data:` の CSV は `.md` と同じ場所のファイルだけ。`/` や `..` で別の場所を指すと読まない
- 注釈の字に `,` は書けない。数を並べるときは `・` で区切る
- 測った CSV は消さずにコミットする (図の元になる)。図の SVG・PNG (`out/`) はコミットしない

## LTspice での確かめ (対象外)

回路を足さない、図の書き方の題なので SPICE の対象外。図の数は 11-1 の LTspice の表 (3 kHz で −6.583 dB、0.469 倍) を指す。
図2 の CH2 の振幅は 1 V ÷ √(1 + (2π × 3 kHz × 100 µs)²) = 0.469 V と算術で確かめた。

## 出典

自作。図のフェンスの書き方は [tommie-fence](https://github.com/tommie-jp/tommie-fence) の graph・scope フェンスの文法。
