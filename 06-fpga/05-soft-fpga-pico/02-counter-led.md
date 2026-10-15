---
book: fpga
chapter: 5
id: 5-2
title: カウンタを Pico 2 で回して LED を点ける
tier: 50
source: 自作
board: BB
device: PICO
---

# 5-2 カウンタを Pico 2 で回して LED を点ける

> [!WARNING]
> **この題は実機で組んでいない。** `.uf2` のビルドと、同じ主ループを PC で回して数えるところまでを確かめた。
> Pico 2 に書き込んで点滅を測ってはいない。「見るべき値」の点滅の速さは、測って表に書く。

2-7 の `blink.v` は、クロックを `CLK_HZ` 回数えるごとに LED を 1 回点滅させる回路だった。
FPGA なら `CLK_HZ` にボードの水晶の周波数 (Tang Nano 9K なら 27 MHz) を入れれば、ちょうど 1 Hz になる。

Pico 2 の Soft-FPGA には水晶のようなクロックが無い。5-1 で見たとおり、主ループが 1 周するたびに 1 クロック進む。
1 周の時間は計算の量で決まり、書く前には分からない。この題では `CLK_HZ` に仮の値 100 000 を入れて動かし、
**点滅が 1 Hz にならないこと**を AD3 の Logic で確かめる。測った点滅の速さから、Pico 2 の上のクロックの周波数が逆算できる。

## 点滅の速さとクロックの関係

`blink.v` は HALF = `CLK_HZ` / 2 クロックごとに LED を反転する (`BLINK_HZ` = 1)。点滅の 1 周期は 2 × HALF = `CLK_HZ` クロック。
主ループの 1 周が 1 クロックなので、Pico 2 の上のクロックの周波数を f<sub>clk</sub> とすると次になる (計算値)。

```text
点滅の周波数 f_led = f_clk / CLK_HZ
f_clk = CLK_HZ x f_led = 100 000 x f_led
```

| 主ループ 1 周の時間 (仮に置いた値) | f<sub>clk</sub> | 点滅 (計算値) |
| --- | --- | --- |
| 10 µs (マイクロ秒) | 100 kHz | 1 Hz (`CLK_HZ` = 100 000 は、この場合にちょうど合う) |
| 5 µs | 200 kHz | 2 Hz |
| 20 µs | 50 kHz | 0.5 Hz |

1 周が何 µs かは、この表のどれとも決まっていない。測った f<sub>led</sub> から上の式で f<sub>clk</sub> を出す。

## 論理図と Verilog

回路は 2-7 の図1 (カウンタが HALF 回数えるたびに LED を反転する) と、2-7 の `blink.v` のまま。書き換えない。
Pico 2 で動かすときに変えるのは `CLK_HZ` だけで、Verilator に `-GCLK_HZ=100000` を渡して決める。

この題のビルドは 5-1 とまったく同じ。ファイル (`main.cpp`・`verilate.sh`・`CMakeLists.txt` ほか) も打つ物も、
[5-1 の「ファイル」と「ビルドする」](01-verilator-on-pico.md#ファイル)のとおり。
`verilate.sh` が `-GCLK_HZ=100000` を渡し、`main.cpp` は LED を GP14 に出す。5-1 で作った `build/blink_pico.uf2` (92 160 バイト) を Pico 2 に書けばよい。

### PC で主ループを数える

Pico 2 に書き込む前に、同じ `main.cpp` を PC で回した。Pico SDK の `gpio_init` `gpio_put` などを、
PC で動く替え玉 (書いた値と回数を覚えるだけの関数) に差し替え、Verilator の `--exe --build` で PC 用にビルドした。
`gpio_put` が呼ばれた回数が主ループの周回の数 (= クロックの数) になる。

```text
LED=1 at loop 50000 (50000 loops after previous)
LED=0 at loop 100000 (50000 loops after previous)
LED=1 at loop 150000 (50000 loops after previous)
LED=0 at loop 200000 (50000 loops after previous)
```

LED は 50 000 周ごとに反転し、点滅の 1 周期は 100 000 周 (= `CLK_HZ`) だった。上の式どおりである。
PC の上の 1 周の時間は Pico 2 とは違うので、ここでは周回の数だけを見る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 GP14 から 330 Ω と LED を通して GND へ
parts:
  MCU: pico2 9,3 mirror
  R1: resistor 12,5 14,5 330
  D1: led 14,5 14,7 red
  G1: ground 14,7
  G2: ground 6.5,1
wires:
  - MCU.GP14 -| 12,5
  - MCU.GND38 -| 6.5,1
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/02-counter-led.svg)

- Pico 2 の箱は左右を入れ替えて描いた (`mirror`)。GP14 (19 番) が右に来て、信号が左から右へ流れる
- LED の電流は (3.3 − 2.0) / 330 ≈ 3.9 mA (計算値。赤 LED の V<sub>F</sub> を 2.0 V と置いた)。0-3 と同じ
- 330 Ω (オーム) は E24 の値。電源は Pico 2 の USB から取る
- Pico 2 の GND (38 番) と LED の GND は同じ GND。実体配線図では − レールでつながる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 GP14 の LED を AD3 の Logic (DIO0) で見る
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor h26 h29 330
  D1: led f29(A) f30(K) red cap=above
  LOG:
    type: device
    at: bottom
    label: AD3 Logic
    pins: [DIO0, GND]
wires:
  - MCU.GND38 -- -t7 black
  - -t3 -- -b3 black
  - i23 -- i26 yellow
  - j30 -- -b30 black
  - LOG.DIO0 -- j26 yellow
  - LOG.GND -- -b34 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/breadboard/02-counter-led.svg)

- `pico2 @ h5` は 0-3・0-4 と同じ置き方。GP14 (19 番) は 23 列の h にある
- GP14 から i23 → i26 の黄の線で R1 (h26〜h29) へ。R1 の先が LED のアノード (f29)、カソード (f30) は j30 から下の − レールへ
- GND は Pico 2 の GND (38 番) から上の − レールへ。上下の − レールは 3 列の黒い線でつなぐ
- AD3 の DIO0 は、GP14 と同じ 26 列の j26 に挿す。LED の手前の、GP14 の電圧そのものを見る
- この配線は 5-3・5-4 のブレッドボードの左半分と同じ。5-3 ではここに LED をもう 1 つと DIP スイッチを足す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 を Enable。標本化 5 kS/s、500 ms/div から始める。点滅が速ければ time/div を細かくする |
| Logic のトリガ | DIO0 の立ち上がり |
| カーソル | X1・X2 を、隣り合う 2 つの H の真ん中に置く。ΔX が点滅の周期、1/ΔX が f<sub>led</sub> |

5 kS/s は、仮の値どおりの 1 Hz の 5000 倍で、点滅が 1 kHz まで速くても、標本化は点滅の 4 倍以上ある。
5 s の窓は 25 000 標本で、AD3 の 1 本 32 768 標本に収まる。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 仮の値どおりなら (1 クロック 10 µs) GP14 は 1 Hz で点滅する
device: ad3
time: 500ms/div
sample: 5kHz
signals:
  GP14: dio0 pattern 0101010101 bit 500ms
cursors: [750ms, 1750ms]
trigger: GP14 rising at 500ms
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/02-counter-led.svg)

図3 は、主ループの 1 周がちょうど 10 µs のときに見えるはずの画面で、**測った画面ではない**。
実機では周期が 1 s からずれる。ずれた量がこの題で見たいもの。

## 見るべき値

計算値と、測って書く欄。

| 測る所 | 見るべき値 | 分かること |
| --- | --- | --- |
| LED | 点滅する | `blink.v` が Pico 2 の上で動き、GP14 に出ている |
| LED の電流 | 約 3.9 mA (計算値) | GPIO 1 本の電流の目安に収まる |
| Logic の 1/ΔX (f<sub>led</sub>) | 測って書く (1 Hz とは限らない) | 仮の値の `CLK_HZ` では 1 Hz にならない |
| f<sub>clk</sub> = 100 000 × f<sub>led</sub> | 測った f<sub>led</sub> から計算して書く | Pico 2 の上で `blink.v` の 1 クロックが何 µs か (1 / f<sub>clk</sub>) |

`CLK_HZ` を測った f<sub>clk</sub> に書き直せば、点滅は 1 Hz に近づく。ただし、回路やプログラムを変えると 1 周の時間も変わる。
クロックをきちんと測る方法は 5-5、回路の大きさで変わる様子は 5-6、一定の間隔に固定する方法は 5-7 で扱う。

## シミュレーションでの確かめ (対象外を含む)

PC で回す確かめは手元の Verilator 5.042 で行った。`.uf2` の大きさは、本文の Docker でビルドし直した。主ループは本文の `main.cpp` (5-1) と同じ形で、
`gpio_put` の呼び出しを数える替え玉に差し替えて PC で回した (`sim/02-counter-led-pc.cpp`。替え玉の `pico/stdlib.h` は `sim/pcstub/`)。
`blink.v` は 2-7 のもの。ビルドの前提は 5-1 と同じ。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| LED の反転 (`CLK_HZ` = 100 000) | 50 000 周ごと、1 周期は 100 000 周 (4 行) | `LED=1 at loop 50000`、`0 at 100000`、`1 at 150000`、`0 at 200000` (各 50 000 周後) | 合った |
| 主ループの 1 周 10 µs のときの点滅 | 100 kHz → 1 Hz | 1 / (100 000 × 10 µs) = 1 Hz (計算) | 計算値として合った |
| 5 µs / 20 µs のとき | 2 Hz / 0.5 Hz | 200 kHz ÷ 100 000 = 2 Hz、50 kHz ÷ 100 000 = 0.5 Hz (計算) | 計算値として合った |
| LED の電流 | 約 3.9 mA | (3.3 − 2.0) ÷ 330 = 3.9 mA (計算) | 計算値として合った |
| `.uf2` の大きさ | 92 160 バイト (5-1 と同じ) | 92 160 バイト (5-1 と同じ) | 合った |

確かめられなかったもの。

- Pico 2 に書き込んだ LED の点滅と、AD3 での周期の測定 (実機)。「見るべき値」の測る欄は空のまま

## 出典

自作。`blink.v` は 2-7。Pico SDK でビルドする手は 5-1 と、5-1 が倣った
[tommie-jp/Soft-FPGA-Reversi](https://github.com/tommie-jp/Soft-FPGA-Reversi)。
Pico 2 のピン番号は Raspberry Pi の Pico 2 のピン配置図 ([Pico-2-Pinout.pdf](https://datasheets.raspberrypi.com/pico/Pico-2-Pinout.pdf))。
AD3 の Logic の使い方は 0-4。
