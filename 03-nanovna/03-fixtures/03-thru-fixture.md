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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/03-thru-fixture.svg)

## 実体配線図

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard のスルー治具
points:
  GND: 09
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
wires:
  - a10 -- x10
  - 09 -- y9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/perfboard/03-thru-fixture.svg)

- J1 の中心導体から J2 の中心導体まで、i 行を 1 本の線でつなぐだけ
- この 1 本の長さが、そのまま**治具だけが持つ寄生インダクタンス**になる
  (3-6 で測る)
- GND は J1 と J2 の凹の腕どうし (j0〜j25) を、信号の線のすぐ隣の j 行で 1 本につなぐ。
  帰り道を信号の線と同じ長さに抑えるため

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

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
title: 図3 治具だけの理想は平ら (実測のずれが治具の限界)
dut: series R 0
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 1M
  - 300M
notes:
  - text 20M -40dB: 理想は平ら (S21 は 0 dB、S11 は −∞ で枠の下)
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/03-thru-fixture.svg)

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
