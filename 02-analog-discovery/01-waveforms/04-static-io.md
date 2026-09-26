---
book: analog-discovery
chapter: 1
id: 1-4
title: Static I/O — LED とボタンを DIO で
tier: 50
source: 自作 (公式は WaveForms リファレンスマニュアルの Static I/O)
board: BB
---

# 1-4 Static I/O — LED とボタンを DIO で

Static I/O は、Analog Discovery のデジタル入出力ピン (`DIO0`〜) を
1 本ずつ**手で** High / Low に切り替えたり読んだりできる計器。
ここでは `DIO0` を出力にして LED を点け、`DIO1` を入力にしてボタンを読む。

## 回路図

```circuit
title: 図1 DIO0 で LED を光らせ、DIO1 でボタンを読む
parts:
  AD:
    type: device
    at: e20
    label: Analog Discovery
    pins: [DIO0, V+, DIO1, GND]
  R1: resistor a1 a3 470
  D1: led a5 a7
  SW1: button c11 c13
  R2: resistor c15 c17 10k
  G1: ground a9
wires:
  - a3 -- a5
  - a7 -- a9
  - c13 -- c15
  - c17 |- a9
  - AD.DIO0 -| a1
  - AD.V+ -| c11
  - AD.DIO1 -| c15
  - AD.GND -| a9
```

- `DIO0` → R1 (470 Ω) → LED → GND。Static I/O で `DIO0` を **Output・High**
  にすると LED が点く。**`DIO` の High は Supplies の V+ (5 V) とは別物で、
  3.3 V (LVCMOS3V3) 固定**。既定の駆動能力 (4 mA) に収まるよう R1 は
  330 Ω より大きくしてある
- V+ → SW1 (ボタン) → `DIO1` の節点 → R2 (10 kΩ、プルダウン) → GND。
  ボタンを離しているときは R2 が `DIO1` を GND (Low) に引き、押すと V+
  (5 V) が勝つ。`DIO1` の入力は 5 V トレラント (許容) なので、3.3 V 系の
  ピンに 5 V を入れても壊れない。`DIO1` は **Input** にして状態を読む

## 実体配線図

```breadboard
title: 図2 ブレッドボードで LED とボタンをつなぐ
board: half
parts:
  R1: resistor c3 c8 470
  D1: led d8(A) d10(K) red
  SW1: button @ e20
  R2: resistor j20 j25 10k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [DIO0, GND, DIO1, V+]
wires:
  - AD.DIO0 -- a3 yellow
  - a10 -- -t10 black
  - AD.GND -- -t13 black
  - AD.V+ -- a20 red
  - AD.DIO1 -- h20 green
  - i25 -- -t25 black
```

- SW1 (`@ e20`) は溝をまたぐタクトスイッチ。手前側 (20 列) に V+、
  向こう側 (20 列の下ブロック。R2 の上端 j20 と同じ列) が `DIO1` の節点
- R2 (10 kΩ) は `DIO1` の節点を GND に引くプルダウン

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |
| Static I/O | `DIO0` = Output、`DIO1` = Input |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| `DIO0` を High にしたとき | LED が点く。R1 の電流は約 2.8 mA (計算値。(3.3 − 2.0) / 470 Ω) | デジタル出力ピン (3.3 V, 既定 4 mA 駆動) でも LED を直接駆動できる |
| `DIO0` を Low にしたとき | LED が消える | |
| ボタンを離しているとき `DIO1` | Low (0) | R2 が GND に引いている |
| ボタンを押したとき `DIO1` | High (1) | V+ が R2 の 10 kΩ に打ち勝って引き上げる |

## 出典

自作。計器の名前は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Static I/O の節)。
