---
book: analog-discovery
chapter: 9
id: 9-1
title: エミッタ接地の利得と帯域 (NA)
tier: 50
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 9-1 エミッタ接地の利得と帯域 (NA)

2SC1815 のエミッタ接地増幅回路を組み、**Network** (ネットワークアナライザ) で
利得と帯域を測る。エミッタ抵抗 Re をバイパスせずに残すと、利得が hFE に
ほぼ依存せず計算しやすい。

## 回路図

```circuit
title: 図1 エミッタ接地増幅回路
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
  Q1: npn f11 2SC1815
  R1: resistor c9 f9 39k
  R2: resistor f9 i9 12k
  Rc: resistor c14 f14 1k
  Re: resistor f17 i17 220
  Cin: capacitor f3 f9 1u
wires:
  - AD.V+ -| c9
  - AD.V+ -| c14
  - AD.W1 -| f3
  - AD.1+ -| f3
  - f9 |- Q1.B
  - f14 |- Q1.C
  - f17 -- f15 -- g15 -- g11 -- Q1.E
  - AD.2+ -| e20 -| f14
  - AD.1- |- i9
  - AD.2- |- i9
  - AD.GND |- i9
  - i9 -- i17
```

- R1・R2 (39 kΩ・12 kΩ) がベースの分圧、Re (220 Ω、バイパスなし) がエミッタの
  負帰還。Rc (1 kΩ) がコレクタ負荷
- 1+ は Cin の手前 (W1)、2+ はコレクタ (出力)。1−・2− は GND
- Cin (1 µF) は直流を切る結合コンデンサ

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Q1: transistor h9(B) h10(C) h11(E) 2SC1815
  Rc: resistor d3 d6 1k
  R1: resistor d25 d20 39k
  R2: resistor e20 e15 12k
  Cin: capacitor/ceramic b17 b20 1u
  Re: resistor j17 j22 220
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - c3 -- +t3 red
  - c25 -- +t25 red
  - a15 -- -t15 black
  - i22 -- -b22 black
  - c6 -- g10 gray
  - c20 -- g9 orange
  - i17 -- j11 blue
  - AD.W1 -- a17 yellow
  - AD.1+ -- c17 orange
  - AD.2+ -- b6 gray
  - AD.1- -- -t8 black
  - AD.2- -- -t9 black
  - -t28 -- -b28 black
```

- `Q1` の実際の足の並びは平らな面を見て E・C・B。図のとおり左から B・C・E
  (h9・h10・h11) に挿すには**平らな面を奥 (a〜e 側) に向ける**
- **トランジスタの胴は下ブロックの数列ぶんを占める**ので、分圧・負荷 (R1・R2・Rc・Cin)
  は上ブロックへ逃がし、橙の線で下ブロックのベース (9 列)・コレクタ (10 列) へ橋渡しする。
  エミッタ (11 列) だけは下ブロックのまま、青の線で遠い列の Re へ渡す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Network | 掃引 10 Hz〜1 MHz、点数 101、振幅 50 mV、Reference = CH1、DUT = CH2 |

**振幅を小さく** (50 mV) するのは、ベースへの入力振幅を線形領域に収めるため。

## 見るべき値

計算値。Vcc = 5 V、hFE = 200 と仮定。

| 項目 | 計算値 | 分かること |
| --- | --- | --- |
| ベース電圧 Vb | 1.18 V | 分圧 5 × 12k/51k (簡易近似。ベース電流ぶん実際はもう少し低い) |
| エミッタ電流 Ie | 2.17 mA | (Vb − 0.7) / Re |
| コレクタ電圧 Vc | 2.83 V | Vcc − Ie × Rc (中間電位で振幅を確保) |
| 中域利得 Av = Rc / (Re + re′) | 4.32 倍 (12.7 dB) | re′ = 25 mV / Ie ≈ 11.5 Ω |
| 低域 −3 dB (Cin と入力インピーダンスで決まる) | 約 21 Hz | 音声帯域より十分低い |
| 高域 −3 dB (Rc とオシロ入力容量 20 pF で決まる) | 約 7.96 MHz | **ブレッドボードとプローブの負荷容量が上限を決めている** (8 章の続き) |

**利得はほぼ Rc / Re で決まり、hFE の個体差にあまり影響されない。** 高域の
上限がトランジスタ自身の f<sub>T</sub> (2SC1815 で 80 MHz 級) よりずっと低いのは、
コレクタの 1 kΩ に対してオシロやブレッドボードの数十 pF が効くため。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
