---
book: analog-discovery
chapter: 5
id: 5-6
title: オペアンプ非反転増幅の利得と帯域 (GBW)
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-6 オペアンプ非反転増幅の利得と帯域 (GBW)

オペアンプの**利得帯域幅積 (GBW)** は「利得 × 帯域幅 ≒ 一定」という関係。
非反転アンプの利得を変えて、帯域 (−3 dB 点) がどう動くかを Network で測る。
LM358 (GBW ≈ 1 MHz、データシート代表値) を使う。

## 回路図

```circuit
title: 図1 非反転増幅
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  G1: ground c1
  G2: ground c3
  U1: opamp b6 +up
  Rin: resistor c7 d7 1k
  G3: ground d7
  Rf: resistor c7 c9 10k
  M2: voltmeter b10 d10 l=$\mathrm{CH2}$
  G4: ground d10
wires:
  - a1 -- a3
  - a3 |- U1.+
  - c7 |- U1.-
  - U1.out -- b9 -- b10
  - c9 -- b9
```

利得 A<sub>v</sub> = 1 + R<sub>f</sub> / R<sub>in</sub>。図は R<sub>f</sub> = 10 kΩ
(A<sub>v</sub> = 11) の状態。**R<sub>f</sub> を 100 kΩ に差し替えると A<sub>v</sub> = 101**
になる。W1 の Amplitude は 20 mV に抑える (出力が電源レールに近づかないように)。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  U1: dip8 @ f5 LM358
  Rin: resistor h6 h9 1k
  Rf: resistor i6 i5 10k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, V+, V-, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t2 black
  - AD.V+ -- a5 red
  - AD.V- -- h8 orange
  - AD.W1 -- h7 yellow
  - AD.1+ -- i7 orange [h10]
  - AD.1- -- -t11 black
  - AD.2+ -- j5 blue
  - AD.2- -- -t12 black
  - i9 -- -t9 black
  - a8 -- -t8 black
  - a6 -- a7 green
```

- U1 (LM358) は 2 回路入り。使うのは 1 回路目 (1 番 OUT・2 番 IN−・3 番 IN+・
  4 番 V−)、5〜8 番は 8 番が V+、5〜7 番が使わない側の回路
- **使わない側は 6 番 (OUT2) と 7 番 (IN2−) を短絡し、5 番 (IN2+) を GND に落とす**
  (`a6 -- a7` と `a8 -- -t8`)。フォロワにして入力を固定し、発振や不定動作を防ぐ
- 3 番 (IN1+、上の回路図の +) に W1 と CH1、1 番 (OUT1) に CH2、2 番 (IN1−) に
  R<sub>in</sub>、1 番と 2 番の間に R<sub>f</sub> を渡す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、V− = −5 V。Master Enable を入れる (1-1 と同じ) |
| Wavegen | W1: Amplitude 20 mV |
| Network | Start 1 kHz、Stop 1 MHz、Log、Steps 101、Reference: Channel 1 |

## 見るべき値

計算値。GBW ≈ 1 MHz (LM358 のデータシート代表値) として、
**帯域 (−3 dB) ≈ GBW / A<sub>v</sub>**。

| R<sub>f</sub> | 利得 A<sub>v</sub> | 直流利得 (dB) | 予想帯域 (−3 dB) |
| --- | --- | --- | --- |
| 10 kΩ | 11 | 20.8 dB | 90.9 kHz |
| 100 kΩ | 101 | 40.1 dB | 9.90 kHz |

分かること:

- **利得を 10 倍にすると帯域はほぼ 1/10 になる。** 90.9 kHz → 9.90 kHz と、
  ほぼきれいに 1/10 (GBW が一定という近似が成り立つ範囲)
- 出力の振幅は A<sub>v</sub> = 101 のとき最大で 20 mV × 101 ≈ 2.02 V (0-peak)。
  スルーレートで必要な dV/dt は 2π × 9.9 kHz × 2.02 V ≈ 0.126 V/µs で、
  LM358 のスルーレート (0.3 V/µs 程度) の範囲内 — 波形がなまらずに測れる
- 実測の帯域がこの計算値より低く出たら、GBW がデータシート代表値より低い
  個体か、ブレッドボードの浮遊容量 (第 8 章) が効いている可能性がある

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。LM358 の GBW はデータシートの代表値。
