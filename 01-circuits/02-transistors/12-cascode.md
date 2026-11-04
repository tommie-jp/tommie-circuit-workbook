---
book: circuits
chapter: 2
id: 2-12
title: カスコード
tier: 200
source: 自作
---

# 2-12 カスコード

2-3 のエミッタ接地増幅は利得が大きいが、高い周波数で利得が早く落ちる。原因はベースとコレクタの間の小さな容量
C<sub>µ</sub> (ミュー、数 pF) で、コレクタが入力の A 倍の大きさで逆向きに振れるため、入力から見ると **(1 + A) 倍の容量**に見える。
これを**ミラー効果**と呼ぶ。利得 83 倍なら 4 pF が約 340 pF になり、信号源の抵抗とローパスを作る。

**カスコード**は、増幅する Q1 のコレクタの上にベース接地の Q2 を重ねた形。Q2 のベースはコンデンサで交流的に GND に止めてあり、
Q2 のエミッタ (= Q1 のコレクタ) はほとんど振れない。Q1 のコレクタから見た負荷は Q2 の re (約 26 Ω) だけなので、
Q1 の電圧利得は約 1 倍で、ミラー効果が消える。電流はそのまま Q2 を通って `RC` へ流れるので、全体の利得はエミッタ接地と同じ。

この題では、同じ基板で Q2 の C-E 間を線で短絡するとエミッタ接地に戻ることを使い、**利得は同じまま帯域が約 3 倍に広がる**ことを、
方形波の立ち上がりの時間で比べる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 カスコード (Q1 のコレクタに Q2 のベース接地を重ねる)
parts:
  VCC: vcc 8,2 5V
  R1: resistor 8,2 8,5 22k
  R2: resistor 8,5 8,9 6.8k
  R3: resistor 8,9 8,12 12k
  G3: ground 8,12
  CB: ecap 6,5 6,7 10u
  G6: ground 6,7
  W1: square 1,9 1,12 l=$\mathrm{W1}$
  G1: ground 1,12
  M1: voltmeter 3,9 3,12 l=$\mathrm{CH1}$
  RS: resistor 3,9 5,9 10k
  CIN: capacitor 5,9 7,9 1u
  RC: resistor 11,2 11,4 2.2k
  Q2: npn 11,5
  Q1: npn 11,9
  RE: resistor 11,11 11,13 820
  G4: ground 11,13
  CE: ecap 13,11 13,13 100u
  OUT: port 14,4
  M2: voltmeter 15,4 15,6 l=$\mathrm{CH2}$
  G5: ground 15,6
wires:
  - 8,2 -- 11,2
  - 1,9 -- 3,9
  - 1,12 -- 3,12
  - 6,5 -- 8,5
  - 7,9 -- 8,9
  - 8,5 -- Q2.B
  - 11,4 -- Q2.C
  - Q2.E -- Q1.C
  - 8,9 -- Q1.B
  - Q1.E -- 11,11
  - 11,11 -- 13,11
  - 11,13 -- 13,13
  - 11,4 -- 14,4
  - 14,4 -- 15,4
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/12-cascode.svg)

図1 の電源は Analog Discovery 3 (AD3) の V+ (5 V)。入力は W1 から `RS` (10 kΩ) を通して入れる。`RS` は信号源の抵抗の代わりで、
ミラー効果の容量と組むローパスを見やすくするために置いた。CH1 で W1、CH2 でコレクタ (OUT) を見る。

- 直流: `R1`・`R2`・`R3` の分圧で、Q1 のベースが 5 × 12 / 40.8 ≈ **1.47 V**、Q2 のベースが 5 × 18.8 / 40.8 ≈ **2.30 V**。
  Q1 のエミッタは約 0.8 V で、I<sub>E</sub> ≈ 0.8 V / 820 Ω ≈ **0.98 mA**。コレクタは 5 − 0.98 mA × 2.2 kΩ ≈ **2.8 V**
- Q2 のエミッタ (Q1 のコレクタ) は 2.30 − 0.65 ≈ **1.65 V**。Q1 の C-E 間は約 0.85 V、Q2 は約 1.2 V で、どちらも飽和しない
- 交流: re = 26 mV / 0.98 mA ≈ 27 Ω、ベースからコレクタまでの利得は 2200 / 27 ≈ **83 倍**。ベースから見た入力の抵抗は
  `R2` ∥ `R3` ∥ (β × re) ≈ 2.6 kΩ (`CB` で Q2 のベースが交流の GND なので `R2` も GND へ落ちて見える) で、`RS` との分圧が 0.21。
  W1 からの利得は約 **17 倍** (20 mVpp → 約 340 mVpp、反転)
- 帯域: ベースの節点の抵抗は `RS` ∥ 2.6 kΩ ≈ 2.1 kΩ。容量はベース-エミッタ間の C<sub>π</sub> (パイ、約 120 pF) に、
  エミッタ接地ではミラー効果の 4 pF × 84 ≈ 340 pF が足され、−3 dB の周波数は 1 / (2π × 2.1 kΩ × 460 pF) ≈ **160 kHz**。
  カスコードでは C<sub>µ</sub> が 2 倍 (8 pF) にしかならず ≈ **580 kHz** (C<sub>µ</sub>・C<sub>π</sub> は LTspice の模型の値で、目安)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 カスコード (Q1・Q2 は下のブロック、バイアスは上のブロック)
board: half
parts:
  RS: resistor c5 c10 10k
  CIN: capacitor d10 d13 1uF
  R3: resistor a13 -t13 12k
  R2: resistor b13 b17 6.8k
  R1: resistor a17 +t17 22k
  CB: capacitor/electrolytic c17(+) c20(-) 10uF
  Q1: transistor g11 g12 g13 2SC1815 cap=left
  Q2: transistor g15 g16 g17 2SC1815
  RE: resistor j11 -b11 820 cap=right
  CE: capacitor/electrolytic i11(+) i7(-) 100uF
  RC: resistor j16 +b16 2.2k
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (電源・W1・CH1)
    pins: [V+, GND, 1+, W1, 1-]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery 3 (CH2)
    pins: [2+, 2-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1+ -- a4 blue
  - e4 -- e5 blue
  - AD.W1 -- a5 yellow
  - AD.1- -- -t7 black
  - a20 -- -t20 black
  - e13 -- f13 white
  - e17 -- f17 green
  - h12 -- h15 orange
  - j7 -- -b7 black
  - AD1.2+ -- i16 orange
  - AD1.2- -- -b19 black
  - +t30 -- +b30 red
  - -t29 -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/12-cascode.svg)

図2 は、上のブロックに入力とバイアスの抵抗、下のブロックに 2 つのトランジスタを置いた。5 V は AD3 の V+ (赤) から上の + レールへ。
**下のレールは列 29・30 の線で上のレールとつなぐ** (レールは上下で別々)。

- **Q1 のベース (列 13)**: `CIN` と、− レールへ縦の `R3`、Q2 のベースへ向かう `R2` が上のブロックの列 13 に集まる。白い線で下の列 13 (Q1 の B) へ渡す
- **Q2 のベース (列 17)**: `R2` の右端、+ レールからの `R1`、`CB` の + 側。緑の線で下の列 17 (Q2 の B) へ
- **Q1 と Q2**: どちらも平らな面を手前に E・C・B (2SC1815)。Q1 の C (列 12) と Q2 の E (列 15) を橙の線 `h12`–`h15` でつなぐ
- `RE` は Q1 の E (列 11) から下の − レールへ、`CE` は列 11 から列 7 へ寝かせ、列 7 を − レールへ。`RC` は Q2 の C (列 16) から下の + レールへ
- CH2 の 2+ は `i16` (コレクタ)、2− は下の − レール

**エミッタ接地に切り替える (J1)**: `f15` と `f16` を短い線でつなぐ。Q2 の C-E 間が短絡され、Q1 のコレクタに `RC` が直に付く。
Q2 は B-E 間が逆向きにかかって切れ、動作点はほぼ変わらない (コレクタ 2.7 V)。線を抜けばカスコードに戻る。

## 計器の設定

計器は AD3 のオシロ (立ち上がりの時間を波形で見るため)。W1 を 20 kHz・20 mVpp の方形波にする。CH1 (入力) は 10 mV/div、
CH2 (出力) は 50 mV/div で、CH2 の Offset を −2.8 V にして直流を画面の中央に戻す。時間軸は 1 µs/div、CH1 の立ち下がりでトリガする。
Measure で CH2 の Rise Time (10〜90 %) を出す。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 カスコード — 入力 (CH1) が下がると出力 (CH2) が約 0.64 µs で上がる
time: 1us/div
trigger: ch1 falling 0V at -3div
ch1: {wave: square 20kHz 20mVpp phase 180deg, range: 10mV/div}
ch2: {wave: ch1 | invert | gain 17 | rc 0.29us, range: 50mV/div}
measure: [vpp, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/12-cascode-1.svg)

図3 はカスコード (J1 なし)、図4 は J1 を挿したエミッタ接地。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 J1 で Q2 を短絡 (エミッタ接地) — 立ち上がりが約 1.8 µs に延びる
time: 1us/div
trigger: ch1 falling 0V at -3div
ch1: {wave: square 20kHz 20mVpp phase 180deg, range: 10mV/div}
ch2: {wave: ch1 | invert | gain 17 | rc 0.83us, range: 50mV/div}
measure: [vpp, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/12-cascode-2.svg)

図3・図4 の出力は振れ (340 mVpp) が同じで、立ち上がりだけが違う。1 次のローパスとみなすと、立ち上がりの時間は 0.35 / f<sub>−3dB</sub> で、
カスコードは約 0.6 µs、エミッタ接地は約 2 µs になる (図は LTspice の値 0.64 µs・1.83 µs に合わせた 1 次の近似)。
AD3 の Network Analyzer で 1 kHz〜10 MHz を掃引すれば、−3 dB の周波数そのものを読める。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 22 kΩ |
| R2 | 抵抗 (1/4 W) | 6.8 kΩ |
| R3 | 抵抗 (1/4 W) | 12 kΩ |
| RS | 抵抗 (1/4 W) | 10 kΩ (信号源の抵抗の代わり) |
| RC | 抵抗 (1/4 W) | 2.2 kΩ |
| RE | 抵抗 (1/4 W) | 820 Ω |
| CIN | フィルムコンデンサ | 1 µF |
| CB | 電解コンデンサ | 10 µF (Q2 のベースを交流的に GND へ) |
| CE | 電解コンデンサ | 100 µF |
| Q1, Q2 | NPN トランジスタ | 2SC1815 |
| J1 | ジャンパ線 | `f15`–`f16` (エミッタ接地と比べるときだけ) |
| — | 電源 | AD3 の V+ (5 V、約 1.1 mA) |

## 見るべき値

直流はテスターで GND から測る (W1 を止める)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Q1 のベース / Q2 のベース | 約 1.45 V / 約 2.25 V | 3 本の抵抗の分圧 |
| Q2 のエミッタ (Q1 のコレクタ) | 約 1.6 V | Q2 のベースより V<sub>BE</sub> だけ低い所に止まる |
| コレクタ (OUT) | 約 2.8 V (J1 ありで 2.7 V) | 動作点は J1 でほとんど変わらない |
| 20 mVpp の入力に対する出力 (CH2) | 約 340 mVpp、反転 (J1 の有無で同じ) | 利得は約 17 倍で、カスコードにしても変わらない |
| 出力の立ち上がり (カスコード) | 約 0.6 µs | ミラー効果が無い |
| 出力の立ち上がり (J1 あり) | 約 1.8 µs | C<sub>µ</sub> が (1 + 83) 倍に見え、帯域が約 3 分の 1 |

## LTspice での確かめ

`sim/12-cascode.cir` で 1 kHz の利得と −3 dB の周波数 (.ac) を、`sim/12-cascode-tran.cir` で 20 kHz・20 mVpp の方形波の応答と直流の電圧 (.tran) を読んだ。
J1 は C-E 間の抵抗 `rj` で、1 mΩ (J1 あり) と 1 GΩ (なし) に振った。Q1・Q2 は 2-3 と同じ 2SC1815 の代用モデル (C<sub>µ</sub> 4 pF・τ<sub>F</sub> 2.8 ns の仮定で、実測ではない)。
出力には AD3 の入力の容量の代わりに 20 pF を置いた (仮定)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| Q1 / Q2 のベース電圧 | 1.47 V / 2.30 V | 1.42 V / 2.24 V | 近い (ベース電流の分だけ低い) |
| Q2 のエミッタ電圧 | 約 1.65 V | 1.60 V | 合う |
| コレクタ電流 | 約 0.98 mA | 1.01 mA | 合う |
| コレクタ電圧 (カスコード / J1 あり) | 約 2.8 V / 2.7 V | 2.78 V / 2.70 V | 合う |
| 1 kHz の利得 (W1 から) | 約 17 倍 | 16.1 倍 / 16.3 倍 | 近い (同じ利得) |
| −3 dB の周波数 (カスコード / J1 あり) | 約 580 kHz / 160 kHz | 560 kHz / 202 kHz | 近い (比は本文 3.6 倍・LTspice 2.8 倍) |
| 立ち上がり 10〜90 % (カスコード / J1 あり) | 約 0.6 µs / 約 1.8 µs | 0.64 µs / 1.83 µs | 合う (本文の値は LTspice の読み) |

本文の −3 dB の見積りは、ベースの節点だけの 1 次のローパスとした。エミッタ接地の 160 kHz が LTspice より低いのは、
ミラー効果の倍率 (1 + A) を低い周波数の A で数えたため (高い周波数では A が下がり、容量も減る)。

## 出典

自作。2-3 の回路の上にベース接地を重ねたもの。

参考: [カスコード (Wikipedia)](https://ja.wikipedia.org/wiki/カスコード)、[Miller effect (Wikipedia)](https://en.wikipedia.org/wiki/Miller_effect)
