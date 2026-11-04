---
book: circuits
chapter: 11
id: 11-9
title: モータドライバ (DRV8833)
tier: 200
source: 自作
era: 今
---

# 11-9 モータドライバ (DRV8833)

7-3 では、スイッチ 4 つの H ブリッジでモータの向きを替えた。DRV8833 (TI) は、その H ブリッジを MOSFET で 2 組 (A と B) 持つ IC で、
入力 2 本 (AIN1・AIN2) の H・L の組で、前進・後進・ブレーキ・空転を選ぶ。入力の 1 本を PWM にすれば速さも決まる。
ここでは Pico 2 の PWM 2 本で A 側を動かし、7-2 と同じ小型のモータを、前進 50 % → ブレーキ → 後進 50 % → ブレーキと回す。

| AIN1 | AIN2 | AOUT1 | AOUT2 | 働き |
| --- | --- | --- | --- | --- |
| L | L | 開放 | 開放 | 空転 (コースト) |
| L | H | L | H | 後進 |
| H | L | H | L | 前進 |
| H | H | L | L | ブレーキ |

(TI の DRV8833 データシートの Table 1)。**AIN1 を H にしたまま AIN2 を PWM にする**と、「前進」と「ブレーキ」を行き来する。
ブレーキの間もモータの電流は下側の 2 つの MOSFET を回って流れ続ける (スロー減衰)。AIN2 が L の割合が、モータに掛かる平均の電圧の割合になる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Pico 2 の PWM 2 本で DRV8833 の A 側の H ブリッジを動かす
parts:
  U1: pico2 3,3 mirror
  G4: ground 1.75,1.25 r90
  U2:
    type: device
    model: DRV8833-POLOLU
    label: DRV8833
    at: 12,5.5
    pins: [SLP, VIN, AIN1, AIN2, AOUT1, AOUT2, GND]
  V5: vcc 10.75,4 5V
  G1: ground 11,7
  R1: resistor 8.5,6.25 8.5,7.25 15
  M1: motor 8.5,7.25 8.5,8.25
wires:
  - U1.GND38 -- 1.75,1.25
  - U1.GP14 -- U2.AIN1
  - U1.GP15 -- U2.AIN2
  - U2.VIN -- 10.75,5 -- 10.75,4
  - U2.SLP -- 10.75,4.75
  - U2.GND -| 11,7
  - U2.AOUT1 -- 8.5,5.75 -- 8.5,6.25
  - 8.5,8.25 -- 10.25,8.25 -- 10.25,6 -- U2.AOUT2
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/09-drv8833-motor.svg)

- GP14 (AIN1) と GP15 (AIN2) は、RP2350 の PWM の同じスライス (7 番) の A と B。同じ周波数 (20 kHz) で、H の長さだけ別に決められる
- DRV8833 は Pololu 2130 の基板 (DRV8833 Dual Motor Driver Carrier) で使う。モータの電源 VIN は 5 V、入力の H は 2 V 以上 (データシートの V<sub>IH</sub>) なので、
  Pico 2 の 3.3 V の出力でそのまま動く
- SLP (nSLEEP) は L だと IC が眠ったまま。H の下限が 2.5 V なので VIN (5 V) につなぐ (入力の推奨は 5.75 V まで)
- R1 (15 Ω (オーム)、1 W) は 7-2 と同じ電流の制限。モータを手で止めても (停動)、5 V ÷ (15 Ω + 11.8 Ω + 0.36 Ω) ≈ 0.18 A に収まる
  (11.8 Ω は RF-300CA の 2 V で停動 0.17 A から、0.36 Ω は DRV8833 の上下の MOSFET のオン抵抗 200 mΩ + 160 mΩ)
- モータの 5 V は Pico 2 とは別の USB アダプタ (1 A 以上) から取る。AD3 の Supplies は 5 V で 50 mA ほどまでなので足りない。GND は Pico 2 とつなぐ

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 DRV8833 のモジュールとモータは基板の外。モータの 5 V は別の USB アダプタから
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor i48 i53 15
  PS:
    type: device
    at: bottom
    label: 5V USB アダプタ
    pins: [V+, GND]
  DRV:
    type: device
    model: DRV8833-POLOLU
    at: bottom
    label: DRV8833 モジュール
    pins: [AIN1, AIN2, GND, SLP, VIN, AOUT1, AOUT2]
  M1:
    type: device
    at: bottom
    label: DC モータ RF-300CA
    pins: [1, 2]
  SC:
    type: device
    at: top
    label: AD3 Scope
    pins: [1+, 2+, 1-, 2-]
wires:
  - MCU.GND38 -- -t7 black
  - -t62 -- -b62 black
  - DRV.AIN1 -- j23 yellow
  - MCU.GP15 -- i27 green
  - DRV.AIN2 -- j27 green
  - DRV.GND -- -b30 black
  - DRV.SLP -- +b32 red
  - DRV.VIN -- +b34 red
  - DRV.AOUT1 -- j48 orange
  - j53 -- M1.1 orange
  - DRV.AOUT2 -- j57 blue
  - i57 -- M1.2 blue
  - PS.V+ -- +b12 red
  - PS.GND -- -b13 black
  - SC.1+ -- g27 green
  - SC.2+ -- h48 orange
  - SC.1- -- -t30 black
  - SC.2- -- -t31 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/breadboard/09-drv8833-motor.svg)

- DRV8833 の基板とモータは基板の外に置き、線でつなぐ。ピンの名前は Pololu 2130 の印字と同じ
- Pico 2 の `GND` (7 列の上) を上の − レールへ。上下の − レールは右端の線でつなぐ。下の + レールが 5 V (USB アダプタの V+)
- GP14 (23 列の下) は `j23` から黄の線で AIN1 へ。GP15 (24 列の下) は緑の線で 27 列へ運び、`j27` から AIN2 へ
- SLP と VIN は下の + レール (5 V)、GND は下の − レールへ
- AOUT1 は `j48` へ、R1 (48〜53 列、i 行) を通して `j53` からモータの 1 番へ。AOUT2 は `j57`〜`i57` を通ってモータの 2 番へ
- AD3 は Scope だけ。1+ を AIN2 (`g27`)、2+ を AOUT1 (`h48`) へ、1−・2− を上の − レールへ
- ブレッドボードを通るモータの電流は、停動でも約 0.18 A (計算値)。1 穴の線の 200 mA に収まるが余裕は小さい。止めたまま長く置かない

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | マイコン | Raspberry Pi Pico 2 (USB で給電) |
| U2 (図2 では DRV) | モータドライバの基板 | DRV8833 (Pololu 2130) |
| M1 | DC モータ (7-2 と同じ小電流の品) | マブチ RF-300CA-11440 (0.7〜5.0 V。2 V で無負荷 0.018 A・停動 0.17 A) |
| R1 | 抵抗 (モータの電流の制限、1 W) | 15 Ω |
| — | 電源 | 5 V の USB アダプタ (1 A 以上)。モータの電流が AD3 の Supplies の 50 mA を超えるため |
| — | 計器 | Analog Discovery 3 の Scope (1+ = AIN2、2+ = AOUT1、1−・2− = GND) |

## 計器の設定

計器は AD3 のオシロ (Scope)。前進 50 % の間の AIN2 と AOUT1 を重ねて、**AIN2 が L の間だけ AOUT1 が 5 V になる**のを見る。

| 項目 | 値 |
| --- | --- |
| 電源 | Pico 2 は USB、モータは 5 V の USB アダプタ |
| CH1 (1+) | AIN2 (GP15)。1 V/div、0 V を中央の半目盛上 |
| CH2 (2+) | AOUT1。2 V/div、0 V を下から半目盛 |
| 時間レンジ | 10 µs/div (20 kHz の 2 周期) |
| トリガ | CH1 の立ち上がり、1.65 V。トリガの点を左から 1 目盛に置く |
| Measurements | Frequency・Duty |
| カーソル | X1 を 10 µs (AIN2 が H)、X2 を 35 µs (AIN2 が L) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 前進 50 % — AIN2 (CH1) が L の間だけ AOUT1 (CH2) が 5 V
time: 10us/div
trigger: ch1 rising 1.65V at -4div
ch1: {wave: square 20kHz 1.65V offset 1.65V, range: 1V/div, position: 0.5div}
ch2: {wave: = 5V - 5V * ch1 / 3.3V, range: 2V/div, position: -3.5div}
cursors: [10us, 35us]
measure: [freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/scope/09-drv8833-motor.svg)

- CH1 (AIN2) は 20 kHz・H が 50 %。CH2 (AOUT1) はその裏返しで、AIN2 が L の 25 µs だけ 5 V、H の 25 µs は 0 V (ブレーキ)
- X1 (10 µs) は AIN2 = 3.3 V・AOUT1 = 0 V、X2 (35 µs) は AIN2 = 0 V・AOUT1 = 5 V
- 図は理想の形。実物の AOUT1 の縁には、モータの巻線と配線のインダクタンスによる跳ねが乗る (目安で数百 ns)

## プログラム

### C/C++ (Pico SDK)

```c
#include "pico/stdlib.h"
#include "hardware/pwm.h"

#define PIN_AIN1 14     // PWM スライス 7 の A
#define PIN_AIN2 15     // PWM スライス 7 の B
#define TOP 7499        // 150 MHz ÷ 7500 = 20 kHz

// duty: -100〜100 (%)。正で前進、負で後進、0 でブレーキ (スロー減衰)
static void motor(int duty) {
    uint n = (TOP + 1) * (uint)(duty < 0 ? -duty : duty) / 100;
    if (duty >= 0) {                              // AIN1 = H のまま、AIN2 が L の割合 = duty
        pwm_set_gpio_level(PIN_AIN1, TOP + 1);
        pwm_set_gpio_level(PIN_AIN2, TOP + 1 - n);
    } else {                                      // AIN2 = H のまま、AIN1 が L の割合 = duty
        pwm_set_gpio_level(PIN_AIN1, TOP + 1 - n);
        pwm_set_gpio_level(PIN_AIN2, TOP + 1);
    }
}

int main(void) {
    gpio_set_function(PIN_AIN1, GPIO_FUNC_PWM);
    gpio_set_function(PIN_AIN2, GPIO_FUNC_PWM);
    uint slice = pwm_gpio_to_slice_num(PIN_AIN1);
    pwm_set_clkdiv(slice, 1.0f);
    pwm_set_wrap(slice, TOP);
    motor(0);
    pwm_set_enabled(slice, true);

    while (true) {
        motor(50);  sleep_ms(2000);   // 前進 50 %
        motor(0);   sleep_ms(1000);   // ブレーキ
        motor(-50); sleep_ms(2000);   // 後進 50 %
        motor(0);   sleep_ms(1000);
    }
}
```

- `pwm_set_wrap(slice, 7499)` で、カウンタが 0〜7499 を数えて 1 周期 (150 MHz ÷ 7500 = 20 kHz)。レベルを 7500 にすると、ずっと H
- 20 kHz にしたのは、人の耳に聞こえる高さ (16 kHz ほどまで) より上にして、モータのうなりを聞こえなくするため
- `CMakeLists.txt` は 11-2 と同じ形で、名前を `motor` にし、`target_link_libraries` を `pico_stdlib hardware_pwm` にする

### MicroPython

```python
from machine import Pin, PWM
import time

FREQ = 20_000
ain1 = PWM(Pin(14), freq=FREQ, duty_u16=65535)
ain2 = PWM(Pin(15), freq=FREQ, duty_u16=65535)

def motor(duty):                  # -100〜100 (%)。0 でブレーキ
    n = 65535 * abs(duty) // 100
    if duty >= 0:
        ain1.duty_u16(65535)
        ain2.duty_u16(65535 - n)
    else:
        ain1.duty_u16(65535 - n)
        ain2.duty_u16(65535)

while True:
    motor(50)
    time.sleep(2)
    motor(0)
    time.sleep(1)
    motor(-50)
    time.sleep(2)
    motor(0)
    time.sleep(1)
```

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| モータの回り方 | 前進 2 秒 → 止まる 1 秒 → 逆向き 2 秒 → 止まる 1 秒 |
| AIN2 の PWM | 20 kHz、H が 50 % (前進の間) |
| AOUT1 の平均 (前進 50 %、テスターの直流) | 約 2.5 V (5 V × 50 %) |
| 前進 50 % で手で軸を止めたときの電流 | 約 92 mA (R1 の両端の電圧 ÷ 15 Ω、計算値) |

ブレーキのとき (AIN1・AIN2 とも H) は、空転 (両方 L) よりも速く止まる。プログラムの `motor(0)` を、両方のレベルを 0 にする空転に替えて比べるとよい。

## LTspice での確かめ

`sim/09-drv8833-motor.cir` で、前進・スロー減衰 (AIN1 = H、AIN2 = 20 kHz の PWM) を解いた。DRV8833 の MOSFET は 0.18 Ω のスイッチ、
モータは止めた状態 (逆起電力 0) の巻線を 11.8 Ω + 1 mH (インダクタンスは仮定) で表した。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| AOUT1 の平均 (50 %) | 約 2.5 V | 2.48 V | 合う |
| 停動の電流の平均 (50 %) | 約 92 mA | 92.1 mA | 合う |
| 同 (80 %) | 4.0 V ÷ 27.2 Ω ≈ 147 mA (算術) | 147 mA | 合う |
| 電流の揺れ (50 %) | — | 60 mApp | 追記 (1 mH の仮定による。インダクタンスが大きいほど小さい) |

100 % の停動は 5 V ÷ 27.2 Ω ≈ 0.18 A (算術)。ブレーキの間も電流が流れ続けるので、平均の電流は「平均の電圧 ÷ 抵抗」で決まる。
PWM の周期は算術で確かめた (150 MHz ÷ (7499 + 1) = 20 kHz、50 % で AIN2 のレベル 3750)。

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| PWM の設定 | GP14・GP15 をスライス 7 の PWM に。周期 50 µs (20 kHz) | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 前進 50 % (1 s のとき) | AIN1 が 100 %、AIN2 が H 50 % | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| ブレーキ (2.5 s) と後進 50 % (4 s) | 両方 100 %。後進は AIN1 が H 50 %・AIN2 が 100 % | C: Pico SDK のモック・MicroPython: `machine` のスタブ |

見ていない物: DRV8833 の動作・モータの電流・AOUT1 の波形

## 出典

自作。DRV8833 の入力と出力の表、入力のしきい値、MOSFET のオン抵抗は [TI DRV8833 データシート](https://www.ti.com/lit/ds/symlink/drv8833.pdf) (Table 1・Table 2、Electrical Characteristics) による。

参考: [Pololu DRV8833 Dual Motor Driver Carrier](https://www.pololu.com/product/2130)、[Pico SDK (hardware_pwm)](https://github.com/raspberrypi/pico-sdk)
