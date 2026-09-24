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
非反転入力は GND に直結。利得は −Rf/Rin で、**符号が反転**する。OP アンプの
基本形の 3 つ目。

## 回路図

```circuit
title: 図1 反転増幅
parts:
  B1: battery vp mid 9
  B2: battery mid vm 9
  G1: ground mid
  V1: sine a2 mid 0.1
  Rin: resistor a2 c5 10k
  Rf: resistor c5 c7 100k
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

- **+ 入力を GND に直結**したのが反転増幅の印。OP アンプは − 入力も GND
  近くに保とうとする (仮想接地)
- Rin (10 kΩ) が入力インピーダンス、Rf (100 kΩ) が帰還。
  **利得 = −Rf/Rin = −10 倍**
- 仮想接地のおかげで、Rin に流れ込む電流がそのまま Rf を通って出力へ抜ける
  (電流はどこにも溜まらない、というのが仮想接地の考え方)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上のレールは +9V/GND。V− は赤レールに乗せず、BAT から直配線する
board: half
parts:
  U1: dip8 @ e10 LM358
  Rin: resistor g5 g11 10k
  Rf: resistor h10 h11 100k
  GEN:
    type: device
    at: top
    label: 発振器 1kHz 0.1V
    pins: [OUT, GND]
  BAT:
    type: device
    at: bottom
    label: 電源 ±9V
    pins: [V+, GND, V-]
wires:
  - GEN.OUT -- a5 yellow
  - e5 -- f5 yellow
  - GEN.GND -- -t5 black
  - i12 -- -t12 black
  - +t10 -- a10 red
  - BAT.V+ -- +t20 red
  - BAT.GND -- -t20 black
  - BAT.V- -- j13 orange
```

- **IN+ (3 番、12 列) は `i12--(-t12)` で GND に直結。** 分圧は要らない
- **IN− (2 番、11 列) に Rin と Rf の両方が集まる。** Rin はここへ信号を入れ、
  Rf はここから出力 (1 番、10 列) へ戻す
- コンデンサ (直流カット) は無い。発振器は 0V を中心に振れるので直結でよい

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方) | LM358 |
| Rin | 抵抗 (入力) | 10 kΩ |
| Rf | 抵抗 (帰還) | 100 kΩ |
| — | 信号源 | 1 kHz、振幅 0.1 V |
| — | 電源 | ±9 V (電池 2 個) |

## 見るべき値

計算値。利得 A = −Rf/Rin。

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
