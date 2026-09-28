---
book: denken
chapter: 6
id: 6-9
title: 負帰還 — 増幅度と帯域の交換
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-9 負帰還 — 増幅度と帯域の交換

OP アンプそのものの増幅度 (開ループ利得) は 10 万倍を超えるが、数十 Hz から上では
周波数に反比例して下がる。出力の一部を入力へ戻す**負帰還**をかけると、増幅度は抵抗の比で
決まる小さな値になる代わりに、平らに増幅できる周波数の幅 (帯域) が広がる。
**増幅度 × 帯域 = 一定 (利得帯域幅積 GBW)** になることを、帰還の抵抗を 3 通りに変えて
AD のネットワークアナライザで確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| A = A₀ / (1 + A₀ β) ≒ 1 / β | 帰還をかけた増幅度。β = R1 / (R1 + R_f) は出力を戻す割合 |
| A = 1 + R_f / R1 | 非反転増幅の増幅度 (6-4) |
| f_H = GBW × β = GBW / A | 帰還をかけたときの高い側の遮断周波数 (−3 dB) |
| A × f_H = GBW | 増幅度と帯域の積は帰還のかけ方によらない |

## 回路図

```circuit
title: 図1 非反転増幅の帰還を変える
parts:
  V1: sine d1 f1 10m l=$\mathrm{W1}$
  U1: opamp c6 +up TL072
  R1: resistor d4 f4 1k
  Rf: resistor d5 d8 100k
  OUT: port c11
  G1: ground f1
wires:
  - U1.+ -| d1
  - d4 |- U1.-
  - d4 -- d5
  - d8 -- d9 -- c9
  - U1.out -- c9 -- c11
  - f1 -- f4
notes:
  - text b1 blue: 入力 (CH1)
  - text b9 blue: 出力 (CH2)
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/circuit/09-negative-feedback.svg)

- U1 は TL072 の 1 回路目。電源は AD の Supplies の ±5 V
- R_f = 100 kΩ のまま、R1 を **1 kΩ (A = 101)**・**10 kΩ (A = 11)**・**外す (A = 1)** と
  差し替える。R1 を外すと出力が全部 − に戻り (β = 1)、ボルテージフォロアになる
- 入力はネットワークアナライザの W1 (振幅 10 mV)。CH1 で入力、CH2 で出力を測り、比をとる

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  U1: dip8 @ f14 r180 TL072
  R1: resistor a20 -t20 1k
  Rf: resistor d20 d24 100k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V-, W1, 1+, GND, 1-, 2+, 2-, V+]
wires:
  - AD.V- -- a14 purple
  - AD.W1 -- a15 yellow
  - AD.1+ -- b15 yellow [h10]
  - AD.GND -- -t17 black
  - AD.1- -- -t18 black
  - c16 -- c20 blue
  - b17 -- b24 green
  - AD.2+ -- a24 green
  - AD.2- -- -t26 black
  - AD.V+ -- +t28 red
  - +t29 -- +b29 red
  - -t2 -- -b2 black
  - j17 -- +b17 red
  - j14 -- -b14 black
  - g15 -- g16 green
notes:
  - text small: TL072 (1 回路目で非反転増幅)。1=OUT1 2=IN1- 3=IN1+ 4=V-
  - text small: 5=IN2+ 6=IN2- 7=OUT2 8=V+。使わない 2 回路目は 5 番を GND、6・7 番をつなぐ
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/breadboard/09-negative-feedback.svg)

- TL072 は `r180` で置き、上の段 (e14〜e17) が 4・3・2・1 番。3 番 (IN1+、15 列) に W1 と CH1、
  1 番 (OUT1、17 列) から緑の線で 24 列へ出して CH2 (2+)
- 2 番 (IN1−、16 列) は青い線で 20 列へ運ぶ。20 列に R1 (− のレールへ) と R_f (20〜24 列) が集まる
- 4 番 (V−、14 列) に AD の V− (紫)。8 番 (V+) は下の段の f17 で、j17 から + のレール (下) へ。
  上下の + のレールと − のレールは右端・左端の線でつなぐ
- R1 を 1 kΩ → 10 kΩ → 抜く、と差し替えて 3 回掃引する

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、V− = −5 V |
| Network | Start 100 Hz、Stop 10 MHz、Scale Log、Steps 101、W1 の Amplitude 10 mV、Offset 0 V。Channel 1 を基準 (入力)、Channel 2 を出力 |
| 表示 | Magnitude (dB) と Phase。Cursor で −3 dB の周波数を読む |

入力を 10 mV にとどめるのは、A = 101 で出力が 1 V になり、TL072 の出力の振れ (±5 V 電源で
約 ±3.5 V) と速さ (スルーレート 13 V/µs) に十分な余裕を持たせるため。AD の Network は
10 MHz まで掃引できるが、付属の線で配線すると 9 MHz あたりから上は線そのものの影響が出る。
A = 1 の −3 dB (約 3 MHz) はその手前で読める。

```graph
title: 図3 帰還の量と帯域 (計算) — 増幅度を 1/10 にすると帯域が 10 倍に
x: 周波数 Hz log 100..10M
y: 増幅度 dB -10..110
lines:
  開ループ dB: 20 * log10(200000 / sqrt(1 + (x / 15) ^ 2))
  A=101 dB: 20 * log10(101 / sqrt(1 + (x / 29.7k) ^ 2))
  A=11 dB: 20 * log10(11 / sqrt(1 + (x / 273k) ^ 2))
  A=1 dB: 20 * log10(1 / sqrt(1 + (x / 3M) ^ 2))
notes:
  - mark 29.7k
  - mark 273k
  - mark 3M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/graph/09-negative-feedback.svg)

開ループの線は TL072 の代表値 (直流の増幅度 20 万倍 = 106 dB、GBW 3 MHz) から、
折れ点を 3 MHz ÷ 20 万 = 15 Hz として描いた。帰還をかけた 3 本は、どれも開ループの線に
ぶつかった所で折れて、その線に沿って下がる。

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。

| AD | 汎用の計器 |
| --- | --- |
| W1 | FG の OUT。Sine、**20 mVpp** (AD の Amplitude 10 mV は山の高さ)、Offset 0 V、出力は High-Z。周波数は手で変える |
| V+ / V− | 2 出力の安定化電源で ±5 V。電流制限は各 10 mA |
| 1+ | CH1 の先端を 15 列 (入力)、グランドクリップを GND のレール |
| 2+ | CH2 の先端を 24 列 (出力)、グランドクリップを GND のレール |

- ネットワークアナライザの掃引の代わりに、FG の周波数を 1-2-5 の刻み (1 kHz、2 kHz、5 kHz …) で
  手で変え、Measure の CH1・CH2 の Vpp の比を表にする。−3 dB (比が 0.707 倍) の前後は細かく刻む
- 20 mVpp の入力は CH1 で読みにくい。CH1 は 5 mV/div にして Average を掛けるか、FG の表示の
  振幅を入力の値として使う (入力は OP アンプの + なので、FG の 50 Ω による低下は無い)
- A = 1 の 3 MHz は、×10 のプローブで測る (×1 のプローブは数 MHz で自分の帯域に掛かる)

## 見るべき値

計算値。TL072 の GBW = 3 MHz (代表値) とした。GBW は個体と製造元で違い、改良版の TL072H は
5 MHz を超える。どの個体でも**積が一定になる**ことを確かめる。

| R1 | 増幅度 A (= 1 + R_f / R1) | 低い周波数での利得 | −3 dB の周波数 f_H | A × f_H |
| --- | --- | --- | --- | --- |
| 1 kΩ | 101 | 40.1 dB | 29.7 kHz | 3.0 MHz |
| 10 kΩ | 11 | 20.8 dB | 273 kHz | 3.0 MHz |
| 外す | 1 | 0 dB | 3.0 MHz | 3.0 MHz |

- −3 dB の周波数では、位相も入力より 45° 遅れている。Phase の表示で −45° の所を読んでも同じ周波数になる
- 図3 の読み値は各 mark の所の 4 本の利得。帰還をかけた線は、自分の mark で低い周波数の値から
  3.0 dB 下がっている

分かること:

- **負帰還は増幅度を帯域に両替する**。10 倍の増幅度を手放すと、帯域が 10 倍広がる。
  広い帯域が要るなら 1 段の増幅度を抑え、何段かに分けて増幅する
- 帰還をかけた増幅度は R_f と R1 の比だけで決まり、OP アンプの開ループ利得のばらつき
  (個体で数倍違う) がほとんど効かない。6-3 で R_E を残したのと同じ考え (負帰還の安定化)
- 開ループの線は 20 dB/dec で下がる。帰還をかけた線はこの線より上には出られない

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network・Supplies の節)。TL072 の GBW・開ループ利得・スルーレートはメーカーのデータシート
(Texas Instruments TL07x)。
