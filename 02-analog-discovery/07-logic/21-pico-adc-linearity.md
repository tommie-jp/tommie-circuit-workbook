---
book: analog-discovery
chapter: 7
id: 7-21
title: Pico の ADC の特性 (直線性・雑音)
tier: 200
source: 自作 (計器の操作は Digilent の Using the Waveform Generator・Using the Oscilloscope)
board: BB
---

# 7-21 Pico の ADC の特性 (直線性・雑音)

Raspberry Pi Pico 2 の ADC (RP2350 の 12 ビット、500 kS/s) が、入れた電圧をどれだけ正しくコードにするかを AD3 で調べる。
**Wavegen** の W1 で 0.1〜3.2 V の遅い三角波を GP26 (ADC0) に入れ、同じ点を **Scope** の CH1 で読んで「本当の電圧」にする。
Pico 2 は 10 kS/s で 60 s 読み、コードごとの度数 (ヒストグラム) と平均・標準偏差を USB シリアルに出す。
三角波は電圧の上をどこも同じ速さで通るので、理想の ADC なら**どのコードも同じ数だけ出る** (度数法、code density test)。
度数のでこぼこが DNL (微分非直線性、1 コードの幅の狂い) で、DC を入れたときの標準偏差が雑音。
回路の教科書の 11-3 で ADC を使った。ここではその ADC 自身を測る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Wavegen の電圧を Pico 2 の ADC0 (GP26) と Scope で同時に読む
parts:
  U1: pico2 3,6
  G2: ground 5,5.2 r270
  G3: ground 5,3.2 r270
  R1: resistor 6,6 9,6 1k
  C1: capacitor 6,6 6,8 100n
  G1: ground 6,8
  AD:
    type: device
    at: 12,5.6
    label: AD3
    pins: [2+, 1+, W1, 1-, 2-, GND]
  G4: ground 10.5,8
wires:
  - U1.GP26 -- 6,6
  - U1.AGND -| 5,5.2
  - U1.GND38 -| 5,3.2
  - U1.ADC_VREF -| 9.5,4.4
  - 9.5,4.4 |- AD.2+
  - 6,6 -- 6,4.8
  - 6,4.8 -- 8,4.8
  - 8,4.8 |- AD.1+
  - AD.W1 -| 9,6
  - AD.1- -| 10.5,8
  - AD.2- -| 10,8
  - AD.GND -| 9.5,8
  - 9.5,8 -- 10,8 -- 10.5,8
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/21-pico-adc-linearity.svg)

- R1 (1 kΩ (キロオーム)) は保護。W1 は ±5 V まで出せるので、設定を誤って 3.3 V を超えても GP26 に流れ込む電流を (5 − 3.3) / 1 kΩ = 1.7 mA に抑える
- C1 (100 nF) は ADC が標本を取る瞬間の電流を受け持つ。R1・C1 の時定数は 0.1 ms で、3.3 Hz の三角波には遅れ 0.1 ms しか生まない
- **Scope の 1+ は R1 の後ろ (GP26) に当てる。** ADC の入力インピーダンスは最小 100 kΩ (データシート) で、R1 の電圧降下が最悪 1 % 出るが、
  1+ も同じ点を読むので比べる相手は同じ電圧になる
- **ADC の目盛の元は ADC_VREF** (35 番)。Pico 2 では 3.3 V を 200 Ω と 2.2 µF (マイクロファラド) で濾して作り、ADC の消費 (約 150 µA) で約 30 mV 下がる
  (Pico 2 のデータシート)。2+ で ADC_VREF を読み、コードを電圧に直すときに使う

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (Pico 2 は USB から給電)
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor d27 d31 1k
  C1: capacitor c27 c29 100n cap=right
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [2+, 1+, W1, GND, 1-, 2-]
wires:
  - b14 -- b27 yellow
  - a29 -- -t29 black
  - a7 -- -t7 black
  - a12 -- -t12 black
  - AD.2+ -- a10 white
  - AD.1+ -- a27 yellow
  - AD.W1 -- a31 orange
  - AD.GND -- -t34 black
  - AD.1- -- -t35 black
  - AD.2- -- -t36 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/21-pico-adc-linearity.svg)

Pico 2 は h5 (USB が左)。上の列の 14 列が GP26 (31 番)、10 列が ADC_VREF (35 番)、12 列が AGND (33 番)、7 列が GND (38 番)。
GP26 は b14〜b27 (黄) で右へ出し、27 列に R1 (d27〜d31) と C1 (c27〜c29) を置く。C1 の他端は a29 から −t へ。
AGND と GND は −t でまとめ、AD3 の GND・1−・2− も −t へ。W1 は a31、1+ は a27、2+ は a10。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1 = Triangle、3.3 Hz、Amplitude 1.55 V、Offset 1.65 V (0.1〜3.2 V)。**出す前に Amplitude と Offset を確かめる** |
| Scope | CH1 (GP26)・CH2 (ADC_VREF) とも 500 mV/div、Time 50 ms/div。Measure に Maximum・Minimum・Frequency・Average |
| 雑音を見るとき | W1 = DC 1.65 V に替え、同じプログラムで 60 s 取る |

3.3 Hz は 10 kS/s と割り切れない (1 周期 3030.3 標本) ので、周期ごとに標本の当たる電圧がずれ、60 s でどのコードにも満遍なく当たる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 GP26 の三角波 (CH1、0.1〜3.2 V・3.3 Hz) と ADC_VREF (CH2)
time: 50ms/div
trigger: ch1 rising 1.65V
ch1: {wave: triangle 3.3Hz 1.55V offset 1.65V, range: 500mV/div, position: -3.3div}
ch2: {wave: dc 3.27V, range: 500mV/div, position: -3.3div}
cursors: [-75.76ms, 75.76ms]
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/21-pico-adc-linearity.svg)

CH2 の 3.27 V は目安 (3.3 V から 30 mV 下がった値)。実物の値を読んで、下の式の 3.27 V を置き換える。

## Pico 2 のプログラム

C/C++ (Pico SDK) が第 1、MicroPython が第 2 (同じ動き)。どちらも 10 kS/s で 600,000 回読み、
1 行目に標本数・平均・標準偏差 (コード)・平均を 3.3 V の目盛で直した電圧を、続けて「コード 度数」を出たコードだけ出す。

### C/C++ (Pico SDK)

```c
#include <stdio.h>
#include <math.h>
#include "pico/stdlib.h"
#include "hardware/adc.h"

#define RATE_HZ   10000u
#define PERIOD_US (1000000u / RATE_HZ)   // 100 µs ごとに 1 回
#define N_SAMPLES (RATE_HZ * 60u)        // 60 s
static uint32_t hist[4096];              // コードごとの度数

int main(void) {
    stdio_init_all();
    adc_init();
    adc_gpio_init(26);                   // GP26 = ADC0
    adc_select_input(0);
    sleep_ms(3000);                      // USB シリアルを開く間

    double sum = 0.0, sum2 = 0.0;
    uint64_t next = time_us_64();
    for (uint32_t i = 0; i < N_SAMPLES; i++) {
        next += PERIOD_US;
        while (time_us_64() < next) tight_loop_contents();
        uint16_t code = adc_read() & 0x0fff;
        hist[code]++;
        sum += code;
        sum2 += (double)code * code;
    }
    double mean = sum / N_SAMPLES;
    double sd = sqrt(sum2 / N_SAMPLES - mean * mean);
    printf("N %lu mean %.2f sd %.2f V %.4f\n",
           (unsigned long)N_SAMPLES, mean, sd, mean * 3.3 / 4096.0);
    for (int c = 0; c < 4096; c++)
        if (hist[c]) printf("%d %lu\n", c, (unsigned long)hist[c]);
    while (true) tight_loop_contents();
}
```

`CMakeLists.txt` は 7-3 と同じ形で、`target_link_libraries` に `pico_stdlib hardware_adc` を書き、
`pico_enable_stdio_usb(<名前> 1)` で USB シリアルに出す。ビルドと書き込みは 7-3 と同じ (`PICO_BOARD=pico2`)。

### MicroPython

```python
from machine import ADC, Pin
import math
import time

RATE_HZ = 10_000
PERIOD_US = 1_000_000 // RATE_HZ        # 100 µs ごとに 1 回
N_SAMPLES = RATE_HZ * 60                # 60 s

adc = ADC(Pin(26))                      # GP26 = ADC0
hist = [0] * 4096
time.sleep(3)                           # シリアルを開く間

s = 0
s2 = 0
nxt = time.ticks_us()
for i in range(N_SAMPLES):
    nxt = time.ticks_add(nxt, PERIOD_US)
    d = time.ticks_diff(nxt, time.ticks_us())
    if d > 0:
        time.sleep_us(d)
    code = adc.read_u16() >> 4          # read_u16 は 0〜65535 に広げた値
    hist[code] += 1
    s += code
    s2 += code * code

mean = s / N_SAMPLES
sd = math.sqrt(s2 / N_SAMPLES - mean * mean)
print('N %d mean %.2f sd %.2f V %.4f' % (N_SAMPLES, mean, sd, mean * 3.3 / 4096))
for c in range(4096):
    if hist[c]:
        print(c, hist[c])
```

MicroPython は 1 回の処理が 100 µs に収まらないと間隔が延びる (度数法では間隔が揃わなくても結果は変わらないが、時間は 60 s より延びる。目安)。

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1 | Raspberry Pi Pico 2 | USB から給電。ADC0 = GP26 |
| R1 | 1 kΩ | 保護。W1 が 5 V でも 1.7 mA・2.9 mW |
| C1 | 100 nF (104) | セラミック。標本を取る瞬間の電流を受ける |
| 電源 | USB 5 V (Pico 2 の 3.3 V は基板の上で作る) | AD3 の Supplies は使わない |

## 見るべき値

計算値と目安。1 LSB = 3.3 V / 4096 = 0.806 mV (ADC_VREF 3.3 V のとき)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の最大・最小・周波数 | 3.20 V・0.100 V・3.300 Hz | ADC に入る電圧 (本当の値) |
| CH2 (ADC_VREF) | 3.27 V 前後 (目安) | ADC の目盛。コード = 4096 × V / ADC_VREF |
| 三角波で出るコードの範囲 | 124〜3972 (3.3 V の目盛)、125〜4008 (3.27 V) | 端のコードで ADC_VREF が逆算できる |
| 1 コードあたりの度数 | 600,000 / 3848 ≈ 156 (ばらつき 1σ で ±8 %) | 度数 / 156 − 1 が DNL。±0.5 を超えるコードは幅が狂っている |
| DC 1.65 V の平均 | 2048 (3.3 V)・2067 (3.27 V) | 図4 の傾きのずれ (18.8 LSB) |
| DC 1.65 V の標準偏差 | 1〜2 LSB rms (目安) | 雑音。ENOB 9〜9.5 ビット (データシート) を雑音とひずみに直すと 2.3〜1.6 LSB rms |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 コードの誤差 (読み − 4096 × V / 3.3) — ADC_VREF が 3.27 V なら傾きがずれる
x: 入力の電圧 V 0..3.3
y: 誤差 LSB -10..40
lines:
  ADC_VREF 3.300 V (理想) LSB: 0*x
  ADC_VREF 3.270 V LSB: 4096*x/3.27 - 4096*x/3.3
notes:
  - mark 0.1
  - mark 1.65
  - mark 3.2
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/graph/21-pico-adc-linearity.svg)

**直線性の読み方**: W1 を DC にして 0.1 V から 3.2 V まで 0.1 V ずつ変え、各点の平均コードを CH1 の電圧に対して並べると、
直線からのずれが INL (積分非直線性)。ADC_VREF の違いは傾き (利得の誤差) として出るので、先に直線を当てはめてから残りを見る。
RP2350 のデータシートは INL と DNL の値をまだ載せていない (「Details to follow」)。測った値がそのまま手持ちの石の特性になる。
**動かないとき**: 度数が 0 か 4095 に固まるなら GP26 の配線か W1 の振幅、平均が CH1 と大きく違うなら AGND と GND のつなぎを確かめる。

## LTspice での確かめ

`02-analog-discovery/07-logic/sim/21-pico-adc-input.cir`。W1 の三角波 (3.3 Hz、0.1〜3.2 V) → R1 → GP26 と C1、ADC の入力を抵抗 R<sub>in</sub> と置いた (仮定)。

| 本文の数字 | LTspice | 判定 |
| --- | --- | --- |
| 遅れ 0.1 ms (R1・C1 の時定数) | 0.101 ms (R<sub>in</sub> 100 MΩ) | 合う |
| GP26 の振れ 0.1〜3.2 V | 0.101〜3.199 V (R<sub>in</sub> 100 MΩ) | 合う |
| 最悪の入力インピーダンス 100 kΩ で約 1 % 下がる | 上端 3.167 V (−1.0 %)、遅れ 0.91 ms | 合う (1+ も同じ点を読むので比べる相手は同じ) |

1 コードの度数 156・誤差 18.8 LSB・36.4 LSB は算術 (600,000 / (3972 − 124)、4096 × V × (1/3.27 − 1/3.3))。

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| ADC の設定 | GP26 を ADC にし、入力 0 を選ぶ | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 標本の間隔と数 | 100 µs ごと (10 kS/s) に 600,000 回、3 s 待ってから 60 s | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 平均・標準偏差・度数 | 2047・2048・2049・2048 を繰り返す入力で mean 2048.00・sd 0.71、度数 150,000・300,000・150,000 | C: Pico SDK のモック・MicroPython: `machine` のスタブ |

見ていない物: ADC の本当の雑音と非直線性 (モックは与えた値を返すだけ)。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Waveform Generator](https://digilent.com/reference/test-and-measurement/guides/waveforms-waveform-generator)・
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
ADC の 12 ビット・ENOB (最小 9・typ 9.5)・入力インピーダンス 100 kΩ・INL と DNL が未掲載なことは
[RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) の 12.4 節と表 1685、
ADC_VREF の作り方 (201 Ω と 2.2 µF、約 30 mV の下がり) は [Pico 2 データシート](https://datasheets.raspberrypi.com/pico/pico-2-datasheet.pdf) の 5.3 節。
参考: [Analog-to-digital converter (DNL・INL)](https://en.wikipedia.org/wiki/Analog-to-digital_converter)
