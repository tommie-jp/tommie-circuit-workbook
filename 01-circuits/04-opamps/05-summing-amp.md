---
book: circuits
chapter: 4
id: 4-5
title: 加算 (ミキサー)
tier: 50
source: 自作
board: BB
---

# 4-5 加算 (ミキサー)

4-3 の反転増幅の入力抵抗を複数にすると、**それぞれの信号を足し合わせて反転する**
ミキサーになる。音声を混ぜるミキサーの基本形はこれ。OP アンプの基本形の
5 つ目。この題では 1 kHz と 3 kHz の正弦波を混ぜ、出力が 2 つの和を裏返した波になることを確かめる。

## 回路図

```circuit
title: 図1 加算アンプ
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground 2,3
  V1: sine 3,2 3,4 0.2
  G2: ground 3,4
  V2: sine 4,4 4,6 0.1
  G3: ground 4,6
  R1: resistor 3,2 6,2 10k
  R2: resistor 4,4 6,4 10k
  Rf: resistor 6,1 9,1 10k
  U1: opamp 8,3.21 +down
  G4: ground 7,4
  OUT: port 10,3.21
points:
  vp: 1,1
  vm: 1,5
  mid: 1,3
wires:
  - mid -- 2,3
  - 6,1 -- 6,2 -- 6,3 -- 6,4
  - 6,3 -| U1.-
  - 7,4 |- U1.+
  - 9,1 -- 9,3.21
  - U1.out -- 9,3.21 -- 10,3.21
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/05-summing-amp.svg)

- 左の VP・VN は OP アンプの ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1 と同じ)
- V1 (1 kHz、振幅 0.2 V) と V2 (3 kHz、振幅 0.1 V) が **同じ − 入力の 1 点 (仮想接地) に
  R1・R2 で合流**する。− 入力は仮想接地 (4-3 で見た) で 0 V に保たれるので、
  V1 と V2 は互いの信号を押し返し合わず、それぞれの電流が Rf で足し合わされる
- **R1 = R2 = Rf = 10 kΩ なので、Vout = −(V1 + V2)。** 抵抗を変えれば
  チャンネルごとに音量を変えられる (Rf/R1、Rf/R2 がそれぞれの利得)
- 非反転入力は GND 直結 (4-3 の反転増幅と同じ)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上のレールは +5V (赤) と GND (青)。下の青レールは −5V (V−)。下の赤レールは使わない
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies ±5V・W1・W2)
    pins: [V+, GND, V-, W1, W2]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [2+, 1+, 1-, 2-]
  U1: dip8 @ e10 LM358
  R1: resistor b4 b9 10k
  R2: resistor d6 d9 10k
  Rf: resistor g10 g11 10k
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t2 black
  - AD3.V- -- -b3 blue
  - AD3.W1 -- a4 yellow
  - AD3.W2 -- a6 green
  - SC.2+ -- c4 orange
  - SC.1+ -- j10 green
  - SC.1- -- i15 black
  - SC.2- -- j15 black
  - +t10 -- a10 red
  - e9 -- f9 orange
  - i9 -- i11 orange
  - j13 -- -b13 blue
  - h12 -- h15 black
  - f15 -- e15 black
  - a15 -- -t15 black
notes:
  - text below: 上の赤レール = +5V、上の青レール = GND、下の青レール = −5V (V−)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/05-summing-amp.svg)

- 図2 の AD3 は、Supplies (V+・V−) が図1 の VP・VN、W1 が V1、W2 が V2 に当たる。
  電源のレールの分け方は 4-1 と同じ (下の青レールは −5V で、GND ではない)
- **R1 (W1 から、上ブロック 4→9 列) と R2 (W2 から、6→9 列) が 9 列の 1 点で合流**し、
  溝をまたぐ線と `i9--i11` で IN− (PIN 2、11 列) へ入る。
  Rf (11→10 列) が出力 (PIN 1、10 列) へ帰還する
- IN+ (PIN 3、12 列) は `h12--h15`、溝をまたぐ線、`a15--(-t15)` の 3 本の黒い線で GND に直結
- Scope はブレッドボードの下に別の箱 (AD3 Scope) で描いた。2+ (橙) は V1 を受ける 4 列 (`c4`)、1+ (緑) は出力の 10 列 (`j10`) に挿し、
  1− と 2− (黒) は GND につながる 15 列 (`i15`・`j15`) へ挿す

## 計器の設定

オシロには AD3 の Scope を使う。1 kHz と 3 kHz の波の形を見る題で、10 MHz よりずっと低いから。
W1 は 1 kHz・振幅 0.2 V、W2 は 3 kHz・振幅 0.1 V (どちらもオフセット 0 V)。同時に出す 2 つの波は、AD3 の Wavegen の同期で位相がそろう。
Scope は CH1 を出力 (10 列)、CH2 を V1 (4 列) にして、トリガは CH2 の立ち上がり 0 V にする。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Sine、1 kHz、振幅 0.2 V、オフセット 0 V |
| Wavegen W2 | Sine、3 kHz、振幅 0.1 V、オフセット 0 V、位相 0° |
| Scope CH1 (出力、10 列) | DC、100 mV/div |
| Scope CH2 (V1、4 列) | DC、100 mV/div |
| Time | 200 µs/div (1 kHz が 2 周期) |
| Trigger | CH2、立ち上がり、0 V |

```scope
title: 図3 出力 (CH1) は V1 (CH2) と V2 の和を裏返した波
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: = -(0.2V * sin(2 * pi * 1kHz * t) + 0.1V * sin(2 * pi * 3kHz * t)), range: 100mV/div}
ch2: {wave: sine 1kHz 0.2V, range: 100mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/05-summing-amp.svg)

図3 の CH1 は 1 kHz の周期でくり返す波で、CH2 (V1) が上がるとき下がる。2 つの正弦波の和は、
山の高さが 0.215 V (計算値) で、0.2 + 0.1 = 0.3 V にはならない。1 kHz と 3 kHz の山が同時には重ならないため。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方) | LM358 |
| R1, R2 | 抵抗 (入力) | 10 kΩ |
| Rf | 抵抗 (帰還) | 10 kΩ |
| — | 信号源 | 1 kHz 0.2V (出力 1)、3 kHz 0.1V (出力 2) |
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |
| — | 計器 | AD3 の W1・W2 (信号源)・Scope 1+/2+ (出力と V1) |

## 見るべき値

発振器は AD3 の W1 (1 kHz・振幅 0.2 V) と W2 (3 kHz・振幅 0.1 V)。オシロの CH1 を
出力 (10 列) に当て (図3)、片方ずつ止めたときと両方入れたときの波を比べる。表の値は計算値。Vout = −(Rf/R1 × V1 + Rf/R2 × V2)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| V1 だけ入れたときの出力振幅 | 0.2 V (反転) | −10k/10k × 0.2V |
| V2 だけ入れたときの出力振幅 | 0.1 V (反転) | −10k/10k × 0.1V |
| 両方入れたときの出力のピーク | 0.3 V 以下 (2 つの位相の関係で変わる)。図3 の位相では約 0.215 V (計算値) | 2 つの正弦波の和。3 kHz は 1 kHz のちょうど 3 倍なので、オシロでは 1 kHz の周期でくり返す波に見える |
| 出力波形の周波数成分 (スペクトラムで見る場合) | 1 kHz と 3 kHz の 2 本 | 混ざっても周波数は保たれる (入力を足すと出力も足し算になる、線形回路の性質) |

R1・R2 を別の値にすると「CH1 を大きく、CH2 を小さく」のようなミキサーの
音量バランスが作れる (利得はそれぞれ Rf/R1、Rf/R2 で独立に決まる)。

## 出典

自作。
