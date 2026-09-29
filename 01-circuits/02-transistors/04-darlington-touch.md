---
book: circuits
chapter: 2
id: 2-4
title: ダーリントン — 指で触れて点く
tier: 50
source: 自作
board: BB
---

# 2-4 ダーリントン — 指で触れて点く

トランジスタ 2 つを**エミッタ→ベースで縦につなぐ**と、電流増幅率が
掛け算になる (ダーリントン接続)。指の皮膚の抵抗 (数百 kΩ) ほどの
わずかな電流でも、LED を光らせるだけの電流に増幅できる。

## 回路図

```circuit
title: 図1 ダーリントンで作る指タッチスイッチ (CH2 でベース、CH1 でコレクタを見る)
parts:
  VCC: vcc a2 5V
  TP1: port a4
  TP2: port f3
  RB: resistor f4 h4 1M
  G2: ground h4
  Q1: npn f7
  Q2: npn g9
  RC: resistor a9 c9 470
  D1: led c9 e9
  G3: ground h9
  M2: voltmeter f3 h3 l=$\mathrm{CH2}$
  G5: ground h3
  M1: voltmeter e11 h11 l=$\mathrm{CH1}$
  G4: ground h11
wires:
  - a2 -- a4 -- a9
  - f3 -- f4 -- Q1.B
  - Q1.E |- Q2.B
  - e9 -| Q1.C
  - e9 -- Q2.C
  - Q2.E -- h9
  - e9 -- e11
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/04-darlington-touch.svg)

`TP1` と `TP2` が指で触れる 2 枚の金属板 (アルミ箔やねじの頭など)。
触れていないときは `RB` (1MΩ) が Q1 のベースを GND 側に引いて OFF に保つ。

- 指の抵抗 (仮に 500kΩ とする、実際は 100kΩ〜1MΩ 程度と幅がある) を通って
  ベースの節点に流れ込む電流: I ≈ (5V − 1.4V) / 500kΩ ≈ **7.2 µA**
  (1.4V はダーリントンのベース-エミッタ 2 段ぶん)。`RB` (1MΩ) は同じ節点から
  GND へも 1.4V / 1MΩ ≈ **1.4 µA** を引き取るので、Q1 のベースに実際に
  入る電流は差し引き 7.2 − 1.4 ≈ **5.8 µA** (計算値)
- 2SC1815 の hFE を 200 と仮定すると、ダーリントン全体の電流増幅率は
  200 × 200 = **40000** (理論値。実際は洩れ電流などで数千程度に下がることが多い)
- LED の電流は増幅率ではなく **RC で頭打ちになる** (十分に飽和するため):
  I<sub>C</sub> = (5 − V<sub>CE(sat)</sub> − V<sub>F</sub>) / RC ≈ (5 − 0.4 − 2.0) / 470
  ≈ **5.5 mA** (計算値)
- 飽和に必要な最小ベース電流は 5.5mA / 40000 ≈ 0.14µA。指の電流 (約 5.8µA)
  は実際の (理想より低い) 増幅率で見ても十分足りる — これが「軽く触れるだけで
  点く」理由

## 実体配線図

```breadboard
title: 図2 ダーリントンタッチスイッチ
# 5V は AD の V+ から上の + レールへ。下の − レールは 28 列で上の − レールとつなぐ
board: half
parts:
  RC: resistor b5 b8 470
  D1: led c8(A) c9(K) red
  Q1: transistor h12(B) h13(C) h14(E) 2SC1815
  Q2: transistor h17(B) h18(C) h19(E) 2SC1815
  RB: resistor b21 b24 1M
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1+, 1-, 2-, 2+]
  TP1:
    type: device
    at: top
    label: 触れる板 1 (+)
    pins: [A]
  TP2:
    type: device
    at: top
    label: 触れる板 2
    pins: [B]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1+ -- a9 orange
  - AD.1- -- -t10 black
  - AD.2+ -- a20 blue
  - AD.2- -- -t19 black
  - +t5 -- a5 red
  - d9 -- f13 orange
  - a24 -- -t24 black
  - e21 -- f12 yellow
  - d20 -- d21 blue
  - f14 -- f17 blue
  - g18 -- g13 orange
  - j19 -- -b19 black
  - -t28 -- -b28 black
  - TP1.A -- +t26 red
  - TP2.B -- a21 gray
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/04-darlington-touch.svg)

部品はすべて上のレール側から組む。5V は Analog Discovery の電源出力 V+ (赤) から
上の + レールへ入れる (WaveForms の Supplies で V+ を 5 V にして入れる)。
流れるのは LED の約 5.5 mA だけなので V+ で足りる。

- `Q1`・`Q2` は下のブロックの h 行 (`h12`〜`h14`・`h17`〜`h19`)。上の f・g 行を線の通り道にする
- `Q1` のエミッタ (`f14`) は `Q2` のベース (`f17`) へ青の線。LED のカソード (`d9`) は `Q1` の
  コレクタの列 (`f13`) へ、`Q2` のコレクタ (`g18`) も同じ列の `g13` へ橙の線
- `Q2` のエミッタは `j19` から下の − レールへ
- `TP1` は上の + レール (`+t26`)、`TP2` は `RB` の上端 (列 21) へ。列 21 は
  黄線で `Q1` のベースにもつながる
- **CH1 (1+、橙)** は LED のカソードの列 9 (`a9`) — コレクタの電圧を見る
- **CH2 (2+、青)** は列 20 (`a20`) に挿し、`d20`–`d21` で列 21 へ渡す — `Q1` のベース (触れる板 2) の電圧を見る
- AD の GND・1−・2− (黒) は上の − レールへ。`Q2` のエミッタ (下の − レール) と
  `RB` の下端 (上の − レール) が同じ GND になるよう、28 列の黒線で上下の − レールを
  つなぐ

## オシロで見る

CH1 を 1 V/div、CH2 を 500 mV/div、時間軸を 20 ms/div にし、CH2 の立ち上がり
(0.7 V) でシングル トリガを掛けてから両方の板に指で触れる。

```scope
title: 図3 指で触れた瞬間 — ベース (CH2) が上がり、コレクタ (CH1) が落ちる
time: 20ms/div
trigger: ch2 rising 0.7V
ch1: {wave: = 3.5V - 2.7V * step(t) | rc 200us, range: 1V/div, position: -3div}
ch2: {wave: = 1.4V * step(t) | rc 200us, range: 500mV/div, position: -3div}
cursors: [-50ms, 50ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/04-darlington-touch.svg)

- 触れる前 (X1): CH2 は `RB` で 0 V、CH1 は約 3.5 V。LED にはオシロの入力 (1 MΩ)
  へ流れるわずかな電流しか流れず、光らない (この値は LED とオシロで変わる目安)
- 触れた後 (X2): CH2 は 2 段ぶんの V<sub>BE</sub> (約 1.4 V) で頭打ちになり、
  CH1 は約 0.8 V まで落ちる (Q2 の V<sub>BE</sub> + Q1 の飽和電圧)。LED が点く
- 指が乾いていて電流が足りないときは、CH1 が 0.8 V まで落ちきらず 50/60 Hz の
  ハム (指が拾う商用電源) でゆれる。そのときは指を湿らせるか `RB` を大きくする

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| RC | 抵抗 (1/4 W) | 470 Ω |
| RB | 抵抗 (1/4 W) | 1 MΩ |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| Q1, Q2 | NPN トランジスタ | 2SC1815 |
| TP1, TP2 | 触れる金属板 (アルミ箔、ねじの頭など) | — |
| — | 電源 | Analog Discovery の V+ (5 V) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 触れていないときの LED | 消灯 | RB が Q1 のベースを GND に落としている |
| 両方の板に指で触れたときの LED | 点灯 (約 5.5mA、計算値) | わずかな指の電流でも十分に飽和する |
| 触れる前の CH1 (コレクタ) / CH2 (ベース) | 約 3.5 V (目安) / 0 V | Tr は OFF、ベースは RB で GND |
| 触れたときの CH2 (Q1 のベース) | 約 1.4 V | V<sub>BE</sub> 2 段ぶんで頭打ち |
| 触れたときの CH1 (Q2 の C-E 間電圧) | 約 0.8 V | ダーリントンは 1 段の Tr (約 0.1〜0.2 V) より大きい飽和電圧が残る |
| RB を 100kΩ に替えたとき | 指の乾き具合によっては点かないことがある | RB が小さすぎると指の電流の大半が RB に逃げてしまう |

## 出典

自作。
