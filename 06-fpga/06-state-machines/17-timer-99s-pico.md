---
book: fpga
chapter: 6
id: 6-17
title: 99 秒タイマーを Pico 2 で動かす — Soft-FPGA の主ループとクロックの固定
tier: 100
source: 自作
board: BB
device: PICO
---

# 6-17 99 秒タイマーを Pico 2 で動かす — Soft-FPGA の主ループとクロックの固定

> [!WARNING]
> **この題は実機で組んでいない。**
> Pico 2 のプログラムは `.uf2` までのビルドを確かめたが、書き込んで動かしてはいない。7 セグの点灯、ブザーの音、AD3 での測定はしていない。
> 「見るべき値」は設計値・シミュレーションの値で、測った値ではない。

[6-7](07-timer-99s.md) で設計して PC のシミュレーションで確かめた 99 秒タイマー `timer99` を、Pico 2 の Soft-FPGA に載せて動かす。
クロックは 5-7 の繰り返しタイマで **1 kHz (1 クロック = 1 ms)** に固定する。動かしたら AD3 の Logic で 1 秒とブザーの音を測る。

## 回路図・実体配線図

回路と部品は [6-19](19-timer-99s-wiring.md) のとおり (6-19 の図1 が回路図、図2 が実体配線図、部品は 6-19 の「部品」の表)。前の題と同じ回路なので、ここには再び載せない。
AD3 は 6-19 の図2 のとおり DIO0 で `SEC` (GP14)、DIO1 で `BZ` (GP15)、DIO2 で `SS` (GP1) を読む。

## Pico 2 のプログラム

組み方は 5-1 (ビルドの道具) と 5-7 (繰り返しタイマで 1 kHz に固定する)。作業用の空のフォルダに、[6-7](07-timer-99s.md#verilog) の `timer99.v`・`key_repeat.v`・`seg7dec.v` と [6-3](03-debounce.md) の `debounce.v` (どちらも本文のコードブロックを写す) と、次のファイルを置く。

| ファイル | 中身 | どこから |
| --- | --- | --- |
| `main.cpp` | 主ループとピンの割り当て | 下に載せる |
| `verilate.sh` | Verilog を C++ にする手順 | 下に載せる |
| `CMakeLists.txt` | ビルドの設定 | 5-1 のもの。最後の行を下の 1 行に替える |
| `pico_tls.cpp` `stub_mutex.h` `cxx_minimal.cpp` `verilated.cpp` | Pico 2 で Verilator の C++ を動かす部品 | 5-1 と同じ |

`main.cpp`:

```cpp
// 6-7 99 秒タイマー — timer99.v を繰り返しタイマの割り込みで 1 kHz で回す (5-7)
#include "pico/stdlib.h"
#include "Vtimer99.h"

constexpr int64_t HALF_US = 500;              // 半周期 500 µs → クロック 1 kHz

constexpr uint PIN_PLUS = 0;                  // 「+」(押すと 0)
constexpr uint PIN_SS   = 1;                  // 「スタート/ストップ」(押すと 0)
constexpr uint PIN_SEC  = 14;                 // 1 秒の印 (AD3 の DIO0)
constexpr uint PIN_BZ   = 15;                 // 圧電サウンダ (AD3 の DIO1)
//                              a   b   c   d   e   f   g
constexpr uint PIN_TENS[7] = {  4,  5, 18, 17, 16,  3,  2 };   // 10 の位 (DS1)
constexpr uint PIN_ONES[7] = {  8,  9, 21, 20, 19,  7,  6 };   // 1 の位 (DS2)

static VerilatedContext ctx;
static Vtimer99 top{&ctx};
static unsigned g_clk = 0;

static void out_init(uint pin) {
    gpio_init(pin);
    gpio_set_dir(pin, GPIO_OUT);
    gpio_put(pin, 0);
}

static void in_init(uint pin) {
    gpio_init(pin);
    gpio_set_dir(pin, GPIO_IN);
    gpio_pull_up(pin);                        // 外に抵抗を付けない (6-2)
}

static void put_outputs() {
    for (int i = 0; i < 7; i++) {
        gpio_put(PIN_TENS[i], (top.seg_tens >> i) & 1u);
        gpio_put(PIN_ONES[i], (top.seg_ones >> i) & 1u);
    }
    gpio_put(PIN_SEC, top.sec);
    gpio_put(PIN_BZ, top.buzzer);
}

static bool on_half(repeating_timer_t*) {
    g_clk ^= 1u;                              // 立ち上がりと立ち下がりを交互に
    if (g_clk) {                              // 立ち上がりの前にボタンを読む
        top.btn_plus_n = gpio_get(PIN_PLUS);
        top.btn_ss_n   = gpio_get(PIN_SS);
    }
    top.clk = g_clk;
    top.eval();
    put_outputs();
    return true;                              // 次も呼ぶ
}

int main() {
    for (int i = 0; i < 7; i++) { out_init(PIN_TENS[i]); out_init(PIN_ONES[i]); }
    out_init(PIN_SEC);
    out_init(PIN_BZ);
    in_init(PIN_PLUS);
    in_init(PIN_SS);

    // リセットを 2 クロック掛ける
    top.btn_plus_n = 1;
    top.btn_ss_n   = 1;
    top.rst = 1;
    for (int i = 0; i < 2; i++) {
        top.clk = 0; top.eval();
        top.clk = 1; top.eval();
    }
    top.rst = 0;
    top.clk = 0; top.eval();

    repeating_timer_t timer;
    // 負の周期は「呼び始めから次の呼び始めまで」。計算の長さで周期がずれない
    add_repeating_timer_us(-HALF_US, on_half, nullptr, &timer);

    while (true)
        tight_loop_contents();
}
```

- 500 µs ごとの割り込みで `clk` を 0 と 1 に交互に変えて `eval()` する (5-7)。クロックは 1 kHz で、`timer99` の 1 秒は 1000 回の立ち上がり
- ボタンは立ち上がりの前に読む。1 ms に 1 回しか読まないが、`debounce` が 20 ms 続いたかを見るので足りる (6-3)
- セグメントは `seg_tens` と `seg_ones` のビット 0〜6 (a〜g) を、表の GPIO に 1 本ずつ出す

| Verilog | Pico 2 | 向き | 設定 |
| --- | --- | --- | --- |
| `clk` | (ピンなし) | — | 500 µs ごとのタイマ割り込みで 0 と 1 を交互に入れて評価する (5-7)。1 kHz |
| `rst` | (ピンなし) | — | 起動して最初の 2 クロックだけ 1 |
| `btn_plus_n` | GP0 | 入力 | 中のプルアップを有効に。SW1 |
| `btn_ss_n` | GP1 | 入力 | 中のプルアップを有効に。SW2 |
| `seg_tens[0]`〜`[6]` (a〜g) | GP4・GP5・GP18・GP17・GP16・GP3・GP2 | 出力 | DS1 (10 の位) |
| `seg_ones[0]`〜`[6]` (a〜g) | GP8・GP9・GP21・GP20・GP19・GP7・GP6 | 出力 | DS2 (1 の位) |
| `sec` | GP14 | 出力 | AD3 の DIO0 |
| `buzzer` | GP15 | 出力 | BZ1 と AD3 の DIO1 |
| `o_state` `o_count` | (ピンなし) | — | 使わない |

セグメントの並びが飛び飛びなのは、ブレッドボードで Pico 2 の上の列と下の列から 7 セグの下のピンと上のピンへ、線を交差させずに運ぶため (6-19 の図2)。

`verilate.sh` (`sfa-dev:local` の中で打つ):

```bash
#!/bin/sh
# Verilog を C++ にする (sfa-dev のコンテナの中で打つ)
set -e
rm -rf vlinc && cp -r /usr/local/share/verilator/include vlinc
verilator --cc --no-timing --no-trace -Wall --prefix Vtimer99 --top-module timer99 --Mdir v_timer99 \
  timer99.v debounce.v key_repeat.v seg7dec.v
```

`CMakeLists.txt` の最後の行:

```cmake
add_soft_fpga(timer99_pico main.cpp timer99)
```

ビルドは 5-1 の「ビルドする」の 2 行と同じ。空のフォルダから打って、次のとおりになった。**実機では動かしていない。**

| 確かめること | 出た物 |
| --- | --- |
| C++ への変換と lint (`sh verilate.sh`) | 警告なし。Verilation Report に `Verilator 5.048` |
| ビルド (`cmake --build build`) | エラーなし。`main.cpp` からの警告なし |
| `.uf2` の大きさ | `build/timer99_pico.uf2` が 97 280 バイト |
| プログラムの大きさ (`arm-none-eabi-size`) | text 52 456 バイト、bss 2 840 バイト |

## 計器の設定

計器は AD3 の Logic。見たいのは 0 / 1 の並びと時刻で、電圧の形ではないので Logic にした。

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 (`SEC`)・DIO1 (`BZ`)・DIO2 (`SS`) を Enable。DIO は 3.3 V。GND を共通にする (0-4) |
| 1 秒を見る (図1) | 時間軸 1 s/div (10 目盛で 10 s)。標本化 1 kS/s (10 s で 1 万標本。AD3 の 1 本 32 768 標本に入る)。トリガは DIO2 の立ち下がり (スタートを押した所)。トリガの前を 1 s 見せる |
| ブザーの音を見る (図2) | 時間軸 1 ms/div (10 目盛で 10 ms)。標本化 100 kS/s。トリガは DIO1 の立ち上がり。トリガの前を 3 ms 見せる |

一番速い変化は、図1 ではボタンを押していた 0.1 s、図2 では 1 ms ごとの反転。標本化はどちらもその 4 倍より十分速い。

## Logic に見えるはずの画面

シミュレーションの時刻をそのまま写した。図1 は残りを 10 s 以上にして、ボタンは跳ねずに 0.1 s 押したとした。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図1 押して 22.5 ms で数え始め、SEC は 1 s ごとに 0.5 s だけ 1
device: ad3
time: 1s/div
start: -1s
sample: 1kHz
signals:
  SEC: dio0 edges -1s=0 22.5ms=1 522.5ms=0 1022.5ms=1 1522.5ms=0 2022.5ms=1 2522.5ms=0 3022.5ms=1 3522.5ms=0 4022.5ms=1 4522.5ms=0 5022.5ms=1 5522.5ms=0 6022.5ms=1 6522.5ms=0 7022.5ms=1 7522.5ms=0 8022.5ms=1 8522.5ms=0
  SS: dio2 edges -1s=1 0s=0 100ms=1
cursors: [272.5ms, 1272.5ms]
trigger: SS falling at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/06-state-machines/logic/17-timer-99s-pico-1.svg)

- X1 (272.5 ms) と X2 (1.2725 s) は、1 秒目と 2 秒目の `SEC` の 1 の真ん中。ΔX は 1.000 s、1/ΔX は 1.000 Hz
- `SEC` はスタートを押してから 22.5 ms で 1 になり、以後 1 s ごとに 0.5 s だけ 1。表示はこの立ち上がりの 1 s 後ごとに 1 減る
- 実機の 1 s は、5-7 で固定したクロックの正確さで決まる。1 クロックが 1.000 ms からずれれば、1 s も同じ割合でずれる

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図2 0 になると BZ が 1 ms ごとに反転する。周期 2 ms = 500 Hz
device: ad3
time: 1ms/div
start: -3ms
sample: 100kHz
signals:
  SEC: dio0 low
  BZ: dio1 pattern 0001010101 bit 1ms from -3ms
cursors: [500us, 2.5ms]
trigger: BZ rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/06-state-machines/logic/17-timer-99s-pico-2.svg)

- t = 0 は `BZ` の最初の立ち上がり。`RING` に入ったのはその 1 ms 前 (`01` が `00` になったクロック) で、`SEC` は `RUN` の最後の秒の後半なので 0 のまま
- X1 (0.5 ms) と X2 (2.5 ms) は、続く 2 つの 1 の真ん中。ΔX は 2.000 ms、1/ΔX は 500.0 Hz
- `BZ` はこのあと 0.5 s 鳴り、0.5 s 休む。1 s/div で見ると 1 ms ごとの反転は細かすぎて塗りになるので、鳴る区間と休む区間は図にせず表に書いた

## 見るべき値

設計値・シミュレーションの値。実機では測っていない。実機では Logic で次の値を読み、表に書き加える。ほかの値は、長押し・99 での頭打ちが 6-7、電流が 6-19 の「見るべき値」。

| 見る所 | 設計値・シミュレーション | どこで得たか | 実機 (測って書く) |
| --- | --- | --- | --- |
| `SEC` の周期 | 1.000 s (1000 クロック)、1 の間は 0.5 s | 6-7 の試験・図1 | |
| スタートを押してから数え始めるまで | 22.5 ms (跳ねずに押したとき) | 6-7 の短い試験・図1 | |
| ブザーの方形波 | 500 Hz (周期 2 ms、1 ms ごとに反転) | 6-7 の試験・図2 | |
| 鳴る区間と休む区間 | 0.5 s ずつ (1 s に 250 周期) | 6-7 の試験 | |

## シミュレーションでの確かめ (対象外を含む)

`.uf2` は、本文の Docker イメージ (`sfa-dev:local` の Verilator 5.048 と `wb-pico-sdk`) で 6-6 と同じ手順でビルドし直した。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| `.uf2` の大きさ | 97 280 バイト | 97 280 バイト | 合った |
| プログラムの大きさ | text 52 456・bss 2 840 バイト | text 52 456・bss 2 840 バイト | 合った |

### エミュレータ (picoemu) での確かめ

picoemu (`danish9661/pico-emulator` の `b83786f` に `sim/picoemu-m33.patch` を当てた版。手順は [5-2](../05-soft-fpga-pico/02-counter-led.md#エミュレータ-picoemu-での確かめ)) に `timer99_pico.uf2` を載せ、Cortex-M33 で動かした。入力は `-script` で与えた (ms 刻み)。
確かめは `python3 sim/picoemu-check.py --picoemu ./picoemu --uf2 <.uf2 を集めたフォルダ> 6-17`。picoemu は機能の模型で、周期・ジッタ・周波数の実時間は対象外にした。

| 項目 | 本文の数字 | picoemu の結果 | 判定 |
| --- | --- | --- | --- |
| 設定の状態の表示 | スタートは 00 では無視。「+」3 回で 03、2 s 押し続けて 20 | 00・03・20 | 合った |
| 走る間 | 5.5 s で 15、止めると 15 のまま、3 s 後も 15 | 15・15・15 | 合った |
| `SEC` の周期、H の幅 | 1000 ms、500 ms | 1000 ms、500 ms (止めた間の 3.68 s を除く) | 合った |
| `RING` に入る時刻とブザー | `RING` は 26 394 ms、ブザーの最初の立ち上がりは 1 ms 後 | ブザーの最初の立ち上がりが 26 395 ms。表示は 15 s 後に 00 | 合った |
| ブザー | 1 s に 250 回の立ち上がり、周期 2 ms、鳴る 0.5 s と休む 0.5 s | 250 回、2.0 ms、50 回/100 ms が 5 区間 → 休み 5 区間 | 合った |
| 30 s で `SET` に戻る・99 での頭打ち | 試験のとおり | この確かめでは 56 s まで (ブザーの最後が 55.9 s)。99 での頭打ちは回していない | 確かめなかった |

確かめられなかったもの。

- Pico 2 への書き込み、7 セグの点灯、ブザーの音、AD3 での測定

## 出典

自作。

- Pico 2 で Verilog を動かす形は [tommie-jp/Soft-FPGA-TD4](https://github.com/tommie-jp/Soft-FPGA-TD4) の `verilator-TD4/main.cpp`、ビルドの手は
  [tommie-jp/Soft-FPGA-Reversi](https://github.com/tommie-jp/Soft-FPGA-Reversi) (5-1)
- 繰り返しタイマは Raspberry Pi の Pico SDK の `pico_time` (`add_repeating_timer_us`、5-7)
