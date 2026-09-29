---
book: circuits
chapter: 5
id: 5-1
title: 半波・全波・ブリッジ整流と平滑 (低圧 AC)
tier: 50
source: 自作
board: BB
---

# 5-1 半波・全波・ブリッジ整流と平滑 (低圧 AC)

交流を直流にする最初の一歩。ダイオード 4 本を組んだ**ブリッジ整流**と、
電解コンデンサによる**平滑**を実際に組む。商用電源には直接つながず、
**9 V の AC アダプタ**(または発振器の出力) を交流源として使う。
電圧は、ブレッドボードで扱える 12 V の範囲 (整流後も 12 V 以下、ピークも 20 V 以下) に収まるように 9 V (実効値) にした。

## 回路図

```circuit
title: 図1 ブリッジ整流と平滑
parts:
  D1: diode acL b3 1N4001
  D2: diode acR dcP 1N4001
  D3: diode f3 acL 1N4001
  D4: diode dcN acR 1N4001
  V1: sine d4 d7 12.7
  C1: ecap b10 f10 1000u
  RL: resistor b13 f13 220
points:
  acL: d3
  acR: d8
  dcP: b8
  dcN: f8
wires:
  - acL -- d4
  - d7 -- acR
  - b3 -- dcP -- b10 -- b13
  - f3 -- dcN -- f10 -- f13
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/01-rectifier-filter.svg)

- V1 は 9 V (実効値) の AC アダプタの出力。振幅 (ピーク) は 9 × √2 ≈ 12.7 V
- **D1・D2 が上側 (+ へ)、D3・D4 が下側 (GND へ)** がブリッジ整流の形 (よく見る菱形の図と同じつながりを、ダイオードを縦に並べて描いている)。
  交流のどちらの半周期でも、C1 の + 側には必ず電流が流れ込む
- C1 (1000 µF) が平滑用。RL (220 Ω) は「電気を使う負荷」の代わり
- RL に流れる電流は約 50 mA (下記)、消費電力は 10.9V² / 220Ω ≈ **0.54 W**。
  1/4W・1/2W 抵抗の定格を超えるので、RL は **1W 級**の抵抗
  (酸化金属被膜など) を使う (定格の半分ほどで余裕がある)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  D1: diode f5(A) f7(K) 1N4001
  D2: diode g9(A) g7(K) 1N4001
  D3: diode j11(A) j5(K) 1N4001
  D4: diode i11(A) i9(K) 1N4001
  C1: capacitor/electrolytic g14(+) g18(-) 1000uF
  RL: resistor j14 j18 220
  GEN:
    type: device
    at: top
    label: 9V AC アダプタ
    pins: [AC1, AC2]
wires:
  - GEN.AC1 -- a5 yellow
  - e5 -- g5 yellow
  - GEN.AC2 -- a9 yellow
  - e9 -- g9 yellow
  - i7 -- i14 red
  - g11 -- i18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/01-rectifier-filter.svg)

- **D1・D2 のカソード側 (7 列) が DC+、D3・D4 のアノード側 (11 列) が DC−。**
  7 列に C1 の + 側、11 列に − 側を挿す
- 整流ダイオードは向き (帯のある側がカソード) を必ず確認する。逆にすると
  電流が流れず、AC アダプタと C1 に負担がかかる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| D1〜D4 | 整流ダイオード | 1N4001 |
| C1 | 電解コンデンサ (平滑) | 1000 µF (耐圧 25 V 以上。整流後は約 11 V) |
| RL | 抵抗 (負荷、**1W**、約 0.54 W を消費するため) | 220 Ω |
| — | 交流源 | 9 V AC アダプタ (または発振器、実効値 9 V) — トランスの実験 (6 章) と同じく低圧の AC 入力 |

## 見るべき値

計算値。ダイオード 1 本の順方向電圧を 0.8 V とする (ブリッジは常に 2 本直列)。
リップルは全波整流の式 V<sub>ripple(pp)</sub> ≈ I<sub>dc</sub> / (f<sub>ripple</sub> × C)、
f<sub>ripple</sub> = 2 × 電源周波数 (60 Hz なら 120 Hz)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 整流直後のピーク電圧 | 約 11.1 V (12.7 V − 2 × 0.8 V) | ダイオード 2 本ぶんの電圧降下 |
| C1・RL 後の直流電圧 (平均) | 約 10.9 V | ピークからリップルの半分ぶん下がる |
| リップル電圧 (peak-to-peak) | 約 0.41 V | I<sub>dc</sub> (≈ 50 mA) / (120 Hz × 1000 µF) |
| **計算 (半波整流だったら)**: 同じ C・RL でのリップル | 約 0.83 V (倍) | f<sub>ripple</sub> が 60 Hz になり、リップルが約 2 倍。全波の利点 |

半波整流はダイオード 1 本だけで作れる (D1 と RL を直結、C1 は AC の片側と
RL の間)。ブリッジより部品は少ないが、リップルが大きく、AC アダプタの
片側の半周期しか使わないので効率も悪い。

## 出典

自作。
