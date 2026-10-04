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

トランジスタ 2 つを、**Q1 のエミッタから Q2 のベースへ**つなぎ、2 つのコレクタどうしもつなぐと、
全体の電流増幅率が 2 つの hFE の掛け算になる (ダーリントン接続)。指の皮膚 (数百 kΩ) を通る
ほどのわずかな電流でも、LED を光らせるだけの電流に増幅できる。

この題では、2 枚の金属板に指で触れると LED が点くスイッチを作り、オシロで触れた瞬間の
ベースとコレクタの電圧を見る。

## 回路図

```circuit
title: 図1 ダーリントンで作る指タッチスイッチ (CH2 でベース、CH1 でコレクタを見る)
parts:
  VCC: vcc b2 5V
  TP1: port b4
  TP2: port g3
  RB: resistor g4 i4 1M
  G2: ground i4
  Q1: npn g7
  Q2: npn h9
  RC: resistor b9 d9 470
  D1: led d9 f9
  G3: ground i9
  M2: voltmeter g3 i3 l=$\mathrm{CH2}$
  G5: ground i3
  M1: voltmeter f11 i11 l=$\mathrm{CH1}$
  G4: ground i11
wires:
  - b2 -- b4 -- b9
  - g3 -- g4 -- Q1.B
  - Q1.E |- Q2.B
  - f9 -| Q1.C
  - f9 -- Q2.C
  - Q2.E -- i9
  - f9 -- f11
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/04-darlington-touch.svg)

図1 の `TP1` と `TP2` が指で触れる 2 枚の金属板 (アルミ箔やねじの頭など)。指で 2 枚にまたがって
触れると、+5V から指を通ってベースへ電流が流れる。
触れていないときは `RB` (1MΩ) が Q1 のベースを GND 側に引いて OFF に保つ。

- 指の抵抗 (仮に 500kΩ とする、実際は 100kΩ〜1MΩ 程度と幅がある) を通って
  ベースの節点に流れ込む電流: I ≈ (5V − 1.4V) / 500kΩ ≈ **7.2 µA**
  (1.4V はダーリントンのベース-エミッタ 2 段ぶん)。`RB` (1MΩ) は同じ節点から
  GND へも 1.4V / 1MΩ ≈ **1.4 µA** を引き取るので、Q1 のベースに実際に
  入る電流は差し引き 7.2 − 1.4 ≈ **5.8 µA** (計算値)
- 2SC1815 の hFE を 200 と仮定すると、ダーリントン全体の電流増幅率は
  200 × 200 = **40000** (理論値。実際は洩れ電流などで数千程度に下がることが多い)
- LED の電流は増幅率ではなく **RC で頭打ちになる** (十分に飽和するため):
  I<sub>C</sub> = (5 − V<sub>CE(sat)</sub> − V<sub>F</sub>) / RC ≈ (5 − 0.8 − 2.0) / 470
  ≈ **4.7 mA** (計算値。ダーリントンの V<sub>CE(sat)</sub> は約 0.8 V)
- 飽和に必要な最小ベース電流は 4.7mA / 40000 ≈ 0.12µA。指の電流 (約 5.8µA)
  は実際の (理想より低い) 増幅率で見ても十分足りる — これが「軽く触れるだけで
  点く」理由

## 実体配線図

```breadboard
title: 図2 ダーリントンタッチスイッチ
# 5V は AD の V+ から上の + レールへ、GND は上の − レール (下のレールは使わない)
board: half
parts:
  RB: resistor b7 b12 1M
  Q1: transistor e12(B) e13(C) e14(E) 2SC1815
  Q2: transistor e17(B) e18(C) e19(E) 2SC1815
  RC: resistor b25 b20 470
  D1: led c20(A) c18(K) red
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
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [2-, 2+, 1+, 1-, V+, GND]
wires:
  - AD.V+ -- +t29 red
  - AD.GND -- -t30 black
  - a7 -- -t7 black
  - AD.2- -- -t9 black
  - AD.2+ -- a12 blue
  - d4 -- d12 blue
  - TP2.B -- a4 gray
  - b13 -- b18 orange
  - c14 -- c17 blue
  - a19 -- -t19 black
  - +t25 -- a25 red
  - AD.1+ -- a18 orange
  - AD.1- -- -t27 black
  - TP1.A -- +t3 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/04-darlington-touch.svg)

図2 のとおり、部品はすべて上のブロックに挿す。5V は Analog Discovery 3 の電源出力 V+ (赤、右端の `+t29`) から
上の + レールへ入れる (WaveForms の Supplies で V+ を 5 V にして入れる)。
流れるのは LED の約 4.7 mA だけなので V+ で足りる。GND は上の − レールだけを使う。

- `Q1`・`Q2` は上のブロックの e 行 (`e12`〜`e14`・`e17`〜`e19`)。足の上の a〜d 行を線の通り道にする
- **ベース (列 12)**: `RB` の右端 (`b12`) が `Q1` の B と同じ列。`RB` の左端は `a7` から − レールへ。
  `TP2` (触れる板 2) は `a4` に挿し、`d4`–`d12` の青線で列 12 へ渡す
- **Q1 の E → Q2 の B**: `c14`–`c17` の青線。**Q1 の C → Q2 の C**: `b13`–`b18` の橙線
- **コレクタ (列 18)**: LED のカソード (`c18`) が `Q2` の C と同じ列。LED のアノード (`c20`) は
  `RC` の左端 (`b20`) と同じ列、`RC` の右端は `a25` から + レールへ
- `Q2` のエミッタは `a19` から − レールへ。`TP1` (触れる板 1) は + レール (`+t3`) へ
- **CH1 (1+、橙)** はコレクタの列 18 (`a18`)、**CH2 (2+、青)** はベースの列 12 (`a12`)。
  AD の GND・1−・2− (黒) は上の − レールへ

## オシロで見る

CH1 を 1 V/div、CH2 を 500 mV/div、時間軸を 20 ms/div にする。トリガは CH2 の立ち上がり
(0.7 V) で、1 回だけ画面を止める Single にしてから両方の板に指で触れる (図3)。

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
| 両方の板に指で触れたときの LED | 点灯 (約 4.7mA、計算値) | わずかな指の電流でも十分に飽和する |
| 触れる前の CH1 (コレクタ) / CH2 (ベース) | 約 3.5 V (目安) / 0 V | トランジスタは OFF、ベースは RB で GND |
| 触れたときの CH2 (Q1 のベース) | 約 1.4 V | V<sub>BE</sub> 2 段ぶんで頭打ち |
| 触れたときの CH1 (Q2 の C-E 間電圧) | 約 0.8 V | ダーリントンは 1 段のトランジスタ (約 0.1〜0.2 V) より大きい飽和電圧が残る |
| RB を 100kΩ に替えたとき | 指の乾き具合によっては点かないことがある | RB が小さすぎると指の電流の大半が RB に逃げてしまう |

## 出典

自作。
