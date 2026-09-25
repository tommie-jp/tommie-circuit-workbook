---
book: analog-discovery
chapter: 1
id: 1-8
title: 電源の電流制限で LED を守る
tier: 100
source: 自作
board: BB
---

# 1-8 電源の電流制限で LED を守る

0-2 では「抵抗なしで LED を V+ に直結し、Supplies の Current Limit（電流制限）で
電流を決める」という考え方だけを扱い、実機では試さなかった。ここでは
Current Limit を先に設定してから、実際にブレッドボードで LED を V+ に直結して
確かめる。**Current Limit を有効にしたまま**なら、抵抗を忘れても LED を壊さない。

## 回路図

```circuit
title: 図1 LED を抵抗なしで V+ に直結
parts:
  V1: vsource a1 c1 5
  D1: led a1 a3 v=VF
  G1: ground c3
wires:
  - c1 -- c3
  - a3 -- c3
```

0-2 と同じ回路。V+（Supplies）から抵抗を挟まずに LED、GND へ。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで LED を V+ に直結する
board: half
parts:
  D1: led c5(A) c8(K) red
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1+, 1-]
wires:
  - AD.V+ -- a5 red
  - c8 -- -t8 black
  - AD.GND -- -t10 black
  - AD.1+ -- b5 yellow
  - AD.1- -- b8 black
```

CH1（`1+` / `1-`）は LED の両端（順方向電圧）を読む。**Current Limit を設定して
から Master Enable を入れる順を守る**（先に電源を入れると、制限が効く前の一瞬
大きな電流が流れる恐れがある）。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ を Enable。**Current Limit を 10 mA に設定してから** Master Enable |
| Scope (CH1) | DC、Range ±3 V 程度 |

## 見るべき値

0-2 と同じ計算（LED の V<sub>F</sub> ≈ 2.0 V と仮定）を、今度は実機で確かめる。

| 設定 | 期待する値（計算値） | 分かること |
| --- | --- | --- |
| Current Limit 10 mA | CH1 ≈ 2.0 V、Supplies 画面の電流 ≈ 10 mA、消費電力 ≈ 20 mW | 抵抗が無くても LED の定格（20 mA・順電圧 5 V 以下）に収まる。V+ の出力自体は 5 V を保てず 2 V 程度まで下がる（0-2 の計算どおり） |
| Current Limit を 15 mA に上げる | CH1 はわずかに上がる（LED は V<sub>F</sub> がほぼ一定なので、目安は 2.0〜2.1 V）、電流 ≈ 15 mA、消費電力 ≈ 30 mW | Current Limit を上げるほど LED は明るくなるが、20 mA の定格に近づく |
| Current Limit を 30 mA まで上げる（**試さない**） | LED の定格 20 mA を超える | Current Limit は LED の定格より低く設定して初めて「守る」働きをする。定格より高い制限値では素子側の限界がそのまま効いてしまう |

Current Limit を切って（無制限にして）同じ回路を組むのは 0-2 で注意したとおり
危険——ここでの実機の安全は、**Current Limit を LED の定格より低い値に設定して
おくこと**で保たれている。

## 出典

自作。
