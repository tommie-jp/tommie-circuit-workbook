---
book: nanovna
chapter: 12
id: 12-2
title: 周波数を掃くと点が回る — 直列の L は上半分、C は下半分を時計回りに
tier: 100
source: 自作
board: —
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

この題は各 vna の図の前に回路図を付け、実体配線図は付けない — 掃き方の読み方の題で、組む回路が無い (組んで測るのは 12-4 のデモボード)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜100 MHz (図 1・図 2)、3 MHz〜30 MHz (図 3) |
| 点数 | 101 |
| 校正 | SOLT (1-1)。ケーブルの先で Open / Short / Load |
| 表示 | S11 の Smith チャート |

## 50 Ω に直列のコイル

50 Ω に 820 nH のコイルを直列に付けた負荷 (Z = 50 + jωL)。**R = 50 Ω の円** (中心を通る円) の上半分を、中心から右へ回る。

```circuit
title: 図1 の回路 (50 Ω と 820 nH の直列)
parts:
  J1: sma c2 mirror
  G0: ground d2
  R1: resistor c5 c9 50
  L1: inductor c9 e9 820n
  G1: ground e9
wires:
  - J1.1 -- c5
  - J1.2 -- d2
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/02-sweep-rotation-1.svg)

```vna
sweep: 1M-100M 101
title: 図1 50 Ω + 820 nH — r = 1 の円の上半分を中心から右へ
dut:
  - series R 50
  - series L 820n
  - short
traces:
  - S11 smith
markers:
  - 1M
  - 10M
  - 30M
  - 100M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/02-sweep-rotation-1.svg)

## 50 Ω に直列のコンデンサ

50 Ω に 330 pF のコンデンサを直列に付けた負荷 (Z = 50 − j / (ωC))。**同じ r = 1 の円の下半分**で、低い周波数では右端の近く (x が大きな負) から始まり、周波数を上げると中心へ近づく。

```circuit
title: 図2 の回路 (50 Ω と 330 pF の直列)
parts:
  J1: sma c2 mirror
  G0: ground d2
  R1: resistor c5 c9 50
  C1: capacitor c9 e9 330p
  G1: ground e9
wires:
  - J1.1 -- c5
  - J1.2 -- d2
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/02-sweep-rotation-2.svg)

```vna
sweep: 1M-100M 101
title: 図2 50 Ω + 330 pF — r = 1 の円の下半分を右から中心へ
dut:
  - series R 50
  - series C 330p
  - short
traces:
  - S11 smith
markers:
  - 1M
  - 10M
  - 30M
  - 100M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/02-sweep-rotation-2.svg)

## コイルとコンデンサを両方 — 共振

25 Ω に 820 nH と 330 pF を直列に付けた負荷。**共振周波数 f0 = 1 / (2π√(LC)) ≈ 9.68 MHz** で、コイルとコンデンサのリアクタンスが打ち消し合って、純粋な抵抗 25 Ω (z = 0.5) になる。
f0 より下は容量性 (下半分)、上は誘導性 (上半分) で、**実軸をちょうど f0 で横切る**。r = 0.5 の円の上を、下から上へ時計回りに動く。

```circuit
title: 図3 の回路 (25 Ω と 820 nH と 330 pF の直列共振)
parts:
  J1: sma c2 mirror
  G0: ground d2
  R1: resistor c5 c9 25
  L1: inductor c9 c13 820n
  C1: capacitor c13 e13 330p
  G1: ground e13
wires:
  - J1.1 -- c5
  - J1.2 -- d2
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/02-sweep-rotation-3.svg)

```vna
sweep: 3M-30M 101
title: 図3 25 Ω + 820 nH + 330 pF の直列共振 — r = 0.5 の円を下から上へ
dut:
  - series R 25
  - series L 820n
  - series C 330p
  - short
traces:
  - S11 smith
markers:
  - 5M
  - 9.7M
  - 15M
  - 30M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/02-sweep-rotation-3.svg)

- 実軸を横切る周波数が共振周波数で、そこの抵抗が直列の抵抗そのもの (25 Ω)。**共振周波数と損失の抵抗を、Smith チャートの 1 点から読める**
- 部品の自己共振周波数 (第 4 章) も、同じように「実軸を横切る周波数」で読める
- 掃引の幅を広げすぎると、円が実軸近くに詰まって読みにくい。**共振を見たいときは、f0 の前後 3〜5 倍くらい**の範囲にする

## 見るべき値

計算値 (基準 50 Ω)。

| 図 | 周波数 | Z | z | 動き |
| --- | --- | --- | --- | --- |
| 図1 (50 Ω + 820 nH) | 1 MHz | 50 + j5.2 Ω | 1 + j0.10 | 中心のすぐ上 |
| | 10 MHz | 50 + j51.5 Ω | 1 + j1.03 | 円のほぼ頂上 |
| | 30 MHz | 50 + j154.6 Ω | 1 + j3.09 | 右端へ向かう |
| | 100 MHz | 50 + j515.2 Ω | 1 + j10.3 | 右端の近く |
| 図2 (50 Ω + 330 pF) | 1 MHz | 50 − j482.3 Ω | 1 − j9.65 | 右端の近く |
| | 10 MHz | 50 − j48.2 Ω | 1 − j0.96 | 円の底のあたり |
| | 30 MHz | 50 − j16.1 Ω | 1 − j0.32 | 中心のすぐ下 |
| | 100 MHz | 50 − j4.8 Ω | 1 − j0.10 | 中心のすぐ下 |
| 図3 (25 Ω + L + C) | 9.68 MHz (共振) | 25 Ω | 0.5 | 実軸、中心の左 |

- 周波数を 100 倍にすると、コイルの z の虚部は 100 倍 (0.10 → 10.3)、コンデンサは 1/100 (−9.65 → −0.10)。**両方とも r = 1 の円の上を、反対の向きから中心へ・右端へ**
- 図 1 と図 2 は、50 Ω を直列に付けたので、**どの周波数でも実部が 1 のまま** (点が r = 1 の円から出ない)

## 出典

自作。
