---
book: analog-discovery
chapter: 7
id: 7-4
title: I2C を見る・叩く (温度センサー)
tier: 50
source: 自作 (計器の操作は Digilent の Using the Protocol Analyzer)
board: BB
---

# 7-4 I2C を見る・叩く (温度センサー)

**Protocol** の I2C モードは、AD 自身がマスタになって読み書きもできる。
温度センサー LM75 (アドレス 0x48) のレジスタ 0 (温度) を読み、Protocol の
解読結果と自分で計算した温度を突き合わせる。

## 回路図

```circuit
title: 図1 LM75 を I2C で読む
parts:
  AD:
    type: device
    at: c2c0f0
    label: Analog Discovery
    pins: [V+, DIO0, DIO1, GND]
    turn: mirror
  U1:
    type: device
    at: d10
    label: LM75
    pins: [SDA, SCL, OS, GND, A2, A1, A0, VDD]
  R1: resistor a6 b6 4.7k
  R2: resistor a8 b8 4.7k
  G1: ground e5
wires:
  - AD.V+ -| a4
  - a4 -- a6
  - a6 -- a8
  - a8 -- a12
  - a12 -- f12
  - f12 -- f9
  - U1.VDD -| f9
  - AD.DIO0 -| b6
  - b6 |- U1.SDA
  - AD.DIO1 -| b8
  - b8 |- U1.SCL
  - AD.GND -| e5
  - U1.GND -| e5
  - U1.A2 -| e5
  - U1.A1 -| e5
  - U1.A0 -| e5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/04-i2c-temperature.svg)

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
  R1: resistor g5 g2 4.7k
  R2: resistor h6 h9 4.7k
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [V+, GND, DIO0, DIO1]
wires:
  - AD.V+ -- +b3 red
  - AD.GND -- -b4 black
  - AD.DIO0 -- j5 yellow
  - AD.DIO1 -- j6 white
  - j2 -- +b2 red
  - j9 -- +b9 red
  - j8 -- -b8 black
  - a5 -- +t5 red
  - a6 -- -t6 black
  - a7 -- -t7 black
  - a8 -- -t8 black
  - +t12 -- +b12 red
  - -t13 -- -b13 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/04-i2c-temperature.svg)

**LM75 の実物は SO-8 (または MSOP-8) しか売っていない**ので、ブレッドボードには
SOP を DIP 化する変換基板 (`dip8/sop`) に載せて挿す (置き方・PIN 番号 は DIP と同じ)。
LM75 (`U1`) は 8=VDD (e5) が左端。1=SDA (f5)・2=SCL (f6) は下ブロックの空いた
行からプルアップと AD へ。プルアップは R1 (g 行、2〜5 列) と R2 (h 行、6〜9 列) を
**行をずらして**重ならないように置き、VCC 側 (2・9 列) を j 行から +b へ、
SDA・SCL 側 (5・6 列) は足と同じ列でつなぐ。AD は板の下に置き、DIO0・DIO1 を
j5・j6 へ、V+・GND を下のレールへ入れる。
5=A2 (e8)・6=A1 (e7)・7=A0 (e6) (上ブロック) は -t で GND に落として 0x48 に固定。
4=GND (f8) は -b で GND へ。上下のレールは 12・13 列で渡す。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Protocol | I2C、SDA = DIO0、SCL = DIO1、Rate = 100 kHz。Read、Address = 0x48、レジスタ 0 を 2 バイト。プルアップは 5 V だが、AD3 の DIO 入力は 5 V まで耐える (5 V tolerant) |

```scope
title: 図3 アドレス 0x91 を送ると、9 クロック目で LM75 が ACK (SDA = L) を返す
time: 20us/div
trigger: ch2 falling 2.5V at -1div
ch1: {wave: = 5V*(step(2.5us-t)+step(t-5us)*step(95us-t)*step(sin(2*pi*100kHz*(t-5us)))+step(t-95us)), range: 2V/div, position: 1div}
ch2: {wave: = 5V*(step(-t)+step(t-2.5us)*step(12.5us-t)+step(t-32.5us)*step(42.5us-t)+step(t-72.5us)*step(82.5us-t)+step(t-100us)), range: 2V/div, position: -2div}
measure: [vmax, vmin]
notes:
  - band 0 10us: スタート
  - band 85us 95us: ACK
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/04-i2c-temperature.svg)

図3 は SCL (CH1、DIO1) と SDA (CH2、DIO0) の計算値の波形で、Rate = 100 kHz (1 クロック 10 µs)。
SCL が L の間に SDA が変わり、SCL が H の間は動かない。SDA が SCL の H のうちに H→L になる最初の変化がスタート条件。
8 ビット 1001 0001 (0x91) を送り、9 クロック目 (85〜95 µs) は LM75 が SDA を L に引いて ACK、
SCL が H のうちに SDA が L→H になる最後の変化がストップ条件。読み出しの 2 バイトはこの後に続く。

## 見るべき値

LM75 のレジスタ 0 は 9 ビット (0.5°C 単位) を上位 9 ビットに詰めた 2 バイト。
上位バイトがそのまま 1°C 単位の整数部 (2 の補数)、下位バイトの最上位ビットが 0.5°C。
温度 = 上位バイト + (下位バイトの最上位ビット) × 0.5°C (9 ビット値 ((上位 << 1) | (下位 >> 7)) × 0.5°C と同じ)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 読めたバイト (25.0°C のとき) | `0x19 0x00` | データシートに載っている 25°C の例そのもの |
| 温度への変換 | 上位 0x19 = 25 → 25°C、下位 0x00 の最上位ビットは 0 → +0°C。合わせて 25.0°C (9 ビット値 0x032 = 50 × 0.5°C でも同じ) | Protocol の解読結果と自分の計算が合えば配線とアドレスが正しい |
| SDA・SCL の H レベル | 5 V 付近 | プルアップが効いている証拠。無いと H が浮く |
| A0=A1=A2=GND のときのアドレス | 0x48 | データシートのアドレス表と一致 |

**プルアップを外す (R1 か R2 を抜く) と、Protocol は NACK か文字化けした
値を返す。** I2C のバスは能動的に H を出さない (オープンドレイン) ことが分かる。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer)
(I2C の節)。LM75 のレジスタ形式とアドレス例はメーカーのデータシートに基づく。
