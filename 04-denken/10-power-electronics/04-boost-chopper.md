---
book: denken
chapter: 10
id: 10-4
title: 昇圧チョッパ — 出力電圧 = 入力 / (1 − デューティ比)
tier: 100
source: 自作
board: BB
---

# 10-4 昇圧チョッパ — 出力電圧 = 入力 / (1 − デューティ比)

コイルに電流をためてから、その電流をダイオードを通して出力へ押し出すと、入力より**高い**直流電圧が得られる。
MOSFET のオンの割合 (デューティ比 D) を上げるほど出力は高くなる。10-3 の降圧チョッパと同じ部品 (2N7000・1N5819・1 mH・10 µF) を
並べ替えて組み、Vout = Vin / (1 − D) を確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Vout = Vin / (1 − D) | 出力電圧 (連続モード)。D = 50 % で 2 倍 |
| (1 − D) × (Vout + VF) = Vin | Q1 のドレインの電圧の平均は Vin に等しい (コイルの電圧の平均は 0)。VF は D1 の順電圧 |
| ΔI = Vin × D / (L × f) | コイルの電流のリップル |
| ΔVout ≒ Iout × D / (f × C) | 出力電圧のリップル |

2 行目がこの題の要。コイルの両端の電圧は、平均すると 0 でなければならない (でないと電流が増え続ける)。
だからドレインの平均は Vin で、ドレインがオフの間だけ Vout + VF に上がるなら、(1 − D) × (Vout + VF) = Vin になる。

## 回路図

```circuit
title: 図1 昇圧チョッパ
style:
  standard: jis
  pitch: 1.2
parts:
  Vin: vsource b1 i1 5
  L1: inductor b2 b5 1m
  D1: schottky b6 b9 1N5819
  Q1: nmos-e g6
  Vg: square i3 h3 l=$\mathrm{PWM}$
  M2: voltmeter f8 i8 l=$\mathrm{CH2}$
  Cout: ecap b11 i11 10u
  RL: resistor b13 i13 2.2k
  M1: voltmeter b16 i16 l=$\mathrm{CH1}$
  G1: ground i1
wires:
  - b1 -- b2
  - b5 -- b6 -- f6
  - f6 -- Q1.D
  - f6 -- f8
  - b9 -- b11 -- b13 -- b16
  - Q1.G -| h3
  - Q1.S |- i6
  - i1 -- i3 -- i6 -- i8 -- i11 -- i13 -- i16
notes:
  - text a6f5 blue: X
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/10-power-electronics/circuit/04-boost-chopper.svg)

- Vin は DC 5 V (AD の Supplies の V+)。Vg は AD の Wavegen (W1) で作る PWM (方形波、200 kHz、0〜5 V)
- Q1 (2N7000) は**ソースが GND のローサイド**で、昇圧チョッパはこれが元の形 (10-3 のように負荷を置き換える工夫が要らない)。
  オンの間は Vin → L1 → Q1 → GND と流れて L1 に電流をためる。オフになると L1 の電流は D1 を通って Cout と RL へ押し出され、
  節点 X (ドレイン) は Vout + VF まで上がる
- 出力は GND 基準。M1 (CH1) が Vout、M2 (CH2) が節点 X
- RL は 2.2 kΩ。軽すぎる負荷にすると電流が途切れ (不連続)、Vout が式より高くなる。**RL を外したまま動かさない**
  (出力が上がり続けて Cout の耐圧 25 V を超える)
- 周波数を 10-3 の 100 kHz から 200 kHz に上げたのは、RL = 2.2 kΩ の軽い負荷でもコイルの電流を連続にするため

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上の赤レール = 5 V (AD の V+)、青レール = GND。下の青レールも 29 列でつなぐ
board: half
parts:
  Q1: transistor c5(S) c6(G) c7(D) 2N7000
  L1: inductor/axial g2 g7 1m
  D1: schottky h7(A) h12(K) 1N5819
  Cout: capacitor/electrolytic g12(+) g15(-) 10u
  RL: resistor i12 i18 2200
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, W1, 2+, GND, 2-, 1+, 1-]
wires:
  - AD.V+ -- +t4 red
  - +t2 -- a2 red
  - e2 -- f2 red
  - AD.W1 -- a6 yellow
  - a5 -- -t5 black
  - AD.GND -- -t9 black
  - e7 -- f7 green
  - AD.2+ -- b7 blue
  - AD.2- -- -t11 black
  - AD.1+ -- a12 orange
  - e12 -- f12 orange
  - AD.1- -- -t14 black
  - -t29 -- -b29 black
  - j15 -- -b15 black
  - j18 -- -b18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/10-power-electronics/breadboard/04-boost-chopper.svg)

- 5 V は AD の Supplies (V+) を上の赤レールへ。2 列を通して溝を渡り、下の 2 列から L1 (2→7 列) へ
- Q1 (2N7000) は平らな面を手前にして左から S・G・D (5・6・7 列、10-3 と同じ)。S を青レール、G を W1 へ。
  D (7 列) は溝を渡って下の 7 列 (L1 の右端と D1 の A) とつなぐ。ここが節点 X
  ※ **実物で確かめる: onsemi の 2007 年版の図は S G D、2022 年版の表は D G S で食い違い、表は 2007 年版 (S G D) に従う。実物はテスタで確かめる**
- D1 の K (12 列) が出力。Cout (+ が 12 列、− が 15 列) と RL (12→18 列) を並べ、15・18 列を下の青レールへ
- CH1 (1+) は上の 12 列から溝を渡って f12 (出力)、CH2 (2+) は b7 (節点 X)。1−・2− は青レール

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| 電源 | Supplies: V+ = 5 V |
| Wavegen | PWM: Square、200 kHz、Amplitude 2.5 V、Offset 2.5 V (0〜5 V)、Symmetry (デューティ比) 50 % (25・60 % にも変える) |
| Scope | CH1 = 出力 (Vout)。CH2 = 節点 X (ドレイン)。2 V/div、Time base 2 µs/div |
| Measure | CH1 の Average、CH2 の Average (= Vin になるはず) |

D を 60 % より上げない。D = 75 % では Vout が約 20 V になり、RL の電力 (0.18 W) が 1/4 W の半分を超える。

D = 50 % の画面。節点 X は Q1 がオンの間 0 V、オフの間 Vout + VF = 10 V で、平均が 5 V (Vin) になる。

```scope
title: 図3 D 50 % — 出力 (CH1) は 9.70 V、節点 X (CH2) の平均は Vin の 5 V
time: 2us/div
trigger: ch2 falling 5V
ch1: {wave: dc 9.70V, range: 2V/div, position: -2div}
ch2: {wave: square 200kHz 5V offset 5V phase 180deg, range: 2V/div, position: -4div}
measure: [avg, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/10-power-electronics/scope/04-boost-chopper.svg)

出力のリップル (1.1 mV) は 2 V/div では見えない。AD3 本体のピンの入力は DC 結合だけで、直流を打ち消す Offset も
0.5 V/div 以下の細かい目盛では ±2.5 V までしか動かせないので、9.70 V の直流は打ち消せない。見たいときは AD3 に BNC アダプタを付け、
CH1 のジャンパを AC にして (AC 結合。約 1.6 Hz より低い成分を切る) 1 mV/div まで上げる。

### オシロスコープと発振器

GND 基準の題で、測る所は図1 のまま ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。CH1 の先端を f12 (出力)、CH2 の先端を b7 (節点 X)、
グランドクリップは 2 本とも青レール。10-3 の降圧チョッパと違い、出力が GND 基準なのでそのまま測れる。

- Vin は安定化電源の 5 V、電流制限 100 mA (ふだんは D = 60 % でも 15 mA ほど。Q1 がオンのまま止まると
  L1 の巻線抵抗と Q1 だけで電流が決まり、制限が効く)
- PWM は FG の OUT (High-Z)。Square、200 kHz、Duty 50 %、High 5 V / Low 0 V (Amplitude と Offset で入れる機種なら 5 Vpp・2.5 V)。
  2N7000 のゲートの容量は小さく、FG の 50 Ω でも波形は崩れない
- 節点 X の Mean が 5 V (Vin) になることは、汎用オシロでもそのまま確かめられる

## 見るべき値

計算値 (Vin = 5 V、f = 200 kHz、L = 1 mH、C = 10 µF、RL = 2.2 kΩ、VF = 0.3 V)。

| D | Vout (理想、Vin / (1 − D)) | Vout (VF を引いた値) | Iout | L1 の平均電流 | ΔI | ΔVout |
| --- | --- | --- | --- | --- | --- | --- |
| 25 % | 6.67 V | 6.37 V | 2.89 mA | 3.86 mA | 6.25 mA | 0.36 mV |
| 50 % | 10.0 V | **9.70 V** | 4.41 mA | 8.82 mA | 12.5 mA | 1.1 mV |
| 60 % | 12.5 V | 12.2 V | 5.55 mA | 13.9 mA | 15.0 mA | 1.7 mV |

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の Average (D = 50 %) | 9.70 V | 入力のほぼ 2 倍 |
| CH2 の Average | 5.00 V | 節点 X の平均は Vin。これが Vout = Vin / (1 − D) の元 |
| CH2 の Frequency | 200.0 kHz | PWM の周波数 |

- **D を上げるほど出力は高くなり、D → 100 % で式は無限大に向かう。** 実物では巻線抵抗や Q1 のオン抵抗の損失で頭打ちになる
- どの D でも L1 の平均電流は ΔI の半分より大きく、電流は 0 まで落ちない (連続モード)
- 入力の電流 (L1 の平均電流) は出力の電流の 1 / (1 − D) 倍。入力の電力 5 V × 8.82 mA = 44 mW と出力 9.70 V × 4.41 mA = 43 mW は、
  D1 の損失の分を除けば等しい。電圧を上げた分だけ電流が減る (8-1 の変圧器と同じ関係)
- 実物の 1 mH のアキシャルのコイルは巻線抵抗が数十 Ω あり、Vout はさらに数 % 低く出る

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。
