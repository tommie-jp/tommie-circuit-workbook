---
book: circuits
chapter: 11
id: 11-12
title: デカップリングとグラウンド
tier: 200
source: 自作
era: 今
---

# 11-12 デカップリングとグラウンド

デジタルの IC は、出力が切り替わる数 ns (ナノ秒) のあいだだけ、電源から大きな電流をまとめて引く。電源から IC までの線は、
長さ 1 cm あたり 10 nH ほど (目安) のインダクタンスを持つので、急な電流には追いつけず、IC の VCC のピンの電圧が一瞬下がる。
これを防ぐのが、**IC の VCC と GND のピンのすぐ横に置くコンデンサ (デカップリング、パスコン)**。切り替わりの電流をそこから出し、
長い線には平均の電流だけを流させる。

ここでは Pico 2 の PWM で 74HC04 (NOT が 6 回路) の 1 回路を 1 MHz で動かし、100 pF の負荷を充放電させる。
C1 (0.1 µF) を挿したときと抜いたときで、74HC04 の VCC のピンの電圧を比べる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 GP15 の 1 MHz で 74HC04 を動かす。C1 は VCC のピンの脇に置く
parts:
  U1: pico2 3,5 mirror
  U2: dip14 10,7 74HC04
  P3V3: vcc 1,2.25 3.3V
  G4: ground 1.75,3.25 r90
  P3V3: vcc 11.5,5.25 3.3V
  C1: capacitor 12.25,6.25 12.25,7.25 100n
  G1: ground 12.25,7.25
  C2: capacitor 8.75,6.5 8.75,7.75 100p
  G2: ground 8.75,7.75
  G3: ground 9,8.5
  G5: ground 11,8.5
wires:
  - U1.3V3 -| 1,2.25
  - U1.GND38 -- 1.75,3.25
  - U1.GP15 -- 8.5,7.5 -- 8.5,6.25 -- U2.1A
  - U2.1Y -- 8.75,6.5
  - U2.2A -- 9,6.75
  - U2.3A -- 9,7.25
  - U2.GND -- 9,7.75
  - 9,6.75 -- 9,7.25 -- 9,7.75 -- 9,8.5
  - U2.VCC -- 11.5,6.25 -- 12.25,6.25
  - 11.5,6.25 -- 11.5,5.25
  - U2.6A -- 11,6.5
  - U2.5A -- 11,7
  - U2.4A -- 11,7.5
  - 11,6.5 -- 11,7 -- 11,7.5 -- 11,8.5
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/12-decoupling-ground.svg)

- GP15 の 1 MHz の方形波を 1A (1 番) に入れ、1Y (2 番) で C2 (100 pF。長い線や次の IC の入力の代わり) を充放電する
- **C1 は VCC (14 番) と GND のすぐ横**。回路図では VCC の線の途中に描いたが、実物では「3V3 から来た線が C1 に着いてから IC に入る」ように置く
- 使わない入力 (2A〜6A) は GND につなぐ。CMOS の入力を開けておくと、電圧がふらついて中で電流が流れ、出力も勝手に切り替わる (10-1)
- **GND も電源と同じく線**。GND の線が長いと、戻りの電流で IC の GND のピンが持ち上がる (グラウンドバウンス)。Pico 2 と 74HC04 の GND は太く短く、1 点でまとめる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 74HC04 の VCC (35 列の上) の真横に C1 を挿す。外すと VCC が揺れる
board: full
parts:
  MCU: pico2 @ h5
  U2: dip14 @ e35 74HC04
  C1: capacitor b35 b33 100n
  C2: capacitor h36 h31 100p
  SC2:
    type: device
    at: top
    label: AD3 Scope 2
    pins: [2+, 2-]
  SC1:
    type: device
    at: bottom
    label: AD3 Scope 1
    pins: [1+, 1-]
wires:
  - MCU.3V3 -- +t9 red
  - MCU.GND38 -- -t7 black
  - -t62 -- -b62 black
  - a35 -- +t34 red
  - a33 -- -t33 black
  - a36 -- -t36 black
  - a38 -- -t38 black
  - a40 -- -t40 black
  - j37 -- -b37 black
  - j39 -- -b39 black
  - j41 -- -b41 black
  - j31 -- -b31 black
  - MCU.GP15 -- i35 yellow
  - SC1.1+ -- g36 green
  - SC1.1- -- -b44 black
  - SC2.2+ -- c35 orange
  - SC2.2- -- -t45 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/breadboard/12-decoupling-ground.svg)

- 74HC04 (U2) は e35 に挿す。上の列が左から 14 番 (VCC)・6A・6Y・5A・5Y・4A・4Y、下の列が左から 1A・1Y・2A・2Y・3A・3Y・7 番 (GND)
- VCC (35 列の上) は `a35` から上の + レール (Pico 2 の 3V3) へ。C1 (35〜33 列、b 行) は VCC の列と、上の − レールへ落とした 33 列の間
- 使わない入力の 6A・5A・4A (36・38・40 列の上) は上の − レールへ、2A・3A (37・39 列の下) と GND (41 列の下) は下の − レールへ。上下の − レールは右端でつなぐ
- GP15 (24 列の下) は黄の線で 1A (35 列の下) へ。C2 (36〜31 列、h 行) は 1Y の列と、下の − レールへ落とした 31 列の間
- AD3 の Scope の 1+ を 1Y (`g36`)、2+ を VCC (`c35`) へ。図2 では同じ AD3 を 2 つの箱 (上と下) に描いた
- **比べる実験**: C1 を抜き、さらに `a35` の線を 15 cm ほどの長い線に替えると、VCC の揺れが大きくなる。C1 を戻すと小さくなる
- ブレッドボードを流れる電流は、平均で 100 pF × 3.3 V × 1 MHz ≈ 0.33 mA と小さい (山の電流は 80 mA ほど、数 ns だけ)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | マイコン | Raspberry Pi Pico 2 (USB で給電) |
| U2 | NOT ×6 | 74HC04 (3.3 V で使う) |
| C1 | セラミックコンデンサ (デカップリング) | 0.1 µF (104) |
| C2 | セラミックコンデンサ (負荷の代わり) | 100 pF (101) |
| — | 計器 | Analog Discovery 3 の Scope (1+ = 1Y、2+ = VCC、1−・2− = GND) |

## 計器の設定

計器は AD3 のオシロ (Scope)。1Y が L から H へ切り替わる 1 回の縁を拡大し、**そのときの VCC の落ち込み**を見る。C1 を抜いた形を図3 に描いた。

| 項目 | 値 |
| --- | --- |
| 電源 | Pico 2 の USB (AD3 の Supplies は使わない) |
| CH1 (1+) | 1Y。1 V/div、0 V を中央の半目盛上 |
| CH2 (2+) | VCC (14 番)。1 V/div、0 V を下から半目盛 |
| 時間レンジ | 20 ns/div |
| トリガ | CH1 の立ち上がり、1.65 V。トリガの点を左から 2 目盛に置く |
| Measurements | Minimum・Maximum |
| カーソル | X1 を 0 (切り替わりの瞬間)、X2 を 100 ns (落ち着いたあと) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 C1 を抜いたとき — 1Y (CH1) が上がる瞬間に VCC (CH2) が落ち込む
time: 20ns/div
trigger: ch1 rising 1.65V at -3div
ch1: {wave: square 1MHz 1.65V offset 1.65V, range: 1V/div, position: 0.5div}
ch2: {wave: ch1 | hp 10ns | clip 0V | gain -0.6 | offset 3.3V, range: 1V/div, position: -3.5div}
cursors: [0, 100ns]
measure: [vmin, vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/scope/12-decoupling-ground.svg)

- 1Y が H へ上がる瞬間 (X1)、C2 を充電する電流を長い線が出せず、VCC が 3.3 V から 1.3 V ほどまで落ち込む (下の LTspice の模型の値。図は形を簡単にした)
- 数十 ns で元に戻る (X2 で 3.3 V)。落ち込みが入力の L の上限 (3.3 V のとき 74HC04 で 1 V 前後、データシートの V<sub>IL</sub> は電源に比例) を下回ると、
  ほかの回路が誤って切り替わる
- C1 を挿すと、落ち込みは 0.15 V ほどに小さくなる (下の LTspice)。図は理想の形で、実物には線のインダクタンスと容量による揺れ (リンギング) が付く
- AD3 の Scope の帯域 (30 MHz ほど) では ns の山はなまって見える。山の深さは目安として読む

## プログラム

### C/C++ (Pico SDK)

```c
#include "pico/stdlib.h"
#include "hardware/pwm.h"

#define PIN_OUT 15      // PWM スライス 7 の B
#define TOP 149         // 150 MHz ÷ 150 = 1 MHz

int main(void) {
    gpio_set_function(PIN_OUT, GPIO_FUNC_PWM);
    uint slice = pwm_gpio_to_slice_num(PIN_OUT);
    pwm_set_clkdiv(slice, 1.0f);
    pwm_set_wrap(slice, TOP);
    pwm_set_gpio_level(PIN_OUT, (TOP + 1) / 2);   // H が 50 %
    pwm_set_enabled(slice, true);
    while (true) {
        tight_loop_contents();                     // PWM は CPU を使わずに出続ける
    }
}
```

`CMakeLists.txt` は 11-2 と同じ形で、名前を `pwm1m` にし、`target_link_libraries` を `pico_stdlib hardware_pwm` にする。

### MicroPython

```python
from machine import Pin, PWM

out = PWM(Pin(15), freq=1_000_000, duty_u16=32768)   # 1 MHz、H が 50 %
```

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| 1Y | 1 MHz の方形波 (GP15 の反転)、0〜3.3 V |
| VCC の落ち込み (C1 なし・長い線) | 1 V から 2 V ほど落ちる (模型の値。線の長さと IC で大きく変わる) |
| VCC の揺れ (C1 あり) | 0.2 V 以下 |
| C1 を IC から 10 列離して挿す | C1 なしに近づく (離した線のインダクタンスが効く) |

## LTspice での確かめ

`sim/12-decoupling-ground.cir` で、3V3 から VCC までの線を 150 nH + 0.1 Ω (15 cm の目安、仮定)、74HC04 の出力を内部抵抗 40 Ω の源 (仮定)、
IC の中の容量を 10 pF (仮定)、C1 を 100 nF + ESL 2 nH (仮定) で表して、1 MHz で 100 pF を充放電させた。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| C1 なしの VCC の底 | 1.3 V ほど | 1.33 V (揺れ 3.0 Vpp) | 合う (模型の値) |
| C1 ありの VCC の底 | 0.15 V ほどの落ち込み | 3.20 V (揺れ 0.15 Vpp) | 合う |
| 線を流れる電流の山 (C1 なし → あり) | — | 47 mA → 1.9 mA | 追記 (C1 があると、長い線には平均に近い電流しか流れない) |
| 平均の電流 | 約 0.33 mA (100 pF × 3.3 V × 1 MHz) | — | 算術 |

C1 なしの値は、IC の中の容量を 10 pF と小さく置いた悪い側の見積り。実物はブレッドボードの線どうしの容量などで、もっと小さくなりうる。

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| PWM の周期と H の割合 | GP15 が 1 µs (1 MHz)・50 % | C: Pico SDK のモック・MicroPython: `machine` のスタブ |

見ていない物: 実際の VCC の揺れ・74HC04 の動作・リンギング

## 出典

自作。

参考: [TI SN74HC04 データシート](https://www.ti.com/lit/ds/symlink/sn74hc04.pdf)、[バイパスコンデンサ (Wikipedia)](https://ja.wikipedia.org/wiki/バイパスコンデンサ)
