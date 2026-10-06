---
book: circuits
chapter: 9
id: 9-18
title: RC-CR で 90° を作る — 1 本の正弦から I と Q
tier: 100
source: 自作
board: BB
---

# 9-18 RC-CR で 90° を作る — 1 本の正弦から I と Q

位相が **90° ずれた 2 本の正弦**を、ひと組で **I と Q** と呼ぶ。I は in-phase (同相)、Q は quadrature (直交、90° ずれ) の頭文字。
9-19〜9-24 の I/Q の回路は、どれもこの 2 本から始まる。この題では、抵抗 2 本とコンデンサ 2 個だけで、
1 本の正弦から I と Q を作る。Analog Discovery 3 (AD3) のスコープで、時間の波形と XY の円を見る。

**RC-CR の回路**は、信号源から 2 本の枝を出す。

- **低域側 (RC)**: R1 を直列に通し、C2 で GND に落とす。出力は入力より**遅れる**
- **高域側 (CR)**: C1 を直列に通し、R2 で GND に落とす。出力は入力より**進む**

R と C を両方の枝で同じ値 (680 Ω・470 pF) にすると、2 つの出力の比は次の式になる。

V<sub>高域</sub> / V<sub>低域</sub> = jωRC = j × (f / f<sub>c</sub>)、f<sub>c</sub> = 1 / (2πRC)

j は位相を 90° 進める印だ。だから**位相の差は、どの周波数でもちょうど 90°** になる。
周波数で変わるのは**大きさの比 f / f<sub>c</sub> だけ**で、2 本の振幅がそろうのは f = f<sub>c</sub> のときに限る。

- f<sub>c</sub> = 1 / (2π × 680 Ω × 470 pF) **= 497.9 kHz**。この題の W1 は **498 kHz** にする
- 498 kHz では、低域側が −45°、高域側が +45° で、どちらも入力の 0.707 倍。**差が 90° で振幅も同じ**
- 300 kHz では低域側 0.856 倍・高域側 0.516 倍、800 kHz では低域側 0.528 倍・高域側 0.849 倍。
  振幅は大きく違うが、**位相の差は 90° のまま** (LTspice でも 300 k・498 k・800 kHz の 3 点とも 90.0°)

この題では、**高域側 (+45°) を I、低域側 (−45°) を Q** と呼ぶ。Q は I より 90° 遅れる。
I を cos、Q を sin と見るのと同じ向きだ。9-19 からも同じ名前で使う。

**90° の回路は、決まった 1 つの周波数に使う。** 振幅がそろうのは f<sub>c</sub> の近くだけなので、
周波数が動く信号 (受けたい電波 RF) をこの回路に通すと、I と Q の振幅がずれる。
受信機では、**周波数の決まった局部発振 (LO) のほうを 90° ずらす**。9-19 では、この題の回路をそのまま LO の 90° に使う。

## 回路図

```circuit
title: 図1 RC-CR で W1 から I (高域側 +45°) と Q (低域側 -45°) を作る
parts:
  W1: sine d1 f1 l=$\mathrm{W1}$
  G1: ground f1
  R1: resistor d2 d4 680
  C2: capacitor d6 f6 470p
  M2: voltmeter d9 f9 l=$\mathrm{CH2}$
  C1: capacitor b2 b4 470p
  R2: resistor b11 f11 680
  M1: voltmeter b13 f13 l=$\mathrm{CH1}$
wires:
  - b1 -- d1
  - b1 -- b2
  - d1 -- d2
  - d4 -- d6 -- d9
  - b4 -- b11 -- b13
  - f1 -- f6 -- f9 -- f11 -- f13
notes:
  - text a12f0 small center: I (+45°)
  - text c7f5 small center: Q (-45°)
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/18-rc-cr-quadrature.svg)

## 実体配線図

```breadboard
title: 図2 W1 は 10 列、Q は 6 列、I は 14 列
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, 2-, 2+, W1, 1+, 1-]
  C2: capacitor/ceramic d3 d6 470p
  R1: resistor b6 b10 680
  C1: capacitor/ceramic c10 c14 470p
  R2: resistor d14 d17 680
wires:
  - AD.GND -- -t1 black
  - AD.2- -- -t2 black
  - a3 -- -t3 black
  - AD.2+ -- a6 blue
  - AD.W1 -- a10 yellow
  - AD.1+ -- a14 orange
  - a17 -- -t17 black
  - AD.1- -- -t16 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/18-rc-cr-quadrature.svg)

- 10 列の真ん中に W1 (黄) を挿す。**左へ R1 (b6〜b10) で Q の 6 列、右へ C1 (c10〜c14) で I の 14 列**へ分ける。
  図1 の低域側を左、高域側を右に置いた形だ
- **Q の 6 列**: CH2 の 2+ (青) を a6 に挿す。C2 (d3〜d6) で 3 列へ渡し、a3 の黒い線で上の − レールへ落とす
- **I の 14 列**: CH1 の 1+ (橙) を a14 に挿す。R2 (d14〜d17) で 17 列へ渡し、a17 の黒い線で上の − レールへ落とす
- AD3 の GND・1−・2− (黒) は上の − レールへ。電源 (V+) は使わない。受け身の部品だけの回路なので、電源のレールは要らない
- 498 kHz はブレッドボードの範囲 (3 MHz 以下) に収まる。それでも列どうしの浮遊容量 (数 pF) は 470 pF に効くので、
  **部品のリードは短く切り、AD3 の線の近くにまとめて挿す**。I と Q の 2 つの節点に同じだけ付く容量なら、位相の差は 90° のまま
  (下の「見るべき値」)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1・R2 | 抵抗 (1/4 W、±5 % か ±1 %) | 680 Ω (青灰茶) |
| C1・C2 | セラミックコンデンサ (NP0/C0G) | 470 pF (471)、50 V |
| W1 | 信号発生器 (AD3 の Wavegen W1。出力は約 0 Ω) | 正弦波 498 kHz、1 V<sub>pp</sub> |
| — | 計器 | AD3 の Scope (CH1 = I、CH2 = Q) |

- R と C は 2 組とも同じ値にそろえる。そろっていれば、どの周波数でも位相の差は 90° になる (説明の式)。
  そろっていないと、差が 90° からずれる。たとえば C1 だけが 5 % 大きいと、498 kHz で I が 0.724 倍・Q が 0.707 倍になり、差は 88.6° になる (計算値)
- 位相の差を正確にしたいなら、±1 % の金属皮膜の抵抗と、温度で値の動かない NP0 (C0G) のセラミックコンデンサを使う

## 計器の設定

計器は AD3。Wavegen で 498 kHz を作り、Scope の 2 ch で I と Q を同時に見る。498 kHz は Scope の範囲 (10 MHz 以下) に入る。

| 計器 | 設定 |
| --- | --- |
| Wavegen W1 | Sine、498 kHz、振幅 0.5 V (1 V<sub>pp</sub>)、オフセット 0 V |
| Scope (時間) | CH1 = 1+ を I (14 列)、CH2 = 2+ を Q (6 列)。1−・2− は GND。どちらも 200 mV/div、DC 結合。500 ns/div (2.5 周期)。トリガは CH1 の立ち上がり 0 V |
| Scope (XY) | 表示を XY にし、X = CH1 (I)、Y = CH2 (Q)。どちらも 200 mV/div |
| Measurements | CH1・CH2 の Vpp と Freq、CH2 の Phase (CH1 に対する) |

- 出力 0.707 V<sub>pp</sub> は 200 mV/div で 3.5 目盛。100 mV/div にすると 498 kHz では 7 目盛に広がるが、
  300 kHz の Q (0.856 V<sub>pp</sub>) が画面から切れる。周波数を変えて比べるので、3 枚とも 200 mV/div にそろえた
- 周波数を 300 kHz・800 kHz に変えるときは W1 の周波数だけを変える。回路も振幅もそのまま

## 計器の画面

計算値。498 kHz では I も Q も入力の 0.707 倍 (0.707 V<sub>pp</sub>)。I は入力より 45° 進み、Q は 45° 遅れる。

```scope
title: 図3 498 kHz — Q (CH2) は I (CH1) より 1/4 周期 (0.502 µs) 遅れ、振幅は同じ
time: 500ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 498kHz 0.707Vpp phase 45deg, range: 200mV/div}
ch2: {wave: sine 498kHz 0.707Vpp phase -45deg, range: 200mV/div}
cursors: [0, 502ns]
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/18-rc-cr-quadrature-1.svg)

- カーソルの X1 は CH1 (I) が 0 V を上へ横切る点 (トリガ)、X2 は CH2 (Q) が 0 V を上へ横切る点。
  差は **0.502 µs = 498 kHz の周期 2.008 µs の 1/4**。角度にすると 0.502 ÷ 2.008 × 360° = 90°
- Measurements の CH2 の Phase は **−90°** (負は遅れ)。Vpp は CH1・CH2 とも 0.707 V

XY にすると、90° ずれた同じ大きさの 2 本は**円**を描く (2-5 と同じ)。I = cos θ、Q = sin θ なら I² + Q² = 一定だからだ。

```scope
title: 図4 498 kHz の XY — 振幅がそろうので円
view: xy
ch1: {wave: sine 498kHz 0.707Vpp phase 45deg, range: 200mV/div}
ch2: {wave: sine 498kHz 0.707Vpp phase -45deg, range: 200mV/div}
xy: ch1 ch2
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/18-rc-cr-quadrature-2.svg)

```scope
title: 図5 300 kHz の XY — 90° のまま Q が大きく、縦長の楕円
view: xy
ch1: {wave: sine 300kHz 0.516Vpp phase 58.9deg, range: 200mV/div}
ch2: {wave: sine 300kHz 0.856Vpp phase -31.1deg, range: 200mV/div}
xy: ch1 ch2
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/18-rc-cr-quadrature-3.svg)

```scope
title: 図6 800 kHz の XY — 90° のまま I が大きく、横長の楕円
view: xy
ch1: {wave: sine 800kHz 0.849Vpp phase 31.9deg, range: 200mV/div}
ch2: {wave: sine 800kHz 0.528Vpp phase -58.1deg, range: 200mV/div}
xy: ch1 ch2
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/18-rc-cr-quadrature-4.svg)

- 図5・図6 の楕円は、**軸が画面の縦と横にそろう** (傾かない)。位相の差がちょうど 90° のとき、楕円は傾かない。
  差が 90° からずれると、楕円は右上か左上へ傾く。傾きがあれば、R か C の値が 2 組でそろっていない
- 楕円の幅と高さの比が、振幅の比 f / f<sub>c</sub> だ。300 kHz では 0.516 : 0.856 (= 0.60)、800 kHz では 0.849 : 0.528 (= 1.61)
- XY の画面からは、円が右回りか左回りか (Q が遅れか進みか) は読めない。符号は図3 の時間の画面で読む

## 見るべき値

計算値 (LTspice でも同じ値)。W1 は 1 V<sub>pp</sub>、出力 ≈ 0 Ω。

| 確かめること | 期待する値 |
| --- | --- |
| f<sub>c</sub> = 1 / (2πRC) | 497.9 kHz (680 Ω・470 pF) |
| 498 kHz の I (CH1) と Q (CH2) の Vpp | どちらも 0.707 V (入力の 0.707 倍) |
| 498 kHz の Q の遅れ (図3 のカーソル) | 0.502 µs (1/4 周期)、Phase −90° |
| 498 kHz の XY (図4) | 円 (直径 0.707 V、200 mV/div で 3.5 目盛) |
| 300 kHz の I と Q | I 0.516 V<sub>pp</sub>、Q 0.856 V<sub>pp</sub>、Phase −90° (縦長の楕円、図5) |
| 800 kHz の I と Q | I 0.849 V<sub>pp</sub>、Q 0.528 V<sub>pp</sub>、Phase −90° (横長の楕円、図6) |
| 位相の差の周波数による変化 | 無い (どの周波数でも 90°)。変わるのは振幅の比 f / f<sub>c</sub> だけ |
| I と Q を入れ替えて挿す | Phase が +90° になる (Q が進む)。円は同じ |
| 50 Ω の信号発生器にする | 498 kHz で I・Q とも 0.657 V<sub>pp</sub> に下がる。位相の差は 90° のまま (計算値) |
| I と Q に同じ容量が付く (計器の入力・浮遊容量) | 仮に 24 pF ずつなら、498 kHz で I・Q とも 0.689 V<sub>pp</sub>、差は 90° のまま (計算値)。片側だけだと差がずれる |
| C1 だけ 5 % 大きい | 498 kHz で差 88.6°、I 0.724 V<sub>pp</sub>・Q 0.707 V<sub>pp</sub> (計算値)。XY の円がわずかに傾いた楕円になる |

- **90° はどの周波数でも保たれる**のに、**振幅がそろうのは f<sub>c</sub> だけ**。これが 1 つ目の要点だ
- だから、受信機では周波数の決まった LO を 90° ずらす (9-19)。この題の回路の 680 Ω と 470 pF は、9-19〜9-21 の LO の 498 kHz にそのまま使う
- 信号源の出力抵抗と、2 つの節点に**等しく**付く負荷は、振幅を下げるが位相の差を変えない。
  出力抵抗が効かないのは、2 つの出力の比 V<sub>高域</sub> / V<sub>低域</sub> = jωRC が、2 本の枝の分かれ目の電圧に関係しないからだ。
  等しい負荷 (10 kΩ ずつ、24 pF ずつ) を付けても、100 kHz〜2 MHz で差は 90.0° のままだった (計算値)

## 出典

自作。RC と CR の位相 (−45° と +45°) と 2 つの出力の比 jωRC は、1 次の低域・高域フィルタの伝達関数からの計算。
数値は手計算と LTspice で確かめた。
