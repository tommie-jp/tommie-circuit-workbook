---
book: circuits
chapter: 1
id: 1-11
title: LC 共振 — 直列と並列
tier: 200
source: 自作
board: BB
---

# 1-11 LC 共振 — 直列と並列

コイル (L) とコンデンサ (C) は、交流に対して逆向きに振る舞う。コイルのリアクタンス X<sub>L</sub> = 2πfL は周波数とともに増え、
コンデンサの X<sub>C</sub> = 1 / (2πfC) は減る。2 つが等しくなる周波数 **f<sub>0</sub> = 1 / (2π√(LC))** が**共振周波数**で、
そこでは L と C の電圧 (直列のとき) や電流 (並列のとき) がちょうど打ち消し合う。

- **直列共振**: L と C を直列にすると、f<sub>0</sub> で輪のインピーダンスが抵抗分だけになり、電流が最大になる。
  そのとき **C の両端には入力の Q 倍の電圧**がかかる (Q は山の鋭さ)
- **並列共振**: L と C を並列にすると、f<sub>0</sub> で 2 本の電流が打ち消し合い、外から見たインピーダンスが最大になる。
  抵抗を通して電流を入れると、f<sub>0</sub> でだけ電圧が高くなる

9-1 は直列共振の電流を LED で見た。この題は同じ 10 mH と 10 nF で直列と並列を並べて組み、
**Q 倍の電圧**と**並列の山**、それに f<sub>0</sub> での**位相** (直列の C の電圧は入力より 90° 遅れ、並列の電圧は入力と同じ位相) を測る。
第 9 章の同調回路 (中波ラジオの選局、IF のフィルタ) は、どれもこのどちらかの形でできている。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 直列共振 (上) と並列共振 (下)。どちらも L 10 mH・C 10 nF で f0 は 15.9 kHz
parts:
  W1: sine 2,3 2,6 l=$\mathrm{W1}$
  G1: ground 2,6
  M2: voltmeter 4,3 4,5 l=$\mathrm{CH2}$
  G2: ground 4,5
  R1: resistor 5,2 7,2 100
  L1: inductor 7,2 9,2 10m
  C1: capacitor 10,3 10,5 10n
  G3: ground 10,5
  M1: voltmeter 13,3 13,5 l=$\mathrm{CH1}$
  G4: ground 13,5
  R2: resistor 3,8 6,8 10k
  L2: inductor 7,9 7,11 10m
  C2: capacitor 9,9 9,11 10n
  G5: ground 7,11
  G6: ground 9,11
  M3: voltmeter 12,9 12,11 l=$\mathrm{CH1}$
  G7: ground 12,11
wires:
  - 2,3 -- 2,2
  - 2,2 -- 3,2
  - 3,2 -- 4,2
  - 4,2 -- 4,3
  - 4,2 -- 5,2
  - 3,2 -- 3,8
  - 9,2 -- 10,2
  - 10,2 -- 10,3
  - 10,2 -- 13,2
  - 13,2 -- 13,3
  - 6,8 -- 7,8
  - 7,8 -- 7,9
  - 7,8 -- 9,8
  - 9,8 -- 9,9
  - 9,8 -- 12,8
  - 12,8 -- 12,9
notes:
  - text 10.3,1.6: M
  - text 7.3,7.6: P
  - text 14,4 left: 直列 (CH1 は C1 の電圧)
  - text 13.5,10 left: 並列 (CH1 は P の電圧)
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/11-lc-resonance.svg)

W1 (Analog Discovery 3 (AD3) の Wavegen) から、上の直列と下の並列の両方に同じ正弦波を入れる。CH2 で W1 を、CH1 で M (直列の C1 の電圧) か P (並列の電圧) を見る。

- **f<sub>0</sub>** = 1 / (2π√(10 mH × 10 nF)) = **15.9 kHz**。そこでの X<sub>L</sub> = X<sub>C</sub> = √(L/C) = **1 kΩ** (この値を特性インピーダンスという)
- **直列**: 輪の抵抗は `R1` 100 Ω とコイルの巻線抵抗 r (9-1 で測った 20 Ω ほど) の合計 120 Ω。
  Q = √(L/C) / (R1 + r) = 1000 / 120 = **8.3**。f<sub>0</sub> では C1 の電圧が入力の 8.3 倍になる
- **並列**: f<sub>0</sub> での L2 と C2 の組のインピーダンスは L / (C r) = 10 mH / (10 nF × 20 Ω) = **50 kΩ** (純抵抗)。
  `R2` 10 kΩ との分圧で、P は入力の 50 / 60 = **0.83 倍** (CH1 の 1 MΩ も並列に入るので 0.83 のまま)。
  離れると組のインピーダンスが急に下がり、P はほぼ 0 になる
- **並列の山の鋭さ**: 並列の組から見た抵抗は、`R2` 10 kΩ と 50 kΩ の並列で 8.3 kΩ。Q = 8.3 kΩ / √(L/C) = **8.3** で、
  たまたま直列と同じになるように選んである。帯域 (山の高さの 1/√2 の幅) は f<sub>0</sub> / Q ≈ **1.9 kHz**

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 上のブロックが直列、下のブロックが並列。W1 は両方に入る
board: half
parts:
  R1: resistor b3 b6 100
  L1: inductor/axial d6 d12 10m
  C1: capacitor/ceramic c12 c15 10n
  R2: resistor g3 g9 10k
  L2: inductor/axial i9 i15 10m
  C2: capacitor/ceramic j9 -b9 10n
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [2+, W1, GND, 2-, 1+, 1-]
wires:
  - AD.2+ -- a2 blue
  - c2 -- c3 blue
  - AD.W1 -- a3 yellow
  - AD.GND -- -t5 black
  - AD.2- -- -t7 black
  - e3 -- f3 yellow
  - AD.1+ -- a12 orange
  - a15 -- -t15 black
  - AD.1- -- -t17 black
  - j15 -- -b15 black
  - -t29 -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/11-lc-resonance.svg)

- **上のブロック (直列)**: W1 が列 3。`R1` で列 6、`L1` で **列 12 = M**、`C1` で列 15、列 15 を上の − レールへ。CH1 の 1+ は M (a12)
- **下のブロック (並列)**: 列 3 の W1 を黄の線で下へ渡し、`R2` で **列 9 = P** へ。`L2` は P から列 15 (下の − レールへ)、`C2` は P から下の − レールへ縦に挿す
- **並列を測るとき**は、CH1 の 1+ を a12 から抜いて P (列 9 の下のブロックの空いた穴、h9) へ挿し直す
- 上下の − レールは列 29 でつなぐ。直流の電源は使わない

W1 から流れる電流は、直列の f<sub>0</sub> で最大 4.2 mA (振幅 0.5 V / 120 Ω) と並列の 0.02 mA の合計で、W1 の約 10 mA に収まる。
15.9 kHz はブレッドボードの範囲 (3 MHz 以下) の十分内側。

## 計器の設定

計器は AD3 の Wavegen と Scope。f<sub>0</sub> での大きさと位相は Scope で、山の形 (図4) は Wavegen の周波数を表の順に変えて Scope で読む
(AD3 の Network の画面を使えば、同じ曲線が自動で描ける)。

| 項目 | 値 |
| --- | --- |
| Wavegen W1 | 正弦波、振幅 0.5 V (1 Vpp)、オフセット 0 V、周波数 15.9 kHz から |
| Scope CH1 | 直列の M は 2 V/div、並列の P は 200 mV/div |
| Scope CH2 | 直列のときは CH1 と同じ 2 V/div (高さを比べる)、並列のときは 200 mV/div |
| 時間 | 20 µs/div (15.9 kHz の 1 周期 63 µs が約 3 目盛) |
| トリガ | CH2 の立ち上がり、0 V |

f<sub>0</sub> は部品の誤差 (C の ±5 %、L の ±10 %) で 15.9 kHz から数 % ずれる。周波数を少しずつ動かし、直列は CH1 が最大になる所、
並列は CH1 と CH2 の位相差が 0 になる所を f<sub>0</sub> とする。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 直列共振の f0 — C1 の電圧 (CH1) は入力 (CH2) の 8.3 倍で 90° 遅れる (同じ 2 V/div)
time: 20us/div
trigger: ch2 rising 0V
ch1: {wave: sine 15.9kHz 8.25Vpp phase -90deg, range: 2V/div}
ch2: {wave: sine 15.9kHz 1Vpp, range: 2V/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/scope/11-lc-resonance.svg)

図3 の CH1 は 8.25 Vpp で、CH2 の 1 Vpp の 8.3 倍。CH2 の山から 1/4 周期遅れて CH1 の山が来る。
C1 には入力の 8 倍の電圧がかかるので、C1 は耐圧 50 V の品を使う (入力を 3 V<sub>p</sub> にすると 25 V<sub>p</sub> になる)。

並列は f<sub>0</sub> で P が 0.83 Vpp、CH2 と同じ位相。f<sub>0</sub> より低いと位相が進み、高いと遅れる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| L1, L2 | インダクタ (アキシアル) | 10 mH (巻線抵抗は 20 Ω ほど。テスターで測っておく) |
| C1, C2 | セラミックコンデンサ | 10 nF (103)、耐圧 50 V。温度で値の動かない CH (C0G) かフィルムなら f<sub>0</sub> がずれにくい |
| R1 | 抵抗 (1/4 W) | 100 Ω |
| R2 | 抵抗 (1/4 W) | 10 kΩ |
| — | 信号 | AD3 の W1 (正弦波、1 Vpp) |

## 見るべき値

| 測る所 | 期待する値 (計算値) | 分かること |
| --- | --- | --- |
| 直列の f<sub>0</sub> (CH1 が最大) | 15.9 kHz | 1 / (2π√(LC)) |
| 直列の CH1 / CH2 (f<sub>0</sub>) | 8.3 倍 (8.25 Vpp / 1 Vpp)、位相 −90° | Q 倍の電圧。C の電圧は電流より 90° 遅れ、電流は入力と同じ位相 |
| 直列の CH1 / CH2 (10 kHz・25 kHz) | 1.64 倍・0.68 倍 | 離れると Q 倍の効きがなくなる。低い所では 1 倍、高い所では 0 に近づく |
| 並列の CH1 / CH2 (f<sub>0</sub>) | 0.83 倍、位相 0° | 組のインピーダンスが最大 (50 kΩ) で、純抵抗 |
| 並列の CH1 / CH2 (10 kHz・25 kHz) | 0.10 倍・0.11 倍 | 離れると L か C のどちらかに電流が逃げる |
| 帯域 (並列の山が 0.83 の 1/√2 = 0.58 倍になる 2 つの周波数) | 15.0 kHz と 16.9 kHz (幅 1.9 kHz) | Q = 15.9 / 1.9 ≈ 8.3 |

測った値を周波数ごとに dB (20 log<sub>10</sub>(CH1 / CH2)) にして並べると図4 になる。直列は f<sub>0</sub> で +18 dB の山、並列は −1.7 dB の山で、
どちらも同じ幅の山 (Q が同じ) になる。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 直列 (C1 の電圧) と並列 (P の電圧) の入力に対する比 — どちらも 15.9 kHz で山
x: 周波数 Hz log 5k..50k
y: 入力に対する比 dB
lines:
  直列 (C1 の電圧) dB:
    - 5k 0.89
    - 6k 1.32
    - 8k 2.50
    - 10k 4.29
    - 12k 7.11
    - 13k 9.19
    - 14k 12.04
    - 14.5k 13.86
    - 15k 15.93
    - 15.5k 17.81
    - 15.9k 18.35
    - 16.3k 17.51
    - 16.8k 15.33
    - 17.5k 12.12
    - 18.5k 8.45
    - 20k 4.46
    - 22k 0.67
    - 25k -3.40
    - 32k -9.69
    - 40k -14.53
    - 50k -18.97
  並列 (P の電圧) dB:
    - 5k -29.16
    - 6k -27.16
    - 8k -23.49
    - 10k -19.77
    - 12k -15.38
    - 13k -12.61
    - 14k -9.13
    - 14.5k -7.01
    - 15k -4.65
    - 15.5k -2.47
    - 15.9k -1.66
    - 16.3k -2.23
    - 16.8k -4.14
    - 17.5k -7.00
    - 18.5k -10.20
    - 20k -13.53
    - 22k -16.50
    - 25k -19.47
    - 32k -23.62
    - 40k -26.52
    - 50k -29.02
notes:
  - mark 15.9k
  - band 15k 16.9k: 並列の帯域
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/graph/11-lc-resonance.svg)

図4 の線は図1 の回路 (巻線抵抗 20 Ω、CH1 の入力 1 MΩ を含む) から計算した値で、下の LTspice の値と 3 つの周波数で突き合わせてある。

## LTspice での確かめ

`sim/11-lc-resonance.cir` で図1 の 2 つの回路を .ac (2〜100 kHz) で解き、W1 に対する M と P の大きさと位相を読んだ。
コイルの巻線抵抗 20 Ω は 9-1 の実測に合わせた仮定、CH1 の入力は 1 MΩ。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 直列の f<sub>0</sub> (M の位相が −90°) | 15.9 kHz | 15.92 kHz | 合う |
| 直列の M / W1 (15.92 kHz・最大) | 8.3 倍 | 8.25 倍・最大 8.28 倍 | 合う |
| 直列の電流 (15.92 kHz、W1 の振幅 1 V あたり) | 1 / 120 Ω = 8.3 mA | 8.25 mA | 合う |
| 並列の f<sub>0</sub> (P の位相が 0°) | 15.9 kHz | 15.91 kHz | 合う |
| 並列の P / W1 (15.92 kHz) | 0.83 倍 | 0.825 倍 | 合う |
| 10 kHz の M・P | 1.64 倍・0.10 倍 | 1.64 倍・0.103 倍 | 合う |
| 25 kHz の M・P | 0.68 倍・0.11 倍 | 0.676 倍・0.106 倍 | 合う |
| 並列の帯域の下の端 | 15.0 kHz | 14.94 kHz | 合う |

## 出典

自作。

参考: [共振回路 (Wikipedia)](https://ja.wikipedia.org/wiki/共振回路)、[RLC circuit (Wikipedia)](https://en.wikipedia.org/wiki/RLC_circuit)、[Lessons in Electric Circuits Vol. II 第 6 章 Resonance](https://www.ibiblio.org/kuphaldt/electricCircuits/AC/AC_6.html)
