---
book: analog-discovery
chapter: 1
id: 1-1
title: Supplies — +5 V と −5 V を出して電圧計で読む
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 1-1 Supplies — +5 V と −5 V を出して電圧計で読む

WaveForms の最初の 2 つの計器、**Supplies** (電源) と **Voltmeter** (電圧計) を使う。
Analog Discovery 3 (AD3) の電源から +5 V と −5 V を出し、それぞれに 1 kΩ の負荷を
つないで、オシロスコープの 2 つの入力で電圧を読む。

## 回路図

```circuit
title: 図1 2 つの電源に負荷と電圧計
parts:
  V1: vsource a1 c1 5
  R1: resistor a3 c3 1k
  M1: voltmeter a5 c5 l=$\mathrm{CH1}$
  V2: vsource c7 a7 5
  R2: resistor a9 c9 1k
  M2: voltmeter a11 c11 l=$\mathrm{CH2}$
  G1: ground c6
wires:
  - a1 -- a3 -- a5
  - a7 -- a9 -- a11
  - c1 -- c3 -- c5 -- c6 -- c7 -- c9 -- c11
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/circuit/01-supplies.svg)

- V1 が V+ (GND に対して +5 V)、V2 が V− (**GND に対して −5 V**。+ 側を GND に向けて描いてある)
- 電圧計は**上の番地が + 側**。CH2 は −5 V を読む

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery 3
# 上の赤いレール = +5 V (V+)、上の青いレール = GND。−5 V (V−) はレールに出さず 15 列へ直に
board: half
parts:
  R1: resistor c5 c10 1k
  R2: resistor c15 c20 1k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, V+, 1+, 1-, 2+, V-, 2-]
wires:
  - AD.V+ -- +t6 red
  - AD.GND -- -t4 black
  - +t5 -- a5 red
  - a10 -- -t10 black
  - AD.1+ -- +t7 yellow
  - AD.1- -- -t8 black
  - AD.V- -- b15 blue
  - a20 -- -t20 black
  - AD.2+ -- a15 white
  - AD.2- -- -t17 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/breadboard/01-supplies.svg)

- −5 V は**赤いレールに出さない**。レールの色 (+) と中身 (−) が食い違い、
  挿し間違えの元になる。V− のワイヤを 15 列に直に挿す
- CH1 (1+) は +5 V のレールに挿す。5 列には +5 V の線が来ているので、同じ列に
  2 本挿すより見分けやすい。CH2 (2+) は −5 V が 15 列にしか無いので、V− の線の隣に挿す
- 1− と 2− (オシロの入力の − 側) は GND につなぐ。つながないと値が浮く

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、V− = −5 V。両方を Enable にしてから **Master Enable** を入れる |
| Voltmeter | CH1・CH2 とも DC |

電源を切るときは Master Enable を先に切る。配線を替えるのは切ってから。

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 | +5.00 V 前後 | V+ の出力。負荷をつないでも下がらない |
| CH2 | −5.00 V 前後 | V− は負の電圧。符号を確かめる |
| 負荷 1 kΩ の電流 | 5 mA (1 系統 25 mW) | USB だけで給電するときの Supplies に回せる電力 (2 系統あわせて約 2 W の目安、0-2) のごく一部。外部の 5 V 電源を付ければ 1 系統 800 mA・2.4 W まで |

負荷の抵抗を変えたときに 1 系統が出す電力 (5 V × 5 V ÷ R) を描くと、1 kΩ では
25 mW、100 Ω でも 250 mW (電流 50 mA)。2 系統とも 100 Ω にして 500 mW で、
USB 給電の目安の約 2 W の 1/4。上限に届くのは、USB 給電で 2 系統に 1 W ずつ回すとして 25 Ω (= 5 V × 5 V ÷ 1 W) より
重い負荷のときで、この題の範囲では上限を気にしなくてよい。

```graph
title: 図3 1 系統の電力 — 1 kΩ で 25 mW、100 Ω で 250 mW
x: 負荷の抵抗 Ω log 50..5k
y: 電力 mW 0..500
lines:
  5 V を出す系統 mW: 5*5/x*1000
notes:
  - mark 100
  - mark 1k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/graph/01-supplies.svg)

電力の上限の話は 0-2 で扱う。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Supplies・Voltmeter の節)。Supplies の電圧範囲 (0.5〜5 V と −0.5〜−5 V)・電力の数字は
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
と
[Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
(Power Supplies の節)。
