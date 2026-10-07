---
book: nanovna
chapter: 12
id: 12-5
title: 直列と並列 — 直列は R の円の上を、並列は G の円の上を動く
tier: 200
source: 自作
board: BB
device: LV64
---

# 12-5 直列と並列 — 直列は R の円の上を、並列は G の円の上を動く

12-2 では、50 Ω に**直列**の部品を足すと、点が r = 1 の円の上を動くのを見た。この題では、負荷に**並列**の部品を足したときの動きを加えて、
次の 2 つの決まりに整理する。整合回路 (12-6) は、この 2 つの決まりだけで組める。

- **直列の部品**は**インピーダンス Z** に足される (Z + jX)。実部が変わらないので、**r の円の上**を動く
- **並列の部品**は**アドミタンス Y** (= 1 / Z) に足される (Y + jB)。コンダクタンス g が変わらないので、**g の円の上**を動く。
  g の円は、**r の円を中心に対して反対側へ鏡のように写した円**で、やはり右端で接する

> **この章の図は理想の模型から計算した画面で、実機では測っていない。**

## 動く向きは L か C かで決まる

| 部品 | つなぎ方 | 動く円 | 動く向き |
| --- | --- | --- | --- |
| コイル | 直列 | r の円 | 上 (誘導性の側) |
| コンデンサ | 直列 | r の円 | 下 (容量性の側) |
| コンデンサ | 並列 | g の円 | 下 (容量性の側) |
| コイル | 並列 | g の円 | 上 (誘導性の側) |

- **向きは、コイルなら上、コンデンサなら下**。直列でも並列でも変わらない (上は誘導性、下は容量性なのは、Z で読むかぎり、どの点でも成り立つ)
- 変わるのは**どの円の上を動くか**。同じ負荷 (ここでは 24 Ω) に直列と並列で同じコンデンサを付けると、下へは動くが、途中の道筋が違う
- 並列の部品は、**周波数が低いほど動きが小さい** (コンデンサの B = ωC は周波数に比例)。直列のコイルの X = ωL も周波数に比例して大きくなる

## 掃引の設定

計器は VNA。この本の図は LiteVNA64 の画面に合わせて書いてあり、NanoVNA-H4 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

4 つの回路は 1 枚のブレッドボードに並べて挿しておき、VNA の RF の線を測る回路の列へ挿し替えて 1 つずつ測る (実体配線図は図 5)。各 vna の図の前には、その回路だけの回路図を付ける。負荷 24 Ω は [03-nanovna/12-smith-chart/06-l-match.md](06-l-match.md) と同じ値。周波数は 3 MHz までにした (ブレッドボードの寄生が見えない範囲。理由は [03-nanovna/12-smith-chart/01-map.md](01-map.md) の掃引の設定)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 kHz〜3 MHz |
| 点数 | 101 |
| 校正 | SOLT (1-1) の Open / Short / Load を**ブレッドボードの上で**取る (手順は [03-nanovna/12-smith-chart/01-map.md](01-map.md) の「測る前に」) |
| 表示 | S11 の Smith チャート。マーカー 500 kHz・1・2・3 MHz |

## 直列の部品

24 Ω (z = 0.48) の負荷に、**直列**のコイル (3.9 µH (マイクロヘンリー)) とコンデンサ (10 nF) を足す。

```circuit
title: 図1 の回路 (24 Ω に直列のコイル L1 3.9 µH)
parts:
  J1: sma 2,3 mirror
  G0: ground 2,4
  L1: inductor 5,3 9,3 3.9u
  R1: resistor 9,3 9,5 24
  G2: ground 9,5
wires:
  - J1.1 -- 5,3
  - J1.2 -- 2,4
notes:
  - text 7,2 small center: 入口
  - text 9,7 small center: 負荷
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/05-series-shunt-1.svg)

```vna
sweep: 100k-3M 101
title: 図1 24 Ω に直列のコイル 3.9 µH — r = 0.48 の円の上を上へ
dut:
  - series L 3.9u
  - series R 24
  - short
traces:
  - S11 smith
markers:
  - 500k
  - 1M
  - 2M
  - 3M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/05-series-shunt-1.svg)

```circuit
title: 図2 の回路 (24 Ω に直列のコンデンサ C1 10 nF)
parts:
  J1: sma 2,3 mirror
  G0: ground 2,4
  C1: capacitor 5,3 9,3 10n
  R1: resistor 9,3 9,5 24
  G2: ground 9,5
wires:
  - J1.1 -- 5,3
  - J1.2 -- 2,4
notes:
  - text 7,2 small center: 入口
  - text 9,7 small center: 負荷
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/05-series-shunt-2.svg)

```vna
sweep: 100k-3M 101
title: 図2 24 Ω に直列のコンデンサ 10 nF — r = 0.48 の円の上を下へ
dut:
  - series C 10n
  - series R 24
  - short
traces:
  - S11 smith
markers:
  - 500k
  - 1M
  - 2M
  - 3M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/05-series-shunt-2.svg)

## 並列の部品

同じ 24 Ω の負荷の**入口に並列**にコンデンサとコイルを足す (ケーブルの側から見て、負荷と並列)。

```circuit
title: 図3 の回路 (24 Ω に並列のコンデンサ C1 3.3 nF)
parts:
  J1: sma 2,3 mirror
  G0: ground 2,4
  C1: capacitor 5,3 5,5 3.3n
  G1: ground 5,5
  R1: resistor 9,3 9,5 24
  G2: ground 9,5
wires:
  - J1.1 -- 5,3
  - J1.2 -- 2,4
  - 5,3 -- 9,3
notes:
  - text 7,2 small center: 入口
  - text 9,7 small center: 負荷
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/05-series-shunt-3.svg)

```vna
sweep: 100k-3M 101
title: 図3 24 Ω に並列のコンデンサ 3.3 nF — g = 2.08 の円の上を下へ
dut:
  - shunt C 3.3n
  - series R 24
  - short
traces:
  - S11 smith
markers:
  - 500k
  - 1M
  - 2M
  - 3M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/05-series-shunt-3.svg)

```circuit
title: 図4 の回路 (24 Ω に並列のコイル L1 3.9 µH)
parts:
  J1: sma 2,3 mirror
  G0: ground 2,4
  L1: inductor 5,3 5,5 3.9u
  G1: ground 5,5
  R1: resistor 9,3 9,5 24
  G2: ground 9,5
wires:
  - J1.1 -- 5,3
  - J1.2 -- 2,4
  - 5,3 -- 9,3
notes:
  - text 7,2 small center: 入口
  - text 9,7 small center: 負荷
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/05-series-shunt-4.svg)

```vna
sweep: 100k-3M 101
title: 図4 24 Ω に並列のコイル 3.9 µH — g = 2.08 の円の上を上へ
dut:
  - shunt L 3.9u
  - series R 24
  - short
traces:
  - S11 smith
markers:
  - 500k
  - 1M
  - 2M
  - 3M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/05-series-shunt-4.svg)

- 図 3 の 1 MHz の点 (19.2 − j9.6 Ω) は、中心の左下に来る。**並列の C で、Z の実部は 24 Ω から下がり、虚部は容量性になる** (Z = 1 / (1/24 + jωC))
- 並列のコイルは逆に、上に動き、実部が下がる。**どちらも g = 2.08 の円**の上。直列の動き (図 1・図 2) は r = 0.48 の円

## 実体配線図

```breadboard
title: 図5 4 つの回路をブレッドボードに並べる (図1 を選んだ状態)
board: half
parts:
  VNA:
    type: device
    at: top
    label: VNA (SMA ケーブルの先)
    pins: [GND, RF]
  L1: inductor c3 c7 3.9u
  R1: resistor a7 -t7 24
  C1: capacitor/film c9 c13 10n
  R2: resistor a13 -t13 24
  C2: capacitor/ceramic a17 -t17 3.3n
  R3: resistor a21 -t21 24
  L2: inductor a24 -t24 3.9u
  R4: resistor a28 -t28 24
wires:
  - VNA.GND -- -t1 black
  - VNA.RF -- e3 orange
  - d17 -- d21 yellow
  - d24 -- d28 yellow
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/breadboard/05-series-shunt.svg)

- 列ごとに回路が 1 つ: **図 1 (直列の 3.9 µH) は 3 列目、図 2 (直列の 10 nF) は 9 列目、図 3 (並列の 3.3 nF) は 17 列目、図 4 (並列の 3.9 µH) は 24 列目**が入口。選ぶのはオレンジの線 1 本で、測る回路の入口の列の e の行へ挿し替える
- **直列** (図 1・図 2) は、入口の列からコイルかコンデンサが横に渡り、渡った先の列の 24 Ω が上の − レール (GND) へ下りる
- **並列** (図 3・図 4) は、入口の列のコンデンサかコイルがそのまま GND へ下り、黄色の短い線で隣の列の 24 Ω へつなぐ。入口から見て、部品と 24 Ω が並ぶ
- 上の − レールが GND で、黒い線で VNA の GND へ。校正はこのブレッドボードの上で取り、オレンジの線は校正したときのまま替えない ([03-nanovna/12-smith-chart/01-map.md](01-map.md) の「測る前に」)。コイルとコンデンサは挿す前に 1 本ずつ測っておく
- 部品は E12・E24: コイル 3.9 µH (軸付き)、コンデンサ 10 nF (フィルム) と 3.3 nF (セラミック、C0G がよい)、抵抗 24 Ω

## 見るべき値

計算値 (基準 50 Ω)。

| 図 | 周波数 | Z | z |
| --- | --- | --- | --- |
| 図1 (24 Ω + 3.9 µH) | 1 MHz | 24 + j24.5 Ω | 0.48 + j0.49 |
| 図2 (24 Ω + 10 nF) | 1 MHz | 24 − j15.9 Ω | 0.48 − j0.32 |
| 図3 (24 Ω ∥ 3.3 nF) | 1 MHz | 19.2 − j9.6 Ω | 0.38 − j0.19 |
| 図4 (24 Ω ∥ 3.9 µH) | 1 MHz | 12.2 + j12.0 Ω | 0.24 + j0.24 |

- **直列の動き (図 1・図 2) では実部が 24 Ω のまま**、並列の動き (図 3・図 4) では**実部が 24 Ω から下がっていく** (図 3 は 500 kHz の 22.6 Ω から 3 MHz の 7.4 Ω へ)。並列の部品は、Y に足すので、Z の実部も虚部も一緒に動く
- 並列でも直列でも、**上へ動くのはコイル、下へ動くのはコンデンサ**。次の題では、この 2 つの動きを組み合わせて、24 Ω を中心へ運ぶ

## 出典

自作。アドミタンス (g と b) の Smith チャートの考え方は、整合回路の教科書に共通する内容による。
