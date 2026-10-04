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

信号を + 入力に入れ、出力を抵抗 2 本で分圧して − 入力へ戻す (負帰還。4-1 で見た) と、
**反転せずに増幅**できる。利得は 1 + R3/R2 で、抵抗 2 本だけで決まる。OP アンプの基本形の 2 つ目。
この題では 1 kHz の正弦波を入れ、出力が 11 倍の大きさで同じ向きに出ることを確かめる。

OP アンプは + 入力 = − 入力になるように出力を動かす。− 入力の電圧は出力を R3 と R2 で
分圧した値なので、出力 × R2/(R2+R3) = 入力。これを解くと出力 = 入力 × (1 + R3/R2) になる。

## 回路図

```circuit
title: 図1 非反転増幅
parts:
  VP: vsource a1 c1 5
  VN: vsource c1 e1 5
  G1: ground c2
  V1: sine b4 d4 0.1
  G2: ground d4
  C1: capacitor b4 b6 1u
  Rb: resistor b6 d6 100k
  G3: ground d6
  U1: opamp b9 +up
  R2: resistor d8 f8 1k
  G4: ground f8
  R3: resistor d9 d11 10k
  OUT: port b13
wires:
  - mid -- c2
  - b6 |- U1.+
  - d8 |- U1.-
  - d8 -- d9
  - U1.out -- b12 -- b13
  - d11 -- d12 -- b12
points:
  vp: a1
  vm: e1
  mid: c1
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/02-non-inverting-amp.svg)

- 左の VP・VN は OP アンプの ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1 と同じ)
- V1 は 1 kHz・振幅 0.1 V (0 V から山までの高さ。山から谷までは 0.2 Vpp) の発振器。C1 (1 µF) で直流を切り (交流だけを通す)、Rb (100 kΩ) で
  非反転入力の直流の電位を GND (VP と VN の中点) に決める
- **利得 = 1 + R3/R2 = 1 + 10k/1k = 11 倍。** 出力振幅は 0.1 V × 11 = 1.1 V
- Rb が大きいほど入力インピーダンスは高いが、大きすぎると OP アンプの
  入力バイアス電流 (入力にわずかに流れ込む直流) で誤差が出る (LM358 は数十 nA なので 100 kΩ でも問題ない)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上のレールは +5V (赤) と GND (青)。下の青レールは −5V (V−)。下の赤レールは使わない
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies ±5V・W1)
    pins: [V+, GND, V-, W1]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1-, 2-, 2+, 1+]
  U1: dip8 @ e10 LM358
  C1: capacitor c15 c19 1uF
  Rb: resistor a15 -t15 100k
  R3: resistor g10 g11 10k
  R2: resistor i11 i7 1k
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t2 black
  - AD3.V- -- -b3 blue
  - AD3.W1 -- a19 yellow
  - SC.1+ -- j12 orange
  - SC.2+ -- j10 green
  - SC.1- -- h7 black
  - SC.2- -- j7 black
  - +t10 -- a10 red
  - j13 -- -b13 blue
  - e15 -- f15 orange
  - g15 -- g12 orange
  - f7 -- e7 black
  - a7 -- -t7 black
notes:
  - text below: 上の赤レール = +5V、上の青レール = GND、下の青レール = −5V (V−)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/02-non-inverting-amp.svg)

- 図2 の AD3 は、Supplies (V+・V−) が図1 の VP・VN、W1 が V1 (発振器) に当たる。
  電源のレールの分け方は 4-1 と同じ (下の青レールは −5V で、GND ではない)。
  Scope は板の下に別の箱 (AD3 Scope) で描いた。1+ (橙) は IN+ の 12 列 (`j12`)、2+ (緑) は出力の 10 列 (`j10`) に挿し、1− と 2− (黒) は R2 の GND 側の 7 列 (`h7`・`j7`。上の青レールにつながっている) へ挿す
- **W1 (19 列) の信号を C1 で受け、15 列から溝をまたぐ線と `g15--g12` で IN+ (PIN 3、12 列) へ。**
  Rb は 15 列の a の穴から上の青レール (GND) へ立てて挿すバイアス抵抗 (直流だけを GND へ逃がす)
- R3 (帰還) は出力 (PIN 1、10 列) と IN− (PIN 2、11 列) をつなぐ。R2 は 11 列から 7 列へ渡し、
  7 列から溝をまたぐ黒い線と `a7--(-t7)` で GND へ落とす
- PIN 8 (10 列) は `+t10--a10` で +5V へ、PIN 4 (13 列) は `j13--(-b13)` で −5V へ

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。1 kHz の正弦波の形・振幅・向きを見る題で、10 MHz よりずっと低いから。
W1 は 1 kHz・振幅 0.1 V の正弦波 (オフセット 0 V) に、Scope は CH1 を入力、CH2 を出力にして、トリガは CH1 の立ち上がり 0 V にする。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Sine、1 kHz、振幅 0.1 V、オフセット 0 V |
| Scope CH1 (入力、12 列) | DC、500 mV/div |
| Scope CH2 (出力、10 列) | DC、500 mV/div |
| Time | 200 µs/div (1 kHz が 2 周期) |
| Trigger | CH1、立ち上がり、0 V |

```scope
title: 図3 入力 (CH1) と出力 (CH2) — 出力は 11 倍で同じ向き
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.1V, range: 500mV/div}
ch2: {wave: sine 1kHz 1.1V, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/02-non-inverting-amp.svg)

図3 は 2 本とも 500 mV/div。CH1 (入力) は 0.2 Vpp (0.4 目盛) の小さな波、CH2 (出力) は 2.2 Vpp (4.4 目盛) で、高さは 11 倍。
山と谷は同じ時刻に来るので、向きは反転しない。入力が小さくて読みにくいときは、CH1 だけ 50 mV/div に切り替えて形を見る。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方) | LM358 |
| C1 | セラミックコンデンサ (直流カット) | 1 µF |
| Rb | 抵抗 (+入力のバイアス) | 100 kΩ |
| R2 | 抵抗 | 1 kΩ |
| R3 | 抵抗 (帰還) | 10 kΩ |
| — | 信号源 | 1 kHz、振幅 0.1 V |
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |
| — | 計器 | AD3 の W1 (信号源)・Scope 1+/2+ (入力と出力) |

## 見るべき値

発振器は AD3 の W1 (1 kHz・振幅 0.1 V の正弦波)。オシロの CH1 を入力 (12 列)、
CH2 を出力 (10 列) に当て、2 本を重ねて振幅と向きを比べる (図3)。表の値は計算値。利得 A = 1 + R3/R2。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 入力振幅 (+入力、12 列) | 0.1 V | 発振器の出力そのまま (C1 は交流を通す) |
| 出力振幅 (10 列) | 1.1 V | 0.1 V × 11。位相は入力と同じ (反転しない) |
| 利得 | 11 倍 (20.8 dB。dB は 1-5 で見た) | 1 + 10k/1k |
| R3 を 20 kΩ に替えたときの利得 | 21 倍 | 1 + 20k/1k。R3 だけで利得を変えられる |

利得を 1 倍 (R3 = 0、または R3 を外して直結) にすると 4-1 のフォロアと同じになる。
非反転増幅はフォロアの一般形と見られる。

## 出典

自作。
