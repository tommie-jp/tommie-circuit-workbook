---
book: denken
chapter: 4
id: 4-8
title: 二電力計法 — 2 つの読みの和が三相電力
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 4-8 二電力計法 — 2 つの読みの和が三相電力

三相 3 線式の電力は、電力計 **2 つ**で測れる。1 つ目は a 線の電流と a-c の線間電圧、
2 つ目は b 線の電流と b-c の線間電圧を掛けて平均する。1 つずつの読みは負荷の力率で大きく
違うのに、**2 つの和は必ず三相電力になる**。4-5 と同じ C + R の Y 負荷 (N は浮かせる) で、
AD の Math を電力計の代わりにして確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| P = P_1 + P_2 | 二電力計法。3 線式なら負荷の形 (Y・Δ・不平衡) によらない |
| P_1 = V I cos(θ + 30°)、P_2 = V I cos(θ − 30°) | 平衡・進み力率 (この題の相順) の読み。V・I は線間電圧・線電流の実効値 |
| P_1 + P_2 = √3 V I cos θ | 2 つを足すと 4-5 の式になる |
| P_2 − P_1 = V I sin θ | 差から無効電力 (√3 倍で三相の Q) と力率が出る |
| θ = 60° で P_1 = 0 | 力率 0.5 より悪いと片方は負になる |

## 回路図

```circuit
title: 図1 二電力計法の 1 つ目 (a 線の電流と a-c の線間電圧)
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 e1 l=$\mathrm{W1}$
  G1: ground e1
  V2: sine i1 k1 l=$\mathrm{W2}$
  G2: ground k1
  R1: resistor c3 e3 10k
  R2: resistor i4 g4 10k
  U1: opamp f8 +down TL071
  G3: ground g6
  Rf: resistor d7 d10 10k
  M1: voltmeter c12 f12 l=$\mathrm{CH1}$
  Ca: capacitor c14 c16 220n
  Ra: resistor c18 c20 1k
  M2: voltmeter a18 a20 l=$\mathrm{CH2}$
  Cc: capacitor f14 f16 220n
  Rc: resistor f18 f20 1k
  Cb: capacitor i14 i16 220n
  Rb: resistor i18 i20 1k
wires:
  - c1 -- c3 -- c12 -- c14
  - i1 -- i4 -- i14
  - e3 -- e4 -- e7
  - e4 -- g4
  - d7 -- e7
  - e7 |- U1.-
  - g6 |- U1.+
  - d10 -- f10
  - U1.out -- f10 -- f12 -- f14
  - c16 -- c18
  - f16 -- f18
  - i16 -- i18
  - a18 -- c18
  - a20 -- c20
  - c20 -- c22 -- f22 -- i22
  - f20 -- f22
  - i20 -- i22
notes:
  - text b9: 1 相目
  - text g11: 3 相目
  - text h9: 2 相目
  - text d22a3: N
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/circuit/08-two-wattmeter-1.svg)

```circuit
title: 図2 試験の図の形 (電力計 2 つ、電圧コイルは c 線へ)
style:
  standard: jis
  pitch: 1.2
parts:
  PA: port c1
  PB: port f1
  PC: port i1
  WA: wattmeter c3 c5 l=$\mathrm{P_1}$
  WB: wattmeter f6 f8 l=$\mathrm{P_2}$
  ZA: resistor c10 c12 l=$\mathrm{Z}$
  ZB: resistor f10 f12 l=$\mathrm{Z}$
  ZC: resistor i10 i12 l=$\mathrm{Z}$
wires:
  - c1 -- c3
  - f1 -- f6
  - i1 -- i10
  - c5 -- c10
  - f8 -- f10
  - c12 -- c14 -- f14 -- i14
  - f12 -- f14
  - i12 -- i14
notes:
  - line c5 i5 blue
  - line f8 i8 blue
  - text d5a3: 電圧コイル (a-c)
  - text g8a3: 電圧コイル (b-c)
  - text b14: N
  - text b1: a 線
  - text e1: b 線
  - text h1: c 線
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/circuit/08-two-wattmeter-2.svg)

- 図1 の左は 4-1 の三相電源。負荷は 4-5 と同じ C (220 nF) + R (1 kΩ) の Y で、**N はどこにもつながない** (3 線式)
- CH1 は a 線 (1 相目) と c 線 (3 相目) の間の線間電圧 (差動)。CH2 は Ra の両端 (差動) で、÷ 1 kΩ が a 線の電流。
  Math の C1 × C2 / 1000 の平均が 1 つ目の電力計の読み P_1
- 2 つ目 (P_2) は、CH1 を b 線と c 線の間、CH2 を Rb の両端に付け替えて同じように測る
- 図2 は試験の図の形。電力計は電流コイルを線に直列に、電圧コイル (青の線) を c 線との間に入れる

## 実体配線図

```breadboard
title: 図3 ブレッドボードと Analog Discovery (1 つ目の電力計)
# 上のブロック: TL071 の入力側と R1・R2、右に 3 相の C + R。下のブロック: 出力側と Rf、g・h・j 行で 3 相を右へ運ぶ
board: full
parts:
  R1: resistor b17 b21 10k
  R2: resistor c25 c21 10k
  Rf: resistor i21 i14 10k
  U1: dip8 @ f13 r180 TL071
  Ca: capacitor/film b35 b38 220n
  Ra: resistor d38 d41 1k
  Cb: capacitor/film b42 b45 220n
  Rb: resistor d45 d48 1k
  Cc: capacitor/film b49 b52 220n
  Rc: resistor d52 d55 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V-, W1, V+, GND, W2, 1+, 2+, 2-, 1-]
wires:
  - AD.V+ -- +t23 red
  - AD.GND -- -t24 black
  - AD.V- -- a13 purple
  - AD.W1 -- a17 yellow
  - AD.1+ -- a35 yellow
  - AD.W2 -- a25 orange
  - a14 -- -t14 black
  - d15 -- d21 green
  - e21 -- f21 green
  - +t2 -- +b2 red
  - j15 -- +b15 red
  - e17 -- f17 yellow
  - g17 -- g35 yellow
  - e25 -- f25 orange
  - j25 -- j42 orange
  - h14 -- h49 blue
  - f35 -- e35 yellow
  - f42 -- e42 orange
  - f49 -- e49 blue
  - a41 -- a48 green
  - c48 -- c55 green [v-15, h140]
  - AD.2+ -- a38 pink
  - AD.1- -- a49 blue
  - AD.2- -- c41 green
notes:
  - text small: 35・42・49 列が a・b・c 線。41・48・55 列を束ねた緑の線が N (GND につながない)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/breadboard/08-two-wattmeter.svg)

- 三相電源と C + R は 4-5 と同じ。R の右の端 (41・48・55 列) は a 行と c 行の緑の線で束ねて N にし、GND にはつながない。
- 1 つ目: 1+ を 35 列 (a 線)、1− を 49 列 (c 線)、2+ を 38 列 (Ca と Ra のつなぎ目)、2− を 41 列 (c41、N)
- 2 つ目: 1+ を 42 列 (a42、b 線)、2+ を 45 列 (a45、Cb と Rb のつなぎ目) に挿し替える。1− と 2− はそのまま
- **1− と 2− を GND のレールにつながない** (つなぐと c 線か N が GND に落ちる)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Phase 0°。W2: 同じく Phase −120° |
| Supplies | V+ = 5 V、V− = −5 V |
| Scope | CH1 = 線間電圧 (差動、1 V/div)、CH2 = R の電圧 (差動、500 mV/div)。Average を 16 回 |
| Math | M1 = C1 × C2 / 1000 (単位 W、500 µW/div) |
| Measure | CH1・CH2 の Amplitude、CH1 に対する CH2 の Phase、M1 の Average |

```scope
title: 図4 1 つ目 — 電流 (CH2) は線間電圧 (CH1) より 65.9° 進み、P_1 = 0.287 mW
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1.7321V, range: 1V/div}
ch2: {wave: sine 1kHz 0.8102V phase 65.9deg, range: 500mV/div}
math: {expr: ch1 * ch2 / 1000, unit: W, range: 500uW/div, position: -1div}
measure: [vmax, avg, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/scope/08-two-wattmeter-1.svg)

```scope
title: 図5 2 つ目 — 電流 (CH2) は線間電圧 (CH1) より 5.9° 進み、P_2 = 0.698 mW
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1.7321V, range: 1V/div}
ch2: {wave: sine 1kHz 0.8102V phase 5.9deg, range: 500mV/div}
math: {expr: ch1 * ch2 / 1000, unit: W, range: 500uW/div, position: -1div}
measure: [vmax, avg, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/scope/08-two-wattmeter-2.svg)

### オシロスコープと発振器

発振器・電源の読み替えは 4-1 と同じ ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。AD 版は 1− を c 線、2− を N に挿す差動の測り方で、
汎用オシロのグランドクリップはどちらにも当てられない (c 線に当てれば OP アンプの出力を短絡し、N に当てれば N が GND に落ちる)。

**N を GND につなぎ、線間電圧を 2 回に分けて掛ける**。平衡なので N に電流は流れず (4-4)、つないでも読みは変わらない。
N が GND なら R の上の端 (38・45 列) を 1 本の先端で読めば相電流になる。そのうえで

P_1 = 平均 (v_a × i_a) − 平均 (v_c × i_a)、 P_2 = 平均 (v_b × i_b) − 平均 (v_c × i_b)

と、線間電圧の引き算を平均の引き算に移す (掛け算と平均は引き算と入れ替えられる)。

| 回 | CH1 の先端 | CH2 の先端 | Math C1 × C2 / 1000 の平均 (計算値) |
| --- | --- | --- | --- |
| 1 | 35 列 (v_a) | 38 列 (Ra の上) | 0.328 mW |
| 2 | 49 列 (v_c) | 38 列 | 0.042 mW → P_1 = 0.328 − 0.042 = 0.287 mW |
| 3 | 42 列 (v_b) | 45 列 (Rb の上) | 0.328 mW |
| 4 | 49 列 (v_c) | 45 列 | −0.370 mW → P_2 = 0.328 + 0.370 = 0.698 mW |

- N を GND にするには、41 列 (b41) から GND のレールへ黒い線を渡す。グランドクリップは 2 本とも GND のレール
- 4 ch のオシロなら、v_a − v_c を Math で作って 1 回で掛けられる機種もある
- FG の出力の 50 Ω で電圧は 3.7 % 下がり、電力は 7 % 下がる (4-5 と同じ)。CH1 の振幅を 1.00 V に合わせ直す

## 見るべき値

計算値 (相電圧の振幅 1 V、線間電圧の振幅 1.732 V (実効値 1.225 V)、線電流の振幅 0.810 mA (実効値 0.573 mA)、
θ = 35.9° 進み)。C を 100 nF にした場合 (θ = 57.9°) も並べる。

| 量 | C = 220 nF | C = 100 nF |
| --- | --- | --- |
| 力率 cos θ | 0.810 | 0.532 |
| 1 つ目: CH1 に対する CH2 の Phase | +65.9° | +87.9° |
| **P_1** (M1 の Average) | **0.287 mW** | **0.017 mW** |
| 2 つ目: CH1 に対する CH2 の Phase | +5.9° | +27.9° |
| **P_2** (M1 の Average) | **0.698 mW** | **0.407 mW** |
| P_1 + P_2 | 0.985 mW | 0.425 mW |
| √3 V I cos θ (4-5 の式) | 0.985 mW | 0.425 mW |
| 相電流 (CH2 の振幅) | 0.810 V | 0.532 V |

分かること:

- **2 つの読みは大きく違うのに、和は三相電力に等しい。** θ = 35.9° では 0.29 と 0.70、θ = 57.9° では
  片方がほぼ 0 (0.017 mW) になる。θ が 60° を越えると P_1 は負になり、和は「差」になる
- 線間電圧と線電流の角は θ ± 30°。**1 つずつの読みは力率の電力ではない**。和を取って初めて意味を持つ
- 差 P_2 − P_1 = V I sin θ (0.41 mW) の √3 倍 0.71 mvar が三相の無効電力 (4-5 の表と同じ)
- 電力計が 2 つで済むのは、3 線式で i_a + i_b + i_c = 0 だから。中性線に電流の流れる 4 線式の不平衡では成り立たない

## AD3 を 2 台使う — 電力計 2 つを同時に

AD3 を 2 台使うと、オシロの入力が 4 ch になる。2 台の配線・GND の共通化・T2 での同期は
[4-1 の「AD3 を 2 台使う」](01-three-phase-source.md) と同じ。W1・W2 と Supplies は AD-A だけが出し、
AD-B は測るだけ (Wavegen も Supplies も使わない)。
2 台とも、片方が 1 つの電力計になる。**2 つの読み P_1・P_2 を同時に見て、足せる。**

| 台 | CH1 | CH2 | Math |
| --- | --- | --- | --- |
| AD-A (1 つ目) | a-c の線間電圧 (差動) | a 線の R の電圧 (差動) | M1 = C1 × C2 / 1000 |
| AD-B (2 つ目) | b-c の線間電圧 (差動) | b 線の R の電圧 (差動) | M1 = C1 × C2 / 1000 |

計算値 (C = 220 nF)。

| 台 | 測る所 | 期待する値 |
| --- | --- | --- |
| AD-A | CH1 に対する CH2 の Phase、M1 の Average | +65.9°、**P_1 = 0.287 mW** |
| AD-B | CH1 に対する CH2 の Phase、M1 の Average | +5.9°、**P_2 = 0.698 mW** |
| 2 台の和 | P_1 + P_2 | 0.985 mW (= √3 V I cos θ) |

- 差動の入力は、AD-A は 1 つ目の測り方 (1+ を a 線、2+ を Ca と Ra のつなぎ目)、AD-B は 2 つ目の測り方
  (1+ を b 線、2+ を Cb と Rb のつなぎ目) と同じ穴を使う。1− と 2− は、2 台とも c 線と N の点で、
  **同じ穴に 2 本は挿せない**ので、同じ列の別の行 (同じネット) を使う
- 2 台の 1−・2− は GND のレールには挿さない。2 台の GND 端子だけを GND のレールにつなぐ
- Math は各台の中で完結するので、2 台の同期 (T2) は要らない。**P_1 と P_2 を足すのは手で** (画面の値の和)
- 実機では確かめていない (計算値)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。
