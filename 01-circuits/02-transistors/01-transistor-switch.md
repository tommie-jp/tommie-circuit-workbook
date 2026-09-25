---
book: circuits
chapter: 2
id: 2-1
title: トランジスタスイッチ (LED)
tier: 50
source: 自作
board: BB
---

# 2-1 トランジスタスイッチ (LED)

トランジスタは**小さい電流で大きい電流を制御する**部品。ベースにわずかな
電流を流すだけで、コレクタ-エミッタ間に大きな電流を通す/止めるスイッチとして
使える。ベースの電流源には、電池 3 本 (4.5V) や USB の 5V など小さな電圧で足りる。

## 回路図

```circuit
title: 図1 NPN トランジスタで LED をスイッチする
parts:
  V1: vsource b2 d2 5
  G1: ground d2
  R1: resistor b5 d5 330
  D1: led d5 f5
  Q1: npn g5
  RB: resistor g2 g4 10k
  IN: port g2
  G2: ground h5
wires:
  - b2 -- b5
  - f5 -- Q1.C
  - g4 -- Q1.B
  - Q1.E -- h5
style:
  grid: on
  pitch: 1.2
```

`IN` に 5V (スイッチや押しボタン) を入れるとベースに電流が流れ、
トランジスタが**飽和**して LED が光る。0V (開放) にすると LED は消える。

- ベース電流: I<sub>B</sub> = (5 − 0.7) / 10kΩ ≈ **0.43 mA**
- コレクタ電流 (LED): I<sub>C</sub> = (5 − 0.2 − 2.0) / 330Ω ≈ **8.5 mA**
  (V<sub>CE(sat)</sub> ≈ 0.2V、LED の V<sub>F</sub> ≈ 2.0V として計算)
- I<sub>C</sub> / I<sub>B</sub> ≈ 20 倍。2SC1815 の hFE (100〜700) よりずっと小さいので、
  hFE が低い個体でも確実に**飽和領域**で動く (スイッチとして使うときの基本)

## 実体配線図

```breadboard
title: 図2 トランジスタスイッチ
# 上のレール = +5V、下のレール = GND
board: half
parts:
  R1: resistor a5 a8 330
  D1: led b8(A) b9(K) red
  Q1: transistor f12(B) f13(C) f14(E) 2SC1815
  RB: resistor a17 a20 10k
wires:
  - +t5 -- b5 red
  - c9 -- g13 orange
  - g12 -- b20 yellow
  - g14 -- -b14 black
```

`Q1` は平らな面を見て左から E・C・B (2SC1815 の実物の並び)。図は B・C・E の
順に挿すので、**平らな面を奥に向けて**挿す。`RB` の左端 (`a17`) が入力の端子。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 330 Ω |
| RB | 抵抗 (1/4 W) | 10 kΩ |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 電源 | 5 V |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| IN = 5V のときの LED の電流 (R1 の両端 ÷ 330Ω) | 約 8.5 mA | 計算値と一致すれば飽和で動いている証拠 |
| IN = 5V のときの Q1 の C-E 間電圧 | 約 0.2 V (V<sub>CE(sat)</sub>) | 飽和領域では非常に小さい電圧しか残らない |
| IN = 0V (開放) のときの LED | 消える | ベース電流が無いとコレクタ電流も流れない |
| ベース抵抗を 100kΩ に替えたとき | LED はやや暗くなる程度で点いたまま | I<sub>B</sub> が減っても hFE に余裕があるので飽和が保たれる |

## 出典

自作。
