---
book: circuits
chapter: 11
id: 11-2
title: ボタン入力とプルアップ
tier: 50
source: 自作
board: BB
era: 今
---

# 11-2 ボタン入力とプルアップ

11-1 では GPIO を出力に使った。この題では GPIO を入力にして、ボタンが押されているかを
プログラムで読む。

GPIO の入力は、何もつながないと電位が決まらず、0 と 1 の間でふらつく (10-1 の CMOS の入力と
同じ)。そこで抵抗で 3.3V へ引き上げ (プルアップ)、押していない間は GPIO が確実に H (3.3V) に
なるようにする。Pico 2 は内蔵プルアップ (データシートでは 32〜86kΩ) も使えるが、
ここでは抵抗が電位を決める働きを目で追えるように外付けにする。

## 回路図

```circuit
title: 図1 プルアップ抵抗とボタン
parts:
  U1: pico2 e3c0
  R1: resistor f6 i6 10k
  SW1: button i6 k6 l=$\mathrm{SW1}$
  G1: ground k6
wires:
  - U1.3V3 -| f6
  - U1.GP16 -| i5 -- i6
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/02-button-pullup.svg)

- R1 (10kΩ) が GP16 を 3V3 (Pico 2 が出す 3.3V) へ引き上げる。ボタンを離している間、
  GP16 は 3.3V (H)
- SW1 を押すと GP16 が直接 GND につながり、0V (L) になる。R1 には
  3.3V ÷ 10kΩ ≈ 0.33mA しか流れないので、GPIO やボタンを壊さない
- プルアップの先は 3V3 (ピン 36、Pico 2 自身が出す 3.3V) にする。VBUS (ピン 40、5V) に
  つなぐと GPIO の定格 (3.3V) を超えて壊れる

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor a30 a33 10k
  SW1: button @ e35
wires:
  - MCU.3V3 -- +t9 red
  - MCU.GND38 -- -t7 black
  - +t30 -- b30 red
  - MCU.GP16 -- b33 yellow
  - c33 -- c35 yellow
  - g37 -- -b37 black
  - -t40 -- -b40 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/breadboard/02-button-pullup.svg)

- Pico 2 の `3V3` (ピン 36、9 列の上) を上の + レールへ、`GND` (ピン 38、7 列の上) を
  上の − レールへ (USB を挿しただけではレールに出ないので、この 2 本は必ず配線する)
- GP16 (ピン 21、24 列の上) は黄の線で Pico 2 の胴の外の 33 列 (b33) まで運び、
  R1 (a30〜a33) と SW1 へつなぐ (胴の真上・真下の列は他のピンと紛れやすいので避ける)
- R1 の左足 (30 列) は + レールへ。33 列から c 行の黄の線で SW1 (e35) の手前側へ渡し、
  SW1 の奥側 (37 列) を下の − レールへ。下の − レールは 40 列の線で上の − レール
  (Pico 2 の GND) とつなぐ (これが無いと押しても GP16 が L にならない)

## 見るべき値

計算値。テスターの直流電圧レンジで、GP16 (ピン 21) と GND の間を測る。

| 状態 | GP16 の電圧 | R1 の電流 |
| --- | --- | --- |
| ボタンを離している | 約3.3V (H) | ほぼ0 (GPIO 入力はほぼ電流を引かない) |
| ボタンを押している | 0V (L) | 約0.33mA (3.3V ÷ 10kΩ) |

## プログラム

11-1 と同じく、C/C++ を第 1、MicroPython を第 2 に並べる。どちらも 0.2 秒ごとに GP16 を
読み、離していれば 1、押していれば 0 を PC の画面に出す。

### C/C++ (Pico SDK)

`main.c` (0.2 秒ごとに GP16 を読んで USB シリアルへ出す)。

```c
#include <stdio.h>
#include "pico/stdlib.h"

#define BUTTON_PIN 16

int main(void) {
    stdio_init_all();
    gpio_init(BUTTON_PIN);
    gpio_set_dir(BUTTON_PIN, GPIO_IN);   // プルアップは外付けの R1 が受け持つ

    while (true) {
        printf("%d\n", gpio_get(BUTTON_PIN));   // 離している: 1、押している: 0
        sleep_ms(200);
    }
}
```

- `gpio_set_dir(BUTTON_PIN, GPIO_IN)` で GP16 を入力にする
- `gpio_get(BUTTON_PIN)` が GP16 の今の値 (H なら 1、L なら 0) を返す
- `stdio_init_all()` と `printf` で、値を USB シリアル (USB ケーブルを通した文字の通信) に出す

`CMakeLists.txt` は 11-1 と同じ形で、名前を `button` にし、USB シリアルを使う 2 行を足す。
ビルドと書き込みも 11-1 と同じ (`PICO_BOARD=pico2`、`.uf2` を BOOTSEL のドライブへ)。

```cmake
cmake_minimum_required(VERSION 3.13)
set(PICO_BOARD pico2 CACHE STRING "Board type")
include(pico_sdk_import.cmake)
project(button C CXX ASM)
pico_sdk_init()
add_executable(button main.c)
target_link_libraries(button pico_stdlib)
pico_enable_stdio_usb(button 1)
pico_enable_stdio_uart(button 0)
pico_add_extra_outputs(button)
```

USB シリアルの出力は、PC のシリアルターミナル (`screen` や TeraTerm など、届いた文字を
表示するソフト) で見る。

内蔵プルアップに替えるなら `gpio_pull_up(BUTTON_PIN)` を足し、R1 を外す。

### MicroPython

`Pin(16, Pin.IN)` で GP16 を入力にし、`button.value()` で今の値を読む。`print` の出力は
Thonny の画面 (シェル) に出る。

```python
from machine import Pin
from time import sleep

button = Pin(16, Pin.IN)   # プルアップは外付けの R1 が受け持つ

while True:
    print(button.value())   # 離している: 1、押している: 0
    sleep(0.2)
```

内蔵プルアップに替えるなら `Pin(16, Pin.IN, Pin.PULL_UP)` にする。

C/C++ は `PICO_BOARD=pico2` の `.uf2` までビルドが通ることを確かめた。
実機では動かしていない。MicroPython は実行していない (未確認)。

## 出典

自作。GPIO のプルアップ抵抗値 (32〜86kΩ、IOVDD=3.3V) は RP2350 データシート
(14.9 電気的特性、Digital IO) による。
