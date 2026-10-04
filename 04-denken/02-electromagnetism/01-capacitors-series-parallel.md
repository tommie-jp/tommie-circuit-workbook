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
  E1: battery c1 e1 5
  R1: resistor c1 c3 10k
  S1: switch c3 c5
  C1: capacitor c5 c7 2.2u
  C2: capacitor c7 c9 4.7u
  V1: voltmeter a5 a7
  V2: voltmeter a7 a9
  G1: ground e1
wires:
  - a5 -- c5
  - a7 -- c7
  - a9 -- c9
  - c9 -- e9
  - e1 -- e9
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/circuit/01-capacitors-series-parallel-1.svg)

```circuit
title: 図2 並列つなぎ
style:
  standard: jis
  pitch: 1.2
parts:
  E1: battery c1 e1 5
  R1: resistor c1 c3 10k
  S1: switch c3 c5
  C1: capacitor c7 e7 2.2u
  C2: capacitor c10 e10 4.7u
  G1: ground e1
wires:
  - c5 -- c7 -- c10
  - e1 -- e7 -- e10
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/circuit/01-capacitors-series-parallel-2.svg)

- E1 は 5 V の電源 (USB の 5 V か AD の Supplies。単 3 電池 3 本の 4.5 V でも可)
- R1 (10 kΩ) は充電の突入電流を抑える電流制限抵抗。S1 を閉じるとコンデンサが
  充電される
- 図1 は C1・C2 が 1 本道 (直列)、図2 は両方とも電源に直接つながる (並列)

## 実体配線図

```breadboard
title: 図3 直列のブレッドボード
board: half
parts:
  R1: resistor c3 c8 10k
  S1: switch d8 d10
  C1: capacitor/film c10 c15 2.2u
  C2: capacitor/film d15 d20 4.7u
  BAT:
    type: device
    at: top
    label: "電源 5V"
    pins: ["+", "-"]
wires:
  - BAT.+ -- a3 red
  - BAT.- -- -t6 black
  - a20 -- -t20 black
notes:
  - text: "V1 (電圧レンジ) を C1 の両端 (10・15 列) に当てる"
  - text: "V2 (電圧レンジ) を C2 の両端 (15・20 列) に当てる"
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/breadboard/01-capacitors-series-parallel.svg)

- S1 (スイッチ) を実際に挿す。閉じてから数秒待てば十分充電される
  (時定数は R1 × 合成容量で 15 ms ほど。過渡現象は 5 章で扱う)
- 並列にするには、C2 の左足を C1 の左足と同じ列 (10 列) に挿し替え、C1 の右足の
  列 (15 列) から GND レール (−t) へ黒い線を 1 本足す。C2 を挿し替えるだけだと
  C1 の右足 (15 列) がどこにもつながらず、C1 が回路から外れてしまう

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| テスター | 直流電圧レンジ。S1 を閉じて 1 秒ほど待ってから、各コンデンサの両端に当てる |

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
