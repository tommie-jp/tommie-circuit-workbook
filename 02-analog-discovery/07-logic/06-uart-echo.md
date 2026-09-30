---
book: analog-discovery
chapter: 7
id: 7-6
title: プロトコルアナライザから送信する
tier: 100
source: 自作 (計器の操作は Digilent の Using the Protocol Analyzer)
board: BB
---

# 7-6 プロトコルアナライザから送信する

**Protocol** はここまで、7-3 では受信だけ、7-4 の I2C・7-5 の SPI ではバスの
マスタとしてアドレスやコマンドを送ってきた。実は 7-4・7-5 でも Protocol は
自分から送信していたが、狙いは返ってくる値を読むことだった。UART は 1 対 1 の
線なので、**送ること自体が目的**になる場面がある (GPS モジュールにコマンドを
打つ、Bluetooth モジュールを設定する、など)。ここでは Protocol の UART モードで
実際に 1 バイト送信し、Pico 2 がそれを受けて 1 を足して送り返す様子を、TX・RX
両方を同時に捕まえて確かめる。

## 回路図

```circuit
title: 図1 AD3 から Pico 2 へ送り、返信を受ける
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [GND, DIO0, DIO1]
  MCU: pico2 c5
wires:
  - AD.DIO0 -| MCU.GP0
  - AD.DIO1 -| MCU.GP1
  - AD.GND -| MCU.GND3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/06-uart-echo.svg)

- Pico 2 の **GP0 (UART0 TX)** を AD の DIO0 (Protocol の RX) へ、**GP1
  (UART0 RX)** を DIO1 (Protocol の TX) へつなぐ。7-3 は受信専用だったので
  GP1 (Pico 2 側の受信) は使っていなかった
- Pico 2 は USB で給電する (この図には描かない)。GND は直接線でも渡す (7-3 と
  同じ理由)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  MCU: pico2 @ h5
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [DIO0, DIO1, GND]
wires:
  - AD.DIO0 -- j5 yellow
  - AD.DIO1 -- j6 white
  - AD.GND -- j7 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/06-uart-echo.svg)

- `pico2 @ h5` は 7-3 と同じ向き (USB を左に)。下の行 (h) の左端が GP0 (h5)、
  2 番目が GP1 (h6)、3 番目が GND (h7)
- 配線は基板自身が使っている h 行の穴を避け、**同じ列の空いた j 行**から取る
  (7-3 と同じやり方)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Protocol | UART、**TX = DIO1**、**RX = DIO0**、Baud = 115200、8N1。送信欄に `0x41` (`'A'`) を 1 バイト入力して Write |

Pico 2 側は GP1 (UART0 RX) で受けた 1 バイトに 1 を足し、GP0 (UART0 TX) から送り返すだけの
簡単なプログラムを常駐させておく (下の「Pico 2 のプログラム」)。

## Pico 2 のプログラム

プログラムは **C/C++ (Pico SDK) を第 1、MicroPython を第 2** として並べる (どちらも同じ動き)。
Pico 2 (RP2350) の UART0 は、既定の TX = GP0・RX = GP1。

### C/C++ (Pico SDK)

`main.c` (UART0 で 1 バイト受けて、1 を足して送り返す)。

```c
#include "pico/stdlib.h"
#include "hardware/uart.h"

#define UART_ID uart0
#define BAUD_RATE 115200
#define UART_TX_PIN 0
#define UART_RX_PIN 1

int main(void) {
    uart_init(UART_ID, BAUD_RATE);
    gpio_set_function(UART_TX_PIN, GPIO_FUNC_UART);
    gpio_set_function(UART_RX_PIN, GPIO_FUNC_UART);
    uart_set_format(UART_ID, 8, 1, UART_PARITY_NONE);  // 8N1

    while (true) {
        uint8_t c = (uint8_t)uart_getc(UART_ID);   // 1 バイト来るまで待つ
        uart_putc_raw(UART_ID, (char)(c + 1));     // +1 して送り返す (0xFF は 0x00 に戻る)
    }
}
```

同じフォルダに `pico_sdk_import.cmake` (SDK の `external/` にあるものをコピーする) と
`CMakeLists.txt` を置く。

```cmake
cmake_minimum_required(VERSION 3.13)
set(PICO_BOARD pico2 CACHE STRING "Board type")
include(pico_sdk_import.cmake)
project(uart_echo C CXX ASM)
pico_sdk_init()
add_executable(uart_echo main.c)
target_link_libraries(uart_echo pico_stdlib hardware_uart)
pico_add_extra_outputs(uart_echo)
```

`PICO_SDK_PATH` に SDK のフォルダを指して、`cmake -B build -DPICO_BOARD=pico2` と
`cmake --build build` でビルドする。`build/uart_echo.uf2` ができるので、
**BOOTSEL ボタンを押しながら USB をつなぐ**と出てくる USB ドライブ (ボリューム名は
既定で `RP2350`) にコピーして書き込む。`PICO_BOARD=pico2` を付け忘れると Pico (RP2040) 用に
なり、Pico 2 では動かない。

### MicroPython

Pico 2 用の MicroPython (`RPI_PICO2`) の `.uf2` を入れ、Thonny で実行する。

```python
from machine import UART, Pin

uart = UART(0, baudrate=115200, tx=Pin(0), rx=Pin(1))   # 8N1 が既定

while True:
    data = uart.read(1)   # 何も来ていなければ None
    if data:
        uart.write(bytes([(data[0] + 1) & 0xFF]))   # +1 (0xFF は 0x00 に戻る)
```

C/C++ のプログラムは、この環境で `PICO_BOARD=pico2` の `.uf2` までビルドが通ることを確かめた。
**実機では動かしていない。** MicroPython は実行していない (未確認)。

## 見るべき値

計算値。115200 bps では 1 ビット = 1/115200 s (7-3 と同じ)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| DIO1 (Protocol の TX) の解読結果 | `0x41` (`'A'`) | 打ち込んだとおりに送信できている |
| DIO0 (Protocol の RX) の解読結果 | `0x42` (`'B'`) | Pico 2 が受けて +1 して送り返した |
| 1 フレームの時間 (start + 8 data + stop) | 86.8 µs (10 ビット) | 7-3 と同じボーレートなので同じ値 |
| 送信から応答までの遅れ | 目安、実測でしか分からない (ハードの伝送時間ではなく Pico 2 のソフト処理時間で決まる) | 配線・ボーレートとは別に、応答の速さは相手のプログラム次第 |

**送信側 (DIO1) と受信側 (DIO0) を同時に Enable すれば、Protocol の解読結果に
TX と RX が並んで表示され、送った文字と返ってきた文字を一度に見比べられる。**
7-4・7-5 のときは「読めた値」だけを見ていたが、UART では送った側の波形も
同じように解読して確かめられる。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer)
(UART の節。送信 (Write) の機能を使う)。
