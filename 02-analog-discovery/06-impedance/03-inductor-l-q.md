---
book: analog-discovery
chapter: 6
id: 6-3
title: コイルの L と Q
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-3 コイルの L と Q

コイルも実物は**巻線抵抗 Rs が直列に付いた L** (Z = Rs + jωL) になる。
6-1・6-2 と同じ基準抵抗の仕組みで、10 mH のリード付きインダクタを測り、
L と、コイルの良さを表す **Q = ωL / Rs** を求める。

## 回路図

```circuit
title: 図1 基準抵抗と 10 mH のコイル
parts:
  AD:
    type: device
    at: 1,1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Rref: resistor 3,3 6,3 680
  Ldut: inductor 9,3 12,3 10m l=$\mathrm{L_{DUT}}$
  G1: ground 14,3
wires:
  - AD.W1 -| 3,3
  - AD.1+ -| 3,3
  - AD.1- -| 6,3
  - 6,3 -- 9,3
  - AD.2+ -| 9,3
  - AD.2- -| 12,3
  - 12,3 -- 14,3
  - AD.GND -| 14,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/circuit/03-inductor-l-q.svg)

- Rref は 680 Ω。1 kHz より高い**10 kHz** で測るので、XL (628 Ω) に近い値を選んだ
- L<sub>DUT</sub> は 10 mH のリード付きインダクタ (小信号用)。巻線抵抗は数 Ω〜数十 Ω
  あり、データシートに無いことが多いので実測する

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rref: resistor c5 c10 680
  Ldut: inductor/axial d10 d14 10mH
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, 1+, 1-, 2+, 2-, GND]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- a10 green
  - AD.2+ -- b10 white [h10]
  - AD.2- -- b14 gray
  - a14 -- -t14 black
  - AD.GND -- -t17 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/breadboard/03-inductor-l-q.svg)

配線の考え方は 6-1・6-2 と同じ。10 列がコイルと Rref の中点。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**10 kHz**、Amplitude 2 V |
| Scope | CH1 = Rref の両端、CH2 = L<sub>DUT</sub> の両端。Range は両方 500 mV/div |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase |

周波数を 1 kHz ではなく 10 kHz にするのは、XL = 2πfL をある程度大きくして
Rref と桁を合わせるため (1 kHz だと XL は 63 Ω しかない)。

```scope
title: 図3 CH2 (L の電圧) が CH1 (電流) より 89.3° 進む — 90° に足りないぶんが巻線抵抗
time: 50us/div
trigger: ch1 rising 0V
ch1: {wave: sine 10kHz 1.46V, range: 500mV/div}
ch2: {wave: sine 10kHz 1.35V phase 89.3deg, range: 500mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/scope/03-inductor-l-q.svg)

## 見るべき値

計算値。巻線抵抗はここでは **Rs ≈ 8 Ω** と仮定した (実測して確かめる)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| XL = 2πfL | 628 Ω | 理想のリアクタンス |
| CH1 (Rref の両端) | 1.46 V | I ≈ 2.15 mA |
| CH2 (L<sub>DUT</sub> の両端) | 1.35 V、位相 89.3° | \|Z\| = 628 Ω |
| L = \|Z\|sin(89.3°) / ω | 約 10.0 mH | 表示値どおり |
| Q = XL / Rs | 約 78.5 | 巻線抵抗が小さいほど Q は大きい |

位相が 90° にどれだけ足りないかで Rs (巻線抵抗) が分かる。**自己共振の近くでは
この単純なモデルが崩れる** (100 µH の小さなコイルでの様子は 6-4)。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。
