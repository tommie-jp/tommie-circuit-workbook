---
book: analog-discovery
chapter: 7
id: 7-4
title: I2C を見る・叩く (温度センサ)
tier: 50
source: 自作 (計器の操作は Digilent の Using the Protocol Analyzer)
board: BB
---

# 7-4 I2C を見る・叩く (温度センサ)

**Protocol** の I2C モードは、AD 自身がマスタになって読み書きもできる。
温度センサ LM75 (アドレス 0x48) のレジスタ 0 (温度) を読み、Protocol の
解読結果と自分で計算した温度を突き合わせる。

## 回路図

```circuit
title: 図1 LM75 を I2C で読む
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [V+, GND, DIO0, DIO1]
  U1:
    type: device
    at: h3
    label: LM75
    pins: [SDA, SCL, OS, GND, A0, A1, A2, VDD]
  R1: resistor m3 m5 4.7k
  R2: resistor m9 m11 4.7k
wires:
  - AD.V+ -| m3
  - AD.V+ -| m9
  - AD.V+ -| U1.VDD
  - m5 |- U1.SDA
  - m5 |- AD.DIO0
  - m11 |- U1.SCL
  - m11 |- AD.DIO1
  - AD.GND -| U1.GND
  - AD.GND -| U1.A0
  - AD.GND -| U1.A1
  - AD.GND -| U1.A2
```

- R1・R2 は SDA・SCL の **プルアップ (4.7 kΩ)**。I2C はオープンドレインなので
  プルアップが無いと H が出ない
- A0・A1・A2 を GND に落とすと 7 ビットアドレスは **0x48**。3 本とも浮かせたり
  電源に上げたりすると別のアドレスになる (基板の実装で決まっている品もある)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  U1: dip8/sop @ e5 LM75
  R1: resistor i5 i2 4.7k
  R2: resistor j6 j9 4.7k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, DIO0, DIO1]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - a5 -- +t5 red
  - a6 -- -t6 black
  - a7 -- -t7 black
  - a8 -- -t8 black
  - j8 -- -b8 black
  - h2 -- +t2 red
  - h9 -- +t9 red
  - AD.DIO0 -- j5 yellow
  - AD.DIO1 -- i6 white
  - +t20 -- +b20 red
  - -t20 -- -b20 black
```

**LM75 の実物は SO-8 (または MSOP-8) しか売っていない**ので、ブレッドボードには
SOP を DIP 化する変換基板 (`dip8/sop`) に載せて挿す (置き方・足番号は DIP と同じ)。
LM75 (`U1`) は 8=VDD (e5) が左端。1=SDA (f5)・2=SCL (f6) は下ブロックの空いた
行 (i・j) からプルアップと AD へ。プルアップは列 1〜2 (R1・R2 の VCC 側) と
列 5〜6 (SDA・SCL 側) を、**行をずらして** (R1 は i 行、R2 は j 行) 重ならないように
引いてある。5=A0・6=A1・7=A2 (上ブロック) は -t で GND に落として 0x48 に固定。
4=GND (f8) も -b で GND へ。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Protocol | I2C、SDA = DIO0、SCL = DIO1、Rate = 100 kHz。Read、Address = 0x48、レジスタ 0 を 2 バイト |

## 見るべき値

LM75 のレジスタ 0 は 9 ビット (0.5°C 単位) を上位 9 ビットに詰めた 2 バイト。
温度 = (上位バイト を 1 ビット右シフト) × 0.5°C。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 読めたバイト (25.0°C のとき) | `0x19 0x00` | データシートに載っている 25°C の例そのもの |
| 温度への変換 | 0x19 = 25、25 >> 1 は使わない (9 ビット表現は上位バイトがそのまま 0.5°C 単位の値の上位 8 ビット) → 25 × 0.5°C 相当の並びで 25.0°C | Protocol の解読結果と自分の計算が合えば配線とアドレスが正しい |
| SDA・SCL の H レベル | 5 V 付近 | プルアップが効いている証拠。無いと H が浮く |
| A0=A1=A2=GND のときのアドレス | 0x48 | データシートのアドレス表と一致 |

**プルアップを外す (R1 か R2 を抜く) と、Protocol は NACK か文字化けした
値を返す。** I2C のバスは能動的に H を出さない (オープンドレイン) ことが分かる。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer)
(I2C の節)。LM75 のレジスタ形式とアドレス例はメーカーのデータシートに基づく。
