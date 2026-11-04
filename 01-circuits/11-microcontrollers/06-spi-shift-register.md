---
book: circuits
chapter: 11
id: 11-6
title: SPI (シフトレジスタ / 表示)
tier: 200
source: 自作
era: 今
---

# 11-6 SPI (シフトレジスタ / 表示)

7 セグメント LED (7 セグ) を点けるには、セグメント 7 本ぶんの出力が要る。マイコンのピンを 7 本使う代わりに、
シフトレジスタ 74HC595 に 1 ビットずつ送り込み、8 本の並列の出力に直してもらう。1 ビットずつ送る線の決まりが SPI で、
クロック (SCK) の立ち上がりごとにデータの線 (MOSI) の 0/1 を 1 ビット読む。Pico 2 は SPI の回路を持っていて、
1 バイトを書けば 8 回のクロックとデータを自分で出す。ここでは SPI0 で 1 バイト送り、ラッチの線を 1 回上げて、
0〜9 を 0.5 秒ごとに数える。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 SPI0 で 74HC595 に 1 バイト送り、7 セグを点ける
parts:
  U1: pico2 3,5 mirror
  P3V3: vcc 1.5,2.5 3.3V
  G4: ground 4.5,7.5
  U2: ic 9,5 74HC595
  P3V3: vcc 9,1 3.3V
  C1: capacitor 7.5,1.5 7.5,2.5 100n
  G0: ground 7.5,2.5
  G1: ground 9,7.75
  G2: ground 9.5,7.75
  Ra: resistor 11,3 12.5,3 l=$R_a$
  Rb: resistor 11,3.5 12.5,3.5 l=$R_b$
  Rc: resistor 11,4 12.5,4 l=$R_c$
  Rd: resistor 11,4.5 12.5,4.5 l=$R_d$
  Re: resistor 11,5 12.5,5 l=$R_e$
  Rf: resistor 11,5.5 12.5,5.5 l=$R_f$
  Rg: resistor 11,6 12.5,6 l=$R_g$
  DS1:
    type: device
    at: 17,5
    label: 5161AS
    pins: [e, g, f, a, b, c, d, COM]
  G3: ground 15.5,7
wires:
  - U1.3V3 -| 1.5,2.5
  - U1.GND18 -| 4.5,7.5
  - U2.QA -| 11,3
  - U2.QB -| 11,3.5
  - U2.QC -| 11,4
  - U2.QD -| 11,4.5
  - U2.QE -| 11,5
  - U2.QF -| 11,5.5
  - U2.QG -| 11,6
  - 12.5,3 -- 15.25,3 -- 15.25,4.25 -- DS1.e
  - 12.5,3.5 -- 15,3.5 -- 15,4.5 -- DS1.g
  - 12.5,4 -- 14.75,4 -- 14.75,4.75 -- DS1.f
  - 12.5,4.5 -- 14.5,4.5 -- 14.5,5 -- DS1.a
  - 12.5,5 -- 14.25,5 -- 14.25,5.25 -- DS1.b
  - 12.5,5.5 -- DS1.c
  - 12.5,6 -- 14.25,6 -- 14.25,5.75 -- DS1.d
  - DS1.COM -| 15.5,7
  - U2.VCC |- 9,1.5
  - 9,1.5 -- 9,1
  - 7.5,1.5 -- 9,1.5
  - U2.SRCLR |- 9.5,1.5
  - 9,1.5 -- 9.5,1.5
  - U2.GND |- 9,7.75
  - U2.OE |- 9.5,7.75
  - U1.GP3 -- 7,3.75 -- 7,4.5
  - U2.SER -| 7,4.5
  - U1.GP6 -- 6.5,4.75 -- 6.5,5
  - U2.SRCLK -| 6.5,5
  - U1.GP7 -- 6,5 -- 6,5.5
  - U2.RCLK -| 6,5.5
notes:
  - text 11.75,6.6: Ra-Rg はどれも 470Ω
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/06-spi-shift-register.svg)

- Pico 2 の GP3 (SPI0 の TX = MOSI) を 74HC595 の SER (14 番)、GP6 (SPI0 の SCK) を SRCLK (11 番) につなぐ。SRCLK の立ち上がりで、
  SER の値が 1 段目に入り、それまでの中身が 1 段ずつ奥へずれる。8 回で 1 バイトが QA〜QH に並ぶ
- GP7 は普通の GPIO で、RCLK (12 番) につなぐ。RCLK の立ち上がりで、ずらし終えた 8 ビットを出力 QA〜QH へ写す (ラッチ)。
  ずらしている途中の値は出力に出ないので、表示がちらつかない
- 74HC595 は Pico 2 の 3V3 (3.3 V) で動かす。5 V で動かすと、入力の H の下限が 0.7 × 5 V = 3.5 V になり、Pico 2 の 3.3 V の出力では
  確実に H と読まれない (10-1 の CMOS の入力の電圧)。3.3 V なら下限は 2.31 V で足りる
- OE (13 番、L で出力を出す) は GND、SRCLR (10 番、L で中身を消す) は 3.3 V に固定する。C1 (0.1 µF (マイクロファラド)) は VCC と GND の間のデカップリング (11-12)
- 7 セグはカソードコモン (COM を GND) の 5161AS。出力からセグメントへ 470 Ω (オーム) を 1 本ずつ入れる。**どの出力をどのセグメントにつなぐかは、
  図2 で配線が短くなる順に決めた** (QA = e、QB = g、QC = f、QD = a、QE = b、QF = c、QG = d)。どのビットがどのセグメントかはプログラムの表が受け持つ。
  QH と小数点 (dp) は使わない

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (74HC595 は向きを逆に挿す。AD3 は Scope だけ)
board: full
parts:
  MCU: pico2 @ h5
  U1: dip16 @ e30 r180 74HC595
  C1: capacitor i34 i37 100n
  DS1: seg7 @ e44
  Re: resistor a34 a48 470 cap=above
  Rd: resistor b35 b47 470 cap=left
  Rc: resistor c36 c45 470 cap=left
  Rb: resistor d37 d44 470 cap=left
  Ra: resistor j36 j44 470
  Rg: resistor e51 f51 470
  Rf: resistor e52 f52 470
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [2+, 1+, 1-, 2-]
wires:
  - MCU.3V3 -- +t9 red
  - MCU.GND38 -- -t7 black
  - -t62 -- -b62 black
  - +t63 -- +b63 red
  - a30 -- -t30 black
  - j37 -- +b37 red
  - j31 -- +b31 red
  - j34 -- -b34 black
  - MCU.GP3 -- h35 yellow
  - MCU.GP6 -- g32 green
  - MCU.GP7 -- h33 blue
  - a32 -- a51 white
  - a33 -- a52 orange
  - j51 -- j45 white
  - j52 -- j47 orange
  - j46 -- -b46 black
  - SC.1+ -- j13 green
  - SC.2+ -- j9 yellow
  - SC.1- -- -b17 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/breadboard/06-spi-shift-register.svg)

- Pico 2 の `3V3` (9 列の上) を上の + レールへ、`GND` (7 列の上) を上の − レールへ。上下のレールは右端 (62・63 列) でつなぐ
- 74HC595 (U1) は**切り欠きを右にして** e30 に挿す (`r180`)。上の列が左から 8 番 (GND)・QH・QG・QF・QE・QD・QC・QB、
  下の列が左から 9 番 (QH')・SRCLR・SRCLK・RCLK・OE・SER・QA・16 番 (VCC)。こうすると出力の 7 本のうち 6 本が上のブロックに並ぶ。
  GND (30 列) は − レールへ、VCC (37 列)・SRCLR (31 列) は下の + レールへ、OE (34 列) は下の − レールへ。C1 は VCC の 37 列と OE (= GND) の 34 列の間
- 上のブロックの 4 本は、470 Ω を出力の列から 7 セグの上のピンの列へ直に渡す (a〜d 行に 1 本ずつ)。Re (a 行) が QE → b、Rd (b 行) が QD → a、
  Rc (c 行) が QC → f、Rb (d 行) が QB → g。QA (36 列の下) は j 行の Ra で 7 セグの e (44 列の下) へ
- QG (32 列) と QF (33 列) は白と橙の線で 51・52 列へ運び、溝をまたいで挿した Rg・Rf を通して、下のブロックから 7 セグの d (45 列)・c (47 列) へ戻す
- 7 セグ (DS1) は e44 に挿す。上のピンは左から g・f・COM・a・b、下のピンは左から e・d・COM・c・dp。下の COM (46 列) を − レールへ
- SPI の 3 本は Pico 2 の下の列から出す: GP3 (9 列) を SER (35 列)、GP6 (13 列) を SRCLK (32 列)、GP7 (14 列) を RCLK (33 列) へ
- AD3 は電源に使わず、Scope だけをつなぐ。1+ を SCK (13 列の `j13`)、2+ を MOSI (9 列の `j9`) へ、1−・2− を下の − レールへ
- ブレッドボードを流れる電流は、7 セグ全部 (数字の 8) で 7 × 2.5 mA ≈ 17 mA ほど (下の LTspice)。ブレッドボードの範囲に収まり、Pico 2 の 3V3 の出力 (300 mA まで) にも余裕がある

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | マイコン | Raspberry Pi Pico 2 (USB で給電) |
| U2 (図2 では U1) | シフトレジスタ | 74HC595 (3.3 V で使う) |
| DS1 | 7 セグメント LED | 5161AS (赤・カソードコモン) |
| Ra〜Rg | 抵抗 | 470 Ω × 7 |
| C1 | セラミックコンデンサ | 0.1 µF (104) |
| — | 計器 | Analog Discovery 3 の Scope (1+ = SCK、2+ = MOSI、1−・2− = GND) |

## 計器の設定

計器は AD3 のオシロ (Scope)。1 MHz の SPI の 1 バイト (8 µs (マイクロ秒)) を画面に入れ、**SCK の立ち上がりで MOSI が読まれる**のを見る。
見せるのは数字の 3 (0x7A = 0111 1010) を送る所。

| 項目 | 値 |
| --- | --- |
| 電源 | Pico 2 の USB (AD3 の Supplies は使わない) |
| CH1 (1+) | SCK (GP6)。1 V/div、0 V を中央の半目盛上 (画面の上半分) |
| CH2 (2+) | MOSI (GP3)。1 V/div、0 V を下から半目盛 (画面の下半分) |
| 時間レンジ | 1 µs/div |
| トリガ | CH1 の立ち上がり、1.65 V、Single。トリガの点を左から 1 目盛に置く |
| カーソル | X1 を 1.25 µs、X2 を 5.25 µs (2 ビット目と 6 ビット目の SCK が H の間) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 数字の 3 (0x7A) を送る 1 バイト — SCK (CH1) と MOSI (CH2)
time: 1us/div
trigger: ch1 rising 1.65V at -4div
ch1: {wave: = 3.3V * step(sin(2 * pi * 1MHz * t)) * step(t) * step(7.75us - t), range: 1V/div, position: 0.5div}
ch2: {wave: = 3.3V * (step(t - 0.5us) - step(t - 4.5us) + step(t - 5.5us) - step(t - 6.5us)), range: 1V/div, position: -3.5div}
cursors: [1.25us, 5.25us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/scope/06-spi-shift-register.svg)

- SCK は 0 µs・1 µs・…・7 µs に 8 回立ち上がる (1 MHz)。MOSI は SCK の立ち下がりで次のビットに変わり、立ち上がりの時刻には落ち着いている (SPI のモード 0)
- 立ち上がりで読まれる値は上位ビットから 0・1・1・1・1・0・1・0。最初のビットが 8 回ずれて QH に、最後のビットが QA に入る
- X1 (1.25 µs) の MOSI は 3.3 V (2 ビット目 = 1)、X2 (5.25 µs) は 0 V (6 ビット目 = 0)。図は理想の形で、実物の縁はブレッドボードの容量で数十 ns なまる (目安)

## プログラム

### C/C++ (Pico SDK)

`main.c` (0〜9 を 0.5 秒ごとに表示する)。

```c
#include "pico/stdlib.h"
#include "hardware/spi.h"

#define PIN_MOSI  3   // SPI0 TX → 74HC595 の SER
#define PIN_SCK   6   // SPI0 SCK → SRCLK
#define PIN_LATCH 7   // GPIO → RCLK

// bit0 = QA = e, bit1 = QB = g, bit2 = QC = f, bit3 = QD = a,
// bit4 = QE = b, bit5 = QF = c, bit6 = QG = d (図2 の配線の順)
static const uint8_t DIGITS[10] = {
    0x7D, 0x30, 0x5B, 0x7A, 0x36, 0x6E, 0x6F, 0x38, 0x7F, 0x7E};

static void show(uint8_t pattern) {
    spi_write_blocking(spi0, &pattern, 1);   // 8 クロックで 1 バイトをずらし込む
    gpio_put(PIN_LATCH, 1);                  // RCLK の立ち上がりで出力へ写す
    sleep_us(1);
    gpio_put(PIN_LATCH, 0);
}

int main(void) {
    spi_init(spi0, 1000 * 1000);             // 1 MHz
    spi_set_format(spi0, 8, SPI_CPOL_0, SPI_CPHA_0, SPI_MSB_FIRST);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);
    gpio_set_function(PIN_SCK, GPIO_FUNC_SPI);
    gpio_init(PIN_LATCH);
    gpio_set_dir(PIN_LATCH, GPIO_OUT);
    gpio_put(PIN_LATCH, 0);

    for (int n = 0;; n = (n + 1) % 10) {
        show(DIGITS[n]);
        sleep_ms(500);
    }
}
```

- `spi_set_format(spi0, 8, SPI_CPOL_0, SPI_CPHA_0, SPI_MSB_FIRST)` が、8 ビット・SCK の休みは L・立ち上がりで読む・上位ビットから、の決まり (モード 0)。74HC595 はこの形で読む
- 表 `DIGITS` は「点けるセグメントのビットを 1」にした値。例えば 3 は a・b・c・d・g で、bit3・4・5・6・1 が 1 の 0x7A
- `CMakeLists.txt` は 11-2 と同じ形で、名前を `spi7seg` にし、`target_link_libraries` を `pico_stdlib hardware_spi` にする

### MicroPython

```python
from machine import Pin, SPI
import time

spi = SPI(0, baudrate=1_000_000, polarity=0, phase=0, bits=8, firstbit=SPI.MSB,
          sck=Pin(6), mosi=Pin(3), miso=Pin(4))
latch = Pin(7, Pin.OUT, value=0)
DIGITS = bytes([0x7D, 0x30, 0x5B, 0x7A, 0x36, 0x6E, 0x6F, 0x38, 0x7F, 0x7E])

def show(pattern):
    spi.write(bytes([pattern]))
    latch.value(1)    # RCLK の立ち上がりで出力へ写す
    latch.value(0)

n = 0
while True:
    show(DIGITS[n])
    n = (n + 1) % 10
    time.sleep(0.5)
```

`miso=Pin(4)` は使わないが、指定しないと既定のピン (GP16) が SPI に取られるので、空いている GP4 を書いておく。

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| 表示 | 0 → 1 → … → 9 → 0 と 0.5 秒ごとに変わる |
| SCK の周波数 | 1 MHz (8 回で 1 バイト、8 µs) |
| 1 セグメントの電流 | 約 2.6 mA (Ra の両端の電圧 ÷ 470 Ω、計算値) |
| 74HC595 の VCC の電流 (数字の 8) | 約 17 mA (7 本ぶん、計算値) |

表示がでたらめなら、QA〜QG とセグメントの対応 (図2) と表 `DIGITS` が食い違っている。全部消えたままなら、OE が GND か、SRCLR が 3.3 V かを見る。

## LTspice での確かめ

`sim/06-spi-shift-register.cir` で、出力 1 本 → 470 Ω → セグメント 1 本を解いた。74HC595 の出力は 3.3 V の源と 50 Ω の内部抵抗 (仮定)、
LED は 1-1 と同じ仮定のモデル。7 本点けたときは電源の線に 5 Ω (仮定) を入れた。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 1 セグメントの電流 | 約 2.6 mA | 2.62 mA (Vf 1.94 V) | 合う |
| 7 本点けたときの 1 本の電流 | 約 2.5 mA | 2.46 mA | 合う |
| 7 本の合計 | 約 17 mA | 17.3 mA | 合う |

SPI の並びは算術で確かめた。0x7A = 0111 1010 を上位ビットから送ると、8 回ずれたあと QA = 0 (e)、QB = 1 (g)、QC = 0 (f)、QD = 1 (a)、QE = 1 (b)、QF = 1 (c)、QG = 1 (d) で、
a・b・c・d・g が点く (数字の 3)。表の 10 個は全部この対応から計算した。

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| SPI の設定 | SPI0 を 1 MHz、8 ビット・モード 0・上位ビットから。GP3・GP6 を SPI に | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 送る並び | 0x7D, 0x30, 0x5B, 0x7A, … (0〜9) を順に 1 バイトずつ | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| ラッチ | 1 バイトごとに GP7 が 1 回上がる。間隔 0.5 s | C: Pico SDK のモック・MicroPython: `machine` のスタブ |

見ていない物: SCK と MOSI の実際の波形・74HC595 の動作・LED の明るさ

## 出典

自作。

参考: [TI SN74HC595 データシート](https://www.ti.com/lit/ds/symlink/sn74hc595.pdf)、[Pico SDK (hardware_spi)](https://github.com/raspberrypi/pico-sdk)、[シリアル・ペリフェラル・インタフェース (Wikipedia)](https://ja.wikipedia.org/wiki/シリアル・ペリフェラル・インタフェース)
