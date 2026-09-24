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

反転増幅の入力抵抗を複数にすると、**それぞれの信号を足し合わせて反転する**
ミキサーになる。音声を混ぜるミキサーの基本形はこれ。OP アンプの基本形の
5 つ目。

## 回路図

```circuit
title: 図1 加算アンプ
parts:
  B1: battery vp mid 9
  B2: battery mid vm 9
  G1: ground mid
  V1: sine a2 mid 0.2
  V2: sine a4 mid 0.1
  R1: resistor a2 c5 10k
  R2: resistor a4 c5 10k
  Rf: resistor c5 c7 10k
  U1: opamp b6 +up
  OUT: port b8
points:
  vp: a1
  vm: e1
  mid: c1
wires:
  - b4 -- mid
  - b4 |- U1.+
  - c5 |- U1.-
  - U1.out -- b7 -- b8
  - c7 -- b7
style:
  grid: on
```

- V1 (1 kHz、0.2 V) と V2 (3 kHz、0.1 V) が **同じ − 入力の 1 点 (仮想接地) に
  R1・R2 で合流**する。仮想接地なので互いの信号を押し返し合わない
- **R1 = R2 = Rf = 10 kΩ なので、Vout = −(V1 + V2)。** 抵抗を変えれば
  チャンネルごとに音量を変えられる (Rf/R1、Rf/R2 がそれぞれの利得)
- 非反転入力は GND 直結 (4-3 の反転増幅と同じ)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上のレールは +9V/GND。V− は赤レールに乗せず、BAT から直配線する
board: half
parts:
  U1: dip8 @ e10 LM358
  R1: resistor g5 g11 10k
  R2: resistor h7 h11 10k
  Rf: resistor i11 i10 10k
  GEN:
    type: device
    at: top
    label: 発振器 2ch (1kHz 0.2V / 3kHz 0.1V)
    pins: [OUT1, OUT2, GND]
  BAT:
    type: device
    at: bottom
    label: 電源 ±9V
    pins: [V+, GND, V-]
wires:
  - GEN.OUT1 -- a5 yellow
  - e5 -- f5 yellow
  - GEN.OUT2 -- a7 green
  - e7 -- f7 green
  - GEN.GND -- -t3 black
  - j12 -- -t12 black
  - +t10 -- a10 red
  - BAT.V+ -- +t20 red
  - BAT.GND -- -t20 black
  - BAT.V- -- j13 orange
```

- **R1 (5→11 列) と R2 (7→11 列) が IN− (11 列、2 番) の 1 点に合流**。
  Rf (11→10 列) が出力 (10 列、1 番) へ帰還する
- IN+ (12 列、3 番) は `j12--(-t12)` で GND に直結

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方) | LM358 |
| R1, R2 | 抵抗 (入力) | 10 kΩ |
| Rf | 抵抗 (帰還) | 10 kΩ |
| — | 信号源 | 1 kHz 0.2V (CH1)、3 kHz 0.1V (CH2) |
| — | 電源 | ±9 V (電池 2 個) |

## 見るべき値

計算値。Vout = −(Rf/R1 × V1 + Rf/R2 × V2)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| V1 だけ入れたときの出力振幅 | 0.2 V (反転) | −10k/10k × 0.2V |
| V2 だけ入れたときの出力振幅 | 0.1 V (反転) | −10k/10k × 0.1V |
| 両方入れたときの出力 (最大振幅) | 最大 0.3 V まで (周波数が違うのでピークは揃わない) | 2 つの正弦波の和。オシロで見ると「うなり」のような波形 |
| 出力波形の周波数成分 (スペクトラムで見る場合) | 1 kHz と 3 kHz の 2 本 | 混ざっても周波数は保たれる (線形回路の性質) |

R1・R2 を別の値にすると「CH1 を大きく、CH2 を小さく」のようなミキサーの
音量バランスが作れる (利得はそれぞれ Rf/R1、Rf/R2 で独立に決まる)。

## 出典

自作。
