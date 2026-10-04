---
book: circuits
chapter: 11
id: 11-3
title: ADC で CdS を読む
tier: 100
board: BB
source: 自作
era: 今
---

# 11-3 ADC で CdS を読む

8-1 の CdS はトランジスタで「暗い/明るい」の ON/OFF にしていた。Pico 2 (RP2350) の
ADC (アナログ→デジタル変換。電圧を数値に変える回路) を使えば、明るさを細かい段階の
数値として読める。この題では GP26 (ADC0、ADC につながる入力の 0 番) で CdS の分圧の
電圧を測り、明るさで値が変わるのを確かめる。

## 回路図

```circuit
title: 図1 CdS分圧をADC0(GP26)で読む
parts:
  U1: pico2 d3
  P1: vcc a6i0 3.3V
  P2: vcc a5i0 3.3V
  CDS1: photoresistor a6i0 c6i0 GL5528 l=$\mathrm{CDS1}$
  R1: resistor c6i0 e6i0 10k
  G1: ground e6i0
wires:
  - U1.3V3 -| a5i0
  - U1.GP26 -| c6i0
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/03-adc-cds.svg)

- CdS を 3V3 側 (Pico 2 自身が出す 3.3V)、固定抵抗 R1 (10kΩ) を GND 側に置いた分圧
  (1-2)。2 つの間の点 (以下 V<sub>node</sub>) を GP26 で読む。明るい (CdS の抵抗が下がる)
  ほど、ADC が読む電圧は 3.3V に近づく
- CdS (硫化カドミウムセル、代表的な GL5528) の抵抗は明るさで大きく変わる。
  光を直接当てると目安 1kΩ 前後、室内で 10kΩ 前後、真っ暗で目安 200kΩ 以上
- R1 = 10kΩ は CdS の室内の明るさでの抵抗と同じ桁に選んである。
  こうすると室内光でだいたい半分の電圧になり、ADC の測れる範囲を無駄なく使える

計算値 (V<sub>node</sub> = 3.3V × R1 / (R<sub>CdS</sub> + R1)):

| 明るさ | CdS の抵抗 (目安) | V<sub>node</sub> | `adc_read()` の値 (0〜4095) | `read_u16()` の値 (0〜65535) |
| --- | --- | --- | --- | --- |
| 明るい (光を当てる) | 約1kΩ | 約3.0V | 約3700 | 約59600 |
| 室内 | 約10kΩ (R1 と同じ) | **1.65V (半分)** | **約2048 (半分)** | **約32768 (半分)** |
| 真っ暗 | 約200kΩ | 約0.16V | 約200 | 約3100 |

Pico 2 の ADC は 12 bit (0〜4095 の 4096 段階、最大 500kS/s = 1 秒に 50 万回) で、
C/C++ の `adc_read()` はその値をそのまま返す。MicroPython の `read_u16()` は他のボードとそろえるために
0〜65535 へ引き伸ばして返す (分解能は 12 bit のまま)。
基準電圧は `ADC_VREF` (ピン35) で、Pico 2 基板上では 3.3V の電源をフィルタして
作っている (データシートによる)。ADC は「基準電圧を 4096 等分した何段目か」を返すので、
電圧に戻す式は V = 値 × 3.3V / 4096 (`read_u16()` なら 65535 で割る)。基準を精密に
したいときは `ADC_VREF` に外付けの基準電圧をつなげる。

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む (Pico 2 は USB から給電、AD3 は Scope だけ)
board: full
parts:
  MCU: pico2 @ h5
  CDS1: photoresistor a30 a33 GL5528
  R1: resistor c33 c37 10k
  SC:
    type: device
    at: top
    label: AD3 Scope
    pins: [1+, 1-]
wires:
  - MCU.3V3 -- +t9 red
  - MCU.GND38 -- -t7 black
  - +t30 -- b30 red
  - MCU.GP26 -- d33 yellow
  - d37 -- -t37 black
  - SC.1+ -- e33 yellow
  - SC.1- -- -t42 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/breadboard/03-adc-cds.svg)

- 電源は Pico 2 の USB。`3V3` (ピン 36、9 列の上) を上の + レールへ、`GND` (ピン 38、7 列の上) を上の − レールへ出す
  (11-2 と同じ。USB を挿しただけではレールに出ない)
- CdS (CDS1) は 30〜33 列、R1 は 33〜37 列。33 列が分圧の点 (V<sub>node</sub>) で、GP26 (ピン 31) からの黄の線、
  AD3 の 1+ (黄) も同じ 33 列に挿す。CDS1 の左端 (30 列) は + レール、R1 の右端 (37 列) は − レールへ
- AD3 は電源に使わず、**オシロ (Scope) だけ**をつなぐ。1+ は V<sub>node</sub> (33 列) に、1− (黒) は − レール (GND) へ。
  Scope の入力は 1MΩ なので、10kΩ の分圧にほとんど負荷をかけない (ずれは 1% ほど)
- ブレッドボードを流れる電流は、CdS が 1kΩ (明るい) のとき最大でも 3.3V ÷ (1kΩ + 10kΩ) = 0.3mA。
  ブレッドボードの範囲 (1 穴 200mA・ブレッドボード全体 500mA) に収まる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | マイコン | Raspberry Pi Pico 2 (USB で給電) |
| CDS1 | CdS セル | GL5528 |
| R1 | 抵抗 (分圧) | 10kΩ |
| — | 計器 | Analog Discovery 3 の Scope (1+ = V<sub>node</sub>、1− = GND) |

## 計器の設定

計器は AD3 のオシロ (Scope)。**CdS を手で覆った瞬間に V<sub>node</sub> が約 1.65V から約 0.16V へ落ち、手を離すと戻る**のを、
時間の形で見る。覆うのも離すのも 1 回きりの変化なので、トリガを Single (1 回だけ捕まえる) にし、
覆ってから離すまで (約 1.2 秒) を 1 画面に入れる。ここでは室内の明るさ (CdS = 10kΩ) と真っ暗 (200kΩ) を例にした
(上の計算値。CdS の抵抗は個体差が大きい目安)。

| 項目 | 値 |
| --- | --- |
| 電源 | Pico 2 の USB (AD3 の Supplies は使わない) |
| CH1 (1+) | V<sub>node</sub> (33 列)。500mV/div、0V を下から 1 目盛 |
| 1− | GND |
| 時間レンジ | 200ms/div (1 画面 2 秒) |
| トリガ | CH1 の立ち下がり、0.9V (1.65V と 0.16V の中ほど)、Single。トリガの点を左から 2 目盛に置く |
| Measurements | Maximum・Minimum |
| カーソル | X1 を覆う前 (−200ms)、X2 を覆っている間 (600ms) に置く |

```scope
title: 図3 CdS を覆うと分圧の点が約 1.65V から約 0.16V へ落ち、離すと戻る
time: 200ms/div
trigger: ch1 falling 0.9V at -3div
ch1: {wave: = 1.65V - 1.493V * step(t) + 1.493V * step(t - 1.2s) | rc 50ms, range: 500mV/div, position: -3div}
cursors: [-200ms, 600ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/scope/03-adc-cds.svg)

- 図3 の X1 (覆う前) は約 1.65V、X2 (覆っている間) は約 0.16V。上の計算値の表の「室内」と「真っ暗」の行と同じ値で、
  プログラムが出す電圧 (V = 値 × 3.3V / 4096) とも一致する
- 図は理想の形。覆う動きと CdS の応答は実際には時間がかかる (CdS は光が変わってから数十 ms〜数百 ms かけて変わる。目安)。
  図では手の動きを時定数 50ms のなめらかな変化で表した

## プログラム

11-1 と同じく、C/C++ を第 1、MicroPython を第 2 に並べる。どちらも 0.5 秒ごとに GP26 を
読み、値と電圧を PC の画面に出す。

### C/C++ (Pico SDK)

`main.c` (0.5 秒ごとに GP26 を読み、値と電圧を USB シリアルへ出す)。

```c
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/adc.h"

#define ADC_PIN 26      // GP26 = ADC0
#define ADC_INPUT 0
#define ADC_VREF_VOLTS 3.3f
#define ADC_STEPS 4096.0f   // 12 bit

int main(void) {
    stdio_init_all();
    adc_init();
    adc_gpio_init(ADC_PIN);
    adc_select_input(ADC_INPUT);

    while (true) {
        uint16_t value = adc_read();                       // 0〜4095
        float voltage = value * ADC_VREF_VOLTS / ADC_STEPS;
        printf("%u %.3f\n", value, voltage);
        sleep_ms(500);
    }
}
```

- `adc_init()` で ADC を動かし、`adc_gpio_init(26)` で GP26 をアナログ入力に切り替える
- `adc_select_input(0)` で、ADC の入力 0〜3 のうち 0 番 (GP26) を選ぶ
- `adc_read()` が 1 回変換して 0〜4095 の値を返す。`* 3.3 / 4096` で電圧に戻す

`CMakeLists.txt` は 11-2 と同じ形で、名前を `adc` にし、`target_link_libraries` に
`hardware_adc` を足す (`pico_stdlib hardware_adc`)。ビルドと書き込みは 11-1 と同じ
(`cmake -B build -DPICO_BOARD=pico2 && cmake --build build`、`.uf2` を BOOTSEL のドライブへ)。

### MicroPython

`ADC(26)` が GP26 の ADC を用意し、`adc.read_u16()` が 0〜65535 の値を返す。

```python
from machine import ADC
import time

adc = ADC(26)  # GP26 = ADC0

while True:
    value = adc.read_u16()          # 0〜65535
    voltage = value * 3.3 / 65535
    print(value, voltage)
    time.sleep(0.5)
```

C/C++ は `PICO_BOARD=pico2` の `.uf2` までビルドが通ることを確かめた。
実機では動かしていない。MicroPython は実行していない (未確認)。

## 見るべき値

値は USB シリアル (C/C++) か Thonny の画面 (MicroPython) で読む。

| 測る所 | 期待する値 |
| --- | --- |
| テスターの直流電圧レンジで GP26 (ピン 31) と GND の間 | プログラムが出す電圧とほぼ同じ |
| 明るい場所 (CdS に光を当てる) の値 | 大きい (`adc_read()` で 3000 台、`read_u16()` で 5 万台、計算値) |
| CdS を手で覆ったときの値 | 小さい (`adc_read()` で数百、`read_u16()` で数千、計算値) |
| CdS と R1 を入れ替えたとき | 明暗の関係が逆になる (暗いほど値が大きい) |

CdS の抵抗は個体差が大きく、上の表の値は目安。実際の値は
表示させながら手で覆ったり光を当てたりして確かめる。

## 出典

自作。ADC の仕様 (12 bit・500kS/s) は RP2350 データシート (12.4 ADC)、
`ADC_VREF` の説明は Raspberry Pi Pico 2 データシートによる。
