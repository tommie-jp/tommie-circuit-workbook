---
book: analog-discovery
chapter: 7
id: 7-25
title: アイパターンのまね
tier: 200
source: 自作 (計器の操作は Digilent の Using the Oscilloscope)
board: BB
---

# 7-25 アイパターンのまね

ディジタルの信号が配線 (伝送路) を通ると、角が丸まり、前のビットの名残りが次のビットに残る (符号間干渉、ISI)。
受け側の波形を **1 ビットの長さごとに切って全部重ねる**と、真ん中に目のような穴が開く。これが**アイパターン**で、
穴 (アイ) の高さが「0 と 1 をどれだけ確かに見分けられるか」を表す。専用の計器はクロックを取り出して重ねるが、
ここでは AD3 の **Scope** の重ね書きでまねる。Raspberry Pi Pico 2 の UART0 から 1 Mbit/s で疑似乱数の並び (PRBS7) を出し、
R1 = 1 kΩ (キロオーム) と C1 の RC を「帯域の狭い伝送路」の代わりにする。C1 を 220 pF と 1 nF で替え、アイが閉じていく様子を見る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 UART0 の TX (GP16) を RC の伝送路に通して受け側を見る
parts:
  U1: pico2 3,6
  G2: ground 5,3.2 r270
  R1: resistor 6,10 9,10 1k
  C1: capacitor 9,10 9,12 220p
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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/25-eye-pattern.svg)

- 伝送路の時定数 τ (タウ) = R1 × (C1 + 24 pF)。24 pF は Scope の入力容量 (AD3 の仕様)。220 pF で 0.244 µs (マイクロ秒)、1 nF で 1.024 µs
- 1 ビット T = 1 µs。最悪の 1 (0 が続いた後の 1 つだけの 1) は 1 ビットの終わりで 3.3 V × (1 − e<sup>−T/τ</sup>) まで、
  最悪の 0 は 3.3 V × e<sup>−T/τ</sup> までしか動かない。アイの高さ = 3.3 V × (1 − 2 e<sup>−T/τ</sup>)
- UART0 の TX は GP16 に出す (RP2350 の UART の機能では GP0・GP12・GP16・GP28 から選べる)。7-22 と同じ配置で組める
- GPIO の出力抵抗 (数十 Ω、目安) は R1 に比べて小さいので無視した

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (Pico 2 は USB から給電)
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor b24 b29 1k
  C1: capacitor c29 c31 220p
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/25-eye-pattern.svg)

配置は 7-22 と同じで、R1 (b24〜b29) を 1 kΩ、C1 (c29〜c31) を 220 pF にする。1+ は a24 (送り側)、2+ は a29 (受け側)。
1 nF のときは C1 だけを同じ穴で差し替える。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Scope | CH1・CH2 とも 1 V/div、Time 200 ns/div (2 ビットぶん)。Trigger は CH1 の立ち上がりと立ち下がりの両方 (Either) 1.65 V、Position を −500 ns にして端を画面の左寄りへ |
| 重ね書き | 残像 (Persistence) の表示を入れて数秒。CH2 に目が開く (目安。表示の名前は WaveForms の版で違う) |
| 波形を順に見る | Time 1 µs/div、Trigger は CH1 の立ち上がり、Persistence を切る (図3・図4) |

1 回分の波形を順に見ると、1 つだけの 1 と、続いた 1 の後の 1 つだけの 0 の所で、CH2 がどこまで届くかが分かる。
重ね書きのアイは、この 2 つ (と、さらに長く続いた並び) の外形が重なった物になる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 C1 = 1 nF (τ 1.02 µs) — 1 つだけの 1 は 2.06 V までしか上がらない
time: 1us/div
trigger: ch1 rising 1.65V at -4div
ch1: {wave: "= 3.3V * (step(t) - step(t - 1us) + step(t - 3us) - step(t - 6us) + step(t - 7us) - step(t - 8us))", range: 1V/div, position: 0.3div}
ch2: {wave: ch1 | rc 1.024us, range: 1V/div, position: -3.7div}
cursors: [999ns, 6.999us]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/25-eye-pattern-1.svg)

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 C1 = 220 pF (τ 0.244 µs) — 1 ビットのうちにほぼ 0 V と 3.3 V に届く
time: 1us/div
trigger: ch1 rising 1.65V at -4div
ch1: {wave: "= 3.3V * (step(t) - step(t - 1us) + step(t - 3us) - step(t - 6us) + step(t - 7us) - step(t - 8us))", range: 1V/div, position: 0.3div}
ch2: {wave: ch1 | rc 244ns, range: 1V/div, position: -3.7div}
cursors: [999ns, 6.999us]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/25-eye-pattern-2.svg)

## Pico 2 のプログラム

PRBS7 (x<sup>7</sup> + x<sup>6</sup> + 1 の帰還シフトレジスタ。127 ビットで一巡し、1 から 7 まで続く 1 と 0 を全部含む) を
127 バイト作り、1 Mbit/s の UART で送る。127 バイト送るごとに 2 ms 休む (休みは H が続くだけで、続いた 1 の一種になる)。
C/C++ (Pico SDK) が第 1、MicroPython が第 2。

### C/C++ (Pico SDK)

```c
#include "pico/stdlib.h"
#include "hardware/uart.h"

#define TX_PIN 16                // UART0 の TX
#define BAUD   1000000           // 1 Mbit/s → 1 ビット 1 µs
#define NBYTES 127
static uint8_t buf[NBYTES];

static void make_prbs7(void) {
    uint8_t lfsr = 0x7f;
    for (int i = 0; i < NBYTES; i++) {
        uint8_t b = 0;
        for (int k = 0; k < 8; k++) {
            uint8_t bit = ((lfsr >> 6) ^ (lfsr >> 5)) & 1;   // x^7 + x^6 + 1
            lfsr = (uint8_t)(((lfsr << 1) | bit) & 0x7f);
            b |= (uint8_t)(bit << k);                        // UART は LSB から送る
        }
        buf[i] = b;
    }
}

int main(void) {
    uart_init(uart0, BAUD);
    gpio_set_function(TX_PIN, GPIO_FUNC_UART);
    uart_set_format(uart0, 8, 1, UART_PARITY_NONE);   // 8N1
    make_prbs7();
    while (true) {
        for (int i = 0; i < NBYTES; i++) uart_putc_raw(uart0, buf[i]);  // FIFO が空くのを待って送る
        sleep_ms(2);
    }
}
```

`CMakeLists.txt` は 7-3 と同じ形 (`pico_stdlib hardware_uart`)。

### MicroPython

```python
from machine import UART, Pin
import time


def prbs7(n):
    lfsr = 0x7F
    out = bytearray(n)
    for i in range(n):
        b = 0
        for k in range(8):
            bit = ((lfsr >> 6) ^ (lfsr >> 5)) & 1   # x^7 + x^6 + 1
            lfsr = ((lfsr << 1) | bit) & 0x7F
            b |= bit << k                           # UART は LSB から送る
        out[i] = b
    return out


uart = UART(0, baudrate=1_000_000, tx=Pin(16))   # 8N1 が既定
buf = prbs7(127)
while True:
    uart.write(buf)
    time.sleep_ms(2)
```

MicroPython の `write` は送る前に返るので、休みの長さは C 版と少し違う (目安。アイには効かない)。

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1 | Raspberry Pi Pico 2 | USB から給電。UART0 TX = GP16 |
| R1 | 1 kΩ | 伝送路の抵抗の代わり。最大 3.3 mA は GPIO の 4 mA (既定) に収まる |
| C1 | 220 pF (221)・1 nF (102) | 差し替える。受け側の容量の代わり |
| 電源 | USB 5 V | AD3 の Supplies は使わない |

## 見るべき値

計算値。T = 1 µs、τ = 1 kΩ × (C1 + 24 pF)。

| 測る所 | C1 = 220 pF (τ 0.244 µs) | C1 = 1 nF (τ 1.024 µs) | 分かること |
| --- | --- | --- | --- |
| 1 つだけの 1 の終わり (図の X1) | 3.24 V | 2.06 V | 1 ビットでどこまで上がれるか |
| 3 つ続いた 1 の後の 1 つだけの 0 の終わり (X2) | 0.055 V | 1.18 V | 前のビットの名残り (ISI) |
| アイの高さ (最悪) 3.3 V × (1 − 2 e<sup>−T/τ</sup>) | 3.19 V (97 %) | 0.81 V (25 %) | 1.65 V で 0 と 1 を見分ける余裕 |
| アイの真ん中の時刻 | 端から約 0.5 µs | 端から 1 µs 近く (遅れる) | 標本を取る時刻の余裕 |

**読み方**: アイの高さが 0 に近づくと、受け側は 1.65 V のしきい値で 0 と 1 を取り違える。τ が T に近い (1 nF) と
アイは 4 分の 1 まで閉じ、雑音やしきい値のずれ (Pico 2 の V<sub>IH</sub> 2.0 V・V<sub>IL</sub> 0.8 V) に食われる。
速く送るほど (T が短いほど) アイは閉じるので、伝送路の帯域とビットの速さの釣り合いが見える。
**動かないとき**: CH1 に信号が無ければプログラムと GP16 の列、CH2 が平らなら R1 と C1 の列を確かめる。

## LTspice での確かめ

`02-analog-discovery/07-logic/sim/25-eye-rc-channel.cir`。図3 と同じ並び (1 ビット 1 µs) の 0 / 3.3 V の PWL → R1 → C1 (+ 24 pF)。
GPIO の出力抵抗は無視した (仮定)。

| 本文の数字 | LTspice | 判定 |
| --- | --- | --- |
| 1 nF: X1 2.06 V・X2 1.18 V | 2.056 V・1.183 V | 合う |
| 220 pF: X1 3.24 V・X2 0.055 V | 3.245 V・0.055 V | 合う |

アイの高さ 3.19 V・0.81 V は算術 (3.3 × (1 − 2 e<sup>−T/τ</sup>)、0 と 1 が限りなく続いた後の最悪)。

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| UART の設定 | UART0 を 1 Mbit/s・8N1、TX = GP16 | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 送る並び | 127 バイト (1016 ビット) が 127 ビットの周期で繰り返し、1 周期に 1 が 64 個、7 ビットの窓 127 通りが全部違う (PRBS7) | C: Pico SDK のモック・MicroPython: `machine` のスタブ |

見ていない物: 線の上の波形 (外部部品)。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
UART0 の TX に使える GPIO は [RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) の GPIO の機能表、
Scope の入力容量は [Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
参考: [Eye pattern](https://en.wikipedia.org/wiki/Eye_pattern)、[Pseudorandom binary sequence](https://en.wikipedia.org/wiki/Pseudorandom_binary_sequence)
