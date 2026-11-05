---
book: analog-discovery
chapter: 7
id: 7-19
title: 真理値表を当てる — Pattern で入力を全部出し、Logic で 74HC00 の出力と突き合わせる
tier: 200
source: 自作 (計器の操作は Digilent の Using the Logic Analyzer)
board: BB
---

# 7-19 真理値表を当てる — Pattern で入力を全部出し、Logic で 74HC00 の出力と突き合わせる

ゲートの働きは、入力の組を**全部**入れて出力を並べれば決まる。2 入力なら組は 00・01・10・11 の 4 つ。
ここでは 74HC00 (2 入力 NAND が 4 つ) で XOR を組み、**Pattern** (パターンジェネレータ) で A と B の 4 つの組を
0.5 ms ずつ順に出す。**Logic** (ロジックアナライザ) で入力と途中の節点 (N1〜N3) と出力 Y を同時に取り、
カーソル 4 本で真理値表を読む。どの NAND も「両方 1 のときだけ 0」になっているか、Y が XOR になっているかを
表の上で突き合わせる。7-2 で Pattern と Logic を、7-10 で Pattern の Clock を使った。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 NAND 4 つで XOR を組み、全部の節点を Logic で見る
parts:
  PG:
    type: device
    at: 2,6
    label: AD3 Pattern
    turn: mirror
    pins: [DIO0, DIO1, DIO6, GND]
  G1: ground 3.5,8
  U1A: nand 7,6 74HC00
  U1B: nand 11,4 74HC00
  U1C: nand 11,8 74HC00
  U1D: nand 15,6 74HC00
  LA:
    type: device
    at: 19,5.6
    label: AD3 Logic
    pins: [DIO2, DIO3, DIO5, DIO4]
wires:
  - PG.DIO0 -| 5,2
  - 5,2 -- 6,2 -- 10,2
  - PG.DIO1 -| 5,10
  - 5,10 -- 6,10
  - PG.DIO6 -| 4.5,11
  - 4.5,11 -- 10,11
  - PG.GND -| 3.5,8
  - 6,2 |- U1A.a
  - 6,10 |- U1A.b
  - U1A.out -- 9,6
  - 10,2 |- U1B.a
  - 9,6 |- U1B.b
  - 9,6 |- U1C.a
  - 10,11 |- U1C.b
  - 9,6 -- 9,1
  - 9,1 -- 17.5,1
  - 17.5,1 |- LA.DIO2
  - U1B.out -- 13,4
  - 13,4 |- U1D.a
  - 13,4 -- 16.5,4
  - 16.5,4 |- LA.DIO3
  - U1C.out -- 13,8
  - 13,8 |- U1D.b
  - 13,8 -- 16.5,8
  - 16.5,8 |- LA.DIO4
  - U1D.out -| LA.DIO5
notes:
  - text 5.3,1.6 blue: A
  - text 5.3,10.4 blue: B
  - text 9.2,5.6 blue: N1
  - text 13.2,3.6 blue: N2
  - text 13.2,8.4 blue: N3
  - text 15.9,5.7 blue: Y
  - text 7,11.4 blue: "B (DIO6 も同じ波)"
  - text 1,12.5 small left: "U1 は 74HC00。VCC は PIN 14 (3.3 V)、GND は PIN 7"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/19-nand-truth-table.svg)

- XOR = NAND 4 つの定番の組み方。N1 = (A·B)′、N2 = (A·N1)′、N3 = (B·N1)′、Y = (N2·N3)′ (′ は否定)
- **B は Pattern の DIO1 と DIO6 の 2 本から同じ波を出す。** U1C の入力 (10 番) はブレッドボードの上のブロックにあり、
  DIO1 から線を回すと IC の胴を跨ぐため。DIO の間のずれは 2 ns (AD3 の仕様の typical) で、0.5 ms の組には効かない
- 電源は AD3 の **Supplies の V+ を 3.3 V** にする。DIO の H は 3.3 V (LVCMOS) なので、74HC00 も 3.3 V にそろえる。
  Logic の入力の H のしきい値 V<sub>IH</sub> は 2.0 V で、無負荷の HC の出力 (ほぼ 3.3 V) は余裕で H と読める

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3
board: half
parts:
  U1: dip14 @ e10 74HC00
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, GND, DIO4, 2+, DIO5, 1+, DIO0, DIO1, DIO3, DIO2, DIO6, 1-, 2-]
wires:
  - AD.V+ -- +b3 red
  - +b2 -- +t2 red
  - a10 -- +t10 red
  - AD.GND -- -b4 black
  - j16 -- -b16 black
  - AD.DIO0 -- j10 yellow
  - i10 -- i13 yellow
  - AD.DIO1 -- j11 green
  - AD.DIO6 -- e24 green
  - a14 -- a24 green
  - j12 -- j14 blue
  - g14 -- g20 blue
  - f20 -- e20 blue
  - d20 -- d15 blue
  - AD.DIO2 -- i20 blue
  - AD.DIO3 -- j15 orange
  - h15 -- h22 orange
  - f22 -- e22 orange
  - c22 -- c12 orange
  - b11 -- b16 purple
  - c11 -- c5 purple
  - AD.DIO4 -- e5 purple
  - d13 -- d7 white
  - AD.DIO5 -- e7 white
  - a7 -- a6 white
  - AD.2+ -- e6 white
  - h13 -- h8 yellow
  - AD.1+ -- j8 yellow
  - AD.1- -- -b27 black
  - AD.2- -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/19-nand-truth-table.svg)

U1 は e10 (1 番が f10)。下の列が 1〜7 番 (1A 1B 1Y 2A 2B 2Y GND)、上の列が右から 8〜14 番 (3Y 3A 3B 4Y 4A 4B VCC)。

| 節点 | ピン | 列 | 線 |
| --- | --- | --- | --- |
| A | 1・4 | 下 10・13 | DIO0 → j10、i10〜i13 (黄) |
| B | 2・10 | 下 11・上 14 | DIO1 → j11、DIO6 → e24 から a24〜a14 (緑) |
| N1 | 3・5・9 | 下 12・14・上 15 | j12〜j14、g14〜g20、f20〜e20 で溝を渡り d20〜d15 (青)。DIO2 は i20 |
| N2 | 6・12 | 下 15・上 12 | DIO3 → j15、h15〜h22、f22〜e22、c22〜c12 (橙) |
| N3 | 8・13 | 上 16・11 | b11〜b16、c11〜c5、DIO4 → e5 (紫) |
| Y | 11 | 上 13 | d13〜d7、DIO5 → e7。a7〜a6 と 2+ → e6 (白) |
| A (Scope) | — | 下 13 | h13〜h8、1+ → j8 (黄) |

溝を渡る線は IC の右の 20・22 列でまとめて渡し、IC の胴の上を通る線を作らない。
V+ は下の +b から 2 列で上の +t へ渡し、14 番 (a10) へ。7 番 (j16) と GND・1−・2− は −b へ。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 3.3 V、Master Enable を入れる |
| Pattern | DIO0 = Clock 1 kHz (A)。DIO1 と DIO6 = Clock 500 Hz (B)。どれも Duty 50 %・Phase 0 で、同時に始める |
| Logic | DIO0〜DIO5 を Add し、Rate 1 MS/s、Samples 5k (5 ms)。Trigger は DIO1 の立ち上がり。カーソル 4 本を 0.25・0.75・1.25・1.75 ms に置く |

A は 0.5 ms ごと、B は 1 ms ごとに変わるので、2 ms で 4 つの組 (B A) = 11・10・01・00 が一巡する。
Logic は Pattern が出している DIO0・DIO1 もそのまま読める (同じ DIO を出力と入力の両方に使う)。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 4 つの組を 0.5 ms ずつ出し、カーソル 4 本で真理値表を読む
device: ad3
time: 500us/div
sample: 1MHz
signals:
  A: dio0 clock 1kHz
  B: dio1 clock 500Hz
  N1: dio2 pattern 0111 bit 500us repeat
  N2: dio3 pattern 1101 bit 500us repeat
  N3: dio4 pattern 1011 bit 500us repeat
  Y: dio5 pattern 0110 bit 500us repeat
buses:
  BA: B A bin
cursors: [250us, 750us, 1250us, 1750us]
trigger: B rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/logic/19-nand-truth-table.svg)

図3 のカーソルの縦の並びが、そのまま真理値表の 1 行になる。電圧の振れは Scope でも確かめる
(CH1 = A、CH2 = Y。図2 の 1+ と 2+)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 A (CH1) と Y (CH2) の電圧 — Y は 0〜3.3 V で 500 Hz
time: 500us/div
trigger: ch1 rising 1.65V at -4div
ch1: {wave: square 1kHz 1.65V offset 1.65V, range: 1V/div, position: 0.5div}
ch2: {wave: square 500Hz 1.65V offset 1.65V | delay 500us, range: 1V/div, position: -3.5div}
cursors: [250us, 750us]
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/19-nand-truth-table.svg)

Y は「A と B が違うときだけ 1」なので、組 10 と 01 の 1 ms だけ H になり、周期 2 ms (500 Hz) の方形波に見える。

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1 | 74HC00 (SN74HC00N) | 2 入力 NAND × 4。DIP14 |
| 電源 | 3.3 V (AD3 の Supplies の V+) | DIO の H (3.3 V) にそろえる。消費は µA で、Supplies の 250 mW に遠く収まる |
| 線 | ジャンパ線 | 色は図2 のとおり (節点ごとに 1 色) |

## 見るべき値

計算値 (真理値表)。図3 のカーソル X1〜X4 の読みと同じ。

| B | A | N1 = (A·B)′ | N2 = (A·N1)′ | N3 = (B·N1)′ | Y = (N2·N3)′ | 分かること |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 1 | 0 | 1 | 1 | 0 | U1A は両方 1 のときだけ 0 |
| 1 | 0 | 1 | 1 | 0 | 1 | U1C は B と N1 が両方 1 で 0 |
| 0 | 1 | 1 | 0 | 1 | 1 | U1B は A と N1 が両方 1 で 0 |
| 0 | 0 | 1 | 1 | 1 | 0 | Y は A と B が違うときだけ 1 = XOR |

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| A・B の周期 | 1.000 ms・2.000 ms | Pattern の設定どおり。4 つの組が 0.5 ms ずつ |
| Y の周期・H の幅 | 2 ms・1 ms (組 10 と 01) | XOR の出力 |
| Y の H・L の電圧 (Scope) | 3.3 V・0 V に近い (無負荷の HC) | Logic の V<sub>IH</sub> 2.0 V・V<sub>IL</sub> 0.8 V に余裕がある |
| 各ゲートの出力 | 上の表の 4 行と一致 | 1 つでも違えば、そのゲートの配線かピンの取り違え |

**当てる練習**: 4 つの NAND のどれかの入力をわざと別の節点に挿し替え、表を取り直すと、
どの列が変わったかで「どのゲートの入力がどこにつながっているか」を当てられる。動かないときも同じ手順で、
N1 → N2・N3 → Y と前から順に表と比べ、最初に合わなくなった節点のゲートを調べる。

**組が同時に変わる所のひげ**: 1 ms (10 → 01) と 2 ms (00 → 11) では A と B が同時に変わる。
DIO の間のずれ (2 ns) とゲートの遅れ (74HC00 の t<sub>pd</sub> は 4.5 V で typ 9 ns、3.3 V ではもっと長い) のため、
Rate を 100 MS/s に上げると Y に数 ns〜数十 ns のひげ (ハザード) が見えることがある (目安。出ないこともある)。
1 MS/s (1 µs ごと) では見えない。組の変わり目で読まず、組の真ん中でカーソルを読むのはこのため。

## LTspice での確かめ (対象外)

ロジック IC の真理値表の題。算術で確かめた。N1 = (A·B)′、N2 = (A·N1)′、N3 = (B·N1)′、Y = (N2·N3)′ を 4 つの組で計算すると、
上の表のとおり Y = 0・1・1・0 で A と B の XOR になる (Python で 4 行を総当たりして確かめた)。
図3 の読み値 (`check` のカーソルの表) は表と 4 行とも一致した。A 1 kHz・B 500 Hz で 1 組 0.5 ms、Y は周期 2 ms。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer)
(Pattern Generator の節)。74HC00 のピンの並びと t<sub>pd</sub> は
[TI SN74HC00 データシート](https://www.ti.com/lit/ds/symlink/sn74hc00.pdf)。DIO の V<sub>IH</sub>・V<sub>IL</sub>・
チャネル間のずれ (2 ns) は
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
参考: [NAND logic](https://en.wikipedia.org/wiki/NAND_logic)、[ハザード (論理回路)](https://ja.wikipedia.org/wiki/%E3%83%8F%E3%82%B6%E3%83%BC%E3%83%89_(%E8%AB%96%E7%90%86%E5%9B%9E%E8%B7%AF))
