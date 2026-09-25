---
book: circuits
chapter: 11
id: 11-4
title: PWM で LED 調光とサーボ
tier: 100
source: 自作
era: 今
---

# 11-4 PWM で LED 調光とサーボ

**PWM (パルス幅変調)** は、H と L を高速に繰り返し、H の割合 (デューティ比)
で「実質の電圧」や「角度」を伝える方式。11-1 の L チカと同じ回路で LED を
**調光**でき、サーボモータの**角度**も PWM のパルス幅だけで指定できる。

## 回路図

LED の調光は 11-1 と**同じハードウェア**で、ソフトウェアが単純な ON/OFF から
PWM に変わるだけ。

```circuit
title: 図1 GP15でLEDをPWM調光
parts:
  U1: pico e3c0 mirror
  R1: resistor i6 i8 330
  D1: led i8 k8 red
  G1: ground k8
wires:
  - U1.GP15 -| i6
style:
  pitch: 1.2
```

サーボは **5V (VBUS) で電源を取り、信号線だけ Pico の GPIO** につなぐ。

```circuit
title: 図2 GP14でサーボを回す
parts:
  U1: pico g4
  SV1:
    type: device
    at: d10
    label: Servo
    pins: [VCC, GND, SIG]
wires:
  - U1.VBUS -| c6e0 |- SV1.VCC
  - U1.GND38 -- SV1.GND
  - U1.GP14 -| l2 -- l7 |- SV1.SIG
style:
  pitch: 1.2
```

- **LED**: 11-1 と同じ 330Ω + 赤色 LED。GP15 を単純な H/L ではなく、
  短い周期 (例えば 1kHz) で H の時間比 (デューティ比) を変えて出すと、
  人の目には**明るさが変わって**見える (残像で平均化される)
- **サーボ**: SG90 などの小型サーボは 3 本線 (電源・GND・信号)。
  **信号は 20ms 周期のパルスで、パルス幅 1.5ms が中央 (0°)、1.0ms が
  −90°、2.0ms が +90°** という約束
- **サーボの電源は VBUS (USB の 5V) から取る。** Pico 自身の 3V3
  レギュレータは数百mA しか出せず、サーボの起動時の突入電流 (SG90 で
  瞬間 500mA 程度) を賄えないことがある。GND は Pico と必ず共通にする
- **信号は 3.3V ロジックのまま**でも SG90 クラスは多くの場合動くが、
  確実にするならレベル変換 (10-17) を挟むか、入力のしきい値が低い 74HCT 系
  (5V で動き、V<sub>IH</sub> は 2.0V) を 1 段はさむとよい。3.3V が 5V 系の
  V<sub>IH</sub> を満たすとは限らない

## 見るべき値

```python
from machine import Pin, PWM
import time

led = PWM(Pin(15))
led.freq(1000)  # 1kHz、ちらつきが見えない周波数

for duty in range(0, 65536, 4096):   # 徐々に明るく
    led.duty_u16(duty)
    time.sleep(0.05)
```

| デューティ比 | LED の平均電流 (計算値) | 明るさ |
| --- | --- | --- |
| 0% | 0mA | 消灯 |
| 25% | 約1.0mA | 暗い |
| 50% | 約2.0mA | 半分点灯 |
| 100% | 約3.9mA (11-1 と同じ) | 最大 |

平均電流はデューティ比にほぼ比例するが、**人の目に見える明るさは比例しない**
(目は対数に近く反応するので、50% デューティは「半分の明るさ」には見えにくい)。

サーボは次のように角度を指定する。

```python
from machine import Pin, PWM
import time

servo = PWM(Pin(14))
servo.freq(50)          # 20ms周期

def set_pulse_ms(ms):
    servo.duty_u16(int(ms / 20 * 65535))

set_pulse_ms(1.5)   # 中央 (0°)
time.sleep(1)
set_pulse_ms(1.0)   # -90°
time.sleep(1)
set_pulse_ms(2.0)   # +90°
```

| パルス幅 | `duty_u16()` の値 (計算値) | 角度の目安 |
| --- | --- | --- |
| 1.0ms | 約3277 | −90° |
| 1.5ms | 約4915 | 0° (中央) |
| 2.0ms | 約6554 | +90° |

## 出典

自作。
