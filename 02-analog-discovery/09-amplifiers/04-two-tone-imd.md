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
    at: a1
    label: Analog Discovery
    pins: [V+, GND, W1, W2, 1+, 1-, 2+, 2-]
  Rsuma: resistor c4 c7 10k
  Rsumb: resistor c8 c15 10k
  Cin: capacitor f8 f11 1u
  R1: resistor i20 i23 100k
  R2: resistor i23 i26 100k
  U1: opamp l35 LM358
  Rf: resistor i40 i43 10k
  Rg: resistor i43 i46 1k
  Cg: capacitor i46 i49 10u
  G1: ground i49
  G2: ground i26
wires:
  - AD.W1 -| c4
  - AD.W2 -| c15
  - c7 -- c8
  - c8 -- f8
  - f11 -- j11
  - j11 -- j23
  - j23 -- i23
  - AD.V+ -| i20
  - AD.1+ -| i23
  - U1.+ |- k23
  - k23 -- i23
  - U1.- |- k43
  - k43 -- i43
  - U1.out |- i40
  - AD.2+ -| i40
  - AD.1- -| i26
  - AD.2- -| i26
  - AD.GND -| i26
```

- Rsuma・Rsumb (各 10 kΩ) が W1・W2 を足し合わせる抵抗。**足し合わせる時点で
  それぞれの振幅は半分になる** (等しい抵抗どうしの分圧) ので、Wavegen 側の
  振幅は狙う振幅の 2 倍にしておく
- 増幅回路そのものは 9-2・9-3 と同じ LM358 非反転増幅 (利得 11 倍)
- 1+ が入力のバイアス点、2+ が出力

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: full
parts:
  Rsuma: resistor b40 b43 10k
  Rsumb: resistor c48 c45 10k
  Cin: capacitor/ceramic b27 b30 1u
  U1: dip8 @ e5 LM358
  R1: resistor d35 d30 100k
  R2: resistor e30 e25 100k
  Rf: resistor j5 j6 10k
  Rg: resistor i6 i9 1k
  Cg: capacitor/electrolytic h9(+) h12(-) 10uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, W2, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - AD.W1 -- a40 yellow
  - AD.W2 -- a45 green
  - d43 -- d48 orange
  - e48 -- c27 orange
  - j8 -- -b8 black
  - c35 -- +t35 red
  - c25 -- -t25 black
  - c30 -- g7 orange
  - a5 -- +t5 red
  - AD.1+ -- a30 orange
  - AD.2+ -- i5 gray
  - AD.1- -- -t8 black
  - AD.2- -- -t9 black
  - i12 -- -b12 black
  - +t50 -- +b50 red
  - -t50 -- -b50 black
  - c6 -- c7 green
  - a8 -- -t7 black
```

- Rsuma (W1 側、40 列) と Rsumb (W2 側、45 列) の先 (43 列・48 列) を橙の線で
  合流させ、27 列 (Cin の左足) へ橋渡しする。ここが 2 つの正弦波を足した節点で、
  Cin を通って 9-2 と同じバイアス点へ入る
- 9-2・9-3 の板に Rsuma・Rsumb・その合流の配線だけを、空いている 40〜48 列に足した形
- LM358 の使わない 2 回路目は 9-2 と同じくフォロワにして固定する (7=OUT2 と 6=IN2− を
  `c6 -- c7` で短絡、5=IN2+ を `a8 -- -t7` で GND へ)

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
