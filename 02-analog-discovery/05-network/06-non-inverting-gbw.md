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
  U1: dip8 @ f8 LM358
  Rin: resistor i9 i4 1k
  Rf: resistor g9 g8 10k
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [2+, 1+, V-, W1, GND, 1-, 2-, V+]
wires:
  - -b1 -- -t1 black
  - j4 -- -b4 black
  - a9 -- a10 green
  - a11 -- -t11 black
  - +t8 -- a8 red
  - AD.2+ -- j8 blue
  - AD.1+ -- j10 orange
  - AD.V- -- j11 purple
  - i10 -- i12 yellow
  - AD.W1 -- j12 yellow
  - AD.GND -- -b14 black
  - AD.1- -- -b15 black
  - AD.2- -- -b16 black
  - AD.V+ -- +b18 red
  - +b20 -- +t20 red
```

- U1 (LM358) は 2 回路入り。使うのは 1 回路目 (1 番 OUT・2 番 IN−・3 番 IN+・
  4 番 V−)、5〜8 番は 8 番が V+、5〜7 番が使わない側の回路 (5 番 IN2+・6 番 IN2−・7 番 OUT2)
- **使わない側は 7 番 (OUT2) と 6 番 (IN2−) を短絡し、5 番 (IN2+) を GND に落とす**
  (`a9 -- a10` と `a11 -- -t11`)。フォロワにして入力を固定し、発振や不定動作を防ぐ
- 3 番 (IN1+、上の回路図の +) に W1 と CH1、1 番 (OUT1) に CH2、2 番 (IN1−) に
  R<sub>in</sub>、1 番と 2 番の間に R<sub>f</sub> を渡す。3 番 (10 列) は W1 と CH1 の 2 本を挿すので、
  黄の短い線 (`i10 -- i12`) で 12 列へ延ばして W1 をそちらに挿す
- AD は下の帯に置いた (つなぐ先の多くが下のブロックにあるため)。V+ は下の + レールから
  20 列の赤線で上の + レールへ渡して 8 番 (`a8`) に入れる。GND は下の − レールに落とし、
  1 列目の黒線 (`-b1 -- -t1`) で上の − レールとつなぐ (5 番の GND はこちら)

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
