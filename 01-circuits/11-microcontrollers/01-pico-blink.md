---
book: circuits
chapter: 11
id: 11-1
title: Pico 2 の L チカ
tier: 50
source: 自作
board: BB
era: 今
---

# 11-1 Pico 2 の L チカ

Raspberry Pi Pico 2 (RP2350) の GPIO ピン 1 本に LED をつなぎ、C/C++ (Pico SDK) と
MicroPython の両方で点滅させる。
マイコンで最初に書くプログラムの定番「L チカ」を、外付けの LED で行う
(基板上の LED は GP25 に固定されていて配線の練習にならない)。

## 回路図

```circuit
title: 図1 Pico2でLEDを点滅させる
parts:
  U1: pico2 e3c0 mirror
  R1: resistor i6 i8 330
  D1: led i8 k8 red
  G1: ground k8
  G2: ground h5c0 r270
wires:
  - U1.GP15 -| i6
  - U1.GND18 -| h5c0
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/01-pico-blink.svg)

- GP15 (汎用入出力) を出力に設定し、program で H (3.3V) / L (0V) を切り替える
- LED の戻り道として、Pico 2 の GND (ここではピン 18) を GND につなぐ。
  これが無いと電流の帰り道が無く、LED は点かない
- R1 (330Ω) が電流を決める。3.3V − V<sub>F</sub> (赤色 LED 約2.0V) を 330Ω で割ると
  約 3.9mA。Pico 2 (RP2350) の GPIO は 1 本あたり最大 12mA (既定は 4mA の設定)、
  全ピンの合計 100mA までなので余裕がある。3.9mA は既定の 4mA に収まる

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor j24 j28 330
  D1: led i28(A) i30(K) red
wires:
  - j30 -- -b30 black
  - j22 -- -b22 black
  - -t50 -- -b50 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/breadboard/01-pico-blink.svg)

- `pico2 @ h5` は基板の左端 (h 行、ピン 1 = GP0) を指す。USB を左に向けた
  ときの実物のピン配置のまま
- GP15 (ピン20) は下側のピン列にあるので `j` 行 (下ブロック) の空いた穴から
  配線する。`h5` に置いたとき `j24` が GP15 の列 (`j23` は隣の GP14)
- LED のアノードは R1 の右足と同じ 28 列 (i28)、カソード (30 列) は j30 から下の
  − レール (GND) へ
- **Pico 2 の GND (ピン 18、22 列) を j22 から下の − レールへ渡す。** これが無いと
  LED の電流が Pico 2 へ戻れず、点かない (Pico 2 の GND はどのピンも中でつながって
  いるので、どれか 1 本をレールへ出せばよい)。上下の − レールは 50 列で渡して
  おく

## 見るべき値

計算値。

| 測る所 | 期待する値 |
| --- | --- |
| GP15 が H のときの R1 の両端 | 約1.3V (3.3 − 2.0) |
| R1 に流れる電流 | 約3.9mA |
| LED の両端 | 約2.0V (順方向電圧、赤色) |

## プログラム

プログラムは **C/C++ (Pico SDK) を第 1、MicroPython を第 2** として並べる。
C/C++ を先にするのは、この教科書の標準がそうだからで、実行時間が読みやすく
(後の章の PWM や I2C のタイミングに効く)、RAM も食わないため。
どちらも同じ動きをする。

### C/C++ (Pico SDK)

`main.c` (GP15 を出力にして 0.5 秒ごとに H/L を切り替える)。

```c
#include "pico/stdlib.h"

#define LED_PIN 15

int main(void) {
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);

    while (true) {
        gpio_put(LED_PIN, 1);   // H (3.3V): LED 点灯
        sleep_ms(500);
        gpio_put(LED_PIN, 0);   // L (0V): LED 消灯
        sleep_ms(500);
    }
}
```

同じフォルダに `pico_sdk_import.cmake` (SDK の `external/` にあるものをコピーする) と
`CMakeLists.txt` を置く。

```cmake
cmake_minimum_required(VERSION 3.13)
set(PICO_BOARD pico2 CACHE STRING "Board type")
include(pico_sdk_import.cmake)
project(blink C CXX ASM)
pico_sdk_init()
add_executable(blink main.c)
target_link_libraries(blink pico_stdlib)
pico_add_extra_outputs(blink)
```

環境変数 `PICO_SDK_PATH` に SDK のフォルダを指しておき、次でビルドする。

```sh
cmake -B build -DPICO_BOARD=pico2
cmake --build build
```

`build/blink.uf2` ができる。**BOOTSEL ボタンを押しながら USB をつなぐ**と Pico 2 が
USB ドライブ (ボリューム名は既定で `RP2350`) として見えるので、`.uf2` をそこへ
コピーすれば書き込まれて動く。`PICO_BOARD=pico2` を付け忘れると Pico (RP2040) 用に
ビルドされ、Pico 2 では動かない。

### MicroPython

Pico 2 用の MicroPython (ダウンロードページ `RPI_PICO2`、Pico 用とは別のファイル) の
`.uf2` を、同じく BOOTSEL でつないで出てきたドライブへコピーする。あとは
Thonny で「MicroPython (Raspberry Pi Pico)」を選び、次を実行する。

```python
from machine import Pin
from time import sleep

led = Pin(15, Pin.OUT)

while True:
    led.value(1)   # H (3.3V): LED 点灯
    sleep(0.5)
    led.value(0)   # L (0V): LED 消灯
    sleep(0.5)
```

C/C++ のプログラムは、この環境で `PICO_BOARD=pico2` の `.uf2` までビルドが
通ることを確かめた。**実機では動かしていない。** MicroPython は実行していない
(未確認)。

## 出典

自作。Pico 2 の仕様 (RP2350A、4MB フラッシュ、最大 150MHz、SRAM 520kB) は
Raspberry Pi Pico 2 データシート、GPIO の電流 (最大 12mA・全ピン合計 100mA・既定 4mA)
は RP2350 データシート (14.9 電気的特性) による。
