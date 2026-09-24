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
**12 V 前後の AC アダプタ**(または発振器の出力) を交流源として使う。

## 回路図

```circuit
title: 図1 ブリッジ整流と平滑
parts:
  D1: diode acL dcP 1N4001
  D2: diode acR dcP 1N4001
  D3: diode dcN acL 1N4001
  D4: diode dcN acR 1N4001
  V1: sine g3 g9 17
  C1: ecap dcP dcN 1000u
  RL: resistor a12 e12 220
points:
  acL: c3
  acR: c9
  dcP: a6
  dcN: e6
wires:
  - g3 -- acL
  - g9 -- acR
  - dcP -- a12
  - dcN -- e12
style:
  grid: on
```

- V1 は 12 V (実効値) の AC アダプタの出力。振幅 (ピーク) は 12 × √2 ≈ 17 V
- **D1・D2 が上側 (+ へ)、D3・D4 が下側 (GND へ)** の菱形がブリッジ整流の形。
  交流のどちらの半周期でも、C1 の + 側には必ず電流が流れ込む
- C1 (1000 µF) が平滑用。RL (220 Ω) は「電気を使う負荷」の代わり

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  D1: diode f5(A) f7(K) 1N4001
  D2: diode g9(A) g7(K) 1N4001
  D3: diode h11(A) h5(K) 1N4001
  D4: diode i11(A) i9(K) 1N4001
  C1: capacitor/electrolytic g14(+) g18(-) 1000uF
  RL: resistor j14 j18 220
  GEN:
    type: device
    at: top
    label: 12V AC アダプタ
    pins: [AC1, AC2]
wires:
  - GEN.AC1 -- a5 yellow
  - e5 -- g5 yellow
  - GEN.AC2 -- a9 yellow
  - e9 -- g9 yellow
  - i7 -- i14 red
  - g11 -- i18 black
```

- **D1・D2 のカソード側 (7 列) が DC+、D3・D4 のアノード側 (11 列) が DC−。**
  7 列に C1 の + 側、11 列に − 側を挿す
- 整流ダイオードは向き (帯のある側がカソード) を必ず確認する。逆にすると
  電流が流れず、AC アダプタと C1 に負担がかかる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| D1〜D4 | 整流ダイオード | 1N4001 |
| C1 | 電解コンデンサ (平滑) | 1000 µF (耐圧 25 V 以上) |
| RL | 抵抗 (負荷) | 220 Ω |
| — | 交流源 | 12 V AC アダプタ (または発振器、実効値 12 V) |

## 見るべき値

計算値。ダイオード 1 本の順方向電圧を 0.8 V とする (ブリッジは常に 2 本直列)。
リップルは全波整流の式 V<sub>ripple(pp)</sub> ≈ I<sub>dc</sub> / (f<sub>ripple</sub> × C)、
f<sub>ripple</sub> = 2 × 電源周波数 (60 Hz なら 120 Hz)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 整流直後のピーク電圧 | 約 15.4 V (17 V − 2 × 0.8 V) | ダイオード 2 本ぶんの電圧降下 |
| C1・RL 後の直流電圧 (平均) | 約 15.1 V | ピークからリップルの半分ぶん下がる |
| リップル電圧 (peak-to-peak) | 約 0.57 V | I<sub>dc</sub> (≈ 69 mA) / (120 Hz × 1000 µF) |
| **計算 (半波整流だったら)**: 同じ C・RL でのリップル | 約 1.12 V (倍近い) | f<sub>ripple</sub> が 60 Hz になり、リップルが約 2 倍。全波の利点 |

半波整流はダイオード 1 本だけで作れる (D1 と RL を直結、C1 は AC の片側と
RL の間)。ブリッジより部品は少ないが、リップルが大きく、AC アダプタの
片側の半周期しか使わないので効率も悪い。

## 出典

自作。
