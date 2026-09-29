---
book: analog-discovery
chapter: 5
id: 5-2
title: RC ハイパス
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-2 RC ハイパス

5-1 と同じ R・C を使い、出力を C ではなく **R の両端**から取ると、低い周波数を
落とすハイパスになる。同じ部品で反対の性質が出ることを、Network の Bode 線図
で確かめる。

## 回路図

```circuit
title: 図1 RC ハイパス
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  C1: capacitor a5 a7 100n
  R1: resistor a7 c7 1k
  M2: voltmeter a9 c9 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c7 -- c9
  - a7 -- a9
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/02-rc-highpass.svg)

C1 = 100 nF、R1 = 1 kΩ → f<sub>c</sub> は 5-1 と同じ **≈ 1.59 kHz**
(直列の RC で f<sub>c</sub> = 1/(2πRC) は R と C の順番によらない)。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  C1: capacitor c5 c10 100n
  R1: resistor d10 d14 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t3 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- -t8 black
  - AD.2+ -- a10 blue
  - AD.2- -- -t12 black
  - a14 -- -t14 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/02-rc-highpass.svg)

5-1 の R1 と C1 を入れ替えただけの配置。**5-1 のブレッドボードから部品を
入れ替えるだけで作れる。**

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V |
| Network | Start 100 Hz、Stop 100 kHz、Log、Steps 101、Reference: Channel 1 |

## 見るべき値

計算値。利得 (dB) = 20 log₁₀ ((f/f<sub>c</sub>) / √(1 + (f/f<sub>c</sub>)²))、
位相 = +arctan(f<sub>c</sub> / f)。

| 周波数 | 利得 | 位相 |
| --- | --- | --- |
| 100 Hz | −24.05 dB | +86.4° |
| 1.59 kHz (f<sub>c</sub>) | −3.01 dB | +45.0° |
| 10 kHz | −0.11 dB (ほぼ 0 dB) | +9.0° |
| 100 kHz | −0.001 dB (ほぼ 0 dB) | +0.9° |

図3 は 5-1 のローパスを同じ枠に重ねたもの。

```graph
title: 図3 ハイパスとローパスは 1.59 kHz で鏡写し — 利得は同じ −3 dB、位相は ±45°
x: 周波数 Hz log 100..100k
y:
  - 利得 dB
  - 位相 deg
lines:
  ハイパス 利得 dB: 20*log10((x/1.59k)/sqrt(1+(x/1.59k)^2))
  ローパス (5-1) 利得 dB: 20*log10(1/sqrt(1+(x/1.59k)^2))
  ハイパス 位相 deg: deg(atan(1.59k/x))
  ローパス (5-1) 位相 deg: -deg(atan(x/1.59k))
notes:
  - level -3dB
  - mark 100
  - mark 1.59k
  - mark 10k
  - mark 100k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/02-rc-highpass.svg)

分かること:

- **5-1 (ローパス) と 5-2 (ハイパス) は f<sub>c</sub> で鏡写しの形になる。**
  ローパスが高い周波数で落ちるのに対し、ハイパスは低い周波数で落ちる。
  f<sub>c</sub> ちょうどでは両方とも −3.01 dB、位相は符号が逆で大きさが同じ
  (±45°)
- **位相の符号がローパスと逆 (+側、進み)。** ハイパスは低域で入力より位相が
  進むのが特徴で、5-4 の「位相の読み方」で符号のルールを確認する
- 100 kHz でほぼ 0 dB (フルに通る) になっているのは、周波数が f<sub>c</sub> の
  約 63 倍まで上がり、C1 のインピーダンスが R1 に対して十分小さくなったため

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。
