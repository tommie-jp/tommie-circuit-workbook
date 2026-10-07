---
book: denken
chapter: 2
id: 2-1
title: コンデンサの直列・並列 — 合成容量と分担電圧
tier: 50
source: 自作
board: BB
---

# 2-1 コンデンサの直列・並列 — 合成容量と分担電圧

コンデンサの合成容量は、抵抗の直列・並列 (1-2) と逆になる。**コンデンサは直列にすると
合成容量が小さくなり、並列にすると大きくなる**。同じ 2 個のコンデンサ
(2.2 µF と 4.7 µF) を直列・並列に組んで、電圧の分かれ方の違いも確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| 1/C = 1/C1 + 1/C2 (直列) | 直列の合成容量。個々の容量より必ず小さくなる |
| V1 = V × C2 / (C1 + C2) | 直列につないだコンデンサの分担電圧。**小さい容量のほうが電圧を多く受け持つ** (抵抗の分圧と逆) |
| C = C1 + C2 (並列) | 並列の合成容量。個々の容量より必ず大きくなる |
| Q = C V | 各コンデンサに蓄えられる電荷。並列では両方とも電源電圧そのものが掛かる |

## 回路図

```circuit
title: 図1 直列つなぎ
style:
  standard: jis
  pitch: 1.2
parts:
  E1: battery 1,3 1,5 5
  R1: resistor 1,3 3,3 10k
  S1: switch 3,3 5,3
  C1: capacitor 5,3 7,3 2.2u
  C2: capacitor 7,3 9,3 4.7u
  V1: voltmeter 5,1 7,1
  V2: voltmeter 7,1 9,1
  G1: ground 1,5
wires:
  - 5,1 -- 5,3
  - 7,1 -- 7,3
  - 9,1 -- 9,3
  - 9,3 -- 9,5
  - 1,5 -- 9,5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/circuit/01-capacitors-series-parallel-1.svg)

```circuit
title: 図2 並列つなぎ
style:
  standard: jis
  pitch: 1.2
parts:
  E1: battery 1,3 1,5 5
  R1: resistor 1,3 3,3 10k
  S1: switch 3,3 5,3
  C1: capacitor 7,3 7,5 2.2u
  C2: capacitor 10,3 10,5 4.7u
  G1: ground 1,5
wires:
  - 5,3 -- 7,3 -- 10,3
  - 1,5 -- 7,5 -- 10,5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/circuit/01-capacitors-series-parallel-2.svg)

- E1 は 5 V の電源 (USB の 5 V か AD の Supplies。単 3 電池 3 本の 4.5 V でも可)
- R1 (10 kΩ) は充電の突入電流を抑える電流制限抵抗。S1 を閉じるとコンデンサが
  充電される
- 図1 は C1・C2 が 1 本道 (直列)、図2 は両方とも電源に直接つながる (並列)

## 実体配線図

```breadboard
title: 図3 直列のブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c3 c8 10k
  S1: switch d8 d10
  C1: capacitor/film c10 c15 2.2u
  C2: capacitor/film d15 d20 4.7u
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, "1+", "1-", "2+", "2-"]
wires:
  - AD.V+ -- a3 red
  - AD.GND -- -t6 black
  - AD.1+ -- a10 blue
  - AD.1- -- b15 orange
  - AD.2+ -- a15 white
  - AD.2- -- b20 green
  - a20 -- -t20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/breadboard/01-capacitors-series-parallel.svg)

- AD の V+ が 3 列 (R1 の左端)、GND が青レール。CH1 (1+・1−) は C1 の両端 (10 列と 15 列)、
  CH2 (2+・2−) は C2 の両端 (15 列と 20 列)。C2 の右リード (20 列) も青レールにつなぐ
- S1 (スイッチ) を実際に挿す。閉じてから数秒待てば十分充電される
  (時定数は R1 × 合成容量で 15 ms ほど。過渡現象は 5 章で扱う)
- 並列にするには、C2 の左リードを C1 の左リードと同じ列 (10 列) に挿し替え、C1 の右リードの
  列 (15 列) から GND レール (−t) へ黒い線を 1 ピンす。C2 を挿し替えるだけだと
  C1 の右リード (15 列) がどこにもつながらず、C1 が回路から外れてしまう

## 計器の設定

AD の Supplies で 5 V を出し、Scope で C1 と C2 の電圧を同時に見る (テスターでも各コンデンサの電圧は読める)。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V (電源を入れてから S1 を閉じる) |
| Scope | CH1 = C1 の両端、CH2 = C2 の両端 (どちらも差動)。DC 結合、1 V/div、Time base 20 ms/div。Trigger は CH1 の立ち上がり 0.1 V、Single |
| テスター | 直流電圧レンジ。S1 を閉じて 1 秒ほど待ってから、各コンデンサの両端に当てる |

```scope
title: 図4 S1 を閉じると C1 (CH1) は 3.41 V、C2 (CH2) は 1.59 V まで充電される
time: 20ms/div
trigger: ch1 rising 0.1V at -1div
ch1: {wave: "= 3.41V * step(t) * (1 - exp(-t/15ms))", range: 1V/div, position: -3div}
ch2: {wave: "= 1.59V * step(t) * (1 - exp(-t/15ms))", range: 1V/div, position: -3div}
cursors: [0, 15ms]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/scope/01-capacitors-series-parallel.svg)

2 つの電圧は同じ時定数 15 ms (= R1 × 直列の合成容量 10 kΩ × 1.5 µF) で立ち上がり、
最後に 3.41 V : 1.59 V (= C2 : C1 = 4.7 : 2.2) に落ち着く。

### オシロスコープと発振器

発振器は使わない (電源は直流の 5 V)。汎用オシロでは、CH2 の先端を 15 列、CH1 の先端を 10 列に当て、
グランドクリップは 2 本とも青レール。CH2 がそのまま C2 の電圧 (15 列は C2 の + 側で、20 列が GND)、
C1 の電圧は Math の CH1 − CH2 で読む。

## 見るべき値

計算値 (V = 5 V、C1 = 2.2 µF、C2 = 4.7 µF)。単 3 電池 3 本 (4.5 V) なら電圧・電荷とも 0.9 倍になる。

| 配線 | 測る所 | 期待する値 |
| --- | --- | --- |
| 直列 | 合成容量 | 1.5 µF |
| 直列 | V1 (C1 の電圧) | 3.41 V |
| 直列 | V2 (C2 の電圧) | 1.59 V (V1 + V2 = 5.0 V) |
| 並列 | 合成容量 | 6.9 µF |
| 並列 | C1・C2 の電圧 | どちらも 5.0 V |
| 並列 | C1 の電荷 Q1 = C1 V | 11.0 µC |
| 並列 | C2 の電荷 Q2 = C2 V | 23.5 µC |

分かること:

- **直列では容量の小さいほう (C1 = 2.2 µF) に大きい電圧が掛かる。** 直列の
  コンデンサは電荷 Q が共通なので、V = Q / C から容量が小さいほど電圧が
  大きくなる。抵抗の分圧 (大きい抵抗に大きい電圧) とは逆の関係
- **並列では両方に電源電圧がそのまま掛かる。** 電荷は容量に比例して分かれる
  (Q1 : Q2 = C1 : C2 = 2.2 : 4.7)
- 直列の合成容量 (1.5 µF) は、小さいほう (2.2 µF) よりさらに小さくなる

## 出典

自作。
