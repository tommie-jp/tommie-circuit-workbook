---
book: analog-discovery
chapter: 7
id: 7-3
title: UART を見る (Pico 2)
tier: 50
source: 自作 (計器の操作は Digilent の Using the Protocol Analyzer)
board: BB
---

# 7-3 UART を見る (Pico 2)

**Protocol** (プロトコルアナライザ) の UART モードで、Raspberry Pi Pico 2 が
UART0 (GP0) から送る文字を受けて解読する。Pico 2 には 1 秒ごとに `'U'` (0x55、
2 進で 01010101 — スタート・ストップビットを含めた波形が見やすい定番の
テスト文字) を送る簡単なプログラムを書き込んでおく。

## 回路図

```circuit
title: 図1 Pico 2 の UART0 を AD3 で受ける
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [GND, DIO0]
  MCU: pico2 c5
wires:
  - AD.DIO0 -| MCU.GP0
  - AD.GND -| MCU.GND3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/03-uart-pico.svg)

- Pico 2 の **GP0 (UART0 TX)** を AD の DIO0 (Protocol の RX) につなぐだけ。
  受けるだけなので AD からは何も送らない
- Pico 2 は USB で給電する (この図には描かない)。**GND は USB 経由でも AD と
  共通になる**が、ノイズを避けるため直接線でも渡す

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
    pins: [DIO0, GND]
wires:
  - AD.DIO0 -- j5 yellow
  - AD.GND -- j7 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/03-uart-pico.svg)

- `pico2 @ h5` は USB を左に向けた向き。**下の行 (h) の左端がピン 1 = GP0**
  (h5)、3 番目が GND (h7)
- 配線は基板自身が使っている h 行の穴を避け、**同じ列の空いた j 行**から取る
  (j5 = GP0 の列、j7 = GND の列)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Protocol | UART、RX = DIO0、Baud = 115200、8N1 (8 データビット・パリティ無し・ストップビット 1 ビット) |

Pico 2 側は同じ 115200 bps で `'U'` を 1 秒ごとに送るプログラムを動かしておく (下の「Pico 2 のプログラム」)。

## Pico 2 のプログラム

プログラムは **C/C++ (Pico SDK) を第 1、MicroPython を第 2** として並べる (どちらも同じ動き)。
Pico 2 (RP2350) の UART0 は、既定の TX = GP0・RX = GP1。

### C/C++ (Pico SDK)

`main.c` (0x55 (`'U'`) を 1 秒ごとに UART0 の TX (GP0) から送る)。

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
        uart_putc_raw(UART_ID, 'U');   // 0x55
        sleep_ms(1000);
    }
}
```

同じフォルダに `pico_sdk_import.cmake` (SDK の `external/` にあるものをコピーする) と
`CMakeLists.txt` を置く。

```cmake
cmake_minimum_required(VERSION 3.13)
set(PICO_BOARD pico2 CACHE STRING "Board type")
include(pico_sdk_import.cmake)
project(uart_send C CXX ASM)
pico_sdk_init()
add_executable(uart_send main.c)
target_link_libraries(uart_send pico_stdlib hardware_uart)
pico_add_extra_outputs(uart_send)
```

`PICO_SDK_PATH` に SDK のフォルダを指して、`cmake -B build -DPICO_BOARD=pico2` と
`cmake --build build` でビルドする。`build/uart_send.uf2` ができるので、
**BOOTSEL ボタンを押しながら USB をつなぐ**と出てくる USB ドライブ (ボリューム名は
既定で `RP2350`) にコピーして書き込む。`PICO_BOARD=pico2` を付け忘れると Pico (RP2040) 用に
なり、Pico 2 では動かない。

### MicroPython

Pico 2 用の MicroPython (`RPI_PICO2`) の `.uf2` を入れ、Thonny で実行する。

```python
from machine import UART, Pin
from time import sleep

uart = UART(0, baudrate=115200, tx=Pin(0), rx=Pin(1))   # 8N1 が既定

while True:
    uart.write(b'U')   # 0x55
    sleep(1)
```

C/C++ のプログラムは、この環境で `PICO_BOARD=pico2` の `.uf2` までビルドが通ることを確かめた。
**実機では動かしていない。** MicroPython は実行していない (未確認)。

`'U'` (0x55) の 1 フレームを DIO0 の電圧で描くと次のようになる。LSB から送るので、
スタートビット (L) の後は 1・0・1・0… と交互に並び、ストップビット (H) で終わる。

```scope
title: 図3 'U' の 1 フレームは 86.8 µs、1 ビットは 8.68 µs
time: 10us/div
trigger: ch1 falling 1.65V at -4div
ch1: {wave: = 3.3V * (1 - step(t) * step(78.125us - t) * step(sin(2 * pi * 57.6kHz * t))), range: 1V/div, position: -3div}
cursors: [0, 8.68us]
notes:
  - band 0 86.8us: 1 フレーム (10 ビット)
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/03-uart-pico.svg)

## 見るべき値

計算値。115200 bps では 1 ビット = 1/115200 s。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 1 ビットの時間 | 8.68 µs | ボーレートの逆数 |
| 1 フレームの時間 (start + 8 data + stop) | 86.8 µs (10 ビット) | 'U' 1 文字ぶん |
| Protocol の解読結果 | `0x55` (`'U'`) | 送った文字と一致すれば配線とボーレートが合っている |
| 送信の間隔 | 1 s ごと | プログラムどおり |

**ボーレートが合っていないと文字化けする。** わざと Baud を 9600 にしてみると、
スタートビットの途中で次のビットを読んでしまい、`0x55` 以外の値になる —
115200 と 9600 の比が約 12 倍で、1 ビットぶんの時間がずれるため。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer)
(UART の節)。
