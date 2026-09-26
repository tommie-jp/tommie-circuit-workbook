---
book: denken
chapter: 7
id: 7-1
title: 分流器 — 電流計の測定範囲を広げる
tier: 50
source: 自作
board: BB
---

# 7-1 分流器 — 電流計の測定範囲を広げる

検流計 (ガルバノメータ) は流せる電流がとても小さい。もっと大きい電流を測るには、
**分流器** (低い抵抗) を並列に入れて、大部分の電流を分流器に逃がす。実験用の
本物の検流計は手元に無いので、抵抗 r_g (100 Ω) を検流計の内部抵抗の模型として使い、
その両端の電圧を AD で読んで電流に換算する。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| R_s = r_g / (n − 1) | 測定範囲を n 倍にするための分流器の抵抗 (r_g は検流計の内部抵抗) |
| I_s / I_g = r_g / R_s | 分流器と検流計を流れる電流の比 (抵抗の逆比) |
| I = I_g + I_s | 全電流は検流計と分流器の電流の和 |

## 回路図

```circuit
title: 図1 分流器
parts:
  V1: vsource a1 c1 5
  Rt: resistor a1 a5 1k i=Itot
  Rg: resistor a5 a8 100 i=Ig
  G1: galvanometer a8 c8
  Rs: resistor a5 c5 50 i=Is
  G2: ground c1
wires:
  - c1 -- c5 -- c8
style:
  standard: jis
  grid: on
```

- Rg (100 Ω) が検流計の内部抵抗の模型。実物の検流計の記号 (G1) は電流の道筋を
  示すためだけに置き、抵抗の値は Rg が持つ
- Rs (50 Ω) が分流器。Rg と並列に入れる
- Rt (1 kΩ) は回路の外側の抵抗 (負荷) の代わり。値そのものは分流の比に関係しない

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rt: resistor c5 c10 1k
  Rg: resistor c15 c19 100
  Rs: resistor c22 c26 50
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t5 red
  - +t5 -- a5 red
  - a10 -- a15 green
  - b15 -- b22 green
  - a19 -- -t19 black
  - a26 -- -t26 black
  - AD.GND -- -t2 black
  - AD.1+ -- d15 green [h8]
  - AD.1- -- -t20 black
  - AD.2+ -- b5 red [h9]
  - AD.2- -- b10 green [h9]
```

- Rt (1 kΩ) の先で、Rg (100 Ω、検流計の模型) と Rs (50 Ω、分流器) が並列になる
- CH1 (1+) は Rg (= Rs) の両端 (GND 基準)。CH2 は Rt の両端の差動 (全電流)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V |
| Scope | CH1 = 並列部分の電圧 (GND 基準)、CH2 = Rt の両端 (差動、全電流) |

## 見るべき値

計算値。Rg (100 Ω) と Rs (50 Ω) の並列 = 33.3 Ω。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 (並列部分の電圧) | 0.161 V | I_g = 0.161 V ÷ 100 Ω = 1.61 mA |
| CH2 (Rt の両端、全電流) | 4.84 V | I_total = 4.84 V ÷ 1 kΩ = 4.84 mA |
| I_s (= I_total − I_g) | 3.22 mA | 分流器を流れる電流 |
| I_s / I_g | 2.00 (= r_g / R_s = 100/50) | 抵抗の逆比どおりに分かれる |
| I_total / I_g (= n) | 3.00 | 分流器のおかげで測定範囲が 3 倍になる |

分かること:

- **分流器の抵抗が小さいほど、逃がせる電流の割合が増える。** R_s を半分 (25 Ω)
  にすると n はさらに増える (n = 1 + r_g/R_s の関係)
- 実際の分流器は、検流計の個体ごとの r_g に合わせて精密な抵抗 (シャント抵抗)
  を使う。電流計の切り替えレンジは、この分流器を切り替えて作る

## 出典

自作。
