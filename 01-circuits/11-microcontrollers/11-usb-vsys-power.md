---
book: circuits
chapter: 11
id: 11-11
title: USB 給電と電源設計 (VSYS / VBUS)
tier: 200
source: 自作
era: 今
---

# 11-11 USB 給電と電源設計 (VSYS / VBUS)

Pico 2 の電源の入口は 3 つある。USB の 5 V が来る **VBUS** (ピン 40)、基板の電源の本線の **VSYS** (ピン 39)、
基板が作った 3.3 V を外へ出す **3V3** (ピン 36)。USB から来た VBUS は、基板の中のショットキーダイオード D1 を通って VSYS になり、
VSYS から降圧・昇圧のスイッチング電源 (RT6150) が 3.3 V を作る (Pico 2 のデータシートの「Powering Pico 2」)。

VSYS には 1.8〜5.5 V を入れてよい。ここでは AD3 の V+ (5 V) を、もう 1 本のショットキーダイオード (1N5819) を通して VSYS に入れる。
D1 と 1N5819 の 2 本で **電圧の高いほうが VSYS を受け持ち**、もう片方へは電流が逆流しない (ダイオード OR)。
プログラムは VSYS の電圧と、USB が挿さっているかを読んで表示する。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 外の 5 V を 1N5819 を通して VSYS へ (USB の VBUS は基板の中の D1 を通る)
parts:
  U1: pico2 7,4.5 mirror
  DEXT: schottky 3,2.5 5,2.5 1N5819 l=$D_\mathrm{EXT}$
  P5: vcc 2,2.5 5V
  G1: ground 5.5,4
wires:
  - 2,2.5 -- 3,2.5
  - U1.VSYS -| 5,2.5
  - U1.GND38 -| 5.5,4
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/11-usb-vsys-power.svg)

- D<sub>EXT</sub> (1N5819) は、外の 5 V から VSYS へだけ電流を通す。USB を挿していても、USB の VBUS へ外の 5 V が逆流しない (D1 も同じ働き)。
  **外の電源を VBUS や 3V3 に直につながない**。VBUS に入れると PC の USB の口へ逆流し、3V3 に入れると基板の電源とぶつかる
- ショットキーダイオードを使うのは、順方向の電圧が 0.2〜0.3 V ほどと普通のダイオード (0.6〜0.7 V) より小さく、VSYS が下がりにくいから
- GPIO29 は VSYS を 3 で割った電圧を ADC3 で読める。GPIO24 は VBUS が来ているかを H・L で返す (どちらも基板の中の配線。Pico 2 のデータシート)
- 3V3 から外の回路へ取り出す電流は 300 mA までにする (同データシート)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 AD3 の V+ (5 V) を 1N5819 から VSYS (6 列) へ
board: full
parts:
  MCU: pico2 @ h5
  DEXT: schottky c31 c27 1N5819
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, 2+, 1-, 2-, GND, V+]
wires:
  - MCU.GND38 -- -t7 black
  - AD.V+ -- a31 red
  - b6 -- b27 orange
  - AD.GND -- -t21 black
  - AD.1+ -- a6 yellow
  - AD.2+ -- a9 green
  - AD.1- -- -t18 black
  - AD.2- -- -t19 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/breadboard/11-usb-vsys-power.svg)

- Pico 2 の `VSYS` (6 列の上) から橙の線を 27 列へ運び、D<sub>EXT</sub> (27〜31 列、c 行) のカソード (帯の側) を 27 列に、アノードを 31 列に挿す。
  AD3 の V+ (赤) は 31 列 (`a31`) へ、AD3 の GND は上の − レールへ。Pico 2 の `GND` (7 列の上) も上の − レールへ
- AD3 の Scope の 1+ を VSYS (`a6`)、2+ を 3V3 (9 列の `a9`) へ、1−・2− を上の − レールへ
- AD3 の Supplies は、AD3 を USB で動かすとき 5 V で 50 mA ほどまで。何もつながない Pico 2 は 25 mA ほど (目安) なので足りるが、
  3V3 から外へ電流を取る回路を足すときは、別の 5 V 電源 (USB アダプタ) を V+ の代わりに使う
- ブレッドボードを流れるのは Pico 2 の電流 (25 mA ほど) だけで、範囲に収まる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | マイコン | Raspberry Pi Pico 2 |
| D<sub>EXT</sub> | ショットキーダイオード | 1N5819 (1 A・40 V) |
| — | 電源・計器 | Analog Discovery 3 の Supplies の V+ (5 V) と Scope (1+ = VSYS、2+ = 3V3、1−・2− = GND) |

## 計器の設定

計器は AD3 の Scope。**USB を抜いた状態で** Supplies の V+ を入れ、VSYS が上がってから 3V3 が立ち上がる順を見る。1 回きりなので Single で捕まえる。

| 項目 | 値 |
| --- | --- |
| 電源 | AD3 の Supplies の V+ を 5 V (USB は抜く) |
| CH1 (1+) | VSYS。1 V/div、0 V を下から 1 目盛 |
| CH2 (2+) | 3V3。CH1 と同じ 1 V/div・同じ 0 V の位置 |
| 時間レンジ | 1 ms/div |
| トリガ | CH1 の立ち上がり、1 V、Single。トリガの点を左から 2 目盛に置く |
| Measurements | Maximum |
| カーソル | X1 を 0.5 ms (3V3 が上がり始めるころ)、X2 を 5 ms (落ち着いたあと) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 V+ を入れたときの VSYS (CH1) と 3V3 (CH2) — 立ち上がりの速さは目安
time: 1ms/div
trigger: ch1 rising 1V at -3div
ch1: {wave: = 4.76V * step(t + 0.24ms) * (1 - exp(-(t + 0.24ms) / 1ms)), range: 1V/div, position: -3div}
ch2: {wave: = 3.3V * step(t - 0.5ms) | rc 0.2ms, range: 1V/div, position: -3div}
cursors: [0.5ms, 5ms]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/scope/11-usb-vsys-power.svg)

- VSYS (CH1) は 5 V − 1N5819 の順方向の電圧 ≈ 4.76 V まで上がる (下の LTspice)。3V3 (CH2) は VSYS がスイッチング電源の動く 1.8 V ほどを越えてから 3.3 V へ上がる
- X1 (0.5 ms) で VSYS ≈ 2.5 V・3V3 は 0 V、X2 (5 ms) で VSYS ≈ 4.7 V・3V3 ≈ 3.3 V。**立ち上がりの形と時間は目安** (AD3 の Supplies の上がり方と、RT6150 の起動の時間はデータシートから決めていない)。実機で測って直す
- USB も挿すと、VBUS (5.0〜5.1 V) と外の 5 V のうち高いほうが VSYS を受け持つ。高さが近いと、2 本のダイオードで電流を分け合う

## プログラム

### C/C++ (Pico SDK)

```c
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/adc.h"

#define PIN_VBUS_SENSE 24   // VBUS が来ていれば H
#define PIN_VSYS_ADC   29   // VSYS ÷ 3 (ADC3)

int main(void) {
    stdio_init_all();
    gpio_init(PIN_VBUS_SENSE);
    gpio_set_dir(PIN_VBUS_SENSE, GPIO_IN);
    adc_init();
    adc_gpio_init(PIN_VSYS_ADC);
    adc_select_input(3);

    while (true) {
        float vsys = adc_read() * 3.3f / 4096.0f * 3.0f;   // 基板の中の分圧 1/3 を戻す
        printf("VSYS %.2f V  VBUS %s\n", vsys, gpio_get(PIN_VBUS_SENSE) ? "yes" : "no");
        sleep_ms(1000);
    }
}
```

- `CMakeLists.txt` は 11-2 と同じ形で、名前を `power` にし、`target_link_libraries` を `pico_stdlib hardware_adc` にする。
  USB を抜いて外の 5 V だけで動かすときは、表示を見る口が無くなるので、`pico_enable_stdio_uart(power 1)` にして UART0 (GP0) から読む

### MicroPython

```python
from machine import ADC, Pin
import time

vbus = Pin(24, Pin.IN)       # VBUS が来ていれば 1
vsys = ADC(29)               # VSYS ÷ 3 (ADC3)

while True:
    v = vsys.read_u16() * 3.3 / 65535 * 3
    print("VSYS %.2f V  VBUS %s" % (v, "yes" if vbus.value() else "no"))
    time.sleep(1)
```

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| VSYS (外の 5 V だけ) | 約 4.76 V (テスター。プログラムも同じ) |
| VSYS (USB だけ) | 約 4.76 V (VBUS 5.0 V のとき。D1 の順方向の電圧の分だけ下がる) |
| VSYS (両方、VBUS 5.1 V) | 約 4.86 V。電流はほとんど USB の側から (下の LTspice) |
| `VBUS` の表示 | USB を挿すと yes、抜くと no |
| 3V3 | どの場合も約 3.3 V |

## LTspice での確かめ

`sim/11-usb-vsys-power.cir` で、D1 と D<sub>EXT</sub> の OR を解いた。どちらのダイオードも 1N5819 の模型 (D1 の品番は仮定)、
Pico 2 の消費は VSYS から 25 mA の定電流 (仮定) で表した。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 外の 5 V だけの VSYS | 約 4.76 V | 4.762 V | 合う |
| USB だけ (5.0 V) の VSYS | 約 4.76 V | 4.762 V | 合う |
| GPIO29 (VSYS ÷ 3) | 約 1.59 V | 1.587 V | 合う |
| 両方 (VBUS 5.1 V・外 5.0 V) の VSYS | 約 4.86 V | 4.864 V | 合う |
| 同、USB の側の電流・外の側の電流 | ほとんど USB から | 23.6 mA・1.4 mA | 合う |

## プログラムでの確かめ

本文のプログラムを PC で動かし、ADC の読みを VSYS 4.76 V に当たる値 (1970) にして突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| 設定 | GP24 を入力、GP29 を ADC3 | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 表示 | `VSYS 4.76 V  VBUS yes` を 1 s ごと。GP24 が L なら `no` | C: Pico SDK のモック・MicroPython: `machine` のスタブ |

見ていない物: 実際の電圧・ダイオードの電流・3V3 の立ち上がり

## 出典

自作。VBUS・VSYS・D1・GPIO24・GPIO29 (VSYS/3)・3V3 の 300 mA は [Pico 2 のデータシート](https://datasheets.raspberrypi.com/pico/pico-2-datasheet.pdf) (Pinout・Power Supply・Powering Pico 2) による。

参考: [ショットキーバリアダイオード (Wikipedia)](https://ja.wikipedia.org/wiki/ショットキーバリアダイオード)
