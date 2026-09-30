---
book: circuits
chapter: 11
id: 11-3
title: ADC で CdS を読む
tier: 100
source: 自作
era: 今
---

# 11-3 ADC で CdS を読む

8-1 の CdS はコンパレータで「暗い/明るい」の 2 値にしていたが、Pico 2 (RP2350) の
**ADC (アナログ→デジタル変換)** を使えば、明るさを**連続した数値**として
読める。GP26 (ADC0) で CdS の分圧電圧を測る。

## 回路図

```circuit
title: 図1 CdS分圧をADC0(GP26)で読む
parts:
  U1: pico2 d3
  CDS1: photoresistor a6i0 c6i0
  R1: resistor c6i0 e6i0 10k
  G1: ground e6i0
wires:
  - U1.3V3 -| a5i0 -- a6i0
  - U1.GP26 -| c6i0
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/03-adc-cds.svg)

- CdS を **3V3 側** (Pico 2 自身が出す 3.3V 基準電源)、固定抵抗 R1 (10kΩ) を
  **GND 側**に置いた分圧。明るい (CdS の抵抗が下がる) ほど、ADC が読む
  電圧は 3.3V に近づく
- CdS (硫化カドミウムセル、代表的な GL5528) の抵抗は明るさで大きく変わる:
  明るい部屋で目安 1kΩ 前後、真っ暗で目安 200kΩ 以上
- R1 = 10kΩ は CdS の**室内の明るさでの抵抗と同じ桁**に選んである。
  こうすると室内光でだいたい半分の電圧になり、ADC の可動範囲を無駄なく使える

**計算値** (V<sub>node</sub> = 3.3V × R1 / (R<sub>CdS</sub> + R1)):

| 明るさ | CdS の抵抗 (目安) | V<sub>node</sub> | `adc_read()` の値 (0〜4095) | `read_u16()` の値 (0〜65535) |
| --- | --- | --- | --- | --- |
| 明るい | 約1kΩ | 約3.0V | 約3700 | 約59500 |
| 室内 | 約10kΩ (R1 と同じ) | **1.65V (半分)** | **約2048 (半分)** | **約32768 (半分)** |
| 真っ暗 | 約200kΩ | 約0.16V | 約200 | 約3100 |

Pico 2 の ADC は 12 bit (0〜4095、最大 500kS/s) で、C/C++ の `adc_read()` はその
値をそのまま返す。MicroPython の `read_u16()` は他のボードとそろえるために
0〜65535 へ引き伸ばして返す (分解能は 12 bit のまま)。
基準電圧は `ADC_VREF` (ピン35) で、Pico 2 基板上では 3.3V の電源をフィルタして
作っている (データシートによる)。したがって変換式は
V = 値 × 3.3V / 4096 (`read_u16()` なら 65535 で割る)。基準を精密にしたいときは
`ADC_VREF` に外付けの基準電圧をつなげる。

## プログラム

C/C++ を第 1、MicroPython を第 2 に並べる。この教科書の標準で、実行時間が読みやすい
C/C++ を先にし、手軽に試せる MicroPython を添える。

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

`CMakeLists.txt` は 11-2 と同じ形で、名前を `adc` にし、`target_link_libraries` に
`hardware_adc` を足す (`pico_stdlib hardware_adc`)。ビルドと書き込みは 11-1 と同じ
(`cmake -B build -DPICO_BOARD=pico2 && cmake --build build`、`.uf2` を BOOTSEL のドライブへ)。

### MicroPython

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
**実機では動かしていない。** MicroPython は実行していない (未確認)。

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| 明るい場所 (CdS に光を当てる) の値 | 大きい (`adc_read()` で 3000 台、`read_u16()` で 5 万台、計算値) |
| CdS を手で覆ったときの値 | 小さい (`adc_read()` で数百、`read_u16()` で数千、計算値) |
| CdS と R1 を入れ替えたとき | 明暗の関係が逆になる (暗いほど値が大きい) |

CdS の抵抗は個体差が大きく、上の表の値は**目安**。実際の境目は
表示させながら手で確かめるとよい。

## 出典

自作。ADC の仕様 (12 bit・500kS/s) は RP2350 データシート (12.4 ADC)、
`ADC_VREF` の説明は Raspberry Pi Pico 2 データシートによる。
