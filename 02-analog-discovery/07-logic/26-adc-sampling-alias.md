---
book: analog-discovery
chapter: 7
id: 7-26
title: ADC のサンプリングとエイリアスを Pico で
tier: 200
source: 自作 (計器の操作は Digilent の Using the Waveform Generator・Using the Oscilloscope)
board: BB
---

# 7-26 ADC のサンプリングとエイリアスを Pico で

ADC は電圧を決まった間隔で拾う (標本化)。標本化の周波数 f<sub>s</sub> の半分 (ナイキスト周波数) より速い波を入れると、
拾った点をつないだ波は**元より遅い別の周波数**に見える。これが**エイリアス** (折り返し) で、見える周波数は
入力 f と f<sub>s</sub> の倍数との差 |f − n f<sub>s</sub>| になる。ここでは Raspberry Pi Pico 2 が GP26 を **10 kS/s** で読み、
読んだ値をすぐ 7-22 の PWM の DAC で戻す。**Wavegen** の W1 で 9.5 kHz を入れると、戻した波は 500 Hz になる。
入力を 0.5〜25 kHz で動かし、見える周波数が三角に折り返す様子を **Scope** で確かめる。7-21 で ADC の目盛、7-22 で DAC を使った。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 GP26 で 10 kS/s に標本を取り、GP16 の PWM と RC で戻して見る
parts:
  U1: pico2 3,6
  G2: ground 5,3.2 r270
  R1: resistor 6,6 8.5,6 1k
  AD:
    type: device
    at: 12,6
    label: AD3 (W1 CH1)
    pins: [1+, W1, 1-, GND]
  G3: ground 9.5,8
  R2: resistor 6,10 8.5,10 10k
  C2: capacitor 8.5,10 8.5,12 10n
  G1: ground 8.5,12
  AE:
    type: device
    at: 12,10
    label: AD3 (CH2)
    pins: [2+, 2-]
  G4: ground 10,12
wires:
  - U1.GND38 -| 5,3.2
  - U1.GP26 -- 5.5,6
  - 5.5,6 -- 6,6
  - 5.5,6 -- 5.5,4.8
  - 5.5,4.8 -- 8,4.8
  - 8,4.8 |- AD.1+
  - AD.W1 -| 8.5,6
  - AD.1- -| 9.5,8
  - AD.GND -| 10,8
  - 9.5,8 -- 10,8
  - U1.GP16 -- 6,10
  - AE.2+ -| 8.5,10
  - AE.2- -| 10,12
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/26-adc-sampling-alias.svg)

- **エイリアスを見るため、ADC の前にローパス (アンチエイリアスのフィルタ) をわざと置かない。** R1 (1 kΩ (キロオーム)) は W1 の設定を誤ったときの保護だけ。
  実際の計測では、ADC の前に f<sub>s</sub> / 2 より下で切るフィルタを置いて、折り返す成分を先に消す
- 戻す側は 7-22 と同じ PWM (146.5 kHz・10 ビット)。R2 = 10 kΩ・C2 = 10 nF (τ (タウ) = 0.1 ms、−3 dB が 1.6 kHz) にして、
  500 Hz は通し、10 kS/s の階段の角と PWM の 146.5 kHz を弱める
- ADC の 12 ビットの値を 2 ビット右へずらして 10 ビットの PWM のレベルにするので、入力の電圧がそのまま出力の電圧になる (ADC_VREF と GPIO の H が同じ 3.3 V と仮定)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (Pico 2 は USB から給電)
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor g26 g30 1k
  R2: resistor b24 b29 10k
  C2: capacitor c29 c31 10n
  AE:
    type: device
    at: top
    label: AD3 (CH2)
    pins: [2+, 2-]
  AD:
    type: device
    at: bottom
    label: AD3 (W1 CH1)
    pins: [GND, 1-, 1+, W1]
wires:
  - a14 -- a26 yellow
  - e26 -- f26 yellow
  - AD.1+ -- j26 yellow
  - AD.W1 -- j30 orange
  - AD.GND -- -b22 black
  - AD.1- -- -b23 black
  - a7 -- -t7 black
  - -t2 -- -b2 black
  - a31 -- -t31 black
  - AE.2+ -- a29 blue
  - AE.2- -- -t33 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/26-adc-sampling-alias.svg)

AD3 は線の都合で 2 つの箱に分けて描いた (どちらも同じ AD3)。GP26 (14 列) は a14〜a26 (黄) で右へ出し、26 列で溝を渡って (e26〜f26)、
下のブロックの R1 (g26〜g30) へ。W1 は j30、1+ は j26。GP16 (24 列) は R2 (b24〜b29) から C2 (c29〜c31) へ、2+ は a29。
上の −t と下の −b は 2 列の線でつなぎ、Pico 2 の GND (38 番) は a7 から −t へ。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1 = Sine、9.5 kHz、Amplitude 1 V、Offset 1.65 V (0.65〜2.65 V)。**出す前に Amplitude と Offset を確かめる** |
| Scope | CH1・CH2 とも 1 V/div、Time 500 µs/div (µs はマイクロ秒)、Trigger は CH2 の立ち上がり 1.634 V。Measure に Frequency と Peak to Peak |
| 掃引 | W1 の周波数を 0.5 kHz から 25 kHz まで変え、CH2 の周波数を読む (図4 の点) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 W1 の 9.5 kHz (CH1) を 10 kS/s で取ると、戻した波 (CH2) は 500 Hz になる
time: 500us/div
trigger: ch2 rising 1.634V
ch1: {wave: sine 9.5kHz 1V offset 1.65V, range: 1V/div, position: 0.5div}
ch2: {wave: sine 500Hz 0.94V offset 1.634V, range: 1V/div, position: -3.5div}
cursors: [0, 2ms]
measure: [freq, vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/26-adc-sampling-alias.svg)

CH1 の 9.5 kHz は 500 µs/div では詰まった帯に見えるが、CH2 はゆっくりした 500 Hz になる。図3 の CH1 に出ている縞の模様は、図を描く点の間隔が 9.5 kHz に対して粗いために起きた折り返しで、この題の現象そのもの (実物の画面は AD3 が速く標本を取るので、ほぼ塗りつぶした帯になる)。CH2 には PWM の 146.5 kHz のさざ波 (57 mVpp) が重なる。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 入力の周波数と、10 kS/s で取ったときに見える周波数 (折り返し)
x: 入力の周波数 Hz 0..25k
y: 見える周波数 Hz 0..6k
lines:
  見える周波数 Hz:
    - 0 0
    - 5k 5k
    - 10k 0
    - 15k 5k
    - 20k 0
    - 25k 5k
notes:
  - mark 9.5k
  - mark 10.5k
  - mark 20.5k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/graph/26-adc-sampling-alias.svg)

## Pico 2 のプログラム

100 µs ごとに GP26 を読み、すぐ GP16 の PWM のレベルにする。C/C++ (Pico SDK) が第 1、MicroPython が第 2。

### C/C++ (Pico SDK)

```c
#include "pico/stdlib.h"
#include "hardware/adc.h"
#include "hardware/pwm.h"

#define RATE_HZ   10000u
#define PERIOD_US (1000000u / RATE_HZ)   // 100 µs ごと = 10 kS/s
#define PWM_PIN   16

int main(void) {
    adc_init();
    adc_gpio_init(26);                   // GP26 = ADC0
    adc_select_input(0);

    gpio_set_function(PWM_PIN, GPIO_FUNC_PWM);
    uint slice = pwm_gpio_to_slice_num(PWM_PIN);
    pwm_set_clkdiv(slice, 1.0f);
    pwm_set_wrap(slice, 1023);           // 10 ビット・146.5 kHz (7-22 と同じ)
    pwm_set_enabled(slice, true);

    uint64_t next = time_us_64();
    while (true) {
        next += PERIOD_US;
        while (time_us_64() < next) tight_loop_contents();
        uint16_t code = adc_read() & 0x0fff;          // 0〜4095
        pwm_set_gpio_level(PWM_PIN, code >> 2);       // 0〜1023 にして戻す
    }
}
```

`CMakeLists.txt` は 7-3 と同じ形で、`target_link_libraries` に `pico_stdlib hardware_adc hardware_pwm`。
`RATE_HZ` を 20000 にすると折り返しの点 (図4 の 0 になる所) が 20 kHz おきに動く。

### MicroPython

```python
from machine import ADC, Pin, PWM
import time

RATE_HZ = 10_000
PERIOD_US = 1_000_000 // RATE_HZ      # 100 µs ごと = 10 kS/s
adc = ADC(Pin(26))                    # GP26 = ADC0
pwm = PWM(Pin(16), freq=146_484)      # 7-22 と同じ DAC

nxt = time.ticks_us()
while True:
    nxt = time.ticks_add(nxt, PERIOD_US)
    d = time.ticks_diff(nxt, time.ticks_us())
    if d > 0:
        time.sleep_us(d)
    pwm.duty_u16(adc.read_u16())      # 0〜65535 のまま戻す
```

MicroPython で 1 回の処理が 100 µs を超えると、標本の間隔が延びて見える周波数もずれる (目安)。

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1 | Raspberry Pi Pico 2 | USB から給電。ADC0 = GP26、PWM = GP16 |
| R1 | 1 kΩ | 保護。W1 が 5 V でも 1.7 mA |
| R2 | 10 kΩ | 戻す側の RC |
| C2 | 10 nF (103) | セラミック。τ = 0.1 ms |
| 電源 | USB 5 V | AD3 の Supplies は使わない |

## 見るべき値

計算値。f<sub>s</sub> = 10 kS/s、ナイキスト周波数 5 kHz。見える周波数 = |f − n × 10 kHz| (n は f に一番近い整数)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 入力 1 kHz・4 kHz | 1 kHz・4 kHz | ナイキストより下はそのまま |
| 入力 6 kHz | 4 kHz | 5 kHz を超えると折り返す |
| 入力 9.5 kHz・10.5 kHz・20.5 kHz | どれも 500 Hz | 10 kHz の倍数の近くは遅い波に化ける |
| 入力 10 kHz | 0 Hz (止まった直流。値は位相で決まる) | 標本がいつも同じ位相に当たる |
| 9.5 kHz のときの CH2 の振幅 | 0.94 V<sub>p</sub> (1.88 Vpp)、平均 1.634 V | 0.996 (階段の平均化、sinc) × 0.945 (RC と Scope の 1 MΩ) |
| CH2 に残る像 (9.5・10.5 kHz) と PWM | 約 9 mV・7 mV、PWM のさざ波 57 mVpp | RC で弱めた残り |

**エイリアスは見分けられない。** 500 Hz に見えた波が本当に 500 Hz なのか、9.5 kHz の化けた姿なのかは、標本だけからは分からない。
だから折り返す成分は ADC の前のフィルタで消しておく。**動かないとき**: CH2 が CH1 と同じ周波数に見えるなら入力が 5 kHz より下、
CH2 が平らなら PWM と R2・C2 の列、CH1 が無ければ W1 の Enable を確かめる。

## LTspice での確かめ

`02-analog-discovery/07-logic/sim/26-adc-alias-rc.cir`。入力側 (R1 と Scope の 24 pF、ADC の入力 100 kΩ は最悪の仮定) と、
戻す側の RC (Scope の 1 MΩ を含む) を `.ac` で解いた。標本化そのものと階段の sinc は算術。

| 本文の数字 | LTspice | 判定 |
| --- | --- | --- |
| 戻す側の RC の 500 Hz で 0.945 倍 | −0.488 dB = 0.945 倍 | 合う |
| 像の 9.5 kHz・10.5 kHz で 0.165・0.150 倍 (× sinc 0.0524・0.0474 で 9 mV・7 mV) | −15.64 dB・−16.49 dB = 0.165・0.150 倍 | 合う |
| PWM の 146.5 kHz で約 1/92 | −39.28 dB = 0.0109 倍 | 合う |
| 入力側の 9.5 kHz で ADC に届く割合 | −0.086 dB = 0.990 倍 (100 kΩ の最悪)。振幅は 0.93〜0.94 V<sub>p</sub> | 合う |

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| 標本の間隔 | 100 µs ごと (10 kS/s) | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 戻す値 | 9.5 kHz・1 V<sub>p</sub> の正弦を与えると、PWM のレベルの並びが 500 Hz (20 標本で一巡) の正弦になる (レベル = コード / 4) | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| PWM の周期 | GP16、wrap 1023・clkdiv 1 で 6.827 µs | C: Pico SDK のモック |

見ていない物: ADC の本当の変換の時間と雑音、RC の後ろの電圧。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Waveform Generator](https://digilent.com/reference/test-and-measurement/guides/waveforms-waveform-generator)・
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
ADC の入力インピーダンス (最小 100 kΩ) は [RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) の表 1685、
Scope の入力 (1 MΩ ∥ 24 pF) は [Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
参考: [エイリアシング](https://ja.wikipedia.org/wiki/%E3%82%A8%E3%82%A4%E3%83%AA%E3%82%A2%E3%82%B7%E3%83%B3%E3%82%B0)、[標本化定理](https://ja.wikipedia.org/wiki/%E6%A8%99%E6%9C%AC%E5%8C%96%E5%AE%9A%E7%90%86)
