---
book: etc
chapter: 2
id: 2-5
title: 発振と分周 — 32.768 kHz の水晶を 8 Hz のクロックと 1 秒の TICK にする
tier: 200
source: 自作
board: [BB, PF]
---

# 2-5 発振と分周 — 32.768 kHz の水晶を 8 Hz のクロックと 1 秒の TICK にする

> [!WARNING]
> **この題は、まだ実際の回路で検証していない。** 回路図・実体配線図・波形・数値は、設計から計算と見積りで作ったもので、組んで測ったものではない。水晶の負荷容量は典型値からの見積りだ。

全体の中の位置は [01-block.md](01-block.md) の ④ 時計の、最初のユニット。水晶の 32.768 kHz を CD4040B で分周して
**8 Hz のクロック (CLK)** にし、74HC163 で 8 分周して **1 秒に 1 回の TICK** を作る。
CLK は [04-state-machine.md](04-state-machine.md) の状態遷移のクロックでもある。
TICK を [06-seconds.md](06-seconds.md) (2-6) の秒のカウンタが数え、全体は [07-clock.md](07-clock.md) (2-7) で時計になる。
この題の基板だけで、水晶で作った正確な 1 秒が出る。

## 同期式のクロックと TICK

時計の部分は、**すべてのカウンタとフリップフロップを、8 Hz の CLK の立ち上がりで動かす**。
CLK は図1の CD4040B の Q12 で、[04-state-machine.md](04-state-machine.md) の CLK と同じものだ。
1 Hz は、別の信号 TICK で表す。TICK は 8 クロックに 1 回、1 クロックぶんだけ H になる。
各桁は「下の桁が最大の値で、TICK が来た」ときにだけ数える (イネーブルの鎖)。
ゲートの遅れ (数十 ns) は 125 ms に比べて無視できるので、ゲートの出力は次のクロックまでに必ず落ち着く。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 発振と分周 (ユニット 1)
parts:
  X1: crystal 6,3 16,3 32.768k
  Rf: resistor 6,5 11,5 10M
  U18A: not 9,7 CD4069UB
  Rd: resistor 12,7 16,7 270k
  C1: capacitor 6,9 6,11 18p
  C2: capacitor 16,9 16,11 18p
  GND1: ground 6,11
  GND2: ground 16,11
  U18B: not 17,14.8 CD4069UB
  U19: dip16 26,16 CD4040B r180
  GND3: ground 23.8,18.6
  CLK: port 32,17.68
  U20: ic 13,27 74HC163
  VCC: vcc 10,27 5V
  GND4: ground 9.4,25.5 r90
  VCC: vcc 9.4,27.75 5V
  CLK: port 9.4,28.5
  VCC: vcc 12.5,23.6 5V
  LDD: port 16.6,24.7
  GND5: ground 13,29.6
  TICK: port 16.6,28
  U46A: nor 31,25
  TICK: port 27.5,24.25
  RS: port 27.5,25.75
  LDD: port 34,25
wires:
  - 6,7 -- U18A.in
  - 6,7 -- 6,5
  - 6,5 -- 6,3
  - 6,7 -- 6,9
  - U18A.out -- 11,7
  - 11,7 -- 11,5
  - 11,7 -- 12,7
  - 16,7 -- 16,3
  - 16,7 -- 16,9
  - 11,7 -- 11,14.8
  - 11,14.8 -- U18B.in
  - U18B.out -| U19.CLOCK
  - U19.R -| 23.8,15.28
  - 23.8,15.28 -- 23.8,18.6
  - U19.Q12 -| 32,17.68
  - U20.D -| 10,27
  - U20.A -| 10.5,25.5
  - U20.B -| 10.5,26
  - U20.C -| 10.5,26.5
  - 10.5,25.5 -- 10.5,26
  - 10.5,26 -- 10.5,26.5
  - 10.5,25.5 -- 9.4,25.5
  - U20.ENP -| 10.5,27.5
  - U20.ENT -| 10.5,28
  - 10.5,27.5 -- 10.5,27.75
  - 10.5,27.75 -- 10.5,28
  - 10.5,27.75 -- 9.4,27.75
  - U20.CLK -| 9.4,28.5
  - 12.5,24.2 -| U20.VCC
  - 13,24.2 -| U20.CLR
  - 12.5,24.2 -- 13,24.2
  - 12.5,24.2 -- 12.5,23.6
  - U20.LOAD |- 16.6,24.7
  - 13,29.6 -| U20.GND
  - U20.RCO -| 16.6,28
  - 27.5,24.25 |- U46A.a
  - 27.5,25.75 |- U46A.b
  - U46A.out -- 34,25
notes:
  - text 24,12 small left: U19 CD4040B (4096 分周)  PIN 16 は +5V、PIN 8 は GND
  - text 10,16.8 small left: U18 CD4069UB  PIN 14 は +5V、PIN 7 は GND
  - text 14.5,23.1 small left: U20 74HC163 (8 分周)
  - text 29.9,24.4 tiny center: "2"
  - text 29.9,25.6 tiny center: "3"
  - text 31.7,24.6 tiny center: "1"
  - text 4,32.5 small left: 74HC02 の PIN 14 は +5V、PIN 7 は GND
style:
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/circuit/05-oscillator.svg)

- 水晶 X1 (32.768 kHz) と CD4069UB の 1 つ目のインバータ U18A で、ピアース発振回路を作る。R<sub>f</sub> (10 MΩ) はインバータの入出力を結んで動作点を決め、R<sub>d</sub> (270 kΩ) は水晶に加わる電力を抑える。C1・C2 (18 pF) と基板の浮遊容量が水晶の負荷容量になる。
- 2 つ目のインバータ U18B で四角い波 (CK32) に整え、CD4040B (U19) に入れる。CD4040B は立ち下がりで数え、Q12 は 32768 ÷ 4096 で **8 Hz** になる。これが CLK だ。U19 の R は GND につなぎ、リセットしない。
- U20 (74HC163) は 8 Hz を 8 分周して TICK を作る。データ入力は 8 (D だけ +5 V)。数は 8〜15 で、15 のあいだだけ RCO が H になる。これが TICK で、次のクロックで 8 に戻る。LOAD は LDD で、RS が H のときも 8 を読み込む。
- **RS は 2-7 の窓判定から来る** (正時パルスで U20 を 8 に戻す)。この題だけで組むときは、RS を GND につなぐ (ブレッドボードなら図2 の下の箱の RS の線を − レールへ)。

## 実体配線図

ブレッドボードに載せる回路の周波数は、発振の 32.768 kHz が最高で、ブレッドボードの目安の 3 MHz 以下に収まる。
電源は 5 V で、電流は数 mA (見積り)。IC と部品が 30 列に収まらないので full のブレッドボードにした。
各 IC の電源のそばには 0.1 µF を挿す (図には描いていない)。電源と GND は、上と下のレールの両方に渡す。
ブレッドボードの図のあとに、同じ回路のユニバーサル基板の図 (図2b) を足した。部品面から見た配置と配線の図で、線は半田面に通す。
使わない出力のピンがつながっていないという検査の知らせは、組み立てとして正しいので止めてある (`style: check: off`)。

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図2 発振と分周のブレッドボード (ユニット 1)
board: full
parts:
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  XT:
    type: device
    at: top
    label: 他の基板へ (上)
    pins: [TICK]
  XB:
    type: device
    at: bottom
    label: 他の基板へ (下)
    pins: [CLK, RS]
  U18: dip14 @ e28 CD4069UB
  U19: dip16 @ e37 CD4040B
  U20: dip16 @ e47 74HC163
  U46: dip14 @ e56 74HC02
  X1: crystal/cylinder c6 c10 32.768k
  Rf: resistor b10 b13 10M
  Rd: resistor e6 e13 270k
  C2: capacitor/ceramic a6 -t6 18p
  C1: capacitor/ceramic a10 -t10 18p
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - +t2 -- +b2 red
  - -t2 -- -b2 black
  - XT.TICK -- a48 green
  - XB.CLK -- j37 pink
  - XB.RS -- j58 brown
  - j47 -- +b47 red
  - j52 -- +b52 red
  - j53 -- +b53 red
  - a28 -- +t28 red
  - a37 -- +t37 red
  - a47 -- +t47 red
  - a53 -- +t53 red
  - a56 -- +t56 red
  - j32 -- -b32 black
  - j34 -- -b34 black
  - j44 -- -b44 black
  - j49 -- -b49 black
  - j50 -- -b50 black
  - j51 -- -b51 black
  - j54 -- -b54 black
  - j60 -- -b60 black
  - j61 -- -b61 black
  - j62 -- -b62 black
  - a29 -- -t29 black
  - a31 -- -t31 black
  - a33 -- -t33 black
  - a42 -- -t42 black
  - a58 -- -t58 black
  - a59 -- -t59 black
  - a61 -- -t61 black
  - a62 -- -t62 black
  - e35 -- f35 orange
  - e55 -- f55 yellow
  - e46 -- f46 green
  - e5 -- f5 blue
  - e14 -- f14 purple
  - e15 -- f15 white
  - g14 -- g28 purple
  - h15 -- h29 white
  - g37 -- g48 pink
  - h46 -- h57 green
  - d35 -- d43 orange
  - g31 -- g35 orange
  - d10 -- d14 purple
  - d46 -- d48 green
  - c13 -- c15 white
  - i13 -- i15 white
  - d54 -- d55 yellow
  - g55 -- g56 yellow
  - d5 -- d6 blue
  - g5 -- g6 blue
  - g29 -- g30 white
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/05-oscillator.svg)

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
title: 図2b 発振と分周のユニバーサル基板 (ユニット 1)
board:
  size: 15x9cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
points:
  TICK: ak21
  CLK: z18
  RS: av18
  VCC: a24
  GND: a12
parts:
  U18: dip14 q21 CD4069UB
  U19: dip16 z21 CD4040B
  U20: dip16 aj21 74HC163
  U46: dip14 at21 74HC02
  X1: crystal/cylinder d17 g17
  C2: capacitor/ceramic b17 b14 18p
  C1: capacitor/ceramic i16 i14 18p
  Rf: resistor k16 o16 10M
  Rd: resistor k14 o14 270k
wires:
  - r22 -- r21 black
  - r22 -- t22 black
  - t22 -- v22 black
  - t22 -- t21 black
  - v22 -- v21 black
  - v22 -- x22 black
  - x22 -- x18 black
  - ae22 -- ae21 black
  - ae22 -- ah22 black
  - ah22 -- ah18 black
  - aw22 -- aw21 black
  - aw22 -- ay22 black
  - ay22 -- ay21 black
  - av21 -- aw21 black
  - ay21 -- az21 black
  - az21 -- ba21 black
  - ba21 -- ba18 black
  - u18 -- u17 black
  - w18 -- w17 black
  - w18 -- x18 black
  - ag18 -- ag12 black
  - ag18 -- ah18 black
  - al18 -- am18 black
  - al18 -- al12 black
  - am18 -- an18 black
  - aq18 -- aq12 black
  - ax18 -- ay18 black
  - ax18 -- ax12 black
  - ay18 -- az18 black
  - az18 -- ba18 black
  - u17 -- w17 black
  - w17 -- w12 black
  - b14 -- b12 black
  - i14 -- i12 black
  - GND -- b12 black
  - b12 -- i12 black
  - i12 -- w12 black
  - w12 -- ag12 black
  - ag12 -- al12 black
  - al12 -- aq12 black
  - aq12 -- ax12 black
  - ax12 -- bb12 black
  - VCC -- q24 red
  - q24 -- q21 red
  - q24 -- z24 red
  - z24 -- z21 red
  - z24 -- aj24 red
  - aj24 -- at24 red
  - aj24 -- aj21 red
  - at24 -- bb24 red
  - at24 -- at22 red
  - ap22 -- ap21 red
  - ap22 -- at22 red
  - at22 -- at21 red
  - aj21 -- aj18 red
  - ap21 -- ap18 red
  - ao18 -- ap18 red
  - k18 -- q18 blue
  - k18 -- k16 blue
  - g17 -- g16 blue
  - g16 -- i16 blue
  - i16 -- k16 blue
  - b17 -- d17 orange
  - d17 -- d13 orange
  - k14 -- k13 orange
  - d13 -- k13 orange
  - r18 -- s18 green
  - r18 -- r16 green
  - o16 -- r16 green
  - o16 -- o14 green
  - y23 -- y16 purple
  - y23 -- af23 purple
  - af23 -- af21 purple
  - t18 -- t16 purple
  - t16 -- y16 purple
  - CLK -- z17 yellow
  - ak18 -- ak17 yellow
  - z17 -- ak17 yellow
  - aq21 -- ar21 pink
  - ar21 -- ar18 pink
  - ar18 -- at18 pink
  - ak23 -- bb23 brown
  - ak23 -- TICK brown
  - bb23 -- bb17 brown
  - au18 -- au17 brown
  - au17 -- bb17 brown
style:
  check: off
notes:
  - mark ak21 yellow
  - mark z18 yellow
  - mark av18 yellow
  - parts
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/05-oscillator.svg)

図2b は、上の図2 と同じ回路をユニバーサル基板に組む図だ。発振と分周の 4 個の IC (U18・U19・U20・U46) と水晶まわりの 5 部品を、15×9 cm (54 列 × 33 行) のユニバーサル基板に 1 列に並べた。5×7 cm と 7×9 cm は、IC が 4 個で 1 列に 50 穴ほど要るので収まらない。

- 電源 (赤) は上の縁の筋 (24 行)、GND (黒) は下の縁の筋 (12 行) に通した。各 IC の VCC (左上のピン) からは上へ、GND (右下のピン) からは下へ、IC の真横の 1 列で枝を出す。
- U20 (74HC163) は、+5 V につなぐ D・ENP (6・7 番) が、GND につなぐ C (5 番) と GND (8 番) の間にある。外側で結ぶと + と GND の線が交わるので、CLR (1 番) と VCC (16 番)、ENP (7 番) と ENT (10 番) は、半田面で胴の下を通る短い線で結んだ (同じ IC のピンどうし)。D と ENP は隣のピンどうしを短い線で結ぶ。
- 信号どうしの交差と、+ と GND の交差は無い。残る交差は信号が電源の枝を跨ぐところだけで、半円で跨いだ側を被覆線にする。
- 黄色の丸は、ユニバーサル基板の外へ出る信号のピンだ。そのピンへ直接半田付けして線を出す。信号の名前は次の表のとおり (図の中には名前を書いていない)。ブレッドボードの図の上と下の箱 (他の基板へ) と同じ信号である。
- 使わない出力のピン (CD4040B の Q の多くなど) は、どこにもつながない。

| 信号 | 印を付けたピン |
| --- | --- |
| TICK | U20 の 15 番 RCO |
| CLK | U19 の 1 番 Q12 |
| RS | U46 の 3 |

- 水晶 X1 のまわりは、部品を左の端にまとめ、U18 の 1・2・3 番ピンへ線で渡した。C1 と C2 は下の GND の筋へつなぐ。C1 から筋へ下りる線は、R<sub>d</sub> へ行く線を跨ぐ。
- 発振の部分の線は短いほどよい。長いと、浮遊容量で発振の周波数が変わり、時計が狂う。

## 計器の設定

計器は Analog Discovery 3 (AD3) に決める。発振の 32.768 kHz も、8 Hz のクロックも、AD3 のオシロの範囲に入る。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ を 5 V |
| Scope (図3) | CH1 = XOUT (U18 の PIN 2)、CH2 = CK32 (U18 の PIN 4)。10 µs/div、CH1 の立ち上がりでトリガ |
| Scope (図4) | CH1 = CLK (U19 の Q12)、CH2 = TICK (U20 の RCO)。125 ms/div、CH2 の立ち上がりでトリガ |

次の図は、**設計から計算で出した見えるはずの画面**で、実測ではない。

### 水晶の発振波形

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 水晶発振の波形 (XOUT と CK32、推測)
time: 10us/div
trigger: ch1 rising 2.5V
ch1: sine 32.768kHz 2.2V offset 2.5V
ch2: square 32.768kHz 2.5V offset 2.5V phase 180deg
cursors: [0, 30.52us]
measure: [freq, vpp, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/scope/05-oscillator-1.svg)

| 見る所 | 見るべき値 | check の読み値 |
| --- | --- | --- |
| CH1 (XOUT、U18 の PIN 2) の周波数 | 32.768 kHz | 32.77 kHz |
| CH1 の振幅 | 仮の値 4.4 Vpp。中心は 2.5 V 付近 | Vpp 4.40 V、Avg 2.50 V |
| CH2 (CK32、U18 の PIN 4) | 0 V と 5 V の四角い波、周波数 32.768 kHz | Vpp 5.00 V、32.77 kHz |
| カーソル | 1 周期 = 1 ÷ 32.768 kHz = 30.52 µs | ΔX 30.52 µs (32.77 kHz) |

- 周波数は **CK32 (PIN 4) で測る**。XOUT にプローブを当てると、プローブの容量 (10 pF 前後) が負荷容量に加わり、周波数が数 ppm 以上ずれる。XOUT は形を見るだけにする。
- CH1 の振幅 4.4 Vpp は仮の値で、実測ではない。発振が弱いときは Rd を小さく、強すぎるときは大きくする。

### 8 Hz のクロックと TICK

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 8 Hz の CLK と 1 Hz の TICK (推測)
time: 125ms/div
trigger: ch2 rising 2.5V
ch1: square 8Hz 2.5V offset 2.5V
ch2: pulse 1Hz 2.5V offset 2.5V duty 12.5%
cursors: [31.25ms, 156.25ms]
measure: [freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/scope/05-oscillator-2.svg)

| 見る所 | 見るべき値 | check の読み値 |
| --- | --- | --- |
| CH1 (CLK) | 8 Hz、デューティ 50 % | 8.000 Hz、50.0 % |
| CH2 (TICK) | 1 Hz、デューティ 12.5 % (125 ms) | 1.000 Hz、12.5 % |
| カーソル X1 (31.25 ms) | CLK も TICK も H | CH1 5.00 V、CH2 5.00 V |
| カーソル X2 (156.3 ms) | CLK は H、TICK は L | CH1 5.00 V、CH2 0 V |
| ΔX | 125 ms = 1 ÷ 8 Hz | 125.0 ms (8.000 Hz) |

### 水晶のずれ

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図5 水晶の温度による周波数のずれ (典型値から計算)
x: 温度 °C -10..50
y:
  - 周波数偏差 ppm
  - 一日のずれ s
lines:
  周波数偏差 ppm: -0.034 * (x - 25)^2
  一日のずれ s: -0.034 * (x - 25)^2 * 0.0864
notes:
  - mark 0
  - mark 25
  - mark 45
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/graph/05-oscillator.svg)

| 見る所 | 見るべき値 | check の読み値 |
| --- | --- | --- |
| 25 °C | ずれ 0 | 0 ppm、0 s |
| 0 °C | − 0.034 ppm/°C² × (25 °C)² | − 21.3 ppm、− 1.84 s/日 |
| 45 °C | − 0.034 ppm/°C² × (20 °C)² | − 13.6 ppm、− 1.18 s/日 |

- 32.768 kHz の音叉型の水晶は、25 °C 付近で最も速く、温度が離れると遅れる (放物線)。係数 − 0.034 ppm/°C² は典型値で、実物の規格を確かめる。
- 1 ppm は 1 日で 0.0864 秒。20 ppm なら 1 日で約 1.7 秒、1 時間で 0.07 秒ずれる。正時の窓 ±30 秒に対して十分小さく、毎正時に合わせ直すので、ずれは積もらない。

## 見るべき値 (目安)

| 項目 | 値 | 根拠 |
| --- | --- | --- |
| 水晶の負荷容量 | 約 12 pF | C1・C2 = 18 pF の直列 9 pF + 浮遊容量 3 pF (仮)。水晶は 12.5 pF を想定 |
| 直列抵抗 R<sub>d</sub> | 270 kΩ | C2 のリアクタンス 1 ÷ (2π × 32768 Hz × 18 pF) = 270 kΩ に合わせた |
| CLK | 8 Hz | 32768 ÷ 4096 |
| TICK | 1 Hz、H は 125 ms (1 クロック) | 8 Hz を 8 分周 |

- 発振がかからないときは、C1・C2 を 12 pF〜22 pF で替え、R<sub>d</sub> を 100 kΩ〜470 kΩ で替えてみる。CD4069UB の代わりにバッファつきの 74HC04 を使うと、発振が不安定になることがある。
- 74HC02 (U46) の使わないゲートの入力は、必ず GND につなぐ。浮かせると、消費電流が増え、動きが不安定になる。

## 部品表

| 部品 | 個数 | 備考 |
| --- | --- | --- |
| 32.768 kHz 水晶 (X1) | 1 | 負荷容量 12.5 pF を想定 |
| CD4069UB | 1 | U18。UB (バッファなし) を選ぶ。水晶の発振に使う |
| CD4040B | 1 | U19。74HC4040 でもよい |
| 74HC163 | 1 | U20 (8 分周) |
| 74HC02 | 1 | U46 (2 入力 NOR)。1 回路だけ使う。2-7 では窓判定の 74HC02 と同じ型 |
| 抵抗 10 MΩ | 1 | R<sub>f</sub> |
| 抵抗 270 kΩ | 1 | R<sub>d</sub> |
| セラミックコンデンサ 18 pF | 2 | C1・C2 (E12) |
| 0.1 µF のセラミックコンデンサ | 4 | IC ごとの電源のそば |

## LTspice での確かめ

分周の論理は SPICE の対象外。アナログの値と分周比を `sim/05-oscillator.cir` で確かめた (実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 水晶の負荷容量 (18 pF 2 個の直列) | 12.5 pF を想定 | 9 pF + 浮遊容量 約 3.5 pF | 合う |
| 8 Hz | 32768 / 4096 | 8 Hz | 合う |
| TICK の周波数と H の長さ | 1 Hz、125 ms | 1 Hz、0.125 s | 合う |

## 出典

自作。参考: [TI の CD4069UB データシート (SCHS054E)](https://www.ti.com/lit/ds/symlink/cd4069ub.pdf)、
[TI の CD4040B データシート (SCHS030D)](https://www.ti.com/lit/ds/symlink/cd4040b.pdf)、
[TI の SN74HC163 データシート (SCLS298D)](https://www.ti.com/lit/ds/symlink/sn74hc163.pdf)。

- 水晶の温度係数 (− 0.034 ppm/°C²) と負荷容量は典型値で、使う水晶の規格を確かめる
