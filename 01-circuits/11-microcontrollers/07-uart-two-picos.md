---
book: circuits
chapter: 11
id: 11-7
title: UART — Pico 2 台で通信
tier: 200
source: 自作
era: 今
---

# 11-7 UART — Pico 2 台で通信

UART は、送る線 (TX) と受ける線 (RX) の 2 本で字をやり取りする、いちばん古くからある通信の形。クロックの線は無く、
送る側と受ける側が**同じ速さ (ボーレート)** を前もって決めておく。線は休みの間 H で、1 字を送るたびに
スタートビット (L) → データ 8 ビット (下位ビットから) → ストップビット (H) の 10 ビットを流す。
ここでは Pico 2 を 2 台並べ、TX と RX をたすき掛けにつないで、1 秒ごとに数字を送り合う。2 台とも同じプログラムで動く。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Pico 2 を 2 台、UART0 でたすき掛けにつなぐ
parts:
  A: pico2 3,4 mirror
  B: pico2 13,4
  R1: resistor 5.5,1.75 7,1.75 1k
  R2: resistor 10.5,1.25 9,1.25 1k
  G1: ground 8,2.75
wires:
  - A.GP0 -- 5.5,1.75
  - 7,1.75 -- 8.5,1.75 -- 8.5,2
  - B.GP1 -| 8.5,2
  - B.GP0 -| 11,1.75
  - 11,1.75 -- 11,1.25 -- 10.5,1.25
  - 9,1.25 -- 4.5,1.25 -- 4.5,2
  - A.GP1 -| 4.5,2
  - A.GND3 -| 8,2.25
  - B.GND3 -| 8,2.25
  - 8,2.25 -- 8,2.75
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/07-uart-two-picos.svg)

- A の GP0 (UART0 の TX) を R1 を通して B の GP1 (UART0 の RX) へ、B の GP0 を R2 を通して A の GP1 へ。**TX は相手の RX へ**つなぐ
  (TX どうしをつなぐと、出力どうしがぶつかって何も届かない)
- GND は必ず 2 台でつなぐ。電圧は GND との差なので、GND が別々だと相手の H・L が読めない
- 電源 (3V3・VBUS) は**つながない**。2 台ともそれぞれの USB から給電する。3V3 どうしをつなぐと、2 台のレギュレータが互いに押し合う
- R1・R2 (1 kΩ (オーム)) は保護の抵抗。TX どうしをつなぎ違えて H と L の出力がぶつかっても、電流は 3 mA ほどに収まる (直結なら 40 mA 近く。下の LTspice)。
  9600 bps の通信には影響しない
- 片方の電源を切っても、Pico 2 (RP2350) の GPIO は電源が無いときにほとんど電流を通さない (データシートの「3.3 V-failsafe (unpowered)」)。
  入力に保護ダイオードを持つほかのマイコンにつなぐときは、R1・R2 がそのダイオードの電流も絞る

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 Pico 2 を 2 台並べる (どちらも USB で給電。つなぐのは信号 2 本と GND だけ)
board: full
parts:
  A: pico2 @ h5
  B: pico2 @ h40
  R1: resistor j27 j31 1k
  R2: resistor f33 f29 1k
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 2+, 1-, 2-]
wires:
  - A.GND38 -- -t7 black
  - B.GND38 -- -t42 black
  - A.GP0 -- i27 yellow
  - i31 -- B.GP1 yellow
  - B.GP0 -- h33 green
  - h29 -- A.GP1 green
  - SC.1+ -- g27 orange
  - SC.2+ -- g31 yellow
  - SC.1- -- -b36 black
  - SC.2- -- -b37 black
  - -t62 -- -b62 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/breadboard/07-uart-two-picos.svg)

- A (左) は h5、B (右) は h40 に挿す。どちらも上の列の 7 列目 (A は 7 列、B は 42 列) の `GND` を上の − レールへ。これで 2 台の GND がつながる
- A の GP0 (5 列の下) を黄の線で 27 列へ運び、R1 (27〜31 列、j 行) を通して 31 列から B の GP1 (41 列の下) へ
- B の GP0 (40 列の下) を緑の線で 33 列へ運び、R2 (33〜29 列、f 行) を通して 29 列から A の GP1 (6 列の下) へ
- AD3 は電源に使わず、Scope だけをつなぐ。1+ を R1 の A の側 (27 列の `g27`)、2+ を R1 の B の側 (31 列の `g31`) へ、1−・2− を下の − レールへ。
  下の − レールは右端の線で上の − レールとつなぐ
- ブレッドボードを流れる電流は、RX の入力が引く分だけでほぼ 0 (µA (マイクロアンペア) 以下)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| A・B | マイコン | Raspberry Pi Pico 2 × 2 (どちらも USB で給電) |
| R1・R2 | 抵抗 (保護) | 1 kΩ |
| — | 計器 | Analog Discovery 3 の Scope (1+ = A の TX、2+ = B の RX、1−・2− = GND) |

## 計器の設定

計器は AD3 のオシロ (Scope)。A が送る 1 字「3」(0x33) の 10 ビットを 1 画面に入れる。9600 bps の 1 ビットは 1/9600 s = 104.2 µs (マイクロ秒)。
ロジックアナライザでも見られるが、R1 の両側で電圧の形が同じことを見たいので Scope にした。

| 項目 | 値 |
| --- | --- |
| 電源 | 2 台とも USB (AD3 の Supplies は使わない) |
| CH1 (1+) | A の TX (R1 の A の側)。1 V/div、0 V を中央の半目盛上 |
| CH2 (2+) | B の RX (R1 の B の側)。1 V/div、0 V を下から半目盛 |
| 時間レンジ | 100 µs/div (1 画面 1 ms) |
| トリガ | CH1 の立ち下がり、1.65 V、Normal。トリガの点を左から半目盛に置く (スタートビットの始まり) |
| カーソル | X1 を 156 µs (データの 1 ビット目の真ん中)、X2 を 365 µs (3 ビット目の真ん中) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 「3」(0x33) の 1 字 — A の TX (CH1) と B の RX (CH2)
time: 100us/div
trigger: ch1 falling 1.65V at -4.5div
ch1: {wave: = 3.3V - 3.3V * step(t) + 3.3V * (step(t - 104.17us) - step(t - 312.5us) + step(t - 520.83us) - step(t - 729.17us) + step(t - 937.5us)), range: 1V/div, position: 0.5div}
ch2: {wave: ch1 | delay 50ns, range: 1V/div, position: -3.5div}
cursors: [156us, 365us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/scope/07-uart-two-picos.svg)

- 休みは H (3.3 V)。t = 0 で L に落ちるのがスタートビット。そのあと 104.2 µs ごとに 1 ビットずつ、**下位ビットから** 1・1・0・0・1・1・0・0 が並ぶ。
  逆に読むと 0011 0011 = 0x33 (字の「3」)。937.5 µs からがストップビット (H) で、続けて改行 (0x0A) が来る
- X1 (156 µs) は 3.3 V (1 ビット目 = 1)、X2 (365 µs) は 0 V (3 ビット目 = 0)。受ける側もビットの真ん中あたりで値を読む
- CH2 は R1 (1 kΩ) と RX の入力の容量 (仮定 20 pF) で縁がなまるが、なまりは 50 ns ほどで、1 ビット 104 µs の 0.05 % しかない。図では CH1 を 50 ns 遅らせて描いたが、CH1 と同じ形に見える

## プログラム

2 台に同じプログラムを書き込む。1 秒ごとに 0〜9 の数字と改行を UART0 へ送り、届いた字はそのまま USB シリアル (PC の画面) へ写す。

### C/C++ (Pico SDK)

```c
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/uart.h"

#define UART_ID uart0
#define BAUD    9600
#define PIN_TX  0
#define PIN_RX  1

int main(void) {
    stdio_init_all();                                  // printf は USB シリアルへ
    uart_init(UART_ID, BAUD);
    uart_set_format(UART_ID, 8, 1, UART_PARITY_NONE);  // 8 ビット・ストップ 1・パリティなし
    gpio_set_function(PIN_TX, GPIO_FUNC_UART);
    gpio_set_function(PIN_RX, GPIO_FUNC_UART);

    uint64_t next = time_us_64();
    unsigned n = 0;
    while (true) {
        if (time_us_64() >= next) {                    // 1 秒ごとに 1 行送る
            char line[8];
            snprintf(line, sizeof line, "%u\n", n % 10);
            uart_puts(UART_ID, line);
            n++;
            next += 1000000;
        }
        while (uart_is_readable(UART_ID)) {            // 届いた字は USB シリアルへ写す
            printf("%c", uart_getc(UART_ID));
        }
        tight_loop_contents();
    }
}
```

- 送るのを `sleep_ms(1000)` で待たないのは、待っている間も相手の字を受けるため。時刻 `next` を過ぎたら送り、それ以外は受けた字を見る
- `CMakeLists.txt` は 11-2 と同じ形で、名前を `uart2` にし、`target_link_libraries` を `pico_stdlib hardware_uart` にする。
  **`pico_enable_stdio_uart(uart2 0)` を必ず書く**。1 のままだと printf の出力も GP0 の UART0 へ出て、相手に届いてしまう

### MicroPython

```python
from machine import UART, Pin
import time

uart = UART(0, baudrate=9600, bits=8, parity=None, stop=1, tx=Pin(0), rx=Pin(1))
n = 0
next_ms = time.ticks_ms()
while True:
    if time.ticks_diff(time.ticks_ms(), next_ms) >= 0:   # 1 秒ごとに 1 行送る
        uart.write(str(n % 10).encode() + b"\n")
        n += 1
        next_ms = time.ticks_add(next_ms, 1000)
    if uart.any():                                       # 届いた字は Thonny の画面へ
        print(uart.read(uart.any()).decode(), end="")
    time.sleep_ms(1)
```

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| A の PC の画面 | B が送る 0・1・2・… が 1 秒ごとに 1 行ずつ出る (逆も同じ) |
| 1 ビットの幅 | 104.2 µs (1/9600 s) |
| 1 字の長さ | 1.04 ms (10 ビット) |
| TX どうしを誤ってつないだときの電流 | 約 3 mA (R1 の両端の電圧 ÷ 1 kΩ、計算値) |

字化けするときは、2 台のボーレートが違うか、GND がつながっていない。何も出ないときは TX と RX の取り違え (TX どうし) を疑う。

## LTspice での確かめ

`sim/07-uart-two-picos.cir` で、A の TX → R1 → B の RX を解いた。GPIO は 3.3 V の源と 40 Ω の内部抵抗 (仮定)、RX の入力は 20 pF (仮定)、
TX どうしのぶつかりは、H を出す側と L を出す側をどちらも 40 Ω の内部抵抗で置いた。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| RX の立ち上がり (10 %→90 %) | 50 ns ほど | 46 ns | 合う |
| TX どうしがぶつかったときの電流 (R1 あり) | 約 3 mA | 3.06 mA | 合う |
| 同 (直結) | 40 mA 近く | 41.2 mA | 合う (GPIO の出力の設定 4 mA をはるかに超える。R1 を入れる理由) |

1 ビットの幅と 1 字の長さは算術で確かめた (1/9600 = 104.17 µs、10 ビットで 1.042 ms)。「3」= 0x33 = 0011 0011 を下位ビットから並べると 1100 1100 で、図3 と同じ。

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| UART の設定 | UART0 を 9600 bps・8N1。GP0 = TX・GP1 = RX | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 送る字 | 「0」「改行」「1」「改行」… を 1 s ごとに | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 受けた字 | 相手の「7」「改行」を USB シリアルへそのまま写す | C: Pico SDK のモック・MicroPython: `machine` のスタブ |

見ていない物: 2 台の間の実際の波形・ボーレートの誤差・保護ダイオードの電流

## 出典

自作。

参考: [Pico SDK (hardware_uart)](https://github.com/raspberrypi/pico-sdk)、[UART (Wikipedia)](https://ja.wikipedia.org/wiki/UART)、[RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf)
