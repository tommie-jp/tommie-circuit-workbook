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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/circuit/01-common-emitter-bandwidth.svg)

- R1・R2 (39 kΩ・12 kΩ) がベースの分圧、Re (220 Ω、バイパスなし) がエミッタの
  負帰還。Rc (1 kΩ) がコレクタ負荷
- 1+ は Cin の手前 (W1)、2+ はコレクタ (出力)。1−・2− は GND
- Cin (1 µF) は直流を切る結合コンデンサ

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Cin: capacitor/ceramic c16 c20 1u
  R1: resistor b24 b20 39k
  Rc: resistor d26 d21 1k
  Q1: transistor g20(B) g21(C) g22(E) 2SC1815
  R2: resistor h20 h15 12k
  Re: resistor h22 h27 220
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t12 red
  - AD.GND -- -t13 black
  - AD.W1 -- a16 yellow [h-10]
  - AD.1+ -- b16 orange [h10]
  - AD.1- -- -t18 black
  - AD.2+ -- a21 gray
  - AD.2- -- -t23 black
  - a24 -- +t24 red
  - a26 -- +t26 red
  - e20 -- f20 orange
  - e21 -- f21 gray
  - j15 -- -b15 black
  - j27 -- -b27 black
  - -t28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/breadboard/01-common-emitter-bandwidth.svg)

- `Q1` の実際の足の並びは平らな面を見て E・C・B。図のとおり左から B・C・E
  (g20・g21・g22) に挿すには**平らな面を奥 (a〜e 側) に向ける**
- **トランジスタの胴は下ブロックの数列ぶんを占める**ので、結合・分圧・負荷 (Cin・R1・Rc)
  は上ブロックに置き、ベース (20 列)・コレクタ (21 列) を溝を跨ぐ短い線
  (`e20 -- f20`・`e21 -- f21`) で下ブロックの Q1 へ渡す。R2・Re は下ブロックの h 行で
  Q1 の両脇に置き、GND 側を −b へ落とす (上下の − レールは 28 列で渡す)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Network | 掃引 10 Hz〜1 MHz、点数 101、振幅 50 mV、Reference = CH1、DUT = CH2 |

**振幅を小さく** (50 mV) するのは、ベースへの入力振幅を線形領域に収めるため。

Network の代わりにオシロで中域の波形を見るときは、Wavegen の W1 を 10 kHz・振幅 50 mV の正弦波にし、
Scope の CH2 を AC 結合にする (コレクタに 2.83 V の直流があるため)。

```scope
title: 図3 中域 (10 kHz) で CH2 (コレクタ) は CH1 (入力 50 mV) を約 4.3 倍にして逆向きにする
time: 20us/div
trigger: ch1 rising 0V
ch1: {wave: sine 10kHz 50mV, range: 20mV/div}
ch2: {wave: sine 10kHz 0.216V phase 180deg, range: 100mV/div}
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/scope/01-common-emitter-bandwidth.svg)

図3 は計算値 (中域利得 4.32 倍、出力は入力と逆相)。CH1 は 20 mV/div、CH2 は 100 mV/div と尺度を変えてあるので、
波の高さは CH1 のほうが高く見えるが、Vpp は CH1 0.10 V、CH2 0.43 V で 4.3 倍。

## 見るべき値

計算値。Vcc = 5 V、hFE = 200 と仮定。

| 項目 | 計算値 | 分かること |
| --- | --- | --- |
| ベース電圧 Vb | 1.18 V | 分圧 5 × 12k/51k (簡易近似。ベース電流ぶん実際はもう少し低い) |
| エミッタ電流 Ie | 2.17 mA | (Vb − 0.7) / Re |
| コレクタ電圧 Vc | 2.83 V | Vcc − Ie × Rc (中間電位で振幅を確保) |
| 中域利得 Av = Rc / (Re + re′) | 4.32 倍 (12.7 dB) | re′ = 25 mV / Ie ≈ 11.5 Ω |
| 低域 −3 dB (Cin と入力インピーダンスで決まる) | 約 21 Hz | 音声帯域より十分低い |
| 高域 −3 dB (Rc と AD3 の入力容量 24 pF で決まる) | 約 6.63 MHz (= 1 / (2π × 1 kΩ × 24 pF)、Rc ∥ トランジスタの出力側は無視) | **ブレッドボードとプローブの負荷容量が上限を決めている** (8 章の続き) |

**利得はほぼ Rc / Re で決まり、hFE の個体差にあまり影響されない。** 高域の
上限がトランジスタ自身の f<sub>T</sub> (2SC1815 で 80 MHz 級) よりずっと低いのは、
コレクタの 1 kΩ に対してオシロやブレッドボードの数十 pF が効くため。

入力インピーダンスは R1 ∥ R2 ∥ hFE (Re + re′) ≒ 7.66 kΩ で、Cin (1 µF) と組んで
低域の −3 dB が 20.8 Hz になる。高域は Rc と 24 pF の 6.63 MHz。この 2 つの
折れ点を入れた計算の利得を図にする。

```graph
title: 図4 中域 12.7 dB、−3 dB は 20.8 Hz と 6.63 MHz (計算)
x: 周波数 Hz log 1..100M
y: 利得 dB -20..20
lines:
  計算 dB: 12.71 + 20*log10((x/20.8)/sqrt(1+(x/20.8)^2)) - 10*log10(1+(x/6.63M)^2)
notes:
  - band 10 1M: Network の掃引 (10 Hz〜1 MHz)
  - level 9.7dB
  - mark 20.8
  - mark 1k
  - mark 6.63M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/graph/01-common-emitter-bandwidth.svg)

分かること:

- Network の掃引 (10 Hz〜1 MHz) には低域の折れ点しか入らない。高域の 6.63 MHz は
  掃引の外で、1 MHz ではまだ 0.10 dB しか下がらない
- 中域の平らな所 (100 Hz〜1 MHz) が Rc / (Re + re′) の 12.7 dB

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
