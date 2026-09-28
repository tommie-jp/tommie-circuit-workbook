---
book: denken
chapter: 1
id: 1-5
title: テブナンの定理 — 開放電圧と内部抵抗を測って等価回路を作る
tier: 50
source: 自作
board: BB
---

# 1-5 テブナンの定理 — 開放電圧と内部抵抗を測って等価回路を作る

どんなに複雑な抵抗網でも、**2 つの端子から見れば「1 個の電圧源 + 1 個の
抵抗」に置き換えられる** (テブナンの等価回路)。端子を開放したときの電圧
(開放電圧 V_th) と、電源を止めたときの端子間の抵抗 (内部抵抗 R_th) の
2 つを測るだけで等価回路が作れる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| V_th = 開放電圧 | 端子を何もつながずに測った電圧 |
| R_th = 電源を短絡したときの端子間抵抗 | 電圧源を 0 V (短絡) にして、抵抗計で測る |
| V_load = V_th × R_L / (R_th + R_L) | 等価回路に負荷 R_L をつないだときの電圧 (分圧の式そのもの) |

## 回路図

```circuit
title: 図1 テブナンを求める回路 (R_L をつないだ状態)
style:
  standard: jis
  pitch: 1.2
parts:
  E1: battery a1 e1 5
  R1: resistor a1 a3 1.5k
  R2: resistor a3 e3 3k
  V1: voltmeter a5 e5
  S1: switch a5 a7
  RL: resistor a7 a9 1k
  A1: ammeter a9 e9
  G1: ground e5
wires:
  - a3 -- a5
  - e1 -- e3
  - e3 -- e5
  - e5 -- e9
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/01-dc-circuits/circuit/05-thevenin-1.svg)

```circuit
title: 図2 内部抵抗を測る (電源を短絡)
style:
  standard: jis
  pitch: 1.2
parts:
  SH1: short a1 e1
  R1: resistor a1 a3 1.5k
  R2: resistor a3 e3 3k
  M1: ohmmeter a5 e5
  G1: ground e5
wires:
  - a3 -- a5
  - e1 -- e3
  - e3 -- e5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/01-dc-circuits/circuit/05-thevenin-2.svg)

- 図1: R1・R2 で分圧した後の端子 (V1 の所) に、スイッチ S1 と負荷 R_L をつなぐ
- 図2: 電源を短絡 (SH1) に置き換え、同じ端子をオームメータ (M1) で測る。
  R1 と R2 が**並列に見える** (R1 の片側が短絡で GND に落ちるため)
- E1 は 5 V の電源 (USB の 5 V か AD の Supplies。単 3 電池 3 本の 4.5 V でも可)
- 抵抗は kΩ 台にした。R_L をつないだときの R1 の電流は 2.2 mA ほどで、
  消費電力は 1/4 W 抵抗の定格に十分な余裕がある (見るべき値で計算する)

## 実体配線図

```breadboard
title: 図3 ブレッドボードに組む
board: half
parts:
  R1: resistor c5 c10 1.5k
  R2: resistor f10 f15 3k
  S1: switch d10 d12
  RL: resistor e12 e17 1k
  AM:
    type: device
    at: bottom
    label: "テスター (mA)"
    pins: ["+", "-"]
  E1:
    type: device
    at: top
    label: "電源 5V"
    pins: ["+", "-"]
wires:
  - E1.+ -- a5 red
  - E1.- -- -t7 black
  - a10 -- g10 green
  - g15 -- -b15 black
  - -b27 -- -t27 black
  - AM.+ -- b17 orange
  - AM.- -- -b22 black
notes:
  - text: "S1 (スイッチ、10-12 列)"
  - text: "テスター (mA) を直列に。ここで電流を読む"
  - text: "端子 X (V_th・V_load はここと GND レールの間)"
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/01-dc-circuits/breadboard/05-thevenin.svg)

- R1 の右足 (10 列) が端子 X。R2 は緑の線で下段へ渡す
- S1 (スイッチ) は 10 列と 12 列の間に実物のスイッチとして挿す。開けば V_th
  (端子を開放した状態)、閉じれば R_L がつながった状態になる
- テスター (mA) は「テスター」の機器の箱として描いた通り、R_L の先に**直列**に挟む。
  電圧を測るときは端子 X (10 列) と GND レールにテスターを当てる (回路を切らない)
- R_th を測るときは、電源 (E1) を板から外して 5 列 (E1.+ の跡) を GND レールへ
  つなぎ、S1 を開けたまま端子 X (10 列) と GND レールをオームメータで測る

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| テスター 1 | 直流電圧レンジ。V_th (S1 開放) と V_load (S1 閉) を端子 X-GND で測る |
| テスター 2 | 抵抗レンジ。電源を外して R_th を測る |
| テスター 3 | 直流電流レンジ (mA)。図の AM の位置に直列に入れて I_load を測る |

## 見るべき値

計算値 (E = 5 V、R1 = 1.5 kΩ、R2 = 3 kΩ、R_L = 1 kΩ)。単 3 電池 3 本 (4.5 V) なら電圧・電流とも 0.9 倍になる。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| V_th (S1 開放) | 3.33 V | R1・R2 の分圧: 5 V × 3 kΩ / (1.5 kΩ + 3 kΩ) |
| R_th (電源を短絡) | 1.0 kΩ | R1 // R2 = 1.5 kΩ × 3 kΩ / 4.5 kΩ |
| V_load (S1 閉、R_L = 1 kΩ) | 1.67 V | 等価回路の式: 3.33 V × 1 kΩ / (1 kΩ + 1 kΩ) |
| I_load (AM) | 1.67 mA | V_load / R_L |
| R1 の消費電力 (S1 閉のとき) | 7.4 mW | I1² × R1 (I1 = 2.22 mA)。1/4 W 抵抗の定格に十分な余裕 |

分かること:

- **元の回路を直接計算しても同じ 1.67 V になる** (R2 // R_L = 750 Ω、
  全体 2.25 kΩ、電流 2.22 mA、V_load = 2.22 mA × 750 Ω = 1.67 V)。テブナンの
  等価回路は、R_L をどんな値に変えても同じ考え方でそのまま使える
- **R_th = R_L (= 1 kΩ) のとき、負荷に渡る電力が最大になる** (1-8 で確かめる)
- 電源が 1 個でも複数でも (1-3 のような回路でも) 同じ手順でテブナン化できる

## 出典

自作。
