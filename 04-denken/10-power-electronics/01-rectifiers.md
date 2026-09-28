---
book: denken
chapter: 10
id: 10-1
title: 単相の半波整流と全波整流 — 平均値は 0.45 V と 0.9 V
tier: 50
source: 自作
board: BB
---

# 10-1 単相の半波整流と全波整流 — 平均値は 0.45 V と 0.9 V

ダイオード 1 個で片側だけを通す**半波整流**と、4 個をブリッジに組んで両側を通す
**全波整流**を、同じ交流電源から同時に作って比べる。平均値 (直流分) の違いを
実測する。AD の波形発生器を商用周波数に見立てた 50 Hz で使う (商用電源には繋がない)。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Vavg(半波) = Vm / π ≒ 0.45 × Vrms | 半波整流の平均値 (理想ダイオード) |
| Vavg(全波) = 2Vm / π ≒ 0.9 × Vrms | 全波整流の平均値。半波のちょうど 2 倍 |
| Vavg(実際) ≒ {√(Vm² − V0²) − V0 · cos⁻¹(V0/Vm)} / π × (1 or 2)、V0 = nVf | 実際はダイオードの順電圧 Vf の分だけ低くなり、山の裾の V0 に届かない間は流れない (n = 直列に通る個数)。(Vm − nVf) / π は流れない間を数えないので大きめに出る |

## 回路図

```circuit
title: 図1 半波整流と全波整流ブリッジを並べて比べる
style:
  standard: jis
parts:
  W1: sine c1 g1 l=$\mathrm{W1}$
  D1: diode c1 c3 1N4148
  RL1: resistor c3 g3 1.5k
  M1: voltmeter c5 g5 l=$\mathrm{CH1}$
  D2: diode e10 c13 1N4148
  D3: diode e16 c13 1N4148
  D4: diode g13 e10 1N4148
  D5: diode g13 e16 1N4148
  RL2: resistor c13 g13 1.5k
  M2: voltmeter c15 g15 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - c1 -- a1 -- a10 -- e10
  - g1 -- i1 -- i16 -- e16
  - g1 -- g3
  - c3 -- c5
  - g3 -- g5
  - c13 -- c15
  - g13 -- g15
```

- W1 は AD の波形発生器 (Wavegen)。50 Hz、振幅 5 V
- 左側 (D1 + RL1) が半波整流、右側 (D2〜D5 のブリッジ + RL2) が全波整流。
  同じ W1 から並列に取り出している
- CH1 は半波整流の出力 (RL1 の両端)、CH2 は全波整流の出力 (RL2 の両端) を同時に読む

## 実体配線図

```breadboard
title: 図2 半波整流のブレッドボード
board: half
parts:
  D1: diode c4(A) c9(K) 1N4148
  RL1: resistor e9 e14 1500
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-]
wires:
  - AD.W1 -- a4 yellow
  - AD.GND -- -t6 black
  - AD.1+ -- a9 orange
  - AD.1- -- -t11 black
  - a14 -- -t14 black
```

```breadboard
title: 図3 全波整流 (ブリッジ) のブレッドボード
board: half
parts:
  D2: diode c4(A) c12(K) 1N4148
  D3: diode -t12(A) a12(K) 1N4148
  D4: diode g18(A) g4(K) 1N4148
  D5: diode a18(A) -t18(K) 1N4148
  RL2: resistor d12 d18 1500
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 2+, 2-]
wires:
  - AD.W1 -- a4 yellow
  - AD.GND -- -t8 black
  - AD.2+ -- b12 orange
  - AD.2- -- b18 blue
  - e4 -- f4 yellow
  - e18 -- f18 blue
```

- 半波整流 (図2) は D1 と RL1 だけ。CH1 (1+/1−) は RL1 の両端 (9 列と青レール)
- 全波整流 (図3) は D2〜D5 の 4 本でブリッジを組む。4 列が AC の一方 (W1)、
  青レール (GND) が AC の他方、12 列が正、18 列が負。RL2 (12・18 列) が正負の間の
  負荷。D3 (アノードが青レール、カソードが 12 列) と D5 (アノードが 18 列、
  カソードが青レール) はレールと a 行の間に立てて挿す。D4 は下のブロックに挿し、
  4 列・18 列を溝をまたぐ短い線で上下つなぐ
- CH2 (2+/2−) は RL2 の両端 (12 列側が正、18 列側が負) にあてる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、50 Hz、Amplitude 5 V |
| Scope | CH1 = 半波整流の出力。CH2 = 全波整流の出力。どちらも Measure で Average を読む |

ダイオードは順電圧 0.6 V 一定の模型で描いた (半波は 1 個分、全波は 2 個分を引いて 0 V で切る)。

```scope
title: 図4 半波 (CH1) は 1 周期に山 1 つ、全波 (CH2) は 2 つ
time: 5ms/div
trigger: ch1 rising 1V
ch1: {wave: sine 50Hz 5V | offset -0.6V | clip 0V, range: 1V/div, position: -3div}
ch2: {wave: sine 50Hz 5V | abs | offset -1.2V | clip 0V, range: 1V/div, position: -3div}
measure: [avg, vmax, freq]
```

### オシロスコープと発振器

W1 は FG の OUT (High-Z、50 Hz、振幅 5 V。Vpp で入れる機種なら 10 Vpp) に読み替える
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。半波整流 (図2) は GND 基準で、
CH1 の先端を 9 列、グランドクリップを青レールに当てる。

全波整流 (図3) は差動。**ブリッジの − (18 列) は FG の GND ではない。** AD の 2− を当てていた 18 列に
グランドクリップを当てると、18 列が大地を通って FG の GND (青レール) とつながる。D5 は両端が
同じ GND になり、負の半周期には D4 が FG の出力を GND へじかに短絡する。電流を止めるのは FG の 50 Ω
だけで、山で約 88 mA (計算値) が D4 と FG に流れ、全波整流でもなくなる。

そこで**回路はそのままで、2 本の先端をブリッジの + と − に当て、CH1 − CH2 で引く** (図5)。
差 (出力、山で約 3.8 V) は各点の振れ (約 5 V) の 7 割あり、8 bit でも埋もれない。
2 ch はこれで使い切るので、半波と全波は別々に測る (4 ch のオシロなら同時に測れる)。

```circuit
title: 図5 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{FG}$
  D2: diode e4 c7 1N4148
  D3: diode e10 c7 1N4148
  D4: diode g7 e4 1N4148
  D5: diode g7 e10 1N4148
  RL2: resistor c13 i13 1.5k
  M2: voltmeter i11 k11 l=$\mathrm{CH2}$
  M1: voltmeter c16 k16 l=$\mathrm{CH1}$
  G1: ground g1
  G2: ground g10
  G3: ground k13
wires:
  - c1 -- a1 -- a4 -- e4
  - e10 -- g10
  - c7 -- c13 -- c16
  - g7 -- i7 -- i11 -- i13
  - k11 -- k13 -- k16
```

- ブリッジの右の角 (FG の GND) と FG の − は、どちらも大地につながった同じ GND
  (図では 2 つの接地の記号)。ブリッジの − は GND ではなく、CH2 の先端だけを当てる
- CH1 の先端は 12 列 (+)、CH2 の先端は 18 列 (−)、グランドクリップは 2 本とも青レール。
  ブレッドボードの部品は図3 のまま動かさない
- 全波の出力は Math の CH1 − CH2。平均は Math の Mean か、CH1 と CH2 の Mean の差 (平均は引き算と
  順序を入れ替えられる)。CH1・CH2 はどちらも 1 V/div、DC 結合。
  各点は約 5 V の幅で振れるので、はみ出すなら Offset で画面に収める
- FG の 50 Ω で山がつぶれ、平均値は AD で測るより約 3 % 低く出る (計算値。図1 のように 2 つを
  同時につなぐと約 5 %)

## 見るべき値

計算値。ダイオードの順電圧 Vf ≒ 0.6 V (1N4148) とした。

| 測る所 | 理想の式 | 実際 (Vf を考えた計算値) |
| --- | --- | --- |
| CH1 平均値 (半波) | 0.45 × 3.54 V = 1.59 V | 1.30 V (V0 = 0.6 V) |
| CH2 平均値 (全波) | 0.9 × 3.54 V = 3.18 V | 2.08 V (V0 = 1.2 V) |
| CH2 / CH1 の比 | 2.00 (理想) | 約 1.60 (Vf 2 個分だけ理想より小さい) |

**全波は半波のちょうど 2 倍にはならない。** ブリッジは電流が常に 2 個の
ダイオードを通るので、Vf の効き方が半波 (1 個分) より大きいため。この差は
5 V 程度の低い電圧で特に目立ち、電圧を上げるほど比は 2 に近づく。

## 出典

自作。
