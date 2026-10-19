---
book: fpga
chapter: 5
id: 5-11
title: 精密なクロック — PWM のハードウェアで刻み、その割り込みで回す
tier: 100
source: 自作
board: BB
device: PICO
---

# 5-11 精密なクロック — PWM のハードウェアで刻み、その割り込みで回す

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 のプログラムは `.uf2` までのビルドを確かめたが、書き込んで動かしてはいない。
> 表の周波数と PWM の設定値は、システムクロック 150 MHz から**計算した設計値**。周期のばらつきは測っていない。「見るべき値」の空欄は、測って書き込む。

5-7 のタイマ割り込みは、割り込みの中で CLK のピンを動かしていた。割り込みに入るまでの遅れがあると、端の時刻がその分ずれる (5-10)。

この題では、**端を作る仕事をハードウェアに任せる**。Pico 2 の PWM (パルス幅を変えて出す回路) は、水晶から作ったシステムクロックを数える
カウンタを持ち、数え終わるたびにピンの値を決まった時刻で替える。端の時刻に、ソフトの遅れが乗らない。
ソフトの仕事は、**カウンタが 1 周するたびに入る割り込みで `eval()` を呼ぶこと**だけになる。

| 比べる点 | 5-7 のタイマ割り込み | この題の PWM |
| --- | --- | --- |
| CLK の端を作る所 | 割り込みの中のソフト (`gpio_put`) | PWM のハードウェア |
| 端の時刻を決めるもの | タイマの時刻 + 割り込みに入るまでの遅れ | カウンタの値だけ |
| 割り込みの役 | 端を出す + `eval()` を呼ぶ | `eval()` を呼ぶだけ |
| 周波数の選べ方 | 半周期をマイクロ秒で (1 µs の刻み) | システムクロックの整数分の 1 (割り切れる値だけ) |

## PWM で CLK を作る

PWM のスライスは、次の 3 つの数で周波数を決める。

```text
クロックの周波数 = システムクロック ÷ (div × (wrap + 1))
H の幅           = level ÷ (wrap + 1)  (カウンタが level より小さい間が H)
```

- `div` は 1 から 255 の整数 (整数の分周)。`wrap` は 16 ビットで、最大 65 535
- 50 % のデューティ (H と L を同じ長さ) にするには、`level` を `(wrap + 1) ÷ 2` にする
- GP16 は PWM のスライス 0 のチャンネル A につながる。カウンタが 1 周 (`wrap` から 0 へ戻る) するたびに割り込みが入る。そのとき CLK は H に立ち上がる所

システムクロックは Pico SDK の既定の **150 MHz** (12 MHz の水晶から PLL で作る)。プログラムは `clock_get_hz(clk_sys)` で実際の値を読み、
`sys ÷ (div × freq)` が**割り切れて** 65 536 以下になる `div` を 1 から探す。割り切れない周波数は選ばせない
(割り切れないと、選んだ周波数と実際の周波数が ppm の桁でずれる)。150 MHz のときに見つかる値 (計算値):

| 周波数 | 周期 | div | wrap | level |
| --- | --- | --- | --- | --- |
| 10 Hz | 100 ms | 240 | 62 499 | 31 250 |
| 20 Hz | 50 ms | 120 | 62 499 | 31 250 |
| 50 Hz | 20 ms | 48 | 62 499 | 31 250 |
| 100 Hz | 10 ms | 24 | 62 499 | 31 250 |
| 200 Hz | 5 ms | 12 | 62 499 | 31 250 |
| 500 Hz | 2 ms | 5 | 59 999 | 30 000 |
| 1 kHz | 1 ms | 3 | 49 999 | 25 000 |
| 2 kHz | 500 µs | 2 | 37 499 | 18 750 |

どれも割り切れる (誤差は 0)。1 kHz は 150 000 000 ÷ (3 × 50 000) = 1000 で、5-7 と同じ周波数になる。

選べる最も低い周波数は、`div = 255`、`wrap = 65 535` のとき 150 MHz ÷ (255 × 65 536) ≒ 8.98 Hz (計算値)。
**1 Hz は PWM だけでは出せない。** 1 Hz は、1 kHz で回して Verilog の中で数える (5-12)。

## 1 クロックの回し方

PWM の周期が 1 クロック (CLK の 1 周期) になる。割り込みの中で、立ち上がりと立ち下がりの `eval()` を続けて 2 回呼ぶ。

| 決め | 内容 |
| --- | --- |
| クロックの周波数 | SW1〜SW3 の 3 ビット (SW1 が上の桁、ON = 1) で上の表の 8 つから選ぶ。0 が 10 Hz、7 が 2 kHz |
| 回路 | SW4 OFF: 2-4 の `counter8`。SW4 ON: 2-7 の `blink` (`CLK_HZ = 1000`) |
| CLK のピン (GP16) | PWM のハードウェアが出す。50 % のデューティ |
| BUSY のピン (GP17、AUX) | 割り込みの中で `eval()` を計算している間だけ H |
| LED (GP2〜GP5) と GP18〜GP21 | `counter8` なら `count[7:4]`、`blink` なら `led` (5-6 と同じ) |

**注意:** CLK の端は精密になるが、**回路の出力 (LED) が変わる時刻は、割り込みに入るまでの遅れと計算の時間の分だけ CLK の端より後**になる。
同じ CLK の周期でも、LED の変わる時刻にはばらつきが残る (見込み)。CLK と LED の両方を Logic で見比べると、遅れが見える。
この遅れは、実物の FPGA の出力 (CLK の端と同時) との違いとして、8-7 で再び出てくる。

## 回路図

図1・図2 は 5-5 と同じ。DIP スイッチは、この題では起動時に周波数と回路を選ぶのに使う。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/11-clock-pwm.svg)

- 配線は 5-5 と同じ。AD3 は GP16 (CLK)・GP17 (BUSY)・GP18〜GP21 (LED と同じ値) を読む
- DIP スイッチは起動時に 1 度だけ読む。替えたら、USB をつなぎ直す (または RUN を一瞬 GND につなぐ)

## 実体配線図

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/breadboard/11-clock-pwm.svg)

- 配線は 5-5 と同じ。AD3 は DIO0 (CLK、白)・DIO1 (BUSY、橙)・DIO2 (緑、LED の最下位の写し) を読む
- DIP スイッチは下の列の左から 4・3・2・1。**右端が SW1**

## 部品表

5-5 と同じ (Pico 2、330 Ω (オーム) の抵抗 4 本、赤の LED 4 個、4 連の DIP スイッチ、full のブレッドボード、AD3)。電源は 3.3 V (Pico 2 の GPIO)。
5 V を入れないのは 0-3 と同じ理由。

## Pico 2 のプログラム

作業用のフォルダは 5-5 と共通で、`board.h` は 5-5 のまま。ビルドの打ち方は [5-1 の「ビルドする」](01-verilator-on-pico.md#ビルドする)。
PWM のライブラリ (`hardware_pwm`) をリンクに足す。

`clock511.cpp`:

```cpp
// 5-11 精密なクロック — PWM の 1 周期ごとの割り込みで 1 クロックを回す
// 5-12 でも同じプログラムを使う (SW4 を ON にして 1 kHz の blink を回す)
#include "board.h"
#include "hardware/pwm.h"
#include "hardware/clocks.h"
#include "hardware/irq.h"
#include "Vcounter8.h"
#include "Vblink.h"

// SW1〜SW3 の 3 ビット (SW1 が上の桁) でクロックの周波数 (Hz) を選ぶ
constexpr uint32_t FREQ_HZ[8] = {10, 20, 50, 100, 200, 500, 1000, 2000};

static Vcounter8 c8;
static Vblink    blk;
static bool      g_use_blink = false;
static uint      g_slice = 0;

static void on_wrap() {
    pwm_clear_irq(g_slice);
    gpio_put(PIN_AUX, 1);                       // BUSY: 計算している間だけ H
    if (g_use_blink) {
        blk.clk = 1; blk.eval();
        blk.clk = 0; blk.eval();
        put_leds(blk.led);
    } else {
        c8.clk = 1; c8.eval();
        c8.clk = 0; c8.eval();
        put_leds(c8.count >> 4);
    }
    gpio_put(PIN_AUX, 0);
}

// sys_hz ÷ (div × freq) が割り切れて 65536 以下になる整数の div (1〜255) を探す
static bool find_div(uint32_t sys_hz, uint32_t freq, uint32_t* div, uint32_t* top) {
    for (uint32_t d = 1; d <= 255; d++) {
        const uint64_t denom = (uint64_t)d * freq;
        if (sys_hz % denom != 0) continue;
        const uint64_t period = sys_hz / denom;     // PWM の 1 周期のカウント数
        if (period < 2 || period > 65536) continue;
        *div = d;
        *top = (uint32_t)(period - 1);
        return true;
    }
    return false;
}

int main() {
    board_init();
    c8.rst = 1; blk.rst = 1;
    c8.clk = 0; c8.eval(); c8.clk = 1; c8.eval(); c8.clk = 0; c8.eval();
    blk.clk = 0; blk.eval(); blk.clk = 1; blk.eval(); blk.clk = 0; blk.eval();
    c8.rst = 0; blk.rst = 0;

    const unsigned sw = read_sw();
    g_use_blink = (sw & 0x1u) != 0;                 // SW4 ON: 2-7 の blink (CLK_HZ = 1000)
    const uint32_t freq = FREQ_HZ[(sw >> 1) & 0x7u];

    const uint32_t sys_hz = clock_get_hz(clk_sys);
    uint32_t div = 0, top = 0;
    if (!find_div(sys_hz, freq, &div, &top)) {      // 割り切れない周波数は選ばせない
        put_leds(0xF);
        while (true) tight_loop_contents();
    }

    // CLK のピンは PWM のハードウェアが出す。1 周期の頭 (H の始まり) で割り込みが入る
    gpio_set_function(PIN_CLK, GPIO_FUNC_PWM);
    g_slice = pwm_gpio_to_slice_num(PIN_CLK);
    pwm_config cfg = pwm_get_default_config();
    pwm_config_set_clkdiv_int(&cfg, div);
    pwm_config_set_wrap(&cfg, top);
    pwm_init(g_slice, &cfg, false);
    pwm_set_chan_level(g_slice, pwm_gpio_to_channel(PIN_CLK), (top + 1) / 2);   // 50 %
    pwm_clear_irq(g_slice);
    pwm_set_irq_enabled(g_slice, true);
    irq_set_exclusive_handler(PWM_DEFAULT_IRQ_NUM(), on_wrap);
    irq_set_enabled(PWM_DEFAULT_IRQ_NUM(), true);
    pwm_set_enabled(g_slice, true);

    while (true) tight_loop_contents();
}
```

- `find_div()` が、システムクロックを割り切れる `div` を探す。見つからない周波数 (表の外の値) は、LED を全部点けて止まる
- PWM の割り込みは、カウンタが 1 周するたびに 1 回。割り込みの中では、`eval()` を立ち上がり・立ち下がりの順に 2 回呼ぶ。CLK のピンには触らない
- BUSY は割り込みに入ったところで H、`eval()` が終わったところで L に戻す。5-7 と同じ意味
- PWM の割り込みの番号は、`PWM_DEFAULT_IRQ_NUM()` で取る (Pico 2 は `PWM_IRQ_WRAP_0`)

`CMakeLists.txt` の最後に次の 2 行を足す。

```cmake
add_soft_fpga(clock511 clock511.cpp counter8 blink)
target_link_libraries(clock511 hardware_pwm)   # PWM のハードウェアを使う
```

空のフォルダから 5-1 の手順でビルドし、`build/clock511.uf2` (96 256 バイト) ができた (Verilator 5.048、Pico SDK 2.2.0)。
`arm-none-eabi-size` は text 51 920 バイト、bss 2 520 バイト。**実機では動かしていない。**

## 計器の設定

計器は AD3 の Logic。

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 (CLK)・DIO1 (BUSY)・DIO2 (LED の写し) を Enable。標本化 1 MHz (100 Hz のとき窓は約 33 ms) |
| Logic のトリガ | DIO0 の立ち上がり |
| 時間軸 | CLK が 2 周期入るように合わせる。図3 は 100 Hz (SW2・SW3 が ON) で 2 ms/div |
| カーソル | X1 と X2 を、続く 2 つの H の真ん中に置く。ΔX が周期 |
| ばらつき | 5-10 と同じ。`jitter.py` に渡して、最小・最大・平均・標準偏差を出す |

## Logic に見えるはずの画面

図3 は、100 Hz (SW1 OFF、SW2・SW3 ON) で動かしたときの CLK。周期は設計値 (150 MHz ÷ (24 × 62 500) = 100 Hz)。
**BUSY の幅と LED の遅れは測っていないので描いていない。**

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 PWM の 100 Hz の CLK は周期 10 ms
device: ad3
time: 2ms/div
start: -2ms
sample: 1MHz
signals:
  CLK: dio0 clock 100Hz
cursors: [2.5ms, 12.5ms]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/11-clock-pwm.svg)

- カーソルは H の真ん中。間隔は 10 ms で、CLK の 1 周期
- 実機で BUSY (DIO1) を足すと、CLK の立ち上がりから少し遅れて H になり、`eval()` の間だけ続く。この遅れが、割り込みに入るまでの時間

## 見るべき値

**測っていない。測って空欄を埋める。** 数を決め打たないのは、この冊の決め (1 クロックの時間は実測してから書く)。

| 測る所 | 見るべき値 | 分かること |
| --- | --- | --- |
| CLK の周期 (SW を 011 にして 100 Hz) | 10.000 ms (設計値) | PWM が周波数を決めている |
| CLK の周期 (SW を 110 にして 1 kHz) | 1.000 ms (設計値) | 5-7 と同じ周波数 |
| 周期のばらつき (最大 − 最小) | (測って書く) µs | 5-10 の主ループ・タイマ割り込みと並べる。ソフトの遅れが乗らないぶん、小さくなる見込み |
| 周期の平均の、設計値からのずれ | (測って書く) ppm | 水晶の精度。測り方と読み方は 5-12 |
| BUSY の立ち上がりと CLK の立ち上がりの遅れ | (測って書く) µs | 割り込みに入るまでの時間。LED が変わる時刻の遅れになる |
| BUSY の H の幅 (`counter8`) | (測って書く) µs | `eval()` 2 回ぶん。5-9 の上限を決める |

ばらつきの表 (5-10) の 3 行目に、この題の値を足して、3 つの方法を並べる。

## シミュレーションでの確かめ (対象外を含む)

PC で回す確かめは手元の Verilator 5.042 で行った。`.uf2` の大きさは、本文の Docker でビルドし直した。本文の `find_div()` と同じ探し方を計算し直し、`clock511.cpp` をビルドし直した。
`.uf2` と `arm-none-eabi-size` の値は、本文の Docker イメージ (`sfa-dev:local` の Verilator 5.048 と `wb-pico-sdk` の Pico SDK 2.2.0、`arm-none-eabi-gcc` 13.2.1) で、本文の `.cpp` と `.v` からビルドし直した値。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| 150 MHz のときの `div`・`wrap`・`level` (8 行) | 10 Hz = 240・62 499・31 250 … 2 kHz = 2・37 499・18 750 | 8 行とも同じ (`find_div` の探し方で `div` の小さいものから) | 計算値として合った |
| 最低の周波数 | 約 8.98 Hz | 150 MHz ÷ (255 × 65 536) = 8.976 Hz | 計算値として合った |
| GP16 のスライス・チャンネル | スライス 0、チャンネル A | Pico SDK の `PWM_GPIO_SLICE_NUM` = `(16 >> 1) & 7` = 0、偶数なのでチャンネル A | 合った |
| 割り込み番号 | `PWM_DEFAULT_IRQ_NUM()` (Pico 2 は `PWM_IRQ_WRAP_0`) | `pwm.h` の定義と同じ | 合った |
| `.cpp` のビルド (`hardware_pwm` を足す) | エラーなし | エラーなし | 合った |
| `.uf2` の大きさ | 96 256 バイト、text 51 920・bss 2 520 バイト | 96 256 バイト、text 51 920・bss 2 520 バイト | 合った |

### エミュレータ (picoemu) での確かめ

picoemu (`danish9661/pico-emulator` の `b83786f` に `sim/picoemu-m33.patch` を当てた版。手順は [5-2](02-counter-led.md#エミュレータ-picoemu-での確かめ)) に `clock511.uf2` を載せ、Cortex-M33 で動かした。入力は `-script` で与えた (ms 刻み)。
確かめは `python3 sim/picoemu-check.py --picoemu ./picoemu --uf2 <.uf2 を集めたフォルダ> 5-11`。picoemu は機能の模型で、周期・ジッタ・周波数の実時間は対象外にした。

| 項目 | 本文の数字 | picoemu の結果 | 判定 |
| --- | --- | --- | --- |
| 150 MHz のときの `div`・`wrap`・`level` (8 行) | 10 Hz = 240・62 499・31 250 … 2 kHz = 2・37 499・18 750 | PWM のレジスタに書かれた値が 8 行とも同じ (`PICOEMU_PWM_LOG=1`)。`clock_get_hz(clk_sys)` が 150 MHz で、`find_div` が表の `div` を選ぶ | 合った |
| CLK の周期・BUSY・`blink` の周期 | 1 kHz などの設計値 | picoemu の PWM はレジスタだけでカウンタが動かず、1 周期ごとの割り込みが入らない。CLK も BUSY も変わらなかった | 対象外 (picoemu が模型にしていない) |

確かめられなかったもの。

- CLK の周期・ばらつき・BUSY の遅れ (実機)。PWM のカウンタの動きそのものはシミュレートしていない

## 出典

自作。PWM のスライス・割り込み・分周の仕様は Raspberry Pi の Pico SDK の `hardware_pwm` と [RP2350 のデータシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) (PWM の章)。
システムクロックの既定 (150 MHz、12 MHz の水晶) は Pico SDK 2.2.0 の `hardware/platform_defs.h`。`blink.v` は 2-7、`counter.v` は 2-4。

参考: [Raspberry Pi Pico SDK (GitHub)](https://github.com/raspberrypi/pico-sdk)、[パルス幅変調 (Wikipedia)](https://ja.wikipedia.org/wiki/パルス幅変調)
