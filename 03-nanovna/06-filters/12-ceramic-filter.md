---
book: nanovna
chapter: 6
id: 6-12
title: セラミックフィルタ 455 kHz / 10.7 MHz
tier: 100
source: 自作。フィルタの規格は Murata CERAFIL のカタログ (Cat.No.P50E の SFELF10M7FA00-B0、Cat.No.P05E-16 の CFULA455KE4A-B0)
board: PF
device: H4
---

# 6-12 セラミックフィルタ 455 kHz / 10.7 MHz

ラジオの中間周波 (IF) には、決まった周波数のバンドパスを 1 個の部品にした
**セラミックフィルタ**が使われる。FM ラジオは **10.7 MHz**、AM ラジオは **455 kHz**。
ピンは 3 本 (入力・GND・出力) で、LC を何段も組まなくても急な裾が得られる。
ただし入出力のインピーダンスが 50 Ω ではない (10.7 MHz 用は 330 Ω、455 kHz 用は
1.5 kΩ) ので、NanoVNA につなぐには**直列の抵抗で終端を合わせる**。
2 種類を測り、帯域幅と損失をデータシートと比べる。

## この実験で確かめる式

セラミックフィルタは、決まった抵抗で両側を終端したときに規格どおりの形になる。
データシートの測定回路は「信号源の内部抵抗 Rg + 直列の R1 = 負荷 R2 = 入出力の
インピーダンス」。NanoVNA では Rg = 50 Ω、負荷も CH1 の 50 Ω なので、
**入口と出口に R = Z − 50 Ω を直列に入れる**。

| フィルタ | 入出力の Z | 直列の R (E24) | 終端 (R + 50 Ω) |
| --- | --- | --- | --- |
| SFELF10M7FA00 (10.7 MHz) | 330 Ω | 280 Ω → **270 Ω** | 320 Ω |
| CFULA455KE4A (455 kHz) | 1.5 kΩ | 1.45 kΩ → **1.5 kΩ** | 1.55 kΩ |

直列の R は電圧を分けるので、その分だけ S21 が下がる (フィルタが損失 0 でも)。
計算では **10.7 MHz 用で 16.1 dB、455 kHz 用で 29.8 dB**。測った S21 から
この分を差し引いた値がフィルタそのものの損失になる。

データシートの規格 (抜粋):

| 品 | 中心 | 帯域幅 | 阻止側 | 挿入損失 | 入出力の Z |
| --- | --- | --- | --- | --- | --- |
| SFELF10M7FA00-B0 | 10.700 MHz ± 30 kHz | 3 dB 幅 280 ± 50 kHz | 20 dB 幅 650 kHz 以下。スプリアス 30 dB 以上 (9〜12 MHz) | 4.0 ± 2.0 dB | 330 Ω |
| CFULA455KE4A-B0 | 455 kHz ± 1.5 kHz | 6 dB 幅 ±7.5 kHz 以上 | 40 dB 幅 ±15 kHz 以下。阻止帯域 27 dB 以上 (±100 kHz の内) | 6.0 dB 以下 | 1.5 kΩ |

ピンの並びはどちらも **① 入力・② GND・③ 出力** (カタログの外形図)。
測定回路はどちらも「Rg + R1 = R2 = 入出力の Z」で、10.7 MHz 用は Rg 50 Ω・
R1 280 Ω・R2 330 Ω と書いてある。

## 回路図

```circuit
title: 図1 10.7 MHz のセラミックフィルタ (前後に 270 Ω)
parts:
  J1: sma 2,2 mirror CH0
  R1: resistor 3,2 5,2 270
  U1: ceramic-filter 7,2 SFELF10M7
  R2: resistor 9,2 11,2 270
  J2: sma 13,2 CH1
  G1: ground 2,3
  G2: ground 7,4
  G3: ground 13,3
wires:
  - J1.1 -- 3,2
  - 5,2 -- U1.IN
  - U1.OUT -- 9,2
  - 11,2 -- J2.1
  - U1.GND -- 7,4
  - J1.2 -- 2,3
  - J2.2 -- 13,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/12-ceramic-filter-1.svg)

```circuit
title: 図2 455 kHz のセラミックフィルタ (前後に 1.5 kΩ)
parts:
  J1: sma 2,2 mirror CH0
  R1: resistor 3,2 5,2 1.5k
  U1: ceramic-filter 7,2 CFULA455KE4A
  R2: resistor 9,2 11,2 1.5k
  J2: sma 13,2 CH1
  G1: ground 2,3
  G2: ground 7,4
  G3: ground 13,3
wires:
  - J1.1 -- 3,2
  - 5,2 -- U1.IN
  - U1.OUT -- 9,2
  - 11,2 -- J2.1
  - U1.GND -- 7,4
  - J1.2 -- 2,3
  - J2.2 -- 13,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/12-ceramic-filter-2.svg)

- ピンの並びは ① 入力・② GND・③ 出力。別の品に替えるときは**データシートの図で
  確かめてから**挿す
- セラミックフィルタに直流をかけない (データシートの注意)。NanoVNA は直流を
  出さないのでこのままでよいが、回路に組むときは出力にコンデンサを入れる

## 実体配線図

部品面から見た図。2 枚は抵抗とフィルタが違うだけで同じ並び。
**U1 は 3 ピンの部品の姿 (TO-92 の形) で代わりに描いた**。実物は平たい箱。

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図3 10.7 MHz 用を perfboard に組む
parts:
  J1: sma/female-edge a10 09
  R1: resistor c10 f10 270
  U1: ic3 h10 i10 j10 SFELF10M7
  R2: resistor l10 o10 270
  J2: sma/female-edge x10 y9
wires:
  - a10 -- c10
  - f10 -- h10
  - j10 -- l10
  - o10 -- x10
  - i10 -- i7 black
  - 09 -- b9 black
  - b9 -- b7 black
  - b7 -- i7 black
  - i7 -- o7 black
  - y9 -- o9 black
  - o9 -- o7 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/perfboard/12-ceramic-filter-1.svg)

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図4 455 kHz 用を perfboard に組む
parts:
  J1: sma/female-edge a10 09
  R1: resistor c10 f10 1k5
  U1: ic3 h10 i10 j10 CFULA455
  R2: resistor l10 o10 1k5
  J2: sma/female-edge x10 y9
wires:
  - a10 -- c10
  - f10 -- h10
  - j10 -- l10
  - o10 -- x10
  - i10 -- i7 black
  - 09 -- b9 black
  - b9 -- b7 black
  - b7 -- i7 black
  - i7 -- o7 black
  - y9 -- o9 black
  - o9 -- o7 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/perfboard/12-ceramic-filter-2.svg)

- U1 の真ん中のピン (GND) は、真下 (l 行) の GND の筋へ最短で落とす

## 掃引の設定

| 項目 | 10.7 MHz 用 | 455 kHz 用 |
| --- | --- | --- |
| 範囲 | 9.7〜11.7 MHz (幅 2 MHz) | 425〜485 kHz (幅 60 kHz) |
| 点数 | 201 (10 kHz おき) | 121 (500 Hz おき) |
| 校正 | SOLT。それぞれの範囲で校正し直す (1-4) | 同じ |
| 表示 | S21 の Log Mag | 同じ |

図の模型は、規格の帯域幅に合わせて作った 4 段の LC バンドパスの**等価回路**
(形の目安。実物の中身ではない)。損失は規格の中央の 4 dB になるよう直列共振に抵抗を
入れた。10.7 MHz 用の**見えるはずの画面**。

```vna
device: h4
sweep: 9.7M-11.7M 201
title: 図5 10.7 MHz 用 (等価回路) — 中心で −20.1 dB、3 dB 幅 282 kHz
dut:
  - series R 270
  - shunt L 209.8n
  - shunt C 1055p
  - series L 277.3u esr 187
  - series C 0.7979p
  - shunt L 86.89n
  - shunt C 2546p
  - series L 114.9u esr 187
  - series C 1.926p
  - series R 270
traces:
  - S21 logmag
markers:
  - 10.56M
  - 10.7M
  - 10.8425M
  - 11.2M
notes:
  - band 10.56M 10.8425M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/12-ceramic-filter-1.svg)

455 kHz 用。

```vna
device: h4
sweep: 425k-485k 121
title: 図6 455 kHz 用 (等価回路) — 中心で −33.8 dB、6 dB 幅 16 kHz
dut:
  - series R 1500
  - shunt L 24.11u
  - shunt C 5076p
  - series L 27.57m esr 907
  - series C 4.438p
  - shunt L 9.985u
  - shunt C 12250p
  - series L 11.42m esr 907
  - series C 10.71p
  - series R 1500
traces:
  - S21 logmag
markers:
  - 446.9k
  - 455k
  - 463.3k
  - 480k
notes:
  - band 446.9k 463.3k
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/12-ceramic-filter-2.svg)

## 見るべき値

計算値 (上の等価回路による)。

| 図 | マーカー | 周波数 | S21 | 意味 |
| --- | --- | --- | --- | --- |
| 図5 | 1 | 10.560 MHz | −23.12 dB | 3 dB 幅の下の端 |
| 図5 | 2 | 10.700 MHz | **−20.12 dB** | 中心。抵抗の 16.1 dB + フィルタの 4.0 dB |
| 図5 | 3 | 10.8425 MHz | −23.12 dB | 3 dB 幅の上の端 (幅 282 kHz) |
| 図5 | 4 | 11.200 MHz | −53.13 dB | 中心から 500 kHz 上 |
| 図6 | 1 | 446.9 kHz | −39.89 dB | 6 dB 幅の下の端 |
| 図6 | 2 | 455.0 kHz | **−33.83 dB** | 中心。抵抗の 29.8 dB + フィルタの 4.0 dB |
| 図6 | 3 | 463.3 kHz | −39.85 dB | 6 dB 幅の上の端 (幅 16.4 kHz) |
| 図6 | 4 | 480.0 kHz | −69.65 dB | 中心から 25 kHz 上 |

- 測った S21 から直列の抵抗の分 (16.1 dB・29.8 dB) を引くと、フィルタそのものの
  挿入損失が出る。規格はどちらも 6 dB 以下
- 等価回路の裾は規格より緩い。10.7 MHz 用の 20 dB 幅は 646 kHz (規格 650 kHz 以下)、455 kHz 用の 40 dB 幅は 55 kHz (規格 30 kHz 以下)。**実物の裾は
  図より急なはず**で、合否はデータシートの数で判定する

分かること:

- **1 個の部品で、LC の多段 (6-3) より狭く急なバンドパス**が得られる。中心の
  周波数は工場で決まっていて、調整が要らない
- 規格の帯域幅・損失は**決まった終端で測った値**。50 Ω のまま直につなぐと形が
  崩れる (中の共振の負荷が変わるため)。部品を試すときは、まず終端を合わせる
- 直列の抵抗で合わせる方法は簡単だが、S21 が 16〜30 dB 下がる。NanoVNA の
  ダイナミックレンジ (目安で 70 dB ほど) のうち、裾を見るのに使える幅が
  それだけ減る。損失の少ない合わせ方 (L 型の整合・トランス) は 6-21 で扱う

## 出典

自作。セラミックフィルタの規格と測定回路は Murata のカタログ
「CERAFIL (Filters/Traps/Discriminators) for Audio/Visual」(Cat.No.P50E、SFELF10M7FA00-B0 の行) と
「Ceramic Filters (CERAFIL) / Ceramic Discriminators」(Cat.No.P05E-16、CFULA455KE4A-B0 の行) による。
