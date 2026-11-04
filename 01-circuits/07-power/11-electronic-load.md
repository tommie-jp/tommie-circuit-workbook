---
book: circuits
chapter: 7
id: 7-11
title: 電子負荷
tier: 200
source: 自作
---

# 7-11 電子負荷

電源や電池を試すには、決まった電流を引き出す負荷が要る。抵抗を負荷にすると、電源の電圧が下がれば電流も下がり、
電流を変えるたびに抵抗を付け替えることになる。**電子負荷**は、MOSFET を「電圧で決めた電流だけを流す抵抗」として働かせ、
電源の電圧によらず設定どおりの電流を引く。4 章の OP アンプの負帰還と、2 章の MOSFET の組み合わせで作れる。

働きは次のとおり。OP アンプ U1 は、+ 入力 (設定の電圧 V<sub>set</sub>) と − 入力 (電流を読む抵抗 Rs の電圧) が等しくなるように、
MOSFET Q1 のゲートを動かす。Rs を流れる電流は Q1 のドレインから来るので、

- 電流 I = V<sub>set</sub> ÷ Rs (Rs 10 Ω なら 1 V で 100 mA、0.2 V で 20 mA)
- 被試験物 (DUT。試す電源) の電圧が変わっても、Q1 の V<sub>DS</sub> が変わって吸収するだけで、電流は変わらない
- DUT の電圧と電流を同時に読めば、DUT の出力抵抗が分かる (0-7 のテブナン等価の測り方)

この題では、AD3 の W1 で V<sub>set</sub> を 0.2 V と 1.0 V の間で切り替え、20 mA と 100 mA の 2 つの電流を交互に引いて、
電流の波形と DUT の電圧の下がり方を見る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 OP アンプと MOSFET の電子負荷 (I は Vset / Rs)
parts:
  U1: opamp 5,4 +up
  W1: square 1.2,3.6 1.2,5.4 l=$\mathrm{W1}$
  G1: ground 1.2,5.4
  M1: voltmeter 3,3.6 3,5.4 l=$\mathrm{CH1}$
  G5: ground 3,5.4
  C1: capacitor 3.6,6.4 6.6,6.4 10n
  R2: resistor 3.6,7.6 6,7.6 1k
  Rg: resistor 6.6,4 8.2,4 100
  Q1: nmos-e 9,3.81 IRLZ44N
  Rs: resistor 9,5.4 9,7 10
  G2: ground 9,7
  M2: voltmeter 11.2,5.4 11.2,7 l=$\mathrm{CH2}$
  G3: ground 11.2,7
  B1: battery 12.4,1 12.4,3 5 l=$\mathrm{DUT}$
  G4: ground 12.4,3
wires:
  - 1.2,3.6 -- 3,3.6
  - 3,3.6 -| U1.+
  - U1.- -| 3.6,6.4
  - 3.6,6.4 -- 3.6,7.6
  - U1.out -- 6.6,4
  - 6.6,4 -- 6.6,6.4
  - 6,7.6 -- 7.8,7.6 -- 7.8,5.4 -- 9,5.4
  - 8.2,4 -| Q1.G
  - Q1.S -- 9,5.4
  - 9,5.4 -- 11.2,5.4
  - Q1.D |- 12.4,1
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/circuit/11-electronic-load.svg)

- U1 は LM358 の 2 回路のうちの 1 つ (図では B 側。電源の 8 番 V+ と 4 番 GND は描いていない)。電源は AD3 の V+ (5 V、1 mA ほど)。
  LM358 は入力が GND の電圧まで扱え、5 V の単電源で V<sub>set</sub> 0〜1 V を受けられる。出力は 5 V − 1.5 V = 3.5 V まで上がる
- Q1 (IRLZ44N) はロジックレベルの MOSFET (V<sub>GS(th)</sub> 1.0〜2.0 V)。LM358 の出力 3.5 V で 100 mA を流すのに足りる (LTspice ではゲート 2.6 V)。
  IRF520 (V<sub>GS(th)</sub> 2.0〜4.0 V) では 3.5 V で足りない品がある
- R2 (1 kΩ) と C1 (10 nF) は帰還の補償。Q1 のゲートの容量 (約 1.7 nF) と Rg が OP アンプの帰還の中に遅れを作るので、
  − 入力を Rs から R2 で切り離し、C1 で出力から − 入力へ速い帰還を返して、発振を防ぐ。直流では C1 は開いているので、I = V<sub>set</sub> ÷ Rs は変わらない
- Rs (10 Ω、1 W) は電流を電圧に直す抵抗。100 mA で 1 V・0.1 W
- B1 は DUT (試す電源)。ここでは 5 V の USB アダプタか、単 3 電池 3 本 (4.5 V) を例にする。DUT の − は GND (AD3 の GND と共通)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 LM358 と IRLZ44N の電子負荷 (上の + レールは AD3 の V+)
board: half
parts:
  U1: dip8 @ e5 LM358
  C1: capacitor/ceramic c6 c7 10n cap=left
  Rg: resistor d6 d18 100
  R2: resistor b7 b16 1k
  Q1: transistor/to220 j16(S) j17(D) j18(G) IRLZ44N
  Rs: resistor c16 c21 10 cap=above
  AD:
    type: device
    at: top
    label: AD3 (V+・W1・Scope)
    pins: [V+, GND, W1, 1+, 1-, 2-, 2+]
  DUT:
    type: device
    at: top
    label: DUT (5V の電源)
    pins: ["+", "-"]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - a5 -- +t5 red
  - AD.W1 -- a8 yellow
  - AD.1+ -- c8 blue
  - g5 -- g6 white
  - j7 -- -b7 black
  - j8 -- -b8 black
  - e18 -- f18 orange
  - e16 -- f16 green
  - a21 -- -t21 black
  - AD.2+ -- a16 green
  - AD.1- -- -t10 black
  - AD.2- -- -t12 black
  - DUT.+ -- a17 purple
  - DUT.- -- -t26 black
  - e17 -- f17 purple
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/breadboard/11-electronic-load.svg)

- U1 (LM358) は 5〜8 列。上の段の B 側を使う (e6 が出力 OUT2、e7 が − 入力 IN2−、e8 が + 入力 IN2+、e5 が V+)。
  使わない A 側は、出力 (f5) と − 入力 (f6) を白の線でつなぎ (ボルテージフォロア)、+ 入力 (f7) を GND へ。浮かせると A 側が振れて電流を食う。4 番 (f8) が GND
- C1 は出力 (6 列) と − 入力 (7 列) の間。R2 は − 入力 (7 列) から Q1 のソース (16 列) へ。Rg は出力 (6 列) から 18 列へ渡し、18 列から橙の線で下のブロックの Q1 のゲートへ下ろす
- Q1 (IRLZ44N、TO-220) は下の段の 16・17・18 列 (`j` 行) に、**印字面を奥に向けて**挿す (左から S・D・G。手前に向けると G・D・S)。
  胴が g〜i 行を覆うので、線は f 行で入れる。ソース (16 列) とドレイン (17 列) は、上の段と緑・紫の線 (`e16`→`f16`・`e17`→`f17`) でつなぐ
- Rs は 16 列の上の段から 21 列へ (21 列は − レール)。16 列の上の段がソースの点で、R2・Rs・Scope の 2+ (緑、`a16`) が集まる
- DUT の + (紫) は 17 列の上の段 (`a17`) に入れる。DUT の − は − レールへ。
  **上の + レールは AD3 の V+ (U1 の電源) で、DUT とは別**。DUT の + を + レールにつながない
- W1 (黄、`a8`) と Scope の 1+ (青、`c8`) は + 入力の 8 列
- 100 mA が通る穴は、16 列・17 列・21 列と − レール。1 穴 200 mA の内側。Q1 の熱は 7-12 で測る

## 計器の設定

計器は Analog Discovery 3 の V+ (U1 の電源 5 V)、W1 (設定の電圧) と Scope。電流が設定に追いつく様子は時間の波形で見る。
W1 は Simple の Square、Frequency 500 Hz、Amplitude 0.4 V、Offset 0.6 V (0.2 V と 1.0 V の間)、Symmetry 50 %。
Scope は 1+ を V<sub>set</sub>、2+ を Rs の上にして、2 ch とも 200 mV/div、500 µs/div。2+ の電圧を 10 Ω で割ったものが電流。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 設定 (CH1) と Rs の電圧 (CH2) — 20 mA と 100 mA を交互に引く
time: 500us/div
trigger: ch1 rising 600mV
ch1: {wave: square 500Hz 400mV offset 600mV, range: 200mV/div, position: -3div}
ch2: {wave: "ch1 | rc 1us", range: 200mV/div, position: -3div}
cursors: [500us, 1.5ms]
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/scope/11-electronic-load.svg)

図3 は理想の形。CH2 は CH1 と重なり、0.2 V (20 mA) と 1.0 V (100 mA) を行き来する。切り替わりにかかる時間は 2〜3 µs (LTspice) で、
LM358 の出力の速さ (スルーレート 0.3 V/µs) で決まる。500 µs/div では縦の線に見える。時間軸を 2 µs/div にすると、CH2 の縁が斜めに見える。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | OP アンプ (2 回路、DIP-8) | LM358 (B 側を使う) |
| Q1 | N チャネル パワー MOSFET (ロジックレベル、TO-220) | IRLZ44N (55 V・47 A、V<sub>GS(th)</sub> 1.0〜2.0 V) |
| Rs | 抵抗 (電流を読む、1 W) | 10 Ω (100 mA で 0.1 W) |
| Rg | 抵抗 (ゲート直列) | 100 Ω |
| R2 | 抵抗 (帰還) | 1 kΩ |
| C1 | セラミックコンデンサ (補償) | 10 nF (103) |
| — | U1 の電源 | Analog Discovery 3 の V+ (5 V) |
| — | 被試験物 (DUT) | 5 V の USB アダプタか単 3 電池 3 本 (4.5 V)。電流は最大 100 mA |
| — | 信号源・計器 | Analog Discovery 3 の W1 (V<sub>set</sub> 0.2 V / 1.0 V、500 Hz) と Scope (1+ = V<sub>set</sub>、2+ = Rs の上、1−・2− = GND) |

## 見るべき値

表の値は計算値と LTspice の値で、実測ではない。DUT の電圧は、W1 を止めて V<sub>set</sub> を直流 (Offset だけ) にし、テスターで DUT の + と GND の間を測る。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| V<sub>set</sub> 0.2 V / 1.0 V のときの Rs の電圧 | 0.2 V / 1.0 V | 帰還で − 入力が + 入力に等しくなる |
| そのときの電流 | 20 mA / 100 mA | I = V<sub>set</sub> ÷ Rs |
| DUT を 5 V から 4.5 V (電池) に替えたときの電流 | 変わらない | Q1 の V<sub>DS</sub> が変わって吸収する |
| 100 mA のときの Q1 のゲート電圧 | 2.5 V 前後 | LM358 の出力の上限 3.5 V の内側 |
| 100 mA のときの Q1 の熱 | (5 V − 1 V) × 0.1 A ≈ 0.4 W | Rs の 1 V を除いた電圧がすべて Q1 の熱になる |
| 20 mA と 100 mA で読んだ DUT の電圧の差 ΔV | 内部抵抗 0.5 Ω の電源なら 40 mV | 出力抵抗 = ΔV ÷ ΔI (ΔI = 80 mA) |
| DUT の電圧を下げていったとき | 1 V を切ると 100 mA を流せない | Rs の 1 V と Q1 の降下ぶんは DUT から要る |

Q1 の 0.4 W は、TO-220 を放熱器なしで使うと接合部と周りの間の熱抵抗 62 °C/W (データシートの R<sub>θJA</sub>) で約 25 °C の上昇になる。
長く流すと Q1 は触れて温かい程度になる。電流を上げたいときは放熱器を付ける (7-12)。

## LTspice での確かめ

`sim/11-electronic-load.cir` で図1 を回した。LM358 は 4-11 と同じ汎用模型 (GBW 1 MHz、スルーレート 0.3 V/µs、出力は V+ − 1.5 V まで)、
IRLZ44N は VDMOS の模型 (V<sub>GS(th)</sub> 1.5 V、C<sub>iss</sub> 約 1.7 nF) で、どちらも仮定。DUT は 5 V と内部抵抗 0.5 Ω (仮定)。C1 は 1 nF・10 nF・100 nF を比べた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 電流 (V<sub>set</sub> 0.2 V / 1.0 V) | 20 mA / 100 mA | 20.0 mA / 100.0 mA | 合う |
| 100 mA のときのゲート電圧 | 2.5 V 前後 | 2.60 V | 合う (模型の V<sub>GS(th)</sub> による) |
| DUT の電圧 (20 mA / 100 mA) | 内部抵抗 0.5 Ω で差 40 mV | 4.990 V / 4.950 V | 合う |
| Q1 の熱 (100 mA) | 約 0.4 W | 0.395 W | 合う |
| 切り替わりの時間 (10〜90 %) | 2〜3 µs | 2.3〜2.4 µs | 合う |
| 行き過ぎ (C1 1 nF / 10 nF / 100 nF) | 10 nF で無い | 0.6 % / 0 % / 0 % | 合う (どれも発振しない。10 nF を選んだ) |

## 出典

自作。

参考: [Infineon IRLZ44N のデータシート](https://www.infineon.com/dgdl/irlz44npbf.pdf?fileId=5546d462533600a40153567217c32725)、[TI LM358 のデータシート](https://www.ti.com/lit/ds/symlink/lm358.pdf)、[テブナンの定理 (Wikipedia)](https://ja.wikipedia.org/wiki/テブナンの定理)
