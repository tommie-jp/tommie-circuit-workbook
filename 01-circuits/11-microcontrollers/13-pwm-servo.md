---
book: circuits
chapter: 11
id: 11-13
title: サーボの角度を PWM のパルス幅で決める
tier: 100
board: BB
source: 自作
era: 今
---

# 11-13 サーボの角度を PWM のパルス幅で決める

**先に 11-4 (PWM で LED 調光とサーボ) を組んでおく。** この題は 11-4 の図3 の基板 (GP14 にサーボ、サーボは別の 5 V 電源) で、
サーボの角度を PWM のパルス幅で決めるプログラムを動かし、GP14 のパルスをオシロで測る。
サーボの信号の約束 (20 ms 周期、パルス幅 1.0〜2.0 ms)・別電源の注意・PWM のスライスの説明は 11-4 のまま。

11-4 の図3 の基板と AD3 のつなぎ方をそのまま使い、プログラムと測り方だけを足す題なので、回路図と実体配線図は再掲しない。

## 計器の設定

計器は AD3 のオシロ (Scope)。サーボの信号は周期 20 ms のうち 1〜2 ms しか H にならない細いパルスなので、オシロで幅を測る。

| 項目 | 値 |
| --- | --- |
| 電源 | Pico 2 の USB (AD3 の Supplies は使わない) |
| CH2 (2+) | GP14 (サーボ)。1 V/div |
| 1−・2− | GND |
| サーボのとき (図1) | 時間レンジ 500 µs/div、トリガ CH2 の立ち上がり 1.65 V。パルスの幅 (1.5 ms = 3 目盛) を目盛で読む。カーソル X1 を H の中 (750 µs)、X2 を L の中 (3 ms) に置く。周期 20 ms は 5 ms/div に替えると 2 周期見える |
| Measurements | Maximum・Minimum |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図1 GP14 のサーボ信号 — 周期 20ms、パルス幅 1.5ms (中央)
time: 500us/div
trigger: ch1 rising 1.65V at -4div
ch1: {wave: pulse 50Hz 1.65V offset 1.65V duty 7.5%, range: 1V/div, position: -3div}
cursors: [750us, 3ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/scope/13-pwm-servo.svg)

- 図1 の H の幅は 1.5 ms (500 µs/div で 3 目盛) で、周期 20 ms の 7.5%。X1 は H の中で 3.30 V、X2 は L の中で 0 V。1.0 ms なら 5%、2.0 ms なら 10%。トリガを立ち上がりにするとパルスの始まりが左端に固定される
- 図は理想の形。実機のエッジはなまり、H は 3.3 V に少し足りないことがある

## プログラム

11-1 と同じく、C/C++ を第 1、MicroPython を第 2 に並べる。ビルドと書き込みは 11-4 と同じ
(`CMakeLists.txt` の名前は `pwmservo`)。GP14 は LED の GP15 と同じスライス 7 なので、11-4 の LED のプログラムとは別々に使う。

C/C++ (Pico SDK): `main.c` (20 ms 周期、1 カウントを 1 µs にしてパルス幅をそのまま指定する)。
分周比 150 でカウンタは 1 MHz (1 カウント 1 µs) で進み、`WRAP` を 19999 にすると 20000 カウント
= 20 ms で 1 周期になる。レベルを 1500 にすれば H が 1500 µs = 1.5 ms 続く。

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

MicroPython: `duty_u16()` は 20 ms を 65535 とする割合で書くので、パルス幅 ms を
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

サーボのパルス幅と、プログラムに書く値:

| パルス幅 | `pwm_set_gpio_level()` の値 (C/C++、1 µs 単位) | `duty_u16()` の値 (MicroPython、`int()` で切り捨てた計算値) | 角度の目安 |
| --- | --- | --- | --- |
| 1.0 ms | 1000 | 3276 | −90° |
| 1.5 ms | 1500 | 4915 | 0° (中央) |
| 2.0 ms | 2000 | 6553 | +90° |

C/C++ は `PICO_BOARD=pico2` の `.uf2` までビルドが通ることを確かめた。
実機では動かしていない。MicroPython は実行していない (未確認)。

## LTspice での確かめ

この題は LTspice の対象外 (回路は 11-4 のまま。サーボの角度とトルクは SPICE の対象外)。パルス幅と値は算術で確かめた。
分周比 150 で 150 MHz → 1 MHz (1 カウント 1 µs)、`WRAP` 19999 で 20 ms。
`duty_u16()` の値は 1.0 ms: 1/20 × 65535 = 3276.75 → 3276、1.5 ms: 4915.1 → 4915、2.0 ms: 6553.5 → 6553 で、表と合う。

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`・`npm run pico`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| サーボ: 周期 | 20 ms (50 Hz) | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| サーボ: パルス幅 | 1.5 ms → 1.0 ms → 2.0 ms の順 (誤差 1 µs 未満) | C: Pico SDK のモック・MicroPython: `machine` のスタブ |

見ていない物: サーボの実際の角度・別電源。PWM の出力は picoemu の GPIO の記録に出ないので、picoemu では見ていない

## 出典

自作。PWM の API は [Pico SDK](https://github.com/raspberrypi/pico-sdk) (`hardware_pwm`) による。
