---
book: analog-discovery
chapter: 5
id: 5-4
title: 位相の読み方と −3 dB 点
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-4 位相の読み方と −3 dB 点

Network の Bode 線図はふつう利得と位相を重ねて表示する。**1 次のフィルタでは
利得が −3 dB 落ちた点で位相がちょうど 45° ずれる**という決まった関係がある。
カーソルを −3 dB 点に置いて、そこの位相を読む練習をする。

## 回路図

5-1 と同じ RC ローパスだが、値を変えて別の f<sub>c</sub> にする。

```circuit
title: 図1 RC ローパス (R1 2.2 kΩ、C1 47 nF)
parts:
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  R1: resistor 5,1 7,1 2k2
  C1: capacitor 7,1 7,3 47n
  M2: voltmeter 9,1 9,3 l=$\mathrm{CH2}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1 -- 5,1
  - 1,3 -- 3,3 -- 7,3 -- 9,3
  - 7,1 -- 9,1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/04-phase-and-3db.svg)

f<sub>c</sub> = 1 / (2π × 2.2 kΩ × 47 nF) ≈ **1.539 kHz**。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 2k2
  C1: capacitor d10 d14 47n
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/04-phase-and-3db.svg)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V |
| Network | Start 100 Hz、Stop 20 kHz、Log、Steps 101、表示: 利得 (dB) と位相 (deg) を重ねる。カーソルを 3 本 (0.1×f<sub>c</sub>、f<sub>c</sub>、10×f<sub>c</sub>) 立てる |

```scope
title: 図3 遮断周波数 (1539 Hz) で CH2 は CH1 の 0.71 倍、約 81 µs (45°) 遅れる
time: 100us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1.5392kHz 1V, range: 500mV/div}
ch2: {wave: ch1 | rc 103.4us, range: 500mV/div}
cursors: [162us, 243us]
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/04-phase-and-3db.svg)

図3 は −3 dB 点の 1 点をオシロの時間波形で見た画面 (計算値)。CH2 の Vpp は 1.41 V (入力 2.00 V の 0.71 倍 = −3.01 dB)。
カーソルの間 81 µs は 1 周期 650 µs の 1/8 = 45° の遅れで、利得の −3 dB と位相の −45° が同じ周波数で起きている。

## 見るべき値

計算値。位相 = −arctan(f / f<sub>c</sub>)。

| カーソルの位置 | 周波数 | 利得 | 位相 |
| --- | --- | --- | --- |
| 0.1 × f<sub>c</sub> | 153.9 Hz | −0.04 dB (ほぼ 0) | −5.7° |
| **1 × f<sub>c</sub> (−3 dB 点)** | **1539.2 Hz** | **−3.01 dB** | **−45.0°** |
| 10 × f<sub>c</sub> | 15.39 kHz | −20.04 dB | −84.3° |

```graph
title: 図4 −3 dB の線と −45° の線は同じ 1539 Hz で曲線を横切る
x: 周波数 Hz log 100..20k
y:
  - 利得 dB
  - 位相 deg
lines:
  利得 dB: 20*log10(1/sqrt(1+(x/1539.2)^2))
  位相 deg: -deg(atan(x/1539.2))
notes:
  - level -3dB
  - level -45deg
  - mark 153.9
  - mark 1539.2
  - mark 15.39k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/04-phase-and-3db.svg)

分かること:

- **利得のカーソルを −3 dB の線に合わせると、その周波数が f<sub>c</sub>。** 位相の
  カーソルも同じ周波数に立てれば、そこはほぼ必ず **45°** 付近を指す —
  これが 1 次フィルタで −3 dB 点を見つける実用的な手順になる
- **10 倍離れるごとに、位相は 45° から ±39〜40° ずつ動いて 0°・90° に近づく**
  (0.1×f<sub>c</sub> で −5.7°、10×f<sub>c</sub> で −84.3°。ちょうど 0°・−90° には
  漸近するだけで届かない)
- 5-1 (f<sub>c</sub> ≈ 1.59 kHz) と f<sub>c</sub> の値が違うのは意図的。**部品の値を
  変えても、−3 dB 点と 45° 点が一致する関係そのものは変わらない**ことを
  確かめるため

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。
