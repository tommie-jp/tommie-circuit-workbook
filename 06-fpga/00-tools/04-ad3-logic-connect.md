---
book: fpga
chapter: 0
id: 0-4
title: AD3 の Logic をつなぐ — DIO を 3.3 V にして GND を共通に
tier: 50
source: 自作
board: BB
device: PICO
---

# 0-4 AD3 の Logic をつなぐ — DIO を 3.3 V にして GND を共通に

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 のプログラムは `.uf2` までのビルドを確かめたが、書き込んで動かしてはいない。
> 「見るべき値」は計算値か目安で、測った値ではない。

この冊の計器は Analog Discovery 3 (AD3) の **Logic** (ロジックアナライザ)。
Logic は DIO のピンの高低 (H・L) を時間順に記録して、波形として見せる。

この題では、Pico 2 の 2 本のピン (GP14・GP15) から 2 ビットのカウンタの値 0 → 1 → 2 → 3 を出し、AD3 の DIO0・DIO1 で読む。
この 2 ビットは、第 2 章で書くカウンタの下 2 ビットと同じ並びになる。

守ることは 2 つ。

- DIO の H は **3.3 V** にそろえる。Pico 2 の GPIO は 3.3 V なので、そのまま読める (0-3)
- **GND を共通にする**。AD3 の GND と Pico 2 の GND を、ブレッドボードの上で 1 本の線でつなぐ

## 回路図

```circuit
title: 図1 Pico 2 の GP14・GP15 を AD3 の DIO0・DIO1 で読む
parts:
  AD:
    type: device
    at: e1
    label: AD3
    pins: [GND, DIO0, DIO1]
    turn: mirror
  MCU: pico2 c6
wires:
  - AD.GND -| MCU.GND18
  - AD.DIO0 -| MCU.GP14
  - AD.DIO1 -| MCU.GP15
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/00-tools/circuit/04-ad3-logic-connect.svg)

- Pico 2 が出す側、AD3 が読む側。AD3 からは何も出さない
- GP14 が値の下位ビット (bit0)、GP15 が上位ビット (bit1)
- GND の線が無いと、AD3 は Pico 2 の電圧を測る基準を持てない

## 実体配線図

```breadboard
title: 図2 ブレッドボードに Pico 2 を挿し、AD3 の DIO0・DIO1・GND をつなぐ
board: half
parts:
  MCU: pico2 @ h5
  AD:
    type: device
    at: bottom
    label: AD3 Logic
    pins: [GND, DIO0, DIO1]
wires:
  - AD.GND -- j22 black
  - AD.DIO0 -- j23 yellow
  - AD.DIO1 -- j24 green
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/00-tools/breadboard/04-ad3-logic-connect.svg)

- `pico2 @ h5` は USB を左に向けた向き。下の行 (h) の左端が 1 番ピン (GP0)
- GP14 (19 番) は 23 列、GP15 (20 番) は 24 列、GND (18 番) は 22 列にある。同じ列の下側の空いた穴 (j 行) から線を取る
- DIO0 は黄、DIO1 は緑、GND は黒。赤は電源専用なので使わない
- Pico 2 の電源は USB。AD3 の電源ツールは使わない
- 流れる電流は DIO の入力へ向かうごく小さなもので、ブレッドボードの範囲に収まる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0・DIO1 を Enable。標本化は 100 kS/s。バスを 1 つ作る (DIO1 を上位、DIO0 を下位、10 進) |
| Logic のトリガ | DIO0 の立ち上がり |

標本化は、見せる一番速い変化 (bit0 の 500 Hz) の 4 倍よりずっと速い 100 kS/s にした。
AD3 の DIO は 3.3 V の信号。入力の許容は Digilent の仕様書で確かめる。

## Pico 2 のプログラム

プログラムは **C/C++ (Pico SDK) を第 1、MicroPython を第 2** として並べる。どちらも 1 ms ごとに値を 1 増やし、下位 2 ビットを GP14・GP15 に出す。

### C/C++ (Pico SDK)

`main.c`:

```c
#include "pico/stdlib.h"

#define PIN_BIT0 14
#define PIN_BIT1 15

int main(void) {
    gpio_init(PIN_BIT0);
    gpio_set_dir(PIN_BIT0, GPIO_OUT);
    gpio_init(PIN_BIT1);
    gpio_set_dir(PIN_BIT1, GPIO_OUT);

    uint32_t n = 0;
    while (true) {
        gpio_put(PIN_BIT0, n & 1);
        gpio_put(PIN_BIT1, (n >> 1) & 1);
        n++;
        sleep_ms(1);
    }
}
```

`CMakeLists.txt` と `pico_sdk_import.cmake` の置き方、ビルドの打ち方は 0-2 と同じ。`add_executable(count2 main.c)` と書いて、`count2.uf2` を作る。
0-2 の Docker で `PICO_BOARD=pico2` の `count2.uf2` (12800 バイト) までビルドが通ることを確かめた。**実機では動かしていない。**

### MicroPython

Pico 2 用の MicroPython (`RPI_PICO2`) の `.uf2` を入れ、Thonny で実行する。**実行していない (未確認)。**

```python
from machine import Pin
from time import sleep_ms

bit0 = Pin(14, Pin.OUT)
bit1 = Pin(15, Pin.OUT)

n = 0
while True:
    bit0.value(n & 1)
    bit1.value((n >> 1) & 1)
    n += 1
    sleep_ms(1)
```

## Logic に見えるはずの画面

1 ms ごとに値が 0 → 1 → 2 → 3 → 0 と進む。bit0 は 1 ms ごとに反転、bit1 は 2 ms ごとに反転する。

```logic
title: 図3 0 → 1 → 2 → 3 と数える。bit0 の周期は 2 ms
device: ad3
time: 1ms/div
start: -1ms
sample: 100kHz
signals:
  DIO0: dio0 pattern 01010101010 bit 1ms
  DIO1: dio1 pattern 00110011001 bit 1ms
buses:
  Count: DIO1 DIO0 dec
cursors: [1.5ms, 3.5ms]
trigger: DIO0 rising at 1ms
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/00-tools/logic/04-ad3-logic-connect.svg)

カーソルは 1 ビットの真ん中に置いた (変わり目の上に置くと、新旧どちらの値か曖昧になる)。2 本の間隔は 2 ms で、bit0 の 1 周期に当たる。

## 見るべき値

実機で測っていない。計算値と目安。

| 測る所 | 見るべき値 | 分かること |
| --- | --- | --- |
| バスの値の並び | 0 → 1 → 2 → 3 → 0 … (計算値) | 2 ビットのカウンタとして読める |
| bit0 (DIO0) の周期 | 2 ms 前後 → 500 Hz 前後 (目安) | `sleep_ms(1)` の 1 ms に、ループの処理の数 µs が加わる分だけ少し長い |
| bit1 (DIO1) の周期 | bit0 の 2 倍、4 ms 前後 (目安) | 上位ビットは下位の半分の速さ |
| H の電圧 | 3.3 V 前後 (目安) | Pico 2 の GPIO の H |
| AD3 の GND の線を外す | 波形が出ないか、でたらめに見える (目安) | GND が共通でないと基準が無い。確かめるときは外すだけで、他は触らない |

周期は実機で測って、この表に書き加える。Pico 2 の `sleep_ms` の正確さは測るまで決め打ちしない。

## 出典

自作。AD3 の Logic の使い方は Digilent の
[Using the Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer)。
Pico SDK のピンの扱いは Raspberry Pi の Pico SDK の資料。接続の考え方は 02-analog-discovery の 7-3 と同じ。
