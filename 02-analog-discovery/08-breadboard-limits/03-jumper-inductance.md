---
book: analog-discovery
chapter: 8
id: 8-3
title: ジャンパ線のインダクタンス
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 8-3 ジャンパ線のインダクタンス

8-2 は板の**容量**、この題は板に挿す**ジャンパ線自体のインダクタンス**を測る。
長さ約 5 cm のジャンパ線は、その両端を GND へ短絡して 1 本の小さなコイルとして
扱うと、基準抵抗の仕組みでインダクタンスが測れる。

## 回路図

```circuit
title: 図1 基準抵抗とジャンパ線 (両端を GND へ短絡)
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Rref: resistor c3 c6 2.7
  Ljumper: inductor c9 c12 43n l=$\mathrm{L_{jumper}}$
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

- L<sub>jumper</sub> は**部品ではなく、ジャンパ線 (約 5 cm) の自己インダクタンスの
  模型**。実際にはただの銅線 1 本
- 経験式 L (nH) ≈ 0.2 l {ln(2l/d) − 0.75} (l, d は mm) で見積もると、
  5 cm・AWG22 (直径 0.64 mm) のジャンパは **約 43 nH**
- Rref (2.7 Ω) は 10 MHz での XL (約 2.7 Ω) に合わせた、E12 系列で最も近い値

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rref: resistor c5 c10 2.7
  Ljumper: inductor/axial c15 c20 43nH
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

図のインダクタ記号は**測る対象のジャンパ線そのもの**を指す (実物のインダクタは
使わない)。配線の考え方は 6-3 と同じ。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**10 MHz**、**Amplitude 30 mV** (振幅を絞らないと電流が過大になる) |
| Scope | CH1 = Rref の両端、CH2 = ジャンパの両端。Range は両方 20 mV/div |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase |

**電流の確認**: I = 30 mV / \|Rref + jXL\| ≈ 30 mV / 3.8 Ω ≈ 7.9 mA。
Wavegen の上限 (約 10 mA) の範囲内。

## 見るべき値

計算値。ジャンパ 5 cm、L ≈ 43 nH と仮定 (実測は個体差で数十% 変わりうる)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| XL = 2πfL (10 MHz) | 2.70 Ω | 経験式からの予想リアクタンス |
| CH1 (Rref の両端) | 21.2 mV | I ≈ 7.9 mA |
| CH2 (ジャンパの両端) | 21.2 mV、位相 +90° 付近 | \|Z\| ≈ 2.7 Ω → L ≈ 43 nH |
| ジャンパを 2 本 (10 cm 相当) に延ばしたとき | XL がおよそ 2 倍以上 (長さの対数分だけ余計に増える) | 長いジャンパほど高い周波数で無視できなくなる |

**数 Ω レベルの小さいインピーダンスは測定誤差が大きい。** Average を増やし、
Rref をジャンパの予想インピーダンスに近い値に選ぶのが精度を上げるコツ —
6-1〜6-3 と同じ「基準抵抗は DUT と桁を合わせる」という考え方がここでも効く。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。ジャンパ線のインダクタンスの経験式は電線のインダクタンスに
関する一般的な近似式による。
