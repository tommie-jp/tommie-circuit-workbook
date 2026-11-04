---
book: circuits
chapter: 1
id: 1-10
title: 倍電圧 — ダイオードとコンデンサで (コッククロフト)
tier: 200
source: 自作
board: BB
era: 古
---

# 1-10 倍電圧 — ダイオードとコンデンサで (コッククロフト)

1-9 のクランパは、コンデンサとダイオード 1 本で、波形全体を上へ持ち上げた。持ち上げた波の山を、
もう 1 本のダイオードで別のコンデンサに貯めると、入力の振幅 V<sub>p</sub> の **2 倍の直流**が取り出せる。
これを段に重ねていくと 4 倍・6 倍と増やせる。1932 年にコッククロフトとウォルトンがこの梯子で数十万 V を作り、
加速器で初めて原子核を人工的に壊した。今もテレビのブラウン管、コピー機、静電気の実験器などの高電圧に使われてきた
**コッククロフト・ウォルトン回路** (CW 回路) である。

この題では 2 段 (4 倍) の梯子を組み、±3 V (6 Vpp) の方形波から約 9 V の直流を作る。
変圧器を使わずに、コンデンサとダイオードだけで電圧が上がることを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 2 段のコッククロフト・ウォルトン回路。上の列が交流、下の列が直流の梯子
parts:
  W1: square 2,4 2,6 l=$\mathrm{W1}$
  G1: ground 2,6
  M2: voltmeter 4,4 4,6 l=$\mathrm{CH2}$
  G5: ground 4,6
  RS: resistor 4,2 6,2 560
  C1: capacitor 6,2 8,2 1u
  C3: capacitor 8,2 12,2 1u
  D1: diode 6,5 8,2
  D2: diode 8,2 10,5
  D3: diode 10,5 12,2
  D4: diode 12,2 14,5
  C2: capacitor 6,5 10,5 1u
  C4: capacitor 10,5 14,5 1u
  G2: ground 6,6
  RL: resistor 16,5 16,7 100k
  G3: ground 16,7
  M1: voltmeter 19,5 19,7 l=$\mathrm{CH1}$
  G4: ground 19,7
wires:
  - 2,4 -- 2,2
  - 2,2 -- 4,2
  - 4,2 -- 4,4
  - 6,5 -- 6,6
  - 14,5 -- 16,5
  - 16,5 -- 19,5
notes:
  - text 8.3,1.5: A
  - text 12.3,1.5: C
  - text 10,5.9: B
  - text 14,5.9: D
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/10-cockcroft-walton.svg)

上の列 (`C1`・`C3`) は W1 の交流に揺さぶられる側、下の列 (`C2`・`C4`) は直流が積み上がる側。4 本のダイオードがジグザグに橋を渡す。

- **1 段目 (`C1`・`D1`・`D2`・`C2`)**: W1 が −3 V の間、`D1` が導通して `C1` を約 3 V に充電する (1-9 のクランパと同じ)。
  W1 が +3 V に跳ぶと、A は 3 + 3 = 6 V まで上がり、`D2` を通して `C2` を充電する。B は約 **2V<sub>p</sub> = 6 V** (倍電圧)
- **2 段目 (`C3`・`D3`・`D4`・`C4`)**: 同じことを B を足場にしてもう 1 度行う。C は A よりさらに 2V<sub>p</sub> 高い所で揺れ、
  `D4` で `C4` の上 (D) に貯まる。D は約 **4V<sub>p</sub> = 12 V**
- **理想からの差**: 電流が通るダイオードは 4 本で、それぞれに 0.5 V ほど残る (流れる電流が小さいので 1-9 の 0.7 V より低い)。
  負荷 `RL` (100 kΩ) に電流を取られるたびに各コンデンサの電荷が少しずつ減るので、さらに下がる。LTspice では D は **9.0 V**、B は 4.5 V
- **上の列のコンデンサは直流を通さない**ので、W1 から見た平均の電流はほぼ 0。W1 が負荷に渡す電力は、交流の 1 周期ごとの小さな電荷の受け渡しで運ばれる

`RS` (560 Ω) は、電源を入れた直後に空のコンデンサへ流れ込む電流を、AD3 の Wavegen の約 10 mA 以下に絞るための抵抗
(LTspice で立ち上がりの山が 9.5 mA。470 Ω では 11 mA になった)。

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 上のブロックに 1 段目と D3・D4、下のブロックに C3・C4
board: half
parts:
  RS: resistor b3 b6 560
  C1: capacitor/film d6 d9 1u
  D1: diode -t9 a9 1N4148
  D2: diode b9 b13 1N4148
  C2: capacitor/film a13 -t13 1u
  D3: diode c13 c17 1N4148
  D4: diode b17 b21 1N4148
  RL: resistor d21 d25 100k
  C3: capacitor/film g9 g17 1u
  C4: capacitor/film j13 j21 1u
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [2+, W1, GND, 2-, 1+, 1-]
wires:
  - AD.2+ -- a2 blue
  - e2 -- e3 blue
  - AD.W1 -- a3 yellow
  - AD.GND -- -t5 black
  - AD.2- -- -t7 black
  - e9 -- f9 orange
  - e17 -- f17 green
  - e13 -- f13 purple
  - e21 -- f21 white
  - AD.1+ -- a21 white
  - a25 -- -t25 black
  - AD.1- -- -t27 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/10-cockcroft-walton.svg)

- **上のブロック** (左から右へ梯子を写した順): W1 (列 3) → `RS` → 列 6 → `C1` → **列 9 = A**。`D1` はアノードを − レールに、カソード (帯) を A に縦に挿す。
  `D2` で A から **列 13 = B** へ、`C2` は B から − レールへ縦に。`D3` で B から **列 17 = C** へ、`D4` で C から **列 21 = D** (出力) へ
- **下のブロック**: 上の A・B・C・D を同じ列の線で下へ渡し (橙・紫・緑・白)、`C3` を A (列 9) と C (列 17) の間、`C4` を B (列 13) と D (列 21) の間に挿す
- 出力 D (列 21) から `RL` で列 25、列 25 を − レールへ。CH1 の 1+ を D、CH2 の 2+ を W1 (列 2 を列 3 と青い線でつなぐ)
- ダイオードはどれも帯 (カソード) が右か上。1 本でも逆に挿すと D は上がらない

D の 9〜11 V は、ブレッドボードの範囲 (定常 12 V 以下) に収まる。W1 を ±5 V にすると負荷なしで 18 V を超えるので、±3 V より上げない。

## 計器の設定

計器は AD3 の Wavegen と Scope。方形波の入力と、直流になった出力を同じ画面で比べる。

| 項目 | 値 |
| --- | --- |
| Wavegen W1 | 方形波、1 kHz、振幅 3 V (6 Vpp)、オフセット 0 V |
| Scope CH1 (出力 D) | 2 V/div、Position −4 div (0 V を画面の一番下に) |
| Scope CH2 (入力 W1) | 2 V/div (図3 には描かない。W1 の ±3 V を確かめるだけ) |
| 時間 | 5 ms/div、トリガの点を画面の左端に寄せる |
| トリガ | WaveForms の Scope のトリガ元を Wavegen にし、Single で W1 を動かした瞬間から撮る |

コンデンサを空にしてから (W1 を止め、D と B をそれぞれ 100 Ω ほどで GND に一瞬つないで放電する) W1 を動かすと、
出力が段々に上がっていくようすが撮れる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 W1 を入れると出力 D (CH1) は約 18 ms で 9 割の 8.1 V に上がる (目安)
time: 5ms/div
trigger: ch1 rising 50mV at -5div
ch1: {wave: = 9.0V * step(t) * (1 - exp(-t/7.9ms)), range: 2V/div, position: -4div}
cursors: [0, 18ms]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/scope/10-cockcroft-walton.svg)

図3 の曲線は、LTspice の立ち上がり (5 ms で 4.1 V、20 ms で 8.0 V) に、9 割になる時刻 (18.2 ms) が合うよう時定数 7.9 ms の指数を当てはめた目安。実物の立ち上がりは
1 周期 (1 ms) ごとに小さな段がついた階段になる (W1 が +3 V の間に `C2`・`C4` へ、−3 V の間に `C1`・`C3` へ電荷が送られる)。
立ち上がりきった後は平均 9.0 V で、1 周期ごとに 0.18 Vpp だけ揺れる。揺れは CH1 を 50 mV/div、Offset −9.0 V にすると見える。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| C1〜C4 | フィルムコンデンサ | 1 µF (105)、耐圧 50 V (かかるのは最大で約 6 V) |
| D1〜D4 | 小信号ダイオード | 1N4148 |
| RS | 抵抗 (1/4 W) | 560 Ω (W1 の電流を絞る) |
| RL | 抵抗 (1/4 W) | 100 kΩ (負荷。抜けば負荷なし) |
| — | 信号 | AD3 の W1 (1 kHz、±3 V の方形波) |

## 見るべき値

直流の電圧はテスターで、GND を基準に B と D に当てる (テスターの入力 10 MΩ は 100 kΩ の負荷の 1 % で、読みはほとんど変わらない)。

| 測る所 | 期待する値 (計算値) | 分かること |
| --- | --- | --- |
| B (1 段目、RL 100 kΩ) | 約 4.5 V | 2V<sub>p</sub> (6 V) からダイオード 2 本ぶんと負荷のぶん低い。倍電圧 |
| D (2 段目、RL 100 kΩ) | 約 9.0 V | 4V<sub>p</sub> (12 V) から 4 本ぶんと負荷のぶん低い |
| D の揺れ (RL 100 kΩ) | 約 0.18 Vpp | 負荷の電流 (90 µA) が 1 周期ごとにコンデンサから抜けるぶん |
| D (RL を抜く) | 約 10.9 V | 負荷が無いと理想 (12 V − 4 本の V<sub>F</sub>) に近づき、揺れも 0.01 Vpp まで減る |
| W1 を入れてから D が 9 割に上がるまで | 約 18 ms | 段ごとに少しずつ電荷が送られるので、すぐには上がらない |

**段を増やすと**、理想は 2n V<sub>p</sub> (n は段の数) で増えるが、負荷をつないだときの下がりと揺れは段の数の 2〜3 乗で増える
(遠い段ほど、電荷を何個ものコンデンサを経由して受け取るため)。CW 回路が電流の小さい高電圧 (µA〜mA) にしか使われないのはこのため。

## LTspice での確かめ

`sim/10-cockcroft-walton.cir` で、図1 に ±3 V・1 kHz の方形波を入れて 400 ms まで回し、最後の 20 ms の平均と揺れを読んだ。
ダイオードは 1N4148 の代用模型 (1-9 と同じ D4148。実測ではない)。負荷は 100 kΩ と 1 GΩ (負荷なし) の 2 通り。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| B (RL 100 kΩ) | 約 4.5 V | 4.53 V | 合う |
| D (RL 100 kΩ) | 約 9.0 V | 9.01 V | 合う |
| D の揺れ (RL 100 kΩ) | 約 0.18 Vpp | 0.180 Vpp | 合う |
| D・揺れ (負荷なし) | 約 10.9 V・0.01 Vpp | 10.93 V・0.011 Vpp | 合う |
| D が 9 割 (8.1 V) になるまで | 約 18 ms | 18.2 ms (5 ms で 4.1 V、20 ms で 8.0 V) | 合う |
| W1 の電流の山 (立ち上がり / 定常) | 10 mA 以下 | 9.5 mA / +0.80 mA・−0.71 mA | 合う |

本文の 9.0 V・4.5 V・0.18 Vpp は、この結果から書いた値。

## 出典

自作。

参考: [コッククロフト・ウォルトン回路 (Wikipedia)](https://ja.wikipedia.org/wiki/コッククロフト・ウォルトン回路)、[Voltage multiplier (Wikipedia)](https://en.wikipedia.org/wiki/Voltage_multiplier)、[1N4148 データシート (Vishay, 81857)](https://www.vishay.com/docs/81857/1n4148.pdf)
