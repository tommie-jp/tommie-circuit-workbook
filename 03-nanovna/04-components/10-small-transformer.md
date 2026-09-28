---
book: nanovna
chapter: 4
id: 4-10
title: 小型トランスの周波数特性
tier: 100
source: 自作
board: PF
device: H4
---

# 4-10 小型トランスの周波数特性

トランスは**使える周波数の幅**を持つ。低い側は 1 次巻線のインダクタンス (励磁
インダクタンス) が足りなくなって落ち、高い側は 1 次と 2 次で結合しきれない分
(漏れインダクタンス) と巻線の容量で落ちる。フェライトのトロイダルコアに 2 本の線を
撚って巻いた **1:1 の小型トランス**を作り、S21 でその幅を測る。

## 回路図

```circuit
title: 図1 1:1 トランスを CH0 と CH1 の間に
parts:
  J1: sma b2 mirror CH0
  T1: transformer b5
  J2: sma b9 CH1
  G1: ground c2
  G2: ground c4
  G3: ground c7
  G4: ground c9
wires:
  - J1.1 -| T1.A1
  - T1.A2 -| c4
  - T1.B1 |- J2.1
  - T1.B2 -| c7
  - J1.2 -- c2
  - J2.2 -- c9
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/10-small-transformer.svg)

- CH0 の信号は 1 次巻線 (A1–A2) に、2 次巻線 (B1–B2) から CH1 へ出る。どちらの巻線も
  片側を GND に落とす
- 1:1 なので、帯域の中では S21 が 0 dB、S11 が小さい (50 Ω がそのまま 50 Ω に見える)

| 部品 | 値 | 注意 |
| --- | --- | --- |
| T1 のコア | FT37-43 (フェライト #43、外径 9.5 mm) | A<sub>L</sub> ≈ 350 nH/回² (メーカーの表の値) |
| T1 の巻線 | ポリウレタン線 0.4 mm を 2 本撚り合わせ、**8 回** (2 本いっしょに巻く) | 手巻き。巻き始めの 2 本が A1・B1 |

## 実体配線図

```perfboard
board:
  size: 16x8
  slots: on
title: 図2 トロイダルの 1:1 トランスを直列の位置に
points:
  GND: h2
parts:
  J1: sma/female-edge e1 d0 f0
  J2: sma/female-edge e16 f17
  T1: transformer e6 g6 e11 g11 FT37-43
wires:
  - e1 -- e6
  - e11 -- e16
  - g6 -- h6 black
  - g11 -- h11 black
  - h6 -- GND black
  - h6 -- h11 black
  - h11 -- h15 black
  - f0 -- f2 black
  - f2 -- GND black
  - f17 -- f15 black
  - f15 -- h15 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/10-small-transformer.svg)

- e6・g6 が 1 次 (A1・A2)、e11・g11 が 2 次 (B1・B2)。巻き始め (A1・B1) を上の e 行に、
  巻き終わり (A2・B2) を h 行の GND に
- コアは板に寝かせ、4 本の線をそれぞれの穴まで短く引き出す。図のトランスは角形の
  形で描かれる (フェンスにトロイダルの形が無い) が、足の位置の意味は同じ

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 低い側 50 kHz〜2 MHz、高い側 1 MHz〜300 MHz (2 回に分ける) |
| 点数 | 201 |
| 校正 | SOLT。範囲を変えたら校正し直す (1-4) |
| 表示 | S21 と S11 の Log Mag |
| 模型の仮定 | 等価回路。励磁インダクタンス 350 nH × 8² = 22.4 µH、漏れインダクタンス 100 nH (1 次と 2 次に 50 nH ずつ、見積もり) |

**1. 低い側** — 励磁インダクタンスが GND へ逃がす分で落ちる。

```vna
device: h4
sweep: 50k-2M 201
title: 図3 低い側 — 178 kHz で −3 dB
dut:
  - series L 50n
  - shunt L 22.4u
  - series L 50n
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 178k
  - 1M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/10-small-transformer-1.svg)

**2. 高い側** — 漏れインダクタンスが直列に入って落ちる。

```vna
device: h4
sweep: 1M-300M 201
title: 図4 高い側 — 漏れ 100 nH で 159 MHz あたりから落ちる
dut:
  - series L 50n
  - shunt L 22.4u
  - series L 50n
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 10M
  - 159M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/10-small-transformer-2.svg)

## 見るべき値

計算値 (等価回路から)。

| 周波数 | S21 | S11 | 効いている物 |
| --- | --- | --- | --- |
| 178 kHz | −3.01 dB | −3.01 dB | 励磁インダクタンス (ωL = 25 Ω) |
| 1 MHz | −0.14 dB | −14.9 dB | 帯域の中 (励磁のぶんがまだ少し残る) |
| 10 MHz | −0.03 dB | −21.9 dB | 帯域の中 |
| 159 MHz | −3.02 dB | −3.00 dB | 漏れインダクタンス (ωL = 100 Ω) |

- **低い側の −3 dB は f = 25 Ω / (2π L)。** 25 Ω は CH0 側と CH1 側の 50 Ω の並列。巻き数を
  2 倍にすると L は 4 倍になり、低い側は 1/4 の周波数まで伸びる
- **高い側は漏れインダクタンスで決まる。** 2 本を撚って巻くのは、1 次と 2 次を近づけて
  漏れを減らすため。撚らずに別々に巻くと、高い側がずっと低い周波数で落ちる
- 巻き数を増やすと低い側は伸びるが、線が長くなって漏れと巻線の容量が増え、高い側は
  縮む。**幅は巻き数では広がらず、ずれるだけ**
- #43 のフェライトは数 MHz より上で透磁率が下がり損失が増える。等価回路は L を一定と
  しているので、実測の S21 は 10 MHz 〜 数十 MHz で理想の破線より少し下がる。コアの
  材質の違いは 4-14 で見る

## 出典

自作。FT37-43 の A<sub>L</sub> はフェライトコアのメーカーの表 (#43 材、外径 0.375 インチ) の値。
