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
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Rref: resistor c3 c6 680
  Ldut: inductor c9 c12 10m l=$\mathrm{L_{DUT}}$
  G1: ground c14
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.1- -| c6
  - c6 -- c9
  - AD.2+ -| c9
  - AD.2- -| c12
  - c12 -- c14
  - AD.GND -| c14
```

- Rref は 680 Ω。1 kHz より高い**10 kHz** で測るので、XL (628 Ω) に近い値を選んだ
- L<sub>DUT</sub> は 10 mH のリード付きインダクタ (小信号用)。巻線抵抗は数 Ω〜数十 Ω
  あり、データシートに無いことが多いので実測する

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rref: resistor c5 c10 680
  Ldut: inductor/axial c15 c20 10mH
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

配線の考え方は 6-1・6-2 と同じ。10 = 15 列がコイルと Rref の中点。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**10 kHz**、Amplitude 2 V |
| Scope | CH1 = Rref の両端、CH2 = L<sub>DUT</sub> の両端。Range は両方 1 V/div |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase |

周波数を 1 kHz ではなく 10 kHz にするのは、XL = 2πfL をある程度大きくして
Rref と桁を合わせるため (1 kHz だと XL は 63 Ω しかない)。

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
