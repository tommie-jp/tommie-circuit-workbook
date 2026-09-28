---
book: denken
chapter: 3
id: 3-3
title: RL 直列 — インピーダンスとベクトル図
tier: 50
source: 自作
board: BB
---

# 3-3 RL 直列 — インピーダンスとベクトル図

抵抗とコイルを直列につなぐと、電圧の足し算は単純な数の足し算にならない。
**R の電圧と L の電圧は 90° 位相がずれているので、ベクトルとして足す**必要が
ある。AD の 2 ch で R と L それぞれの電圧を測り、ベクトル図で確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| X_L = ωL = 2πfL | コイルのリアクタンス |
| Z = √(R² + X_L²) | RL 直列のインピーダンス (合成した「抵抗」) |
| tan θ = X_L / R | 電圧が電流より進む角度 θ |
| V = √(V_R² + V_L²) | 電源電圧は V_R と V_L のベクトル和の大きさ (ピタゴラスの定理) |

## 回路図

```circuit
title: 図1 RL 直列
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  R1: resistor c1 c3 100
  L1: inductor c3 c5 15m
  M1: voltmeter a1 a3 l=$\mathrm{CH1}$
  M2: voltmeter e3 e5 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - a1 -- c1
  - a3 -- c3
  - c3 -- e3
  - c5 -- e5 -- g5
  - g1 -- g5
```

- CH1 が R1 の両端 (電流と同位相)、CH2 が L1 の両端 (電流より 90° 進む)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 100
  L1: inductor/axial d10 d15 15m
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, "1+", "1-", "2+", "2-"]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- b5 yellow [h-10]
  - AD.1+ -- a5 blue
  - AD.1- -- b10 orange [h-10]
  - AD.2+ -- a10 white
  - AD.2- -- b15 green [h-10]
  - a15 -- -t15 black
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 0.7 V |
| Scope | CH1・CH2 とも DC 結合。Measure で CH1・CH2 の Amplitude (振幅) と、CH1 に対する CH2 の Phase を読む |

```scope
title: 図3 V_R (CH1) 0.51 V に対して V_L (CH2) 0.48 V が 90° 進む
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.509V, range: 200mV/div}
ch2: {wave: sine 1kHz 0.480V phase 90deg, range: 200mV/div}
measure: [vmax, phase]
```

### オシロスコープと発振器

AD の CH1 は R1 の両端を差動で挟む (1− が 10 列)。汎用オシロのグランドクリップは大地につながって
いるので、10 列には当てられない ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。V_R (0.51 V) は振れ (0.7 V) の 7 割あり
8 bit でも埋もれないので、**回路はそのままで 2 本の先端を当て、V_R を CH1 − CH2 で引く** (図4)。
2 ch はこれで使い切る。

```circuit
title: 図4 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{FG}$
  M1: voltmeter c3 g3 l=$\mathrm{CH1}$
  R1: resistor c3 c6 100 i=I
  L1: inductor c6 g6 15m
  M2: voltmeter c9 g9 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - c1 -- c3
  - c6 -- c9
  - g1 -- g3 -- g6 -- g9
```

- W1 は FG の OUT (High-Z)。CH1 の先端は FG の出力 (5 列)、CH2 の先端は R1 と L1 の間 (10 列)、
  グランドクリップは 2 本とも GND のレール。ブレッドボードの部品は図2 のまま動かさない
- CH1 は電源の電圧 V、CH2 は V_L (図1 と同じ)、V_R は Math の CH1 − CH2
- Math の波形に Phase を当てられない機種は、CH1 に対する CH2 の位相を読む。V は V_R より θ 進み、
  V_L は V_R より 90° 進むので、読みは 90° − θ = +47° (計算値)。θ = 43° が出る
- FG の出力の 50 Ω が R1 に足される。負荷は 137 Ω と小さく、振幅 0.7 V の設定のままだと CH1 は 0.54 V、
  電流は 3.95 mA に下がる (計算値)。**CH1 の振幅が 0.70 V になるまで FG の振幅を上げる**
  (設定は約 0.90 V、Vpp で入れる機種なら 1.80 Vpp)。そうすれば見るべき値の表がそのまま使える

## 見るべき値

計算値 (R = 100 Ω、L = 15 mH、f = 1 kHz、振幅 0.7 V)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| X_L = 2πfL | 94.2 Ω | コイルのリアクタンス |
| Z = √(R² + X_L²) | 137 Ω | 直列インピーダンス |
| 電流の振幅 I = V / Z | 5.1 mA | 回路に流れる電流 |
| CH1 (V_R = I × R) | 0.51 V | 電流と同位相 |
| CH2 (V_L = I × X_L) | 0.48 V | 電流より 90° 進む |
| CH2 の CH1 に対する位相 | +90° | V_L は V_R (電流と同位相) より 90° 進む |
| 電源電圧 V と電流の角 θ | 43° (= tan⁻¹(94.2/100)) | ベクトル図の角度。V_R と V_L の振幅の比から求める |

**ベクトルで確かめる**: V_R と V_L は 90° 直角なので、√(V_R² + V_L²) =
√(0.51² + 0.48²) ≈ 0.70 V。これが電源の振幅 (0.7 V) にほぼ一致する
(単純に 0.51 + 0.48 = 0.99 V ではない。ここが直流の直列と違う所)。

分かること:

- **電圧を単純に足すと合わない。** RL 直列では V_R と V_L が 90° ずれているので、
  足し算は必ずベクトル (フェーザ) で行う
- インピーダンス Z も同じベクトルの考え方で、R と X_L を直角の 2 辺とする
  直角三角形の斜辺になる
- 周波数を上げると X_L が大きくなり、θ が 90° に近づく (3-9 で周波数特性を測る)

## 出典

自作。
