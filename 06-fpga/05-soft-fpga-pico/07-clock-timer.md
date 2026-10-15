---
book: fpga
chapter: 5
id: 5-7
title: クロックを固定する — タイマ割り込みで一定の間隔で回す
tier: 50
source: 自作
board: BB
device: PICO
---

# 5-7 クロックを固定する — タイマ割り込みで一定の間隔で回す

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 のプログラムは `.uf2` までのビルドを確かめたが、書き込んで動かしてはいない。
> 「見るべき値」の 1 kHz と 1 Hz はプログラムで決めた設計値で、測った値ではない。計算にかかる時間 (BUSY の幅) は測っていない。

5-5 と 5-6 で、Soft-FPGA の 1 クロックは計算の時間で決まり、回路を替えると変わることを見た。このままでは 1 Hz の点滅も、決まったボーレートの UART も作れない。

そこで、**クロックを計算の速さから切り離す**。Pico 2 の繰り返しタイマで 500 µs ごとに割り込みを入れ、そのたびに立ち上がりと立ち下がりを交互に 1 回ずつ計算する。
クロックの周期はタイマが決める 1 ms (1 kHz) になり、回路の規模に依らない。計算が早く終われば、残りの時間は待つ。

| 決め | 内容 |
| --- | --- |
| クロック | 1 kHz (半周期 500 µs)。`HALF_US` で決める |
| CLK のピン (GP16) | 割り込みの頭で反転する。H と L が 500 µs ずつの方形波になる |
| BUSY のピン (GP17、AUX) | `eval()` を計算している間だけ H。5-6 の差は、周期ではなく BUSY の幅に出る |
| 回路 | 5-6 と同じ 5 つを DIP スイッチで選ぶ。この題では SW1 を OFF にして、上の 4 つを使う |
| `blink` | 2-7 の `blink` を `CLK_HZ = 1000` にしたもの。クロックが本当に 1 kHz なら、LED が 1 Hz で点滅する |

条件が 1 つある。**計算 (BUSY の幅) が半周期の 500 µs より短いこと。** 長いと割り込みが追いつかず、周期が伸びる。
`many` (N = 256、SW1 を ON) が 500 µs に収まるかは測っていない。上限を探すのは 5-9 の題。

## 回路図

図1・図2 は 5-5 と同じ。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/07-clock-timer.svg)

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/breadboard/07-clock-timer.svg)

- 配線は 5-5 と同じ。AD3 は DIO0 (CLK)・DIO1 (BUSY)・DIO2 (OUT0、`blink` の LED) を読む
- `blink` を選ぶと、ブレッドボードの左端の LED (OUT0) が点滅する

## 部品表

5-5 と同じ。電源は 3.3 V (Pico 2 の GPIO)。

## Pico 2 のプログラム

作業用のフォルダは 5-5 と共通で、`board.h` は 5-5、`models.h` は 5-6 のまま。ビルドの打ち方は [5-1 の「ビルドする」](01-verilator-on-pico.md#ビルドする)。
主ループを、繰り返しタイマの割り込みに替える。

`clock57.cpp`:

```cpp
// 5-7 クロックを固定する — 繰り返しタイマの割り込みで半周期ずつ回す
#include "models.h"

constexpr int64_t HALF_US = 500;    // 半周期 500 µs → クロック 1 kHz

static Models m;
static volatile unsigned g_sel = 0;
static unsigned g_clk = 0;

static bool on_half(repeating_timer_t*) {
    g_clk ^= 1u;                    // 立ち上がりと立ち下がりを交互に
    gpio_put(PIN_CLK, g_clk);
    gpio_put(PIN_AUX, 1);           // BUSY: 計算している間だけ H
    m.edge(g_sel, g_clk);
    gpio_put(PIN_AUX, 0);
    return true;                    // 次も呼ぶ
}

int main() {
    board_init();
    m.reset();

    repeating_timer_t timer;
    // 負の周期は「呼び始めから次の呼び始めまで」。計算の長さで周期がずれない
    add_repeating_timer_us(-HALF_US, on_half, nullptr, &timer);

    while (true) {
        g_sel = read_sel();         // スイッチは主ループで読む
        sleep_ms(10);
    }
}
```

- `add_repeating_timer_us` に**負の周期**を渡すと、「呼び始めから次の呼び始めまで」が 500 µs になる (Pico SDK 2.2.0 の `pico/time.h` の説明)。正の周期だと「呼び終わりから次の呼び始めまで」になり、計算の時間が周期に足されてしまう
- 割り込みの中では、`gpio_put` と `eval()` だけをする。DIP スイッチは主ループで 10 ms ごとに読み、`g_sel` に置く
- CLK のピンを `eval()` の**前**に動かすので、ピンに出る端の時刻はタイマの時刻にほぼ揃う。`eval()` の長さは BUSY の幅に出る

5-5 と共通のフォルダを空から作ってビルドし、`build/clock57.uf2` (107 520 バイト) ができた。**実機では動かしていない。**

`blink` が 1 Hz になることは、PC の Verilator で確かめた。`CLK_HZ = 1000` の `blink` を 5000 クロック回すと、LED は 500 クロックごとに反転した (5000 クロックで 9 回。初めの反転はリセットを放してから 500 個目の立ち上がり)。

## 計器の設定

計器は AD3 の Logic。周期は決まっているので、時間軸も先に決められる。

| 見るもの | 設定 |
| --- | --- |
| CLK (図3) | DIO0 を Enable。標本化 1 MHz、500 µs/div。トリガは DIO0 の立ち上がり。カーソルは 250 µs と 1.25 ms (H の真ん中) |
| BUSY | DIO1 を足す。標本化は同じ 1 MHz で、BUSY の幅を 1 µs 刻みで読む。幅が短くて読めなければ標本化を上げる |
| `blink` (図4) | DIO2 を Enable。標本化 1 kHz、500 ms/div (窓 5 s)。トリガは DIO2 の立ち上がり。カーソルは 250 ms と 1.25 s |

## Logic に見えるはずの画面

図3 と図4 の周期は、プログラムで決めた設計値 (1 kHz と 1 Hz) で描いた。BUSY の幅は測っていないので描いていない。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 タイマで回すと CLK は 1 kHz に決まる
device: ad3
time: 500us/div
start: -500us
sample: 1MHz
signals:
  CLK: dio0 clock 1kHz
cursors: [250us, 1.25ms]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/07-clock-timer-1.svg)

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 2-7 の blink (CLK_HZ = 1000) は 1 Hz で点滅する
device: ad3
time: 500ms/div
start: -1s
sample: 1kHz
signals:
  MON0: dio2 edges -1s=0 0s=1 500ms=0 1s=1 1500ms=0 2s=1 2500ms=0 3s=1 3500ms=0
cursors: [250ms, 1.25s]
trigger: MON0 rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/07-clock-timer-2.svg)

- 図4 の時間軸では CLK は 1 目盛に 500 周期入り、線が塗りになるので載せていない
- t = 0 は LED が点いた所 (トリガ)。0.5 s ごとに点く・消えるを繰り返す

## 見るべき値

| 測る所 | 見るべき値 | 分かること |
| --- | --- | --- |
| CLK の周期 (図3 の ΔX) | 1.000 ms (設計値) | タイマがクロックを決めている |
| CLK の周期を 4 つの回路で比べる | 4 つとも 1.000 ms (設計値) | 周期が回路の規模に依らない。5-6 で測った差がここでは消える |
| BUSY の H の幅 | 回路ごとに (測って書く) µs | 計算の時間。5-6 で測った 1 クロックの半分ほどのはず (見込み) |
| BUSY の幅が 500 µs より短いか | 4 つの回路で (測って書く) | 短ければ、この周期で回せる |
| `blink` の LED の周期 (図4 の ΔX) | 1.000 s (設計値) | 2-7 の `blink` が 1 Hz で動く |
| CLK の周期のばらつき | (測って書く) | 割り込みの入る時刻のずれ。詳しくは 5-10 |

測った周期が 1.000 ms からずれる大きさは、Pico 2 の水晶の精度で決まる。その測り方は 5-12。
クロックが固定できたので、第 6 章のタイマーや第 7 章の UART のように、時間で決まる回路を Pico 2 で動かせる。

## シミュレーションでの確かめ (対象外を含む)

PC で回す確かめは手元の Verilator 5.042 で行った。`.uf2` の大きさは、本文の Docker でビルドし直した。本文の `models.h`・`clock57.cpp` を替え玉の GPIO とタイマ (`sim/pcstub/`) で PC で回し、
`blink` (`CLK_HZ` = 1000) を選んで 5000 クロック回した (`sim/07-clock-timer-pc.cpp`)。
`.uf2` と `arm-none-eabi-size` の値は、本文の Docker イメージ (`sfa-dev:local` の Verilator 5.048 と `wb-pico-sdk` の Pico SDK 2.2.0、`arm-none-eabi-gcc` 13.2.1) で、本文の `.cpp` と `.v` からビルドし直した値。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| `blink` を 5000 クロック | LED が 500 クロックごとに反転、9 回 | 9 回 (501 回目の立ち上がりの呼び出しが最初の反転、以後 500 ごと) | 合った |
| 最初の反転 | リセットを放してから 500 個目の立ち上がり | 呼び出し 501 回目は 500 個目の立ち上がり (1 回目はクロックが 1 のまま変わらず立ち上がりにならない) | 合った |
| 負の周期 | 呼び始めから次の呼び始めまで | Pico SDK 2.2.0 の `time.h` に同じ説明 (`<0` は呼び始めの間隔) | 合った |
| `HALF_US` | 500 µs → 1 kHz | 半周期 500 µs の 2 倍 = 1 ms (計算) | 合った |
| `.uf2` の大きさ | 107 520 バイト | 107 520 バイト | 合った |

### エミュレータ (picoemu) での確かめ

picoemu (`danish9661/pico-emulator` の `b83786f` に `sim/picoemu-m33.patch` を当てた版。手順は [5-2](02-counter-led.md#エミュレータ-picoemu-での確かめ)) に `clock57.uf2` を載せ、Cortex-M33 で動かした。入力は `-script` で与えた (ms 刻み)。
確かめは `python3 sim/picoemu-check.py --picoemu ./picoemu --uf2 <.uf2 を集めたフォルダ> 5-7`。picoemu は機能の模型で、周期・ジッタ・周波数の実時間は対象外にした。

| 項目 | 本文の数字 | picoemu の結果 | 判定 |
| --- | --- | --- | --- |
| CLK の周期 | 1.000 ms (設計値) | 999〜1001 µs (counter8・blink を選んだとき。±1 は picoemu の時計が µs 刻みなため) | 合った |
| `blink` の LED の周期 (SW = 011) | 1.000 s (設計値) | 500 ms ごとに反転 (500.981・1000.981・1500.981 ms …) = 周期 1.000 s | 合った |
| BUSY の幅・CLK のばらつき | 測って書く | 模型の値しか出ない | 対象外 (実時間) |

確かめられなかったもの。

- CLK の周期・BUSY の幅・ばらつき (実機)。「見るべき値」の測る欄は空のまま

## 出典

自作。繰り返しタイマは Raspberry Pi の Pico SDK の `pico_time` (`add_repeating_timer_us`)。`blink.v` は 2-7、回路の切り替えは 5-6。
