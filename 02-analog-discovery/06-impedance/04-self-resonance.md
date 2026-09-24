---
book: analog-discovery
chapter: 6
id: 6-4
title: 自己共振 (SRF) — 100 µH のコイルが容量になる所
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-4 自己共振 (SRF) — 100 µH のコイルが容量になる所

コイルの巻線どうしは小さな**寄生容量 Cp**を持つ。周波数を上げていくと、ある点
(**自己共振周波数 SRF**) で L と Cp が共振し、それより上ではコイルなのに
**容量として振る舞う**。100 µH の小さなインダクタを 100 kHz〜10 MHz で掃引して、
SRF をまたぐ様子を見る。

## 回路図

```circuit
title: 図1 基準抵抗と 100 µH のコイル (掃引)
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Rref: resistor c3 c6 10k
  Ldut: inductor c9 c12 100u l=$\mathrm{L_{DUT}}$
  Cp: capacitor f9 f12 5p
  G1: ground c14
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.1- -| c6
  - c6 -- c9
  - c9 -- f9
  - AD.2+ -| c9
  - AD.2- -| c12
  - c12 -- f12
  - c12 -- c14
  - AD.GND -| c14
```

- L<sub>DUT</sub> と並列に描いた **Cp (5 pF)** は実装した部品ではなく、コイルの巻線間に
  できる寄生容量。実物には無いラベルだが、SRF を計算するために書いてある
- SRF = 1 / (2π√(L·Cp)) ≈ **7.12 MHz** (Cp は仮定値。実測の SRF から逆算もできる)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rref: resistor c5 c10 10k
  Ldut: inductor/axial c15 c20 100uH
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h5]
  - a10 -- a15 blue
  - AD.1- -- b10 green [h5]
  - AD.2+ -- b15 white [h5]
  - AD.2- -- b20 gray [h5]
  - a20 -- -t20 black
  - AD.GND -- -t3 black
```

配線の考え方は 6-1〜6-3 と同じ。寄生容量は板の上には現れない (コイルの中の話)
ので、実体配線図には出てこない。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**100 kHz〜10 MHz を掃引**、Amplitude 1 V |
| Scope | CH1 = Rref の両端、CH2 = L<sub>DUT</sub> の両端 |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase (周波数ごとに記録) |

Rref (10 kΩ) は**共振点付近に合わせてある**。低い周波数では L<sub>DUT</sub> の Z が
Rref よりずっと小さく、CH2 の読みが小さくなって誤差が増えるが、この題の目的は
正確な \|Z\| そのものより**位相が反転する周波数を見つけること**なので実害は小さい。

## 見るべき値

計算値 (L = 100 µH、Cp = 5 pF、巻線抵抗 Rs = 3 Ω と仮定)。

| 周波数 | \|Z\| | 位相 | 分かること |
| --- | --- | --- | --- |
| 100 kHz | 63 Ω | +87.3° | ほぼ理想の L (XL = ωL) |
| 3 MHz | 2.3 kΩ | +89.9° | 共振に近づき \|Z\| が急に増える |
| 7.0 MHz (SRF 直前) | 134 kΩ | +88.8° | まだインダクタ (位相は +) |
| 7.5 MHz (SRF 直後) | 43 kΩ | **−89.7°** | **コンデンサに変わっている** (位相が −) |

**位相の符号が + から − に変わる周波数が SRF。** ここで計算した SRF (7.12 MHz)
の前後で符号が反転しているのが分かる。実際の巻線抵抗や測定のばらつきで、
\|Z\| のピークの高さは計算値ほど鋭くは出ない。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。
