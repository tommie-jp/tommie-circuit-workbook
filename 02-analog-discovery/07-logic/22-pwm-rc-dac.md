---
book: analog-discovery
chapter: 7
id: 7-22
title: PWM + RC で DAC
tier: 200
source: 自作 (計器の操作は Digilent の Using the Oscilloscope)
board: BB
---

# 7-22 PWM + RC で DAC

Raspberry Pi Pico 2 には DAC (デジタルからアナログへの変換器) が無い。代わりに **PWM** の方形波を RC のローパスで濾すと、
デューティに比例した直流が出る (平均値だけが残る)。ここでは 10 ビット (1024 段) の PWM を 146.5 kHz で出し、
R1 = 10 kΩ (キロオーム)・C1 = 100 nF (τ (タウ) = 1 ms) で濾して、0・256・512・768 の 4 段の階段を 20 ms ずつ作る。
AD3 の **Scope** で、出力の電圧 (DC の正確さ)、残るさざ波 (リップル)、段が切り替わってから落ち着くまでの時間を測る。
回路の教科書の 11-4 で LED の明るさに使った PWM を、ここでは電圧の源として使う。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 GP16 の PWM を RC で濾して直流にする
parts:
  U1: pico2 3,6
  G2: ground 5,3.2 r270
  R1: resistor 6,10 9,10 10k
  C1: capacitor 9,10 9,12 100n
  G1: ground 9,12
  AD:
    type: device
    at: 13,9.6
    label: AD3
    pins: [1+, 2+, 1-, 2-, GND]
  G4: ground 11.5,12
wires:
  - U1.GP16 -- 5.5,10
  - 5.5,10 -- 6,10
  - U1.GND38 -| 5,3.2
  - 5.5,10 -- 5.5,8.4
  - 5.5,8.4 -- 10,8.4
  - 10,8.4 |- AD.1+
  - 9,10 -- 10.5,10
  - 10.5,10 |- AD.2+
  - AD.1- -| 11.5,12
  - AD.2- -| 11,12
  - AD.GND -| 10.5,12
  - 10.5,12 -- 11,12 -- 11.5,12
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/22-pwm-rc-dac.svg)

- 出力の平均 = 3.3 V × level / 1024。R1・C1 の −3 dB は 1 / (2π (パイ) × 10 kΩ × 100 nF) = 159 Hz で、146.5 kHz の PWM を約 1/920 に弱める
- **Scope の入力 1 MΩ も負荷になる。** R1 と分圧して出力は 1 MΩ / (1 MΩ + 10 kΩ) = 0.990 倍、時定数も (10 kΩ ∥ 1 MΩ) × 100 nF = 0.99 ms になる。
  負荷を付ける使い方では、後ろにボルテージフォロワを置く
- CH1 は GP16 の PWM そのもの、CH2 が濾した出力

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (Pico 2 は USB から給電)
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor b24 b29 10k
  C1: capacitor c29 c31 100n
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, 2+, GND, 1-, 2-]
wires:
  - a31 -- -t31 black
  - a7 -- -t7 black
  - AD.1+ -- a24 yellow
  - AD.2+ -- a29 blue
  - AD.GND -- -t33 black
  - AD.1- -- -t34 black
  - AD.2- -- -t35 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/22-pwm-rc-dac.svg)

Pico 2 は h5。GP16 (21 番) は上の列の 24 列 (c24)。R1 を b24〜b29 に挿して右へ出し、29 列に C1 (c29〜c31) を置く。
C1 の他端は a31 から −t へ、Pico 2 の GND (38 番、7 列) も a7 から −t へ。1+ は a24 (PWM)、2+ は a29 (出力)、GND・1−・2− は −t。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Scope (階段) | CH1・CH2 とも 500 mV/div、Time 10 ms/div、Trigger は CH2 の立ち下がり 1.2 V (768 → 0 の所)。カーソルを各段の終わりに置く |
| Scope (リップル) | CH1 1 V/div、CH2 2 mV/div で Offset −1.634 V、Time 2 µs/div (µs はマイクロ秒)、Trigger は CH1 の立ち上がり。プログラムの段を 512 に止めて見る |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 0→256→512→768 を 20 ms ずつ — 出力 (CH2) は τ 0.99 ms で階段を上る
time: 10ms/div
trigger: ch2 falling 1.2V at -4.5div
ch2: {wave: "= 0.817V * (step(t - 20ms) + step(t - 40ms) + step(t - 60ms)) - 2.450V * step(t - 80ms) + 2.450V * (1 - step(t)) | rc 990us", range: 500mV/div, position: -3div}
cursors: [15ms, 35ms]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/22-pwm-rc-dac-1.svg)

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 レベル 512 — PWM (CH1) とリップル (CH2、Offset −1.634 V で拡大)
time: 2us/div
trigger: ch1 rising 1.65V at -4div
ch1: {wave: square 146.48kHz 1.65V offset 1.65V, range: 1V/div, position: 0.5div}
ch2: {wave: triangle 146.48kHz 5.63mVpp, range: 2mV/div, position: -2.5div}
measure: [freq, vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/22-pwm-rc-dac-2.svg)

PWM が H の間は C1 が充電されて上がり、L の間は放電されて下がるので、リップルはほぼ三角波になる。

## Pico 2 のプログラム

C/C++ (Pico SDK) が第 1、MicroPython が第 2 (同じ動き)。

### C/C++ (Pico SDK)

```c
#include "pico/stdlib.h"
#include "hardware/pwm.h"

#define PWM_PIN 16
#define WRAP    1023                     // 10 ビット: 0〜1023 の 1024 段
static const uint16_t levels[] = {0, 256, 512, 768};

int main(void) {
    gpio_set_function(PWM_PIN, GPIO_FUNC_PWM);
    uint slice = pwm_gpio_to_slice_num(PWM_PIN);   // GP16 はスライス 0 の A
    pwm_set_clkdiv(slice, 1.0f);                   // 150 MHz のまま数える
    pwm_set_wrap(slice, WRAP);                     // 周期 1024 / 150 MHz = 6.83 µs (146.5 kHz)
    pwm_set_gpio_level(PWM_PIN, 0);
    pwm_set_enabled(slice, true);

    while (true) {
        for (uint i = 0; i < 4; i++) {
            pwm_set_gpio_level(PWM_PIN, levels[i]);  // 出力 = 3.3 V × level / 1024
            sleep_ms(20);
        }
    }
}
```

`CMakeLists.txt` は 7-3 と同じ形で、`target_link_libraries` に `pico_stdlib hardware_pwm` を書く。ビルドと書き込みも 7-3 と同じ。

### MicroPython

```python
from machine import Pin, PWM
import time

LEVELS = (0, 256, 512, 768)          # 10 ビットのレベル (0〜1023)
pwm = PWM(Pin(16), freq=146_484)     # 150 MHz / 1024 ≈ 146.5 kHz

while True:
    for level in LEVELS:
        pwm.duty_u16(level * 64)     # 65536 段に直す: 出力 = 3.3 V × level / 1024
        time.sleep_ms(20)
```

MicroPython の `PWM` は周波数から wrap を自分で決める。146,484 Hz なら wrap は 1023 前後になる (目安)。

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1 | Raspberry Pi Pico 2 | USB から給電。PWM = GP16 |
| R1 | 10 kΩ | 最大 3.3 V / 10 kΩ = 0.33 mA。GPIO の 4 mA (既定) に収まる |
| C1 | 100 nF (104) | セラミック。τ = R1 × C1 = 1 ms |
| 電源 | USB 5 V | AD3 の Supplies は使わない |

## 見るべき値

計算値。PWM の周期 T = 1024 / 150 MHz = 6.827 µs (146.48 kHz)、出力 = 3.3 V × level / 1024 × 0.990 (Scope の 1 MΩ)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の周波数 | 146.5 kHz | wrap 1023・clkdiv 1 |
| 各段の出力 (level 0・256・512・768) | 0・0.817・1.634・2.450 V | 3.3 V × level / 1024 の 0.990 倍。1 段 (level 1) は 3.2 mV |
| 段が切り替わってから 63 % まで | 0.99 ms (τ)。99 % まで 4.6 τ = 4.6 ms | 20 ms の段なら 20 τ で落ち着ききる |
| レベル 512 のリップル | 5.63 mVpp (256・768 で 4.22 mVpp) | 3.3 V × D (1 − D) × T / τ。D = 50 % で最大 |
| リップルの形 | 146.5 kHz の三角波 | H で充電、L で放電 |

**速さと滑らかさの取り合い**: τ を 10 倍にするとリップルは 1/10 になるが、落ち着くまでの時間も 10 倍になる。
2 段の RC にすると、同じ落ち着きの速さでリップルをもっと下げられる。出力の上限 3.3 V は GPIO の H の電圧そのもので、
H の電圧が負荷で下がる分 (目安で数 mV) と、電源の 3.3 V の誤差が DAC の誤差になる。
**動かないとき**: CH1 に方形波が出ていなければプログラムか GP16 の列、出ていて CH2 が 0 なら R1 と C1 の列を確かめる。

## LTspice での確かめ

`02-analog-discovery/07-logic/sim/22-pwm-rc-dac.cir`。0 / 3.3 V の方形波 (周期 1024 / 150 MHz) → R1 → C1 と Scope の 1 MΩ。
GPIO の出力抵抗は無視した (仮定)。15〜20 ms の区間で平均と p-p を測った。

| 本文の数字 | LTspice | 判定 |
| --- | --- | --- |
| D 25 %・50 %・75 % で 0.817・1.634・2.450 V | 0.8168・1.6337・2.4505 V | 合う |
| リップル 5.63 mVpp (D 50 %) | 5.63 mVpp | 合う |
| リップル 4.22 mVpp (D 25 %・75 %) | 4.22・4.22 mVpp | 合う |

τ 0.99 ms は算術 ((10 kΩ ∥ 1 MΩ) × 100 nF)。

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| PWM の周期 | GP16 (スライス 0 の A)、wrap 1023・clkdiv 1 で 6.827 µs (146.48 kHz)。MicroPython は freq 146,484 Hz | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 段の並びと長さ | 0・256・512・768 を 20 ms ずつ、80 ms で一巡。デューティ 0・25・50・75 % | C: Pico SDK のモック・MicroPython: `machine` のスタブ |

見ていない物: RC の後ろの電圧 (外部部品)。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
PWM のスライスと wrap・clkdiv は [RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) の PWM の節、
Scope の入力 1 MΩ は [Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
参考: [パルス幅変調](https://ja.wikipedia.org/wiki/%E3%83%91%E3%83%AB%E3%82%B9%E5%B9%85%E5%A4%89%E8%AA%BF)
