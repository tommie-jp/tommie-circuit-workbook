---
book: denken
chapter: 3
id: 3-5
title: RLC 直列共振 — 共振周波数で電流が最大
tier: 50
source: 自作
board: BB
---

# 3-5 RLC 直列共振 — 共振周波数で電流が最大

コイルとコンデンサを直列にすると、ある周波数で**リアクタンスがちょうど
打ち消し合い**、回路はまるで抵抗だけのように振る舞う。この周波数
(共振周波数) で電流が最大になることを、周波数を掃引して確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| f0 = 1 / (2π√(LC)) | 共振周波数。X_L = X_C になる周波数 |
| Z_min = R | 共振時のインピーダンスは R だけ (リアクタンスが打ち消し合う) |
| I_max = V / R | 共振時の電流は最大で、抵抗だけで決まる |

## 回路図

```circuit
title: 図1 RLC 直列
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  R1: resistor c1 c3 150
  L1: inductor c3 c5 100m
  C1: capacitor c5 c7 100n
  M1: voltmeter a1 a3 l=$\mathrm{CH1}$
  M2: voltmeter e3 e7 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - a1 -- c1
  - a3 -- c3
  - c3 -- e3
  - c7 -- e7 -- g7
  - g1 -- g7
```

- CH1 が R1 の両端 (÷ R で電流になる)、CH2 が L1 + C1 をまとめた両端
  (共振ではここが 0 に近づく)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 150
  L1: inductor/axial d10 d15 100m
  C1: capacitor/ceramic c15 c20 100n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, "1+", "1-", "2+", "2-"]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 blue [h10]
  - AD.1- -- a10 orange
  - AD.2+ -- b10 white [h10]
  - AD.2- -- b20 green [h-10]
  - a20 -- -t20 black
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、Amplitude 1 V。周波数を 500 Hz〜2 kHz の間で振る |
| Scope | CH1・CH2 とも DC 結合。Measure で CH1 の Amplitude (÷ R1 で電流) を読む |

```scope
title: 図3 共振 (1.59 kHz) — V_R (CH1) が 1 V、L + C (CH2) は 0 V
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1.59kHz 1V, range: 500mV/div}
ch2: {wave: dc 0V, range: 500mV/div}
measure: [vmax, freq]
```

### オシロスコープと発振器

AD の CH1 は R1 の両端を差動で挟む (1− が 10 列)。汎用オシロのグランドクリップは大地につながって
いるので、10 列には当てられない ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。共振から外れると V_R は 50 mV ほど
(500 Hz) まで下がり、CH1 − CH2 で引くと 8 bit の分解能に埋もれる。そこで **R1 を GND 側へ移し**
(図4)、電流を 1 本の先端で直に読む。直列なので並べる順を変えても電流は変わらない。

```circuit
title: 図4 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{FG}$
  M2: voltmeter c3 g3 l=$\mathrm{CH2}$
  L1: inductor c3 c5 100m
  C1: capacitor c5 c7 100n
  R1: resistor c9 g9 150 i=I
  M1: voltmeter c12 g12 l=$\mathrm{CH1}$
  G1: ground g1
wires:
  - c1 -- c3
  - c7 -- c9 -- c12
  - g1 -- g3 -- g9 -- g12
```

- W1 は FG の OUT (High-Z)。振幅 1 V は Vpp で入れる機種なら 2 Vpp。CH1 の先端は R1 の上
  (CH1 ÷ 150 Ω が電流で、表と同じ読み方)、CH2 の先端は FG の出力、グランドクリップは 2 本とも GND。
  L1 + C1 の電圧は Math の CH2 − CH1
- ブレッドボードは図2 から、R1 を 5〜10 列から抜いて FG の芯を 10 列へ挿す。20 列から GND のレールへの
  黒い線を外し、R1 を 20〜25 列 (d20–d25) に挿して、25 列から GND のレールへ黒い線を渡す。
  CH1 の先端は 20 列、CH2 の先端は 10 列
- FG の出力の 50 Ω が R1 に足されて 200 Ω になり、共振の山が低く、なだらかになる。振幅の設定を
  変えないときの電流は、f0 で 5.0 mA (CH1 は 0.75 V)、1.3 kHz で 2.20 mA、2.0 kHz で 1.99 mA、
  500 Hz と 800 Hz は表とほぼ同じ (計算値)。共振のときの V_L と V_C は 5.0 V
- 表と同じ値にするなら、周波数を変えるたびに CH2 (FG の出力) の振幅が 1.00 V になるよう FG の振幅を
  合わせ直す (f0 では設定が約 1.33 V になる)

## 見るべき値

計算値 (R = 150 Ω、L = 100 mH、C = 100 nF、振幅 1 V)。共振周波数
f0 = 1 / (2π√(0.1 × 100×10⁻⁹)) ≈ **1.59 kHz**。

| 周波数 | 電流の振幅 (CH1 ÷ 150 Ω) | 備考 |
| --- | --- | --- |
| 500 Hz | 0.35 mA | 共振より低い (C が支配的) |
| 800 Hz | 0.67 mA | |
| 1.3 kHz | 2.30 mA | |
| **1.59 kHz (f0)** | **6.67 mA (最大)** | X_L = X_C = 1000 Ω で打ち消し合う |
| 2.0 kHz | 2.06 mA | 共振より高い (L が支配的) |

共振時: CH1 (V_R) = 1.00 V (= 電源電圧そのもの)、CH2 (V_L+C) ≈ 0 V。
V_L = V_C = I × X_L = 6.67 mA × 1000 Ω = 6.67 V (電源電圧の 1 V よりずっと
大きい。L と C の電圧が電源電圧を超える現象は 3-16 で扱う)。

分かること:

- **共振周波数で電流が最も大きくなる。** 低い周波数では C のリアクタンスが、
  高い周波数では L のリアクタンスが電流を妨げる
- **共振では L と C の電圧が互いに逆位相でほぼ打ち消し合う** (CH2 がほぼ 0 に
  なる)。個々の電圧 (6.67 V) は大きいのに、足し合わせると小さくなるのは
  ベクトル (フェーザ) で考える交流ならでは
- 巻線抵抗のある実物のコイルでは、R がもう少し大きくなるぶん、電流の
  ピークは表より少しなだらかになる

## 出典

自作。
