---
book: analog-discovery
chapter: 5
id: 5-1
title: RC ローパスのボード線図
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-1 RC ローパスのボード線図

**Network** は W1 の周波数を自動で掃引し、CH1 (基準) に対する CH2 (応答) の
利得と位相を測ってボード線図を描く計器。3-2 では手動で Sweep を追ったが、
ここからは Network に任せる。RC ローパス 1 個の教科書どおりの形を確かめる。

## 回路図

```circuit
title: 図1 RC ローパス
parts:
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  R1: resistor 5,1 7,1 1k
  C1: capacitor 7,1 7,3 100n
  M2: voltmeter 9,1 9,3 l=$\mathrm{CH2}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1 -- 5,1
  - 1,3 -- 3,3 -- 7,3 -- 9,3
  - 7,1 -- 9,1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/01-rc-lowpass-bode.svg)

R1 = 1 kΩ、C1 = 100 nF → **f<sub>c</sub> = 1 / (2πRC) ≈ 1.59 kHz**。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 1k
  C1: capacitor d10 d14 100n
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/01-rc-lowpass-bode.svg)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V (Network が自動で掃引する) |
| Network | Start 100 Hz、Stop 100 kHz、**Log**、Steps 101、Reference: Channel 1、表示: Bode (利得 dB・位相 deg) |

```scope
title: 図3 10 kHz では CH2 (出力) が CH1 の 0.16 倍に減り、約 81° 遅れる
time: 20us/div
trigger: ch1 rising 0V
ch1: {wave: sine 10kHz 1V, range: 500mV/div}
ch2: {wave: ch1 | rc 100us, range: 500mV/div}
cursors: [25us, 47.5us]
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/01-rc-lowpass-bode.svg)

図3 は Network が掃引の途中で測っている 10 kHz の 1 点を、オシロの時間波形で見た画面。
CH2 の Vpp は 0.31 V (入力 2.00 V の 0.157 倍 = −16.07 dB)、カーソルの間 22.5 µs は
1 周期 100 µs の 81°ぶんの遅れ (−81.0°)。Network の表はこの比と遅れを周波数ごとに自動で出している。

## 見るべき値

計算値。利得 (dB) = 20 log₁₀ (1 / √(1 + (f/f<sub>c</sub>)²))、
位相 = −arctan(f / f<sub>c</sub>)。

| 周波数 | 利得 | 位相 |
| --- | --- | --- |
| 100 Hz | −0.02 dB (ほぼ 0 dB) | −3.6° |
| 1.59 kHz (f<sub>c</sub>) | −3.01 dB | −45.0° |
| 10 kHz | −16.07 dB | −81.0° |
| 100 kHz | −35.96 dB | −89.1° |

```graph
title: 図4 RC ローパスのボード線図 — −3 dB と −45° が同じ 1.59 kHz に来る
x: 周波数 Hz log 100..100k
y:
  - 利得 dB
  - 位相 deg
lines:
  利得 dB: 20*log10(1/sqrt(1+(x/1.59k)^2))
  位相 deg: -deg(atan(x/1.59k))
notes:
  - level -3dB
  - level -45deg
  - mark 100
  - mark 1.59k
  - mark 10k
  - mark 100k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/01-rc-lowpass-bode.svg)

分かること:

- **f<sub>c</sub> を境に −20 dB/decade で下がる。** 10 kHz (f<sub>c</sub> の約 6.3 倍) で
  −16 dB、100 kHz (約 63 倍) で −36 dB と、10 倍ごとに約 20 dB ずつ下がっている
  ことをカーソルで確かめる
- **位相は f<sub>c</sub> でちょうど −45°**、低い周波数では 0° に、高い周波数では
  −90° に近づく。−3 dB 点と −45° 点が同じ周波数に来るのが 1 次ローパスの特徴
  (5-4 で詳しく読む)
- 100 kHz でも Amplitude 1 V の W1 は問題なく出せる (Wavegen の帯域は BNC アダプタ無しで 9 MHz、
  有りで 12 MHz、3-15 参照)。ブレッドボードの寄生 (8-4) の影響はこの周波数ではまだ
  小さい

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。
