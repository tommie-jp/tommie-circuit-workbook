---
book: analog-discovery
chapter: 2
id: 2-9
title: 10:1 プローブの補正と入力容量の影響
tier: 100
source: 自作
board: BB
---

# 2-9 10:1 プローブの補正と入力容量の影響

オシロの入力は 1 MΩ ∥ 24 pF（0-2・2-4 で使ってきた「1 MΩ」の内訳）。**24 pF の
入力容量**は、信号源のインピーダンスが高いほど波形をなまらせる。10:1 プローブは
「9 MΩ の抵抗＋補正用の可変コンデンサ」を直列に足すことで、入力容量を約 1/10 に
見せかけつつ、電圧を 1/10 にして読む道具。ここでは breadboard 上に簡単な
10:1 分圧網を組んで、補正の合わせ方と、容量の効果そのものを確かめる。

## 回路図

```circuit
title: 図1 10 kΩ の信号源に直結した場合とプローブ経由の場合
parts:
  W1: square a1 c1 1.65
  Rs: resistor a3 a5 10k
  M1: voltmeter a7 c7 l=$\mathrm{CH1}$
  Rp: resistor a9 a11 9.1M
  Cp: capacitor b9 b11 2.6p l=$C_\mathrm{trim}$
  M2: voltmeter a13 c13 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3
  - a5 -- a7
  - a5 -- a9
  - a9 -- b9
  - a11 -- b11
  - a11 -- a13
  - c1 -- c7 -- c13
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/09-probe-compensation.svg)

- W1（1 kHz、0〜3.3 V の方形波）→ Rs（10 kΩ、信号源の内部抵抗のつもり）→ 節点 TP。
- CH1 は TP に**ワイヤで直結**（プローブなし）。AD の入力そのもの（1 MΩ ∥ 24 pF）が
  TP にぶら下がる。
- CH2 は TP から **Rp（9.1 MΩ）と Cp（補正用の可変コンデンサ）の並列**を通して
  つなぐ。Cp は図では固定コンデンサの記号で描くが、実体はトリマ（可変）で、
  ドライバーで容量を変えられる。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで信号源と 2 つの入力経路を組む
board: half
parts:
  Rs: resistor c5 c10 10k
  Rp: resistor a10 a14 9.1M
  Cp: capacitor e10 e14 2.6p
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [W1, 1+, 2+, 1-, GND, 2-]
wires:
  - AD.W1 -- b5 yellow
  - AD.GND -- -t18 black
  - AD.1+ -- b10 orange
  - AD.1- -- -t16 black
  - AD.2+ -- b14 blue
  - AD.2- -- -t20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/09-probe-compensation.svg)

Rs は 5〜10 列の中点が信号源 TP（10 列）。CH1（`1+`）は TP と同じ 10 列（b10）に
直結。Rp（`a` 行）と Cp（`e` 行）は 10〜14 列で上下に離して並べて並列にし、
14 列側を CH2（`2+`）へ。GND は `1-`・`2-` とともに上の − レール（16〜20 列）にまとめる。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 方形波、1 kHz、振幅 1.65 V、オフセット 1.65 V（0〜3.3 V） |
| Scope (CH1) | DC、Range 0〜3.3 V (1 V/div)、Time/div は角の形が見える 20 μs/div 程度 |
| Scope (CH2) | DC、Range 0〜0.4 V (200 mV/div、1/10 に減衰されるため) |

C<sub>trim</sub> の 3 つの設定で CH2 に出る立ち上がりを重ねる。角の形は
プローブの時定数 (R<sub>p</sub> ∥ R<sub>in</sub>) × (C<sub>trim</sub> + C<sub>in</sub>) ≈ 23〜31 μs で決まる。
Time/div を 20 μs/div 程度にするのはこのためで、1 μs/div では角の後の平らな所しか映らない。

```scope
title: 図3 合った 2.6 pF (CH2) は平ら、1 pF (CH3) は丸く、10 pF (CH4) は跳ねる
time: 20us/div
trigger: ch1 rising 1.65V at -4div
ch1: {wave: square 1kHz 1.65V offset 1.65V, range: 1V/div, position: -3div}
ch2: {wave: = 0.099 * ch1, range: 200mV/div, position: -3div}
ch3: {wave: = 3.3V * step(t) * (0.099 - 0.059 * exp(-t / 22.5us)), range: 200mV/div, position: -3div}
ch4: {wave: = 3.3V * step(t) * (0.099 + 0.195 * exp(-t / 30.6us)), range: 200mV/div, position: -3div}
cursors: [1us, 100us]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/09-probe-compensation.svg)

ここで 1 pF は立ち上がり直後が 3.3 V × 1/(1 + 24) ≈ 0.13 V、10 pF は
3.3 V × 10/(10 + 24) ≈ 0.97 V で、どちらも数十 μs かけて 3.3 V ÷ 10.1 ≈ 0.33 V に落ち着く。

## 見るべき値

補正が合う条件は R<sub>p</sub> × C<sub>trim</sub> = R<sub>in</sub> × C<sub>in</sub>
（R<sub>in</sub> = 1 MΩ、C<sub>in</sub> = 24 pF）。

C<sub>trim</sub> = (1 MΩ × 24 pF) / 9.1 MΩ ≈ **2.6 pF（計算値）**

| C<sub>trim</sub> の設定 | 見え方 | 分かること |
| --- | --- | --- |
| 2.6 pF（合った状態） | CH2 は CH1 と同じ形の方形波（振幅は 1/10）。角も同じ速さで立つ | 抵抗の分圧比（1/10.1 ≈ 1/10）と容量の分圧比が一致し、周波数によらず一定の減衰になる |
| 1 pF（小さすぎ＝補正不足） | 角が丸くなる（低域通過フィルタがかかったように見える） | 高域で容量分圧が効きすぎず、抵抗分圧（遅い）が支配的になる |
| 10 pF（大きすぎ＝補正過多） | 立ち上がり直後に一瞬跳ね上がってから落ち着く（オーバーシュート） | 高域で容量分圧が勝ちすぎる |

補正が合うと、プローブ側から見た入力容量は
C<sub>trim</sub> と C<sub>in</sub> の直列 ≈ (2.6 pF × 24 pF) / (2.6 pF + 24 pF)
**≈ 2.3 pF** まで下がる（直結の 24 pF の約 1/10）。

| 経路 | TP に見える容量 | 時定数 τ = R<sub>s</sub> × C（計算値） | 立ち上がり時間 t<sub>r</sub> ≈ 2.2τ |
| --- | --- | --- | --- |
| CH1（直結） | 24 pF | 10 kΩ × 24 pF = 240 ns | 約 528 ns |
| CH2（10:1 プローブ、補正済み） | 約 2.3 pF | 10 kΩ × 2.3 pF = 23 ns | 約 52 ns |

同じ 10 kΩ の信号源でも、**プローブを使うほうが TP 自体への負荷が軽く**、
立ち上がりが約 10 倍速く見える。プローブは「電圧を小さくする道具」であると同時に
「入力容量による負荷を減らす道具」でもあることが、この時定数の差で分かる。

## 出典

自作。入力インピーダンスの値（1 MΩ ∥ 24 pF）は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
（Analog Input の Input Impedance の項）による。
