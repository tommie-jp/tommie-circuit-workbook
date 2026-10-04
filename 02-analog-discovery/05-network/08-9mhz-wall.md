---
book: analog-discovery
chapter: 5
id: 5-8
title: 9 MHz の壁 — スルーで NA 自身の特性を取る
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-8 9 MHz の壁 — スルーで NA 自身の特性を取る

5-5 では低い周波数でスルー (W1 を CH1・CH2 に直結) を測り、掃引設定の効きを見た。
ここでは同じスルーを**10 MHz まで**引っ張り上げる。DUT が無いのに利得が
0 dB から落ちていくとしたら、それは DUT ではなく **AD3 自身の入力帯域**が
見えているということ。この「壁」の高さを測るのがこの題。ここは **BNC アダプタ無し
(2×15 ヘッダにワイヤ) の場合**で、AD3 の仕様の帯域は 9 MHz @ −3 dB。BNC アダプタ有りなら
壁は 30 MHz+ @ −3 dB まで上がる。

## 回路図

```circuit
title: 図1 スルー (基準) の結線
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  M2: voltmeter a5 c5 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/08-9mhz-wall.svg)

5-5 と同じ結線 (W1 を CH1・CH2 の両方に直結) だが、掃引を
10 MHz まで伸ばす。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery 3 (W1 を 1+ と 2+ に直結)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange
  - AD.2+ -- c5 blue
  - AD.GND -- -t3 black
  - AD.1- -- -t8 black
  - AD.2- -- -t10 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/08-9mhz-wall.svg)

W1・1+・2+ を同じ 5 列に挿し、GND・1−・2− は上の − レールにまとめる。部品は無く、電源も使わない。
10 MHz までの信号なのでブレッドボードの範囲 (10 MHz まで) に収まる。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V |
| Network | Start 100 kHz、Stop 10 MHz、Log、Steps 101、Reference: Channel 1 |

付属のワイヤ (MTE ワイヤ) を使う。BNC アダプタに替えると壁の位置がもっと高くなる
(0-5 参照)。

壁の効きを時間波形で見たのが図3。掃引の途中の 1 点、f<sub>BW</sub> = 9 MHz の正弦波を、入力帯域を
1 次ローパス (τ = 1/(2π × 9 MHz) = 17.7 ns) と見立てて描いた。CH1 は基準で 2.00 Vpp、
壁を通った側は 1/√2 倍の 1.41 Vpp になり、山が 1/8 周期 (111 ns ÷ 8 ≈ 13.9 ns) 遅れる。
これが「−3 dB・−45°」の時間波形での姿である。図は 1 次ローパスと仮定した計算の画面で、実機の帯域の形とは少し違う。

```scope
title: 図3 9 MHz の 1 点 — 壁を通った線は 0.71 倍で 13.9 ns (45°) 遅れる
time: 20ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 9MHz 1V, range: 500mV/div}
ch2: {wave: ch1 | rc 17.68ns, range: 500mV/div}
cursors: [27.8ns, 41.7ns]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/08-9mhz-wall.svg)

## 見るべき値

計算値。AD のオシロ入力帯域を**1 次ローパス、f<sub>BW</sub> ≈ 9 MHz** の
フィルタと見立てると、利得 (dB) = −10 log₁₀(1 + (f/f<sub>BW</sub>)²)、
位相 = −arctan(f/f<sub>BW</sub>)。

| 周波数 | 利得 | 位相 |
| --- | --- | --- |
| 100 kHz | −0.00 dB (ほぼ 0) | −0.6° |
| 1 MHz | −0.05 dB | −6.3° |
| 5 MHz | −1.17 dB | −29.1° |
| **9 MHz (f<sub>BW</sub>)** | **−3.01 dB** | **−45.0°** |
| 10 MHz | −3.49 dB | −48.0° |

```graph
title: 図4 DUT なしでも 9 MHz で −3 dB・−45° — AD3 自身の帯域の壁
x: 周波数 Hz log 100k..10M
y:
  - 利得 dB -4..0
  - 位相 deg -60..0
lines:
  利得 dB: -10*log10(1+(x/9M)^2)
  位相 deg: -deg(atan(x/9M))
notes:
  - level -3dB
  - level -45deg
  - mark 1M
  - mark 5M
  - mark 9M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/08-9mhz-wall.svg)

分かること:

- **DUT が無いのに 9 MHz 付近から利得が落ちる。** これは測っている回路の問題では
  なく、**AD3 の入力 (付属ワイヤ使用時) の帯域そのもの**が見えている
- **この壁は 8 章のすべての測定に効く。** 8-1〜8-4 (ブレッドボードの寄生) や
  5-22・6-10・8-8 (25〜30 MHz まで) で BNC アダプタに替えるのは、この壁を
  高い側へ押し上げるため (Network の上限は、システムクロック 100 MHz の 1/4 の 25 MHz
  が既定)
- **DUT の f<sub>c</sub> が 9 MHz に近いと、測った値は DUT と AD の帯域が合成された
  ものになる。** 5-1〜5-4 のような 1〜10 kHz 台の DUT では無視できる差だが、
  5-22 のように DUT 自身が 25 MHz まで伸びる測定では、この壁を差し引いて
  考える必要がある

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。AD3 のオシロ入力帯域 (ヘッダで 9 MHz @ −3 dB、BNC アダプタで 30+ MHz)
と Network の周波数範囲は Digilent の
[AD3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
の値。表と図 3・4 は 1 次ローパスと仮定した計算で、実際の帯域の形とは少し違う
(仕様は 2.9 MHz で −0.5 dB、1 次モデルでは約 −0.43 dB)。
