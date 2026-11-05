---
book: analog-discovery
chapter: 7
id: 7-24
title: ジッタ
tier: 200
source: 自作 (計器の操作は Digilent の Using the Oscilloscope)
board: BB
---

# 7-24 ジッタ

**ジッタ**は、周期的な信号の端 (立ち上がり・立ち下がり) が、決まった時刻から前後に揺れること。
Raspberry Pi Pico 2 で 10 kHz の方形波を 2 通りに作って比べる。GP16 はプログラムが時刻を見て自分で反転する**ソフトの方形波**、
GP18 は PWM の回路が水晶のクロックから作る**ハードの方形波**。プログラムには 1.013 ms ごとに 3 µs (マイクロ秒) かかる割り込み
(ほかの仕事のまね) を入れておく。割り込みがソフトの端の時刻に重なると、その端だけ遅れる。
AD3 の **Scope** で 1 つの端に掛けて、1 周期後 (100 µs 後) の端を重ね書きで見ると、ソフトの端だけが幅を持って散る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ソフトの方形波 (GP16) と PWM の方形波 (GP18) を Scope で比べる
parts:
  U1: pico2 3,6
  G2: ground 5,3.2 r270
  AD:
    type: device
    at: 11,11.2
    label: AD3
    pins: [2+, 1+, 1-, 2-, GND]
  G4: ground 9.5,13
wires:
  - U1.GND38 -| 5,3.2
  - U1.GP18 -| 7,8.8
  - 7,8.8 |- AD.2+
  - U1.GP16 -| 6,10
  - 6,10 |- AD.1+
  - AD.1- -| 9.5,13
  - AD.2- -| 9,13
  - AD.GND -| 8.5,13
  - 8.5,13 -- 9,13 -- 9.5,13
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/24-jitter.svg)

- 部品は無い。CH1 (1+) を GP16、CH2 (2+) を GP18、1−・2−・GND を Pico 2 の GND へ
- 測るのは 1 周期の長さの揺れ (周期ジッタ)。トリガを掛けた端から 1 周期後の端を見るので、トリガの端の揺れも 1 周期後の端の揺れに入る

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (Pico 2 は USB から給電)
board: full
parts:
  MCU: pico2 @ h5
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [2+, 1+, GND, 1-, 2-]
wires:
  - a7 -- -t7 black
  - AD.2+ -- a21 blue
  - AD.1+ -- a24 yellow
  - AD.GND -- -t27 black
  - AD.1- -- -t28 black
  - AD.2- -- -t29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/24-jitter.svg)

Pico 2 は h5。上の列の 24 列が GP16 (21 番)、21 列が GP18 (24 番)、7 列が GND (38 番)。1+ は a24、2+ は a21、GND は a7 から −t へ。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Scope (全体) | CH1・CH2 とも 1 V/div、Time 20 µs/div、Trigger は CH1 の立ち上がり 1.65 V。カーソルを 100 µs と 103 µs に置く |
| Scope (端の拡大) | Time 1 µs/div、横の位置 (Position) を 100 µs にして 1 周期後の端を画面の真ん中へ。残像 (Persistence) の表示で数秒重ねる (目安。表示の名前は WaveForms の版で違う) |
| CH2 で同じこと | Trigger を CH2 の立ち上がりに替えて同じ拡大を見る |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 ソフトの方形波 (CH1) は 1 周期後の端が 3 µs ほど散る。PWM (CH2) は散らない
time: 20us/div
trigger: ch1 rising 1.65V at -4div
ch1: {wave: square 10kHz 1.65V offset 1.65V, range: 1V/div, position: 0.3div}
ch2: {wave: square 10kHz 1.65V offset 1.65V phase -90deg, range: 1V/div, position: -3.7div}
cursors: [100us, 103us]
measure: [freq, duty]
notes:
  - band 100us 103us
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/24-jitter.svg)

図は理想の 1 回ぶんで、帯 (100〜103 µs) が重ね書きで CH1 の端の散る幅。CH2 の位相 (−90°) は図のために置いた値で、
実物では 2 つの方形波の位相は電源を入れた時の順で決まる。

## Pico 2 のプログラム

C/C++ (Pico SDK) が第 1、MicroPython が第 2。

### C/C++ (Pico SDK)

```c
#include "pico/stdlib.h"
#include "hardware/pwm.h"

#define SOFT_PIN 16          // ソフトで反転する方形波
#define PWM_PIN  18          // PWM の方形波 (比べる相手)
#define HALF_US  50          // 半周期 50 µs → 10 kHz
#define ISR_US   3           // 割り込みの中の仕事の長さ (わざと入れる)

static bool on_timer(repeating_timer_t *t) {
    busy_wait_us(ISR_US);    // ほかの仕事 (センサーを読むなど) のまね
    return true;             // 繰り返す
}

int main(void) {
    gpio_set_function(PWM_PIN, GPIO_FUNC_PWM);
    uint slice = pwm_gpio_to_slice_num(PWM_PIN);   // GP18 はスライス 1 の A
    pwm_set_clkdiv(slice, 15.0f);                  // 150 MHz / 15 = 10 MHz
    pwm_set_wrap(slice, 999);                      // 1000 / 10 MHz = 100 µs (10 kHz)
    pwm_set_gpio_level(PWM_PIN, 500);              // 50 %
    pwm_set_enabled(slice, true);

    gpio_init(SOFT_PIN);
    gpio_set_dir(SOFT_PIN, GPIO_OUT);
    repeating_timer_t timer;
    add_repeating_timer_us(-1013, on_timer, NULL, &timer);  // 1.013 ms ごと (100 µs と割り切れない)

    bool level = false;
    uint64_t next = time_us_64();
    while (true) {
        next += HALF_US;                           // 決まった時刻 (遅れは積もらない)
        while (time_us_64() < next) tight_loop_contents();
        level = !level;
        gpio_put(SOFT_PIN, level);
    }
}
```

`ISR_US` を 0 にすると、割り込みがあってもソフトの端はほとんど散らなくなる (割り込みに入って出る時間だけ残る)。
`CMakeLists.txt` は 7-3 と同じ形で、`target_link_libraries` に `pico_stdlib hardware_pwm`。

### MicroPython

```python
from machine import Pin, PWM
import time

HALF_US = 50                                     # 半周期 50 µs → 10 kHz
pwm = PWM(Pin(18), freq=10_000, duty_u16=32768)  # ハードの方形波
soft = Pin(16, Pin.OUT)                          # ソフトの方形波

level = 0
nxt = time.ticks_us()
while True:
    nxt = time.ticks_add(nxt, HALF_US)
    d = time.ticks_diff(nxt, time.ticks_us())
    if d > 0:
        time.sleep_us(d)
    level ^= 1
    soft.value(level)
```

MicroPython 版には割り込みを入れない。それでも、ごみ集め (GC) や 1 行ごとの解釈の時間で、ソフトの端は C 版より大きく散る (目安で数 µs〜数十 µs)。

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1 | Raspberry Pi Pico 2 | USB から給電。GP16 と GP18 |
| 電源 | USB 5 V | AD3 の Supplies は使わない |

## 見るべき値

計算値と目安。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1・CH2 の周波数 | 10.00 kHz (周期 100 µs) | 平均の周期はどちらも同じ |
| CH1 の 1 周期後の端の散る幅 | 約 3 µs (割り込みの仕事の長さ。入って出る時間で少し増える、目安) | 割り込みが端の時刻に重なった回だけ遅れる |
| 遅れる端の割合 | 立ち上がり 1,000 回に 3 回ほど | 割り込みは 1 s に 987 回、そのうち 3 / 50 = 6 % が反転の時刻に重なり、半分が立ち上がり |
| CH2 の 1 周期後の端の散る幅 | 見えない (AD3 の標本の間隔 8 ns より小さい) | PWM は水晶から作るクロックを数えるだけで、プログラムの割り込みに左右されない |

**ジッタの見方**: 重ね書きの幅は、たまにしか起きない遅れも残すので**最悪の幅 (pk-pk)** になる。
平均の周期は揺れの大きさと関係なく 100 µs のままで、Measure の周波数だけを見ていると気づかない。
時刻が大事な信号 (ADC の標本の合図・サーボのパルス・通信のクロック) はハード (PWM・PIO・DMA) で作る。
**動かないとき**: CH1 が出なければ GP16 の列、散らなければ `ISR_US` と割り込みの登録を確かめる。

## LTspice での確かめ (対象外)

回路の部品が無いプログラムの時刻の題。算術で確かめた。半周期 50 µs で 10 kHz、PWM は 150 MHz / 15 / 1000 = 10 kHz。
割り込み 1 回 3 µs、間隔 1.013 ms で 1 s に 987 回、反転 (50 µs ごと) に重なる割合 3 / 50 = 6 % → 1 s に 59 回の反転が遅れ、
立ち上がりはその半分の 30 回 / 10,000 回 = 0.3 %。

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| PWM の周期 | GP18 (スライス 1)、clkdiv 15・wrap 999 で 100 µs、50 %。MicroPython は freq 10,000 Hz | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| ソフトの反転 | 平均 50 µs ごと。1.013 ms ごとの 3 µs の割り込みを模すと、間隔が 47〜53 µs に散り、遅れは積もらない | C: Pico SDK のモック (割り込みはテストの側から呼んだ) |
| MicroPython のソフトの反転 | 50 µs ごと | MicroPython: `machine` のスタブ |

見ていない物: 実機の割り込みの入口・出口の時間、USB の処理による揺れ。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
AD3 の最大の標本化 125 MS/s は [Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)、
PWM のクロックの分け方は [RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) の PWM の節。
参考: [ジッタ](https://ja.wikipedia.org/wiki/%E3%82%B8%E3%83%83%E3%82%BF)
