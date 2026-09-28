---
book: nanovna
chapter: 4
id: 4-12
title: セラミックフィルタ / SAW (部品として)
tier: 100
source: 自作
board: PF
device: H4
---

# 4-12 セラミックフィルタ / SAW (部品として)

FM ラジオの中間周波 (10.7 MHz) の**セラミックフィルタ**は、圧電セラミックの機械的な
共振で狭い帯域だけを通す 3 本足の部品。コイルとコンデンサで組むフィルタ (第 6 章) を
1 個に収めた物として、通す幅と、**50 Ω ではない入出力のインピーダンス**の扱いを見る。
同じ考え方の部品に、数百 MHz〜GHz で使う **SAW フィルタ** (表面弾性波) がある。

## 回路図

セラミックフィルタは入出力が **330 Ω** で作られている。50 Ω の NanoVNA にそのまま
繋ぐと、通過帯域の形が崩れる。そこで**直列に 270 Ω** を入れ、フィルタから見た相手を
50 + 270 = 320 Ω (≈ 330 Ω) にする。

```circuit
title: 図1 10.7 MHz のセラミックフィルタを 270 Ω で 330 Ω 系に
parts:
  J1: sma b2 mirror CH0
  R1: resistor b3 b5 270
  FL1:
    type: ic3
    at: b7
    label: SFELF10M7
    pins: [IN, GND, OUT]
  R2: resistor b9 b11 270
  J2: sma b12 CH1
  G1: ground c2
  G2: ground d7
  G3: ground c12
wires:
  - J1.1 -- b3
  - b5 -- FL1.IN
  - FL1.GND -- d7
  - FL1.OUT -- b9
  - b11 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c12
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/12-ceramic-filter.svg)

| 部品 | 値 | 注意 |
| --- | --- | --- |
| FL1 | 村田製作所 SFELF10M7FA00-B0 (10.700 MHz ± 30 kHz、3 dB 幅 280 ± 50 kHz、挿入損失 4.0 ± 2.0 dB、入出力 330 Ω) | 足は ① 入力・② GND・③ 出力 (カタログの外形図。6-12 と同じ) |
| R1・R2 | 270 Ω (E24) | 330 − 50 = 280 Ω に近い E24 |

## 実体配線図

```perfboard
board:
  size: 16x8
  slots: on
title: 図2 セラミックフィルタと 270 Ω 2 本
points:
  GND: h2
parts:
  J1: sma/female-edge e1 d0 f0
  J2: sma/female-edge e16 f17
  R1: resistor e2 e6 270
  FL1: ic3 e7 e8 e9 SFELF10M7
  R2: resistor e10 e14 270
wires:
  - e1 -- e2
  - e6 -- e7
  - e9 -- e10
  - e14 -- e16
  - e8 -- h8 black
  - f0 -- f2 black
  - f2 -- GND black
  - GND -- h8 black
  - h8 -- h15 black
  - f17 -- f15 black
  - f15 -- h15 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/12-ceramic-filter.svg)

- FL1 の真ん中の足 (e8) を h 行の GND へ最短で落とす。GND の足が長いと、帯域の外の
  減衰が浅くなる (入力と出力が GND の線を通して結合する)
- R1・R2 はフィルタの足のすぐ隣に。フィルタから見た 330 Ω の相手はこの抵抗の位置で決まる

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 10.3 MHz〜11.1 MHz (中心 10.7 MHz、幅 800 kHz。3 dB 幅の約 3 倍。これより広げると S11 の X の振れが目盛を決め、R の山が潰れる) |
| 点数 | 401 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag と S11 の R・X |
| 模型の仮定 | 等価回路。フィルタを 330 Ω 系の 2 段バターワース (中心 10.7 MHz・幅 280 kHz) とし、損失は入れない |

見えるはずの画面 (R1・R2 も入れた理想の模型)。

```vna
device: h4
sweep: 10.3M-11.1M 401
title: 図3 セラミックフィルタの等価回路 — 中心 10.7 MHz で −16.1 dB、幅 280 kHz
dut:
  - series R 270
  - series L 265.3u
  - series C 0.834p
  - shunt L 90.83n cp 2.436n
  - series R 270
traces:
  - S21 logmag
  - S11 r
  - S11 x
markers:
  - 10.56M
  - 10.7M
  - 10.84M
notes:
  - band 10.56M 10.84M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/12-ceramic-filter.svg)

## SAW フィルタ

SAW フィルタ (315 MHz・433.92 MHz などの受信機の前段用) も同じ考え方で測れる。

- ほとんどが**面実装** (数 mm 角) なので、変換基板に載せてから 3-1 の治具に挿す
- 多くは入出力が 50 Ω で作られていて、270 Ω のような抵抗は要らない (データシートで確かめる)
- 周波数が高いぶん、治具の線の長さが効く。**3-6 で見た治具の限界 (300 MHz くらい) に
  近い**ので、ポート延長 (3-7) か De-embedding (3-8) を入れてから読む

## 見るべき値

計算値 (等価回路と R1・R2 から)。

| 周波数 | S21 | S11 の R + jX | 読み方 |
| --- | --- | --- | --- |
| 10.56 MHz | −19.2 dB | 380.6 Ω − j316.4 Ω | 帯域の下の端 (中心から −3 dB) |
| 10.7 MHz | −16.1 dB | 590.0 Ω − j0.1 Ω | 中心 |
| 10.84 MHz | −19.1 dB | 381.6 Ω + j312.5 Ω | 帯域の上の端 (中心から −3 dB) |

- **中心でも S21 は −16.1 dB。** 270 Ω の抵抗 2 本で電力の多くを熱にしている
  (フィルタから見た相手を 330 Ω にするための代償。S21 = 50 / 320 = 0.156)。実物はこれにフィルタ自身の挿入損失
  (カタログで 4.0 ± 2.0 dB) が加わり、理想の破線より下に出る
- **帯域の幅は中心の値から 3 dB 下がった所で読む** (0 dB からではない)。
  データシートの「3 dB 帯域幅」と比べる
- **S11 は中心でも小さくならない。** 270 Ω で合わせたのはフィルタの側で、NanoVNA の
  50 Ω から見ると中心で 590 Ω (270 + 320) の負荷のまま (S11 は −1.5 dB)。S11 を小さくしたいなら 50 Ω と 330 Ω の
  間を L 型の整合回路 (7-4) にする
- 270 Ω を外して 50 Ω に直に繋ぐと、帯域の中に山と谷 (リップル) が出て幅も変わる。
  外して測り比べると、**相手のインピーダンスで形が変わる部品**だと分かる

## 出典

自作。SFELF10M7FA00-B0 の値 (中心 10.700 MHz ± 30 kHz、3 dB 帯域幅 280 ± 50 kHz、
挿入損失 4.0 ± 2.0 dB、入出力 330 Ω) と足の並びは、村田製作所のカタログ
「CERAFIL (Filters/Traps/Discriminators) for Audio/Visual」(Cat.No.P50E) による。
