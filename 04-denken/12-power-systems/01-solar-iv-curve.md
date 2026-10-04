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
  pitch: 1.2
parts:
  PV1: solar c1 g1 4.5 l=$\mathrm{PV}_1$
  M1: voltmeter c4 g4 l=$\mathrm{CH1}$
  Rs: resistor c6 c8 10 i=I
  M2: voltmeter a6 a8 l=$\mathrm{CH2}$
  VR1: potentiometer c10 g10 1k l=$\mathrm{VR}_1$
  G1: ground g1
wires:
  - c1 -- c4 -- c6
  - a6 -- c6
  - a8 -- c8
  - c8 -- c10
  - g1 -- g4 -- g10
  - VR1.w |- g10
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/12-power-systems/circuit/01-solar-iv-curve-1.svg)

- PV1 (太陽電池、屋内の照明かランプで照らす) の + から Rs (10 Ω、電流検出用の
  シャント) を通って VR1 (1 kΩ、可変抵抗) へ。VR1 は摺動子を GND 側の端と
  つないで可変抵抗 (レオスタット、0〜1 kΩ) として使い、摺動子を回して負荷を変える
- CH1 (M1) が太陽電池の端子電圧 V。**Rs の前** (太陽電池の + そのもの) で読む。Rs の後ろで読むと
  I × Rs (最大 0.14 V) だけ低い負荷の電圧になる。CH2 (M2) が Rs の両端 (I = 読み ÷ 10 Ω)

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
  Rs: resistor c3 c7 10
  VR1: potentiometer e14(1) e15(W) e16(3) 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [1+, 1-, 2+, 2-]
wires:
  - PV1.+ -- a3 red
  - PV1.- -- -t5 black
  - AD.1+ -- b3 yellow [h10]
  - AD.1- -- -t9 black
  - AD.2+ -- a11 red
  - AD.2- -- a14 orange
  - e3 -- e11 red
  - b7 -- b14 orange
  - a15 -- -t15 black
  - a16 -- -t16 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/12-power-systems/breadboard/01-solar-iv-curve.svg)

- PV1 (太陽電池パネル) をブレッドボードの外の機器として描く。Rs (10 Ω) で電流を検出し、
  VR1 (1 kΩ) の摺動子で負荷を変える。VR1 は 14 列 (端 1) と 15 列 (摺動子) の間を
  負荷にし、摺動子と 16 列 (端 3) をどちらも GND レールへつなぐ (0〜1 kΩ の
  可変抵抗になる。両端 14・16 列だけを使うと 1 kΩ 固定になって負荷が変わらない)
- Rs は 3 列 (PV1 の +) と 7 列。3 列は赤の線で 11 列へ、7 列は橙の線で 14 列
  (VR1 の端 1) へ延ばす。AD の 1+ は 3 列 (Rs の前)、1− は GND レール、2+ は 11 列、
  2− は 14 列で、ピンの並び (1+ 1− 2+ 2−) どおりに左から挿す
- CH1 (1+/1−) が太陽電池の端子電圧 (Rs の前で読む)、CH2 (2+/2−) が Rs の両端

## 計器の設定

この題はオシロの図を付けない — 直流の量 (V と I) だけを見る。テスターの読みで足りる。

| 計器 | 設定 |
| --- | --- |
| Scope | CH1 = 太陽電池の端子電圧 V (Rs の前、3 列)。CH2 = Rs の両端 (I = 読み ÷ 10 Ω) |
| VR1 | 摺動子をゆっくり回し、短絡に近い所から開放に近い所まで数点測る |
| 照明 | 室内の照明か卓上ランプ。日なたに比べると出力は小さくなる |

### オシロスコープと発振器

AD の CH2 は Rs の両端 (11 列と 14 列、つまり Rs の 3 列と 7 列) を差動で挟む。汎用オシロの
2 本のグランドクリップは中でつながっていて、大地にも落ちている
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md))。CH1 のクリップを青レールに、
CH2 のクリップを Rs のどちらかの端に当てると、太陽電池か負荷をクリップどうしで短絡する。
パネルが大地から浮いていても、この短絡は起きる。Rs の電圧は最大 0.14 V で CH1 (最大 4.5 V) の
3 % しかなく、CH1 − CH2 では 8 bit の分解能に埋もれる。そこで **Rs を負荷の GND 側へ移す** (図3)。
試験の図とはシャントの位置が変わるが、直列なので流れる電流は同じ。電源も発振器も使わない。

```circuit
title: 図3 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  PV1: solar c1 g1 4.5 l=$\mathrm{PV}_1$
  VR1: potentiometer c4 e4 1k l=$\mathrm{VR}_1$
  Rs: resistor e4 g4 10 i=I
  M2: voltmeter e7 g7 l=$\mathrm{CH2}$
  M1: voltmeter c10 g10 l=$\mathrm{CH1}$
  G1: ground g1
wires:
  - c1 -- c4 -- c10
  - VR1.w |- e4
  - e4 -- e7
  - g1 -- g4 -- g7 -- g10
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/12-power-systems/circuit/01-solar-iv-curve-2.svg)

- ブレッドボードの変え方: Rs を 3〜7 列から抜き、3 列と 7 列を線でつなぐ (7 列 → 14 列の橙の線はそのまま)。
  15・16 列から青レールへの 2 本の黒い線を抜き、15 列と 16 列を短い線でつなぎ、
  Rs を 16 列と青レールの間に挿す
- CH1 の先端は 3 列 (太陽電池の +、AD の 1+ と同じ所)、CH2 の先端は 16 列 (Rs の上)。グランドクリップは 2 本とも青レール
- I は CH2 ÷ 10 Ω (図1 と同じ)。CH1 は太陽電池の + を直に読むので、そのまま端子電圧 V になる。
  負荷の電圧が要るときは Math の CH1 − CH2
- 直流なので Measure の Mean (平均) で読む。CH2 は 20 mV/div ほどに絞り、
  最大 0.14 V が画面に収まるよう Offset で 0 V を下へ寄せる

## 見るべき値

計算値。屋内の照明下で開放電圧 Voc = 4.5 V、短絡電流 Isc = 15 mA、
Vmp ≒ 0.8 × Voc、Imp ≒ 0.9 × Isc とした (結晶シリコン太陽電池の目安)。

| 負荷 RL | V | I | P = V×I | 分かること |
| --- | --- | --- | --- | --- |
| 約 50 Ω (短絡寄り) | 0.70 V | 14.0 mA | 9.8 mW | Isc に近い電流。電圧はまだ低い |
| 約 267 Ω (MPP) | 3.60 V | 13.5 mA | 48.6 mW | 電力が最大になる点 |
| 約 10 kΩ (開放寄り) | 4.40 V | 0.44 mA | 1.9 mW | Voc に近い電圧。電流はごく小さい (VR1 の範囲 0〜1 kΩ の外なので、VR1 の代わりに 10 kΩ の抵抗を挿して測る) |

**MPP での電力 (約 48.6 mW) が、短絡寄り・開放寄りのどちらより大きい。**
曲線因子 FF = 48.6 / (4.5 × 15) ≒ 0.72 で、結晶シリコン太陽電池として妥当な値。
照明を暗くすると Isc がほぼ比例して下がり、Voc はあまり下がらない
(半導体の対数特性のため)。

## 出典

自作。
