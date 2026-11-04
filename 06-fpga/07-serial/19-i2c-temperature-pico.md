---
book: fpga
chapter: 7
id: 7-19
title: I2C の温度センサーを Pico 2 で読む — LM75 を組んで AD3 で見る
tier: 100
source: 自作
board: BB
device: PICO
---

# 7-19 I2C の温度センサーを Pico 2 で読む — LM75 を組んで AD3 で見る

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 への書き込みと、LM75・AD3 での測定はしていない。
> 「見るべき値」は 7-5 のシミュレーションの値と計算値。

7-5 の I2C のマスタ (`i2c_read.v` と最上位の `i2c_temp_top.v`) を Pico 2 の Soft-FPGA に載せ、LM75 (0x48) の温度を
0.5 秒ごとに読んで UART に 16 進で出す。AD3 の Logic で SCL・SDA・TXD を見る。
I2C と LM75 の決まり (電源・プルアップの値を含む)、Verilog、Pico 2 のピンの割り当ては 7-5 にある。

## プルアップの抵抗

SCL は **52 µs (19.23 kHz)** (7-5)。

プルアップ抵抗 R<sub>p</sub> の範囲は、Texas Instruments の SLVA689 (出典) の式で計算する。

| 量 | 式 | 値 (3.3 V) |
| --- | --- | --- |
| 下限 R<sub>p(min)</sub> | (V<sub>CC</sub> − V<sub>OL(max)</sub>) ÷ I<sub>OL</sub> = (3.3 − 0.4) ÷ 3 mA | 967 Ω |
| 上限 R<sub>p(max)</sub> | t<sub>r</sub> ÷ (0.8473 × C<sub>b</sub>) = 1000 ns ÷ (0.8473 × 50 pF) | 23.6 kΩ |
| 選ぶ値 | データシートの前提に合わせた E24 の値 | **10 kΩ** |
| 低いときの電流 | 3.3 V ÷ 10 kΩ | 0.33 mA |
| 立ち上がり時間 | 0.8473 × 10 kΩ × 50 pF | 424 ns |

- t<sub>r</sub> = 1000 ns は I2C のスタンダードモードの上限 (SLVA689 の表 2-1)。**C<sub>b</sub> = 50 pF はブレッドボードと配線の見積り**で、測っていない (I2C の上限は 400 pF)
- 立ち上がり 424 ns は、SCL の 1/4 周期 (13 µs) よりずっと短い
- 0 を出す側の電圧は、LM75 が 0.4 V 以下 (3 mA)、Pico 2 が 0.5 V 以下 (RP2350 データシート 14.9.4、IOVDD = 3.3 V)。受ける側の VIL 最大は、
  LM75 が 0.3 × V<sub>S</sub> = 0.99 V、Pico 2 が 0.8 V なので、どちらからも 0 と読める

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 GP4 を SDA、GP5 を SCL につなぎ、LM75 を 3.3 V で読む
parts:
  MCU: pico2 3,7 mirror
  SDA: port 7.5,5.4
  SCL: port 7.5,5.8
  U1:
    type: device
    model: LM75
    at: 17,6.2
    label: LM75
    pins: [VS, SDA, SCL, OS, A0, A1, A2, GND]
  V1: vcc 12,3 3.3V
  R1: resistor 9,3.2 9,5.4 10k
  R2: resistor 10.5,3.2 10.5,5.8 10k
  C1: capacitor 13.4,3 13.4,4.3 100n
  G3: ground 13.4,4.3
  G1: ground 13.8,8.4
  TXD: port 6.5,11
  AD:
    type: device
    at: 24,9
    label: AD3
    pins: [DIO0, DIO1, DIO2, GND]
  SCL: port 22.5,8.17
  SDA: port 22.5,8.58
  TXD: port 22.5,9
  G2: ground 22.5,10.4
wires:
  - MCU.GP4 -- 7.5,5.4 -- 9,5.4 -- U1.SDA
  - MCU.GP5 -- 7.5,5.8 -- 10.5,5.8 -- U1.SCL
  - 9,3.2 -- 9,3 -- 13.4,3
  - 10.5,3.2 -- 10.5,3
  - U1.VS -- 12,5 -- 12,3
  - U1.A0 -- 13.8,6.6
  - U1.A1 -- 13.8,7
  - U1.A2 -- 13.8,7.4
  - U1.GND -- 13.8,7.8
  - 13.8,6.6 -- 13.8,8.4
  - MCU.GP15 |- 6.5,11
  - AD.DIO0 |- 22.5,8.17
  - AD.DIO1 |- 22.5,8.58
  - AD.DIO2 |- 22.5,9
  - AD.GND |- 22.5,9.42 -- 22.5,10.4
style:
  pitch: 1.2
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/circuit/19-i2c-temperature-pico.svg)

- 同じ名前の端子どうしがつながる (6-2 と同じ描き方)。SDA と SCL は Pico 2 の GP4・GP5 から LM75 へ、R1・R2 (10 kΩ) で +3.3 V へ
- R2 の縦の線は SDA の線を横切るが、点が無いので交わっていない
- A0・A1・A2 は GND に落として、アドレスを 0x48 に決める。OS (過温度の出力) は使わず開けておく
- C1 (100 nF) は LM75 の電源のすぐそばに置く。電源は Pico 2 の 3V3 (0-3)
- AD3 は DIO0 (SCL)・DIO1 (SDA)・DIO2 (UART の TXD) を読むだけ。何も出さない。AD3 から I2C を叩くときは、DIO を出力にして同時に Pico 2 を動かさない

## 部品

| 部品 | 値・型番 | 数 | 役 |
| --- | --- | --- | --- |
| U1 | Raspberry Pi Pico 2 | 1 | Soft-FPGA を動かす。USB から給電 |
| U2 | LM75B (SO-8 を DIP 化の変換基板に載せる。型番の末尾が -3 の 3.3 V 品) | 1 | 温度センサー (I2C のスレーブ) |
| R1・R2 | 10 kΩ (E24)、1/4 W | 2 | SDA・SCL のプルアップ |
| C1 | 100 nF (E12)、セラミック | 1 | LM75 の電源のバイパス |
| — | ブレッドボード (full、63 列) | 1 | |
| — | ジャンパ線 | 約 15 本 | |
| AD | Analog Discovery 3 | 1 | Logic と Protocol で読む |

データシートの 10 µF のバルクコンデンサは、USB 電源の Pico 2 の基板に載っているので、この図では省く。

## 実体配線図

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図2 Pico 2 の GP4・GP5 を LM75 につなぎ、AD3 の DIO0 から DIO2 で読む
board: full
parts:
  MCU: pico2 @ h5
  U1: dip8/sop @ e30 LM75
  R1: resistor j30 +b30 10k
  R2: resistor j31 +b31 10k
  C1: capacitor c34 c37 100n
  AD:
    type: device
    at: bottom
    label: AD3 Logic
    pins: [DIO1, GND, DIO2, DIO0]
wires:
  - a9 -- +t9 red
  - +t63 -- +b63 red
  - -t63 -- -b63 black
  - a7 -- -t7 black
  - a30 -- +t30 red
  - a31 -- -t31 black
  - a32 -- -t32 black
  - a33 -- -t33 black
  - a34 -- +t34 red
  - a37 -- -t37 black
  - j33 -- -b33 black
  - i10 -- i30 yellow [v10, h210, v-10, h190]
  - j11 -- i31 green [v10, h210, v-20, h190]
  - AD.DIO1 -- j10 yellow
  - AD.DIO0 -- h31 green [h195, v-156]
  - AD.DIO2 -- j24 blue
  - AD.GND -- -b14 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/breadboard/19-i2c-temperature-pico.svg)

- Pico 2 は USB を左に向けて `@ h5` に挿す (0-4 と同じ)。下の列 (h 行) の 6 番 GP4 が 10 列、7 番 GP5 が 11 列、20 番 GP15 が 24 列。上の列 (c 行) の 36 番 3V3 が 9 列、38 番 GND が 7 列
- LM75 の変換基板は溝をまたいで `@ e30` に挿す。上の列に 8 番 VDD (30 列)・7 番 A0 (31 列)・6 番 A1 (32 列)・5 番 A2 (33 列)、下の列に 1 番 SDA (30 列)・2 番 SCL (31 列)・3 番 OS (32 列)・4 番 GND (33 列)
- SDA は GP4 (10 列、`i10`) から黄の線で 30 列 (`i30`) へ、SCL は GP5 (11 列、`j11`) から緑の線で 31 列 (`i31`) へ。
  2 本は i 行・j 行の下を段違いに通し、途中で 1 段ずつ上がって交わらないようにする。R1 (SDA)・R2 (SCL) は下の + レールへ立てる
- 電源: 3V3 (9 列) から上の + レールへ赤。VDD (30 列) と C1 の一端 (34 列) を上の + レールへ赤。上下の + レールは右端 (63 列) でつなぐ
- GND: Pico 2 の 38 番 (7 列) から上の − レールへ。A0・A1・A2 (31・32・33 列) と C1 の他端 (37 列) を上の − レールへ。4 番 GND (33 列) は下の − レールへ。AD3 の GND は下の − レールへ。黒の線
- AD3 は DIO1 (SDA) を 10 列 (`j10`)、DIO2 (TXD) を 24 列 (`j24`)、DIO0 (SCL) を LM75 の側の 31 列 (`h31`、右から入れる) に挿す。線の色は SDA が黄、SCL が緑、TXD が青
- C1 は 34〜37 列に横に置き、LM75 の VDD (30 列) のすぐ近くでレールから取る
- 電流は 1 mA 以下 (プルアップ 2 本で最大 0.66 mA、LM75 の電源電流は標準 0.25 mA)。信号は 19 kHz で、ブレッドボードの範囲 (3 MHz 以下) に収まる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 = SCL、DIO1 = SDA、DIO2 = TXD を Enable。DIO は 3.3 V。GND を共通にする (0-4) |
| 時間軸 (I2C) | 250 µs/div (10 目盛で 2.5 ms。1 回の通信が 2.46 ms)。標本化 1 MS/s (SCL の 1 周期に 52 標本) |
| トリガ | DIO1 (SDA) の立ち下がり (START)。トリガの前を 40 µs 見せる |
| 時間軸 (UART) | 2 ms/div (10 目盛で 20 ms)。標本化 100 kS/s (1 ビット 208 µs に 21 標本)。トリガは DIO2 の立ち下がり |
| Protocol | I2C。SCL = DIO0、SDA = DIO1。Rate = 19 kHz (SCL の速さに合わせる)。Spy で読む (操作は出典の Digilent の手引き)。UART を読むときは Protocol を UART にして RX = DIO2、4800 bps、8 ビット、パリティなし、ストップ 1 |

## Logic に見えるはずの画面

7-5 のシミュレーション (`EDGE` と `TXD` の行) の変わり目の時刻をそのまま写した。最初の読み出しの START (SDA の立ち下がり) を 0 s とした。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 LM75 の温度を読む 1 回の通信。START から STOP まで 2.46 ms
device: ad3
time: 250us/div
start: -40us
sample: 1MHz
signals:
  SCL: dio0 edges -40us=1 -26us=0 -13us=1 13us=0 39us=1 65us=0 91us=1 117us=0 143us=1 169us=0 195us=1 221us=0 247us=1 273us=0 299us=1 325us=0 351us=1 377us=0 403us=1 429us=0 455us=1 481us=0 507us=1 533us=0 559us=1 585us=0 611us=1 637us=0 663us=1 689us=0 715us=1 741us=0 767us=1 793us=0 819us=1 845us=0 871us=1 897us=0 923us=1 949us=0 975us=1 1001us=0 1027us=1 1053us=0 1079us=1 1105us=0 1131us=1 1157us=0 1183us=1 1209us=0 1235us=1 1261us=0 1287us=1 1313us=0 1339us=1 1365us=0 1391us=1 1417us=0 1443us=1 1469us=0 1495us=1 1521us=0 1547us=1 1573us=0 1599us=1 1625us=0 1651us=1 1677us=0 1703us=1 1729us=0 1755us=1 1781us=0 1807us=1 1833us=0 1859us=1 1885us=0 1911us=1 1937us=0 1963us=1 1989us=0 2015us=1 2041us=0 2067us=1 2093us=0 2119us=1 2145us=0 2171us=1 2197us=0 2223us=1 2249us=0 2275us=1 2301us=0 2327us=1 2353us=0 2379us=1 2405us=0 2431us=1
  SDA: dio1 edges -40us=1 0us=0 26us=1 78us=0 182us=1 234us=0 481us=1 494us=0 949us=1 988us=0 1014us=1 1066us=0 1170us=1 1222us=0 1378us=1 1417us=0 1625us=1 1729us=0 1833us=1 1898us=0 1950us=1 1989us=0 2353us=1 2418us=0 2457us=1
cursors: [455us, 507us]
trigger: SDA falling at 0us
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/logic/19-i2c-temperature-pico-1.svg)

- SCL は START の前に 1 クロックだけ 0 になる (START の枠の頭で SCL を 0 に下げてから SDA を決めるため。START としては正しい)
- SDA が SCL の 1 の間に 1 → 0 になる 0 s が START。続く 8 クロックで 0x90 = 1001 0000 を送る。9 クロック目 (442〜494 µs の SCL = 1 の間) に SDA が 0 になっているのが LM75 の ACK
- 次の 8 クロックでポインタ 0x00、その ACK、949 µs の SDA の 0 → 1 のあと 988 µs の 1 → 0 が再 START (SCL が 1 の間に SDA が 1 → 0)、続いて 0x91 = 1001 0001 と ACK
- そのあとの 16 クロックで 2 バイトが返る。最後の STOP は 2457 µs の SDA の 0 → 1 (SCL は 1 のまま)
- X1 (455 µs) と X2 (507 µs) は連続する SCL の立ち上がりで、ΔX = 52 µs、1/ΔX = 19.23 kHz が SCL の周波数。X1 の SDA = 0 は、アドレスの ACK

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 読み終えた後に UART で出す 1 行。"19 80" と CR LF
device: ad3
time: 2ms/div
start: -1ms
sample: 100kHz
signals:
  TXD: dio2 edges -1ms=1 2496us=0 2704us=1 2912us=0 3536us=1 3952us=0 4368us=1 4602us=0 4810us=1 5018us=0 5434us=1 6058us=0 6474us=1 6708us=0 7956us=1 8164us=0 8580us=1 8814us=0 9646us=1 10270us=0 10686us=1 10920us=0 11960us=1 12376us=0 12792us=1 13026us=0 13234us=1 13442us=0 13650us=1 14066us=0 14898us=1 15132us=0 15548us=1 15756us=0 15964us=1 16172us=0 17004us=1
decode:
  UART: uart TXD baud 4800 8N1 ascii
cursors: [2496us, 4602us]
trigger: TXD falling at 2496us
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/logic/19-i2c-temperature-pico-2.svg)

- STOP (2.457 ms) の 39 µs 後、2.496 ms から "1" "9" " " "8" "0" CR LF の 7 字が出る。1 字は 2.106 ms (10 ビット 2.08 ms + 字のすき間 26 µs、7-1 と同じ)
- 1 行を出し終えるのは約 17.2 ms。次の読み出しは 0.5 s 後

## 見るべき値

7-5 のシミュレーションの値と計算値。実機では測っていない。Logic のカーソルで読み、表に書き加える。

| 見る所 | シミュレーション・計算値 | 実機 (測って書く) |
| --- | --- | --- |
| SCL の周期 | 52 µs (4 クロック × 13 µs) | |
| SCL の周波数 | 19.23 kHz (計算値) | |
| 1 回の通信 (START から STOP) | 2.457 ms | |
| 読み出しの間隔 | 0.5 s | |
| 送るアドレスのバイト | 0x90 (書き)、0x91 (読み) | |
| ACK (9 クロック目の SDA) | 3 か所とも 0 | |
| 2 バイトの値 (室温のとき) | 25 °C なら 0x19 0x00 の付近 | |
| 温度 (式で直す) | 室温 (温度計と ±2 °C 以内が目安) | |
| 指で触ったときの変化 | 数 °C 上がる (変換の間隔 100 ms で更新) | |
| SDA・SCL の High | 3.3 V (3.3 V ± 0.1 V の目安) | |
| SDA・SCL の Low | LM75 が 0.4 V 以下 (3 mA)、Pico 2 が 0.5 V 以下 | |
| SDA・SCL の立ち上がり時間 | 424 ns (計算値。C<sub>b</sub> = 50 pF と置いた) | |
| UART の 1 行 | `19 80` のような 16 進 + CR LF。約 14.7 ms | |

プルアップを外すと (R1 か R2 を抜くと) SDA か SCL が 1 に戻れず、アドレスの ACK が見えなくなって `ERR` になるはず
(実機で確かめる)。AD3 の Protocol の I2C が NACK を示す。

## シミュレーションでの確かめ

Verilator 5.042 で 7-5 のシミュレーション (`sim/05-i2c-master-temperature*.v` と `sim/01-uart-tx.v`) を走らせ、
`EDGE` と `TXD` の行を図と突き合わせた。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| 図3 の SCL・SDA の変わり目 | START (0 µs) から STOP (2457 µs) まで | 時刻・値とも同じ (SCL 97 個、SDA 25 個) | 合った |
| 図4 の TXD の変わり目 | 2496 µs から 17004 µs まで | 同じ | 合った |
| 立ち上がり時間 | 424 ns (R = 10 kΩ、C<sub>b</sub> = 50 pF) | 0.8473 × 10 kΩ × 50 pF = 423.7 ns | 合った |

LM75 の実物の応答、SDA の向き替え (GPIO) と電圧の値は、実機が要るので確かめていない。

## 出典

自作。LM75B の電圧・プルアップの値は Texas Instruments
[LM75B, LM75C データシート (SNIS153D、2015-10)](https://www.ti.com/lit/ds/symlink/lm75b.pdf) の表と本文から読んだ。
プルアップの式は [SLVA689 I2C Bus Pullup Resistor Calculation](https://www.ti.com/lit/an/slva689/slva689.pdf)。
Pico 2 (RP2350) の入出力電圧は [RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) の 14.9.4。
AD3 の Protocol の使い方は Digilent の
[Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer)。
LM75 を AD3 から叩く題は 02-analog-discovery/07-logic/04-i2c-temperature.md (5 V、AD3 がマスタ)。
