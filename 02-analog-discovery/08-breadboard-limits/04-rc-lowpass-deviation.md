---
book: analog-discovery
chapter: 8
id: 8-4
title: RC ローパスの理論と実測のずれ (1 MHz と 10 MHz)
tier: 50
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 8-4 RC ローパスの理論と実測のずれ (1 MHz と 10 MHz)

8-1〜8-3 で確かめた 2 つの寄生 (列間容量・ジャンパのインダクタンス) を、
実際の RC ローパスに当てはめて、**理論値と実測値がどれだけずれるか**を見る。
R = 10 kΩ・C = 10 pF (理想の折れ点 1.59 MHz) という高いインピーダンスの回路を
選ぶと、8-2 の列間容量 (数 pF) が C 自身と同じ桁になり、ずれが目立つ。さらに、出力を読む
**AD3 の CH2 入力 (1 MΩ ∥ 24 pF)** が C1 と並列に乗る。これはブレッドボードの寄生ではなく計器の
ほうの容量だが、この回路では C1 の 2 倍以上あるので、先に数に入れておく。

## 回路図

```circuit
title: 図1 RC ローパスと並列に乗る寄生容量
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  R1: resistor c3 c6 10k
  C1: capacitor c9 c12 10p
  Cstray: capacitor f9 f12 2.5p l=$\mathrm{C_{stray}}$
  G1: ground c14
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.1- -| c14
  - c6 -- c9
  - c6 -- f9
  - AD.2+ -| c9
  - AD.2- -| c14
  - c12 -- c14
  - f12 -- c14
  - AD.GND -| c14
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/circuit/04-rc-lowpass-deviation.svg)

- C<sub>stray</sub> は 8-2 で測った**列間の寄生容量**。C1 (10 pF) と並列に乗るので、
  ブレッドボードの側で効く容量は 10 + 2.5 = 12.5 pF — 入力容量を数える前でも**理論値より 25% 大きい**
- 1+ が入力 (W1)、2+ が出力 (R と C の中点)。1−・2− は GND
- **図に描いていないもう 1 つの容量が、2+ の入力容量 24 pF** (AD3 の仕様)。C1 と
  C<sub>stray</sub> と並列に乗るので、効く容量は 10 + 24 + 2.5 = 36.5 pF になる

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 10k
  C1: capacitor/ceramic c15 c20 10p
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow [h-10]
  - AD.GND -- -t1 black
  - AD.1+ -- b5 white [h10]
  - e10 -- e15 blue
  - AD.1- -- -t11 black
  - AD.2+ -- a15 gray
  - AD.2- -- -t18 black
  - a20 -- -t20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/breadboard/04-rc-lowpass-deviation.svg)

- R1 (10 列) と C1 (15 列) の間を渡す配線が**そのまま 8-2 の「隣の列」**にもなる。
  この図に寄生容量は描かれていない — **描かなくても勝手に乗る**のがブレッドボードの
  限界そのもの
- 1+ は R1 の手前 (5 列)、2+ は R1 と C1 の中点 (15 列)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Network | 掃引 100 kHz〜10 MHz、点数 101、振幅 1 V、Reference = CH1、DUT = CH2 |
| 表示 | S21 の Log Mag と位相 |

10 MHz は AD3 の 2×15 ヘッダ直の帯域 (9 MHz @ −3 dB、5-8) を超えるので、この題は
**BNC アダプタを付けて**測る (Scope 30+ MHz、Wavegen 12 MHz @ −3 dB)。CH1 を基準にした比を
読むので、2 つのチャンネルが同じ帯域を持つ限り、帯域の影響は小さい (目安)。

```scope
title: 図3 1 MHz で CH2 (出力) は 0.40 倍・約 66° 遅れ (理論は 0.85 倍・32°)
time: 200ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 1MHz 1V, range: 500mV/div}
ch2: {wave: sine 1MHz 0.4V phase -66.4deg, range: 500mV/div}
cursors: [250ns, 434ns]
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/scope/04-rc-lowpass-deviation.svg)

図3 は 1 MHz の 1 点を、実測相当 (36.5 pF) の計算値でオシロの時間波形にした画面 (BNC アダプタを付けて測る)。
CH2 の Vpp は 0.80 V (入力 2.00 V の 0.40 倍 = −7.97 dB)、カーソルの間 184 ns は 1 周期 1 µs の 66.4° ぶんの遅れ。
10 pF だけの理論なら CH2 は 0.85 倍 (Vpp 1.69 V)・32.1° 遅れで、入力容量と列間容量が乗ると CH2 が目に見えて小さく遅れる。

## 見るべき値

計算値。理想 (C = 10 pF のみ) の折れ点 f<sub>c</sub> = 1/(2πRC) = **1.59 MHz**。
AD3 の入力容量 24 pF を足す (34 pF) と **468 kHz**、さらに C<sub>stray</sub> を足した
実測相当 (36.5 pF) の折れ点は **436 kHz**。

| 周波数 | 理論値 (10 pF のみ) | 入力容量込み (34 pF) | 実測相当 (36.5 pF) |
| --- | --- | --- | --- |
| 1 MHz | −1.45 dB、−32.1° | −7.45 dB、−64.9° | −7.97 dB、−66.4° |
| 10 MHz | −16.07 dB、−81.0° | −26.60 dB、−87.3° | −27.22 dB、−87.5° |

C<sub>stray</sub> だけの効き (34 pF と 36.5 pF の差) は 1 MHz で約 0.5 dB、10 MHz で約 0.6 dB。

```graph
title: 図4 折れ点は 1.59 MHz から 436 kHz へ (入力 24 pF が主因)
x: 周波数 Hz log 100k..10M
y:
  - 利得 dB -30..0
  - 位相 deg -90..0
lines:
  理論 10 pF 利得 dB: -10*log10(1+(2*pi*x*10k*10p)^2)
  入力込み 34 pF 利得 dB: -10*log10(1+(2*pi*x*10k*34p)^2)
  実測相当 36.5 pF 利得 dB: -10*log10(1+(2*pi*x*10k*36.5p)^2)
  理論 10 pF 位相 deg: -deg(atan(2*pi*x*10k*10p))
  実測相当 36.5 pF 位相 deg: -deg(atan(2*pi*x*10k*36.5p))
notes:
  - mark 1M
  - mark 10M
  - level -3dB
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/graph/04-rc-lowpass-deviation.svg)

**ずれの大半は計器の入力容量 (24 pF) で、ブレッドボードの寄生 (2.5 pF) はその上に乗る小さい分。**
それでも 8-2 のやり方 (挿す・抜くの差) なら 2.5 pF だけを取り出せる。

**ジャンパのインダクタンス (8-3) はここではほぼ効かない。** R = 10 kΩ という
高いインピーダンスの前では、数十 nH の直列リアクタンス (10 MHz でも数 Ω) は
無視できるほど小さい。**寄生が効くかどうかは、回路自身のインピーダンスとの
比で決まる** — 高インピーダンス回路は寄生容量に弱く、低インピーダンス回路
(9-1 のような増幅段など) は寄生インダクタンスに弱い。

## 出典

自作。AD3 の入力容量 (1 MΩ ∥ 24 pF) は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
