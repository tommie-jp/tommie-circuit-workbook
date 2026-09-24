---
book: nanovna
chapter: 3
id: 3-3
title: スルー治具 — 治具だけの S21
tier: 50
source: 自作
board: PF
device: H4
---

# 3-3 スルー治具 — 治具だけの S21

部品を入れず、**perfboard と 2 つの端面 SMA だけ**の治具。3-1 (直列治具)・
3-2 (シャント治具) から DUT を抜いたもので、**治具そのものの損失と反射**
を測るための基準になる。校正の Thru (1-3) と役割は同じだが、こちらは
「治具を経由した」損失を見るためのもの。

## 回路図

```circuit
title: 図1 スルー治具
parts:
  J1: sma b2 mirror
  J2: sma b8
  G1: ground c2
  G2: ground c8
wires:
  - J1.1 -- b8
  - J2.1 -- b8
  - J1.2 -- c2
  - J2.2 -- c8
notes:
  - text a2 center: CH0
  - text a8 center: CH1
```

## 実体配線図

```perfboard
board:
  size: 16x8
  slots: on
title: 図2 perfboard のスルー治具
points:
  GND: h2
parts:
  J1: sma/female-edge e1 d0 f0
  J2: sma/female-edge e16 f17
wires:
  - e1 -- e16
  - f0 -- f2 black
  - f2 -- GND black
  - f17 -- f15 black
  - f15 -- h15 black
  - h15 -- GND black
```

- J1 の中心導体から J2 の中心導体まで、e 行を 1 本の線でつなぐだけ
- この 1 本の長さが、そのまま**治具だけが持つ寄生インダクタンス**になる
  (3-6 で測る)

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | SOLT。ケーブルの先 (治具の SMA に挿す手前) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag、S11 の Log Mag |

治具だけを理想の模型 (0 Ω のスルー) で見たときの画面。

```vna
device: h4
sweep: 1M-300M 101
title: 図3 治具だけの画面 (理想)
dut: series R 0
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 1M
  - 300M
```

## 見るべき値

| 測る所 | 期待する値 (理想) | 分かること |
| --- | --- | --- |
| 治具だけの S21 | 0 dB | 治具そのものに損失が無いという基準 |
| 治具だけの S11 | 検出限界以下 | 治具そのものに反射が無いという基準 |
| 実測との差 | 0 dB からのずれ | **治具そのものの限界** (3-6 で周波数を決める) |

**この治具の実測を基準にすれば、3-1 や 3-2 で測った DUT の値から
治具ぶんを差し引ける** (de-embedding、3-8)。まずは基準になる治具単体の
姿を覚えておく。

## 出典

自作。
