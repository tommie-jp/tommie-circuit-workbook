---
book: denken
chapter: 3
id: 3-7
title: 力率改善 — コンデンサを並列にして線電流を減らす
tier: 50
source: 自作
board: BB
---

# 3-7 力率改善 — コンデンサを並列にして線電流を減らす

遅れ力率の負荷 (抵抗 + コイル) にコンデンサを並列に入れると、負荷の有効電力は
そのままで、線路を流れる電流が減る。電験では理論 (交流の電力)・電力 (調相と送電損失)・
機械 (誘導機の力率)・法規 (力率改善コンデンサの容量) のどの科目にも出る単元。

Analog Discovery (AD) の波形発生器を電源にし、2 ch のオシロスコープで受電端の電圧と
線電流を同時に測る。コンデンサを入れる前と後で、力率・線電流・線路の損失を比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| cos θ = R / √(R² + X_L²) | 負荷の力率 (遅れ)。X_L = ωL |
| P = V I cos θ | 有効電力。コンデンサを入れても変わらない |
| Q = Q_L − Q_C、Q_C = ωC V² | 無効電力。コンデンサの進み無効電力が、負荷の遅れ無効電力を打ち消す |
| p = I² r | 線路の損失。線電流の 2 乗で減る |

## 回路図

```circuit
title: 図1 遅れ力率の負荷とコンデンサ
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  Rs: resistor c1 c4 10 i=I
  M2: voltmeter a1 a4 l=$\mathrm{CH2}$
  M1: voltmeter c6 g6 l=$\mathrm{CH1}$
  R1: resistor c8 e8 47
  L1: inductor e8 g8 10m
  S1: switch c10 e10
  C1: capacitor e10 g10 1.5u i=IC
  G1: ground g6
wires:
  - a1 -- c1
  - a4 -- c4
  - c4 -- c6 -- c8 -- c10
  - g1 -- g6 -- g8 -- g10
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/07-power-factor-1.svg)

- V1 は AD の波形発生器 W1。1 kHz、振幅 0.5 V
- Rs (10 Ω) は線電流 I を測るシャント。同時に**線路の抵抗**の役もする。
  CH2 は Rs の両端 (差動入力) で、読みの 1/10 が線電流 (1 mV = 0.1 mA)
- CH1 は受電端の電圧。R1 + L1 が遅れ力率の負荷、S1 を閉じるとコンデンサ C1 が並列に入る
- 試験の図なら Rs の所に電流計、受電端に電力計を描く。ここでは AD の 2 ch で両方を測る

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上の青いレール = GND。コンデンサの枝は溝を渡って下の段へ、下の青いレールも GND
board: half
parts:
  Rs: resistor c5 c10 10
  R1: resistor d10 d15 47
  L1: inductor/axial c15 c20 10m
  S1: switch g10 g13
  C1: capacitor/film h13 h17 1.5u
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 2+, 1+, 2-, 1-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- b5 yellow [h-10]
  - AD.2+ -- a5 blue
  - AD.1+ -- b10 orange [h-10]
  - AD.2- -- a10 white
  - AD.1- -- -t12 black
  - a20 -- -t20 black
  - e10 -- f10 green
  - j17 -- -b17 black
  - -t28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/breadboard/07-power-factor.svg)

- 10 列が受電端。Rs・R1・CH1 (1+)・CH2 (2−) と、下の段へ渡る緑の線が集まる
- CH2 の 2+ と 2− を Rs の両端 (5 列と 10 列) に挿す。**2− を GND につながない**
  (つなぐと受電端が GND に落ちる)
- 28 列の黒い線で上下の GND のレールをつなぐ。S1 を切り替えて C1 を入れたり外したりする

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 0.5 V、Offset 0 V |
| Scope | CH1 = 受電端の電圧 v、CH2 = Rs の電圧 (= 10 Ω × i)。Range は CH1 が 200 mV/div、CH2 が 20 mV/div。Average を 16 回 |
| Math | M1 = C1 × C2 / 10 (瞬時電力 p、単位 W)。Measure で M1 の Average が有効電力 P |
| Measure | CH1 と CH2 の RMS、CH1 に対する CH2 の Phase (位相差 θ。cos θ が力率) |

**電流の上限**: AD3 の波形発生器は 30 mA まで (ひずみなく出せる上限。40 mA でハードウェアの
保護が働く)。この回路の線電流は最大値で 5.9 mA。振幅を上げるなら 0.8 V (9.4 mA) までにして、
この本の目安 10 mA (0-1) に収める。

C なしと C = 1.5 µF の 2 つの画面。電流 (CH2) は数十 mV なので、CH1 と違う V/div にしてある。
赤の線は Math の瞬時電力 p で、その Avg が有効電力 P。Math も CH1・CH2 と同じく計算で描いた理想の線である。

```scope
title: 図3 C なし — 線電流 (CH2) は 5.9 mA で 53° 遅れる。P は Math の Avg
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.462V, range: 200mV/div}
ch2: {wave: sine 1kHz 58.9mV phase -53.2deg, range: 20mV/div}
math: {expr: ch1 * ch2 / 10, unit: W, range: 500uW/div, position: -2div}
measure: [vmax, rms, avg, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/07-power-factor-1.svg)

```scope
title: 図4 C = 1.5 µF — 線電流 (CH2) は 3.6 mA に減り、遅れは 6°。P は変わらない
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.465V, range: 200mV/div}
ch2: {wave: sine 1kHz 35.6mV phase -5.8deg, range: 20mV/div}
math: {expr: ch1 * ch2 / 10, unit: W, range: 500uW/div, position: -2div}
measure: [vmax, rms, avg, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/07-power-factor-2.svg)

### オシロスコープと発振器

AD の CH2 は Rs の両端を差動で挟む (2− が 10 列)。汎用オシロのグランドクリップは大地につながって
いるので、10 列には当てられない ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。Rs の電圧は最大 36〜59 mV で、
受電端 (0.46 V) との差を 8 bit で引くと分解能に埋もれる。そこで 3-6 と同じく **Rs を GND 側
(戻りの線) へ移す** (図5)。負荷の枝もコンデンサの枝も Rs を通って戻るので、Rs は線電流を測り、
線路の抵抗の役もそのまま。

```circuit
title: 図5 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 i1 l=$\mathrm{FG}$
  M1: voltmeter c3 i3 l=$\mathrm{CH1}$
  R1: resistor c5 e5 47
  L1: inductor e5 g5 10m
  S1: switch c8 e8
  C1: capacitor e8 g8 1.5u i=IC
  Rs: resistor g10 i10 10 i=I
  M2: voltmeter g12 i12 l=$\mathrm{CH2}$
  G1: ground i1
wires:
  - c1 -- c3 -- c5 -- c8
  - g5 -- g8 -- g10 -- g12
  - i1 -- i3 -- i10 -- i12
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/07-power-factor-2.svg)

- W1 は FG の OUT (High-Z)。CH1 の先端は FG の出力 (受電端の上)、CH2 の先端は Rs の上、
  グランドクリップは 2 本とも GND
- ブレッドボードは図2 から次の 3 か所を変える。Rs を 5〜10 列から抜いて FG の芯を 10 列へ挿す。
  20 列から上の GND のレールへの黒い線を外し、Rs を 20〜25 列 (d20–d25) に挿して、25 列から上の GND の
  レールへ黒い線を渡す。C1 の戻りの黒い線 (j17 から下の GND のレール) を外し、j17 から 20 列の上の段 (a20) へ
  黒以外の線を渡す (GND ではなくなるため)。CH1 の先端は 10 列、CH2 の先端は 20 列
- 受電端の電圧は Math の CH1 − CH2。有効電力は、Math の C1 × C2 / 10 の平均 (負荷と Rs を合わせた電力)
  から Rs の損失 (CH2 の RMS² ÷ 10 Ω) を引く。掛け算の無い機種は、CH1 と CH2 の RMS と位相差から
  P = V I cos φ を出して、同じく Rs の損失を引く
- CH1 と CH2 の位相差は Rs を含んだ角度になる。C なしで 48°、1.5 µF で 5°、2.2 µF で −23° (計算値)。
  受電端の力率 (表の 0.60・0.99・0.90) は cos θ = P / (V I) で出す。V は Math (CH1 − CH2) の RMS
- FG の出力の 50 Ω で、振幅 0.5 V の設定のままだと線電流は C なしで 4.0 mA、1.5 µF で 2.6 mA、
  2.2 µF で 3.0 mA に下がる (計算値)。**S1 を切り替えるたびに、CH1 の振幅が 0.50 V になるよう
  FG の振幅を合わせ直す** (設定は約 0.73 V・0.68 V・0.68 V)。そうすれば見るべき値の表がそのまま使える

## 見るべき値

計算値。10 mH の小さなコイルは巻線抵抗 (数 Ω〜数十 Ω) を持ち、その分だけ R が大きく
見えて力率は計算より良くなる。巻線抵抗をテスターで測り、R1 に足して計算し直す。

| 測る所 | C なし | C = 1.5 µF | C = 2.2 µF |
| --- | --- | --- | --- |
| 力率 (受電端) | 0.60 遅れ | 0.99 遅れ | 0.90 進み |
| 線電流の最大値 (CH2 ÷ 10 Ω) | 5.9 mA | 3.6 mA | 3.9 mA |
| 負荷の有効電力 P | 0.82 mW | 0.82 mW | 0.82 mW |
| 線路 Rs の損失 | 0.17 mW | 0.064 mW | 0.077 mW |
| 受電端の電圧の最大値 (CH1) | 0.462 V | 0.465 V | 0.464 V |

分かること:

- **P は変わらない。** コンデンサは有効電力を使わない。減るのは無効電力と線電流
- **線電流が 6 割になると、線路の損失は 4 割弱になる** (電流の 2 乗)。受電端の電圧も
  わずかに上がる (線路の電圧降下が減る)。送電線の目で見直すのが 12-3
- **入れすぎると進み力率になり、電流がまた増える** (2.2 µF)。力率をちょうど 1 にする
  容量は C = X_L / {ω (R² + X_L²)} ≒ 1.6 µF

## 出典

自作。
