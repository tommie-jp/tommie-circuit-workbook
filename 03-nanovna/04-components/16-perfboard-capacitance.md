---
book: nanovna
chapter: 4
id: 4-16
title: perfboard のパターンの容量
tier: 100
source: 自作
board: PF
device: H4
---

# 4-16 perfboard のパターンの容量

perfboard の上で**つながっていない 2 本の線**も、並んで走ればコンデンサになる。
この容量が、自作 Open (3-4) を理想の開放からずらし、フィルタ (第 6 章) の小さな容量に
足され、開いたスイッチ (4-15) の漏れを増やす。3-1 の直列治具で、CH0 から出た線と
CH1 から出た線を 2 穴離して並べ、その間の容量を S21 で読む。

## 回路図

2 本の線の間の容量をコンデンサ C1 として描いた等価回路。部品は何も挿さない。

```circuit
title: 図1 並んだ 2 本の線は小さなコンデンサ (等価回路)
parts:
  J1: sma b2 mirror CH0
  C1: capacitor b4 b6 0.5p
  J2: sma b8 CH1
  G1: ground c2
  G2: ground c8
wires:
  - J1.1 -- b4
  - b6 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c8
notes:
  - text a5 center: 線どうしの容量
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/16-perfboard-capacitance.svg)

## 実体配線図

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 2 穴離して並べた 2 本の線 (つなげない)
unused: [J1.1, J2.1]
points:
  GND: 09
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
wires:
  - a10 -- m10
  - x10 -- x12
  - x12 -- d12
  - 09 -- y9 black
notes:
  - box d12 m10 blue
  - text h20: 並んだ 10 穴 (約 2.3 cm)
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/16-perfboard-capacitance.svg)

- i 行 (CH0 側) と g 行 (CH1 側) の線が、4〜13 列の 10 穴ぶん 2 穴 (5.08 mm) 離れて並ぶ。
  **2 本はどこでもつながっていない**。線はどちらも 0.5 mm のスズめっき線をユニバーサル基板に沿わせる
- 先に**線を張らない治具 (SMA だけ)** を測っておく。SMA どうしの漏れ (3-1 の「何も入れない」)
  が基準で、線を張って増えたぶんが線どうしの容量
- 間隔を 1 穴 (2.54 mm、g 行の代わりに h 行) にしたときも測って比べる
- 2 本の線は片方の端が浮いている。部品をつながないのがこの題の中身なので、
  J1・J2 の中心導体は `unused:` に並べて、検査 (ERC) の「つながっていない」から外してある

## 容量の見積もり

平行な 2 本の線 (直径 d、中心の間隔 D) の、長さ 1 m あたりの容量は

```text
C' = π ε0 εeff / arccosh(D / d)
```

d = 0.5 mm、D = 5.08 mm で arccosh(10.2) ≈ 3.01。線の半分が空気、半分が基板
(紙フェノールやガラスエポキシ、比誘電率 4〜5) に接しているので εeff ≈ 2.5 と仮定すると、
C' ≈ 23 pF/m = 0.23 pF/cm。並んだ約 2.3 cm (10 穴の 9 間隔) で **約 0.5 pF** (見積もり)。

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 201 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag と位相 |

0.5 pF のときに見えるはずの画面 (直列治具に 0.5 pF)。

```vna
device: h4
sweep: 1M-300M 201
title: 図3 0.5 pF の漏れ — 300 MHz で S21 は −20.6 dB
dut:
  - series C 0.5p
traces:
  - S21 logmag
  - S21 phase 2deg at 90deg
markers:
  - 10M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/16-perfboard-capacitance.svg)

## 見るべき値

計算値。直列治具の S21 = 100 / (100 + 1/(jωC))。読んだ |S21| から 4-9 と同じ式で C を出す。

| 周波数 | 0.5 pF の X | S21 (計算値) | 位相 |
| --- | --- | --- | --- |
| 10 MHz | −31.8 kΩ | −50.1 dB | +89.8° |
| 100 MHz | −3.18 kΩ | −30.1 dB | +88.2° |
| 300 MHz | −1.06 kΩ | −20.6 dB | +84.6° |

分かること:

- **1 pF に満たない容量でも、300 MHz では −20 dB 台まで漏れる。** 300 MHz で 0.5 pF は
  約 1 kΩ しかない
- 位相は 300 MHz でも +84.6° で、+90° の近くからほとんど動かない。図3 の位相の線が
  平らなのは意図どおりで、**漏れの相手が容量だけ** (抵抗やコイルが混ざらない) という印
- 同じ漏れが、3-4 の自作 Open では「右端から時計回りに回る」ずれに、開いたスイッチ
  (4-15) ではアイソレーションの悪化になる
- 高い周波数の線どうしは**離す**、間に**GND の線を通す** (容量は GND へ逃げ、向かいの線へは
  漏れにくくなる)。治具の入力と出力の線をユニバーサル基板の両端に離して置くのはこのため
- 低い周波数 (10 MHz) では −50 dB と小さく、SMA どうしの漏れと区別しにくい。
  **容量は高い周波数で読む**

## 出典

自作。平行 2 線の容量の式は電磁気学の教科書にある一般的なもの。
