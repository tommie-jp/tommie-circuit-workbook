---
book: fpga
chapter: 5
id: 5-9
title: 固定できるクロックの上限 — いちばん重い 1 クロックより長い周期を選ぶ
tier: 100
source: 自作
board: BB
device: PICO
---

# 5-9 固定できるクロックの上限 — いちばん重い 1 クロックより長い周期を選ぶ

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 のプログラムは `.uf2` までのビルドを確かめたが、書き込んで動かしてはいない。
> 「見るべき値」の BUSY の幅と上限の周波数は**測っていない**。表の空欄は、測って書き込む。
> 表の周波数と、間に合わないときの動き (LED が全部点いて CLK が止まる) は、プログラムで決めた設計値で、動かして確かめた値ではない。

5-7 では、繰り返しタイマの割り込みで Soft-FPGA のクロックを 1 kHz に固定した。
このとき条件が 1 つだけあった。**1 回の計算 (`eval()`) が半周期より短いこと。**

この題では、その条件が破れる所を探す。半周期を DIP スイッチで 2000 µs (マイクロ秒) から 5 µs まで縮めていき、
計算が間に合わなくなる最初の値を Logic で見つける。回路は、いちばん重い `many` (32 ビットのカウンタを 256 本並べた回路、5-6)。

## 上限の考え方

タイマの割り込みは、半周期ごとに 1 回入り、そのたびに `eval()` を 1 回呼ぶ。
BUSY (GP17) が H の間が `eval()` の計算の時間で、CLK の半周期は、その計算より長くなければならない。

```text
半周期 ≥ BUSY の H の幅 (+ 余裕)
クロックの周波数の上限 = 1 ÷ (2 × (BUSY の H の幅 + 余裕))
```

- BUSY の幅は、立ち上がりの `eval()` と立ち下がりの `eval()` で違うかもしれない。**長いほうで決める**
- 回路を替えると BUSY の幅も変わる。上限は回路ごとに決まる。いちばん重い回路で決めておけば、ほかの回路は必ず収まる
- 余裕は、割り込みに入るまでの遅れとそのばらつき (5-10) を見込む分。ここでは**測った BUSY の最大の 2 倍**を半周期の目安に決める。2 倍にする根拠の数は、5-10 で測るまで持っていない

間に合わないとどうなるか。Pico SDK の繰り返しタイマは、半周期の間隔を「呼び始めから次の呼び始めまで」で数える (5-7)。
計算が間に合わないと、次の呼び出しの時刻は**もう過ぎている**ので、タイマは割り込みの中で続けて呼び出す
(`pico/time.c` の `alarm_pool_irq_handler` を読んだ。実機では確かめていない)。割り込みが連続し、主ループが回らなくなる。
DIP スイッチも読めなくなり、基板が固まったように見える。

そこで、このプログラムは**遅れを自分で測って止める**。割り込みの入った時刻が、本来の時刻より半周期以上遅れたら、
タイマを止めて LED を 4 つとも点ける。固まったのではなく、**上限を越えた**ことが目で分かる。

| 決め | 内容 |
| --- | --- |
| 回路 | `many` (N = 256)。5-6 と同じ |
| 半周期 | SW1〜SW4 の 4 ビットで選ぶ (下の表)。SW1 が上の桁、ON = 1。スイッチを替えると、その半周期でやり直す |
| CLK のピン (GP16) | 割り込みの頭で反転する。H と L が半周期ずつの方形波 |
| BUSY のピン (GP17、AUX) | `eval()` を計算している間だけ H |
| 間に合わないとき | 本来の時刻より半周期以上遅れたら、タイマを止める。LED (GP2〜GP5) が全部点き、CLK は止まった値のまま、BUSY は L |

SW1〜SW4 の値と半周期、クロックの周波数 (1 ÷ 周期 = 1 ÷ (2 × 半周期)。計算値):

| SW1〜SW4 | 半周期 | クロックの周波数 | SW1〜SW4 | 半周期 | クロックの周波数 |
| --- | --- | --- | --- | --- | --- |
| OFF OFF OFF OFF | 2000 µs | 250 Hz | ON OFF OFF OFF | 100 µs | 5 kHz |
| OFF OFF OFF ON | 1500 µs | 333 Hz | ON OFF OFF ON | 70 µs | 7.14 kHz |
| OFF OFF ON OFF | 1000 µs | 500 Hz | ON OFF ON OFF | 50 µs | 10 kHz |
| OFF OFF ON ON | 700 µs | 714 Hz | ON OFF ON ON | 30 µs | 16.7 kHz |
| OFF ON OFF OFF | 500 µs | 1 kHz | ON ON OFF OFF | 20 µs | 25 kHz |
| OFF ON OFF ON | 300 µs | 1.67 kHz | ON ON OFF ON | 15 µs | 33.3 kHz |
| OFF ON ON OFF | 200 µs | 2.5 kHz | ON ON ON OFF | 10 µs | 50 kHz |
| OFF ON ON ON | 150 µs | 3.33 kHz | ON ON ON ON | 5 µs | 100 kHz |

100 kHz までなら、ブレッドボードの範囲 (3 MHz 以下) に収まる。

## 回路図

図1・図2 は 5-5 と同じ。DIP スイッチは、この題では半周期の選択に使う。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/09-clock-limit.svg)

- 配線は 5-5 と同じ。LED は GP2〜GP5 (`many` の出力の上位 4 ビット)、DIP スイッチは GP10〜GP13、AD3 は GP16 (CLK)・GP17 (BUSY)・GP18〜GP21 (LED と同じ値)
- 「間に合わない」の合図は LED の全点灯。AD3 の DIO2〜DIO5 (GP18〜GP21) でも同じ印が H になる

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/breadboard/09-clock-limit.svg)

- 配線は 5-5 と同じ。AD3 は DIO0 (CLK)・DIO1 (BUSY) を主に読む
- DIP スイッチは下の列の左から 4・3・2・1。**右端が SW1** (上の桁)

## 部品表

5-5 と同じ (Pico 2、330 Ω (オーム) の抵抗 4 本、赤の LED 4 個、4 連の DIP スイッチ、full のブレッドボード、AD3)。
電源は 3.3 V (Pico 2 の GPIO)。5 V を入れないのは 0-3 と同じ理由。LED の電流は 5-5 と同じで、1 個あたり約 4 mA (計算値)。

## Pico 2 のプログラム

作業用のフォルダは 5-5 と共通で、`board.h` は 5-5 のまま。ビルドの打ち方は [5-1 の「ビルドする」](01-verilator-on-pico.md#ビルドする)。
`many.v` は 5-6 のもの (`-GN=256`)。

`clock59.cpp`:

```cpp
// 5-9 固定できるクロックの上限 — 半周期を DIP スイッチで縮め、間に合わなくなる所を探す
#include "board.h"
#include "Vmany.h"

// SW1〜SW4 の 4 ビット (SW1 が上の桁、ON = 1) で半周期 (µs) を選ぶ。0000 がいちばん長い
constexpr uint32_t HALF_US[16] = {2000, 1500, 1000, 700, 500, 300, 200, 150,
                                  100,  70,   50,   30,  20,  15,  10,  5};

static Vmany top;
static uint32_t g_half = 0;       // 今の半周期 (µs)
static int64_t g_target = 0;      // 次に呼ばれるはずの時刻 (µs)
static bool g_first = true;
static unsigned g_clk = 0;
static repeating_timer_t g_timer;

static bool on_half(repeating_timer_t*) {
    const int64_t now = (int64_t)time_us_64();
    if (g_first) {                              // 最初の呼び出しを時刻の基準にする
        g_first = false;
        g_target = now;
    }
    if (now - g_target >= (int64_t)g_half) {    // 半周期ぶん以上遅れた = 間に合わない
        put_leds(0xF);                          // LED を全部点けて知らせる
        gpio_put(PIN_AUX, 0);
        return false;                           // タイマを止める
    }
    g_target += g_half;
    g_clk ^= 1u;
    gpio_put(PIN_CLK, g_clk);
    gpio_put(PIN_AUX, 1);                       // BUSY: 計算している間だけ H
    top.clk = g_clk;
    top.eval();
    if (g_clk) put_leds(top.sum >> 4);
    gpio_put(PIN_AUX, 0);
    return true;
}

static void start(unsigned idx) {
    cancel_repeating_timer(&g_timer);
    g_half = HALF_US[idx];
    g_first = true;
    g_clk = 0;
    add_repeating_timer_us(-(int64_t)g_half, on_half, nullptr, &g_timer);
}

int main() {
    board_init();
    top.rst = 1;
    top.clk = 0; top.eval();
    top.clk = 1; top.eval();
    top.clk = 0; top.eval();
    top.rst = 0;

    unsigned idx = read_sw();
    start(idx);
    while (true) {
        const unsigned now = read_sw();
        if (now != idx) {            // スイッチを替えたら、その半周期でやり直す
            idx = now;
            start(idx);
        }
        sleep_ms(10);
    }
}
```

- `g_target` は「次に呼ばれるはずの時刻」。呼ばれるたびに半周期ずつ進め、実際の時刻との差が**遅れ**になる。最初の呼び出しの時刻を基準にする
- 遅れが半周期に達したら `false` を返してタイマを止める。タイマ自体は 5-7 と同じ負の周期 (`-g_half`) で、呼び始めの間隔が半周期になる
- 間に合っていれば、BUSY を H にして `eval()`、終わったら L に戻す。LED は立ち上がりの `eval()` のあとで書く
- スイッチを読むのは主ループで、10 ms ごと。割り込みが止まった (LED が全点灯の) あとも主ループは回るので、スイッチを替えれば、その半周期でやり直せる

`CMakeLists.txt` の最後に次の 1 行を足す (5-5 の 4 行と並べてよい)。

```cmake
add_soft_fpga(clock59 clock59.cpp many)
```

空のフォルダから 5-1 の手順でビルドし、`build/clock59.uf2` (96 256 バイト) ができた (Verilator 5.048、Pico SDK 2.2.0)。
`arm-none-eabi-size` は text 51 760 バイト、bss 2 412 バイト。**実機では動かしていない。**

## 計器の設定

計器は AD3 の Logic。半周期を縮めるほど速くなるので、標本化は半周期の 1/10 以下の刻みを目安に上げる。

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 (CLK)・DIO1 (BUSY) を Enable。標本化は 10 MHz から。BUSY の幅を 0.1 µs 刻みで読む |
| Logic のトリガ | DIO0 の立ち上がり |
| 時間軸 | CLK が 2〜5 周期入るように合わせる。図3 は半周期 100 µs (SW1 だけ ON) で 100 µs/div |
| カーソル | X1 を BUSY の立ち上がり、X2 を立ち下がりに置く。ΔX が計算の時間。CLK の H の幅 (半周期) と並べて読む |

手順は次のとおり。

1. SW1〜SW4 をすべて OFF にして電源を入れる (半周期 2000 µs)。BUSY の幅 (ΔX) を読み、表に書く
2. SW を 1 つずつ上げて (OFF OFF OFF ON、OFF OFF ON OFF、…)、半周期を縮める。そのつど BUSY の幅を読む
3. LED が全部点いて CLK が止まった半周期が、**間に合わなくなった最初の値**。その 1 つ前までが、動く範囲
4. 動いた最後の半周期の BUSY の幅と、半周期の比を計算する。比が 2 を切っていれば、余裕の目安 (2 倍) を割っている

## Logic に見えるはずの画面

図3 は、半周期 100 µs (5 kHz) で動いているときの CLK。周期はプログラムで決めた設計値。**BUSY の幅は測っていないので描いていない。**

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 半周期 100 µs (SW1 だけ ON) の CLK は 5 kHz (周期 200 µs)
device: ad3
time: 100us/div
start: -100us
sample: 10MHz
signals:
  CLK: dio0 clock 5kHz
cursors: [50us, 250us]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/09-clock-limit-1.svg)

図4 は、上限を越えたときに見えるはずの形。CLK が途中で止まり、LED の 4 本が全部 H になる。止まる時刻は仮 (遅れがたまる回数で決まる)。CLK は止まった値のままで、図では L で止まるように描いた。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 上限を越えると CLK が止まり、LED (MON0〜MON3) が全部 H になる (止まる時刻は仮)
device: ad3
time: 100us/div
start: -100us
sample: 10MHz
signals:
  CLK: dio0 edges -100us=0 0s=1 100us=0 200us=1 300us=0 400us=1 500us=0
  MON0: dio2 edges -100us=0 500us=1
  MON1: dio3 edges -100us=0 500us=1
  MON2: dio4 edges -100us=0 500us=1
  MON3: dio5 edges -100us=0 500us=1
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/09-clock-limit-2.svg)

- 図3 のカーソルは H の真ん中。カーソルの間隔は 200 µs で、CLK の 1 周期
- 図4 の LED は、止まった瞬間に全部 H になる。DIP スイッチを替えると、半周期を選び直してやり直す

## 見るべき値

**測っていない。測って空欄を埋める。** 数を決め打たないのは、この冊の決め (1 クロックの時間は実測してから書く)。

| 測る所 | 見るべき値 | 分かること |
| --- | --- | --- |
| 半周期 2000 µs のときの BUSY の H の幅 | (測って書く) µs | `many` の `eval()` 1 回の時間。5-6 で測った 1 クロックの半分ほどのはず (見込み) |
| 立ち上がりと立ち下がりの BUSY の幅 | (測って書く) µs と (測って書く) µs | 長いほうで上限を決める |
| LED が全部点いた最初の半周期 (SW1〜SW4) | (測って書く) | 間に合わなくなった最初の値 |
| 動いた最後の半周期と、その BUSY の幅の比 | (測って書く) | 2 を切るほど余裕が少ない |
| 上限のクロックの周波数 | (測って書く) kHz | 1 ÷ (2 × 動いた最後の半周期) |
| `many` を `counter8` に替えたときの上限 | (測って書く) kHz | 回路が小さいほど上限が高い。5-6 の差と合うか |

測った上限は、**第 6 章以降で時間を決める回路を載せるときの天井**になる。
UART のボーレートや 7 セグの切り替え速度は、この上限の下で決める。

## シミュレーションでの確かめ (対象外を含む)

PC で回す確かめは手元の Verilator 5.042 で行った。`.uf2` の大きさは、本文の Docker でビルドし直した。`many.v` (5-6、`-GN=256`) と本文の `clock59.cpp` をビルドし直し、半周期の表を計算し直した。
`.uf2` と `arm-none-eabi-size` の値は、本文の Docker イメージ (`sfa-dev:local` の Verilator 5.048 と `wb-pico-sdk` の Pico SDK 2.2.0、`arm-none-eabi-gcc` 13.2.1) で、本文の `.cpp` と `.v` からビルドし直した値。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| 半周期の表 (16 行) | 周波数 = 1 ÷ (2 × 半周期) | 2000 µs → 250 Hz、1500 → 333 Hz、700 → 714 Hz、300 → 1.67 kHz、150 → 3.33 kHz、70 → 7.14 kHz、30 → 16.7 kHz、15 → 33.3 kHz、5 µs → 100 kHz (計算) | 計算値として合った |
| `HALF_US[16]` と表の並び | SW1〜SW4 = 0000 が 2000 µs、1111 が 5 µs | 配列の並びと表が一致 | 合った |
| 間に合わないとき | 次の呼び出しの時刻が過ぎていれば連続して呼ぶ | Pico SDK 2.2.0 の `time.c` の `alarm_pool_irq_handler` が、目標時刻を過ぎた間はループして呼ぶ | 合った |
| `.cpp` のビルド | エラーなし | エラーなし (`cancel_repeating_timer`・`time_us_64` が通る) | 合った |
| `.uf2` の大きさ | 96 256 バイト、text 51 760・bss 2 412 バイト | 96 256 バイト、text 51 760・bss 2 412 バイト | 合った |

確かめられなかったもの。

- BUSY の幅と、間に合わなくなる半周期 (実機)。本文のとおり、周波数と LED の全点灯は設計値で、動かして確かめていない

## 出典

自作。繰り返しタイマの時刻の数え方は Raspberry Pi の Pico SDK の `pico_time` (`time.c` の `alarm_pool_irq_handler`、SDK 2.2.0)。
`many.v` は 5-6、タイマ割り込みの組み方は 5-7。
