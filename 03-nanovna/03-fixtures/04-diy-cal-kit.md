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
  J1: sma b2 mirror
  J2: sma f2 mirror
  G2: ground f6
  J3: sma j2 mirror
  R1: resistor j4 j6 50
  G3: ground j8
wires:
  - J2.1 -- f4
  - f4 -- f6
  - J2.2 -- g2 -- g6 -- f6
  - J3.1 -- j4
  - j6 -- j8
  - J3.2 -- k2 -- k8 -- j8
notes:
  - text b2f0 blue center: Open
  - text f2f0 blue center: Short
  - text j2f0 blue center: Load
```

- **Open** は中心導体をどこにもつながず、外皮 (シェル) だけの部品。
  ほかに何もつながる先が無いのは意図どおりで、ERC のお知らせは無視してよい
- **Short** は中心導体を最短距離で外皮 (GND) へ落とす
- **Load** は中心導体と外皮の間に 50 Ω を 1 本入れる

## 実体配線図

3 枚とも 8×8 の小さな板 1 枚に SMA 端面コネクタ 1 つだけを載せる。

```perfboard
board:
  size: 8x8
  slots: on
title: 図2 Open
points:
  GND: g2
parts:
  J1: sma/female-edge e1 d0 f0
```

```perfboard
board:
  size: 8x8
  slots: on
title: 図3 Short
points:
  GND: g2
parts:
  J2: sma/female-edge e1 d0 f0
wires:
  - e1 -- f1
  - f1 -- f0
```

```perfboard
board:
  size: 8x8
  slots: on
title: 図4 Load (50 Ω)
points:
  GND: g3
parts:
  J3: sma/female-edge e1 d0 f0
  R1: resistor e3 g3 50
wires:
  - e1 -- e3
  - f0 -- f2 black
  - f2 -- g2 black
  - g2 -- g3 black
```

- Short は**中心導体からシェルまでの線をできるだけ短く**する。長い線が
  誘導性のオフセットになり、高い周波数ほど Smith の左端から回っていく
- Load の 50 Ω は**リード線も短く**。部品の抵抗値そのものは DC で
  テスターでも確かめられる (1-8)

## 掃引の設定

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

## 見るべき値

| 標準器 | 理想の位置 | perfboard で作ったときのずれやすい原因 |
| --- | --- | --- |
| Open | 右端 (∞ Ω) | シェルと中心導体の間の浮遊容量 (パターンの容量、4-16) |
| Short | 左端 (0 Ω) | 中心導体から GND までの線のインダクタンス (リード線 1 cm、4-7) |
| Load (50 Ω) | 真ん中 | 抵抗のリード線のインダクタンスと実際の抵抗値のずれ |

**300 MHz に近い周波数ほど、この自作キットは理想から離れていく。**
市販キットとの違いや、どこまで信じてよいかは 1-7 と 3-6 で扱う。

## 出典

自作。
