---
book: denken
chapter: 8
id: 8-1
title: 巻数比と電圧比・電流比
tier: 50
source: 自作
board: BB
---

# 8-1 巻数比と電圧比・電流比

変圧器は 1 次巻線と 2 次巻線の**巻数の比**で電圧と電流を変える。小型の出力トランス
(10 kΩ:8 Ω、巻数比 約 35:1) を Analog Discovery (AD) の波形発生器で低い電圧のまま
駆動し、電圧比と電流比の両方が巻数比に合うことを確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| n = N1 / N2 | 巻数比。1 次巻線 (N1) と 2 次巻線 (N2) の巻数の比 |
| n = √(Z1 / Z2) | 整合が取れた負荷のとき、インピーダンス比の平方根が巻数比に等しい |
| V1 / V2 = n | 電圧比は巻数比に等しい |
| I2 / I1 = n | 電流は巻数に反比例する。2 次の電流は 1 次の n 倍 (電圧比の逆) |

このトランスは 1 次 10 kΩ・2 次 8 Ω 用なので、n = √(10000 / 8) ≒ 35.4。

## 回路図

```circuit
title: 図1 巻数比を測る回路
style:
  standard: jis
  pitch: 1.8
parts:
  W1: sine c1 e1 l=$\mathrm{W1}$
  Rs1: resistor c1 c3 100 i=I1
  M2: voltmeter b1 b3 l=$\mathrm{CH2}$
  M1: voltmeter c4f0 d4f0 l=$\mathrm{CH1}$
  T1: transformer d5 10kto8
  RL: resistor c7f0 d7f0 8
  G1: ground e1
wires:
  - b1 -- c1
  - b3 -- c3
  - c3 -- c4 -- c4f0
  - c4f0 -| T1.A1
  - T1.A2 -| d4f0
  - d4f0 -- e4
  - e1 -- e4
  - T1.B1 -| c7f0
  - T1.B2 -| d7f0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/circuit/01-turns-ratio-1.svg)

- W1 は AD の波形発生器 (Wavegen)。1 kHz、振幅 2 V
- Rs1 (100 Ω) は 1 次電流 I1 を読むシャント。10 kΩ に反射した 2 次負荷に対して
  1 % ほどなので、電圧比・電流比の計算にはほぼ効かない
- M1 (CH1) は 1 次巻線の両端、M2 (CH2) は Rs1 の両端 (差動)。1 回目はこの配線で
  V1 と I1 (= 読みの 1/100) を読む
- RL (8 Ω) は 2 次巻線に合わせた負荷。2 回目は CH1 を RL の両端に挿し替えて V2 を読む
  (2 ch しか無いので 2 回に分けて測る)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上の各列は a〜e が 1 つのネット、f〜j が別のネット。T1 は溝をまたいで 1 次・2 次を配る
board: half
parts:
  Rs1: resistor e3 e7 100
  T1: transformer c15 c18 f15 f18 10kto8
  RL: resistor h15 h18 8
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a3 yellow
  - AD.GND -- -t5 black
  - AD.1+ -- a7 orange
  - AD.1- -- -t9 black
  - AD.2+ -- a11 blue
  - AD.2- -- a15 white
  - c3 -- c11 yellow
  - b7 -- b15 orange
  - a18 -- -t18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/breadboard/01-turns-ratio.svg)

- T1 の 1 次リード (10 kΩ側) を 15・18 列の上ブロック、2 次リード (8 Ω側) を同じ
  15・18 列の下ブロックに挿す。上下は別ネットなので、4 本足がそのまま 1 次・2 次を分ける
- RL は 15・18 列の下ブロックに挿すだけで T1 の 2 次と並列になる (列でつながる)
- Rs1 は 3 列と 7 列。3 列 (W1 側) は黄の線で 11 列へ、7 列 (T1 側) は橙の線で
  15 列 (T1 の 1 次) へ延ばし、AD の足の並びどおりに左から挿せるようにしてある
- CH2 (2+/2−) は Rs1 の両端 (11 列と 15 列) にあて、I1 を読む。CH1 (1+/1−) は
  T1 の 1 次 (7 列と − レール) にあて、V1 を読む
- 2 回目は 1+ を g15、1− を g18 (どちらも下ブロックの 15・18 列、RL と同じネット) へ
  挿し替えて V2 を読む

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 2 V |
| Scope (1 回目) | CH1 = 1 次巻線の両端 (V1)。CH2 = Rs1 の両端 (差動、I1 = 読み ÷ 100 Ω) |
| Scope (2 回目) | CH1 を RL の両端に挿し替え、V2 を読む |

1 回目の画面。CH2 は CH1 の約 1/100 しかないので、CH2 だけ 10 mV/div に上げ、2 本が重ならないよう CH1 を上、CH2 を下にずらしてある。
2 次の負荷は抵抗 (8 Ω) なので、I1 は V1 と同じ位相になる。V1 と I1 は Rs1 で 1 % 下がった値
(1.98 V・19.8 mV) で描いた。

```scope
title: 図3 1 回目 — V1 (CH1、1 V/div) と I1 の分 (CH2、10 mV/div) は同じ位相
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1.98V, range: 1V/div, position: 2div}
ch2: {wave: sine 1kHz 19.8mV, range: 10mV/div, position: -2div}
measure: [vmax, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/scope/01-turns-ratio-1.svg)

2 回目は CH1 を RL の両端へ挿し替える。V2 は I1 の分と同じ桁なので、2 本とも 20 mV/div で並べる。

```scope
title: 図4 2 回目 — V2 (CH1) は V1 の 1/35
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 56.0mV, range: 20mV/div}
ch2: {wave: sine 1kHz 19.8mV, range: 20mV/div}
measure: [vmax, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/scope/01-turns-ratio-2.svg)

### オシロスコープと発振器

汎用の計器での読み替えは[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。

AD の CH2 は Rs1 の両端を差動で挟み、1− は巻線の下の端 (GND) に当てている。Rs1 の電圧 (20 mV) は
振れ (2 V) の 1 % しかないので、2 本の先端で引く方法は使えない。**Rs1 を 1 次巻線の GND 側へ
移し**、CH2 の 1 本で直に読む (図5)。直列の順を入れ替えただけなので、I1 は変わらない。

```circuit
title: 図5 汎用オシロでの測り方
style:
  standard: jis
parts:
  FG: sine c1 g1 l=$\mathrm{FG}$
  M1: voltmeter c3 g3 l=$\mathrm{CH1}$
  T1: transformer d7 10kto8
  M2: voltmeter e4 g4 l=$\mathrm{CH2}$
  Rs1: resistor e6 g6 100 i=I1
  RL: resistor c9 e9 8
  M3: voltmeter c11 e11 l=$\mathrm{CH1}$
  G1: ground g1
  G2: ground e11
wires:
  - c1 -- c3 -- c6 |- T1.A1
  - e6 |- T1.A2
  - e4 -- e6
  - g1 -- g3 -- g4 -- g6
  - c8 |- T1.B1
  - e8 |- T1.B2
  - c8 -- c9 -- c11
  - e8 -- e9 -- e11
notes:
  - text d11a4 left: (2回目)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/circuit/01-turns-ratio-2.svg)

- ブレッドボードは Rs1 (e3–e7) を抜いて 3 列と 7 列を線でつなぎ、18 列から − レールへの
  黒い線 (a18) を Rs1 (100 Ω) に替える。18 列が T1 の 1 次の下と Rs1 のつなぎ目になる
- FG の OUT を 3 列、FG の GND を − レール。High-Z、Sine、1 kHz、振幅 2 V (Vpp で入れる機種なら 4 Vpp)。
  負荷は約 10 kΩ なので、FG の 50 Ω で下がる振幅は 0.5 % ほどで無視できる
- 1 回目: CH1 の先端を 3 列 (FG の出力)、CH2 の先端を 18 列。グランドクリップはどちらも − レール。
  CH1 は V1 に Rs1 の電圧が乗った値なので、V1 は Math の CH1 − CH2 で読む
  (差は 1 % なので、CH1 をそのまま V1 としてもよい)。CH2 は 10 mV/div (振れは 40 mVpp)、Average を 16 回
- 2 回目: CH1 の先端を g15、グランドクリップを g18 (2 次の B2 側) に当てて V2 を読む。
  AD の 2 回目と同じく 2 ch では 3 つ (V1・I1・V2) を同時に取れない。4 ch の機種なら 1 回で済む

**1 次と 2 次の GND。** 2 回目は CH2 のクリップ (1 次の GND) と CH1 のクリップ (2 次の B2) が
オシロの中で大地につながり、1 次と 2 次が 1 点でつながる。1 点だけなら電流の輪はできないので、
この題 (1 kHz、数 V) では構わない。ただし 2 次の 2 本の足の両方にクリップを当てると、
2 次が大地を通って短絡する (V2 が 0 になる)。2 次のクリップは B2 の 1 か所だけにする。
V2 の位相の向きは、どちらの足にクリップを当てるかで反転する。

## 見るべき値

計算値 (理想変成器、巻線抵抗は無視)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 (V1、振幅) | 2.00 V | Wavegen の設定どおり |
| CH2 (Rs1 の両端、振幅) | 20.0 mV | I1 = 20.0 mV ÷ 100 Ω = 200 µA |
| CH1 を挿し替えた V2 (振幅) | 56.6 mV | V1 / V2 = 2.00 / 0.0566 ≒ 35.3 ≒ n |
| RL の電流 I2 (= V2 ÷ 8 Ω) | 7.07 mA | I2 / I1 = 7.07 mA / 200 µA ≒ 35.4 ≒ n |

電圧比も電流比も、どちらも巻数比 n ≒ 35.4 に近い値になる。電流比が電圧比の**逆数**
ではなく同じ n になるのは、1 次側の電流を測っているため (2 次側が大きい電流、
1 次側が小さい電流。エネルギー保存 V1×I1 ≒ V2×I2 で確かめられる)。実際は巻線抵抗の
分だけ電圧比がわずかに小さくなる。

## 出典

自作。
