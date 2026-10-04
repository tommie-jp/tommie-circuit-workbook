---
book: circuits
chapter: 4
id: 4-9
title: 微分器
tier: 100
source: 自作
---

# 4-9 微分器

4-6 の積分器は入力抵抗と帰還コンデンサだったが、**入力側にコンデンサ、
帰還に抵抗**を置くと逆の働きをする微分器になる。入力の時間変化 (傾き) に比例した電圧が
出てくる。三角波を入れると、傾きが一定な区間ごとに電圧が
切り替わる**方形波**が出るのが分かりやすい。この題ではそれをオシロで確かめる。

## 回路図

```circuit
title: 図1 微分器
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground c2
  V1: triangle b3 d3 1
  G2: ground d3
  Rs: resistor b3 b5 1k
  Cin: capacitor b5 b7 100n
  Rf: resistor a7 a10 7.5k
  U1: opamp c9 +down
  G3: ground d8
  OUT: port c11
points:
  vp: a1
  vm: e1
  mid: c1
wires:
  - mid -- c2
  - b7 |- U1.-
  - d8 |- U1.+
  - b7 -- a7
  - a10 -- c10
  - U1.out -- c10 -- c11
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/09-differentiator.svg)

- 左の VP・VN は OP アンプの ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1 と同じ)
- V1 は 1 kHz・振幅 ±1 V の**三角波**。Cin (100 nF) が − 入力へ交流電流を送り、
  Rf (7.5 kΩ) の帰還で電圧に変える ── Vout = −Rf×Cin×(dVin/dt)。
  三角波は傾きが一定なので、微分すると**方形波**になる
- **Rs (1 kΩ、Cin の前に直列)** が理想の微分器との違い。理想の微分器は
  周波数が上がるほど利得が増え続けて高域のノイズまで拾ってしまう
  (積分器と逆の弱点)。Rs を入れると、高い周波数では利得が Rf/Rs
  (=7.5 倍) で頭打ちになり、ノイズに強くなる
- Rs と Cin で決まる折れ点周波数 (利得が頭打ちに変わる周波数) は 1/(2πRsCin) ≈ 1.6 kHz。
  信号の 1 kHz はそれより低いので微分器として働く。時間で見ると、Rs・Cin の時定数は
  1kΩ × 100nF = 0.1 ms で、傾きが一定の区間 (半周期 0.5 ms) の 5 分の 1。出力は傾きが折り返った後
  0.1 ms ほどで丸く切り替わり、区間の後半は理想どおりの一定の電圧になる。**Rf は
  7.5 kΩ にしてある。** 10 kΩ にすると出力が ∓4 V まで振れ、±5 V 電源の
  LM358 の出力上限 (Vcc−1.5V ≈ +3.5 V) を超えてしまうため

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上のレールは +5V (赤) と GND (青)。下の青レールは −5V (V−)。下の赤レールは使わない
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies ±5V・W1)
    pins: [V+, GND, V-, W1]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 2+, 1-, 2-]
  U1: dip8 @ e10 LM358
  Rs: resistor i4 i7 1k
  Cin: capacitor j7 j11 100n
  Rf: resistor j15 j18 7.5k
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t2 black
  - AD3.V- -- -b3 blue
  - AD3.W1 -- g4 yellow
  - SC.1+ -- h4 orange
  - SC.2+ -- i10 green
  - SC.1- -- -t20 black
  - SC.2- -- -t21 black
  - h11 -- h15 orange
  - g10 -- g18 green
  - i12 -- -t13 black
  - +t10 -- a10 red
  - j13 -- -b13 blue
notes:
  - text below: 上の赤レール = +5V、上の青レール = GND、下の青レール = −5V (V−)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/09-differentiator.svg)

- 図2 の AD3 は、Supplies (V+・V−) が図1 の VP・VN、W1 が V1 (三角波) に当たる。電源のレールの分け方は 4-2 と同じ
  (下の青レールは −5V で、GND ではない)。電流は数 mA で、各レール約 50 mA の範囲に収まる
- W1 (黄) は 4 列へ。Rs (1 kΩ、4 列〜7 列) の先に Cin (100 nF、7 列〜IN− の 11 列) を直列に挿す
- 帰還の Rf (7.5 kΩ) は IC の足の隣に挿せないので、線で右へ広げる。IN− (PIN 2、11 列) は `h11 → h15`、
  出力 (PIN 1、10 列) は `g10 → g18`。Rf は 15 列と 18 列の間に挿す
- IN+ (PIN 3、12 列) は黒の線 `i12 → -t13` で GND (上の青レール) へ。PIN 8 (10 列) は `+t10 → a10` で +5V へ、PIN 4 (13 列) は `j13 → -b13` で −5V へ
- Scope は板の下に別の箱で描いた。1+ (橙) は入力の 4 列 (`h4`)、2+ (緑) は出力の 10 列 (`i10`)。1− と 2− (黒) は上の青レール (GND) へ

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。1 kHz の三角波と方形波の形を見る題で、10 MHz よりずっと低いから。
W1 は 1 kHz・振幅 1 V の三角波 (オフセット 0 V)、Scope は CH1 を入力、CH2 を出力にして、トリガは CH1 の立ち上がり 0 V にする。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Triangle、1 kHz、振幅 1 V、オフセット 0 V、対称 50 % |
| Scope CH1 (入力、4 列) | DC、500 mV/div |
| Scope CH2 (出力、10 列) | DC、1 V/div |
| Time | 200 µs/div (1 kHz が 2 周期) |
| Trigger | CH1、立ち上がり、0 V |

```scope
title: 図3 入力の三角波 (CH1) と出力の方形波 (CH2)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: triangle 1kHz 1V, range: 500mV/div}
ch2: {wave: "ch1 | hp 100us | gain -7.5", range: 1V/div}
cursors: [200us, 700us]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/09-differentiator.svg)

図3 の CH2 は、Rs・Cin (時定数 0.1 ms) の遅れまで入れた想定図。CH1 は 2 Vpp (4 目盛) の三角波、CH2 は傾きの符号で ±3 V ほどの方形波に近い波形になる。
トリガは CH1 が 0 V を上る点 (t = 0) で、三角波は 250 µs で山、750 µs で谷になる。上りの区間 (X1、200 µs) で CH2 は約 −2.9 V、下りの区間 (X2、700 µs) で約 +2.9 V。理想の ∓3 V に届かないのは、切り替わりが時定数 0.1 ms で丸くなり、区間の途中でもまだ 3 V に落ち着ききらないから。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方) | LM358 |
| Rs | 抵抗 (高域制限、ノイズ対策) | 1 kΩ |
| Cin | セラミックコンデンサ (微分・入力) | 100 nF |
| Rf | 抵抗 (帰還) | 7.5 kΩ |
| — | 信号源 | 1 kHz、三角波、振幅 ±1 V |
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |
| — | 計器 | AD3 の W1 (信号源)・Scope 1+/2+ (入力と出力) |

## 見るべき値

発振器は AD3 の W1 (1 kHz・±1 V の三角波)。オシロの CH1 を入力 (4 列)、CH2 を出力 (10 列) に当て、
同じ時間軸で重ねる (図3)。表の値は計算値。三角波の傾き = 4×振幅/周期。RfCin = 7.5 kΩ × 100 nF = 0.75 ms。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 三角波の傾き (振幅 1V、周期 1ms) | 4000 V/s (4 V/ms) | 4 × 1V / 1ms |
| 出力電圧 (傾きが一定の区間) | 約 ∓3 V (三角波の上りで −3V、下りで +3V) | −Rf×Cin×傾き = −7.5kΩ×100nF×4000V/s |
| 出力波形 | 方形波に近い (三角波の傾きの符号で 2 値) | 切り替わりは Rs・Cin の時定数 (0.1 ms) で丸くなる。理想の微分器なら瞬時に切り替わる |
| Rs を外した場合 | 高域でノイズを拾いやすくなる | 折れ点が無くなり、利得が周波数に比例して増え続ける |

積分 (4-6) と微分 (4-9) は逆の働きだが、**どちらも実用回路では帰還素子と
並列・直列に保護素子を足す**という共通点がある。積分器は帰還コンデンサに
並列の漏れ抵抗、微分器は入力コンデンサに直列の制限抵抗。理想の式のままでは
実際の部品では暴走するか、ノイズを拾うことを覚えておく。

## 出典

自作。
