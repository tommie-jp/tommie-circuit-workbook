---
book: denken
chapter: 3
id: 3-11
title: Q と帯域幅 — 共振の鋭さを R で変える
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-11 Q と帯域幅 — 共振の鋭さを R で変える

3-5 の RLC 直列共振で、共振の山の**鋭さ**を決めるのは R だ。R が小さいほど山は細く高く、
大きいほど低く広がる。鋭さを 1 つの数で表したのが**尖鋭度 Q** で、山の幅 (帯域幅) は
f0 / Q になる。R を 150 Ω と 470 Ω に替えて、AD の Network (ネットワークアナライザ) で
周波数特性を描き、−3 dB の 2 点の間隔を読む。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| f0 = 1 / (2π√(LC)) | 共振周波数。R によらない |
| Q = ω0 L / R = 1 / (ω0 C R) | 尖鋭度。共振のリアクタンスと R の比 |
| B = f2 − f1 = f0 / Q | 帯域幅。電流 (V_R) が最大の 1/√2 (−3 dB) になる 2 点の間 |
| V_R / V = R / √(R² + (ωL − 1/(ωC))²) | 電源に対する R の電圧の比。共振で 1 (0 dB) |
| f1・f2 で位相 ±45° | −3 dB の点では R とリアクタンスの大きさが等しい |

## 回路図

```circuit
title: 図1 RLC 直列 (R1 は GND の側)
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  M1: voltmeter c3 g3 l=$\mathrm{CH1}$
  L1: inductor c5 c7 100m
  C1: capacitor c8 c10 100n
  R1: resistor c12 g12 150 i=I
  M2: voltmeter c14 g14 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - c1 -- c3 -- c5
  - c7 -- c8
  - c10 -- c12 -- c14
  - g1 -- g3 -- g12 -- g14
notes:
  - text e5 blue: 2 回目は R1 を 470 Ω に替える
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/11-q-bandwidth.svg)

- 3-5 と同じ L1・C1 で、R1 を GND の側に置いた。CH1 は電源の電圧 V、CH2 は R1 の電圧 V_R で、
  どちらも GND 基準。**V_R ÷ R1 が電流なので、CH2 ÷ CH1 の形がそのまま共振曲線になる**
- 1 回目は R1 = 150 Ω、2 回目は 470 Ω
- L1 は 100 mH の小さなコイル (例: Bourns RL622-104K、直流抵抗 235 Ω 以下)。**巻線抵抗 r は R1 と直列に入る**ので、
  見るべき値は r = 0 (理想) と r = 235 Ω (データシートの上限) の 2 通りで出した

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (1 回目 R1 = 150 Ω)
board: half
parts:
  L1: inductor/axial c5 c12 100m
  C1: capacitor/ceramic d12 d17 100n
  R1: resistor c17 c22 150
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, "1-", "2-", W1, "1+", "2+"]
wires:
  - AD.GND -- -t2 black
  - AD.1- -- -t3 black
  - AD.2- -- -t4 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.2+ -- a17 blue
  - a22 -- -t22 black
notes:
  - text: 2 回目は R1 を抜き、470 Ω を同じ c17–c22 に挿す
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/breadboard/11-q-bandwidth.svg)

- 5 列が W1、12 列が L1 と C1 のつなぎ目、17 列が C1 と R1 のつなぎ目、22 列が GND 側
- CH1 は 1+ を 5 列、CH2 は 2+ を 17 列。1− と 2− は GND のレール

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Network | Start 500 Hz、Stop 5 kHz、Scale Log、Steps 201。Amplitude 1 V、Offset 0 V。Reference は Channel 1 |
| Network の表示 | Magnitude (dB) と Phase。Magnitude の縦軸は −30〜0 dB |
| Network のカーソル | 最大 (0 dB) の点と、その −3 dB の 2 点 (f1・f2) |
| Scope (確かめ) | f2 の Sine を Wavegen で出し、CH1・CH2 の Amplitude と Phase を読む |

Network は W1 を掃引し、CH2 ÷ CH1 の大きさと位相を描く。CH1 で割るので、電源の振幅が
少し変わっても曲線の形は変わらない。電流は共振の 150 Ω で最大 6.7 mA で、
この本の目安 10 mA (0-1) に収まる。

f2 (1.72 kHz、R1 = 150 Ω) の画面。V_R は電源の 0.707 倍で、45° 遅れる。

```scope
title: 図3 f2 (1.72 kHz) — V_R (CH2) は 0.707 倍、45° 遅れる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1.715kHz 1V, range: 500mV/div}
ch2: {wave: sine 1.715kHz 0.707V phase -45deg, range: 500mV/div}
measure: [vmax, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/11-q-bandwidth.svg)

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい。端子の読み替えは
[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。

- W1 は FG の OUT (High-Z)。振幅 1 V は、Vpp で入れる機種なら 2 Vpp。CH1 の先端は 5 列 (FG の出力)、
  CH2 の先端は 17 列 (R1 の上)、グランドクリップは 2 本とも GND のレール
- Network の掃引は汎用の計器に無い。**FG の周波数を手で変え、CH2 ÷ CH1 の振幅の比を表にする**。
  共振のまわりは細かく (150 Ω なら 1.4〜1.8 kHz を 20 Hz ずつ)。FG に掃引 (Sweep) があれば、
  1〜3 kHz の対数掃引で CH2 の包絡線を見ると形がつかめる
- **比は必ず CH2 ÷ CH1 で取る。** FG の出力の 50 Ω は CH1 の手前に入るので、比の形 (f0・f1・f2・Q) は
  変わらない。FG の振幅の設定を分母にすると、50 Ω が R1 に足されて Q が下がって見える
  (理想のコイルと 150 Ω で Q = 1000 ÷ 200 = 5.0、r = 235 Ω なら 1000 ÷ 435 = 2.3。計算値)。共振では CH1 が 0.75 V まで下がる
- f1・f2 は、比が 0.707 になる周波数。CH1 と CH2 の位相差が ±45° になる周波数でもあるので、
  2 つで確かめる

## 見るべき値

計算値 (L1 = 100 mH、C1 = 100 nF、f0 = 1.59 kHz、共振のリアクタンス ω0 L = 1000 Ω)。

| 量 | R1 = 150 Ω | R1 = 470 Ω | 150 Ω + r 235 Ω | 470 Ω + r 235 Ω |
| --- | --- | --- | --- | --- |
| Q = ω0 L / (R1 + r) | 6.67 | 2.13 | 2.60 | 1.42 |
| 帯域幅 B = f0 / Q | 239 Hz | 748 Hz | 613 Hz | 1122 Hz |
| f1 (山から −3 dB、+45°) | 1.48 kHz | 1.26 kHz | 1.31 kHz | 1.13 kHz |
| f2 (山から −3 dB、−45°) | 1.72 kHz | 2.01 kHz | 1.93 kHz | 2.25 kHz |
| 共振 (山) の V_R / V | 0 dB | 0 dB | −8.2 dB | −3.5 dB |
| 1 kHz の V_R / V | −16.3 dB | −7.2 dB | −16.8 dB | −8.1 dB |
| 2 kHz の V_R / V | −10.2 dB | −2.9 dB | −12.0 dB | −5.1 dB |
| 共振の電流 (振幅 1 V) | 6.67 mA | 2.13 mA | 2.60 mA | 1.42 mA |

右の 2 列では、−3 dB は 0 dB からではなく**山の高さから** 3 dB 下を読む。

```graph
title: 図4 R が小さいほど山は細い — −3 dB の幅が帯域幅
x: 周波数 Hz log 500..5k
y: V_R / V dB -30..0
lines:
  R1 150 Ω dB: 20*log10(150/sqrt(150^2+(2*pi*x*0.1-1/(2*pi*x*100n))^2))
  R1 470 Ω dB: 20*log10(470/sqrt(470^2+(2*pi*x*0.1-1/(2*pi*x*100n))^2))
  R1 150 Ω + r 235 Ω dB: 20*log10(150/sqrt(385^2+(2*pi*x*0.1-1/(2*pi*x*100n))^2))
notes:
  - level -3dB
  - mark 1.261k
  - mark 1.477k
  - mark 1.715k
  - mark 2.009k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/graph/11-q-bandwidth.svg)

分かること:

- **f0 は R によらず 1.59 kHz。変わるのは山の幅だけ。** R を 3.1 倍にすると Q は 1/3.1、
  帯域幅は 3.1 倍になる
- **−3 dB の点では位相がちょうど ±45°。** そこでは |ωL − 1/(ωC)| = R で、抵抗とリアクタンスが
  同じ大きさになる。Network の位相の表示 (図3 の画面も) で f1・f2 を確かめられる
- Q が大きいと、f0 のわずかなずれで電流が大きく落ちる。ラジオの同調回路は Q を大きくして
  隣の局を落とし、電力系統では共振を避けたい所 (高調波) で Q が大きいと危ない
- 100 mH の小さなコイルは巻線抵抗 r が数百 Ω あり、R1 に足される。r = 235 Ω なら 150 Ω の Q は
  6.67 → 2.60 に下がる (計算値)。**Q の式の R は R1 + r で計算する**。r はテスターで測る。
  V_R / V の山の高さも R1 / (R1 + r) (150 Ω で −8.2 dB) に下がる。Q を大きく見せたいなら、
  r の小さなコイル (大きなコアに太い線を巻いたもの) を使う

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network・Wavegen・Scope の節)。
