---
book: analog-discovery
chapter: 7
id: 7-23
title: クロックのオーバーシュートとリンギング
tier: 200
source: 自作 (計器の操作は Digilent の Using the Oscilloscope)
board: BB
---

# 7-23 クロックのオーバーシュートとリンギング

速い立ち上がりのクロックを長い配線で送ると、受け側の電圧が電源を超えて跳ね (オーバーシュート)、しばらく揺れる (リンギング)。
配線のインダクタンス L と受け側の入力容量 C が直列の共振回路を作り、駆動側の抵抗が小さいとほとんど減衰しないためだ。
実物の配線 (数 cm で数十 nH、入力が数 pF) では共振が数百 MHz になり AD3 では見えないので、ここでは
**L を 22 µH (マイクロヘンリー)、C を 220 pF に大きくした模型**で共振を 2.17 MHz に下ろし、Raspberry Pi Pico 2 の GPIO の
100 kHz のクロックで叩く。直列の抵抗 R1 を 0 Ω (オーム)・220 Ω・560 Ω と替え、行き過ぎが減って臨界制動になる様子を **Scope** で見る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 L1 と C1 で配線と受け側の入力をまねる
parts:
  U1: pico2 3,6
  G2: ground 5,3.2 r270
  R1: resistor 6,10 8.5,10 220
  L1: inductor 8.5,10 11,10 22u
  C1: capacitor 11,10 11,12 220p
  G1: ground 11,12
  AD:
    type: device
    at: 15,9.6
    label: AD3
    pins: [1+, 2+, 1-, 2-, GND]
  G4: ground 13.5,12
wires:
  - U1.GP16 -- 5.5,10
  - 5.5,10 -- 6,10
  - 5.5,10 -- 5.5,8.4
  - 5.5,8.4 -- 12,8.4
  - 12,8.4 |- AD.1+
  - U1.GND38 -| 5,3.2
  - 11,10 -- 12.5,10
  - 12.5,10 |- AD.2+
  - AD.1- -| 13.5,12
  - AD.2- -| 13,12
  - AD.GND -| 12.5,12
  - 12.5,12 -- 13,12 -- 13.5,12
notes:
  - text 1,13.4 small left: "R1 は 0 Ω (線)・220 Ω・560 Ω と替える"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/23-clock-overshoot-ringing.svg)

- 共振周波数 f<sub>0</sub> = 1 / (2π (パイ) √(L × C))。C は C1 220 pF と Scope の入力容量 24 pF (AD3 の仕様) を足した 244 pF で、f<sub>0</sub> = 2.17 MHz
- 特性インピーダンス Z<sub>0</sub> = √(L / C) = 300 Ω。直列の抵抗の合計 R (GPIO の出力抵抗 + R1) との比で減衰率 ζ (ゼータ) = R / (2 Z<sub>0</sub>) が決まる
- GPIO の出力抵抗は約 40 Ω と置いた (仮定)。RP2350 のデータシートの 12 mA 駆動の V<sub>OH</sub> ≥ 2.62 V・V<sub>OL</sub> ≤ 0.5 V から、42〜57 Ω 以下になる
- C1 の上には IC をつながない。オーバーシュートで 6 V 近くになり、3.3 V の IC の入力の絶対最大定格を超えるため
- CH1 は GP16 (送り側)、CH2 は C1 の上 (受け側)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (Pico 2 は USB から給電)
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor b24 b28 220
  L1: inductor c28 c32 22u
  C1: capacitor d32 d34 220p
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, 2+, GND, 1-, 2-]
wires:
  - a34 -- -t34 black
  - a7 -- -t7 black
  - AD.1+ -- a24 yellow
  - AD.2+ -- a32 blue
  - AD.GND -- -t36 black
  - AD.1- -- -t37 black
  - AD.2- -- -t38 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/23-clock-overshoot-ringing.svg)

Pico 2 は h5。GP16 (21 番) は上の列の 24 列。R1 (b24〜b28)・L1 (c28〜c32)・C1 (d32〜d34) を上のブロックで右へ並べ、C1 の他端は a34 から −t へ。
GND (38 番、7 列) も a7 から −t へ。1+ は a24 (GP16)、2+ は a32 (C1 の上)、GND・1−・2− は −t。
R1 を 0 Ω にするときは b24〜b28 に線を 1 本挿す。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Scope | CH1 2 V/div、CH2 1 V/div (6 V まで振れるので 0.5 V/div より上の範囲)、Time 500 ns/div、Trigger は CH1 の立ち上がり 1.65 V。カーソルを最初の山に置き、Measure に Maximum |
| 標本化 | 125 MS/s (8 ns ごと)。2.17 MHz の 1 周期 461 ns に 58 点 |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 R1 = 0 Ω — C1 の電圧 (CH2) は 5.98 V まで跳ね、2.17 MHz で揺れる
time: 500ns/div
trigger: ch1 rising 1.65V at -4div
ch1: {wave: square 100kHz 1.65V offset 1.65V, range: 2V/div, position: 1.5div}
ch2: {wave: ch1 | lc 2.17MHz 7.51, range: 1V/div, position: -3.5div}
cursors: [0, 231ns]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/23-clock-overshoot-ringing-1.svg)

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 R1 = 220 Ω — 行き過ぎは 22 % (4.03 V) に減る
time: 500ns/div
trigger: ch1 rising 1.65V at -4div
ch1: {wave: square 100kHz 1.65V offset 1.65V, range: 2V/div, position: 1.5div}
ch2: {wave: ch1 | lc 2.17MHz 1.15, range: 1V/div, position: -3.5div}
cursors: [0, 255ns]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/23-clock-overshoot-ringing-2.svg)

## Pico 2 のプログラム

GP16 に 100 kHz・Duty 50 % のクロックを出し続ける。C/C++ (Pico SDK) が第 1、MicroPython が第 2。

### C/C++ (Pico SDK)

```c
#include "pico/stdlib.h"
#include "hardware/pwm.h"

#define CLK_PIN 16

int main(void) {
    gpio_set_function(CLK_PIN, GPIO_FUNC_PWM);
    gpio_set_drive_strength(CLK_PIN, GPIO_DRIVE_STRENGTH_12MA);  // 強く駆動 (出力抵抗が小さい)
    gpio_set_slew_rate(CLK_PIN, GPIO_SLEW_RATE_FAST);            // 速い立ち上がり
    uint slice = pwm_gpio_to_slice_num(CLK_PIN);
    pwm_set_clkdiv(slice, 1.0f);
    pwm_set_wrap(slice, 1499);              // 1500 / 150 MHz = 10 µs (100 kHz)
    pwm_set_gpio_level(CLK_PIN, 750);       // Duty 50 %
    pwm_set_enabled(slice, true);
    while (true) tight_loop_contents();
}
```

`CMakeLists.txt` は 7-3 と同じ形で、`target_link_libraries` に `pico_stdlib hardware_pwm`。ビルドと書き込みも 7-3 と同じ。

### MicroPython

```python
from machine import Pin, PWM
import time

pwm = PWM(Pin(16), freq=100_000, duty_u16=32768)   # 100 kHz・Duty 50 %
while True:
    time.sleep(1)
```

MicroPython 版は駆動の強さを既定 (4 mA) のまま変えない。出力抵抗が C 版より大きいぶん、リンギングは弱く出る (目安)。

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1 | Raspberry Pi Pico 2 | USB から給電。クロック = GP16 |
| R1 | 0 Ω (線)・220 Ω・560 Ω | 差し替える。560 Ω で臨界制動 (R の合計 600 Ω = 2 Z<sub>0</sub>) |
| L1 | 22 µH | アキシャルのリード品。配線のインダクタンスの代わり。直流抵抗は 1 Ω 前後で無視した (目安) |
| C1 | 220 pF (221) | セラミック。受け側の入力容量の代わり |
| 電源 | USB 5 V | AD3 の Supplies は使わない |

## 見るべき値

計算値。L = 22 µH、C = 244 pF、Z<sub>0</sub> = 300 Ω、GPIO の出力抵抗 40 Ω (仮定)。行き過ぎ = exp(−πζ / √(1 − ζ<sup>2</sup>))。

| R1 | R の合計 | ζ | 山の電圧 (行き過ぎ) | 揺れの周波数 | 分かること |
| --- | --- | --- | --- | --- | --- |
| 0 Ω | 40 Ω | 0.067 | 5.98 V (81 %) | 2.17 MHz | ほとんど減衰しない。包絡線の時定数 2L / R = 1.1 µs |
| 220 Ω | 260 Ω | 0.43 | 4.03 V (22 %) | 1.96 MHz | 2 つめの山はほぼ見えない |
| 560 Ω | 600 Ω | 1.0 | 3.30 V (0 %) | — | 臨界制動。揺れずに最短で 3.3 V に着く |

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の周期 | 10.0 µs (100 kHz) | wrap 1499 |
| 最初の山までの時間 | 231 ns (0 Ω)・255 ns (220 Ω) | 揺れの半周期 |
| 0 Ω の揺れの包絡線 | 1.1 µs ごとに 1/e | 山の高さの比から R の合計 (= 出力抵抗 + R1) を逆算できる |

**直し方は送り側の直列抵抗 (ダンピング抵抗)**。実際の基板では R の合計を Z<sub>0</sub> (線路なら特性インピーダンス) に合わせ、22〜47 Ω を送り側に入れる。
駆動を 12 mA から 2 mA に弱めても出力抵抗が増えて同じ向きに効く。**動かないとき**: CH2 が CH1 と同じ方形波なら L1 の列、
CH2 が 0 V なら C1 の向きと列、揺れの周波数が 2.17 MHz から大きくずれるなら C1 の値 (Scope の 24 pF を足したか) を確かめる。

## LTspice での確かめ

`02-analog-discovery/07-logic/sim/23-clock-ringing.cir`。0〜3.3 V の段 (立ち上がり 2 ns) → 出力抵抗 40 Ω (仮定) → R1 → L1 → C1 244 pF。

| 本文の数字 | LTspice | 判定 |
| --- | --- | --- |
| 0 Ω: 山 5.98 V、揺れ 2.17 MHz | 5.976 V、2.168 MHz | 合う |
| 220 Ω: 山 4.03 V、揺れ 1.96 MHz | 4.030 V、1.958 MHz | 合う |
| 560 Ω: 行き過ぎ 0 % | 最大 3.300 V (3.3 V を超えない) | 合う |

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| クロックの周期とデューティ | GP16 (スライス 0 の A)、wrap 1499 で 10.0 µs (100 kHz)、50 %。MicroPython は freq 100,000 Hz・duty_u16 32768 | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 駆動の強さ | C 版は 12 mA・速い立ち上がり | C: Pico SDK のモック |

見ていない物: 線の上の波形とリンギング (外部部品)。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
GPIO の V<sub>OH</sub>・V<sub>OL</sub> と駆動の強さは [RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) の表 1683、
Scope の入力容量 24 pF・帯域は [Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
参考: [RLC circuit](https://en.wikipedia.org/wiki/RLC_circuit)、[Ringing (signal)](https://en.wikipedia.org/wiki/Ringing_(signal))
