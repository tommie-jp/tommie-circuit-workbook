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
同じ)。そこで抵抗で 3.3 V へ引き上げ (プルアップ)、押していない間は GPIO が確実に H (3.3 V) に
なるようにする。Pico 2 は内蔵プルアップ (データシートでは 32〜86 kΩ) も使えるが、
ここでは抵抗が電位を決める働きを目で追えるように外付けにする。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 プルアップ抵抗とボタン
parts:
  U1: pico2 3,5.2
  R1: resistor 6,6 6,9 10k
  SW1: button 6,9 6,11 l=$\mathrm{SW1}$
  G1: ground 6,11
wires:
  - U1.3V3 -| 6,6
  - U1.GP16 -| 5,9 -- 6,9
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/02-button-pullup.svg)

- R1 (10 kΩ) が GP16 を 3V3 (Pico 2 が出す 3.3 V) へ引き上げる。ボタンを離している間、
  GP16 は 3.3 V (H)
- SW1 を押すと GP16 が直接 GND につながり、0 V (L) になる。R1 には
  3.3 V ÷ 10 kΩ ≈ 0.33 mA しか流れないので、GPIO やボタンを壊さない
- プルアップの先は 3V3 (ピン 36、Pico 2 自身が出す 3.3 V) にする。VBUS (ピン 40、5 V) に
  つなぐと GPIO の定格 (3.3 V) を超えて壊れる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor b36 b33 10k
  SW1: button @ e35
  SC:
    type: device
    at: top
    label: AD3 Scope
    pins: [1+, 1-]
wires:
  - SC.1+ -- a35 yellow
  - SC.1- -- -t42 black
  - MCU.3V3 -- +t9 red
  - MCU.GND38 -- -t7 black
  - +t36 -- a36 red
  - a24 -- a33 yellow
  - d33 -- d35 yellow
  - g37 -- -b37 black
  - -t40 -- -b40 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/breadboard/02-button-pullup.svg)

- Pico 2 の `3V3` (ピン 36、9 列の上) を上の + レールへ、`GND` (ピン 38、7 列の上) を
  上の − レールへ (USB を挿しただけではレールに出ないので、この 2 本は必ず配線する)
- GP16 (ピン 21、24 列の上) は `a24` から黄の線で Pico 2 の胴の外の 33 列 (`a33`) まで運び、
  R1 (`b33`〜`b36`) と SW1 へつなぐ (胴の真上・真下の列は他のピンと紛れやすいので避ける)
- R1 の右リード (36 列) は `a36` から + レールへ。33 列から d 行の黄の線で SW1 (e35) の手前側へ渡し、
  SW1 の奥側 (37 列) を下の − レールへ。下の − レールは 40 列の線で上の − レール
  (Pico 2 の GND) とつなぐ (これが無いと押しても GP16 が L にならない)
- 電源は Pico 2 の USB。Analog Discovery 3 (AD3、0-3 で使った USB 計測器) は **オシロ (Scope) だけ**を
  つなぎ、1+ (黄) を GP16 につながる 35 列 (`a35`、33 列から SW1 へ渡る線と同じ点) に、
  1− (黒) を上の − レール (GND) へ挿す。ブレッドボードを流れる電流は R1 の 0.33 mA ほどで、ブレッドボードの範囲 (ブレッドボード全体 500 mA) に収まる

## 計器の設定

計器は AD3 のオシロ (Scope)。ボタンを押した間だけ GP16 が 3.3 V から 0 V に落ちるのを、
**押した瞬間を捕まえて**見る。1 回きりの変化なので、トリガを Single (1 回だけ捕まえる) にして、
押してから離すまで (約 0.5 秒) を 1 画面に入れる。

| 項目 | 値 |
| --- | --- |
| 電源 | Pico 2 の USB (AD3 の Supplies は使わない) |
| CH1 (1+) | GP16 (ピン 21)。1 V/div、0 V を下から 1 目盛 |
| 1− | GND |
| 時間レンジ | 100 ms/div |
| トリガ | CH1 の立ち下がり、1.65 V (3.3 V の中央)、Single。トリガの点を左から 3 目盛に置く |
| Measurements | Maximum・Minimum |
| カーソル | X1 を離している間 (−100 ms、押す前)、X2 を押している間 (300 ms) に置く |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 ボタンを押した間だけ GP16 が 0V に落ちる (約 0.5 秒押した場合)
time: 100ms/div
trigger: ch1 falling 1.65V at -2div
ch1: {wave: = 3.3V - 3.3V * step(t) + 3.3V * step(t - 500ms), range: 1V/div, position: -3div}
cursors: [-100ms, 300ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/scope/02-button-pullup.svg)

- 図3 の GP16 は、押す前は 3.3 V (R1 が引き上げている)。押した瞬間 (t = 0) に 0 V へ落ち、
  離した瞬間 (約 500 ms) に 3.3 V へ戻る
- カーソルの読みは X1 (押す前) が 3.3 V、X2 (押している間) が 0 V で、下の「見るべき値」の表と同じ。
  図は理想の波形で、実物のボタンは押した直後と離した直後に数 ms のあいだ細かく跳ねる (チャタリング、10-5 で見た)。
  Pico 2 の 0.2 秒ごとの読み取りでは跳ねの影響は出にくい

## 見るべき値

計算値。テスターの直流電圧レンジで、GP16 (ピン 21) と GND の間を測る。

| 状態 | GP16 の電圧 | R1 の電流 |
| --- | --- | --- |
| ボタンを離している | 約3.3V (H) | ほぼ0 (GPIO 入力はほぼ電流を引かない) |
| ボタンを押している | 0 V (L) | 約0.33mA (3.3 V ÷ 10 kΩ) |

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

## LTspice での確かめ

`sim/02-button-pullup.cir` で図1 を解いた。ボタンは 0.1 Ω の接点、GPIO 入力は電流ゼロの理想で表した。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 離している間の GP16 | 約 3.3 V (H) | 3.30 V | 合う |
| 押している間の GP16 | 0 V (L) | 0.03 mV | 合う |
| 押している間の R1 の電流 | 約 0.33 mA | 0.330 mA | 合う |

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`・`npm run pico`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| GP16 の設定 | 入力で、内蔵プルアップは使わない (外付け R1) | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 読み出し | 離している間は 1 を 200 ms ごとに出す | C: Pico SDK のモック・MicroPython: `machine` のスタブ |

見ていない物: ボタンを押した実際の電圧・チャタリング

## 出典

自作。GPIO のプルアップ抵抗値 (32〜86 kΩ、IOVDD=3.3 V) は [RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf)
(14.9 電気的特性、Digital IO) による。
