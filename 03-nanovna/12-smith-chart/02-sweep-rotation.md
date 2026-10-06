---
book: nanovna
chapter: 12
id: 12-2
title: 周波数を掃くと点が回る — 直列の L は上半分、C は下半分を時計回りに
tier: 100
source: 自作
board: BB
device: LV64
---

# 12-2 周波数を掃くと点が回る — 直列の L は上半分、C は下半分を時計回りに

12-1 の点は、周波数を変えても動かない抵抗か、外周を回る純粋なコイル・コンデンサだった。実際の負荷は、
抵抗にコイルやコンデンサが**直列**に付いている。この題では、**50 Ω の抵抗にコイルまたはコンデンサを直列に付けて周波数を掃く**と、
点が **R = 50 Ω の円** (z の実部が 1 の円) の上を**時計回りに**動くことを見る。最後に、コイルとコンデンサを両方付けると、
共振の周波数で実軸を横切ることを確かめる。

> **この章の図は理想の模型から計算した画面で、実機では測っていない。**

## 動き方の決まり

- **周波数を上げると、点はいつも時計回りに動く** (Smith のどの図でも、負荷の側から見た掃引はそう動く)
- 抵抗が変わらない部品を直列に付けると、**実部 r が一定のまま、虚部 x だけが動く**。つまり**その r の円の上**を動く
- コイルは x = ωL / 50 で、周波数に**比例して増える**。0 (実軸) から始まって、円の上半分を実軸の右端 (∞) へ向かう
- コンデンサは x = −1 / (50 ωC) で、周波数が低いほど負に大きい。低い周波数で円の右端 (∞) の近くから始まり、下半分を実軸へ向かって戻ってくる

## 掃引の設定

計器は VNA。この本の図は LiteVNA64 の画面に合わせて書いてあり、NanoVNA-H4 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

3 つの負荷は 1 枚のブレッドボードに並べて挿しておき、VNA の RF の線を測る負荷の列へ挿し替えて 1 つずつ測る (実体配線図は図 4)。
各 vna の図の前には、その負荷だけの回路図を付ける。周波数は 3 MHz までにした (ブレッドボードの寄生が見えない範囲。理由は [03-nanovna/12-smith-chart/01-map.md](01-map.md) の掃引の設定)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 kHz〜3 MHz (図 1・図 2)、300 kHz〜3 MHz (図 3) |
| 点数 | 101 |
| 校正 | SOLT (1-1)。ケーブルの先で Open / Short / Load |
| 表示 | S11 の Smith チャート |

## 50 Ω に直列のコイル

50 Ω に 8.2 µH (マイクロヘンリー) のコイルを直列に付けた負荷 (Z = 50 + jωL)。50 Ω は E24 に無いので、**100 Ω を 2 本並列**にして作る。**R = 50 Ω の円** (中心を通る円) の上半分を、中心から右へ回る。

```circuit
title: 図1 の回路 (50 Ω (100 Ω の 2 本並列) と 8.2 µH の直列)
parts:
  J1: sma c2 mirror
  G0: ground d2
  R1: resistor c5 c9 100
  R2: resistor a5 a9 100
  L1: inductor c9 e9 8.2u
  G1: ground e9
wires:
  - J1.1 -- c5
  - J1.2 -- d2
  - c5 -- a5
  - c9 -- a9
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/02-sweep-rotation-1.svg)

```vna
sweep: 100k-3M 101
title: 図1 50 Ω + 8.2 µH — r = 1 の円の上半分を中心から右へ
dut:
  - series R 50
  - series L 8.2u
  - short
traces:
  - S11 smith
markers:
  - 100k
  - 1M
  - 3M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/02-sweep-rotation-1.svg)

## 50 Ω に直列のコンデンサ

50 Ω (100 Ω の 2 本並列) に 3.3 nF のコンデンサを直列に付けた負荷 (Z = 50 − j / (ωC))。**同じ r = 1 の円の下半分**で、低い周波数では右端の近く (x が大きな負) から始まり、周波数を上げると中心へ近づく。

```circuit
title: 図2 の回路 (50 Ω (100 Ω の 2 本並列) と 3.3 nF の直列)
parts:
  J1: sma c2 mirror
  G0: ground d2
  R1: resistor c5 c9 100
  R2: resistor a5 a9 100
  C1: capacitor c9 e9 3.3n
  G1: ground e9
wires:
  - J1.1 -- c5
  - J1.2 -- d2
  - c5 -- a5
  - c9 -- a9
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/02-sweep-rotation-2.svg)

```vna
sweep: 100k-3M 101
title: 図2 50 Ω + 3.3 nF — r = 1 の円の下半分を右から中心へ
dut:
  - series R 50
  - series C 3.3n
  - short
traces:
  - S11 smith
markers:
  - 100k
  - 1M
  - 3M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/02-sweep-rotation-2.svg)

## コイルとコンデンサを両方 — 共振

25 Ω (12 Ω と 13 Ω の直列) に 8.2 µH と 3.3 nF を直列に付けた負荷。**共振周波数 f0 = 1 / (2π (パイ) √(LC)) ≈ 968 kHz** で、コイルとコンデンサのリアクタンスが打ち消し合って、純粋な抵抗 25 Ω (z = 0.5) になる。
f0 より下は容量性 (下半分)、上は誘導性 (上半分) で、**実軸をちょうど f0 で横切る**。r = 0.5 の円の上を、下から上へ時計回りに動く。

```circuit
title: 図3 の回路 (25 Ω (12 Ω と 13 Ω の直列) と 8.2 µH と 3.3 nF の直列共振)
parts:
  J1: sma c2 mirror
  G0: ground d2
  R1: resistor c5 c8 12
  R2: resistor c8 c11 13
  L1: inductor c11 c14 8.2u
  C1: capacitor c14 e14 3.3n
  G1: ground e14
wires:
  - J1.1 -- c5
  - J1.2 -- d2
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/02-sweep-rotation-3.svg)

```vna
sweep: 300k-3M 101
title: 図3 25 Ω + 8.2 µH + 3.3 nF の直列共振 — r = 0.5 の円を下から上へ
dut:
  - series R 25
  - series L 8.2u
  - series C 3.3n
  - short
traces:
  - S11 smith
markers:
  - 500k
  - 968k
  - 1.5M
  - 3M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/02-sweep-rotation-3.svg)

- 実軸を横切る周波数が共振周波数で、そこの抵抗が直列の抵抗そのもの (25 Ω)。**共振周波数と損失の抵抗を、Smith チャートの 1 点から読める**
- 部品の自己共振周波数 (第 4 章) も、同じように「実軸を横切る周波数」で読める
- 掃引の幅を広げすぎると、円が実軸近くに詰まって読みにくい。**共振を見たいときは、f0 の前後 3〜5 倍くらい**の範囲にする

## 実体配線図

```breadboard
title: 図4 3 つの負荷をブレッドボードに並べる (図1 の 50 Ω + 8.2 µH を選んだ状態)
board: half
parts:
  VNA:
    type: device
    at: top
    label: VNA (SMA ケーブルの先)
    pins: [GND, RF]
  R1: resistor b3 b7 100
  R2: resistor d3 d7 100
  L1: inductor a7 -t7 8.2u
  R3: resistor b11 b15 100
  R4: resistor d11 d15 100
  C1: capacitor/ceramic a15 -t15 3.3n
  R5: resistor b19 b22 12
  R6: resistor d22 d25 13
  L2: inductor b25 b28 8.2u
  C2: capacitor/ceramic a28 -t28 3.3n
wires:
  - VNA.GND -- -t1 black
  - VNA.RF -- e3 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/breadboard/02-sweep-rotation.svg)

- 列ごとに負荷が 1 つ: **図 1 (50 Ω + 8.2 µH) は 3 列目、図 2 (50 Ω + 3.3 nF) は 11 列目、図 3 (25 Ω + 8.2 µH + 3.3 nF) は 19 列目**。選ぶのはオレンジの線 1 本で、測る負荷の列の e の行へ挿し替える
- 50 Ω は **100 Ω の 2 本並列** (R1 と R2、R3 と R4)。2 本は同じ 2 つの列 (3 列目と 7 列目、11 列目と 15 列目) にまたがる。その先のコイル L1・コンデンサ C1 が上の − レール (GND) へ
- 図 3 の負荷は 19 列目から **R5 12 Ω → R6 13 Ω → L2 8.2 µH → C2 3.3 nF → GND** の順に横へ渡る (22・25・28 列目が部品どうしの継ぎ目)
- 上の − レールが GND で、黒い線で VNA の GND へつなぐ。ケーブルの先から挿し先の列までの線は 5 cm 以下にする (測る物に含まれる)

## 見るべき値

計算値 (基準 50 Ω)。

| 図 | 周波数 | Z | z | 動き |
| --- | --- | --- | --- | --- |
| 図1 (50 Ω + 8.2 µH) | 100 kHz | 50 + j5.2 Ω | 1 + j0.10 | 中心のすぐ上 |
| | 1 MHz | 50 + j51.5 Ω | 1 + j1.03 | 円のほぼ頂上 |
| | 3 MHz | 50 + j154.6 Ω | 1 + j3.09 | 右端へ向かう |
| 図2 (50 Ω + 3.3 nF) | 100 kHz | 50 − j482.3 Ω | 1 − j9.65 | 右端の近く |
| | 1 MHz | 50 − j48.2 Ω | 1 − j0.96 | 円の底のあたり |
| | 3 MHz | 50 − j16.1 Ω | 1 − j0.32 | 中心のすぐ下 |
| 図3 (25 Ω + L + C) | 968 kHz (共振) | 25 Ω | 0.5 | 実軸、中心の左 |

- 周波数を 30 倍にすると、コイルの z の虚部は 30 倍 (0.10 → 3.09)、コンデンサは 1/30 (−9.65 → −0.32)。**両方とも r = 1 の円の上を動き、コイルは中心から右端へ、コンデンサは右端から中心へ向かう**
- 図 1 と図 2 は、50 Ω を直列に付けたので、**どの周波数でも実部が 1 のまま** (点が r = 1 の円から出ない)

## 出典

自作。
