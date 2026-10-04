---
book: circuits
chapter: 4
id: 4-5
title: 加算 (ミキサー)
tier: 50
source: 自作
board: BB
---

# 4-5 加算 (ミキサー)

4-3 の反転増幅の入力抵抗を複数にすると、**それぞれの信号を足し合わせて反転する**
ミキサーになる。音声を混ぜるミキサーの基本形はこれ。OP アンプの基本形の
5 つ目。この題では 1 kHz と 3 kHz の正弦波を混ぜ、出力が 2 つの和を裏返した波になることを確かめる。

## 回路図

```circuit
title: 図1 加算アンプ
parts:
  B1: battery vp mid 5
  B2: battery mid vm 5
  G1: ground c2
  V1: sine b3 d3 0.2
  G2: ground d3
  V2: sine d4 f4 0.1
  G3: ground f4
  R1: resistor b3 b6 10k
  R2: resistor d4 d6 10k
  Rf: resistor a6 a9 10k
  U1: opamp c8c0b0 +down
  G4: ground d7
  OUT: port c10c0b0
points:
  vp: a1
  vm: e1
  mid: c1
wires:
  - mid -- c2
  - a6 -- b6 -- c6 -- d6
  - c6 -| U1.-
  - d7 |- U1.+
  - a9 -- c9c0b0
  - U1.out -- c9c0b0 -- c10c0b0
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/05-summing-amp.svg)

- 左の B1・B2 は OP アンプの ±5 V 電源 (4-1 と同じ)
- V1 (1 kHz、振幅 0.2 V) と V2 (3 kHz、振幅 0.1 V) が **同じ − 入力の 1 点 (仮想接地) に
  R1・R2 で合流**する。− 入力は仮想接地 (4-3 で見た) で 0 V に保たれるので、
  V1 と V2 は互いの信号を押し返し合わず、それぞれの電流が Rf で足し合わされる
- **R1 = R2 = Rf = 10 kΩ なので、Vout = −(V1 + V2)。** 抵抗を変えれば
  チャンネルごとに音量を変えられる (Rf/R1、Rf/R2 がそれぞれの利得)
- 非反転入力は GND 直結 (4-3 の反転増幅と同じ)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上下のレールは +5V/GND (1 列目で渡す)。V− は赤レールに乗せず、BAT から直配線する
board: half
parts:
  U1: dip8 @ e10 LM358
  R1: resistor c4 c15 10k
  R2: resistor h6 h11 10k
  Rf: resistor i11 i10 10k
  GEN:
    type: device
    at: top
    label: 発振器 2ch (1kHz 0.2V / 3kHz 0.1V)
    pins: [OUT1, OUT2, GND]
  BAT:
    type: device
    at: bottom
    label: 電源 ±5V
    pins: [V+, GND, V-]
wires:
  - GEN.OUT1 -- a4 yellow
  - GEN.OUT2 -- a6 green
  - e6 -- g6 green
  - GEN.GND -- -t9 black
  - d15 -- f15 orange
  - g15 -- g11 orange
  - j12 -- -b12 black
  - +t10 -- a10 red
  - +t1 -- +b1 red
  - -t1 -- -b1 black
  - BAT.V+ -- +b8 red
  - BAT.GND -- -b10 black
  - BAT.V- -- j13 blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/05-summing-amp.svg)

- 図2 の GEN は図1 の V1・V2 (2 出力の発振器。OUT1 が V1、OUT2 が V2)、BAT は B1・B2 に当たる
- **R1 (上ブロック 4→15 列、溝をまたいで 11 列へ) と R2 (6→11 列) が IN− (11 列、PIN 2) の
  1 点に合流**。
  Rf (11→10 列) が出力 (10 列、PIN 1) へ帰還する
- IN+ (12 列、PIN 3) は `j12--(-b12)` で GND に直結

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方) | LM358 |
| R1, R2 | 抵抗 (入力) | 10 kΩ |
| Rf | 抵抗 (帰還) | 10 kΩ |
| — | 信号源 | 1 kHz 0.2V (出力 1)、3 kHz 0.1V (出力 2) |
| — | 電源 | ±5 V (電池 2 個) |

## 見るべき値

発振器には Analog Discovery の W1 (1 kHz・振幅 0.2 V) と W2 (3 kHz・振幅 0.1 V) を使える。オシロの CH1 を
出力 (10 列) に当て、片方ずつ止めたときと両方入れたときの波を比べる。表の値は計算値。Vout = −(Rf/R1 × V1 + Rf/R2 × V2)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| V1 だけ入れたときの出力振幅 | 0.2 V (反転) | −10k/10k × 0.2V |
| V2 だけ入れたときの出力振幅 | 0.1 V (反転) | −10k/10k × 0.1V |
| 両方入れたときの出力のピーク | 0.3 V 以下 (2 つの位相の関係で変わる) | 2 つの正弦波の和。3 kHz は 1 kHz のちょうど 3 倍なので、オシロでは 1 kHz の周期でくり返す波に見える |
| 出力波形の周波数成分 (スペクトラムで見る場合) | 1 kHz と 3 kHz の 2 本 | 混ざっても周波数は保たれる (入力を足すと出力も足し算になる、線形回路の性質) |

R1・R2 を別の値にすると「CH1 を大きく、CH2 を小さく」のようなミキサーの
音量バランスが作れる (利得はそれぞれ Rf/R1、Rf/R2 で独立に決まる)。

## 出典

自作。
