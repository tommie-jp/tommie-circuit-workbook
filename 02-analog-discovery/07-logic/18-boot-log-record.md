---
book: analog-discovery
chapter: 7
id: 7-18
title: マイコンの起動ログ (UART) を長時間 Record
tier: 200
source: 自作 (計器の操作は WaveForms のヘルプの Logic の Record と UART)
board: BB
---

# 7-18 マイコンの起動ログ (UART) を長時間 Record

マイコンは電源を入れた直後やリセットの直後に、UART へ「起動ログ」を出すことが多い。いつ出るか分からず、何秒も続くので、
Logic の通常の取り込み (AD3 のバッファ 1 本 32,768 標本。1 MS/s で 33 ms) には入りきらない。そこで Logic の **Record** (記録) で
パソコンへ流し続け、リセット (RUN) の瞬間から 10 s ぶんを撮る。撮った後で UART の解読を掛け、**リセットから最初の文字までの時間**と、
1 s ごとの行が抜けていないかを読む。

Scope の Record (2-11) と同じ考え方の、Logic 版。ヘルプによれば Logic の Record は標本を USB で流すので、速さは PC と接続のつごうで
**およそ 1 MS/s** までになる (変化の少ない所は圧縮されるので、速い標本化でも短い塊なら記録できる)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Pico 2 の TX (GP0) と RUN を AD3 の DIO で見る
parts:
  AD:
    type: device
    at: 2,1.25
    label: AD3 Logic
    pins: [DIO0, GND]
    turn: mirror
  AD2:
    type: device
    at: 11,3.75
    label: AD3 Logic
    pins: [DIO1, GND]
  MCU: pico2 6,3.5
  SW1: button 8.5,3.75 8.5,5.25
  G1: ground 8.5,5.25
  G2: ground 4,2.5
  G3: ground 10,5.25
wires:
  - AD.DIO0 -- MCU.GP0
  - AD.GND -- 4,1.5
  - 4,1.5 -- 4,1.75
  - 4,1.75 -- MCU.GND3
  - 4,1.75 -- 4,2.5
  - MCU.RUN -- 8.5,3.75
  - 8.5,3.75 -- AD2.DIO1
  - AD2.GND -| 10,5.25
notes:
  - text 1,7 small left: "Pico 2 は USB で給電する (図に描かない)"
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/18-boot-log-record.svg)

- Pico 2 の GP0 (UART0 の TX) を DIO0 へ。7-3 と同じ。受けるだけ
- RUN (30 番) を DIO1 でも見る。RUN は RP2350 の中で約 50 kΩ (オーム) で 3.3 V に引き上げられていて (データシート)、SW1 で GND に落とすとリセットになる。
  離した瞬間が「起動の始まり」。DIO1 は入力なので、RUN の引き上げを邪魔しない
- Pico 2 は USB で給電する。GND は直接の線でも AD3 とつなぐ (7-3)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (Pico 2 は USB を左に。SW1 はリセット)
board: half
parts:
  MCU: pico2 @ h5
  SW1: button @ e27
  AD:
    type: device
    at: bottom
    label: AD3 Logic
    pins: [DIO0, GND]
  AD2:
    type: device
    at: top
    label: AD3 Logic
    pins: [GND, DIO1]
wires:
  - AD.DIO0 -- j5 yellow
  - AD.GND -- j7 black
  - i7 -- -b7 black
  - MCU.RUN -- a27 white
  - AD2.DIO1 -- a29 blue
  - AD2.GND -- -t25 black
  - -t30 -- -b30 black
  - j27 -- -b27 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/18-boot-log-record.svg)

- Pico 2 は 7-3 と同じく h5 に、USB を左に向けて挿す。GP0 は h5、GND (3 番) は h7。空いた j5・j7 から AD3 へ、i7 から下の − レールへ
- RUN (30 番) は上の列の 16 列。白い線で 27 列へ出し、e27 に挿したタクトスイッチ SW1 の上のピンにつなぐ。SW1 の下のピンを − レールへ
- 上の AD3 の DIO1 (青) は SW1 の上のピンの組 (29 列)。上下の − レールは 30 列でつなぐ
- AD3 は 1 台で、図では上下の 2 つの箱に分けて描いた

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 (TX)・DIO1 (RUN)。**Mode = Record**、Rate 1 MHz、Samples 10 M (10 s)。トリガは DIO1 の立ち下がり (リセット)、トリガの前を 1 s 入れる |
| Logic の解読 | Add → UART。Data = DIO0、Baud 115200、8 ビット・パリティ無し・ストップ 1 |
| Pico 2 | 下のプログラムを書き込んでおく。USB は挿したまま (給電) |

見る物は 0 か 1 かと文字の並びと時刻なので、オシロではなくロジックの画面にした。

手順: Logic を Record で Run にし、SW1 を 0.3 s ほど押して離す。10 s たつと記録が止まり、解読の欄に文字が並ぶ。
1 MHz なら 1 ビット (8.68 µs (マイクロ秒)) を 8.7 標本で撮れ、UART の解読に足りる。ボーレートを上げるなら Rate も上げる (1 ビットに 4 標本以上。目安)。
10 s を 1 MHz で撮ると 1 本 1,000 万標本で、ふつうのバッファの 300 倍。Record でなければ撮れない (図3 の下のお知らせ)。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 Record で 10 s — リセット (RUN) の後に boot、0.5 s 後から 1 s ごとに 1 行
device: ad3
time: 1s/div
start: 0s
sample: 1MHz
signals:
  RUN: dio1 edges 0s=1 1s=0 1.3s=1
  TX:  dio0 edges 0s=1 1.302s=0 1.302521s=1 1.802s=0 1.803042s=1 2.802s=0 2.802434s=1 3.802s=0 3.802434s=1 4.802s=0 4.802434s=1 5.802s=0 5.802434s=1 6.802s=0 6.802434s=1 7.802s=0 7.802434s=1 8.802s=0 8.802434s=1 9.802s=0 9.802434s=1
cursors: [1.3s, 1.802s]
trigger: RUN falling at 1s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/logic/18-boot-log-record-1.svg)

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 最初の行を拡大 — 6 文字 (b o o t CR LF) が 521 µs
device: ad3
time: 100us/div
start: -50us
sample: 1MHz
signals:
  TX: dio0 pattern 111001000110101111011010111101101000101110101011000010010100001 bit 8.6806us from -26.0418us
decode:
  Log: uart TX baud 115200 8N1 ascii
cursors: [0s, 520.8us]
trigger: TX falling at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/logic/18-boot-log-record-2.svg)

図3・図4 はプログラムから計算した理想の画面で、実測ではない。リセットから最初の文字までを 2 ms と置いた (目安。測って書き直す)。
図3 は 10 s 全体で、TX の行は文字の並びが 1 目盛 (1 s) に比べて細かすぎるので塗りで描かれる (WaveForms でも縮めると同じに見える)。
X1 (1.3 s) は SW1 を離した所、X2 (1.802 s) は ready の行の始まりで、ΔX 502 ms = 起動の 2 ms + プログラムの 500 ms。
図4 は最初の行の拡大で、6 文字が続けて 521 µs (1 文字 86.8 µs × 6)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| MCU | マイコン | Raspberry Pi Pico 2 (USB で給電) |
| SW1 | タクトスイッチ (リセット) | 1 個 |
| — | 計器 | Analog Discovery 3 (Logic) |

## Pico 2 のプログラム

C/C++ (Pico SDK) を第 1、MicroPython を第 2 として並べる (どちらも同じ動き)。ビルドと書き込みは 7-3 と同じ。

### C/C++ (Pico SDK)

`main.c` (起動したら `boot`、0.5 s 後に `ready`、そのあと 1 s ごとに `t=0` `t=1` … を UART0 の TX (GP0) へ)。

```c
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/uart.h"

#define UART_ID uart0

int main(void) {
    uart_init(UART_ID, 115200);
    gpio_set_function(0, GPIO_FUNC_UART);   // GP0 = TX
    gpio_set_function(1, GPIO_FUNC_UART);   // GP1 = RX
    uart_set_format(UART_ID, 8, 1, UART_PARITY_NONE);  // 8N1

    uart_puts(UART_ID, "boot\r\n");          // 起動して最初の行
    sleep_ms(500);
    uart_puts(UART_ID, "ready\r\n");

    char line[16];
    for (int n = 0;; n++) {
        snprintf(line, sizeof line, "t=%d\r\n", n);   // 1 s ごとの行
        uart_puts(UART_ID, line);
        sleep_ms(1000);
    }
}
```

`CMakeLists.txt` は 7-3 と同じで、名前だけ `boot_log` にする。

### MicroPython

Pico 2 用の MicroPython (`RPI_PICO2`) を入れ、**`main.py` の名前で保存する** (リセットのたびに自動で走る)。
MicroPython は自身の起動に時間がかかるので、リセットから `boot` までは C より長くなる。

```python
from machine import UART, Pin
from time import sleep_ms

uart = UART(0, baudrate=115200, tx=Pin(0), rx=Pin(1))   # 8N1 が既定

uart.write(b'boot\r\n')
sleep_ms(500)
uart.write(b'ready\r\n')

n = 0
while True:
    uart.write(('t=%d\r\n' % n).encode())
    n += 1
    sleep_ms(1000)
```

**実機では動かしていない。**

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 解読の欄の並び | `boot` `ready` `t=0` `t=1` … (各行の後に CR LF) | 起動ログを全部取り逃さずに撮れた |
| RUN を離してから `boot` の最初のビットまで | C で数 ms (目安。測って書く)、MicroPython で長い | 起動にかかる時間 (ブートローダとランタイムの初期化) |
| `boot` から `ready` まで | 500 ms | プログラムの `sleep_ms(500)` |
| `t=n` の行の間隔 | 1000 ms (数え落としが無ければ 10 s で 8〜9 行) | 1 s ごとに 1 行。抜けた行があれば Record が取りこぼした |
| 1 行の長さ (`boot\r\n`) | 521 µs (6 文字 × 86.8 µs) | 文字の間に隙間が無い (FIFO から続けて送る) |
| Rate を 10 MHz にして 10 s | 途中で止まるか、抜けが出る | USB で流せる上限 (およそ 1 MS/s) を超える |

## LTspice での確かめ (対象外)

UART とプログラムの時間の題。算術で確かめた。1 ビット 1 ÷ 115200 = 8.68 µs、1 文字 86.8 µs、`boot\r\n` 6 文字 = 521 µs。1 MHz × 10 s = 1,000 万標本で、32,768 標本のバッファの 305 倍。
図3 の ΔX 502 ms = 2 ms (仮定) + 500 ms、図4 の解読 `b` `o` `o` `t` 0x0D 0x0A は 86.8 µs ずつ並ぶ。

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| UART の設定 | UART0 を 115200 baud・8N1。GP0 が TX、GP1 が RX | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 送る行と時刻 | `boot` が 0 s、`ready` と `t=0` が 0.5 s、`t=1` が 1.5 s、`t=2` が 2.5 s | C: Pico SDK のモック・MicroPython: `machine` のスタブ |

見ていない物: 線の上の波形と、リセットから `main` までの起動の時間 (モックは `main` から始まる)

## 出典

自作。計器の名前と操作は WaveForms のヘルプ (Logic の Mode の Record、UART の解読) と Digilent の
[Using the Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer)。

参考: [Raspberry Pi Pico 2 のデータシート](https://datasheets.raspberrypi.com/pico/pico-2-datasheet.pdf)
