---
book: denken
chapter: 12
id: 12-1
title: 太陽電池の I-V 特性と最大電力点
tier: 50
source: 自作
board: BB
---

# 12-1 太陽電池の I-V 特性と最大電力点

太陽電池は負荷によって出す電圧と電流が変わり、その積 (電力) が最大になる点
(最大電力点、MPP) がある。負荷抵抗を変えながら電圧と電流を測り、I-V 特性と
電力のグラフを作る。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| P = V × I | 太陽電池が出す電力。V と I の積が最大になる所が MPP |
| FF = (Vmp × Imp) / (Voc × Isc) | 曲線因子。理想 (四角い I-V) に対する実際の比 |

## 回路図

```circuit
title: 図1 太陽電池と可変負荷
style:
  standard: jis
parts:
  PV1: solar c1 g1 4.5
  Rs: resistor c1 c3 10 i=I
  M2: voltmeter a1 a3 l=$\mathrm{CH2}$
  VR1: potentiometer c3 g3 1k
  M1: voltmeter a5 a8 l=$\mathrm{CH1}$
  G1: ground g1
wires:
  - a1 -- c1
  - a3 -- c3
  - a5 |- c3
  - a8 |- g3
  - g1 -- g3
```

- PV1 (太陽電池、屋内の照明かランプで照らす) の + から Rs (10 Ω、電流検出用の
  シャント) を通って VR1 (1 kΩ、可変抵抗) へ。VR1 の摺動子を回して負荷を変える
- CH1 (M1) が太陽電池の端子電圧 V、CH2 (M2) が Rs の両端 (I = 読み ÷ 10 Ω)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと太陽電池
board: half
parts:
  PV1:
    type: device
    at: top
    label: 太陽電池パネル 5V
    pins: ["+", "-"]
  Rs: resistor a5 a9 10
  VR1: potentiometer a13(1) a14(W) a15(3) 1k
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [1+, 1-, 2+, 2-]
wires:
  - PV1.+ -- b5 red
  - PV1.- -- -t2 black
  - c9 -- a13 orange [h11]
  - -t15 -- a15 black [h30]
  - AD.1+ -- b9 orange
  - AD.1- -- -t9 black [h27]
  - AD.2+ -- b5 red [h29]
  - AD.2- -- b9 orange [h29]
```

- PV1 (太陽電池パネル) を板の外の機器として描く。Rs (10 Ω) で電流を検出し、
  VR1 (1 kΩ) の摺動子で負荷を変える
- CH1 (1+/1−) が太陽電池の端子電圧、CH2 (2+/2−) が Rs の両端

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Scope | CH1 = 太陽電池の端子電圧 V。CH2 = Rs の両端 (I = 読み ÷ 10 Ω) |
| VR1 | 摺動子をゆっくり回し、短絡に近い所から開放に近い所まで数点測る |
| 照明 | 室内の照明か卓上ランプ。日なたに比べると出力は小さくなる |

## 見るべき値

計算値。屋内の照明下で開放電圧 Voc = 4.5 V、短絡電流 Isc = 15 mA、
Vmp ≒ 0.8 × Voc、Imp ≒ 0.9 × Isc とした (結晶シリコン太陽電池の目安)。

| 負荷 RL | V | I | P = V×I | 分かること |
| --- | --- | --- | --- | --- |
| 約 50 Ω (短絡寄り) | 0.70 V | 14.0 mA | 9.8 mW | Isc に近い電流。電圧はまだ低い |
| 約 267 Ω (MPP) | 3.60 V | 13.5 mA | 48.6 mW | 電力が最大になる点 |
| 約 10 kΩ (開放寄り) | 4.40 V | 0.44 mA | 1.9 mW | Voc に近い電圧。電流はごく小さい |

**MPP での電力 (約 48.6 mW) が、短絡寄り・開放寄りのどちらより大きい。**
曲線因子 FF = 48.6 / (4.5 × 15) ≒ 0.72 で、結晶シリコン太陽電池として妥当な値。
照明を暗くすると Isc がほぼ比例して下がり、Voc はあまり下がらない
(半導体の対数特性のため)。

## 出典

自作。
