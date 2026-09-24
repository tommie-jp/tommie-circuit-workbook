---
book: nanovna
chapter: 3
id: 3-1
title: 直列治具 — 部品を CH0 と CH1 の間に入れる
tier: 50
source: 自作
board: PF
device: H4
---

# 3-1 直列治具 — 部品を CH0 と CH1 の間に入れる

部品 1 つを **CH0 と CH1 の間に直列**に入れて、通り抜ける量 (S21) と跳ね返る量
(S11) を測るための治具。端面の SMA を 2 つ、perfboard の両端に載せる。
部品の章 (第 4 章) とフィルタの章 (第 6 章) で使い回す。

## 回路図

```circuit
title: 図1 直列治具
parts:
  J1: sma b2 mirror CH0
  R1: resistor b4 b6 100
  J2: sma b8 CH1
  G1: ground c2
  G2: ground c8
wires:
  - J1.1 -- b4
  - b6 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c8
```

- R1 が測る部品 (DUT)。ここでは 100 Ω の抵抗を入れて、治具が正しく作れたかを確かめる
- 2 つの SMA の外皮 (GND) は治具の上でつなぐ。つながないと、GND の戻り道が
  ケーブルの外側を回って値が狂う

## 実体配線図

```perfboard
board:
  size: 16x8
  slots: on
title: 図2 perfboard に端面 SMA を 2 つ
points:
  GND: h2
parts:
  J1: sma/female-edge e1 d0 f0
  J2: sma/female-edge e16 f17
  R1: resistor e6 e11 100
wires:
  - e1 -- e6
  - e11 -- e16
  - f0 -- f2 black
  - f2 -- GND black
  - f17 -- f15 black
  - f15 -- h15 black
  - h15 -- GND black
```

- 端面 SMA の凹の腕 (GND) を板の縁の銅箔に半田付けし、中心導体を板の穴に通す
- **中心導体から部品までの線はできるだけ短く**。長い線はそのぶんインダクタンスに
  なり、高い周波数で値がずれる (どこまで信じられるかは 3-6 で測る)
- GND は下の行 (h 行) を太めの線でまとめ、両方の SMA をつなぐ

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | SOLT。ケーブルの先 (治具の SMA に挿す手前) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag、S11 の Log Mag と Smith チャート |

## 見るべき値

50 Ω 系に直列に Z を入れると、S21 = 2·50 / (2·50 + Z)、S11 = Z / (2·50 + Z)。

| 入れる物 | S21 | S11 | 分かること |
| --- | --- | --- | --- |
| 100 Ω の抵抗 | −6.0 dB | −6.0 dB | 治具が正しく作れている (低い周波数で合えばよい) |
| 太い銅線 (0 Ω) | 0 dB | 小さいほど良い | 治具だけの損失と反射。3-3 のスルー治具と同じ |
| 何も入れない (開放) | 小さいほど良い | 0 dB | SMA どうしの漏れ (容量で高い周波数ほど増える) |

周波数を上げていくと 100 Ω の値が −6.0 dB から離れていく。そこが治具と
部品のリードの限界で、3-6 でその周波数を測って決める。

## 出典

自作。
