---
book: denken
chapter: 11
id: 11-1
title: 照度の逆二乗則 — LED からの距離とフォトダイオードの電流
tier: 50
source: 自作
board: BB
---

# 11-1 照度の逆二乗則 — LED からの距離とフォトダイオードの電流

点光源とみなせる LED からの距離を 2 倍にすると、そこに届く光の強さ (照度) は
1/4 になる。フォトダイオードで光を電流に変え、距離を変えて確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| E ∝ 1 / d² | 照度 E は光源からの距離 d の 2 乗に反比例する (逆二乗則) |
| Iph = E × (受光面の感度) | フォトダイオードの光電流は照度にほぼ比例する |
| Vout = Iph × R | 光電流を抵抗に通して電圧に変え、AD で読む |

## 回路図

```circuit
title: 図1 LED とフォトダイオード
style:
  standard: jis
parts:
  B1: battery a1 e1 4.5
  R1: resistor a1 a3 150
  D1: led a3 e3
  G1: ground e1
  V2: vsource a7 e7 5
  D2: photodiode a9 a7
  R2: resistor a9 e9 100k
  M1: voltmeter a11 e11 l=$\mathrm{CH1}$
wires:
  - e1 -- e3
  - e7 -- e9 -- e11
  - a9 -- a11
```

- 左側 (B1・R1・D1) が発光側。電池で LED を一定の電流 (約 10 mA) で光らせる
- 右側 (V2・D2・R2) が受光側。D2 (フォトダイオード) を逆方向にバイアスし、
  光電流を R2 (100 kΩ) で電圧に変える。CH1 がその電圧
- D1 と D2 を一直線上に向かい合わせ、間の距離 d を変えて測る

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  BAT:
    type: device
    at: top
    label: 電池 4.5V
    pins: ["+", "-"]
  R1: resistor a3 a9 150
  D1: led/5mm b9(A) b12(K)
  SUP:
    type: device
    at: top
    label: AD Supplies 5V
    pins: ["+", "-"]
  D2: photodiode f23(A) f20(K)
  R2: resistor g23 g26 100k
  AD:
    type: device
    at: bottom
    label: Analog Discovery (Scope)
    pins: [1+, 1-]
wires:
  - BAT.+ -- a3 red
  - BAT.- -- c12 black [h15]
  - SUP.+ -- g20 red [h30]
  - SUP.- -- i26 black [h30]
  - AD.1+ -- h23 orange
  - AD.1- -- h26 black
```

- 左 (BAT・R1・D1) が発光側。電池 4.5 V を R1 (150 Ω) で電流を決めて LED を光らせる
- 右 (SUP・D2・R2) が受光側。AD の Supplies 5 V で D2 (フォトダイオード) を
  逆バイアスし、光電流を R2 (100 kΩ) で電圧に変える
- D1 と D2 を板の外で向かい合わせに固定し、間の距離を変える (板には距離は描けない)
- CH1 (1+/1−) は R2 の両端にあてる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| 電源 | LED 側は電池 4.5 V。フォトダイオード側は AD の Supplies 5 V |
| Scope | CH1 = R2 の両端の電圧。Average を取ってから読む |

## 見るべき値

計算値。d = 5 cm のときの読みを基準にした相対値 (絶対値は LED の明るさと
フォトダイオードの感度で変わるので、比だけを確かめる)。

| 距離 d | 期待する CH1 | 5 cm との比 |
| --- | --- | --- |
| 5 cm | 2.00 V (基準) | 1 |
| 10 cm (2 倍) | 0.50 V | 1/4 |
| 20 cm (4 倍) | 0.125 V | 1/16 |

**距離を 2 倍にするたびに、読みは 1/4 になる。** LED は完全な点光源でも
完全な平行光でもないので、近い距離ほど逆二乗則からのずれが大きくなりやすい
(LED の指向性、フォトダイオードの受光面の大きさの影響)。d を LED の大きさより
十分大きく取ると式に近づく。

## 出典

自作。
