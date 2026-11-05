---
book: analog-discovery
chapter: 5
id: 5-20
title: 10:1 プローブ込みの NA
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-20 10:1 プローブ込みの NA

Network の CH2 を、インピーダンスの高い節点 (100 kΩ の先など) につなぐと、計器の入力 (1 MΩ ∥ 24 pF) とつなぐ線の容量が
節点に足されて、測りたい回路そのものが変わる。**10:1 プローブ**は先端の 9 MΩ と小さなコンデンサで入力を 10 MΩ ∥ 十数 pF に見せ、
この影響を 1/10 ほどに減らす。代わりに 2 つの手間が増える。信号が 1/10 になるので計器の側に減衰比 (10×) を入れること、
先端のコンデンサの**補正**を合わせること (2-9)。補正がずれると、プローブ自身が周波数特性を持ち、ボード線図に段ができる。

この題では 100 kΩ・100 pF の RC ローパス (f<sub>c</sub> = 15.9 kHz) を、CH2 を 1:1 の同軸で直につないだときと 10:1 プローブで
つないだときで掃引し、さらにプローブの補正をわざとずらして比べる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 RC ローパスを 10:1 プローブで測る (プローブと CH2 は等価回路)
parts:
  V1: sine 1,2 1,4 l=$\mathrm{W1}$
  G1: ground 1,4
  M1: voltmeter 3,2 3,4 l=$\mathrm{CH1}$
  G2: ground 3,4
  R1: resistor 3,2 6,2 100k
  C1: capacitor 6,2 6,4 100p
  G3: ground 6,4
  Rtip: resistor 8,1.5 11,1.5 9M l=$\mathrm{R_{tip}}$
  Ctip: capacitor 8,2.5 11,2.5 12.7p l=$\mathrm{C_{tip}}$
  Rin: resistor 12,2 12,4 1M l=$\mathrm{R_{in}}$
  Cin: capacitor 14,2 14,4 114p l=$\mathrm{C_{in}}$
  G4: ground 12,4
  G5: ground 14,4
  M2: voltmeter 16,2 16,4 l=$\mathrm{CH2}$
  G6: ground 16,4
wires:
  - 1,2 -- 3,2
  - 6,2 -- 8,2
  - 8,1.5 -- 8,2
  - 8,2 -- 8,2.5
  - 11,1.5 -- 11,2
  - 11,2 -- 11,2.5
  - 11,2 -- 12,2
  - 12,2 -- 14,2
  - 14,2 -- 16,2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/20-probe-10x-na.svg)

- R1・C1 が測る回路 (DUT)。出力 X は 100 kΩ の先で、インピーダンスが高い
- R<sub>tip</sub>・C<sub>tip</sub> は 10:1 プローブの先端、R<sub>in</sub>・C<sub>in</sub> は CH2 の入力 (1 MΩ ∥ 24 pF、AD3 の仕様) とプローブの線 (90 pF と仮定) を
  合わせた**等価回路**。基板には載らない
- 補正が合うのは R<sub>tip</sub> C<sub>tip</sub> = R<sub>in</sub> C<sub>in</sub> のとき、C<sub>tip</sub> = 114 pF/9 = 12.7 pF。
  このとき先端から見たプローブは 10 MΩ ∥ 11.4 pF
- 1:1 で測るときは、プローブを外して CH2 を同軸 (線の容量 90 pF と仮定) で X に直につなぐ。X に 1 MΩ ∥ 114 pF が直に掛かる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (CH2 は 10:1 プローブ)
board: half
parts:
  R1: resistor c5 c10 100k
  C1: capacitor a10 -t10 100p cap=right
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (BNC アダプタ)
    pins: [1-, GND, 1+, W1]
  P2:
    type: device
    at: bottom
    label: 10:1 プローブ (CH2 の BNC へ)
    pins: [TIP, GND]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange
  - AD.GND -- -t3 black
  - AD.1- -- -t2 black
  - d10 -- g10 white
  - P2.TIP -- i10 blue
  - P2.GND -- -b13 black
  - -b1 -- -t1 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/20-probe-10x-na.svg)

- R1 は 5 列 (W1・CH1) から 10 列 (X)、C1 は 10 列から上の − レールへ。10 列は白の線で溝を渡して下のブロックへ延ばし、
  プローブの先端 (TIP) を `i10` に掛ける。プローブの GND の線は下の − レールへ短く
- AD3 には BNC アダプタを付ける。W1 と CH1 は BNC からクリップのケーブルで、CH2 は 10:1 プローブを BNC に挿す
- 1:1 で測るときは、プローブの代わりに BNC のクリップのケーブル (1 m) を CH2 につなぎ、同じ `i10` に挿す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V、Offset 0 V |
| Network | Start 100 Hz、Stop 100 kHz、Log、Steps 201、Reference: Channel 1 |
| CH2 の減衰比 | 10:1 プローブのときは CH2 の Attenuation を 10× にする (1:1 のときは 1×)。設定の場所は WaveForms の版で違う (目安) |
| 補正 | 先に 2-9 の手順で、1 kHz の方形波が平らになるようにプローブの補正を合わせる |

**減衰比を入れ忘れると、ボード線図全体が −20 dB にずれる**。形は同じなので、低い周波数で −20 dB 前後なら設定を疑う。

10:1 プローブ (補正が合う) で 10 kHz の時間波形が図3 (計算値。減衰比 10× を入れた表示)。CH2 は 0.81 倍で 35° 遅れる。
プローブなしの理想 (0.85 倍・32°) にほぼ近い。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 10:1 プローブ・10 kHz — CH2 は 0.81 倍で 35° 遅れる
time: 20us/div
trigger: ch1 rising 0V
ch1: {wave: sine 10kHz 1V, range: 500mV/div}
ch2: {wave: sine 10kHz 0.814V phase -34.7deg, range: 500mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/20-probe-10x-na.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 100 kΩ |
| C1 | セラミックコンデンサ (C0G、101) | 100 pF |
| P2 | 10:1 のオシロスコープ用プローブ (補正つき) | 入力 10 MΩ ∥ 十数 pF のもの |
| — | AD3 の BNC アダプタと BNC のクリップのケーブル | 2 本 (W1・CH1)。1:1 で比べるとき CH2 用に 1 本 |
| — | 電源 | 使わない |
| — | 計器 | AD3 の W1・Scope 1・Scope 2 (プローブ) |

## 見るべき値

計算値。CH2 の入力と線は 1 MΩ ∥ 114 pF (24 pF + 線 90 pF、仮定)、10:1 プローブの先端は 9 MΩ ∥ 12.7 pF (補正が合うとき)。
理想 (計器を何もつながない) は直流 0 dB・f<sub>c</sub> 15.9 kHz。

| つなぎ方 | 低い周波数 (10 Hz) | 1 kHz | f<sub>c</sub> (−3 dB) |
| --- | --- | --- | --- |
| 1:1 の同軸で直に | −0.83 dB | −0.89 dB | **8.2 kHz** |
| 10:1 (補正が合う) | −0.09 dB | −0.11 dB | **14.4 kHz** |
| 10:1 (C<sub>tip</sub> 20 % 多い、補正しすぎ) | −0.08 dB | **+0.44 dB** | 18.8 kHz |
| 10:1 (C<sub>tip</sub> 20 % 少ない、補正が足りない) | −0.09 dB | **−0.61 dB** | 8.7 kHz |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 1:1 は fc を半分に下げる。10:1 は理想に近いが、補正がずれると段ができる
x: 周波数 Hz log 100..100k
y: 利得 dB -20..2
lines:
  1:1 (同軸) dB:
    - 100 -0.83
    - 200 -0.83
    - 500 -0.84
    - 1k -0.89
    - 2k -1.08
    - 5k -2.21
    - 8k -3.74
    - 10k -4.80
    - 15k -7.22
    - 20k -9.26
    - 50k -16.67
    - 100k -22.60
  10:1 (補正が合う) dB:
    - 100 -0.09
    - 200 -0.09
    - 500 -0.09
    - 1k -0.11
    - 2k -0.17
    - 5k -0.58
    - 8k -1.25
    - 10k -1.79
    - 15k -3.27
    - 20k -4.74
    - 50k -11.23
    - 100k -16.99
  10:1 (補正しすぎ +20 %) dB:
    - 100 -0.08
    - 200 -0.05
    - 500 0.10
    - 1k 0.44
    - 2k 0.84
    - 5k 0.73
    - 8k 0.09
    - 10k -0.45
    - 15k -1.95
    - 20k -3.44
    - 50k -9.96
    - 100k -15.73
  10:1 (補正が足りない −20 %) dB:
    - 100 -0.09
    - 200 -0.12
    - 500 -0.25
    - 1k -0.61
    - 2k -1.25
    - 5k -2.16
    - 8k -2.91
    - 10k -3.46
    - 15k -4.93
    - 20k -6.39
    - 50k -12.84
    - 100k -18.59
notes:
  - level -3dB
  - mark 1k
  - mark 14.4k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/20-probe-10x-na.svg)

分かること:

- **1:1 で直につなぐと、f<sub>c</sub> は 15.9 kHz から 8.2 kHz へほぼ半分に下がる。** 100 kΩ の先に 114 pF が足され、C1 (100 pF) より大きいため。
  直流でも 1 MΩ と 100 kΩ の分圧で −0.83 dB 下がる
- **10:1 なら 14.4 kHz と理想に近い。** 先端の 11.4 pF が残るので、理想からは 1 割ずれる。高いインピーダンスの節点ほど、
  この残りが効く
- **補正がずれると、プローブ自身の段が DUT の特性に重なる。** 補正しすぎなら 1 kHz 付近から持ち上がり、f<sub>c</sub> が高く読める。
  足りなければ下がり、低く読める。どちらも低い周波数 (10 Hz) では正しいので、段は 1 kHz 前後に現れる
  (1/(2π × (9 MΩ ∥ 1 MΩ) × (C<sub>tip</sub> + C<sub>in</sub>)) ≈ 1.4 kHz)。掃引の前に必ず 2-9 で補正を合わせる
- CH1 は W1 の出力 (インピーダンスが低い) につなぐので、1:1 のままでよい。プローブが要るのは高いインピーダンスの節点だけ

## LTspice での確かめ

`sim/20-probe-10x-na.cir` で図1 を AC 解析した。CH2 と線は 1 MΩ ∥ 114 pF、プローブは 9 MΩ ∥ (114 pF/9 × m) とした (**仮定**)。
1:1 と、10:1 の m = 1・1.2・0.8 の 4 通りに振り、10:1 は 10 倍して読んだ。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 1:1 の直流・f<sub>c</sub> | −0.83 dB・8.2 kHz | 0.9091 倍 (−0.83 dB)・8.16 kHz | 合う |
| 10:1 (合う) の直流・f<sub>c</sub> | −0.09 dB・14.4 kHz | 0.9901 倍 (−0.086 dB)・14.40 kHz | 合う |
| 10:1 (合う) の 10 kHz | 0.81 倍 | 0.8138 倍 | 合う |
| 10:1 (しすぎ) の 1 kHz・f<sub>c</sub> | +0.44 dB・18.8 kHz | 1.0516 倍 (+0.44 dB)・18.76 kHz | 合う |
| 10:1 (足りない) の 1 kHz・f<sub>c</sub> | −0.61 dB・8.7 kHz | 0.9318 倍 (−0.61 dB)・8.66 kHz | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。CH2 の入力インピーダンス (1 MΩ ∥ 24 pF) は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
プローブの線の容量 (90 pF) は一般的な値からの仮定。
