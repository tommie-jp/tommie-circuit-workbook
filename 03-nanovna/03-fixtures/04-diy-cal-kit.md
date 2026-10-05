---
book: nanovna
chapter: 3
id: 3-4
title: 自作校正キット — Open / Short / Load (50 Ω) を perfboard で
tier: 50
source: 自作
board: PF
device: H4
---

# 3-4 自作校正キット — Open / Short / Load (50 Ω) を perfboard で

市販の校正キットが無くても、**端面 SMA 1 つずつの小さな perfboard 3 枚**
で Open・Short・Load を自作できる。1-2 で見た理想の位置 (Smith チャートの
右端・左端・真ん中) に、どれだけ近い標準器が作れるかを確かめる。

## 回路図

```circuit
title: 図1 自作の Open・Short・Load
parts:
  J1: sma a1 mirror
  J2: sma a4 mirror
  G2: ground c5
  J3: sma a8 mirror
  R1: resistor a9 c9 100
  R2: resistor a11 c11 100
  G3: ground c11
wires:
  - J2.1 -- a5
  - a5 -- c5
  - J2.2 -- c4 -- c5
  - J3.1 -- a9 -- a11
  - J3.2 -- c8 -- c9 -- c11
notes:
  - text d1 blue center: Open
  - text d4a5 blue center: Short
  - text d9a5 blue center: "Load (50 Ω)"
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/04-diy-cal-kit.svg)

- **Open** は中心導体をどこにもつながず、外皮 (シェル) だけの部品。
  ほかに何もつながる先が無いのは意図どおりで、ERC のお知らせは無視してよい
- **Short** は中心導体を最短距離で外皮 (GND) へ落とす
- **Load** は中心導体と外皮の間に 50 Ω を入れる。50 Ω は E24 に無いので、
  **100 Ω を 2 本並列**にする (R1 ∥ R2 = 50 Ω)。2 本を並べると、リード線の
  インダクタンスも 2 本の並列で半分になり、1 本より高い周波数まで 50 Ω に近い

## 実体配線図

3 枚とも 8×8 の小さな基板 1 枚に SMA 端面コネクタ 1 つだけを載せる。

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 Open
points:
  GND: b8
parts:
  J1: sma/female-edge a10 011 09
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/perfboard/04-diy-cal-kit-1.svg)

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図3 Short
points:
  GND: b8
parts:
  J2: sma/female-edge a10 011 09
wires:
  - a10 -- a9
  - a9 -- 09
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/perfboard/04-diy-cal-kit-2.svg)

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図4 Load (50 Ω)
points:
  GND: c7
parts:
  J3: sma/female-edge a10 011 09
  R1: resistor c10 c7 100
  R2: resistor e10 e7 100
wires:
  - a10 -- c10
  - c10 -- e10
  - 09 -- b9 black
  - b9 -- b7 black
  - b7 -- c7 black
  - c7 -- e7 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/perfboard/04-diy-cal-kit-3.svg)

- Short は**中心導体からシェルまでの線をできるだけ短く**する。長い線が
  誘導性のオフセットになり、高い周波数ほど Smith の左端から回っていく
- Load の 100 Ω 2 本は**リード線も短く**。2 本並列の抵抗値 (50 Ω) は DC で
  テスターでも確かめられる (1-8)

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | この題は自作標準器**そのもの**を見る (校正前) |
| 表示 | S11 の Smith チャート |

```vna
device: h4
sweep: 1M-300M 101
title: 図5 自作 Open — Smith の右端 (理想)
dut: open
traces:
  - S11 smith
markers:
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/04-diy-cal-kit-1.svg)

```vna
device: h4
sweep: 1M-300M 101
title: 図6 自作 Short — Smith の左端 (理想)
dut: short
traces:
  - S11 smith
markers:
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/04-diy-cal-kit-2.svg)

```vna
device: h4
sweep: 1M-300M 101
title: 図7 自作 Load (50 Ω) — Smith の真ん中 (理想)
dut:
  - series R 50
  - short
traces:
  - S11 smith
markers:
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/04-diy-cal-kit-3.svg)

## 見るべき値

| 標準器 | 理想の位置 | perfboard で作ったときのずれやすい原因 |
| --- | --- | --- |
| Open | 右端 (∞ Ω) | シェルと中心導体の間の浮遊容量 (パターンの容量、4-16) |
| Short | 左端 (0 Ω) | 中心導体から GND までの線のインダクタンス (リード線 1 cm、4-7) |
| Load (50 Ω) | 真ん中 | 抵抗のリード線のインダクタンスと実際の抵抗値のずれ (100 Ω 2 本の誤差の平均) |

**300 MHz に近い周波数ほど、この自作キットは理想から離れていく。**
市販キットとの違いや、どこまで信じてよいかは 1-7 と 3-6 で扱う。

## 出典

自作。
