---
book: fpga
chapter: 6
id: 6-18
title: 長押しと短押しを Pico 2 で動かす — ボタン 1 つと LED 3 個
tier: 100
source: 自作
board: BB
device: PICO
---

# 6-18 長押しと短押しを Pico 2 で動かす — ボタン 1 つと LED 3 個

> [!WARNING]
> **この題は実機で組んでいない。**
> Pico 2 のプログラムは `.uf2` までのビルドを確かめたが、書き込んで動かしてはいない。AD3 での測定もしていない。
> 「見るべき値」はシミュレーションの値と設計値で、測った値ではない。

[6-6](06-long-short-press.md) で設計して PC のシミュレーションで確かめた長押し・短押しの状態機械 (`press_top`) を、Pico 2 の Soft-FPGA に載せて動かす。
ブレッドボードは 6-2・6-3 と同じ物を使い、LED の役だけ替える。クロックは 5-7 の方法で **1 kHz** に固定する。動かしたら AD3 の Logic で、押した時刻と 3 本の LED の時刻を読む。

## 回路図

回路は 6-2・6-3 と同じ。LED の役だけを替えた。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 GP0 で押しボタンを読み、短押し・長押し・繰り返しを GP15・GP14・GP16 の LED で見せる
parts:
  U1: pico2 4,6 mirror
  SHT: port 6.5,9.8
  LNG: port 6.5,9.4
  BTN: port 6.5,2.2
  RPT: port 1.5,9.8
  G0: ground 1.5,3.4
  SHT: port 8.5,3
  D1: led 8.5,3 8.5,5 green
  R1: resistor 8.5,5 8.5,7 330
  G1: ground 8.5,7
  LNG: port 11,3
  D2: led 11,3 11,5 yellow
  R2: resistor 11,5 11,7 330
  G2: ground 11,7
  RPT: port 13.5,3
  D3: led 13.5,3 13.5,5 red
  R3: resistor 13.5,5 13.5,7 330
  G3: ground 13.5,7
  BTN: port 16,3
  SW1: button 16,4 16,6 l=$\mathrm{SW1}$
  G4: ground 16,6
  AD:
    type: device
    at: 19.5,9
    label: AD3
    pins: [DIO0, DIO1, DIO2, DIO3, GND]
  SHT: port 18,8.17
  LNG: port 18,8.58
  RPT: port 18,9
  BTN: port 18,9.42
  G5: ground 18,10.4
wires:
  - U1.GP15 |- 6.5,9.8
  - U1.GP14 |- 6.5,9.4
  - U1.GP0 |- 6.5,2.2
  - U1.GP16 |- 1.5,9.8
  - U1.GND38 |- 1.5,3 -- 1.5,3.4
  - 16,3 -- 16,4
  - AD.DIO0 |- 18,8.17
  - AD.DIO1 |- 18,8.58
  - AD.DIO2 |- 18,9
  - AD.DIO3 |- 18,9.42
  - AD.GND |- 18,9.83 -- 18,10.4
style:
  pitch: 1.2
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/06-state-machines/circuit/18-long-short-press-pico.svg)

- 線で結ぶ代わりに、同じ名前の端子どうしがつながっている
- `SHT` は D1 (短押し)、`LNG` は D2 (長押し)、`RPT` は D3 (繰り返し)、`BTN` は押しボタン
- 押しボタンは GP0 と GND の間。GP0 は Pico 2 の中でプルアップする (6-2)。離すと 1、押すと 0
- AD3 は DIO3 でボタンの電圧を、DIO0〜DIO2 で 3 つの LED の信号を読む。LED の信号は 100 ms に伸ばした後の物で、
  立ち上がりの時刻が出来事の時刻 (1 ms のパルスそのものは Pico 2 の中にあり、ピンには出さない)

## 部品

6-2・6-3 と同じ。

| 部品 | 値・型番 | 数 | 役 |
| --- | --- | --- | --- |
| U1 | Raspberry Pi Pico 2 | 1 | Soft-FPGA を動かす。USB から給電 |
| D1〜D3 | 5 mm LED 緑・黄・赤 | 各 1 | 短押し・長押し・繰り返し |
| R1〜R3 | 330 Ω (オーム)、E24、1/4 W | 3 | LED の電流を決める |
| SW1 | タクトスイッチ (4 ピン) | 1 | 押す長さを変えて押すボタン |
| — | ブレッドボード (full、63 列) | 1 | |
| — | ジャンパ線 | 約 15 本 | |
| AD | Analog Discovery 3 | 1 | Logic で 4 本を測る |

電源は 3.3 V (Pico 2 の GPIO)。教科書の既定の 5 V から外すのは、Pico 2 のピンに 5 V を入れると壊れるため (0-3)。

LED の抵抗は 3.3 V で決めた。LED の順電圧を 2.0 V、流したい電流を 4 mA ほどと置くと、
(3.3 V − 2.0 V) ÷ 4 mA = 325 Ω。E24 で一番近い 330 Ω にして、電流は (3.3 − 2.0) ÷ 330 ≈ 3.9 mA (計算値)。
LED は 1 個ずつ 100 ms しか点かず、3 個が同時に点くことは無いので、GPIO 1 本あたりも合計も 4 mA ほどに収まる。

## 実体配線図

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図2 6-3 と同じブレッドボード。D1・D2・D3 が短押し・長押し・繰り返し
board: full
parts:
  MCU: pico2 @ h5
  SW1: button @ e1
  D1: led f30(A) f32(K) green
  R1: resistor j32 -b32 330
  D2: led f36(A) f38(K) yellow
  R2: resistor j38 -b38 330
  D3: led g42(A) g44(K) red
  R3: resistor j44 -b44 330
  AD:
    type: device
    at: bottom
    label: AD3 Logic
    pins: [DIO3, DIO0, DIO1, DIO2, GND]
wires:
  - a7 -- -t7 black
  - a1 -- -t1 black
  - -t63 -- -b63 black
  - i5 -- i3 blue
  - i24 -- i30 white
  - j23 -- j26 orange
  - h26 -- h36 orange
  - b24 -- b42 gray
  - e42 -- f42 gray
  - AD.DIO3 -- j3 purple
  - AD.DIO0 -- j30 green
  - AD.DIO1 -- j36 green
  - AD.DIO2 -- j42 green
  - AD.GND -- -b50 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/06-state-machines/breadboard/18-long-short-press-pico.svg)

- 6-2 の図3と同じ配線。D1 (30 列) が GP15、D2 (36 列) が GP14、D3 (42 列) が GP16、ボタン (3 列) が GP0
- GND は Pico 2 の 38 番 (7 列) から上の − レールへ。上と下の − レールは右端 (63 列) でつなぐ。
  正の電源はブレッドボードに配らないので、赤の線は無い
- AD3 の DIO3 (紫) はボタンの 3 列、DIO0〜DIO2 (緑) は 3 つの LED の列に j 行で挿す
- 電源は Pico 2 の USB。ブレッドボードを流れる電流は LED 1 個分の 4 mA ほど (計算値)、信号は 10 Hz 以下 (一番速いのは 0.2 秒ごとの繰り返し) で、ブレッドボードの範囲に収まる

## Pico 2 のプログラム

組み方は 6-2・6-3 と同じ (5-3・5-7)。

| Verilog | Pico 2 | 向き | 設定 |
| --- | --- | --- | --- |
| `clk` | (ピンなし) | — | 500 µs (マイクロ秒) ごとのタイマ割り込みで 0 と 1 を交互に入れて評価する (5-7)。1 kHz |
| `rst` | (ピンなし) | — | 起動して最初の 2 クロックだけ 1 |
| `btn_n` | GP0 | 入力 | 中のプルアップを有効に |
| `led_short` | GP15 | 出力 | D1 |
| `led_long` | GP14 | 出力 | D2 |
| `led_repeat` | GP16 | 出力 | D3 |
| `o_state` `o_pulse` | (ピンなし) | — | 使わない |

`press66.cpp`:

```cpp
// 6-6 長押しと短押し — 5-7 の繰り返しタイマで 1 kHz に固定して press_top を回す
#include "pico/stdlib.h"
#include "Vpress_top.h"

constexpr uint PIN_BTN    = 0;     // GP0: SW1。中のプルアップ、押すと L
constexpr uint PIN_LONG   = 14;    // GP14: D2 (黄)
constexpr uint PIN_SHORT  = 15;    // GP15: D1 (緑)
constexpr uint PIN_REPEAT = 16;    // GP16: D3 (赤)
constexpr int64_t HALF_US = 500;   // 半周期 500 µs → クロック 1 kHz

static VerilatedContext ctx;
static Vpress_top top{&ctx};
static unsigned g_clk = 0;

static bool on_half(repeating_timer_t*) {
    g_clk ^= 1u;
    if (g_clk) top.btn_n = gpio_get(PIN_BTN);   // 立ち上がりの前に 1 回だけ読む
    top.clk = g_clk;
    top.eval();
    gpio_put(PIN_SHORT,  top.led_short);
    gpio_put(PIN_LONG,   top.led_long);
    gpio_put(PIN_REPEAT, top.led_repeat);
    return true;                                // 次も呼ぶ
}

int main() {
    gpio_init(PIN_BTN);
    gpio_set_dir(PIN_BTN, GPIO_IN);
    gpio_pull_up(PIN_BTN);
    for (uint p : {PIN_SHORT, PIN_LONG, PIN_REPEAT}) {
        gpio_init(p);
        gpio_set_dir(p, GPIO_OUT);
    }

    // リセットを 2 クロック掛ける
    top.btn_n = 1;
    top.rst = 1;
    for (int i = 0; i < 2; i++) {
        top.clk = 0; top.eval();
        top.clk = 1; top.eval();
    }
    top.rst = 0;

    repeating_timer_t timer;
    add_repeating_timer_us(-HALF_US, on_half, nullptr, &timer);   // 負の周期: 呼び始めの間隔 (5-7)
    while (true) tight_loop_contents();
}
```

- ボタンは立ち上がりの半周期の頭で 1 回だけ読む。1 kHz なので 1 ms に 1 回。6-3 と同じく、1 ms より短い跳ねは読まれないこともある
- 割り込みの中は `gpio_get`・`eval()`・`gpio_put` だけ。主ループは何もしない

ビルドは 5-1 の手順と同じ。作業用のフォルダに `press66.cpp` と 4 つの `.v` (6-6 の `press_fsm.v`・`pulse_stretch.v`・`press_top.v` と 6-3 の `debounce.v`。どれも本文のコードブロックを写す)、5-1 の `CMakeLists.txt`・`pico_tls.cpp`・
`stub_mutex.h`・`cxx_minimal.cpp`・`verilated.cpp` を置き、`CMakeLists.txt` の最後の行と `verilate.sh` を次に替える。

```cmake
add_soft_fpga(press66 press66.cpp press_top)
```

`verilate.sh`:

```bash
#!/bin/sh
# Verilog を C++ にする (sfa-dev のコンテナの中で打つ)
set -e
rm -rf vlinc && cp -r /usr/local/share/verilator/include vlinc
verilator --cc --no-timing --no-trace -Wall --prefix Vpress_top --top-module press_top --Mdir v_press_top \
  press_top.v press_fsm.v pulse_stretch.v debounce.v
```

打つのは 5-1 の「ビルドする」の 2 行 (`sfa-dev:local` で `sh verilate.sh`、`wb-pico-sdk` で `cmake`)。
空のフォルダから作ってビルドし、`build/press66.uf2` (95 744 バイト) ができた。`press66.cpp` に警告は出なかった。**実機では動かしていない。**

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Logic | DIO3 (ボタン)・DIO0 (D1、短押し)・DIO1 (D2、長押し)・DIO2 (D3、繰り返し) を Enable。DIO は 3.3 V。GND を共通にする (0-4) |
| 時間軸 | 400 ms/div (10 目盛で 4 s)。標本化 5 kS/s (4 s で 2 万標本。AD3 の 1 本 32 768 標本に入る) |
| トリガ | DIO3 の立ち下がり (短押しの押し始め)。トリガの前を 0.2 s 見せる |

一番速い変化は LED の 100 ms で、5 kS/s はその 500 倍。ボタンの跳ね (数 ms) も 0.2 ms ごとに読めるが、
400 ms/div では 1 目盛の 1/100 より細かく、画面では線 1 本に潰れる。跳ねを見たいときは 6-3 の 5 ms/div にする。

## Logic に見えるはずの画面

6-6 のシミュレーションの 1 と 2 (短押し 300 ms と長押し 2.5 s) の時刻を写した。ボタンの跳ねはこの時間軸では見えないので描いていない
(押した・離した時刻だけを描いた)。LED の時刻はシミュレーションの値。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 短押しは離した所で D1、長押しは 1 s で D2、その後は 0.2 s ごとに D3
device: ad3
time: 400ms/div
start: -200ms
sample: 5kHz
signals:
  BTN: dio3 edges -1s=1 0s=0 300ms=1 800ms=0 3300ms=1
  SHT: dio0 edges 0s=0 322.5ms=1 422.5ms=0
  LNG: dio1 edges 0s=0 1825.5ms=1 1925.5ms=0
  RPT: dio2 edges 0s=0 2025.5ms=1 2125.5ms=0 2225.5ms=1 2325.5ms=0 2425.5ms=1 2525.5ms=0 2625.5ms=1 2725.5ms=0 2825.5ms=1 2925.5ms=0 3025.5ms=1 3125.5ms=0 3225.5ms=1 3325.5ms=0
cursors: [2075.5ms, 2275.5ms]
trigger: BTN falling at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/06-state-machines/logic/18-long-short-press-pico.svg)

- 短押し (0〜300 ms): 離した 300 ms の 22.5 ms 後に SHT が 100 ms 点く。押している間は何も出ない
- 長押し (800 ms〜): 押してから 1025.5 ms 後 (1825.5 ms) に LNG が 100 ms 点く。その 200 ms 後から RPT が 0.2 s ごとに 7 回点く。離した 3300 ms の後と、離した所には何も出ない
- X1 (2075.5 ms) と X2 (2275.5 ms) は、1 回目と 2 回目の RPT の真ん中。ΔX = 200 ms、1/ΔX = 5 Hz が `REPEAT_MS = 200` の間隔

## 見るべき値

シミュレーションの値と設計値。実機では測っていない。実機では、Logic でボタンの押し始め・離した所と 3 本の LED の立ち上がりの時刻を読み、表に書き加える。出来事の数 (短押し・長押し・繰り返し・ひげ) は 6-6 の「見るべき値」。

| 見る所 | シミュレーション・設計値 | 実機 (測って書く) |
| --- | --- | --- |
| 離してから D1 が点くまで (短押し) | 22.5 ms (跳ねた押し方。最後の跳ねから 21.1 ms) | |
| 押してから D2 が点くまで (長押し) | 1025.5 ms (跳ねた押し方)、1022.5 ms (跳ねない押し方) | |
| D3 の間隔 (図3 の ΔX) | 200 ms (設計値 `REPEAT_MS`。1/ΔX = 5 Hz) | |
| LED が点いている長さ | 100 ms (設計値 `SHOW_MS`) | |
| LED 1 個の電流 | 約 3.9 mA (計算値) | |

実機の時間は、5-7 で固定したクロックの正確さで決まる。1 クロックが 1.000 ms からずれれば、1 s も 0.2 s も同じ割合でずれる。

## シミュレーションでの確かめ (対象外を含む)

`.uf2` は、本文の Docker イメージ (`sfa-dev:local` の Verilator 5.048 と `wb-pico-sdk` の Pico SDK 2.2.0、`arm-none-eabi-gcc` 13.2.1) でビルドし直した。
`verilate.sh` の `-Wall` は 5.048 でも止まらなかった。状態機械の振る舞いの確かめは 6-6。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| `.uf2` の大きさ | 95 744 バイト | 95 744 バイト (text 51 504・bss 2 840) | 合った |
| `.cpp` のコンパイル | 警告なし | エラーなしでリンクまで通った (警告の有無は見ていない) | 通った |

### エミュレータ (picoemu) での確かめ

picoemu (`danish9661/pico-emulator` の `b83786f` に `sim/picoemu-m33.patch` を当てた版。手順は [5-2](../05-soft-fpga-pico/02-counter-led.md#エミュレータ-picoemu-での確かめ)) に `press66.uf2` (本文の `press66.cpp` を 5-7 の方法で 1 kHz にした物) を載せ、Cortex-M33 で動かした。入力は `-script` で与えた (ms 刻み)。
確かめは `python3 sim/picoemu-check.py --picoemu ./picoemu --uf2 <.uf2 を集めたフォルダ> 6-18`。picoemu は機能の模型で、周期・ジッタ・周波数の実時間は対象外にした。

| 項目 | 本文の数字 | picoemu の結果 | 判定 |
| --- | --- | --- | --- |
| 5 つの押し方の出来事の数 (跳ねは ms 刻みで与えた) | 短押し 300 ms: 1・0・0、長押し 2.5 s: 0・1・7、0.9 s: 1・0・0、1.1 s: 0・1・0、ひげ 5 ms: 0・0・0 (short・long・repeat) | 5 つとも同じ | 合った |
| `repeat` の間隔 | 200 ms | 7 回とも 200.0 ms | 合った |
| 離してから D1 まで | 22.5 ms (跳ねた押し方) | 22.8 ms (跳ねを ms 刻みで入れたため 0.3 ms の差) | 合った |
| 押してから D2 まで (跳ねない押し方) | 1022.5 ms | 1022.8 ms | 合った |
| LED が点いている長さ | 100 ms | 100.0 ms | 合った |

確かめられなかったもの。

- Pico 2 への書き込み、AD3 での測定、実機の 1 クロックの正確さ

## 出典

自作。状態機械は 6-6、チャタリング取りの `debounce.v` は 6-3、クロックを 1 kHz に固定する方法は 5-7、
Pico 2 のビルドは 5-1 (Soft-FPGA-Reversi の `stub_mutex.h`・`cxx_minimal.cpp`・`verilated.cpp`、コミット `5be3b16`)。
Pico 2 で Verilog を動かす形は [tommie-jp/Soft-FPGA-TD4](https://github.com/tommie-jp/Soft-FPGA-TD4) の `verilator-TD4/main.cpp`。
