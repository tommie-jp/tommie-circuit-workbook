---
book: circuits
chapter: 7
id: 7-7
title: ハイサイドとローサイド
tier: 100
board: BB
source: 自作
---

# 7-7 ハイサイドとローサイド

負荷を ON/OFF するスイッチは、負荷より GND 側 (**ローサイド**) に置くか、
負荷より電源側 (**ハイサイド**) に置くかの 2 通りがある。2-1 (NPN) と 7-2 (N チャネル
MOSFET) は、どちらもローサイドだった。同じ負荷 (LED) を今度はハイサイド
(P チャネル MOSFET) で切ってみて、駆動のしかたの違いを比べる。
負荷の片側を GND につないだままにしたい機器 (車の電装品など) では、ハイサイドが要る。

## 回路図

```circuit
title: 図1 ローサイド (左) とハイサイド (右) の比較
parts:
  VCC: vcc b6 5V
  R1: resistor b6 d6 330
  D1: led d6 e6
  Q1: nmos-e f6 2N7000
  IN1: port f2
  Rg1: resistor f2 f4 100
  Rpd1: resistor f4 h4 10k
  G1: ground g6
  G2: ground h4
  VCC: vcc b13 5V
  Q2: pmos-e d13 BSS84
  R2: resistor e13 g13 330
  D2: led g13 h13
  IN2: port d10
  Rg2: resistor d10 d12 100
  Rpu2: resistor d12 b12 10k
  VCC: vcc b12 5V
  G3: ground h13
wires:
  - e6 -- Q1.D
  - Q1.S -- g6
  - f4 |- Q1.G
  - b13 -- Q2.S
  - Q2.D -- e13
  - d12 |- Q2.G
notes:
  - line a8 h8 ink
  - text a3 center: ローサイド (N ch)
  - text a11 center: ハイサイド (P ch)
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/circuit/07-high-side-low-side.svg)

- ローサイド (図1 の左): 負荷 (R1・D1) を VCC 側に固定し、GND 側を Q1 (N チャネル
  MOSFET) で開閉する。2-1・7-2 と同じ形。IN1 (GPIO) が H で ON になる、素直な向きだ。
  Rpd1 (10 kΩ) は、GPIO が何もつながっていないのと同じ状態 (高インピーダンス) のときに Q1 を
  確実に OFF に保つプルダウン (7-2 で見た)
- ハイサイド (図1 の右): 負荷 (R2・D2) を GND 側に固定し、VCC 側を Q2 (P チャネル
  MOSFET) で開閉する。Q2 のソースが VCC、ドレインが負荷側になるので、
  ゲート-ソース間電圧 V<sub>GS</sub> は「IN2 の電圧 − VCC」になる。
  IN2 が VCC (H) のとき V<sub>GS</sub> = 0 で OFF、IN2 が GND (L) のとき
  V<sub>GS</sub> = −VCC で ON になる。**ローサイドと ON/OFF の論理が逆になる**のが、
  ハイサイドの特徴だ。Rpu2 (10 kΩ、VCC へのプルアップ) は、GPIO が高インピーダンスの
  とき、ゲートを H に引いて Q2 を確実に OFF に保つ
- この回路は、VCC = 5 V (GPIO と同じ電源) を前提にしている。VCC が GPIO より
  高い電源 (例えば 12 V のモータ電源) だと、GPIO の H (5 V や 3.3 V) では
  ゲートを VCC まで持ち上げきれず、Q2 を確実に OFF にできない。その場合は、
  ゲートを VCC へプルアップし、NPN 1 石で GND へ引き下げる回路が要る (2-11 の PNP ハイサイドスイッチ、
  7-8 のゲートドライバ IC 参照)

## 実体配線図

```breadboard
title: 図2 ローサイド (左) とハイサイド (右) を 1 枚のブレッドボードに組む
board: half
parts:
  R1: resistor f2 f5 330
  D1: led f6(A) f9(K) red
  Q1: transistor h9(D) h10(G) h11(S) 2N7000
  Rg1: resistor b10 b13 100
  Rpd1: resistor d10 d12 10k
  Q2: transistor h19(S) h20(G) h21(D) BSS84
  R2: resistor f22 f25 330
  D2: led f26(A) f29(K) red
  Rg2: resistor b17 b20 100
  Rpu2: resistor d18 d20 10k
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies V+ = 5V、Wavegen、Scope)
    pins: [V+, GND, W1, W2, 1+, 2+, 1-, 2-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - j2 -- +b2 red
  - g5 -- g6 orange
  - j11 -- -b11 black
  - e10 -- f10 orange
  - a12 -- -t12 black
  - e20 -- f20 orange
  - a18 -- +t18 red
  - j19 -- +b19 red
  - g21 -- g22 orange
  - g25 -- g26 orange
  - j29 -- -b29 black
  - +t29 -- +b29 red
  - -t30 -- -b30 black
  - AD.W1 -- a13 yellow
  - AD.W2 -- a17 yellow
  - AD.1+ -- d13 blue
  - AD.2+ -- f21 green
  - AD.1- -- -t4 black
  - AD.2- -- -t6 black
  - AD.GND -- -t8 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/breadboard/07-high-side-low-side.svg)

- 電源は AD3 の Supplies の V+ (5 V) を使う。LED 2 個で約 18 mA (下の表の 9 mA × 2) なので、Supplies の 50 mA (USB 給電で 250 mW) に収まり、ブレッドボードの 1 穴 200 mA・ブレッドボード全体 500 mA の内側でもある
- 左がローサイド、右がハイサイド。+ レールの赤い線は上下 (`+t29` と `+b29`) をつないで、ブレッドボードの下側の Q2 のソースと Rpu2 にも 5 V を届ける。− レールも同じ (`-t30` と `-b30`)
- Q1 のピンは、平らな面を手前に見て左から S・G・D。図は平らな面を奥に向けて挿すので、左から D・G・S になる (7-2 と同じ)。
  Q2 の BSS84 は面実装 (SOT-23) なので、変換基板に載せた姿で描いた。変換基板のピンの並びは品によるため、図の S・G・D はその基板の印に合わせて挿す
- 信号の源は AD3 の Wavegen。W1 を Rg1 の左端 (13 列) に、W2 を Rg2 の左端 (17 列) に入れる。W2 は W1 と同じ設定にする (WaveForms の Synchronized)。
  同じ信号を 2 つの入力に入れると、IN が H のときは D1 だけ、L のときは D2 だけが点く
- Scope の 1+ (青) は 13 列の IN1 を、2+ (緑) は Q2 のドレイン (21 列) を見る。1−・2−・GND (黒) は上の − レールへ

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | N チャネル MOSFET (ロジックレベル) | 2N7000 |
| Q2 | P チャネル MOSFET (ロジックレベル。面実装の SOT-23 なので、試すときは変換基板に載せる) | BSS84 |
| R1・R2 | 抵抗 (負荷電流を決める) | 330 Ω |
| D1・D2 | LED (赤、負荷の代わり) | V<sub>F</sub> ≈ 2.0 V |
| Rg1・Rg2 | 抵抗 (ゲート直列) | 100 Ω |
| Rpd1 | 抵抗 (ゲートプルダウン) | 10 kΩ |
| Rpu2 | 抵抗 (ゲートプルアップ) | 10 kΩ |
| — | 電源 | 5 V (GPIO と共通)。AD3 の Supplies の V+ (約 18 mA) |
| — | 信号源・計器 | Analog Discovery 3 の W1 (IN1)・W2 (IN2) と Scope (1+ = IN1、2+ = Q2 のドレイン、1−・2− = GND) |

## 計器の設定

計器は Analog Discovery 3。IN の H/L の切り替わりと LED の点き方の関係は時間の波形で見るので、テスターでは足りない (V<sub>GS</sub> だけならテスターで足りる)。
W1・W2 はどちらも Simple の Square、Frequency 100 Hz、Amplitude 2.5 V、Offset 2.5 V、Symmetry 50 % (0〜5 V の方形波)。
目で見て確かめるときは 1 Hz にする。Scope は 1+ を IN1、2+ を Q2 のドレインにして、2 ch とも 1 V/div、2 ms/div。

```scope
title: 図3 IN が H の間は D1 (ローサイド) が、L の間は D2 (ハイサイド) が点く
time: 2ms/div
trigger: ch1 rising 2.5V
ch1: {wave: pulse 100Hz 2.5V offset 2.5V duty 50%, range: 1V/div, position: -3div}
ch2: {wave: "ch1 | invert | offset 5V | gain 0.98", range: 1V/div, position: -3div}
cursors: [2.5ms, 7.5ms]
measure: [vmax, vmin, freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/scope/07-high-side-low-side.svg)

図3 は理想の形。CH1 は IN1 (= IN2)、CH2 は Q2 のドレイン。カーソルの 2.5 ms は IN が H の真ん中 (CH1 = 5 V、CH2 = 0 V)、7.5 ms は L の真ん中 (CH1 = 0 V、CH2 = 約 4.9 V)。
IN が H の間は Q1 が ON で D1 が点き、Q2 は OFF でドレインは R2・D2 を通って GND に引かれ 0 V になる。
IN が L の間は Q2 が ON になってドレインが 5 V 近くに上がり、D2 が点く。CH2 が CH1 と逆向きに動くのが、ハイサイドの論理の逆転だ。
ON のときの 4.9 V は、Q2 の ON 抵抗による降下を 0.1 V (目安。約 9 mA の電流に対する見積りで、実測ではない) としたもの。

## 見るべき値

表の値は計算値。VCC = 5 V、LED の V<sub>F</sub> ≈ 2.0 V とする。
V<sub>GS</sub> は、テスターの DC 電圧レンジの + 側の棒をゲート、− 側の棒をソースに当てて測る。
IN1・IN2 は、GPIO の代わりに線で 5 V か GND につないで試せる。AD3 の Wavegen で 100 Hz の方形波を入れたときの波形は図3。

| 測る所 (ローサイド) | 期待する値 | 分かること |
| --- | --- | --- |
| IN1 = L (0 V) のとき Q1 の状態 | OFF (Rpd1 でゲートが GND) | 消灯 |
| IN1 = H (5 V) のとき Q1 の状態 | ON | D1 に約 9.1 mA (= (5 − 2) / 330) 流れて点灯 |

| 測る所 (ハイサイド) | 期待する値 | 分かること |
| --- | --- | --- |
| IN2 = H (5 V) のとき Q2 の V<sub>GS</sub> | 0 V (Rpu2 でゲートが VCC) | OFF、消灯 |
| IN2 = L (0 V) のとき Q2 の V<sub>GS</sub> | −5 V | ON、D2 に約 9.1 mA 流れて点灯 (論理がローサイドと逆) |

## 出典

自作。
