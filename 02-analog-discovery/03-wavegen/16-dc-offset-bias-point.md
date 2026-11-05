---
book: analog-discovery
chapter: 3
id: 3-16
title: DC オフセットでバイアス点を振る (トランジスタの動作点)
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-16 DC オフセットでバイアス点を振る (トランジスタの動作点)

エミッタ接地の増幅回路は、ベースに掛ける直流 (バイアス) で**動作点**が決まる。ふつうは抵抗の分圧でバイアスを作るが、
ここではバイアスの抵抗を置かず、Wavegen の **Offset** をそのままバイアスにし、**Amplitude** を小さな入力信号にする。
Offset のつまみ 1 つで動作点を動かし、出力の正弦波が上で切れる (遮断)・きれいに増幅される (活性)・下で切れる (飽和) の
3 つの様子を Scope で確かめる。最後に Offset を 0〜3 V と振った直流の特性 (伝達特性) と突き合わせる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 の Offset がそのままベースのバイアスになる
parts:
  V1: sine 1,4 1,6 l=$\mathrm{W1}$
  M1: voltmeter 3,4 3,6 l=$\mathrm{CH1}$
  RB: resistor 3,4 5,4 1k
  Q1: npn 6,4 2SC1815
  VCC: vcc 6,1 5V
  RC: resistor 6,1 6,3 2.2k
  RE: resistor 6,5 6,7 1k
  M2: voltmeter 8,3 8,7 l=$\mathrm{CH2}$
  G1: ground 1,7
wires:
  - 1,4 -- 3,4
  - 5,4 -- Q1.B
  - 6,3 -- Q1.C
  - Q1.E -- 6,5
  - 6,3 -- 8,3
  - 1,6 -- 1,7 -- 3,7 -- 6,7 -- 8,7
  - 3,6 -- 3,7
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/circuit/16-dc-offset-bias-point.svg)

- V1 (W1) は Offset (直流) と Amplitude 0.3 V・1 kHz の正弦の和。RB (1 kΩ) は W1 から流れ込むベース電流を抑える守りで、電圧はほとんど落ちない
- RE (1 kΩ) がエミッタの抵抗。コレクタの電流は I<sub>C</sub> ≈ (V<sub>offset</sub> − 0.63 V) / RE で、h<sub>FE</sub> にほとんどよらない
- RC (2.2 kΩ) をつなぐ +5 V は AD3 の Supplies の V+。利得は −RC / RE ≈ −2.2 (反転)
- CH1 は W1、CH2 はコレクタ

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 2SC1815 と 3 本の抵抗を上のブロックに組む
board: half
parts:
  RB: resistor c5 c10 1k
  Q1: transistor e12 e11 e10 2SC1815 cap=below
  RC: resistor a7 a11 2.2k cap=above
  RE: resistor d12 d16 1k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, 1-, 2-, W1, 1+, 2+, V+]
wires:
  - AD.GND -- -t2 black
  - AD.1- -- -t3 black
  - AD.2- -- -t4 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange
  - AD.2+ -- b11 blue
  - b7 -- +t7 red
  - b16 -- -t16 black
  - AD.V+ -- +t20 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/breadboard/16-dc-offset-bias-point.svg)

- Q1 (2SC1815) は平らな面を奥 (a 行側) に向けて e 行の 10・11・12 列に挿す。左から B・C・E (手前から見た E・C・B の裏返し)
- RB は 5 列 (W1) から 10 列 (B) へ。RC は 11 列 (C) から 7 列へ、7 列を + レールへ。RE は 12 列 (E) から 16 列へ、16 列を − レールへ
- W1 (黄) と 1+ (橙) は 5 列、2+ (青) はコレクタの 11 列。V+ (赤) は + レールの 20 列

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | NPN トランジスタ | 2SC1815 (GR か Y) |
| RC | 抵抗 (コレクタ) | 2.2 kΩ |
| RE | 抵抗 (エミッタ) | 1 kΩ |
| RB | 抵抗 (ベースの直列) | 1 kΩ |
| — | 電源 | 5 V (AD3 の Supplies の V+。電流は最大 1.5 mA) |
| — | 計器 | Analog Discovery 3 (W1、Scope の CH1・CH2) |

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ 5 V を on |
| Wavegen | W1: Sine 1 kHz、Amplitude 0.3 V、**Offset 0.8 V → 1.4 V → 2.0 V** |
| Scope | CH1・CH2 とも DC 結合、Range 500 mV/div、位置 −4 div (0〜4 V が画面に入る)。Time 200 µs/div、トリガ CH1 立ち上がり (水準は Offset の値)。Measure に Maximum・Minimum・Average |

Offset が 1.25 V を超えると W1 の出力は ±1.25 V のレンジを外れ、±5 V のレンジ (分解能 665 µV) に切り替わる (仕様)。
0.3 V の振幅には十分細かい。W1 の電流はベース電流と RB の分だけで、数 µA。

Offset 1.4 V では、CH2 は CH1 と逆向きに 2.1 倍で振れる (図3)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 Offset 1.4 V — コレクタ (CH2) は 3.32 V を中心に 1.26 Vpp で逆向きに振れる
time: 200us/div
trigger: ch1 rising 1.4V
ch1: {wave: sine 1kHz 0.3V offset 1.4V, range: 500mV/div, position: -4div}
ch2: {wave: = 3.321V - 2.105 * (ch1 - 1.4V), range: 500mV/div, position: -4div}
measure: [vmax, vmin, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/16-dc-offset-bias-point-1.svg)

Offset 2.0 V では、入力の山 (2.3 V) で Q1 が飽和し、CH2 の谷が 1.67 V で平らになる (図4)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 Offset 2.0 V — 入力の山で飽和し、CH2 の谷が 1.67 V で切れる
time: 200us/div
trigger: ch1 rising 2V
ch1: {wave: sine 1kHz 0.3V offset 2V, range: 500mV/div, position: -4div}
ch2: {wave: "= max(1.667V, 2.046V - 2.137 * (ch1 - 2V))", range: 500mV/div, position: -4div}
measure: [vmax, vmin, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/16-dc-offset-bias-point-2.svg)

## 見るべき値

LTspice の値 (2SC1815 の近似のモデル。h<sub>FE</sub> 250 と仮定)。CH2 の Average は動作点のコレクタの電圧にほぼ等しい。

| Offset | 動作点の V<sub>C</sub> (直流) | CH2 の Max / Min | CH2 の Vpp | 様子 |
| --- | --- | --- | --- | --- |
| 0.8 V | 4.55 V (I<sub>C</sub> 0.2 mA) | 4.99 V / 3.95 V | 1.04 V | 入力の谷 (0.5 V) で Q1 が切れ、CH2 の山が 5 V で平らになる (遮断) |
| 1.4 V | 3.32 V (I<sub>C</sub> 0.76 mA) | 3.95 V / 2.69 V | 1.26 V | 上下とも切れずに 2.1 倍 (活性) |
| 2.0 V | 2.05 V (I<sub>C</sub> 1.34 mA) | 2.68 V / 1.66 V | 1.02 V | 入力の山 (2.3 V) で飽和し、CH2 の谷が平らになる (飽和) |

Offset を 0〜3 V と 0.1 V ずつ変え、Amplitude を 0 にして CH2 の Average を読むと、直流の伝達特性が描ける (図5)。
Wavegen の DC の機能 (3-1) で同じことをしてもよい。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図5 W1 の直流とコレクタの電圧 — 傾きの所 (0.6〜2.1 V) だけが増幅に使える
x: W1 の直流 V 0..3
y: コレクタの電圧 V 0..5.5
lines:
  コレクタ V:
    - 0.0 5.000
    - 0.1 5.000
    - 0.2 5.000
    - 0.3 5.000
    - 0.4 5.000
    - 0.5 4.990
    - 0.6 4.903
    - 0.7 4.740
    - 0.8 4.553
    - 0.9 4.356
    - 1.0 4.153
    - 1.1 3.948
    - 1.2 3.740
    - 1.3 3.531
    - 1.4 3.321
    - 1.5 3.110
    - 1.6 2.898
    - 1.7 2.686
    - 1.8 2.473
    - 1.9 2.260
    - 2.0 2.046
    - 2.1 1.832
    - 2.2 1.669
    - 2.3 1.674
    - 2.4 1.701
    - 2.5 1.733
    - 2.6 1.768
    - 2.7 1.804
    - 2.8 1.840
    - 2.9 1.877
    - 3.0 1.915
notes:
  - mark 0.8
  - mark 1.4
  - mark 2.0
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/graph/16-dc-offset-bias-point.svg)

分かること:

- **傾きの真ん中 (1.4 V) に動作点を置くと、上下に同じだけ振れる余裕ができる**。0.6 V より下は遮断で V<sub>C</sub> = 5 V、
  約 2.1 V より上は飽和で V<sub>C</sub> がエミッタの電圧 (約 1.6 V) より下がらない
- 傾きは −2.1。RC / RE = 2.2 より少し小さいのは、エミッタの内部の抵抗 (約 26 mV / I<sub>C</sub> = 34 Ω) と RB / h<sub>FE</sub> が RE に足されるため
- 振幅を 0.3 V から 0.6 V に上げると、1.4 V の動作点でも両側が切れ始める。動作点と振幅の両方で「切れない範囲」が決まる
- 実際の増幅回路ではこの Offset の役を抵抗の分圧が受け持ち、信号は結合のコンデンサで足す。Wavegen 1 台で両方を作れるのは、
  バイアスを決める前に「どこに置くとよいか」を探る道具として便利

## LTspice での確かめ

`sim/16-dc-offset-bias-point.cir` (過渡解析、Offset 0.8・1.4・2.0 V と振幅 0・0.3 V) と `sim/16-dc-offset-bias-point-dc.cir` (直流の掃引) で回した。
2SC1815 は他の題と同じ近似のモデルで、実測ではない。表の数は LTspice の値そのもので、図3・図4 の CH2 はその値に合わせた折れ線の近似。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| Offset 1.4 V の動作点・振れ | 3.32 V、1.26 Vpp | 3.321 V、1.257 Vpp | 合う |
| Offset 0.8 V の山 (遮断) | 4.99 V | 4.990 V | 合う |
| Offset 2.0 V の谷 (飽和) | 1.66 V | 1.664 V | 合う |
| 飽和の始まり (V<sub>CE</sub> = 0.3 V) | 約 2.1 V | 2.13 V | 合う |
| V+ の電流の最大 | 1.5 mA | 1.52 mA | 合う (Supplies の 50 mA よりずっと小さい) |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen と Supplies の節)、出力のレンジは
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
参考: [バイアス (電子工学) (Wikipedia)](https://ja.wikipedia.org/wiki/バイアス_(電子工学))
