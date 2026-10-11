---
book: fpga
chapter: 5
id: 5-16
title: ブラウザと Pico 2 で同じ Verilog を動かして波形を比べる
tier: 100
source: 自作
board: BB
device: PICO
---

# 5-16 ブラウザと Pico 2 で同じ Verilog を動かして波形を比べる

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 のプログラムは `.uf2` までのビルドを確かめたが、書き込んで動かしてはいない。
> 値の並びは PC の Verilator で同じ回路を回した値で、4-3 のブラウザの値 (実際に動かして確かめた) と突き合わせた。
> Pico 2 の画面の時間の目盛は、プログラムで決めた設計値 (100 Hz)。実測の欄は空けてある。

この本の芯は、**1 本の Verilog を、ブラウザ → Pico 2 → 実物の FPGA の 3 つの所で動かして比べる**ことである。
4-3 では、分周器の Verilog をブラウザの soft-fpga で動かした。この題では、**同じ `counter.v` を、1 文字も変えずに** Pico 2 で動かし、
AD3 の Logic で見た波形を 4-3 の画面と並べる。

比べるのは 2 つ。

- **値の並び**: `led`・`tick`・`ticks` の変わり方。Verilog が同じなら、どこで動かしても**同じ**になるはず
- **時間の目盛**: 1 クロックが何秒か。ブラウザでは「ページが回した速さ」、Pico 2 では 5-7 で決めたタイマの周期になり、**違う**

## 動かす Verilog

4-3 の `counter.v` (分周器、`DIV = 4`)。ポートは `clk`・`rst`・`count[7:0]`。`count` の下位 4 ビットだけを LED と AD3 に出す。

| count のビット | 名前 | 意味 | Pico 2 のピン |
| --- | --- | --- | --- |
| `count[0]` | `led` | DIV クロックごとに反転 (周期 8 クロック) | GP5 (LED OUT0)、GP18 (AD3 の DIO2) |
| `count[1]` | `tick` | `phase == DIV-1` のとき 1 クロックだけ 1 | GP4 (LED OUT1)、GP19 (DIO3) |
| `count[2]` | `ticks[0]` | `tick` の回数の最下位 | GP3 (LED OUT2)、GP20 (DIO4) |
| `count[3]` | `ticks[1]` | `tick` の回数の次のビット | GP2 (LED OUT3)、GP21 (DIO5) |

Verilog の全文は 4-3 にある。ここでは置かない (二重にしない)。4-3 の手順 1 のとおり `counter.v` を作り、作業用のフォルダの `div43/counter.v` に置く。

## 同じ値の並び (PC の Verilator)

`counter.v` を Verilator で C++ にし、リセットのあと、立ち上がりごとに `count` を読んだ値。4-3 の画面と、Pico 2 の画面の両方が、この並びになる (24 クロックぶんのうち、初めの 12)。

| 立ち上がり | `led` | `tick` | `ticks[0]` | `ticks[1]` | `count` |
| --- | --- | --- | --- | --- | --- |
| 1 | 0 | 0 | 0 | 0 | 0 |
| 2 | 0 | 0 | 0 | 0 | 0 |
| 3 | 0 | 1 | 0 | 0 | 2 |
| 4 | 1 | 0 | 1 | 0 | 5 |
| 5 | 1 | 0 | 1 | 0 | 5 |
| 6 | 1 | 0 | 1 | 0 | 5 |
| 7 | 1 | 1 | 1 | 0 | 7 |
| 8 | 0 | 0 | 0 | 1 | 8 |
| 9 | 0 | 0 | 0 | 1 | 8 |
| 10 | 0 | 0 | 0 | 1 | 8 |
| 11 | 0 | 1 | 0 | 1 | 10 |
| 12 | 1 | 0 | 1 | 1 | 13 |

- `led` は 4 つ目 (4・8・12 …) の立ち上がりで反転する。`tick` はその 1 つ前の立ち上がり (3・7・11 …) で立つ
- 4-3 の「見るべき値」の、`led` の反転が 4・8・12・16・20 回目、`tick` が 3・7・11・15・19 回目という並びと一致する

## 回路図

図1・図2 は 5-5 と同じ。DIP スイッチは使わない。

```circuit
title: 図1 Pico 2 に LED 4 個・DIP スイッチ・AD3 の Logic をつなぐ
parts:
  U1: pico2 8,8 mirror
  R1: resistor 13,2 15,2 330
  D1: led 15,2 17,2
  R2: resistor 13,3.2 15,3.2 330
  D2: led 15,3.2 17,3.2
  R3: resistor 13,4.4 15,4.4 330
  D3: led 15,4.4 17,4.4
  R4: resistor 13,5.6 15,5.6 330
  D4: led 15,5.6 17,5.6
  G1: ground 17.6,6.4
  G3: ground 10.2,7.6
  SW1: dip-switch4 13,10
  G2: ground 15.4,11.2
  AD:
    type: device
    at: 2,10.8
    label: AD3
    pins: [DIO5, DIO4, DIO3, DIO2, GND, DIO1, DIO0]
    turn: mirror
wires:
  - U1.GP2 -| 10,2
  - 10,2 -- 13,2
  - U1.GP3 -| 10.5,3.2
  - 10.5,3.2 -- 13,3.2
  - U1.GP4 -| 11,4.4
  - 11,4.4 -- 13,4.4
  - U1.GP5 -| 11.5,5.6
  - 11.5,5.6 -- 13,5.6
  - 17,2 -- 17.6,2 -- 17.6,3.2
  - 17,3.2 -- 17.6,3.2 -- 17.6,4.4
  - 17,4.4 -- 17.6,4.4 -- 17.6,5.6
  - 17,5.6 -- 17.6,5.6 -- 17.6,6.4
  - U1.GND8 -| 10.2,7.6
  - U1.GP10 -| 9.8,9.4
  - 9.8,9.4 |- SW1.A1
  - U1.GP11 -| 10,9.8
  - 10,9.8 |- SW1.A2
  - U1.GP12 -| 10.2,10.2
  - 10.2,10.2 |- SW1.A3
  - U1.GP13 -| 10.4,10.6
  - 10.4,10.6 |- SW1.A4
  - SW1.B1 -| 15.4,9.4
  - SW1.B2 -| 15.4,9.8
  - SW1.B3 -| 15.4,10.2
  - SW1.B4 -| 15.4,10.6
  - 15.4,9.4 -- 15.4,9.8 -- 15.4,10.2 -- 15.4,10.6 -- 15.4,11.2
  - AD.DIO5 -- U1.GP21
  - AD.DIO4 -- U1.GP20
  - AD.DIO3 -- U1.GP19
  - AD.DIO2 -- U1.GP18
  - AD.GND -- U1.GND23
  - AD.DIO1 -- U1.GP17
  - AD.DIO0 -- U1.GP16
notes:
  - text 9,12.6: GP10-GP13 は Pico 2 の内蔵プルアップ (ON で L)
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/16-browser-vs-pico.svg)

- 配線は 5-5 と同じ。AD3 の DIO2 (`led`)・DIO3 (`tick`)・DIO4 (`ticks[0]`)・DIO5 (`ticks[1]`) を読む。DIO0 は CLK
- LED (GP2〜GP5) は `count[3:0]` の上から順 (GP2 が `ticks[1]`、GP5 が `led`)

## 実体配線図

```bread
title: 図2 Pico 2 の左に LED、右に DIP スイッチ、上に AD3 の Logic
board: full
parts:
  U1: pico2 @ g15
  R4: resistor g3 c3 330
  D4: led b3(A) b4(K) red
  R3: resistor g6 c6 330
  D3: led b6(A) b7(K) red
  R2: resistor g9 c9 330
  D2: led b9(A) b10(K) red
  R1: resistor g12 c12 330
  D1: led b12(A) b13(K) red
  SW1: dip-switch4 @ e37 r180
  AD:
    type: device
    at: top
    label: AD3 Logic
    pins: [DIO5, DIO4, DIO3, DIO2, GND, DIO1, DIO0]
wires:
  - j22 -- -b22 black
  - -t1 -- -b1 black
  - a4 -- -t4 black
  - a7 -- -t7 black
  - a10 -- -t10 black
  - a13 -- -t13 black
  - h18 -- h12 yellow
  - i19 -- i9 yellow
  - j20 -- j6 yellow
  - j21 -- j3 yellow [v15]
  - a37 -- -t37 black
  - a38 -- -t38 black
  - a39 -- -t39 black
  - a40 -- -t40 black
  - h31 -- h37 blue
  - i30 -- i38 blue
  - j29 -- j39 blue
  - j28 -- j40 blue [v15]
  - AD.DIO5 -- a28 green
  - AD.DIO4 -- a29 green
  - AD.DIO3 -- a30 green
  - AD.DIO2 -- a31 green
  - AD.GND -- -t32 black
  - AD.DIO1 -- a33 orange
  - AD.DIO0 -- a34 white
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/breadboard/16-browser-vs-pico.svg)

- 配線は 5-5 と同じ。AD3 は DIO0 (白、CLK) と DIO2〜DIO5 (緑)
- LED は左から OUT0・OUT1・OUT2・OUT3 (左が下の桁)。OUT0 が `led`

## 部品表

5-5 と同じ (Pico 2、330 Ω (オーム) の抵抗 4 本、赤の LED 4 個、4 連の DIP スイッチ、full のブレッドボード、AD3)。DIP スイッチはこの題では使わない。
電源は 3.3 V (Pico 2 の GPIO)。5 V を入れないのは 0-3 と同じ理由。

## Pico 2 のプログラム

作業用のフォルダは 5-5 と共通で、`board.h` は 5-5 のまま。`counter.v` は `div43/` に置く (2-4 の `counter.v` と名前が重なるため)。

`verilate.sh` の最後に、次の 1 行を足す。

```bash
verilator --cc --no-timing --no-trace -Wall --prefix Vcounter43 --Mdir v_counter43 div43/counter.v
```

`clock516.cpp`:

```cpp
// 5-16 4-3 の分周器 (counter43.v) を、5-7 の方法で 100 Hz に固定して回す
#include "board.h"
#include "Vcounter43.h"

constexpr int64_t HALF_US = 5000;   // 半周期 5 ms → クロック 100 Hz

static Vcounter43 top;
static unsigned g_clk = 0;

static bool on_half(repeating_timer_t*) {
    g_clk ^= 1u;
    gpio_put(PIN_CLK, g_clk);
    top.clk = g_clk;
    top.eval();
    if (g_clk) put_leds(top.count & 0xFu);    // b0 = led、b1 = tick、b2 = ticks[0]、b3 = ticks[1]
    return true;
}

int main() {
    board_init();
    top.rst = 1; top.eval();                  // 非同期リセット
    top.rst = 0; top.eval();

    repeating_timer_t timer;
    add_repeating_timer_us(-HALF_US, on_half, nullptr, &timer);
    while (true) tight_loop_contents();
}
```

`CMakeLists.txt` の最後に次の 1 行を足す。

```cmake
add_soft_fpga(clock516 clock516.cpp counter43)
```

- 回し方は 5-7 と同じ。負の周期の繰り返しタイマで、半周期 5 ms (クロック 100 Hz) ごとに立ち上がりと立ち下がりを交互に `eval()` する
- `counter.v` のリセットは非同期 (`posedge rst`) なので、`rst` を 1 → 0 にして `eval()` するだけでよい
- LED を目で見るなら、`HALF_US` を 250 000 (半周期 250 ms、クロック 2 Hz) にして書き直す。`led` の周期は 8 クロック = 4 s になる

`lint` は 4-3 と同じく警告なしで通った (Verilator 5.042 の `--lint-only -Wall`)。`-Wall` の C++ への変換も警告なし (Verilator 5.048)。
空のフォルダから 5-1 の手順でビルドし、`build/clock516.uf2` (94 208 バイト) ができた (Pico SDK 2.2.0)。
`arm-none-eabi-size` は text 50 696 バイト、bss 2 376 バイト。**実機では動かしていない。**

## 計器の設定

計器は AD3 の Logic。

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 (CLK)、DIO2〜DIO5 (`led`・`tick`・`ticks[0]`・`ticks[1]`) を Enable。標本化 10 kHz (窓は 3.28 s) |
| バス | DIO5・DIO4 を `ticks` の 2 ビットとして、10 進で見る (4-3 と同じ) |
| Logic のトリガ | DIO0 の立ち上がり。リセットのあと最初の立ち上がり |
| 時間軸 | 20 ms/div (窓 200 ms で 20 クロック) |
| カーソル | X1 を 45 ms、X2 を 125 ms。どちらも `led` が H の間。間隔 80 ms が `led` の 1 周期 |

## Logic に見えるはずの画面

図3 は 4-3 のブラウザの画面 (1 クロックを 1 ms と置いて描いた図)。図4 は同じ Verilog を Pico 2 で 100 Hz に固定して動かしたときの Logic。
**値の並びは同じで、横軸の目盛だけが 10 倍違う**。ブラウザの画面の時間は仮の目盛、Pico 2 の画面はタイマの設計値。

```logic
title: 図3 ブラウザ (4-3) の画面。1 クロックを 1 ms と置いた仮の目盛
device: generic
window: 20ms
signals:
  CLK: dio0 clock 1kHz
  LED: dio1 edges 0s=0 3ms=1 7ms=0 11ms=1 15ms=0 19ms=1
  TICK: dio2 edges 0s=0 2ms=1 3ms=0 6ms=1 7ms=0 10ms=1 11ms=0 14ms=1 15ms=0 18ms=1 19ms=0
  T0: dio3 edges 0s=0 3ms=1 7ms=0 11ms=1 15ms=0 19ms=1
  T1: dio4 edges 0s=0 7ms=1 15ms=0
buses:
  Ticks: T1 T0 dec
cursors: [4.5ms, 12.5ms]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/16-browser-vs-pico-1.svg)

```logic
title: 図4 Pico 2 の画面。値の並びは図3 と同じで、1 クロックが 10 ms (設計値)
device: ad3
time: 20ms/div
start: -20ms
sample: 10kHz
signals:
  CLK: dio0 clock 100Hz
  LED: dio2 edges -20ms=0 30ms=1 70ms=0 110ms=1 150ms=0 190ms=1
  TICK: dio3 edges -20ms=0 20ms=1 30ms=0 60ms=1 70ms=0 100ms=1 110ms=0 140ms=1 150ms=0 180ms=1 190ms=0
  T0: dio4 edges -20ms=0 30ms=1 70ms=0 110ms=1 150ms=0 190ms=1
  T1: dio5 edges -20ms=0 70ms=1 150ms=0
buses:
  Ticks: T1 T0 dec
cursors: [45ms, 125ms]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/16-browser-vs-pico-2.svg)

- 図3 と図4 の `led` は、どちらも 3 つ目の立ち上がりの次 (4 つ目) で H になり、4 クロックのあいだ H。時間だけが 1 ms と 10 ms
- `tick` は `led` が変わる 1 クロック前に立つ。図3 では 2 ms、図4 では 20 ms (どちらも 3 つ目の立ち上がり)
- カーソルの間隔は `led` の 1 周期 (8 クロック)。図3 では 8 ms、図4 では 80 ms
- 図4 の時間は、**ばらつきを含まない設計値**。実機の CLK の周期の揺れは 5-10 で測る

## 見るべき値

**Pico 2 の画面は測っていない。** 値の並びは PC の Verilator の値 (4-3 と一致)。

| 比べる所 | ブラウザ (4-3) | Pico 2 (この題) | 種類 |
| --- | --- | --- | --- |
| `led` が反転するクロック | 4・8・12・16・20 回目 | 同じ (Verilator の値) | ブラウザは動かして確かめた。Pico 2 は PC の値 |
| `tick` が 1 になるクロック | 3・7・11・15・19 回目 | 同じ (Verilator の値) | 同上 |
| 100 クロック後の `count` | 101 (`ticks` = 25、`tick` = 0、`led` = 1) | 101 (PC の Verilator の値) | ブラウザの値は 4-3 |
| 1 クロックの時間 | ページが回した速さ。決まっていない | 10.000 ms (設計値) | Pico 2 はタイマの設計値 |
| `led` の周期 (ΔX、図4 のカーソル) | 8 クロック (時間は決まらない) | 80 ms (設計値)。(測って書く) ms | Pico 2 は測って書く |
| CLK の周期のばらつき | (ない。時間が決まらない) | (測って書く) µs (マイクロ秒) | 5-10 の測り方 |
| Logic の 4 本の変わり目の順 | `tick` → `led` と `ticks[0]` が同時 → `ticks[1]` | 同じ順 (測って書く) | Pico 2 は測って書く |

次の 8-6・8-7 で、同じ `counter.v` を実物の FPGA で動かし、**1 クロックの時間が水晶で決まる**(ばらつきが小さい) ことを、この表の続きに足す。

## 出典

自作。`counter.v` は 4-3。ブラウザの画面は [soft-fpga](https://github.com/tommie-jp/soft-fpga) の `examples/01-counter`、Pico 2 での回し方は 5-1・5-7。
値の並びは Verilator で回した (PC)。
