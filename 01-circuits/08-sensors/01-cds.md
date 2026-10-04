---
book: circuits
chapter: 8
id: 8-1
title: CdS で暗くなると点く
tier: 50
source: 自作
board: BB
---

# 8-1 CdS で暗くなると点く

CdS セル (硫化カドミウムを使った光センサー) は、当たる光が弱いほど抵抗が
大きくなる。固定抵抗と組んで分圧すると、明るさを電圧に変えられる。
その電圧でトランジスタを ON/OFF すれば、暗くなったら自動で LED が点く回路になる。

## 回路図

```circuit
title: 図1 CdS が暗いとトランジスタが ON になる
parts:
  VCC: vcc e2 5V
  R1: resistor e2 g2 10k
  CDS1: photoresistor g2 i2 GL5528 l=$\mathrm{CDS1}$
  G1: ground i2
  Q1: npn g5 2SC1815
  VCC: vcc b5 5V
  R2: resistor b5 d5 330
  D1: led d5 f5
  G2: ground i5
wires:
  - g2 -- Q1.B
  - f5 -- Q1.C
  - Q1.E -- i5
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/circuit/01-cds.svg)

- R1 (固定 10 kΩ、上) と CDS1 (CdS、下) で分圧し (1-2 で見た)、その中点を Q1 の
  ベースに直結する。CdS が暗くて抵抗が大きくなるほど、中点の電圧は +5 V に
  近づく。上の R1 は固定なのに下の CDS1 の抵抗だけが上がるので、電圧の
  ほとんどが CDS1 側に掛かるからだ
- 中点の電圧が Q1 の V<sub>BE</sub> (約 0.7 V) に達すると Q1 が ON になり、
  R2 (330 Ω) を通して D1 (LED) が点く
- ベースに分圧の中点を直接つなぐ簡単な作りなので、切り替わりはゆるやかで、
  はっきりした ON/OFF にはならない。感度は R1 で変えられる。R1 を大きくすると、もっと暗くならないと点かなくなる

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上の赤いレール = +5V、青いレール = GND (右端で上下を渡している)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
  R1: resistor b3 b7 10k
  CDS1: photoresistor d7 d12 GL5528
  Q1: transistor h7(B) h8(C) h9(E) 2SC1815
  D1: led f13(A) f8(K) red
  R2: resistor h13 h17 330
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - +t3 -- a3 red
  - a12 -- -t12 black
  - e7 -- f7 green
  - j9 -- -b9 black
  - j17 -- +b17 red
  - +t30 -- +b30 red
  - -t29 -- -b29 black
notes:
  - text: 7 列 (R1 と CDS1 の間) が分圧の中点。緑の線で Q1 のベースへ渡す
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/01-cds.svg)

- AD3 の V+ (+5 V) と GND を上のレールに入れ、右端 (29・30 列) で下のレールへ渡す
- 分圧 (R1・CDS1) は上のブロックに置く。R1 (3→7 列) の 3 列を + レールへ、CDS1 (7→12 列) の 12 列を − レールへつなぐ。
  CDS1 は、受光面の蛇行した線で見分けられる部品。向きは無い
- 7 列が分圧の中点で、緑の線で下のブロックの 7 列 (Q1 のベース) へ渡す
- Q1 (2SC1815) は、平らな面を手前にして見ると左から E・C・B。ここでは平らな面を奥 (f 行側) に向けて挿し、
  B・C・E を h 行の 7・8・9 列に入れる。
  エミッタ (9 列) は下の − レールへ。コレクタ (8 列) に D1 のカソード、D1 のアノード (13 列) から R2 (13→17 列) を通して下の + レールへつなぐ

## 計器の設定

計器は Analog Discovery 3 の Supplies (電源) とテスターを使う。AD3 の V+ を 5 V にして出力を ON にする。
この回路の消費は LED の約 9 mA と分圧の数百 µA で、AD3 の電源 1 系統の約 50 mA に収まる。
ブレッドボードの 1 穴を通る電流も 200 mA 以下で、ブレッドボードの範囲に入る。

この題はオシロの図を付けない。見るのは明るさでゆっくり変わる直流の電圧で、時間で変わる波形ではない。
テスターの読み値で足りる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 | 10 kΩ |
| CDS1 | CdS セル | GL5528 (10 lux で 8〜20 kΩ) |
| Q1 | NPN トランジスタ | 2SC1815 |
| R2 | 抵抗 | 330 Ω |
| D1 | LED (赤) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | 5 V (AD3 の Supplies の V+) |

## 見るべき値

表の値は計算値。CdS の抵抗は、照度 (明るさ。単位は lux) のおよそ 0.7 乗に反比例するという代表的な特性で見積もった
目安だ (10 lux で 10 kΩ とした。実物には個体差があるので、実測して確かめる)。
中点の電圧は 5 V × R<sub>CdS</sub> / (10 kΩ + R<sub>CdS</sub>) で、Q1 をつながないときの値。
Q1 が ON になると、中点は V<sub>BE</sub> (約 0.7 V) あたりに抑えられる。
中点が約 0.65 V になる R<sub>CdS</sub> ≈ 1.5 kΩ (約 150 lux) あたりで、Q1 が ON に切り替わり始める。

測り方: CdS の抵抗は、回路から外してテスターの抵抗レンジで測る。中点の電圧は、Q1 のベースへの緑の線を抜いて、
テスターの DC 電圧レンジで 7 列と GND の間を測る。

| 明るさ | CdS の抵抗 (目安) | 分圧の中点の電圧 | Q1 と LED |
| --- | --- | --- | --- |
| 明るい室内 (500 lux) | 約 650 Ω | 約 0.3 V | OFF (消灯) |
| 薄暗い室内 (100 lux) | 約 2 kΩ | 約 0.8 V | ON になり始める (LED が点き始める) |
| 夕方くらい (10 lux) | 約 10 kΩ | 約 2.5 V | ON (点灯) |
| 手で覆う (ほぼ 0 lux) | 約 500 kΩ | 約 4.9 V | ON (しっかり点灯) |

## 出典

自作。
