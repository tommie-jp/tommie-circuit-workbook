---
book: nanovna
chapter: 12
id: 12-6
title: L 形の整合を Smith チャート上で作る — 24 Ω を 50 Ω にする
tier: 200
source: 自作
board: PF
device: LV64
---

# 12-6 L 形の整合を Smith チャート上で作る — 24 Ω を 50 Ω にする

12-5 で、**直列の部品は r の円の上を、並列の部品は g の円の上を動く**ことを見た。この 2 つの動きを順に使えば、**24 Ω (z = 0.48) の負荷を中心 (50 Ω) へ運べる**。
コイル 1 つとコンデンサ 1 つだけの **L 形整合回路**で、10 MHz の SWR を 2.08 から約 1.02 に下げる。手順は 2 手:

1. **直列にコイル**を足す。r = 0.48 の円の上を**上へ**動かす。**この円が、中心を通る g = 1 の円と交わる所**まで
2. **並列にコンデンサ**を足す。**g = 1 の円の上を下へ**動かして、**中心に着く**

> **この章の図は理想の模型から計算した画面で、実機では測っていない。** 回路の値 (L = 390 nH・C = 330 pF) は E12 の値で、計算上は 10 MHz で 49.0 + j0.2 Ω、SWR 1.02。
> 実物の perfboard では、部品のリード線と配線のインダクタンスのぶん、少しずれる見込み。

## 回路図

```circuit
title: 図1 L 形整合回路 (24 Ω を 50 Ω に見せる)
parts:
  J1: sma c2 mirror
  G0: ground d2
  C1: capacitor c5 e5 330p
  G1: ground e5
  L1: inductor c5 c9 390n
  R1: resistor c9 e9 24
  G2: ground e9
wires:
  - J1.1 -- c5
  - J1.2 -- d2
notes:
  - text b7 small center: 入口
  - text g9 small center: 負荷
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/06-l-match.svg)

- 負荷 R1 (24 Ω) の**先に直列で L1 (390 nH)、入口に並列で C1 (330 pF)**。ケーブルの側から見ると、C1 が先、L1 がその次、R1 が最後
- 値の求め方 (10 MHz): 負荷が R_L = 24 Ω、基準が 50 Ω のとき、**Q = √(50 / 24 − 1) = 1.04**。直列のリアクタンス X_L = Q × R_L = 25 Ω → L = X_L / (2π × 10 MHz) = **398 nH**
  (E12 の 390 nH)。並列のリアクタンス X_C = 50 / Q = 48 Ω → C = 1 / (2π × 10 MHz × 48 Ω) = **331 pF** (E12 の 330 pF)
- **Smith チャート上の手順と式は同じこと**を見ている。チャートは、式の Q と X をグラフにしたもの

## 実体配線図

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 L 形整合回路 (perfboard、端面 SMA)
points:
  GND: 011
parts:
  J1: sma/female-edge a10 011 09
  C1: capacitor/ceramic e9 e4 330p
  L1: inductor f10 k10 390n
  R1: resistor k9 k4 24
wires:
  - a10 -- e10
  - e10 -- f10
  - k10 -- k9
  - e9 -- e10
  - e4 -- e3 black
  - k4 -- k3 black
  - e3 -- e2 black
  - k3 -- k2 black
  - 09 -- 02 black
  - 02 -- e2 black
  - e2 -- k2 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/perfboard/06-l-match.svg)

- SMA (A10) から、10 行の線で E10 へ。**E10 が C1 の上端** (E9〜E4 の縦のコンデンサ) で、そのまま F10 から K10 の **L1 (390 nH)**。K10 の先が **R1 (24 Ω)** の上端 (K9〜K4 の縦の抵抗)
- GND は 2 行の線で、C1 の下端 (E2) と R1 の下端 (K2) と SMA の GND (09 → 02) をつなぐ。**C1 と R1 のリードは短く**する
- 負荷の R1 は、**測るための模擬の負荷** (実際は、アンテナなど 24 Ω 前後の負荷を K9 の線に付け替える)
- 値は **L1 390 nH (E12)・C1 330 pF (E12)・R1 24 Ω (E24)**。コイルは軸付きの小さなインダクタ。C はセラミック (C0G)

## 掃引の設定

計器は VNA。この本の図は LiteVNA64 の画面に合わせて書いてあり、NanoVNA-H4 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 5 MHz〜20 MHz |
| 点数 | 151 |
| 校正 | SOLT (1-1)。ケーブルの先 (治具の SMA に挿す手前) で Open / Short / Load |
| 表示 | S11 の Smith チャートと SWR。マーカーは 10 MHz |

手順は **部品を 1 つずつ足して、その都度測る**:

1. R1 だけ (L1 の線も C1 の線も外す): 24 Ω の点を見る (図 3)
2. L1 を足す: 点が上へ動く (図 4)
3. C1 を足す: 点が中心へ着く (図 5)

以下は、**理想の模型から計算した画面**。

```vna
sweep: 5M-20M 151
title: 図3 整合の前 — 24 Ω だけ (z = 0.48、SWR 2.08)
dut:
  - series R 24
  - short
traces:
  - S11 smith
  - S11 swr
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/06-l-match-1.svg)

```vna
sweep: 5M-20M 151
title: 図4 直列に L 390 nH を足す — r = 0.48 の円を上へ
dut:
  - series L 390n
  - series R 24
  - short
traces:
  - S11 smith
  - S11 swr
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/06-l-match-2.svg)

```vna
sweep: 5M-20M 151
title: 図5 入口に並列に C 330 pF を足す — g の円を下へ、中心に着く
dut:
  - shunt C 330p
  - series L 390n
  - series R 24
  - short
traces:
  - S11 smith
  - S11 swr
markers:
  - 7M
  - 10M
  - 14M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/06-l-match-3.svg)

- 図 3 から図 4 への動きは**直列の L**で、実部が 24 Ω のまま上へ (24 + j24.5 Ω)。図 4 から図 5 への動きは**並列の C**で、g の円の上を中心へ
- 図 5 の SWR は **10 MHz でほぼ 1**、その周波数から離れると上がる。**整合は 1 つの周波数でしか完全には取れない**。SWR が 1.5 以下に収まるのは**約 6.8〜12.6 MHz** (計算)。図の 7 MHz は 35 + j6.6 Ω (SWR 1.48)、14 MHz は 49 − j34 Ω (SWR 1.96)

## 見るべき値

計算値 (基準 50 Ω)。

| 段 | 10 MHz の Z | z | SWR |
| --- | --- | --- | --- |
| R1 だけ (図 3) | 24 Ω | 0.48 | 2.08 |
| + L1 (図 4) | 24 + j24.5 Ω | 0.48 + j0.49 | 2.69 |
| + C1 (図 5) | 49.0 + j0.2 Ω | 0.98 + j0.00 | 1.02 |

- **手順を逆にすると着かない**: 先に並列の C を足し、次に直列の L を足しても、ふつうは中心に着かない。**どの円の上を動くか**が決まっているため、足す順に意味がある
- 上の 2 手の順は、**負荷が 50 Ω より小さいとき** (z < 1)。**50 Ω より大きいとき** (z > 1) は、**先に並列、次に直列**に変わる (考え方は同じで、左右が入れ替わる)
- 実物の perfboard で測ると、**最良の周波数が 10 MHz から少しずれる**。リード線のインダクタンスのぶん、L1 が実質大きくなるため。ずれたぶんは、L1 を少し短く (巻き数を減らす、リードを短くする) して 10 MHz に合わせる

## 出典

自作。L 形整合回路の値の式 (Q = √(R_高 / R_低 − 1)) は、整合回路の教科書に共通する内容による。
