---
book: denken
chapter: 3
id: 3-4
title: RC 直列 — 電圧の和はベクトルの和
tier: 50
source: 自作
board: BB
---

# 3-4 RC 直列 — 電圧の和はベクトルの和

RL 直列 (3-3) と同じ考え方を、今度は抵抗とコンデンサの直列で確かめる。
コンデンサは電流が電圧より 90° 進むので、R の電圧と C の電圧はやはり
90° ずれる。テスターで別々に測った電圧を単純に足しても電源電圧にならない
ことを、実際に測って確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| X_C = 1 / (ωC) = 1 / (2πfC) | コンデンサのリアクタンス |
| Z = √(R² + X_C²) | RC 直列のインピーダンス |
| tan θ = X_C / R | 電圧が電流より遅れる角度 θ |
| V = √(V_R² + V_C²) | 電源電圧は V_R と V_C のベクトル和の大きさ |

## 回路図

```circuit
title: 図1 RC 直列
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine 1,3 1,7 l=$\mathrm{W1}$
  R1: resistor 1,3 3,3 1k
  C1: capacitor 3,3 5,3 100n
  M1: voltmeter 1,1 3,1 l=$\mathrm{CH1}$
  M2: voltmeter 3,5 5,5 l=$\mathrm{CH2}$
  G1: ground 1,7
wires:
  - 1,1 -- 1,3
  - 3,1 -- 3,3
  - 3,3 -- 3,5
  - 5,3 -- 5,5 -- 5,7
  - 1,7 -- 5,7
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/04-rc-series-1.svg)

- CH1 が R1 の両端 (電流と同位相)、CH2 が C1 の両端 (電流より 90° 遅れる)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 1k
  C1: capacitor/ceramic d10 d15 100n
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/breadboard/04-rc-series.svg)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V |
| Scope | CH1・CH2 とも DC 結合。Measure で Amplitude と、CH1 に対する CH2 の Phase を読む |

```scope
title: 図3 V_R (CH1) 0.53 V に対して V_C (CH2) 0.85 V が 90° 遅れる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.532V, range: 250mV/div}
ch2: {wave: sine 1kHz 0.847V phase -90deg, range: 250mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/04-rc-series.svg)

### オシロスコープと発振器

3-3 と同じ組み方になる。AD の CH1 は R1 の両端を差動で挟む (1− が 10 列) が、汎用オシロの
グランドクリップは大地につながっていて 10 列には当てられない
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。V_R (0.53 V) は振れ (1 V) の半分あり
8 bit でも埋もれないので、**回路はそのままで 2 本の先端を当て、V_R を CH1 − CH2 で引く** (図4)。

```circuit
title: 図4 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine 1,3 1,7 l=$\mathrm{FG}$
  M1: voltmeter 3,3 3,7 l=$\mathrm{CH1}$
  R1: resistor 3,3 6,3 1k i=I
  C1: capacitor 6,3 6,7 100n
  M2: voltmeter 9,3 9,7 l=$\mathrm{CH2}$
  G1: ground 1,7
wires:
  - 1,3 -- 3,3
  - 6,3 -- 9,3
  - 1,7 -- 3,7 -- 6,7 -- 9,7
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/04-rc-series-2.svg)

- W1 は FG の OUT (High-Z)。振幅 1 V は Vpp で入れる機種なら 2 Vpp。CH1 の先端は FG の出力 (5 列)、
  CH2 の先端は R1 と C1 の間 (10 列)、グランドクリップは 2 本とも GND のレール。
  ブレッドボードの部品は図2 のまま動かさない
- CH1 は電源の電圧 V、CH2 は V_C (図1 と同じ)、V_R は Math の CH1 − CH2
- Math の波形に Phase を当てられない機種は、CH1 に対する CH2 の位相を読む。V は V_R より θ 遅れ、
  V_C は V_R より 90° 遅れるので、読みは −(90° − θ) = −32° (計算値)。θ = 58° が出る
- FG の出力の 50 Ω で、CH1 は 0.986 V、電流は 0.524 mA に下がる (1.4 %、計算値)。
  表どおりにするなら CH1 の振幅が 1.00 V になるまで FG の振幅を上げる (約 2.03 Vpp)

## 見るべき値

計算値 (R = 1 kΩ、C = 100 nF、f = 1 kHz、振幅 1 V)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| X_C = 1 / (2πfC) | 1592 Ω | コンデンサのリアクタンス |
| Z = √(R² + X_C²) | 1880 Ω | 直列インピーダンス |
| 電流の振幅 I = V / Z | 0.53 mA | 回路に流れる電流 |
| CH1 (V_R = I × R) | 0.53 V | 電流と同位相 |
| CH2 (V_C = I × X_C) | 0.85 V | 電流より 90° 遅れる |
| CH2 の CH1 に対する位相 | −90° | V_C は V_R (電流と同位相) より 90° 遅れる |
| 電源電圧 V と電流の角 θ | −58° | ベクトル図の角度 (電圧が電流より遅れる)。V_R と V_C の振幅の比から求める |

**ベクトルで確かめる**: √(V_R² + V_C²) = √(0.53² + 0.85²) ≈ 1.00 V。
これが電源の振幅 (1 V) に一致する。テスターで V_R と V_C を測って単純に
足すと 0.53 + 0.85 = 1.38 V となり、電源電圧の 1 V を超えてしまう —
これは測り方の間違いではなく、**足し算がベクトルでないと合わない**という
交流の性質そのもの。

分かること:

- RL (3-3) は電圧が電流より**進む**、RC は電圧が電流より**遅れる**。
  進み・遅れが逆になる
- 周波数を上げると X_C が小さくなり (RL の X_L は逆に大きくなる)、
  θ が 0° に近づく (3-9 で周波数特性を測る)
- R と C を入れ替えて測っても Z や θ は同じ (直列では順番によらない)

## 出典

自作。
