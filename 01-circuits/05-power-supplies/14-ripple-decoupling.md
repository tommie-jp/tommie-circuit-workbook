---
book: circuits
chapter: 5
id: 5-14
title: リップルとデカップリングの実測
tier: 200
source: 自作
---

# 5-14 リップルとデカップリングの実測

IC の電源のピンの近くには、たいてい 0.1 µF (マイクロファラド) のコンデンサと、少し離れて 10〜100 µF の電解コンデンサが付いている。
これがデカップリング (パスコン) で、負荷の電流が急に変わったときに、電源の線を通らずにコンデンサから電流を出す役目をする。
この題では、電源の線の抵抗を 2.2 Ω (オーム) の抵抗 RW で大げさに作り、その先で 22 mA の負荷を 10 kHz で開け閉めして、
電源の電圧 VL がどれだけ沈むか (リップル) を、コンデンサを替えながら測る。

考え方は 2 つ。

1. **コンデンサが無ければ**、負荷が入るたびに VL は RW × 電流 = 2.2 Ω × 22 mA ≈ 49 mV だけ沈む。電源の線の抵抗がそのまま電圧の沈みになる
2. **コンデンサがあれば**、沈みは RW × C の時定数でゆっくりになる。時定数が負荷の切り替わりの間隔 (ここでは 50 µs) より長いほど沈みは小さい。
   0.1 µF なら 0.22 µs で、10 kHz の沈みにはほとんど効かない。100 µF なら 220 µs で、沈みは 1/9 ほどになる

0.1 µF が効くのは、もっと速い変化 (切り替わりの瞬間の電流の髭や、配線のインダクタンスで出る跳ね) で、10 kHz の沈みを抑えるのは容量の大きい電解コンデンサの仕事。
2 つを並べて使うのはこのため。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 電源の線 (RW) の先で負荷を開け閉めし、VL の沈みを見る
parts:
  VS: vsource 2,3 2,8 5
  RW: resistor 2,3 5,3 2.2
  M2: voltmeter 2.5,1.5 4.5,1.5 l=$\mathrm{CH2}$
  CB: ecap 6,3 6,8 100u
  CD: capacitor 9,3 9,8 0.1u
  RD: resistor 12,3 12,5 220
  Q1: nmos 12,6 mirror 2N7000
  RG: resistor 14,6.5 14,8 100k
  W1: square 16,6.5 16,8 l=$\mathrm{W1}$
  M1: voltmeter 18,6.5 18,8 l=$\mathrm{CH1}$
  G1: ground 2,8
wires:
  - 2,3 -- 2,1.5 -- 2.5,1.5
  - 4.5,1.5 -- 5,1.5 -- 5,3
  - 5,3 -- 6,3 -- 9,3 -- 12,3
  - 12,5 -- Q1.D
  - Q1.S -- 12,8
  - 2,8 -- 6,8 -- 9,8 -- 12,8 -- 14,8 -- 16,8 -- 18,8
  - Q1.G -| 14,6.5
  - 14,6.5 -- 16,6.5 -- 18,6.5
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/14-ripple-decoupling.svg)

- VS は AD3 の Supplies の V+ (5 V)。RW (2.2 Ω) は細く長い電源の線の代わり (実物の線は 0.1〜0.5 Ω ほどの目安。差が見やすいよう大きくした)
- RD (220 Ω) が負荷、Q1 (2N7000) がそれを W1 の方形波 (0〜5 V、10 kHz) で開け閉めする。入ると約 22 mA が流れる。RG (100 kΩ) はゲートを 0 V に落とす抵抗
- CB (100 µF の電解) と CD (0.1 µF のセラミック) は VL に抜き差しして比べる
- CH2 は RW の両端 (VS − VL)。VS が一定なので、これが VL の沈みそのもの。CH1 は W1 (ゲート)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 RW の先の上の赤レールが VL。CB と CD はレールの間に抜き差しする
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies・CH2)
    pins: [GND, 2+, V+, 2-]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery 3 (W1・CH1)
    pins: [1-, 1+, W1]
  RW: resistor c4 c8 2.2
  CB: capacitor/electrolytic +t12(+) -t12(-) 100uF
  CD: capacitor +t15 -t15 0.1uF
  RD: resistor b20 b26 220
  Q1: transistor f24 f25 f26 2N7000 cap=below:2,0
  RG: resistor h21 h25 100k
wires:
  - AD.GND -- -t2 black
  - AD.V+ -- a4 red
  - AD.2+ -- d4 yellow
  - AD.2- -- d8 blue
  - a8 -- +t8 red
  - +t20 -- a20 red
  - e26 -- g26 orange
  - j24 -- -b24 black
  - j21 -- -b21 black
  - -t30 -- -b30 black
  - AD1.W1 -- i25 green
  - AD1.1+ -- j25 yellow
  - AD1.1- -- -b18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/14-ripple-decoupling.svg)

- AD3 の V+ (赤) は 4 列 (`a4`)。RW (`c4`–`c8`) を通って 8 列から上の赤いレールへ。**上の赤いレールが VL**
- CB (+ を赤いレール) と CD は、上の赤と青のレールの間に挿す (12・15 列)。比べるときは片方ずつ抜き差しする
- RD (`b20`–`b26`) は赤いレールから 20 列を経て 26 列へ。26 列から橙の線で下のブロックの 26 列 (Q1 の D) へ渡す
- Q1 (2N7000) は平らな面を手前にして左から S・G・D (24・25・26 列)。S は下の青いレールへ。下の青いレールは 30 列で上の青いレールとつなぐ
- G (25 列) に W1 (緑) と CH1 (黄)、RG (`h21`–`h25`) で GND へ
- CH2 は差動で、2+ を RW の電源側 (`d4`)、2− を RW の VL 側 (`d8`) に当てる

ブレッドボードを流れる電流は最大 22 mA で、ブレッドボードの範囲 (1 穴 200 mA) に収まる。周波数は 10 kHz で 3 MHz の内側。

## 計器の設定

計器は AD3 の Supplies・Wavegen・Scope。V+ を 5 V、W1 を方形波・10 kHz・振幅 2.5 V・オフセット 2.5 V (0〜5 V) にする。
Scope は CH1 を 2 V/div、CH2 を 10 mV/div (100 µF を挿したら 2 mV/div)、時間軸 20 µs/div、トリガは CH1 の立ち上がり 2.5 V。
CH2 は RW の両端の差なので、5 V のオフセットを引かずに mV の沈みを細かく読める。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 0.1 µF だけのとき — 負荷が入るたびに VL が 49 mV 沈む
time: 20us/div
trigger: ch1 rising 2.5V
ch1: {wave: square 10kHz 5Vpp offset 2.5V, range: 2V/div, position: -1div}
ch2: {wave: ch1 | gain 0.0098, range: 10mV/div, position: -2div}
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/scope/14-ripple-decoupling-1.svg)

図3 は CD (0.1 µF) だけを挿したときの理想 (計算) の画面。CH2 は CH1 と同じ形の方形波で、負荷が入る間だけ 49 mV 沈む。0.1 µF では形がほとんど変わらない。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 100 µF を足すと — 沈みは 5.5 mV の山に減る
time: 20us/div
trigger: ch1 rising 2.5V
ch1: {wave: square 10kHz 5Vpp offset 2.5V, range: 2V/div, position: -1div}
ch2: {wave: ch1 | gain 0.0098 | rc 220us, range: 2mV/div, position: -12div}
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/scope/14-ripple-decoupling-2.svg)

図4 は CB (100 µF、ESR 0 とした理想) を挿したときの画面。CH2 は三角の山になり、高さは 5.5 mV。負荷が入っている間は CB が電流を出して少しずつ下がり、
切れている間に RW から充電し直す。平均の沈み (約 25 mV) は変わらない (平均の電流 11 mA × 2.2 Ω)。コンデンサが減らすのは揺れで、平均の電圧降下は減らせない。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| RW | 抵抗 (1/4 W) | 2.2 Ω (電源の線の抵抗の代わり。損失 1 mW) |
| RD | 抵抗 (1/4 W) | 220 Ω (負荷。入っている間の損失 110 mW、平均 55 mW) |
| RG | 抵抗 (1/4 W) | 100 kΩ |
| Q1 | N チャネル MOSFET | 2N7000 |
| CB | 電解コンデンサ (16 V) | 100 µF |
| CD | セラミックコンデンサ (104) | 0.1 µF |
| — | 電源 | AD3 の Supplies の V+ (5 V) |
| — | 計器 | AD3 の Wavegen (W1 = ゲート) と Scope (CH1 = W1、CH2 = RW の両端) |

## 見るべき値

CH2 の山から谷まで (Vpp) で読む。表の値は LTspice の読み。

| VL のコンデンサ | CH2 の Vpp (沈み) | 分かること |
| --- | --- | --- |
| なし | 49 mV | RW × 22 mA がそのまま出る |
| 0.1 µF (CD) | 49 mV | 時定数 0.22 µs は 10 kHz には短すぎる |
| 10 µF | 40 mV | 時定数 22 µs。山の角が丸くなるが、まだ沈む |
| 100 µF (CB、ESR 0) | 5.5 mV | 時定数 220 µs。1/9 に減る |
| 100 µF (ESR 0.3 Ω) + 0.1 µF | 10 mV | 電解の ESR (等価直列抵抗) に電流が流れて段が乗る。実物はこちらに近い |

- 平均の沈みは、どのコンデンサでも約 25 mV。デカップリングは揺れを減らす部品で、線の抵抗の損を取り戻す部品ではない
- 実物のブレッドボードでは、負荷が切り替わる瞬間に CH2 に細い髭が立つことがある。線と部品のリードのインダクタンスによるもので、
  CD を Q1 と RD のすぐそば (VL の線の終わり) に挿すと小さくなる。どこに挿すと何 mV になるかを比べてみるとよい (模型には入れていないので値は決めない)
- 電解コンデンサの ESR は品種と温度で大きく変わる。低 ESR 品や、10 µF の積層セラミックに替えて CH2 の段の高さを比べると、ESR の効き目が分かる

## LTspice での確かめ

`sim/14-ripple-decoupling.cir` で図1 を 20 ms 動かし、最後の 1 ms の VL の Vpp を読んだ。`.step` でコンデンサを 5 通りに替えた。
2N7000 は 02-transistors の題と同じ仮定の模型。コンデンサの ESL とブレッドボードのインダクタンスは入れていない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 負荷の電流 (入っている間) | 約 22 mA | 22.2 mA | 合う |
| 沈み (なし・0.1 µF) | 49 mV | 49.1 mV・48.7 mV | 合う |
| 沈み (10 µF) | 40 mV | 39.7 mV | 合う |
| 沈み (100 µF、ESR 0) | 5.5 mV | 5.56 mV | 合う (図4 の読み 5.54 mV) |
| 沈み (100 µF、ESR 0.3 Ω + 0.1 µF) | 10 mV | 10.1 mV | 本文の値は LTspice の読み (ESR 0.3 Ω は仮定) |
| VL の平均 | 5 V − 約 25 mV | 4.976 V | 合う |

図4 の山の高さは、方形波の電流を時定数 220 µs で均した式 (49 mV × tanh(100 µs ÷ (4 × 220 µs)) ≈ 5.5 mV) と同じ。

## 出典

自作。

参考: [バイパスコンデンサ (Wikipedia)](https://ja.wikipedia.org/wiki/バイパスコンデンサ)、[Decoupling capacitor (Wikipedia)](https://en.wikipedia.org/wiki/Decoupling_capacitor)、[Equivalent series resistance (Wikipedia)](https://en.wikipedia.org/wiki/Equivalent_series_resistance)
