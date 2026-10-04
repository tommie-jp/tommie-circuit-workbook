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

マイコンは、プログラムで決めたとおりにピンの電圧を H・L に切り替えたり、ピンの
電圧を読んだりする IC。第 10 章ではスイッチと配線で決めていた 0・1 を、プログラムで
決められるようになる。

この題では、Raspberry Pi Pico 2 (マイコン RP2350 を載せた小さな基板。以下 Pico 2) の
GPIO (汎用入出力ピン。入力にも出力にも使える) 1 本に LED をつなぎ、C/C++ (Pico SDK) と
MicroPython の両方で点滅させる。LED を点滅させる (L チカ) のは、マイコンで最初に
書くプログラムの定番。基板上の LED は使わず、外付けの LED で行う
(基板上の LED は中で GP25 に固定されていて、配線の練習にならない)。

## 回路図

```circuit
title: 図1 Pico2でLEDを点滅させる
parts:
  U1: pico2 e3c0 mirror
  R1: resistor i6 i8 330
  D1: led i8 k8 red
  G1: ground k8
  G2: ground h5c0
wires:
  - U1.GP15 -| i6
  - U1.GND18 -| h5c0
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/01-pico-blink.svg)

- GP15 (図1 の右下、ピン 20) を出力に設定し、プログラムで H (3.3V) / L (0V) を切り替える。
  Pico 2 の GPIO の H は 5V ではなく 3.3V
- LED の戻り道として、Pico 2 の GND (ここではピン 18) を GND につなぐ。
  これが無いと電流の帰り道が無く、LED は点かない
- R1 (330Ω) が電流を決める。I = (3.3V − V<sub>F</sub>) / R1 = (3.3V − 2.0V) / 330Ω ≈ 3.9mA
  (V<sub>F</sub> は LED の順方向電圧。赤色 LED で約 2.0V、計算値)。Pico 2 (RP2350) の
  GPIO は 1 本あたり最大 12mA (既定の設定は 4mA)、全ピンの合計 100mA までなので余裕がある。
  3.9mA は既定の 4mA にも収まる

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor j24 j28 330
  D1: led i28(A) i30(K) red
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 1-, 2+, 2-]
wires:
  - SC.1+ -- g24 yellow
  - SC.2+ -- g28 blue
  - SC.1- -- -b26 black
  - SC.2- -- -b27 black
  - j30 -- -b30 black
  - j22 -- -b22 black
  - -t50 -- -b50 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/breadboard/01-pico-blink.svg)

- `pico2 @ h5` は基板の左端 (h 行、ピン 1 = GP0) を指す。USB を左に向けた
  ときの実物のピン配置のまま
- GP15 (ピン20) は下側のピン列にあるので `j` 行 (下ブロック) の空いた穴から
  配線する。`h5` に置いたとき `j24` が GP15 の列 (`j23` は隣の GP14)
- LED のアノードは R1 の右リードと同じ 28 列 (i28)、カソード (30 列) は j30 から下の
  − レール (GND) へ
- Pico 2 の GND (ピン 18、22 列) を j22 から下の − レールへ渡す。これが無いと
  LED の電流が Pico 2 へ戻れず、点かない (Pico 2 の GND はどのピンも中でつながって
  いるので、どれか 1 本をレールへ出せばよい)。上下の − レールは 50 列で渡して
  おく
- 電源は Pico 2 の USB (VBUS ピン 40 に来る 5V を、基板上のレギュレータが 3.3V にして使う)。
  Analog Discovery 3 (AD3、0-3 で使った USB 計測器) は電源に使わず、**オシロ (Scope) だけ**を
  つなぐ。1+ (黄) を GP15 の列 (24 列、`g24`) に、2+ (青) を LED のアノードの列 (28 列、`g28`) に挿し、
  1− と 2− (黒) は下の − レール (GND) へ。ブレッドボードを流れる電流は LED の約 3.9mA だけで、
  ブレッドボードの範囲 (1 穴 200mA・ブレッドボード全体 500mA) に収まる

## 計器の設定

計器は AD3 のオシロ (Scope)。**GP15 が 0.5 秒ごとに H・L を切り替え、LED のアノードが
H のときだけ約 2.0V (LED の順方向電圧) に上がる**のを見る。1 周期 1 秒のゆっくりした波なので、
時間レンジは 200ms/div (1 画面 2 秒、2 周期)。

| 項目 | 値 |
| --- | --- |
| 電源 | Pico 2 の USB (AD3 の Supplies は使わない) |
| CH1 (1+) | GP15 (ピン 20)。1V/div、0V を下から 1 目盛 |
| CH2 (2+) | LED のアノード (R1 と LED のあいだ)。CH1 と同じ 1V/div・同じ 0V の位置 |
| 1−・2− | GND |
| 時間レンジ | 200ms/div |
| トリガ | CH1 の立ち上がり、1.5V。トリガの点を左から 1 目盛に置く |
| Measurements | Frequency・Vmax |
| カーソル | X1 を点灯の中 (250ms)、X2 を消灯の中 (750ms) に置く。ΔX が半周期 500ms |

```scope
title: 図3 GP15 (CH1) と LED のアノード (CH2) — 0.5 秒ごとに切り替わる
time: 200ms/div
trigger: ch1 rising 1.5V at -4div
ch1: {wave: square 1Hz 1.65V offset 1.65V duty 50%, range: 1V/div, position: -3div}
ch2: {wave: square 1Hz 1V offset 1V duty 50%, range: 1V/div, position: -3div}
cursors: [250ms, 750ms]
measure: [freq, vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/scope/01-pico-blink.svg)

- 図3 の CH1 (GP15) は 0V と 3.3V を行き来する。High が 0.5 秒、Low が 0.5 秒で、周波数は 1Hz
  (プログラムの `sleep_ms(500)` の 2 回分が 1 周期)
- CH2 (LED のアノード) は GP15 が High のとき約 2.0V。残りの約 1.3V は R1 の両端にかかる
  (3.3V − 2.0V、下の「見るべき値」と同じ計算値)。Low のときは 0V で LED は消える
- 0.5 秒の点滅はテスターでは追えないが、オシロなら 1 画面で High・Low の両方が見える

## 見るべき値

計算値。テスターの直流電圧レンジで、LED が点いている間に測る。0.5 秒の点滅では
読みにくいので、プログラムの `sleep_ms(500)` (MicroPython は `sleep(0.5)`) を 5 秒ほどに
延ばしてから測るとよい。

| 測る所 | 期待する値 |
| --- | --- |
| GP15 (ピン 20) と GND の間 (H のとき) | 約3.3V |
| GP15 が H のときの R1 の両端 | 約1.3V (3.3 − 2.0) |
| R1 に流れる電流 | 約3.9mA (R1 の両端の電圧 ÷ 330Ω) |
| LED の両端 | 約2.0V (順方向電圧、赤色) |

## プログラム

プログラムは C/C++ (Pico SDK) を第 1、MicroPython を第 2 として並べる。どちらも同じ動きをする。
C/C++ を先にするのはこの教科書の標準で、1 行の実行にかかる時間が読みやすく
(この章の PWM や I2C のタイミングにかかわる)、RAM も少なくて済むため。
MicroPython は書いてすぐ試せるのが利点。

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

- `gpio_init(LED_PIN)` で GP15 を GPIO として使えるようにし、`gpio_set_dir(..., GPIO_OUT)` で出力にする
- `gpio_put(LED_PIN, 1)` で H、`gpio_put(LED_PIN, 0)` で L を出す
- `sleep_ms(500)` は 500ms (0.5 秒) 待つ。`while (true)` で点灯と消灯をいつまでも繰り返す

同じフォルダに `pico_sdk_import.cmake` (SDK の `external/` にあるものをコピーする) と
`CMakeLists.txt` (ビルドの設定) を置く。

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

環境変数 `PICO_SDK_PATH` に SDK のフォルダを指しておき、次でビルド (プログラムを
Pico 2 で動く形に変換) する。

```sh
cmake -B build -DPICO_BOARD=pico2
cmake --build build
```

`build/blink.uf2` ができる。基板上の BOOTSEL ボタンを押しながら USB をつなぐと Pico 2 が
USB ドライブ (ボリューム名は既定で `RP2350`) として見えるので、`.uf2` をそこへ
コピーすれば書き込まれて動く。`PICO_BOARD=pico2` を付け忘れると Pico (RP2040) 用に
ビルドされ、Pico 2 では動かない。

### MicroPython

Pico 2 用の MicroPython (ダウンロードページ `RPI_PICO2`、Pico 用とは別のファイル) の
`.uf2` を、同じく BOOTSEL でつないで出てきたドライブへコピーする。あとは
Thonny (Python の開発環境) で「MicroPython (Raspberry Pi Pico)」を選び、次を実行する。
`Pin(15, Pin.OUT)` が GP15 を出力にし、`led.value(1)` / `led.value(0)` で H / L を出す。

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
通ることを確かめた。実機では動かしていない。MicroPython は実行していない
(未確認)。

## 出典

自作。Pico 2 の仕様 (RP2350A、4MB フラッシュ、最大 150MHz、SRAM 520kB) は
Raspberry Pi Pico 2 データシート、GPIO の電流 (最大 12mA・全ピン合計 100mA・既定 4mA)
は RP2350 データシート (14.9 電気的特性) による。
