---
book: circuits
chapter: 4
id: 4-2
title: 非反転増幅
tier: 50
source: 自作
board: BB
---

# 4-2 非反転増幅

信号を + 入力に入れ、− 入力へ抵抗で帰還をかけると、**反転せずに増幅**できる。
利得は 1 + R3/R2 で、抵抗 2 本だけで決まる。OP アンプの基本形の 2 つ目。

## 回路図

```circuit
title: 図1 非反転増幅
parts:
  B1: battery vp mid 9
  B2: battery mid vm 9
  G1: ground mid
  V1: sine a2 mid 0.1
  C1: capacitor a2 b2 1u
  Rb: resistor b2 mid 100k
  U1: opamp b4 +up
  R2: resistor c3 mid 1k
  R3: resistor c3 c5 10k
  OUT: port b6
points:
  vp: a1
  vm: e1
  mid: c1
wires:
  - b2 |- U1.+
  - c3 |- U1.-
  - U1.out -- b5 -- b6
  - c5 -- b5
style:
  grid: on
```

- V1 は 1 kHz・振幅 0.1 V の発振器。C1 (1 µF) で直流を切り、Rb (100 kΩ) で
  非反転入力を GND (電池の中点) へ持ち上げる (交流だけを通す)
- **利得 = 1 + R3/R2 = 1 + 10k/1k = 11 倍。** 出力振幅は 0.1 V × 11 = 1.1 V
- Rb が大きいほど入力インピーダンスは高いが、大きすぎると OP アンプの
  入力バイアス電流で誤差が出る (LM358 は数十 nA なので 100 kΩ でも問題ない)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上のレールは +9V/GND。V− は赤レールに乗せず、BAT から直配線する
board: half
parts:
  U1: dip8 @ e10 LM358
  GEN:
    type: device
    at: top
    label: 発振器 1kHz 0.1V
    pins: [OUT, GND]
  C1: capacitor f5 f8 1uF
  Rb: resistor h12 h7 100k
  R2: resistor j11 j7 1k
  R3: resistor i10 i11 10k
  BAT:
    type: device
    at: bottom
    label: 電源 ±9V
    pins: [V+, GND, V-]
wires:
  - GEN.OUT -- a5 yellow
  - e5 -- g5 yellow
  - GEN.GND -- -t5 black
  - g8 -- g12 orange
  - i7 -- -t7 black
  - +t10 -- a10 red
  - BAT.V+ -- +t20 red
  - BAT.GND -- -t20 black
  - BAT.V- -- j13 orange
```

- **GEN (発振器) の出力を C1 で受け、12 列 (IN+、3 番) へ。** Rb はその 12 列を
  GND へ持ち上げるバイアス抵抗 (直流だけを GND へ逃がす)
- R2 (IN−、11 列) は 7 列で GND へ、R3 (帰還) は 11 列から 10 列 (OUT、1 番) へ
- V− は赤レールに乗せず、`BAT.V- -- j13` で 4 番 (GND/V−) へ直配線する

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方) | LM358 |
| C1 | セラミックコンデンサ (直流カット) | 1 µF |
| Rb | 抵抗 (+入力のバイアス) | 100 kΩ |
| R2 | 抵抗 | 1 kΩ |
| R3 | 抵抗 (帰還) | 10 kΩ |
| — | 信号源 | 1 kHz、振幅 0.1 V |
| — | 電源 | ±9 V (電池 2 個) |

## 見るべき値

計算値。利得 A = 1 + R3/R2。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 入力振幅 (+入力、12 列) | 0.1 V | 発振器の出力そのまま (Rb で交流だけ通る) |
| 出力振幅 (10 列) | 1.1 V | 0.1 V × 11。位相は入力と同じ (反転しない) |
| 利得 | 11 倍 (20.8 dB) | 1 + 10k/1k |
| R3 を 20 kΩ に替えたときの利得 | 21 倍 | 1 + 20k/1k。R3 だけで利得を変えられる |

利得を 1 倍 (R3 = 0、または R3 を外して直結) にすると 4-1 のフォロアと同じになる。
非反転増幅はフォロアの一般形と見られる。

## 出典

自作。
