---
book: circuits
chapter: 4
id: 4-11
title: 単電源での使い方 — 仮想 GND、レール to レール
tier: 100
board: BB
source: 自作
era: 今
---

# 4-11 単電源での使い方 — 仮想 GND、レール to レール

4-1〜4-10 はどれも AD3 の Supplies (V+・V−) で ±5 V の**両電源**を作っていた。実際の工作では
USB の 5 V や電池 1 本など**単電源**しか無いことが多い。交流信号は 0 V を
またいで振れるので、単電源のままだと負の半分が切り捨てられる。
**仮想 GND** (電源電圧の半分を新しい基準点にする) を作れば、
両電源用の回路をほぼそのまま使える。この題では 5 V の単電源で 4-2 の非反転増幅を組み直し、
出力が 2.5 V を中心に振れることを確かめる。題名の「レール to レール」は、出力 (と入力) が
電源の端 (レール。0 V と 5 V) から端まで振れる OP アンプのことで、後半で扱う。

## 回路図

```circuit
title: 図1 単電源 + 仮想GND (LM358 の片方を仮想GND、もう片方を増幅に使う)
parts:
  V1: vsource vcc gnd 5
  G1: ground gnd
  R1: resistor f4 h4 10k
  R2: resistor h4 j4 10k
  GR2: ground j4
  Cbyp: ecap h6 j6 10u
  GCbyp: ground j6
  U1: opamp h9c0b0 +up
  V2: sine b2 d2 0.3
  G2: ground d2
  Cin: capacitor b2 b4 1u
  Rbias: resistor b5 d5 100k
  U2: opamp b9c0b0 +up
  Rg: resistor e8 d8 10k
  Rf: resistor d8 d11 10k
  OUT: port b12c0b0
points:
  vcc: f2
  gnd: h2
wires:
  - vcc -- f4
  - h4 -- h6 -| U1.+
  - i8 |- U1.-
  - i8 -- i10 -- h10c0b0
  - U1.out -- h10c0b0 -- e10
  - d5 -- e5 -- e8 -- e10
  - b4 -- b5 -| U2.+
  - d8 |- U2.-
  - d11 -- b11c0b0
  - U2.out -- b11c0b0 -- b12c0b0
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/11-single-supply.svg)

- 図1 の下半分が仮想 GND を作る部分、上半分が増幅する部分。
  **R1・R2 (各 10 kΩ) が Vcc/2 = 2.5 V を作る分圧、U1 はそれをバッファする
  ボルテージフォロア。** Cbyp (10 µF) は分圧点のノイズを抑える。
  これが**仮想 GND** で、以後この 2.5 V を「0 V」のつもりで信号を扱う
- V2 (0.3 V、AC) は本物の GND を基準にした信号源 (マイクや発振器の出力を想定)。
  **Cin (1 µF) で直流を切ってから Rbias (100 kΩ) で仮想 GND に持ち上げる**。
  これで信号は 2.5 V を中心に ±0.3 V 振れるようになり、単電源の中に収まる
- U2 は非反転増幅 (利得 = 1 + Rf/Rg = 2)。**Rg は GND ではなく仮想GND へ**
  つなぐのが両電源版 (4-2) との違い。出力は 2.5 V ± 0.6 V (1.9〜3.1 V) の範囲で
  振れ、Vcc (5V) にも GND (0V) にも到達しない
- **LM358 はレール to レールではない。** 出力は GND 近くまでは下がるが、
  +側は Vcc から 1.5 V ほど残ったところ (今回なら 3.5 V 程度) で頭打ちになる。
  単電源 5 V では頭上の余裕が少ないので、信号源の振幅を 0.5 V ではなく
  0.3 V に控えて出力 (最大 3.1 V) を 3.5 V の手前に収めた。それでも上側の
  余裕は 0.4 V しかなく、振幅を欲張るとすぐにクリップする。ぎりぎりまで
  振りたいなら **MCP6002 のようなレール to レール入出力の CMOS OP アンプ**に
  替える (今どきの低電圧回路の定番)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上のレールは +5V (赤) と GND (青)。下のレールも赤 +5V・青 GND (左の 1 列と 4 列の線で渡す)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies 5V・W1)
    pins: [V+, GND, W1]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 2+, 1-, 2-]
  U1: dip8 @ e10 LM358
  R1: resistor j12 +b12 10k
  R2: resistor j14 -b14 10k
  Cbyp: capacitor/electrolytic h14(+) h17(-) 10u
  Rbias: resistor b13 b8 100k
  Rg: resistor d12 d8 10k
  Cin: capacitor d13 d16 1u
  Rf: resistor b17 b20 10k
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t3 black
  - +t1 -- +b1 red
  - -t4 -- -b4 black
  - AD3.W1 -- b16 yellow
  - SC.1+ -- e16 orange
  - SC.2+ -- e20 green
  - SC.1- -- -t26 black
  - SC.2- -- -t27 black
  - g10 -- g11 green
  - h10 -- c8 green
  - g12 -- g14 orange
  - a11 -- a20 green
  - c12 -- c17 orange
  - +t10 -- a10 red
  - j13 -- -b13 black
  - j17 -- -b17 black
notes:
  - text below: 上下とも 赤レール = +5V、青レール = GND (単電源なので −5V は無い)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/11-single-supply.svg)

- 図2 の AD3 は、Supplies の V+ (+5 V) が図1 の V1 (単電源)、W1 が V2 (信号源) に当たる。V− は使わない。
  V+ は上の赤レール、GND は上の青レールへ入れ、下のレールには 1 列の赤い線と 4 列の黒い線で渡す。電流は LED なしで 5 mA 前後、AD3 の 5 V の約 50 mA の範囲に収まる
- 1 個の LM358 の 2 回路を両方使う。**下ブロック側の回路 (PIN 1〜3) が U1 (仮想 GND)、上ブロック側 (PIN 5〜7) が U2 (増幅)。** 図1 の U1・U2 はブレッドボードでは 1 つの IC
- **仮想 GND**: R1 (10 kΩ、12 列から下の赤レール +5V) と R2 (10 kΩ、14 列から下の青レール GND) の中点を `g12 → g14` でつなぎ、
  U1 の + 入力 (PIN 3、12 列) へ。Cbyp (10 µF) は 14 列 (+) と 17 列 (−、`j17 → -b17` で GND) の間。出力 (PIN 1、10 列) は `g10 → g11` で − 入力に戻す (フォロア)。
  PIN 4 (13 列) は `j13 → -b13` で GND、PIN 8 (10 列) は `+t10 → a10` で +5V
- 仮想 GND の出力 (10 列) は緑の線 `h10 → c8` で上ブロックの 8 列へ上げる。Rbias (100 kΩ、b 段) は 8 列と U2 の + 入力 (PIN 5、13 列)、Rg (10 kΩ、d 段) は 8 列と U2 の − 入力 (PIN 6、12 列) の間
- Cin (1 µF) は + 入力の 13 列から 16 列へ。W1 (黄) は 16 列 (`b16`) へ入れる。Rf (10 kΩ) は − 入力 (橙の線 `c12 → c17` で 17 列へ) と出力 (緑の線 `a11 → a20` で 20 列へ) の間
- Scope の 1+ (橙) は入力の 16 列 (`e16`)、2+ (緑) は出力の 20 列 (`e20`)。1− と 2− (黒) は上の青レール (GND) へ

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。1 kHz の正弦波の振幅と中心の電圧を見る題で、10 MHz よりずっと低いから。
W1 は 1 kHz・振幅 0.3 V の正弦波 (オフセット 0 V。GND 基準)、Scope は CH1 を入力 (Cin の入力側)、CH2 を出力にして、**どちらも DC 結合**にする。
トリガは CH2 の立ち上がり 2.5 V にする。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Sine、1 kHz、振幅 0.3 V、オフセット 0 V |
| Scope CH1 (入力、16 列) | DC、100 mV/div。0 V を中心の線に置く |
| Scope CH2 (出力、20 列) | DC、500 mV/div。オフセットを −2.5 V にして 2.5 V を中心の線に置く |
| Time | 200 µs/div (1 kHz が 2 周期) |
| Trigger | CH2、立ち上がり、2.5 V |

```scope
title: 図3 入力 (CH1) は 0 V が中心、出力 (CH2) は 2.5 V が中心で ±0.6 V
time: 200us/div
trigger: ch2 rising 2.5V
ch1: {wave: sine 1kHz 0.3V, range: 100mV/div}
ch2: {wave: sine 1kHz 0.6V offset 2.5V, range: 500mV/div, position: -5div}
cursors: [250us, 750us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/11-single-supply.svg)

図3 は CH1 が 100 mV/div で 0.6 Vpp (6 目盛、入力、0 V 中心)、CH2 が 500 mV/div で 1.2 Vpp (約 2.4 目盛、出力、2.5 V 中心)。CH2 は Scope のオフセットを −2.5 V にして、2.5 V の線を画面の中心に置く。
カーソルを山 (X1、250 µs) と谷 (X2、750 µs) に置くと、CH2 の読みが 3.1 V と 1.9 V (表の「1.9〜3.1 V」) になる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1, U2 | オペアンプ (1 個の LM358 の 2 回路を両方使う) | LM358 |
| R1, R2 | 抵抗 (仮想 GND の分圧) | 各 10 kΩ |
| Cbyp | 電解コンデンサ (仮想 GND のノイズ対策) | 10 µF |
| Cin | セラミックコンデンサ (信号の直流カット) | 1 µF |
| Rbias | 抵抗 (信号を仮想 GND へ持ち上げる) | 100 kΩ |
| Rg | 抵抗 (利得設定、仮想GND側) | 10 kΩ |
| Rf | 抵抗 (帰還) | 10 kΩ |
| — | 信号源 | 0.3 V、交流 (GND 基準) |
| — | 電源 | 単電源 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の W1 (信号源)・Scope 1+/2+ (入力と出力) |

## 見るべき値

電源は Analog Discovery の V+ (5 V) でよい。直流はテスターで GND を基準に測り、出力の振幅は
W1 (1 kHz・振幅 0.3 V の正弦波) を入れてオシロで見る。オシロは DC 結合にして、2.5 V を中心に振れるのを確かめる。
表の値は計算値。仮想 GND = Vcc/2 = 2.5 V。利得 = 1 + Rf/Rg = 2。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 仮想 GND (U1 の出力) | 2.5 V | Vcc/2、R1=R2 の分圧をバッファした値 |
| U2 の + 入力の直流電圧 | 2.5 V | Cin・Rbias で仮想 GND に持ち上げられている |
| 出力の直流電圧 (信号 0 のとき) | 2.5 V | 仮想 GND がそのまま基準点になる |
| 出力の振幅 | ±0.6 V (1.9〜3.1 V の範囲) | 0.3 V × 利得 2、仮想 GND を中心に振れる |
| Vcc・GND への余裕 | 上に 0.4 V、下に 1.9 V | 上は LM358 の出力制限 (Vcc−1.5V ≈ 3.5 V) までの余裕。単電源 5 V では上側がぎりぎりで、振幅をこれ以上大きくできない |

4-2 の回路の電源を単電源 5 V に替えただけだと、+ 入力は Rb で GND (0 V、単電源の下の端) に
引かれたままなので、信号の負の半分が切れて波形が潰れる。**単電源化は電源だけでなく、GND の取り方も一緒に直す必要がある**
というのがこの題の要点。

## 出典

自作。
