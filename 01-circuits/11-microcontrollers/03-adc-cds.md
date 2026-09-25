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

8-1 の CdS はコンパレータで「暗い/明るい」の 2 値にしていたが、Pico の
**ADC (アナログ→デジタル変換)** を使えば、明るさを**連続した数値**として
読める。GP26 (ADC0) で CdS の分圧電圧を測る。

## 回路図

```circuit
title: 図1 CdS分圧をADC0(GP26)で読む
parts:
  U1: pico b2
  CDS1: photoresistor e10 e13
  R1: resistor e13 e16 10k
  G1: ground e16
wires:
  - U1.3V3 |- e10
  - U1.GP26 -| e13
```

- CdS を **3V3 側** (Pico 自身が出す 3.3V 基準電源)、固定抵抗 R1 (10kΩ) を
  **GND 側**に置いた分圧。明るい (CdS の抵抗が下がる) ほど、ADC が読む
  電圧は 3.3V に近づく
- CdS (硫化カドミウムセル、代表的な GL5528) の抵抗は明るさで大きく変わる:
  明るい部屋で目安 1kΩ 前後、真っ暗で目安 200kΩ 以上
- R1 = 10kΩ は CdS の**室内の明るさでの抵抗と同じ桁**に選んである。
  こうすると室内光でだいたい半分の電圧になり、ADC の可動範囲を無駄なく使える

**計算値** (V<sub>node</sub> = 3.3V × R1 / (R<sub>CdS</sub> + R1)):

| 明るさ | CdS の抵抗 (目安) | V<sub>node</sub> | `read_u16()` の値 (0〜65535) |
| --- | --- | --- | --- |
| 明るい | 約1kΩ | 約3.0V | 約59500 |
| 室内 | 約10kΩ (R1 と同じ) | **1.65V (半分)** | **約32768 (半分)** |
| 真っ暗 | 約200kΩ | 約0.16V | 約3100 |

Pico の ADC は物理には 12 bit (0〜4095) だが、MicroPython の
`read_u16()` は他のボードとそろえるために 0〜65535 へ引き伸ばして返す。
基準電圧は `3V3` (ADC_VREF、ピン35) で、Pico 基板上で `3V3` (ピン36) と
つながっている。

## 見るべき値

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

| 測る所 | 期待する値 |
| --- | --- |
| 明るい場所 (CdS に光を当てる) の `value` | 大きい (5万台、計算値) |
| CdS を手で覆ったときの `value` | 小さい (数千、計算値) |
| CdS と R1 を入れ替えたとき | 明暗の関係が逆になる (暗いほど値が大きい) |

CdS の抵抗は個体差が大きく、上の表の値は**目安**。実際の境目は
`print()` で表示させながら手で確かめるとよい。

## 出典

自作。
