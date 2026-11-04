---
book: circuits
chapter: 2
id: 2-14
title: 定電流源 — Tr + ツェナー / 2 石
tier: 200
source: 自作
---

# 2-14 定電流源 — Tr + ツェナー / 2 石

**定電流源**は、負荷の抵抗や負荷に掛かる電圧が変わっても、同じ電流を流し続ける回路。LED の明るさをそろえる、
差動増幅 (2-6) のエミッタに電流を供給する、電池を一定の電流で放電させる、などに使う。2-9 では JFET 1 本で作った。
この題では、トランジスタで作る定番の 2 つを並べて比べる。

- **A: Tr + ツェナー** — ベースをツェナーダイオードで一定の電圧に止める。エミッタはそれより V<sub>BE</sub> だけ低い所に止まり、
  `RE` の両端の電圧 (V<sub>Z</sub> − V<sub>BE</sub>) が一定なので、エミッタの電流も一定になる。I ≈ (V<sub>Z</sub> − V<sub>BE</sub>) / `RE`
- **B: Tr 2 石** — `RS` の両端の電圧を Q3 の V<sub>BE</sub> で見張る。電流が増えて `RS` の電圧が 0.6 V を越えると Q3 が流し、
  Q2 のベースを引き下げて電流を戻す (負帰還)。I ≈ V<sub>BE</sub> / `RS`

どちらもコレクタの側 (負荷) の電圧には関係なく電流が決まる。ただし、トランジスタが飽和しない範囲 (**コンプライアンス**、動ける電圧の幅) に限る。
この題では、負荷の上の電圧を W1 で 0〜5 V に振り、負荷の電流がどこまで一定かをオシロで見る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 定電流源。A は Tr + ツェナー、B は Tr 2 石 (負荷の上を W1 で振る)
parts:
  W1: triangle 1,3 1,6 l=$\mathrm{W1}$
  M1: voltmeter 3,3 3,6 l=$\mathrm{CH1}$
  G1: ground 1,6
  VCC: vcc 5,5 5V
  RZ: resistor 5,5 5,8 1k
  DZ1: zener 5,12 5,8 5.1V
  RL1: resistor 7,3 7,5 680
  M2: voltmeter 9,3 9,5 l=$\mathrm{CH2}$
  Q1: npn 7,8
  RE: resistor 7,10 7,12 1.3k
  RL2: resistor 13,3 13,5 680
  RB: resistor 9,8 11,8 10k
  G2: ground 9,9
  Q2: npn 13,8
  Q3: npn 11,10 mirror
  RS: resistor 13,10 13,12 200
  VEE: vee 9,13 5V
wires:
  - 1,3 -- 3,3
  - 1,6 -- 3,6
  - 3,3 -- 7,3
  - 7,3 -- 9,3
  - 9,3 -- 13,3
  - 9,5 -- 7,5
  - 7,5 -- Q1.C
  - 5,8 -- Q1.B
  - Q1.E -- 7,10
  - 13,5 -- Q2.C
  - Q2.E -- 13,10
  - Q3.B -- 13,10
  - 9,8 -- 9,9
  - 11,8 -- Q2.B
  - Q3.C -- 11,8
  - Q3.E -- 11,12
  - 5,12 -- 7,12
  - 7,12 -- 9,12
  - 9,12 -- 11,12
  - 11,12 -- 13,12
  - 9,12 -- 9,13
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/14-constant-current.svg)

図1 の電源は AD3 の Supplies の ±5 V (V+ が +5 V、V− が VEE = −5 V)。両電源にしたのは、5 V の単電源ではツェナー (5.1 V) とトランジスタの電圧が収まらないため。
W1 は 2 つの負荷 `RL1`・`RL2` (680 Ω) の上を同時に振る。CH1 で W1、CH2 で `RL1` の両端 (差動) を見る。B を見るときは CH2 を `RL2` へつなぎ替える。

- **A の電流**: `RZ` (1 kΩ) でツェナーに約 5 mA を流す。1N5231B は 20 mA で 5.1 V の規格なので、5 mA では約 4.9 V (目安)。
  エミッタは VEE + 4.9 − 0.65 ≈ **−0.75 V**、I ≈ 4.25 V / 1.3 kΩ ≈ **3.3 mA**。`RL1` の両端は 3.3 mA × 680 Ω ≈ **2.2 V**
- **B の電流**: Q3 の V<sub>BE</sub> は 3 mA ほどでは約 0.61 V。I ≈ 0.61 V / 200 Ω ≈ **3.05 mA**、`RL2` の両端は約 **2.07 V**。
  `RB` (10 kΩ) は Q2 のベースへ電流を送り、余りを Q3 が引き抜く
- **A のコンプライアンス**: Q1 のコレクタ (W1 − 2.2 V) が エミッタ (−0.75 V) より 0.3 V ほど上にある間は一定。W1 ≳ **1.6 V** まで
- **B のコンプライアンス**: Q2 のエミッタは VEE + 0.61 V ≈ −4.4 V で、コレクタはその少し上まで下がれる。W1 ≳ **−2 V** まで一定で、0〜5 V では全域で一定
- **温度**: A は V<sub>Z</sub> − V<sub>BE</sub> = 4.25 V のうちの V<sub>BE</sub> (−2 mV/°C) と V<sub>Z</sub> の温度係数 (5.1 V で約 +0.03 %/°C) が効き、
  電流の変化は 0.1 %/°C 以下 (見積り)。B は 0.61 V の V<sub>BE</sub> そのものが −2 mV/°C 動くので、**約 −0.3 %/°C** (見積り)

A は温度に強いが動ける幅が狭く、B は動ける幅が広いが温度に弱い。B の `RS` を流れる電流は、Q3 を指で温めると減るのが分かる。

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 定電流源 (左が A、右が B。下の − レールが −5 V)
# 上の + レール = +5 V (V+)、上の − レール = GND、下の − レール = −5 V (V−、紫の線)。下の + レールは使わない
board: full
parts:
  RZ: resistor a8 +t8 1k
  DZ1: zener h5 h8 5.1V
  Q1: transistor g8(B) g9(C) g10(E) 2SC1815 cap=above:1,0
  RE: resistor j10 -b10 1.3k
  RL1: resistor h16 h9 680
  RL2: resistor i16 i23 680
  Q2: transistor g22(B) g23(C) g24(E) 2SC1815 cap=above:1,0
  Q3: transistor g28(B) g29(C) g30(E) 2SC1815
  RS: resistor j24 -b24 200
  RB: resistor a22 -t22 10k
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (V+・GND・CH1−)
    pins: [V+, GND, 1-]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery 3 (V−・W1・CH1・CH2)
    pins: [V-, 2-, W1, 1+, 2+]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1- -- -t5 black
  - f8 -- e8 white
  - j5 -- -b5 purple
  - f22 -- e22 white
  - f29 -- e29 green
  - d29 -- d22 green
  - h24 -- h28 orange [v-10]
  - j30 -- -b30 purple
  - AD1.V- -- -b3 purple
  - AD1.2- -- j9 blue
  - AD1.W1 -- j16 yellow
  - AD1.1+ -- j17 orange
  - f17 -- f16 yellow
  - AD1.2+ -- j18 blue
  - g18 -- g16 blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/14-constant-current.svg)

図2 は full のブレッドボード。部品は下のブロックに並べ、**レールの使い方が 3 つある**ので注意する。

- 上の + レール = +5 V (AD3 の V+、赤)、上の − レール = GND (黒)、**下の − レール = −5 V** (AD3 の V−、紫)。下の + レールは使わない
- **A (列 5〜10)**: Q1 は**平らな面を奥に**して挿し、手前から見て左から B・C・E (列 8・9・10)。ツェナー `DZ1` は帯 (カソード) を列 8 にして `h5`–`h8`、
  アノードの列 5 を紫の線で −5 V へ。列 8 は白い線で上のブロックへ渡し、`RZ` で +5 V へ。`RE` は列 10 から −5 V へ
- **W1 の列 (列 16・17)**: W1 (黄) は `j16`、CH1 の 1+ (橙) は `j17` で、`f17`–`f16` で同じにする。CH2 の 2+ (青) は `j18` から `g18`–`g16` で同じ列へ。
  `RL1` (`h16`–`h9`) が Q1 のコレクタへ、`RL2` (`i16`–`i23`) が Q2 のコレクタへ
- **B (列 22〜30)**: Q2・Q3 も平らな面を奥に、左から B・C・E。Q2 の E (列 24) と Q3 の B (列 28) を橙の線 `h24`–`h28` で、
  Q3 の C (列 29) と Q2 の B (列 22) を緑の線で上のブロックの d 行を回してつなぐ。`RB` は列 22 の上から GND へ、`RS` は列 24 から −5 V へ、Q3 の E は −5 V へ
- CH2 の 2− (青) は `j9` (A の負荷の下)。B を測るときは 2− を `j23` に挿し替える

## 計器の設定

計器は AD3 のオシロ (負荷の電圧を W1 と同じ時間軸で比べるため)。Supplies で V+ を +5 V、V− を −5 V にする。
W1 を Triangle、100 Hz、Amplitude 2.5 V、Offset 2.5 V (0〜5 V)。CH1 と CH2 は 1 V/div・Offset −4 V、時間軸 1 ms/div、
CH1 の立ち下がり 2.5 V でトリガして画面の左端に寄せる。CH2 は差動 (2+ が W1、2− が負荷の下) で、`RL` の両端の電圧 = 電流 × 680 Ω を見る。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 A (Tr + ツェナー) — W1 が 1.5 V を下回ると負荷の電流が減る
time: 1ms/div
trigger: ch1 falling 2.5V at -5div
ch1: {wave: triangle 100Hz 2.5V offset 2.5V, range: 1V/div, position: -4div}
ch2: {wave: ch1 | gain 0.874 | offset 0.877V | clip 0V 2.21V, range: 1V/div, position: -4div}
cursors: [0.98ms, 2.5ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/14-constant-current-1.svg)

図3 の X1 は W1 が 1.52 V の所で、CH2 (A の負荷) がここから下がり始める。X2 (W1 = 0 V) では 0.88 V (1.3 mA) まで落ちる。
2− を `j23` に挿し替えると図4 になり、CH2 (B の負荷) は 2.07 V (3.05 mA) の一直線のまま変わらない。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 B (Tr 2 石) — W1 が 0 V まで下がっても負荷の電流は一定
time: 1ms/div
trigger: ch1 falling 2.5V at -5div
ch1: {wave: triangle 100Hz 2.5V offset 2.5V, range: 1V/div, position: -4div}
ch2: {wave: dc 2.07V, range: 1V/div, position: -4div}
cursors: [0.98ms, 2.5ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/14-constant-current-2.svg)

図3・図4 の CH2 の値は LTspice の .dc の読み (下の節) を折れ線にしたもの。A が下がり始める所は、Q1 が飽和に入る所である。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| DZ1 | ツェナーダイオード (0.5 W) | 1N5231B (5.1 V。5 mA で約 4.9 V) |
| RZ | 抵抗 (1/4 W) | 1 kΩ (ツェナーに約 5 mA。24 mW) |
| RE | 抵抗 (1/4 W) | 1.3 kΩ (14 mW) |
| RS | 抵抗 (1/4 W) | 200 Ω |
| RB | 抵抗 (1/4 W) | 10 kΩ |
| RL1, RL2 | 抵抗 (1/4 W) | 680 Ω (負荷。電流を電圧で読む) |
| Q1, Q2, Q3 | NPN トランジスタ | 2SC1815 |
| — | 電源 | AD3 の V+ (+5 V) と V− (−5 V) — ツェナーの 5.1 V と B の飽和しない幅のために両電源 |

W1 が 2 つの負荷へ出す電流は合わせて約 6.4 mA で、AD3 の Wavegen の目安 (10 mA) に収まる。

## 見るべき値

直流は W1 を 5 V の DC にしてテスターで測る。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ツェナーの両端 (列 5〜8) | 約 4.9 V | 5 mA ではツェナー電圧が規格 (20 mA で 5.1 V) より少し低い |
| A の `RE` の両端 | 約 4.24 V | V<sub>Z</sub> − V<sub>BE</sub> |
| A の負荷 `RL1` の両端 (W1 = 5 V) | 約 2.21 V (3.25 mA) | I = (V<sub>Z</sub> − V<sub>BE</sub>) / `RE` |
| B の `RS` の両端 | 約 0.61 V | Q3 の V<sub>BE</sub> |
| B の負荷 `RL2` の両端 (W1 = 5 V) | 約 2.07 V (3.05 mA) | I = V<sub>BE</sub> / `RS` |
| A の電流が 1 % 落ちる W1 | 約 1.6 V | A のコンプライアンスの下の端 |
| W1 = 0 V の A の負荷の電圧 | 約 0.88 V | Q1 が飽和して電流が減る |
| W1 = 0 V の B の負荷の電圧 | 約 2.07 V | B は 0 V でも一定 |

## LTspice での確かめ

`sim/14-constant-current.cir` で W1 を −5〜+5 V に振る .dc を回し、負荷・`RE`・`RS` の電圧と、負荷の電流が 1 % 落ちる W1 を読んだ。
トランジスタは 2-3 と同じ 2SC1815 の代用モデル、ツェナーは 1N5231B に似せた模型 (5 mA で 4.9 V になるよう置いた仮定)。どちらも実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| ツェナーの電圧 / 電流 | 約 4.9 V / 約 5 mA | 4.91 V / 5.09 mA | 合う (模型をそう置いた) |
| A の `RE` の電圧 | 約 4.25 V | 4.24 V | 合う |
| A の負荷の電流 | 約 3.3 mA | 3.25 mA (`RL1` 2.21 V) | 合う |
| B の `RS` の電圧 | 約 0.61 V | 0.611 V | 合う |
| B の負荷の電流 | 約 3.05 mA | 3.05 mA (`RL2` 2.07 V) | 合う |
| A の電流が 1 % 落ちる W1 | 約 1.6 V | 1.56 V | 合う |
| B の電流が 1 % 落ちる W1 | 約 −2 V | −2.19 V | 合う |
| W1 = 0 V の A の負荷の電圧 | 約 0.88 V | 0.877 V | 本文の値は LTspice の読み |

A のエミッタは −0.76 V、B のエミッタは −4.39 V で、B のほうがエミッタが VEE に近い分だけ、コンプライアンスが 3.7 V 広い。
温度係数の行は見積りで、LTspice では回していない (対象外)。

## 出典

自作。ツェナーの電圧と温度係数は [Vishay 1N5221 series のデータシート](https://www.vishay.com/docs/85588/1n5221.pdf) (Document Number 85588)。

参考: [Current source (Wikipedia)](https://en.wikipedia.org/wiki/Current_source)、[ツェナーダイオード (Wikipedia)](https://ja.wikipedia.org/wiki/ツェナーダイオード)
