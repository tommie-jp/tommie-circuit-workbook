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
  U1: pico2 e3c0 mirror
  R1: resistor i6 i8 330
  D1: led i8 k8 red
  G1: ground k8
wires:
  - U1.GP15 -| i6
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/04-pwm-led-servo-1.svg)

サーボは **5V (VBUS) で電源を取り、信号線だけ Pico 2 の GPIO** につなぐ。

```circuit
title: 図2 GP14でサーボを回す
parts:
  U1: pico2 g4
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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/04-pwm-led-servo-2.svg)

- **LED**: 11-1 と同じ 330Ω + 赤色 LED。GP15 を単純な H/L ではなく、
  短い周期 (例えば 1kHz) で H の時間比 (デューティ比) を変えて出すと、
  人の目には**明るさが変わって**見える (残像で平均化される)
- **サーボ**: SG90 などの小型サーボは 3 本線 (電源・GND・信号)。
  **信号は 20ms 周期のパルスで、パルス幅 1.5ms が中央 (0°)、1.0ms が
  −90°、2.0ms が +90°** という約束
- **サーボの電源は VBUS (USB の 5V) から取る。** Pico 2 自身の 3V3
  は、データシートが外部への負荷を 300mA 未満にとどめるよう勧めている。
  サーボの起動時の突入電流 (SG90 で瞬間 500mA 程度) はこれを超えうる。GND は Pico 2 と必ず共通にする
- **信号は 3.3V ロジックのまま**でも SG90 クラスは多くの場合動くが、
  確実にするならレベル変換 (10-17) を挟むか、入力のしきい値が低い 74HCT 系
  (5V で動き、V<sub>IH</sub> は 2.0V) を 1 段はさむとよい。3.3V が 5V 系の
  V<sub>IH</sub> を満たすとは限らない

## プログラム

C/C++ を第 1、MicroPython を第 2 に並べる。この教科書の標準で、実行時間が読みやすい
C/C++ を先にし、手軽に試せる MicroPython を添える。ビルドと書き込みは 11-1 と同じ
(`CMakeLists.txt` は名前を `pwmled`・`pwmservo` にし、`target_link_libraries` を
`pico_stdlib hardware_pwm` にする。`cmake -B build -DPICO_BOARD=pico2 && cmake --build build`、
`.uf2` を BOOTSEL のドライブへ)。

**GP14 と GP15 は Pico 2 の同じ PWM スライス (スライス 7) の A・B 出力で、周期
(周波数) を共有する。** 1kHz の LED と 50Hz のサーボを同時に出すことはできないので、
下の 2 つのプログラムは別々に使う (同時に使うなら、ピンを別のスライスに替える)。

### LED の調光

C/C++ (Pico SDK): `main.c` (1kHz、デューティを 16 段階で上げる)。

```c
#include "pico/stdlib.h"
#include "hardware/pwm.h"

#define LED_PIN 15
#define WRAP 999            // 1000 カウントで 1 周期
#define STEPS 16

int main(void) {
    gpio_set_function(LED_PIN, GPIO_FUNC_PWM);
    uint slice = pwm_gpio_to_slice_num(LED_PIN);
    pwm_set_clkdiv(slice, 150.0f);     // 150MHz ÷ 150 ÷ 1000 = 1kHz
    pwm_set_wrap(slice, WRAP);
    pwm_set_gpio_level(LED_PIN, 0);
    pwm_set_enabled(slice, true);

    for (int step = 0; step < STEPS; step++) {     // 徐々に明るく
        pwm_set_gpio_level(LED_PIN, (WRAP + 1) * step / STEPS);
        sleep_ms(50);
    }
    while (true) tight_loop_contents();            // 最後の明るさのまま
}
```

`150.0f` は Pico 2 の既定のシステムクロック 150MHz を前提にした分周比。

MicroPython:

```python
from machine import Pin, PWM
import time

led = PWM(Pin(15))
led.freq(1000)  # 1kHz、ちらつきが見えない周波数

for duty in range(0, 65536, 4096):   # 徐々に明るく
    led.duty_u16(duty)
    time.sleep(0.05)
```

### サーボの角度

C/C++ (Pico SDK): `main.c` (20ms 周期、1 カウントを 1µs にしてパルス幅をそのまま指定する)。

```c
#include "pico/stdlib.h"
#include "hardware/pwm.h"

#define SERVO_PIN 14
#define WRAP 19999          // 20000 カウント = 20ms 周期

static void set_pulse_us(uint16_t us) {
    pwm_set_gpio_level(SERVO_PIN, us);   // 1 カウント = 1µs
}

int main(void) {
    gpio_set_function(SERVO_PIN, GPIO_FUNC_PWM);
    uint slice = pwm_gpio_to_slice_num(SERVO_PIN);
    pwm_set_clkdiv(slice, 150.0f);     // 150MHz ÷ 150 = 1MHz (1 カウント 1µs)
    pwm_set_wrap(slice, WRAP);
    pwm_set_enabled(slice, true);

    set_pulse_us(1500); sleep_ms(1000);   // 中央 (0°)
    set_pulse_us(1000); sleep_ms(1000);   // -90°
    set_pulse_us(2000);                   // +90°
    while (true) tight_loop_contents();
}
```

MicroPython:

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

## 見るべき値

| デューティ比 | LED の平均電流 (計算値) | 明るさ |
| --- | --- | --- |
| 0% | 0mA | 消灯 |
| 25% | 約1.0mA | 暗い |
| 50% | 約2.0mA | 半分点灯 |
| 100% | 約3.9mA (11-1 と同じ) | 最大 |

平均電流はデューティ比にほぼ比例するが、**人の目に見える明るさは比例しない**
(目は対数に近く反応するので、50% デューティは「半分の明るさ」には見えにくい)。

| パルス幅 | `pwm_set_gpio_level()` の値 (C/C++、1µs 単位) | `duty_u16()` の値 (MicroPython、計算値) | 角度の目安 |
| --- | --- | --- | --- |
| 1.0ms | 1000 | 約3277 | −90° |
| 1.5ms | 1500 | 約4915 | 0° (中央) |
| 2.0ms | 2000 | 約6554 | +90° |

C/C++ は `PICO_BOARD=pico2` の `.uf2` までビルドが通ることを確かめた。
**実機では動かしていない。** MicroPython は実行していない (未確認)。

## 出典

自作。Pico 2 の 3V3 の負荷の目安 (300mA 未満) は Raspberry Pi Pico 2 データシート、
PWM の API は Pico SDK (`hardware_pwm`) による。
