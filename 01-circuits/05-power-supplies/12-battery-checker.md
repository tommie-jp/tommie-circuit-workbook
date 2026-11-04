---
book: circuits
chapter: 5
id: 5-12
title: 電池残量チェッカー
tier: 200
source: 自作
---

# 5-12 電池残量チェッカー

単 3 のアルカリ乾電池 1 本の電圧を、LED 3 個の点き方で読む。新しい電池は 1.5〜1.6 V、使い切りに近づくと 1.2 V、1.0 V と下がっていく。
その電圧を **1.4 V・1.2 V・1.0 V の 3 つのしきい値と比べ**、超えた数だけ LED を点ける (棒グラフ)。

| 電池の電圧 | 緑 (1.4 V) | 黄 (1.2 V) | 赤 (1.0 V) | 読み |
| --- | --- | --- | --- | --- |
| 1.4 V より上 | 点く | 点く | 点く | まだ十分 |
| 1.2〜1.4 V | 消える | 点く | 点く | 半分ほど |
| 1.0〜1.2 V | 消える | 消える | 点く | そろそろ替える |
| 1.0 V より下 | 消える | 消える | 消える | 使い切り |

比べるのは 4-4 で使った比較器 (オペアンプの + と − の大小で出力が振り切れる) で、ここでは 4 回路入りの LM324 の 3 回路を使う。
しきい値は 5 V を 4 本の抵抗で分けて作る。この題ではまず Analog Discovery 3 (AD3) の Wavegen の W1 を電池の代わりにし、
0.9〜1.6 V をゆっくり上下させて、LED が順に点いて消えることを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 電池残量チェッカー (LM324 の 3 回路で 1.4・1.2・1.0 V と比べる)
parts:
  VCC: vcc 4,1 5V
  RA: resistor 4,1 4,2.85 36k
  RB: resistor 4,2.85 4,6.85 2k
  RC: resistor 4,6.85 4,10.85 2k
  RD: resistor 4,10.85 4,14 10k
  G1: ground 4,14
  U1A: opamp 10,3.2 +down LM324
  U1B: opamp 10,7.2 +down LM324
  U1C: opamp 10,11.2 +down LM324
  R1: resistor 12,3.2 14,3.2 330
  D1: led 14,3.2 14,5 green
  R2: resistor 12,7.2 14,7.2 330
  D2: led 14,7.2 14,9 yellow
  R3: resistor 12,11.2 14,11.2 330
  D3: led 14,11.2 14,13 red
  G3: ground 14,5
  G4: ground 14,9
  G5: ground 14,13
  W1: triangle 7,12.4 7,14 l=$\mathrm{W1}$
  G2: ground 7,14
  M1: voltmeter 9,12.4 9,14 l=$\mathrm{CH1}$
  G6: ground 9,14
wires:
  - 4,2.85 -| U1A.-
  - 4,6.85 -| U1B.-
  - 4,10.85 -| U1C.-
  - 7,3.55 -| U1A.+
  - 7,7.55 -| U1B.+
  - 7,11.55 -| U1C.+
  - 7,3.55 -- 7,7.55 -- 7,11.55 -- 7,12.4
  - 7,12.4 -- 9,12.4
  - U1A.out -- 12,3.2
  - U1B.out -- 12,7.2
  - U1C.out -- 12,11.2
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/12-battery-checker.svg)

- 分圧 (RA 36 kΩ (オーム)・RB 2 kΩ・RC 2 kΩ・RD 10 kΩ、合計 50 kΩ) に 5 V を掛けると 0.1 mA が流れ、RD の上が 1.0 V、RC の上が 1.2 V、RB の上が 1.4 V になる。
  4 本とも E24 の値で、計算どおりの 1.0・1.2・1.4 V がちょうど出る
- U1A・U1B・U1C は LM324 の 1・2・3 番の回路。+ に電池の電圧 (W1)、− にしきい値を入れる。電池の電圧がしきい値より高いと出力が High
  (約 3.5 V。LM324 は 5 V の電源で出力が約 1.5 V 低い所までしか上がらない) になり、330 Ω を通して LED に約 4.5 mA が流れる
- LM324 の電源 (4 番が +5 V、11 番が GND) と使わない 4 番目の回路は図に描いていない (実体配線図にはある)
- しきい値の精度は 5 V の精度で決まる。5 V が 5 % ずれるとしきい値も 5 % (1.4 V なら 70 mV) ずれる。AD3 の Supplies なら十分に安定している
- CH1 は電池 (W1) の電圧

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (W1 が電池の代わり)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies・W1・CH1)
    pins: [V+, GND, 1-, W1, 1+]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery 3 (CH2)
    pins: [2-, 2+]
  U1: dip14 @ e14 LM324
  RA: resistor b1 b5 36k
  RB: resistor c5 c9 2k
  RC: resistor d9 d13 2k
  RD: resistor a13 -t13 10k
  R1: resistor i14 i10 330
  D1: led j10(A) j6(K) green
  R2: resistor j20 j24 330
  D2: led h24(A) h27(K) yellow
  R3: resistor b20 b24 330
  D3: led c24(A) c27(K) red
wires:
  - AD.V+ -- +t3 red
  - AD.GND -- -t4 black
  - +t1 -- a1 red
  - e5 -- f5 orange
  - g5 -- g15 orange
  - e9 -- f9 blue
  - h9 -- h19 blue
  - c13 -- c19 white
  - AD.W1 -- b18 yellow
  - a18 -- a22 yellow
  - e22 -- f22 yellow
  - g22 -- g18 yellow
  - i18 -- i16 yellow
  - j17 -- +b17 red
  - a17 -- -t17 black
  - b16 -- -t16 black
  - d14 -- d15 green
  - i6 -- -b6 black
  - j27 -- -b27 black
  - a27 -- -t27 black
  - +t29 -- +b29 red
  - -t30 -- -b30 black
  - AD.1+ -- d22 yellow
  - AD.1- -- -t8 black
  - AD1.2+ -- j14 green
  - AD1.2- -- -b11 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/12-battery-checker.svg)

- LM324 (DIP-14) は切り欠きを左にして 14〜20 列に挿す。下の f 行が 1〜7 番、上の e 行が 14〜8 番 (右から左)
- 分圧は上のブロックの左。+5 V の 1 列から RA (`b1`–`b5`)・RB (`c5`–`c9`)・RC (`d9`–`d13`) とつなぎ、RD (`a13`) を青いレールへ。
  5 列 (1.4 V) は橙の線で 1IN− (15 列の下)、9 列 (1.2 V) は青の線で 2IN− (19 列の下)、13 列 (1.0 V) は白の線で 3IN− (19 列の上) へ
- W1 (黄) は 3IN+ (18 列の上) に入れ、黄の線で 22 列を回って 2IN+ (18 列の下)・1IN+ (16 列の下) へ配る。黄の線はどれも電池の電圧
- 出力は 1OUT (14 列の下) → R1 → 緑 (D1)、2OUT (20 列の下) → R2 → 黄 (D2)、3OUT (20 列の上) → R3 → 赤 (D3)。LED のカソードは青いレールへ
- VCC+ (17 列の下) は下の赤いレール、VCC− (17 列の上) は上の青いレールへ。上下のレールは 29・30 列でつなぐ
- 使わない 4 番目の回路は、4IN+ (16 列の上) を GND へ、4IN− と 4OUT (15・14 列の上) を短い緑の線でつなぐ (フォロアにして出力を 0 V に止める)
- CH1 (1+) は 22 列 (電池の電圧)、CH2 (2+) は 1OUT (14 列の下)。2− と 1− は GND

ブレッドボードを流れる電流は LED 3 個と LM324 で 15 mA ほどで、ブレッドボードの範囲 (1 穴 200 mA) に収まる。

## 計器の設定

計器は AD3 の Supplies・Wavegen・Scope。Supplies の V+ を 5 V にする。Wavegen の W1 を三角波・0.1 Hz・振幅 0.35 V (0.7 Vpp)・オフセット 1.25 V にすると、
10 秒かけて 0.9 V と 1.6 V の間を往復する。Scope は CH1 (W1) を 200 mV/div、CH2 (緑の出力) を 1 V/div、時間軸 1 s/div、
トリガは CH1 の立ち上がり 1.25 V。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 W1 (CH1) が 1.4 V を超える間だけ、緑の LED の出力 (CH2) が High
time: 1s/div
trigger: ch1 rising 1.25V at -5div
ch1: {wave: triangle 0.1Hz 0.7Vpp offset 1.25V, range: 200mV/div, position: -6div}
ch2: {wave: "= 3.5V * step(ch1 - 1.4V)", range: 1V/div, position: -4div}
cursors: [1.07s, 3.93s]
measure: [vmax, vmin]
notes:
  - text 2.5s 1.6V: 1.6 V
  - text ch1 7.5s 0.9V: 0.9 V
  - text ch2 2.5s 3.5V: 緑が点く (1.4 V より上)
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/scope/12-battery-checker.svg)

図3 は理想 (計算) の画面。CH1 が 1.4 V を上へ超える X1 (1.07 s) で CH2 が High (約 3.5 V) になり、1.4 V を下へ割る X2 (3.93 s) で 0 V に戻る。
同じ往復の間に、黄は 1.2 V を割る 5.36 s で、赤は 1.0 V を割る 6.79 s で消え、赤は 1.0 V を超え直す 8.22 s でまた点く。
CH2 を U1B・U1C の出力 (20 列の下・上) に付け替えると、それぞれの時刻で切り替わるのが見える。

しきい値のすぐ近くでは、W1 のわずかな雑音で LED がちらつくことがある。比較器にヒステリシス (しきい値の幅) が無いからで、
4-8 (シュミットトリガ) のように正帰還を足すと止まる。電池の電圧はゆっくりしか動かないので、この題ではそのままにする。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 4 回路のオペアンプ (DIP-14) | LM324 (比較器として使う。入力は 0 V まで扱える) |
| RA | 抵抗 (1/4 W) | 36 kΩ |
| RB, RC | 抵抗 (1/4 W) | 2 kΩ |
| RD | 抵抗 (1/4 W) | 10 kΩ |
| R1, R2, R3 | 抵抗 (1/4 W) | 330 Ω (LED の電流 約 4.5 mA) |
| D1, D2, D3 | LED (5 mm) | 緑・黄・赤 |
| — | 電源 | AD3 の Supplies の V+ (5 V) |
| — | 計器 | AD3 の Wavegen (W1 = 電池の代わり) と Scope (CH1 = 電池、CH2 = 緑の出力) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| RB・RC・RD の上 (テスターで) | 1.40 V・1.20 V・1.00 V | 分圧でしきい値ができている |
| 緑が点く・消える W1 の電圧 (図3 の X1・X2) | 1.40 V | + が − を超えると出力が High |
| 黄・赤が消える W1 の電圧 | 1.20 V・1.00 V | 3 つのしきい値で棒グラフになる |
| 点いた LED の電流 | 約 4.5 mA ((3.5 V − 2.0 V) ÷ 330 Ω) | LM324 の High は電源より約 1.5 V 低い |
| CH2 の High | 約 3.5 V | 同上 (目安。負荷と個体で ±0.2 V ほど動く) |

**本物の電池を測るとき**は W1 を外し、電池の + を 22 列、− を青いレールにつなぎ、電池と並列に 33 Ω を挿して約 45 mA の負荷を掛けてから読む
(33 Ω の損失は 1.6 V で 78 mW、1/4 W の半分以下)。電池は負荷を掛けないと、使い古しでも 1.4 V 前後を示すことがある。
内部の抵抗が増えていて、電流を取ると電圧が下がるからだ。33 Ω は電池を減らすので、読むときだけ挿す。ユニバーサル基板に組んで残すなら 12-7 で扱う。

## LTspice での確かめ

`sim/12-battery-checker.cir` で図1 を W1 の三角波 (図3 と同じ時刻) で 10 秒動かした。LM324 は 04-opamps の題と同じ汎用のオペアンプの模型
(仮定: GBW 1 MHz、出力 High は電源 − 1.5 V)、LED は他の題と同じ仮定の模型。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| しきい値 (RB・RC・RD の上) | 1.40・1.20・1.00 V | 1.400・1.200・1.000 V | 合う |
| 分圧の電流 | 0.1 mA | 0.100 mA | 合う |
| 緑が点く・消える時刻 | 1.07 s・3.93 s | 1.073 s・3.930 s (W1 は 1.400 V) | 合う |
| 黄が消える・赤が消える・赤が点く時刻 | 5.36 s・6.79 s・8.22 s | 5.359 s・6.787 s・8.216 s | 合う |
| 出力の High | 約 3.5 V | 3.50 V (模型の決め) | 模型の仮定どおり |
| LED の電流 (緑・赤) | 約 4.5 mA | 4.41 mA・4.64 mA | 合う |

出力の High の 3.5 V は模型に入れた仮定なので、LTspice は確かめていない。実物で CH2 を読んで比べる。

## 出典

自作。

参考: [LM324 のデータシート (TI)](https://www.ti.com/lit/ds/symlink/lm324.pdf)、[コンパレータ (Wikipedia)](https://ja.wikipedia.org/wiki/コンパレータ)、[アルカリマンガン乾電池 (Wikipedia)](https://ja.wikipedia.org/wiki/アルカリマンガン乾電池)
