---
book: circuits
chapter: 4
id: 4-3
title: 反転増幅
tier: 50
source: 自作
board: BB
---

# 4-3 反転増幅

信号を − 入力へ抵抗 (Rin) で入れ、出力から同じ − 入力へ抵抗 (Rf) で帰還をかける。
非反転入力 (+ 入力) は GND に直結。利得は −Rf/Rin で、**符号が反転**する。OP アンプの
基本形の 3 つ目。この題では 1 kHz の正弦波を入れ、出力が 10 倍の大きさで逆向きに出ることを確かめる。

## 回路図

```circuit
title: 図1 反転増幅
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground c2
  V1: sine b3 d3 0.1
  G2: ground d3
  Rin: resistor b3 b6 10k
  Rf: resistor a6 a9 100k
  U1: opamp c8 +down
  G3: ground d7
  OUT: port c10
points:
  vp: a1
  vm: e1
  mid: c1
wires:
  - mid -- c2
  - b6 |- U1.-
  - d7 |- U1.+
  - b6 -- a6
  - a9 -- c9
  - U1.out -- c9 -- c10
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/03-inverting-amp.svg)

- 左の VP・VN は OP アンプの ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1 と同じ)
- **+ 入力を GND に直結**したのが反転増幅の印。OP アンプは + 入力 = − 入力になるように出力を
  動かすので、− 入力は GND につながっていないのに 0 V に保たれる。これを**仮想接地**と呼ぶ
- Rin (10 kΩ) が入力インピーダンス、Rf (100 kΩ) が帰還。
  **利得 = −Rf/Rin = −10 倍**
- − 入力が 0 V なので、Rin には 入力 ÷ Rin の電流が流れる。OP アンプの入力には電流が
  流れ込まないので、この電流はそのまま Rf を通って出力へ抜ける。Rf の両端の電圧は
  電流 × Rf なので、出力 = −入力 × Rf/Rin になる

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
  U1: dip8 @ e10 LM358
  Rin: resistor g6 g11 10k
  Rf: resistor i10 i11 100k
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t2 black
  - AD3.V- -- -b3 blue
  - AD3.W1 -- a6 yellow
  - e6 -- f6 yellow
  - +t10 -- a10 red
  - j13 -- -b13 blue
  - h12 -- h15 black
  - f15 -- e15 black
  - a15 -- -t15 black
notes:
  - text below: 上の赤レール = +5V、上の青レール = GND、下の青レール = −5V (V−)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/03-inverting-amp.svg)

- 図2 の AD3 は、Supplies (V+・V−) が図1 の VP・VN、W1 が V1 (発振器) に当たる。
  電源のレールの分け方は 4-1 と同じ (下の青レールは −5V で、GND ではない)
- **IN+ (PIN 3、12 列) は GND に直結。** `h12--h15`、溝をまたぐ線、`a15--(-t15)` の
  3 本の黒い線で上の青レールへつなぐ。分圧は要らない
- **IN− (PIN 2、11 列) に Rin と Rf の両方が集まる。** W1 の信号は 6 列で溝をまたいで下ブロックへ下り、
  Rin (6→11 列) を通ってここへ入る。Rf はここから出力 (PIN 1、10 列) へ戻す
- コンデンサ (直流カット) は無い。発振器は 0V を中心に振れるので直結でよい

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方) | LM358 |
| Rin | 抵抗 (入力) | 10 kΩ |
| Rf | 抵抗 (帰還) | 100 kΩ |
| — | 信号源 | 1 kHz、振幅 0.1 V |
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |

## 見るべき値

測り方は 4-2 と同じ (発振器は AD の W1、CH1 を入力、CH2 を出力の 10 列)。表の値は計算値。利得 A = −Rf/Rin。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 出力振幅 | 1.0 V | 0.1 V × 10 |
| 位相 | 入力と 180° ずれる (反転) | 反転増幅の名の由来 |
| 利得 | −10 倍 (20 dB) | −Rf/Rin = −100k/10k |
| 入力インピーダンス | 10 kΩ (Rin そのもの) | 4-2 (非反転、Rb=100 kΩ) より低い |

**入力インピーダンスが Rin で決まってしまう**のが反転増幅の弱点。
高いインピーダンスが欲しい信号源には 4-2 の非反転を使う。

## 出典

自作。
