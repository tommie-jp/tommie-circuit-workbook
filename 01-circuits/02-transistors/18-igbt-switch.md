---
book: circuits
chapter: 2
id: 2-18
title: IGBT スイッチ
tier: 200
source: 自作
era: 今
---

# 2-18 IGBT スイッチ

**IGBT** (絶縁ゲートバイポーラトランジスタ) は、入口が MOSFET、出口がバイポーラトランジスタの素子。
ゲートは MOSFET と同じく電圧で動かし (電流はほとんど要らない)、主電流はバイポーラの PNP が流す。端子はゲート (G)・コレクタ (C)・エミッタ (E)。
インバータ (モータ・エアコン・電車・電気自動車)、IH 調理器、溶接機など、**数百 V・数十 A** を切り替える所の定番である。

MOSFET (2-5・2-17) と比べると、性格がはっきり違う。

- **オンの電圧**: MOSFET は R<sub>DS(on)</sub> × I で、電流が小さいほど 0 V に近づく。IGBT は PNP の pn 接合が 1 つ入るので、
  どんなに小さな電流でも約 0.7 V が残る。大電流では電圧が増えにくく、600 V 級では MOSFET より損失が小さい
- **ゲートの電圧**: しきい値が 4.0〜6.5 V (IRGB4062D) と高く、データシートの値は V<sub>GE</sub> = 15 V で決めてある。**5 V のロジックでは動かせない**
- **切るとき**: PNP の中に残った電荷が抜けるまで電流が尾を引く (テイル電流)。数十 kHz より速い切り替えは苦手

この題では、AD3 の Supplies の +5 V と −5 V の間 (10 V) で IGBT を使い、ゲートに 8.2 V を掛けて LED を点け、
C-E 間に約 0.7 V が残ることと、ゲートが 4 V ほどでは点かないことを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 IGBT スイッチ (エミッタは -5 V。W1 でゲートに 0 / 8 V)
parts:
  VCC: vcc 7,2 5V
  R1: resistor 7,2 7,4 820
  D1: led 7,4 7,5
  Q1: nigbt 7,7
  VEE: vee 7,10
  W1: square 1,7 1,10 l=$\mathrm{W1}$
  G1: ground 1,10
  RG: resistor 1,7 3,7 2.2k
  M1: voltmeter 3,7 3,10 l=$\mathrm{CH1}$
  G2: ground 3,10
  RGE: resistor 5,7 5,9 10k
  M2: voltmeter 10,5 10,9 l=$\mathrm{CH2}$
wires:
  - 3,7 -- 5,7
  - 5,7 -- Q1.G
  - 7,5 -- Q1.C
  - Q1.E -- 7,9
  - 7,9 -- 7,10
  - 5,9 -- 7,9
  - 7,5 -- 10,5
  - 7,9 -- 10,9
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/18-igbt-switch.svg)

図1 の電源は AD3 の Supplies の ±5 V。IGBT のエミッタを VEE (−5 V) に置き、負荷 (`R1` + 赤 LED) を +5 V からコレクタへつなぐ。
W1 は GND 基準で −5 V / +5 V の方形波 (1 kHz) で、ゲートから見ると 0 V / 10 V の振れになる。CH1 はゲート (GND 基準)、CH2 は C-E 間 (差動)。

- **ゲートの電圧**: `RG` (2.2 kΩ) と `RGE` (10 kΩ) の分圧で、V<sub>GE</sub> = 10 × 10 / 12.2 ≈ **8.2 V** (オン) と **0 V** (オフ)。
  `RGE` は 2-17 のプルダウンと同じ役目で、W1 を外したときにゲートをエミッタへ落とす
- **負荷の電流**: (10 V − LED 2.0 V − V<sub>CE</sub> 0.7 V) / 820 Ω ≈ **8.9 mA**。電源から取るのは V+ と V− がそれぞれ約 45 mW
- **オンの V<sub>CE</sub>**: 約 **0.7 V** (pn 接合 1 つ分。目安)。同じ 9 mA を 2N7000 (2-5) で切れば 0.03 V ほどで、小電流では IGBT のほうが 20 倍以上損をする。
  IRGB4062D の V<sub>CE(on)</sub> は 24 A で 1.60 V (代表)。電流が 2,700 倍になっても電圧は 2.3 倍にしかならない
- **5 V のロジックで動かすと**: W1 を −5 V / 0 V にすると V<sub>GE</sub> は 0 V / 4.1 V。しきい値の最小 4.0 V ぎりぎりで、多くの個体では LED は点かない
- **ゲートの電流**: IGBT の入力容量 C<sub>ies</sub> は 1490 pF (代表)。W1 が 10 V 跳ぶ瞬間の電流の山は 10 V / 2.2 kΩ ≈ 4.5 mA で、W1 の目安 (10 mA) に収まる。
  時定数は約 2.7 µs で、1 kHz では跳びと同じに見える

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 IGBT スイッチ (下の + レールが +5 V、下の − レールが −5 V)
# 下の + レール = +5 V (V+)、下の − レール = −5 V (V−、紫の線)、上の − レール = GND (黒の線)。上の + レールは使わない
board: half
parts:
  Q1: transistor/to220 f8(G) f9(C) f10(E) IRGB4062D cap=right
  RG: resistor g3 g8 2.2k
  RGE: resistor j7 -b7 10k
  D1: led g13(A) g9(K) red
  R1: resistor j13 +b13 820
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (GND・CH1−)
    pins: [GND, 1-]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery 3 (V+・V−・W1・CH1+・CH2)
    pins: [W1, 1+, 2+, 2-, V-, V+]
wires:
  - AD.GND -- -t2 black
  - AD.1- -- -t6 black
  - AD1.W1 -- j3 yellow
  - h8 -- h7 orange
  - AD1.1+ -- i8 blue
  - AD1.2+ -- i9 green
  - j10 -- -b10 purple
  - AD1.2- -- -b11 green
  - AD1.V- -- -b16 purple
  - AD1.V+ -- +b20 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/18-igbt-switch.svg)

図2 は部品を下のブロックに置き、**下の + レールを +5 V、下の − レールを −5 V** にした。上の − レールは GND (AD3 の GND と CH1 の 1−) だけに使う。

- **Q1 (IRGB4062D、TO-220)**: 印字面を手前に、左から G・C・E (列 8〜10、データシートの TO-220AB の並び)。放熱板は要らない (損失は 6 mW ほど)
- **ゲート (列 8)**: `RG` (`g3`–`g8`) が W1 (`j3`) から来る。橙の線 `h8`–`h7` で列 7 へ渡し、`RGE` を −5 V のレールへ。CH1 の 1+ (青) は `i8`
- **コレクタ (列 9)**: 赤 LED (カソードが列 9、アノードが列 13)、`R1` は列 13 から +5 V のレールへ。CH2 の 2+ (緑) は `i9`
- **エミッタ (列 10)**: 紫の線で −5 V のレールへ。CH2 の 2− (緑) も −5 V のレール (C-E 間を差動で測る)
- TO-220 のピンはブレッドボードの穴には太い。奥まで押し込まず、浅く挿して接触を確かめる

## 計器の設定

計器は AD3 のオシロ (オン・オフの電圧を波形で読むため)。Supplies で V+ を +5 V、V− を −5 V にする。W1 を Square、1 kHz、Amplitude 5 V、Offset 0 V (−5 V / +5 V)。
CH1 は 2 V/div、CH2 は 2 V/div・Offset −4 V、時間軸 200 µs/div、CH1 の立ち上がり 0 V でトリガ。Measure で CH2 の Minimum (オンの V<sub>CE</sub>) を出す。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 ゲート (CH1) が +3.2 V (G-E 間 8.2 V) でオン、C-E 間 (CH2) は 0.71 V まで下がる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: square 1kHz 4.1V offset -0.9V, range: 2V/div}
ch2: {wave: ch1 | invert | gain 0.9354 | offset 3.703V, range: 2V/div, position: -2div}
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/18-igbt-switch.svg)

図3 の CH1 は −5 V と +3.2 V (V<sub>GE</sub> 0 V と 8.2 V)。CH1 が上の間、CH2 (C-E 間) は 0.71 V まで下がり、LED が点く。
CH2 の上の 8.38 V は、オフの IGBT に LED を通して 10 V が掛かり、LED に µA しか流れないので 1.6 V ほど残った値 (CH2 の入力 1 MΩ を負荷にした計算値)。

**5 V では動かないことを確かめる**: W1 の Amplitude を 2.5 V、Offset を −2.5 V (−5 V / 0 V) にする。V<sub>GE</sub> は 4.1 V までしか上がらず、
CH2 は 8.4 V のままで LED は点かない (しきい値の低い個体ではわずかに光る)。Offset を少しずつ上げて、LED が点き始める W1 の電圧からしきい値を読む。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | IGBT (TO-220AB) | IRGB4062DPbF (600 V・24 A、V<sub>GE(th)</sub> 4.0〜6.5 V) |
| RG | 抵抗 (1/4 W) | 2.2 kΩ |
| RGE | 抵抗 (1/4 W) | 10 kΩ |
| R1 | 抵抗 (1/4 W) | 820 Ω (8.9 mA で 65 mW) |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | AD3 の V+ (+5 V) と V− (−5 V) — IGBT のゲートに 5 V より高い電圧を掛けるため、エミッタを −5 V に置く |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| オンのときの V<sub>GE</sub> | 約 8.2 V | `RG` と `RGE` の分圧 |
| オンのときの V<sub>CE</sub> (CH2 の Minimum) | 約 0.7 V | pn 接合が 1 つ残る (MOSFET の 2-5 は 0.03 V) |
| 負荷の電流 (`R1` の電圧 / 820 Ω) | 約 8.9 mA | LED が点く |
| オフのときの V<sub>CE</sub> (CH2) | 約 8.4 V | LED の µA の漏れで 1.6 V ほど残る |
| W1 を −5 V / 0 V にしたとき (V<sub>GE</sub> 4.1 V) | LED は点かない (V<sub>CE</sub> 約 8.4 V のまま) | 5 V のロジックでは足りない |

## LTspice での確かめ

`sim/18-igbt-switch.cir` で V<sub>GE</sub> を 0・4.1・5・5.5・6・8.2 V に振り、C-E 間の電圧と負荷の電流を読んだ。
LTspice には IGBT の部品が無いので、MOSFET が PNP のベース電流を流す等価回路で置いた (しきい値 5.2 V の仮定。IRGB4062D の資料の 4.0〜6.5 V の中ほど)。
LED は 2-5 と同じ仮定、CH2 は 1 MΩ の負荷とした。どれも実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| オンの V<sub>CE</sub> (V<sub>GE</sub> 8.2 V) | 約 0.7 V | 0.708 V | 合う (模型の PNP の V<sub>BE</sub> で決まる) |
| 負荷の電流 | 約 8.9 mA | 8.89 mA | 合う |
| オフの V<sub>CE</sub> (CH2 の 1 MΩ を負荷に) | 約 8.4 V | 8.38 V | 合う |
| V<sub>GE</sub> 4.1 V / 5 V | 点かない | どちらも 0.01 mA、V<sub>CE</sub> 8.38 V | 合う (しきい値 5.2 V の模型で) |
| V<sub>GE</sub> 5.5 V / 6 V | — | 8.89 mA、V<sub>CE</sub> 0.71 V | 9 mA ではしきい値を越えればすぐ飽和する |

オンの V<sub>CE</sub> の 0.7 V は等価回路の作りから出た値で、実物の小電流の V<sub>CE(on)</sub> はデータシートの図 (数 A から上) に無い。
実物で測って書き直す値である。テイル電流は 9 mA では小さく、AD3 では見えないので、ここでは回していない (対象外)。

## 出典

自作。IGBT の値とピンの並びは [Infineon IRGB4062DPbF のデータシート](https://www.infineon.com/dgdl/irgb4062dpbf.pdf) (V<sub>GE(th)</sub>・V<sub>CE(on)</sub>・C<sub>ies</sub>・TO-220AB の G C E)。

参考: [絶縁ゲートバイポーラトランジスタ (Wikipedia)](https://ja.wikipedia.org/wiki/絶縁ゲートバイポーラトランジスタ)
