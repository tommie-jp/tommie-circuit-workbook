---
book: circuits
chapter: 4
id: 4-6
title: 積分器
tier: 100
board: BB
source: 自作
---

# 4-6 積分器

4-3 の反転増幅の帰還抵抗をコンデンサに変えると、入力を時間で積分した波形
(入力の電圧を時間について足し込んだ値。グラフの面積に当たる) が出力に出る。
入力が一定の間は、出力が一定の傾きで動き続ける。方形波を入れると、直線的に上下する
**三角波**が出てくるのが分かりやすい。この題ではそれをオシロで確かめる。
理想の積分器は直流でも増幅し続けてしまうので、実用回路では漏れ抵抗を 1 本足して暴走を防ぐ。

## 回路図

```circuit
title: 図1 積分器
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground c2
  V1: square c3 e3 1
  G2: ground e3
  Rin: resistor c3 c6 10k
  Cf: capacitor b6 b9 100n
  Rbleed: resistor a6 a9 1M
  Rbias: resistor e7 f7 10k
  GBias: ground f7
  U1: opamp d8 +down
  OUT: port d10
points:
  vp: a1
  vm: e1
  mid: c1
wires:
  - mid -- c2
  - c6 |- U1.-
  - e7 |- U1.+
  - a6 -- b6 -- c6
  - a9 -- b9 -- d9
  - U1.out -- d9 -- d10
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/06-integrator.svg)

- 左の VP・VN は OP アンプの ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1 と同じ)
- V1 は 1 kHz **方形波**、振幅 ±1 V。**Cf (帰還のコンデンサ) が Rin と組んで
  積分**する。− 入力は仮想接地 (4-3) なので、Rin を流れる電流 Vin/Rin がそのまま Cf を充電し、
  Vout = −(1/RinCf) ∫Vin dt になる。方形波の積分は直線 (三角波) になる
- **Rbleed (1 MΩ) は Cf と並列の漏れ抵抗。** 理想の積分器は直流成分まで
  積分し続けて出力が電源電圧まで張り付いてしまう (OP アンプの入力バイアス電流や
  オフセット電圧 (入力が 0 でも出力に出る、わずかな直流のずれ) のように、わずかな直流も時間をかけて積分されると無視できなくなる)。
  Rbleed を入れると、直流に対しては利得が Rbleed/Rin (=100 倍) の
  反転増幅に留まり、暴走が止まる。1 kHz の交流に対しては Rbleed
  (1 MΩ) が Cf (1 kHz で 1.6 kΩ) よりずっと大きいので積分動作を邪魔しない
- **Rbias (10 kΩ) は + 入力のバイアス電流補償。** ほぼ Rin (10 kΩ) と同じ値に
  すると、LM358 の入力バイアス電流が + と − の両方の入力で同じだけ電圧降下を
  作り、オフセット誤差が打ち消し合う

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
    pins: [1-, 2-, 2+, 1+]
  U1: dip8 @ e10 LM358
  Cf: capacitor j19 j22 100n
  Rbleed: resistor g19 g22 1M
  Rin: resistor j11 j7 10k
  Rbias: resistor g12 g15 10k
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t2 black
  - AD3.V- -- -b3 blue
  - AD3.W1 -- g7 yellow
  - SC.1+ -- h7 orange
  - SC.2+ -- j10 green
  - SC.1- -- j15 black
  - SC.2- -- h15 black
  - i10 -- i22 green
  - h11 -- h19 yellow
  - +t10 -- a10 red
  - j13 -- -b13 blue
  - f15 -- -t15 black
notes:
  - text below: 上の赤レール = +5V、上の青レール = GND、下の青レール = −5V (V−)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/06-integrator.svg)

- 図2 の AD3 は、Supplies (V+・V−) が図1 の VP・VN、W1 が V1 (方形波) に当たる。電源のレールの分け方は 4-2 と同じ
  (下の青レールは −5V で、GND ではない)。OP アンプ 1 個と抵抗の電流は数 mA で、各レール約 50 mA の範囲に収まる
- W1 (黄) は 7 列へ。Rin (10 kΩ) が 7 列から IN− (PIN 2、11 列) へ渡す
- 帰還の 2 本は IC の足の隣では部品を挿せないので、線で右へ広げる。IN− (11 列) は `h11 → h19`、出力 (PIN 1、10 列) は `i10 → i22`。
  Cf (100 nF) は 19 列と 22 列の間 (`j19`・`j22`)、Rbleed (1 MΩ) も 19 列と 22 列の間 (`g19`・`g22`) に挿す (並列)
- Rbias (10 kΩ) は IN+ (PIN 3、12 列) から 15 列へ。15 列は黒の線 `f15 → -t15` で GND へ落とす
- Scope は板の下に別の箱で描いた。1+ (橙) は入力の 7 列 (`h7`)、2+ (緑) は出力の 10 列 (`j10`)。1− と 2− (黒) は GND の 15 列 (`j15`・`h15`) へ
- PIN 8 (10 列) は `+t10 → a10` で +5V へ、PIN 4 (13 列) は `j13 → -b13` で −5V へ

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。1 kHz の方形波と三角波の形・傾きを見る題で、10 MHz よりずっと低いから。
W1 は 1 kHz・振幅 1 V の方形波 (オフセット 0 V)、Scope は CH1 を入力、CH2 を出力にして、トリガは CH1 の立ち上がり 0 V にする。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Square、1 kHz、振幅 1 V、オフセット 0 V、デューティ 50 % |
| Scope CH1 (入力、7 列) | DC、500 mV/div |
| Scope CH2 (出力、10 列) | DC、200 mV/div |
| Time | 200 µs/div (1 kHz が 2 周期) |
| Trigger | CH1、立ち上がり、0 V |

```scope
title: 図3 入力の方形波 (CH1) と出力の三角波 (CH2)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: square 1kHz 1V, range: 500mV/div}
ch2: {wave: "ch1 | integrate 1ms | invert", range: 200mV/div}
cursors: [50us, 450us]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/06-integrator.svg)

図3 は CH1 が 500 mV/div、CH2 が 200 mV/div。CH1 は 2 Vpp (4 目盛) の方形波、CH2 は 0.5 Vpp (2.5 目盛) の三角波。
方形波が High の半周期 (0〜500 µs) の間、出力は直線で下がり、Low の間は上がる。カーソルを 50 µs と 450 µs に置くと、CH1 は 1 V のまま、CH2 は +0.2 V から −0.2 V へ変わる。ΔV = −0.4 V を 400 µs で割ると傾き −1 V/ms で、下の表の値と合う。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方) | LM358 |
| Rin | 抵抗 (入力) | 10 kΩ |
| Cf | セラミックコンデンサ (積分・帰還) | 100 nF |
| Rbleed | 抵抗 (直流の漏れ、暴走防止) | 1 MΩ |
| Rbias | 抵抗 (+入力のバイアス電流補償) | 10 kΩ |
| — | 信号源 | 1 kHz、方形波、振幅 ±1 V |
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |
| — | 計器 | AD3 の W1 (信号源)・Scope 1+/2+ (入力と出力) |

## 見るべき値

発振器は AD3 の W1 (1 kHz・±1 V の方形波)。オシロの CH1 を入力 (7 列)、CH2 を出力 (10 列) に当て、
同じ時間軸で重ねる (図3)。表の値は計算値。傾き = Vin / (Rin×Cf)。RinCf = 10 kΩ × 100 nF = 1 ms。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 出力の傾き (Vin=+1V の半周期) | 約 −1 V/ms | −Vin / (RinCf)。方形波が High の間は出力が直線的に下がる |
| 半周期 (1 kHz の半分、0.5 ms) での電圧変化 | 約 0.5 V | 傾き × 半周期の時間 |
| 出力波形 | 三角波、振幅 約 ±0.25 V (0.5 Vpp) | 方形波の積分は三角波になる (符号は反転) |
| Rbleed を外した場合 | 出力がどちらかの電源電圧近くまで張り付く | 直流の漏れが積分され続けて飽和する (積分器の弱点) |

方形波の周波数を上げると三角波の振幅は小さくなる (傾きは同じでも半周期が
短くなるため)。逆に下げると振幅が大きくなり、電源電圧で頭が潰れやすくなる。
積分として働くのは、Rbleed と Cf で決まる 1/(2π × 1MΩ × 100nF) ≈ 1.6 Hz より十分高い周波数だけ。
Rbleed を小さくして低域の利得を抑えるほど、この下限が上がる。暴走の止めやすさと、積分できる周波数の
広さは引き換えになる。

## 出典

自作。
