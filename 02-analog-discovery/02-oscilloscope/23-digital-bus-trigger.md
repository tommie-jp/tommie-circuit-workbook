---
book: analog-discovery
chapter: 2
id: 2-23
title: デジタル ch (バスの値) でトリガする
tier: 200
source: 自作
board: BB
---

# 2-23 デジタル ch (バスの値) でトリガする

Scope にはアナログの 2 ch のほかにデジタル ch (DIO) を足して、同じ時間軸に並べられる (2-8 の MSO)。
足したデジタル ch は**トリガの元にもなる**。7-7 では Logic の計器でバスの値を条件にしたが、
ここでは **Scope のトリガを DIO の値の組 (バス) にして、その瞬間のアナログ波形を捕まえる**。

題材は 4 ビットのカウンタ 74HC393 と、4 本の抵抗で出力を 1 本の電圧にまとめる簡単な D/A 変換 (重み付き抵抗の DAC)。
CH1 には 0〜3.3 V の階段が出て、DIO0〜DIO3 にはその階段の「番号」が出る。
「番号が 15 になった瞬間」でトリガすれば、階段のいちばん上の段が毎回同じ所に止まる。
CH1 のレベルでトリガしても同じ絵は出せるが、それは段の電圧が分かっているからできることで、
アナログの値から番号が決まらない回路 (アドレスとデータの組など) ではバスの値でしか狙えない。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 74HC393 の 4 ビットを抵抗の重みで 1 本の電圧にする
parts:
  W1: square 2,6 2,8 1.65 l=$\mathrm{W1}$
  G1: ground 2,8
  U1: ic 8,6 74HC393
  VCC: vcc 8,2.5 3.3V
  G2: ground 6,9.5
  G3: ground 7.5,9.5
  RD: resistor 11,8 11,10 10k
  RC: resistor 13,8 13,10 20k
  RB: resistor 15,8 15,10 39k
  RA: resistor 17,8 17,10 82k
  DIO3: port 12,7 out
  DIO2: port 14,7 out
  DIO1: port 16,7 out
  DIO0: port 18,7 out
  M1: voltmeter 19.5,10 19.5,12 l=$\mathrm{CH1}$
  G4: ground 19.5,12
wires:
  - 2,6 -| U1.1CLK
  - U1.2CLK -| 6,9.5
  - U1.VCC |- 8,2.5
  - U1.GND |- 7.5,9
  - U1.1CLR -| 8,9
  - U1.2CLR -| 8.5,9
  - 7.5,9 -- 8,9 -- 8.5,9
  - 7.5,9 -- 7.5,9.5
  - U1.1QD -| 11,7
  - 11,7 -- 11,8
  - U1.1QC -| 13,7
  - 13,7 -- 13,8
  - U1.1QB -| 15,7
  - 15,7 -- 15,8
  - U1.1QA -| 17,7
  - 17,7 -- 17,8
  - 11,7 -- 12,7
  - 13,7 -- 14,7
  - 15,7 -- 16,7
  - 17,7 -- 18,7
  - 11,10 -- 13,10 -- 15,10 -- 17,10 -- 19.5,10
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/23-digital-bus-trigger.svg)

- W1 (1 kHz、0〜3.3 V の方形波。図の 1.65 V は振幅で、オフセットも 1.65 V) を 74HC393 の 1CLK へ。1CLR は GND (数え続ける)。
  74HC393 は **CLK の立ち下がりで 1 つ進む** 4 ビットの 2 進カウンタで、1QA が最下位
- 使わない 2 番目のカウンタは 2CLK・2CLR を GND に固定する (CMOS の入力を浮かせない)
- 1QA〜1QD をそのまま DIO0〜DIO3 へ (図の矢印)。同じ 4 本から抵抗 RA〜RD を OUT にまとめ、OUT を CH1 で見る
- 電源は Supplies の V+ を 3.3 V にする。DIO の入力は 3.3 V の CMOS なので、カウンタも 3.3 V で動かして H の電圧を合わせる (7-7 と同じ理由)

**重み付き抵抗の DAC**: OUT の電圧は、H のビットの抵抗の逆数 (コンダクタンス) の和を、全部の和で割った分だけ 3.3 V に近づく。
RD (1QD、最上位) 10 kΩ (キロオーム)、RC 20 kΩ、RB 40 kΩ、RA 80 kΩ にすれば重みがちょうど 8 : 4 : 2 : 1 になり、
番号 n のとき OUT = 3.3 V × n / 15。40 kΩ と 80 kΩ は E24 に無いので最寄りの 39 kΩ と 82 kΩ に丸め、期待値はこの値で計算し直した (「見るべき値」)。
OUT から見た抵抗は 4 本の並列で 5.3 kΩ。CH1 の 1 MΩ で 0.5 % 下がる。

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (74HC393 と重みの抵抗 4 本)
board: half
parts:
  U1: dip14 @ e12 74HC393
  RA: resistor g14 g6 82k cap=above
  RB: resistor h15 h6 39k cap=below:0,1
  RC: resistor g16 g24 20k cap=above
  RD: resistor h17 h24 10k cap=below:0,1
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, GND, W1, DIO0, DIO1, DIO2, DIO3, 1+, 1-]
wires:
  - AD.V+ -- +b8 red
  - AD.GND -- -b9 black
  - +b2 -- +t2 red
  - -b3 -- -t3 black
  - a12 -- +t12 red
  - a13 -- -t13 black
  - a14 -- -t14 black
  - j13 -- -b13 black
  - j18 -- -b18 black
  - i6 -- i24 blue
  - AD.W1 -- j12 yellow
  - AD.DIO0 -- j14 green
  - AD.DIO1 -- j15 green
  - AD.DIO2 -- j16 green
  - AD.DIO3 -- j17 green
  - AD.1+ -- j24 orange
  - AD.1- -- -b26 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/23-digital-bus-trigger.svg)

U1 (74HC393) は 12〜18 列。1 番 (1CLK) が左下の f12 で、下のブロックに 1CLK・1CLR・1QA〜1QD・GND が並ぶ。
カウンタの出力は 4 列が隣り合うので、抵抗を左右に分けた: 1QA・1QB の RA・RB は左の 6 列へ、1QC・1QD の RC・RD は右の 24 列へ。
6 列と 24 列は i 行の青い線でつなぎ、24 列が OUT (CH1 の 1+)。DIO0〜DIO3 は 14〜17 列の j 行に下から挿す。
上のブロックは VCC (e12) を + レールへ、2CLK・2CLR を − レールへ。上下のレールは 2・3 列でつなぐ。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 3.3 V、Master Enable |
| Wavegen (W1) | 方形波、1 kHz、振幅 1.65 V、オフセット 1.65 V (0〜3.3 V) |
| Scope (CH1) | DC、500 mV/div、Time 2 ms/div (階段 1 周の 16 ms が 1 画面に入る) |
| Scope のデジタル ch | DIO0〜DIO3 を足し、4 本をまとめて Bus を作る (DIO3 が最上位、10 進表示) |
| Trigger | 元を Digital にし、条件を Bus = 15 にする (DIO0〜DIO3 がすべて H)。Mode は Normal |

デジタル ch の足し方とトリガの条件の書き方は WaveForms の版で画面が違う (目安。Scope の Channels の追加の欄と Trigger の Source)。
条件はビットごとに「H・L・立ち上がり・立ち下がり・どちらでもよい」を並べる形のこともあり、そのときは 4 本とも H を選べば同じ意味になる。

CH1 に見えるはずの画面が図3、同じ瞬間のデジタル ch が図4 (Scope の画面ではデジタル ch は CH1 の下に並ぶ。ここでは分けて描いた)。
図3 のトリガは描く都合で CH1 の 3.2 V の立ち上がりにしてある。3.2 V を上に横切るのは 14→15 の 1 か所だけなので、Bus = 15 でトリガしたのと同じ絵になる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 バス = 15 でトリガした CH1 (t = 0 で 3.30 V、1 ms 後に 0 V)
time: 2ms/div
trigger: ch1 rising 3.2V
ch1: {wave: "= 3.3V * (0.0649 * step(sin(2 * pi * 500Hz * t)) + 0.1365 * step(cos(2 * pi * 250Hz * t)) + 0.2662 * step(sin(pi / 4 - 2 * pi * 125Hz * t)) + 0.5324 * step(sin(pi / 8 - 2 * pi * 62.5Hz * t)))", range: 500mV/div, position: -3div}
cursors: [-0.5ms, 0.5ms]
measure: [vmax, vmin, period]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/23-digital-bus-trigger.svg)

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 同じ瞬間の DIO0〜DIO3 とバスの値 (MSB が DIO3)
device: ad3
time: 2ms/div
start: 0.5ms
axis: ms
signals:
  CLK: clock 1kHz
  Q: dio0..dio3 counter on CLK falling start 5 wrap 16
buses:
  Bus: Q3..Q0 dec
cursors: [10ms, 11ms]
trigger: Q0 rising at 10.5ms
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/logic/23-digital-bus-trigger.svg)

図4 の横軸は窓の左端からの時刻で、図3 の t = 0 が図4 の 10.5 ms (T の印) に当たる。
カーソル X1・X2 は図3 も図4 も、トリガの 0.5 ms 前と 0.5 ms 後 (番号 14 と 15)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 4 ビット 2 進カウンタ × 2 | 74HC393 (DIP14) |
| RD | 抵抗 (1/4 W) | 10 kΩ (1QD、重み 8) |
| RC | 抵抗 (1/4 W) | 20 kΩ (1QC、重み 4) |
| RB | 抵抗 (1/4 W) | 39 kΩ (1QB、重み 2。40 kΩ を E24 に丸めた) |
| RA | 抵抗 (1/4 W) | 82 kΩ (1QA、重み 1。80 kΩ を E24 に丸めた) |
| — | 電源 | Analog Discovery 3 の V+ (3.3 V。DIO の入力が 3.3 V なので 5 V にしない) |

抵抗に流れる電流は最大で 3.3 V / 10 kΩ = 0.33 mA、電力は 1 mW ほどで、1/4 W の半分よりずっと小さい。

## 見るべき値

計算値。OUT = 3.3 V × (n<sub>A</sub>/82 kΩ + n<sub>B</sub>/39 kΩ + n<sub>C</sub>/20 kΩ + n<sub>D</sub>/10 kΩ) ÷ (1/82 kΩ + 1/39 kΩ + 1/20 kΩ + 1/10 kΩ)
(n<sub>A</sub> などは各ビットの 0 か 1)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| トリガの直前 (番号 14) の CH1 | 3.09 V (理想の 3.3 × 14/15 = 3.08 V) | 丸めた抵抗でも 1 段 (0.22 V) の 1 割より小さいずれ |
| トリガの直後 (番号 15) の CH1 | 3.30 V (CH1 の 1 MΩ を入れると 3.28 V) | いちばん上の段が毎回 t = 0 に止まる |
| 1 段の高さ | 約 0.21〜0.24 V (理想は 0.22 V) | 重み 2 の RB が 39 kΩ に丸めたぶん、1QB が変わる段だけ少し高い |
| 番号 7→8 の段 | 1.54 V → 1.76 V | 4 本が一斉に変わる段も 1 段ぶんだけ上がる (単調に増える) |
| 階段の周期 | 16 ms (1 kHz の 16 クロック) | トリガは 16 ms に 1 回。Time を速くしても止まる位置は同じ |
| トリガの位置と CLK | トリガは W1 の立ち下がりの直後 (数十 ns 遅れ) | 74HC393 は立ち下がりで数え、CLK から QA まで典型 15 ns (4.5 V。3.3 V では長め) |

**トリガの値の選び方に気を付ける。** 74HC393 はリップルカウンタで、下のビットの変化が次のビットを動かす。
7 (0111) → 8 (1000) では QA・QB・QC が順に L になってから QD が H になり、その途中で 6・4・0 の値が数 ns ずつ現れる
(データシートの遅れは CLK から QA が典型 15 ns、QD が 32 ns。4.5 V、負荷 50 pF)。
**Bus = 0 を条件にすると、この途中の 0 (1→2・3→4・7→8 の切り替わり) でもトリガが掛かることがある** (目安。
8 ns の標本の間に入るかどうかで変わる)。その画面は階段の途中で止まり、表示がときどき跳ぶ。
途中の値で一度も現れないのが 15 で、15 は 14 (1110) から QA だけが変わって来るので、条件に使っても誤って掛からない。
同期式のカウンタ (74HC161 など) ならビットがそろって変わるので、この心配は小さい。

## LTspice での確かめ

`sim/23-bus-trigger-dac.cir` で、番号 n (0〜15) の 4 ビットを 0 V / 3.3 V の理想の電圧源にして (74HC393 の出力抵抗は 0 と仮定)、
RA〜RD と CH1 の 1 MΩ をつないだ OUT を `.dc` で読んだ。カウンタの動きとトリガの条件は算術で確かめた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 番号 1 の OUT | 0.214 V | 0.213 V | 合う |
| 番号 7 / 8 の OUT | 1.54 V / 1.76 V | 1.535 V / 1.748 V | 合う (1 MΩ のぶん 0.5 % 低い) |
| 番号 14 の OUT | 3.09 V | 3.069 V | 合う (同上) |
| 番号 15 の OUT | 3.30 V (1 MΩ で 3.28 V) | 3.283 V | 合う |

算術: 1 kHz の立ち下がりごとに 1 つ進むので、15 は 16 ms に 1 回、1 ms だけ続く。図3 の読み値 (X1 3.09 V、X2 3.30 V、周期 16.00 ms) と合う。
途中の値は、n から n + 1 への変化で下から続く 1 のビットが順に 0 になる並びを書き出して数えた (0 が途中に出るのは 1→2・3→4・7→8 の 3 か所、15 は 0 か所)。

## 出典

自作。

参考: [SN74HC393 データシート (Texas Instruments)](https://www.ti.com/lit/ds/symlink/sn74hc393.pdf)、[Digital-to-analog converter (Wikipedia)](https://en.wikipedia.org/wiki/Digital-to-analog_converter) (Binary-weighted の節)
