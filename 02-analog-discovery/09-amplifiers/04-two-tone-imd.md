---
book: analog-discovery
chapter: 9
id: 9-4
title: 2 トーン IMD (Wavegen 2 ch + FFT)
tier: 100
source: 自作 (計器の操作は Digilent の Using the Waveform Generator と Using the Spectrum Analyzer)
board: BB
---

# 9-4 2 トーン IMD (Wavegen 2 ch + FFT)

W1・W2 に周波数の近い 2 つの正弦波を出し、抵抗で足し合わせてから 9-2 と同じ
LM358 の非反転増幅に入れる。**増幅回路がわずかでも非線形なら**、出力の FFT に
元の 2 つの周波数 (基本波) だけでなく、その組み合わせでできる**相互変調
(IMD) 成分**が現れる。3 次の相互変調は基本波のすぐ近くに出るので、フィルタで
は取り除けない — 無線機やミキサーで嫌われる歪みの入口をここで見る。

## 回路図

```circuit
title: 図1 W1・W2 を抵抗で足し合わせて増幅回路へ
parts:
  AD:
    type: device
    at: f2
    label: Analog Discovery
    pins: [2+, V+, W1, W2, 1+, 1-, 2-, GND]
    turn: mirror
  Rsuma: resistor e6 e8 10k
  Rsumb: resistor g10 g8 10k
  Cin: capacitor e10 e12 1u
  R1: resistor c14 e14 100k
  R2: resistor e14 g14 100k
  U1: opamp e17d0f0 +up LM358
  Rf: resistor g20 g16 10k
  Rg: resistor g16 i16 1k
  Cg: capacitor i16 k16 10u
  G1: ground k16
  G2: ground g14
  G3: ground h5
wires:
  - AD.W1 -| e6
  - AD.W2 -| g8
  - e8 -- e10
  - g10 -- e10
  - AD.V+ -| c5
  - c5 -- c14
  - e12 -- e13 -- e14
  - AD.1+ -| i7
  - i7 -- i13 -- e13
  - e14 -| U1.+
  - U1.- -| g16
  - U1.out -| g20
  - AD.2+ -| b4
  - b4 -- b21 -- g21
  - g20 -- g21
  - AD.GND -| h4
  - AD.2- -| h5
  - AD.1- -| h6
  - h4 -- h5 -- h6
style:
  pitch: 1.2
```

- Rsuma・Rsumb (各 10 kΩ) が W1・W2 を足し合わせる抵抗。**足し合わせる時点で
  それぞれの振幅は半分になる** (等しい抵抗どうしの分圧) ので、Wavegen 側の
  振幅は狙う振幅の 2 倍にしておく
- 増幅回路そのものは 9-2・9-3 と同じ LM358 非反転増幅 (利得 11 倍)
- 1+ が入力のバイアス点、2+ が出力

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rsuma: resistor b3 b7 10k
  Rsumb: resistor d7 d4 10k
  Cin: capacitor/ceramic a7 a10 1u
  U1: dip8 @ e14 r180 LM358
  R1: resistor e13 e10 100k
  R2: resistor c10 c14 100k
  Rf: resistor h19 h22 10k
  Rg: resistor i22 i26 1k
  Cg: capacitor/electrolytic g26(+) g29(-) 10uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, W2, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.W1 -- a3 yellow
  - AD.W2 -- a4 green
  - AD.1+ -- a15 orange
  - AD.1- -- -t12 black
  - AD.2+ -- a19 gray
  - AD.2- -- -t21 black
  - a13 -- +t13 red
  - a14 -- -t14 black
  - b10 -- b15 orange
  - b17 -- b19 gray
  - c16 -- c22 blue
  - e19 -- f19 gray
  - e22 -- f22 blue
  - j14 -- -b14 black
  - g15 -- g16 green
  - j17 -- +b17 red
  - j29 -- -b29 black
  - +t30 -- +b30 red
  - -t1 -- -b1 black
```

- Rsuma (W1 側、3 列) と Rsumb (W2 側、4 列) の先を 7 列で合流させる。ここが
  2 つの正弦波を足した節点で、Cin (7〜10 列) を通って 9-2 と同じバイアス点
  (10 列、`b10 -- b15` で 3=IN1+ へ) へ入る
- チップを `r180` で置き、帰還 (Rf・Rg・Cg) を右の下ブロックで組むのは 9-2 と同じ。
  左に Rsuma・Rsumb を足したぶん、チップを 2 列右 (e14) へずらしてある
- LM358 の使わない 2 回路目は 9-2 と同じくフォロワにして固定する (7=OUT2 と 6=IN2− を
  `g15 -- g16` で短絡、5=IN2+ を `j14 -- -b14` で GND へ)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Wavegen | W1: Sine 10 kHz、W2: Sine 11 kHz。どちらも振幅 40 mV (抵抗で半分になるので、入力に実際に乗るのは各 20 mV) |
| Spectrum | Range 0〜20 kHz、窓 Flat-top (振幅を正しく読むため)、CH2 (出力) を表示 |

## 見るべき値

計算値。基本波は W1・W2 の設定どおり 10 kHz・11 kHz。3 次相互変調成分の
周波数は 2f1 − f2、2f2 − f1 の公式で決まる (計算値、掃引の設定に依らない)。

| 周波数 | 何が見えるか | 由来 |
| --- | --- | --- |
| 9 kHz | IM3 成分の 1 つ | 2×10k − 11k |
| 10 kHz | 基本波 (W1) | — |
| 11 kHz | 基本波 (W2) | — |
| 12 kHz | IM3 成分の 1 つ | 2×11k − 10k |

**IM3 の絶対的な大きさは LM358 固有の非線形性で決まるので測って確かめるしか
ないが、入力を変えたときの「傾き」は理論から言える。** 弱い非線形性
(3 次までの多項式) を仮定すると、基本波の振幅は入力に比例 (傾き 1)、IM3 の
振幅は入力の 3 乗に比例 (傾き 3) する。**入力振幅を 2 倍 (6 dB 上げる) すると、
基本波は 6 dB 上がるが、IM3 は 18 dB 上がる** — 入力を上げるほど IM3 が
急に育つのが 2 トーン IMD 測定の基本の見方。9-3 の 1 dB 圧縮点に近づくほど
この傾きも崩れてくる (非線形性が強くなるため)。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Waveform Generator](https://digilent.com/reference/test-and-measurement/guides/waveforms-waveform-generator)
と
[Using the Spectrum Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-spectrum-analyzer)。
