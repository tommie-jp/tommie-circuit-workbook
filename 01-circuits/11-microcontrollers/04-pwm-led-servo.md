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

マイコンのピンは H と L の 2 つしか出せない。それでも LED の明るさを途中の段階に
したり、モータの角度を決めたりできるのが PWM (パルス幅変調)。H と L を速く繰り返し、
1 周期のうち H の時間の割合 (デューティ比) で「平均の電圧」や「角度」を伝える。
3-6 では 555 で作った PWM を、ここではマイコンで作る。11-1 の L チカと同じ回路で LED を
調光し、サーボモータ (信号で決めた角度まで回って止まるモータ) の角度も PWM の
パルス幅で指定する。

## 回路図

LED の調光は 11-1 と同じ回路 (図1) で、プログラムが単純な ON/OFF から
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

サーボ (図2) は 5V (VBUS) で電源を取り、信号線だけを Pico 2 の GPIO (GP14) につなぐ。

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

- LED: 11-1 と同じ 330Ω + 赤色 LED。GP15 を単純な H/L ではなく、
  短い周期 (例えば 1kHz = 1 秒に 1000 回) でデューティ比を変えて出すと、
  人の目には明るさが変わって見える (目は速い点滅を追えず、平均の明るさに見える)
- サーボ: SG90 などの小型サーボは 3 本線 (電源・GND・信号)。
  信号は 20ms 周期のパルスで、パルス幅 1.5ms が中央 (0°)、1.0ms が
  −90°、2.0ms が +90° という約束
  (目安。品によっては 1.0〜2.0ms で ±45° ほどしか回らず、0.5〜2.4ms で ±90° のものもある)
- サーボの電源は VBUS (ピン 40、USB の 5V) から取る。Pico 2 自身の 3V3
  は、データシートが外部への負荷を 300mA 未満にとどめるよう勧めている。
  サーボの起動時の突入電流 (SG90 で瞬間 500mA 程度) はこれを超えうる。GND は Pico 2 と必ず共通にする
- 信号は 3.3V のロジックのままでも、SG90 クラスは多くの場合動く。ただし 5V で動く回路の
  V<sub>IH</sub> (H と認める最低の入力電圧) を 3.3V が満たすとは限らない。確実にするなら
  レベル変換 (10-17) を挟むか、入力のしきい値が低い 74HCT 系 (5V で動き、V<sub>IH</sub> は
  2.0V) を 1 段はさむ

## プログラム

11-1 と同じく、C/C++ を第 1、MicroPython を第 2 に並べる。ビルドと書き込みは 11-1 と同じ
(`CMakeLists.txt` は名前を `pwmled`・`pwmservo` にし、`target_link_libraries` を
`pico_stdlib hardware_pwm` にする。`cmake -B build -DPICO_BOARD=pico2 && cmake --build build`、
`.uf2` を BOOTSEL のドライブへ)。

Pico 2 の PWM は、スライスと呼ぶ発生器がいくつか並んで受け持つ。1 つのスライスは A・B の
2 本のピンに出せるが、周期 (周波数) は 2 本で共通になる。GP14 と GP15 は同じスライス 7 の
A・B 出力なので、1kHz の LED と 50Hz のサーボを同時に出すことはできない。下の 2 つの
プログラムは別々に使う (同時に使うなら、どちらかのピンを別のスライスのピンに替える)。

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

PWM は、カウンタが 0 から `WRAP` まで数えて 0 に戻るのを 1 周期とし、カウンタが
「レベル」より小さい間だけ H を出す。

- `gpio_set_function(LED_PIN, GPIO_FUNC_PWM)` で GP15 を PWM の出力に切り替え、
  `pwm_gpio_to_slice_num()` で GP15 のスライスの番号を得る
- `pwm_set_clkdiv(slice, 150.0f)` でカウンタを数える速さを決める。`150.0f` は Pico 2 の
  既定のシステムクロック 150MHz を 150 で割る分周比で、カウンタは 1MHz で進む
- `pwm_set_wrap(slice, 999)` で 1 周期を 1000 カウントにする。1MHz ÷ 1000 = 1kHz
- `pwm_set_gpio_level()` がレベル (H の長さ) を決める。0 で常に L、1000 で常に H。
  ループで 0、62、125、… と 16 段階に上げる (最後は 937 で約 94%)
- `pwm_set_enabled(slice, true)` で動かし始める。`tight_loop_contents()` は何もしない待ち

MicroPython: `PWM(Pin(15))` で PWM を用意し、`freq(1000)` で周波数、`duty_u16()` で
デューティ比を 0〜65535 で決める (65535 で 100%)。

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
分周比 150 でカウンタは 1MHz (1 カウント 1µs) で進み、`WRAP` を 19999 にすると 20000 カウント
= 20ms で 1 周期になる。レベルを 1500 にすれば H が 1500µs = 1.5ms 続く。

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

MicroPython: `duty_u16()` は 20ms を 65535 とする割合で書くので、パルス幅 ms を
`ms / 20 × 65535` に直す。

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

LED の電流は、テスターの直流電圧レンジで R1 の両端を測り、330Ω で割って求める
(多くのテスターは速い PWM の平均の電圧を示す)。Analog Discovery 3 のオシロで GP15 を
見ると、周期 1ms のまま H の幅だけが変わるのが分かる (0-3)。

| デューティ比 | LED の平均電流 (計算値) | 明るさ |
| --- | --- | --- |
| 0% | 0mA | 消灯 |
| 25% | 約1.0mA | 暗い |
| 50% | 約2.0mA | 半分点灯 |
| 100% | 約3.9mA (11-1 と同じ) | 最大 |

平均電流はデューティ比にほぼ比例する (3.9mA × デューティ比) が、人の目に見える明るさは
比例しない。目は対数に近く反応するので、50% デューティは「半分の明るさ」には見えにくい。

サーボのパルス幅と、プログラムに書く値:

| パルス幅 | `pwm_set_gpio_level()` の値 (C/C++、1µs 単位) | `duty_u16()` の値 (MicroPython、`int()` で切り捨てた計算値) | 角度の目安 |
| --- | --- | --- | --- |
| 1.0ms | 1000 | 3276 | −90° |
| 1.5ms | 1500 | 4915 | 0° (中央) |
| 2.0ms | 2000 | 6553 | +90° |

C/C++ は `PICO_BOARD=pico2` の `.uf2` までビルドが通ることを確かめた。
実機では動かしていない。MicroPython は実行していない (未確認)。

## 出典

自作。Pico 2 の 3V3 の負荷の目安 (300mA 未満) は Raspberry Pi Pico 2 データシート、
PWM の API は Pico SDK (`hardware_pwm`) による。
