---
book: fpga
chapter: 0
id: 0-3
title: 3.3 V の決まり — Pico 2 と FPGA のピンに 5 V を入れない
tier: 50
source: 自作
board: BB
device: PICO
---

# 0-3 3.3 V の決まり — Pico 2 と FPGA のピンに 5 V を入れない

> [!WARNING]
> **この題は実機で組んでいない。** 「見るべき値」の数は計算値か目安で、測った値ではない。
> 組むときは、自分の Pico 2 と AD3 で測って確かめてほしい。

ほかの冊の既定は 5 V だが、この冊は **3.3 V** で通す。
Pico 2 の GPIO も FPGA の入出力ピンも、信号の H は 3.3 V だから。
5 V の信号をうっかり入れると、ピンの保護回路を越えて壊す恐れがある。

この題では、Pico 2 の 3V3 ピンから LED を 1 つ点け、電源と GND の取り回しを確かめる。
プログラムは使わない。信号を出す練習は 0-4 に置く。

## ピンの電圧

| 所 | ピン | 電圧 | 使い方 |
| --- | --- | --- | --- |
| Pico 2 | GP0〜GP28 (GPIO) | 3.3 V の信号 | 入出力。ここに 5 V を入れない |
| Pico 2 | 3V3 (36 番) | 3.3 V の電源 | 基板の上のレギュレータが出す。LED やプルアップの電源に使う |
| Pico 2 | VBUS (40 番) | USB の 5 V そのまま | 5 V の電源が要るときだけ。GPIO や 3V3 の線に混ぜない |
| Pico 2 | VSYS (39 番) | 電源の入口 | 外から給電するときの入口。信号には使わない |
| Tang Nano 9K | IO のピン (`IO` + 番号) | 3.3 V の信号 | 入出力 |
| Tang Nano 9K | `IO79`〜`IO86` | **1.8 V の信号** | 右の列の BANK3。3.3 V の線を直に入れない |
| Tang Nano 9K | `5V` と書かれたピン | 5 V の電源 | 信号には使わない |

Raspberry Pi の資料には、条件つきで 5 V を許す記述のある機種もある。条件は機種ごとに違い、外れると壊す。
この冊は条件を調べずに済むよう、**ピンには一律に 5 V を入れない**。
ほかの冊で 5 V の回路を組んだら、この冊に持ち込むときは 3.3 V に直す。

Tang Nano 9K のピンの電圧は、Sipeed の wiki のピン配置図で確かめた (出典)。BANK3 の `IO79`〜`IO86` が 1.8 V で、ほかの IO は 3.3 V。

## 回路図

```circuit
title: 図1 3V3 から抵抗と LED を通して GND へ
parts:
  U1: pico2 3,5.2
  R1: resistor 6,6 6,9 330
  D1: led 6,9 6,11 red
  G1: ground 6,11
  G2: ground 5,8.2
wires:
  - U1.3V3 -| 6,6
  - U1.GND38 -| 5,8.2
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/00-tools/circuit/03-voltage-rule-3v3.svg)

- 3V3 (36 番) から R1 (330 Ω) と LED を通って GND に戻る。信号のピンは使わない
- 電流は I = (3.3 V − V<sub>F</sub>) / R1。赤 LED の V<sub>F</sub> を 2.0 V と置くと (3.3 − 2.0) / 330 ≈ 3.9 mA (計算値)
- 330 Ω は E24 の値。LED の電流は 1 本あたり数 mA に抑える
- GND には、Pico 2 の GND (38 番) をつなぐ。戻り道が無いと LED は点かない

## 実体配線図

```breadboard
title: 図2 3V3 の線を LED に引き、AD3 の DIO0 で見る
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor a30 a33 330
  D1: led c33(A) c36(K) red
  AD:
    type: device
    at: top
    label: AD3 Logic
    pins: [DIO0, GND]
wires:
  - AD.DIO0 -- b30 yellow
  - AD.GND -- -t42 black
  - MCU.3V3 -- +t9 red
  - MCU.GND38 -- -t7 black
  - +t30 -- c30 red
  - d36 -- -t36 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/00-tools/breadboard/03-voltage-rule-3v3.svg)

- `pico2 @ h5` は USB を左に向けた向き。3V3 (36 番) は 9 列の上、GND (38 番) は 7 列の上にある
- 3V3 は赤い線で上の + レールへ、GND は黒い線で上の − レールへ出す
- 上の + レールの 30 列から R1 (a30〜a33)、LED のアノード (c33) へ。カソード (c36) は d36 から − レールへ
- AD3 の DIO0 は、R1 の手前 (30 列、+ レールの電圧) に挿す。LED の手前ではなく、3V3 の線そのものを見る
- AD3 の GND は − レールへ。Pico 2 の GND と AD3 の GND は、**必ず同じレールで共通にする**

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 を Enable。標本化は 100 kS/s ほど。H/L の読み取りだけなので遅くてよい |

電源は Pico 2 の USB から取る。AD3 の電源ツール (Supplies) は使わない。
AD3 の DIO は 3.3 V の信号で、Pico 2 の GPIO と電圧がそろう (AD3 の入力の許容は Digilent の仕様書で確かめる)。

```logic
title: 図3 3V3 の線は H のまま動かない
device: ad3
time: 1ms/div
sample: 100kHz
signals:
  DIO0: dio0 high
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/00-tools/logic/03-voltage-rule-3v3.svg)

## 見るべき値

実機で測っていない。計算値と目安を並べる。

| 測る所 | 見るべき値 | 分かること |
| --- | --- | --- |
| LED | 点く | 3V3 → R1 → LED → GND の道が通っている |
| LED の電流 | 約 3.9 mA (計算値。赤 LED の V<sub>F</sub> = 2.0 V と置いた) | GPIO の電流の目安 (1 本数 mA) に収まる |
| Logic の DIO0 | H のまま変わらない (目安) | 3V3 の線を読めている。AD3 の GND が共通 |
| Logic の DIO0 (AD3 の GND を外す) | H にならず、不安定になる (目安) | GND が共通でないと基準が無い。0-4 でも確かめる |

LED が点かないとき、先に疑うのは GND。3V3 だけをつないで GND を忘れると、電流の戻り道が無い。

## 出典

自作。Pico 2 のピン番号と電圧は Raspberry Pi の Pico 2 のデータシート (Raspberry Pi Pico-series の資料)。
Tang Nano 9K のピンの電圧は
[Sipeed の Tang Nano 9K の wiki](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html) のピン配置図。
LED の電流の考え方は 01-circuits の 11-1 と同じ。
