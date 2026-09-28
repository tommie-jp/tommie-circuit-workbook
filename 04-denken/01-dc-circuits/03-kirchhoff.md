---
book: denken
chapter: 1
id: 1-3
title: キルヒホッフの法則 — 2 電源の回路で節点の電流と閉路の電圧
tier: 50
source: 自作
board: BB
---

# 1-3 キルヒホッフの法則 — 2 電源の回路で節点の電流と閉路の電圧

電源が 1 つならオームの法則だけで解けるが、電源が 2 つある回路は
オームの法則だけでは解けない。電流則 (節点に入る電流の和 = 出る電流の和) と
電圧則 (閉路を 1 周すると電圧の和は 0) を連立させて解く。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I1 + I2 = I3 (電流則) | 節点 B に入る電流の和は、出る電流に等しい |
| E1 = I1 R1 + I3 R3 (電圧則、左の閉路) | E1 の閉路を 1 周した電圧の和は 0 |
| E2 = I2 R2 + I3 R3 (電圧則、右の閉路) | E2 の閉路を 1 周した電圧の和は 0 |

## 回路図

```circuit
title: 図1 2 電源とキルヒホッフの法則
style:
  standard: jis
  pitch: 1.2
parts:
  E1: battery a1 e1 5
  R1: resistor a1 a3 400
  A1: ammeter a3 a5
  A3: ammeter a5 c5
  R3: resistor c5 e5 100
  A2: ammeter a5 a7
  R2: resistor a7 a9 200
  E2: battery a9 e9 3
  G1: ground e5
wires:
  - e1 -- e5
  - e5 -- e9
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/01-dc-circuits/circuit/03-kirchhoff.svg)

- 節点 B (A1・A2・A3 が集まる所) に電流則を当てはめる: I1 + I2 = I3
- E1 と R1 の枝、E2 と R2 の枝、R3 の枝が節点 B で合流する。
  A1・A2・A3 はそれぞれの枝の電流を測る

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  R1a: resistor c5 c8 200
  R1b: resistor e8 e11 200
  R2: resistor c13 c18 200
  R3: resistor f15 f20 100
  E1:
    type: device
    at: top
    label: "電源 5V (E1)"
    pins: ["+", "-"]
  E2:
    type: device
    at: top
    label: "電池 3V (E2)"
    pins: ["+", "-"]
wires:
  - E1.+ -- c3 red
  - E1.- -- -t6 black
  - b11 -- b13 orange
  - d13 -- f13 green
  - g20 -- -b20 black
  - -b27 -- -t27 black
  - E2.+ -- c20 red
  - E2.- -- -t22 black
notes:
  - text: "A1 (mA)。3 列と 5 列の間に直列に入れる"
  - text: "A3 (mA)。下段 13 列と 15 列の間に直列に入れる"
  - text: "A2 (mA)。18 列と 20 列の間に直列に入れる"
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/01-dc-circuits/breadboard/03-kirchhoff.svg)

- 3 列と 5 列の間、13 列と 15 列の間 (下段)、18 列と 20 列の間は、
  それぞれ A1・A3・A2 (テスターの電流レンジ) を直列に入れる隙間
- R1 は 200 Ω の 2 本 (R1a・R1b) を 8 列でつないだ直列。R1a は c 行、R1b は e 行に挿す
- 11 列と 13 列の間 (橙) が節点 B。下段の 13 列へ緑の線で渡し、R3 につなぐ

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| E1 | 電源 | 5 V (USB の 5 V か AD の Supplies の V+) |
| E2 | 電池 | 3 V (単 3 電池 2 本)。2 つの電源を見分けるため、E1 と電圧を変える |
| R1 | 抵抗 (1/4 W) | 400 Ω — 200 Ω を 2 本直列 (R1a・R1b) |
| R2 | 抵抗 (1/4 W) | 200 Ω |
| R3 | 抵抗 (1/4 W) | 100 Ω |

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| テスター | 直流電流レンジ (mA)。3 か所の隙間 (A1・A2・A3) に順に直列で入れる |

## 見るべき値

計算値 (E1 = 5 V、E2 = 3 V、R1 = 400 Ω、R2 = 200 Ω、R3 = 100 Ω)。

| 測る所 | 期待する値 |
| --- | --- |
| I1 (A1、E1 の枝) | 8.57 mA |
| I2 (A2、E2 の枝) | 7.14 mA |
| I3 (A3、R3 の枝) | 15.71 mA (= I1 + I2、電流則) |
| 節点 B の電圧 (R3 の両端) | 1.57 V (= I3 × R3) |

電圧則の確かめ: E1 の閉路 = I1 R1 + I3 R3 = 8.57 mA × 400 Ω + 15.71 mA × 100 Ω
= 3.43 V + 1.57 V = 5.00 V (= E1 ✓)。
E2 の閉路 = I2 R2 + I3 R3 = 7.14 mA × 200 Ω + 15.71 mA × 100 Ω
= 1.43 V + 1.57 V = 3.00 V (= E2 ✓)。

各抵抗の消費電力は最大でも 25 mW (R3) で、1/4 W 抵抗の定格に余裕がある
(R1 は 29 mW を 2 本で分けるので 1 本 15 mW)。

分かること:

- **電流則と電圧則を連立させて初めて解ける。** オームの法則 1 本では
  変数 (I1・I2・I3) が 3 つに対して式が足りない
- この回路は 1-4 の重ね合わせの理でも同じ形を使う。
  同じ回路を別の解き方で解けることを確かめる

## 出典

自作。
