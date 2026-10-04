---
book: analog-discovery
chapter: 8
id: 8-1
title: ジャンパ 1 本のスルーの S21 を 100 kHz〜10 MHz
tier: 50
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 8-1 ジャンパ 1 本のスルーの S21 を 100 kHz〜10 MHz

ブレッドボードの限界を測る前に、まず**基準**を作る。ジャンパ線 1 本だけを
挟んだだけの「スルー」を Network アナライザで 100 kHz〜10 MHz まで掃引し、
S21 (出力 ÷ 入力) がどれだけ 0 dB からずれるかを見る。ここで平らなら、
ブレッドボードの限界は 8-2 以降で測る**別の原因** (列間容量・ジャンパの
インダクタンス) だと分かる。

## 回路図

```circuit
title: 図1 ジャンパ 1 本のスルーと負荷抵抗
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  J1: short c3 c6
  Rload: resistor c6 c9 1k
  G1: ground c11
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.1- -| c11
  - AD.2+ -| c6
  - AD.2- -| c11
  - c9 -- c11
  - AD.GND -| c11
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/circuit/01-jumper-s21.svg)

- 1+ は W1 の節点 (ジャンパの手前)、2+ はジャンパの向こう側 (負荷抵抗の頭)。
  1−・2− はどちらも GND — 片側基準の測定
- 負荷 1 kΩ は**オシロの入力インピーダンス (1 MΩ) だけに頼らない**ため。
  1 MΩ だけだと僅かな漏れ電流でも電圧が動いてしまう

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rload: resistor c10 c15 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow [h-10]
  - e5 -- e10 orange
  - AD.1+ -- b5 white [h10]
  - AD.2+ -- b10 gray
  - AD.GND -- -t3 black
  - AD.1- -- -t8 black
  - AD.2- -- -t12 black
  - a15 -- -t15 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/breadboard/01-jumper-s21.svg)

- 橙の線 (5 列 → 10 列、約 5 cm) が**測るジャンパそのもの**。ほかの配線は
  測定のための接続で、長さは気にしなくてよい
- 1+ (5 列) と 2+ (10 列) の間、ジャンパだけを挟む。それ以外の寄り道が無いように

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Network | 掃引 100 kHz〜10 MHz、点数 101、振幅 1 V、Reference = CH1、DUT = CH2 |
| 表示 | S21 の Log Mag と位相 |

10 MHz は AD3 の 2×15 ヘッダ直の帯域 (9 MHz @ −3 dB、5-8) を超えるので、この題は
**BNC アダプタを付けて**測る (Scope 30+ MHz、Wavegen 12 MHz @ −3 dB)。CH1 を基準にした比を
読むので、2 つのチャンネルが同じ帯域を持つ限り、帯域の影響は小さい (目安)。

```scope
title: 図3 ジャンパを通した 10 MHz — CH2 は CH1 に重なり、遅れは 0.15° (0.4 ns) しかない
time: 20ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 10MHz 1V, range: 500mV/div}
ch2: {wave: sine 10MHz 1V phase -0.15deg, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/scope/01-jumper-s21.svg)

図3 は 10 MHz の 1 点をオシロの時間波形で見た画面 (計算値。BNC アダプタを付けて測る)。
CH1 (ジャンパの手前) と CH2 (向こう側) は、100 ns の周期の中で 0.4 ns しかずれず、振幅も同じ 2.00 V なので、
画面では 1 本に見える。Network の S21 が 0 dB・0° に張り付くのは、時間波形ではこの重なりのこと。

## 見るべき値

計算値。ジャンパ (約 5 cm) の直列インピーダンスは、抵抗分が数十 mΩ、
インダクタンスが約 43 nH (8-3 で計算する経験式と同じ)。負荷 1 kΩ に対して
どちらも無視できるほど小さい。

| 周波数 | S21 (計算値) | 分かること |
| --- | --- | --- |
| 100 kHz | −0.0004 dB、位相 −0.0015° | ジャンパの抵抗・インダクタンスの影響は測定誤差以下 |
| 1 MHz | −0.0004 dB、位相 −0.015° | 同上。−0.0004 dB は抵抗 50 mΩ の分で、周波数によらず平ら |
| 10 MHz | −0.0005 dB、位相 −0.15° | 10 MHz でもズレは 1000 分の 1 dB 以下 |

**ジャンパ線 1 本の「スルー」自体はブレッドボードの弱点ではない。** 弱いのは
使っていない列どうしの容量 (8-2) や、ジャンパ自身のインダクタンス
(単体では小さくても、低いインピーダンスの回路に入ると効いてくる。8-3・8-4)。

```graph
title: 図4 ジャンパ 1 本のスルーは 10 MHz でも −0.0005 dB・−0.15° しか動かない
x: 周波数 Hz log 100k..10M
y:
  - S21 dB -0.001..0
  - 位相 deg -0.2..0
lines:
  S21 dB: -10*log10(((1000+0.05)^2+(2*pi*x*43n)^2)/1000^2)
  位相 deg: -deg(atan2(2*pi*x*43n, 1000.05))
notes:
  - mark 1M
  - mark 10M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/graph/01-jumper-s21.svg)

縦軸は 0.001 dB・0.2° の幅しかない。ふつうの Bode 線図の尺度 (数十 dB) なら 0 dB の
水平線にしか見えない。模型はジャンパの抵抗 50 mΩ・43 nH と負荷 1 kΩ。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
