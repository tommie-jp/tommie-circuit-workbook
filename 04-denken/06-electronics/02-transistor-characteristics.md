---
book: denken
chapter: 6
id: 6-2
title: トランジスタの静特性 — I_C-V_CE と h_FE
tier: 50
source: 自作
board: BB
---

# 6-2 トランジスタの静特性 — I_C-V_CE と h_FE

トランジスタはベース電流 I_B の何倍もの電流 I_C をコレクタに流せる (電流増幅)。
その倍率 **h_FE** を、ベースとコレクタそれぞれの抵抗の両端の電圧から求める。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I_B = (V_CC − V_BE) / R_B | ベース電流。V_BE ≈ 0.6 V (シリコンの順方向電圧) |
| I_C = h_FE × I_B | コレクタ電流。h_FE がこのトランジスタの電流増幅率 |
| V_CE = V_CC − I_C × R_C | コレクタ・エミッタ間の電圧 (エミッタ接地、エミッタは GND) |
| h_FE = I_C / I_B = (V_RC / R_C) / (V_RB / R_B) | 測った 2 つの電圧から h_FE を求める式 |

## 回路図

```circuit
title: 図1 固定バイアスで hFE を測る
parts:
  VCC: vcc a3
  RB: resistor a3 a7 470k i=IB
  RC: resistor c3 c7 1k i=IC
  Q1: npn e5 2SC1815
  G1: ground e9
wires:
  - a3 -- c3
  - a7 |- Q1.B
  - c7 |- Q1.C
  - Q1.E -| e9
style:
  standard: jis
  grid: on
```

- R_B (470 kΩ) がベース電流を決め、R_C (1 kΩ) がコレクタ電流を電圧に変える
- Q1 は 2SC1815 (GR ランク、h_FE は個体差があり 200〜400 程度)。ここでは
  代表値 h_FE = 250 として計算する
- V_CC は AD の Supplies (+5 V)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  RB: resistor b10 b15 470k
  RC: resistor b24 b16 1k
  Q1: transistor e15(B) e16(C) e17(E) 2SC1815
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, 1+, GND, 1-, 2-, 2+]
wires:
  - AD.V+ -- +t6 red
  - AD.1+ -- +t8 red
  - AD.GND -- -t12 black
  - +t10 -- a10 red
  - +t24 -- a24 red
  - a17 -- -t17 black
  - AD.1- -- a15 orange
  - AD.2- -- a16 green
  - AD.2+ -- +t20 red
```

- +t (赤レール) が +5 V。R_B・R_C ともここから取る (R_B は 10 列、R_C は 24 列から)。
  もう片方の足はベース (15 列)・コレクタ (16 列) に直に挿す
- CH1 (1+/1−) は R_B の両端の差動 (1+ は +t レール、1− は 15 列)。CH2 は R_C の両端の差動
  (2+ は +t レール、2− は 16 列)。Q1.E (17 列) は -t のレールへ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V |
| Scope | CH1 = R_B の両端 (差動)、CH2 = R_C の両端 (差動) |

## 見るべき値

計算値。h_FE = 250 と仮定して計算している (実測の h_FE は使ったトランジスタの
個体で変わる)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 (R_B の両端) | 4.40 V | I_B = 4.40 V ÷ 470 kΩ = 9.36 µA。V_CC − V_BE そのもの |
| CH2 (R_C の両端) | 2.34 V | I_C = 2.34 V ÷ 1 kΩ = 2.34 mA |
| V_CE (= 5 V − CH2) | 2.66 V | 飽和 (約 0.2 V) より十分高く、能動領域で動いている |
| h_FE (= I_C / I_B) | 250 | 計算どおりなら代表値と一致する。実測では個体差が出る |

分かること:

- **CH1 は h_FE によらずほぼ一定** (V_CC − V_BE を R_B で割るだけ)。CH2 だけが
  トランジスタの個体差で変わるので、h_FE の違いは CH2 の値にそのまま出る
- R_B を 2 倍 (940 kΩ) にすると I_B が半分になり、I_C・CH2 も半分になる —
  比例関係を変えて確かめられる
- V_CE が V_CE(sat) (約 0.2 V) より小さくなると I_C は h_FE × I_B より頭打ちになる
  (飽和。6-7 のスイッチ動作で使う領域)

## 出典

自作。
