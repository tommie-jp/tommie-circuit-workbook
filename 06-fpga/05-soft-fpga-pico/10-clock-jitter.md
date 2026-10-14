---
book: fpga
chapter: 5
id: 5-10
title: クロックの周期のばらつき (ジッタ) を測る
tier: 100
source: 自作
board: BB
device: PICO
---

# 5-10 クロックの周期のばらつき (ジッタ) を測る

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 のプログラムは `.uf2` までのビルドを確かめたが、書き込んで動かしてはいない。
> 周期の最小・最大・平均・標準偏差は**測っていない**。「見るべき値」の表の空欄は、測って書き込む。
> 集計の `jitter.py` は、作り物の CSV で動きだけを確かめた (WaveForms が書き出す CSV の形は想定で、実物では確かめていない)。

5-5 の表に「CLK の周期の最小と最大」という行があった。FPGA のクロックは水晶が決めるので 1 周期ごとの長さが揃う。
Soft-FPGA は、計算の時間やタイマ割り込みの入り方が毎回少しずつ違うので、**周期が揃わない**。
この周期のばらつきをジッタと呼ぶ。

この題では、Soft-FPGA のクロックを 2 つの方法で回し、周期を Logic で何百回も測って、最小・最大・平均・標準偏差を比べる。

| 方法 | 題 | CLK の端を出す所 |
| --- | --- | --- |
| 主ループ | 5-5 | 計算の合間に、プログラムが自分で GP16 を動かす。端の時刻は、前の周回の計算の長さに左右される |
| タイマ割り込み | 5-7 | 割り込みの頭で GP16 を動かす。端の時刻は、タイマの時刻と、割り込みに入るまでの遅れで決まる |

ばらつきの原因を、先に見込みとして書いておく。測って確かめるのは、このあとの手順。

- 主ループ: 1 周の長さは、計算の量・分岐・命令の取り込み (フラッシュからのキャッシュ) で変わる。**端の間隔に直接乗る** (見込み)
- タイマ割り込み: 端は計算の前に出すので、計算の長さは乗らない。乗るのは、割り込みを受け付けるまでの遅れの変動 (見込み)。
  Pico 2 の CPU は既定 150 MHz (Pico SDK の `SYS_CLK_HZ`) なので、1 サイクルは 6.67 ns (ナノ秒、計算値)。遅れの変動はこの数倍から数十倍と見込むが、**測っていない**

## 測り方の限界

Logic は 1 回の取り込みで 32 768 標本を持つ (5-5 の前提)。標本化を 10 MHz にすると、窓は 3.28 ms、時間の刻みは 0.1 µs (マイクロ秒)。
1000 周期を 1 回の取り込みに入れるのは無理で、**何回か撮って足す**。1 回に入る周期の数は、半周期で決まる (計算値)。

| 半周期 | クロックの周期 | 10 MHz で 1 回に入る周期 | 1000 周期に要る取り込み |
| --- | --- | --- | --- |
| 5 µs | 10 µs (100 kHz) | 約 327 | 4 回 |
| 10 µs | 20 µs (50 kHz) | 約 163 | 7 回 |
| 20 µs | 40 µs (25 kHz) | 約 81 | 13 回 |
| 50 µs | 100 µs (10 kHz) | 約 32 | 32 回 |
| 500 µs | 1 ms (1 kHz) | 約 3 | 334 回 |

- **刻みの 0.1 µs より小さいばらつきは見えない。** 1 サイクル (6.67 ns) の変動は、10 MHz の標本化では見えない。標本化を上げると窓が狭くなる (窓 = 32 768 ÷ 標本化)
- 周期が短いほど少ない回数で足りる。ただし半周期が `eval()` の計算の長さを切ると、割り込みが間に合わない (5-9)。この題の `counter8` は小さな回路なので 5 µs でも収まる見込みだが、**測っていない**。半周期を縮めて周期が伸びたら、5-9 の上限に当たっている
- 主ループの周期は 5-5 で測った値で決まるので、選べない。比べるタイマ割り込みの半周期は、**主ループの周期に近い値**を表から選ぶ

## 回路図

図1・図2 は 5-5 と同じ。DIP スイッチは、この題では起動時に動かし方を選ぶのに使う。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/10-clock-jitter.svg)

- 配線は 5-5 と同じ。AD3 は GP16 (CLK) を DIO0 で読む。ほかの DIO はつながったままでよい (LED の写しが出るだけ)
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/breadboard/10-clock-jitter.svg)

- 配線は 5-5 と同じ。AD3 は DIO0 (CLK、白) を読む
- DIP スイッチは下の列の左から 4・3・2・1。**右端が SW1**

## 部品表

5-5 と同じ。電源は 3.3 V (Pico 2 の GPIO)。5 V を入れないのは 0-3 と同じ理由。

## Pico 2 のプログラム

作業用のフォルダは 5-5 と共通で、`board.h` は 5-5 のまま。ビルドの打ち方は [5-1 の「ビルドする」](01-verilator-on-pico.md#ビルドする)。
回路は 5-5 の `counter8` (2-4 の 8 ビットのカウンタ) を使う。

`clock510.cpp`:

```cpp
// 5-10 クロックの周期のばらつきを測る — 主ループと、タイマ割り込みを起動時の SW1 で選ぶ
#include "board.h"
#include "Vcounter8.h"

// タイマ割り込みの半周期 (µs)。SW2〜SW4 の 3 ビット (SW2 が上の桁) で選ぶ
constexpr uint32_t HALF_US[8] = {5, 10, 20, 50, 100, 200, 500, 1000};

static Vcounter8 top;
static unsigned g_clk = 0;

static bool on_half(repeating_timer_t*) {
    g_clk ^= 1u;
    gpio_put(PIN_CLK, g_clk);       // 端を eval の前に出す。eval の長さが端の時刻に乗らない
    top.clk = g_clk;
    top.eval();
    if (g_clk) put_leds(top.count >> 4);
    return true;
}

int main() {
    board_init();
    top.rst = 1;
    top.clk = 0; top.eval();
    top.clk = 1; top.eval();
    top.clk = 0; top.eval();
    top.rst = 0;

    const unsigned sw = read_sw();          // 起動時に 1 度だけ読む
    if (sw & 0x8u) {                        // SW1 ON: タイマ割り込み
        static repeating_timer_t timer;
        const int64_t half = HALF_US[sw & 0x7u];
        add_repeating_timer_us(-half, on_half, nullptr, &timer);
        while (true) tight_loop_contents();
    }
    while (true) {                          // SW1 OFF: 主ループ (5-5 と同じ形)
        gpio_put(PIN_CLK, 1);
        top.clk = 1; top.eval();
        put_leds(top.count >> 4);
        gpio_put(PIN_CLK, 0);
        top.clk = 0; top.eval();
    }
}
```

| 起動時のスイッチ | 動き |
| --- | --- |
| SW1 OFF | 主ループ。5-5 と同じ形 (AUX は使わない) |
| SW1 ON、SW2〜SW4 | タイマ割り込み。SW2〜SW4 の 3 ビット (SW2 が上の桁) で半周期を選ぶ |

タイマ割り込みの半周期 (SW2 SW3 SW4。計算値):

| SW2 SW3 SW4 | 半周期 | クロックの周波数 |
| --- | --- | --- |
| OFF OFF OFF | 5 µs | 100 kHz |
| OFF OFF ON | 10 µs | 50 kHz |
| OFF ON OFF | 20 µs | 25 kHz |
| OFF ON ON | 50 µs | 10 kHz |
| ON OFF OFF | 100 µs | 5 kHz |
| ON OFF ON | 200 µs | 2.5 kHz |
| ON ON OFF | 500 µs | 1 kHz |
| ON ON ON | 1000 µs | 500 Hz |

`CMakeLists.txt` の最後に次の 1 行を足す。

```cmake
add_soft_fpga(clock510 clock510.cpp counter8)
```

空のフォルダから 5-1 の手順でビルドし、`build/clock510.uf2` (94 208 バイト) ができた (Verilator 5.048、Pico SDK 2.2.0)。
`arm-none-eabi-size` は text 50 720 バイト、bss 2 400 バイト。**実機では動かしていない。**

## 計器の設定

計器は AD3 の Logic。

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 (CLK) を Enable。標本化 10 MHz (窓は約 3.28 ms) |
| Logic のトリガ | DIO0 の立ち上がり |
| 時間軸 | 窓の全体に周期が並ぶように合わせる。図3 は半周期 20 µs (SW1・SW3 が ON) で 20 µs/div |
| 取り込み | 1 回撮るたびに、データを CSV に書き出す (WaveForms の Logic の書き出し)。方法ごとに 1000 周期以上たまるまで繰り返す |

CSV は、次の `jitter.py` に渡す。立ち上がり (0 → 1) の時刻の差を周期として、最小・最大・平均・標準偏差を出す。

```python
#!/usr/bin/env python3
"""jitter.py — Logic の CSV から、立ち上がりの間隔 (周期) の最小・最大・平均・標準偏差を出す。

使い方: python3 jitter.py logic.csv [列の番号]
  1 列めが時刻 (s)、2 列め以降が DIO。列の番号の既定は 1 (DIO0 = CLK)。
  '#' で始まる行と、数にならない行 (見出し) は読み飛ばす。複数のファイルを足すときは続けて書く。
"""
import csv
import statistics
import sys


def periods(path, col):
    """立ち上がり (0 → 1) の時刻の差を、出てくる順に返す。"""
    prev_value = None
    prev_rise = None
    out = []
    with open(path, newline="") as f:
        for row in csv.reader(f):
            if not row or row[0].lstrip().startswith("#"):
                continue
            try:
                t = float(row[0])
                v = int(float(row[col + 1]))
            except (ValueError, IndexError):
                continue
            if prev_value == 0 and v == 1:
                if prev_rise is not None:
                    out.append(t - prev_rise)
                prev_rise = t
            prev_value = v
    return out


def main(argv):
    paths = [a for a in argv if not a.isdigit()]
    col = int(next((a for a in argv if a.isdigit()), "0"))
    if not paths:
        sys.exit("使い方: jitter.py logic.csv [DIO の番号]")
    values = []
    for path in paths:
        values += periods(path, col)
    if len(values) < 2:
        sys.exit("周期が 2 つ以上取れなかった (立ち上がりが足りない)")
    us = [v * 1e6 for v in values]
    print(f"周期の数  {len(us)}")
    print(f"最小      {min(us):.3f} us")
    print(f"最大      {max(us):.3f} us")
    print(f"平均      {statistics.mean(us):.3f} us")
    print(f"標準偏差  {statistics.pstdev(us):.3f} us")
    print(f"最大-最小 {max(us) - min(us):.3f} us")


if __name__ == "__main__":
    main(sys.argv[1:])
```

```bash
python3 jitter.py main_01.csv main_02.csv main_03.csv 0     # 主ループ (DIO0 = 0)
python3 jitter.py timer_01.csv timer_02.csv 0               # タイマ割り込み
```

- 1 列めを時刻 (s)、2 列め以降を DIO と読む。末尾の数が DIO の番号 (0 なら DIO0)。WaveForms の書き出しが違う形なら、`periods()` の列の読みを直す
- 複数のファイルは、周期を足し合わせて集計する。取り込みの境目は周期として数えない

## Logic に見えるはずの画面

図3 は、タイマ割り込みの半周期 20 µs (25 kHz、周期 40 µs) で動いているときの CLK。周期はプログラムで決めた設計値で、**ばらつきは測っていないので描いていない**
(測れば、立ち上がりの位置が周期ごとに少しずつずれる)。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 タイマ割り込みの半周期 20 µs の CLK は 25 kHz (周期 40 µs)
device: ad3
time: 20us/div
start: -20us
sample: 10MHz
signals:
  CLK: dio0 clock 25kHz
cursors: [10us, 50us]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/10-clock-jitter.svg)

- カーソルは H の真ん中。間隔は 40 µs で、CLK の 1 周期
- 実機では、トリガから離れた周期ほど立ち上がりの位置が揺れて見える。揺れの幅が、ここで測るジッタ

## 見るべき値

**測っていない。測って空欄を埋める。** 数を決め打たないのは、この冊の決め (1 クロックの時間は実測してから書く)。

| 方法 | 周期の数 | 最小 | 最大 | 平均 | 標準偏差 | 最大 − 最小 |
| --- | --- | --- | --- | --- | --- | --- |
| 主ループ (SW1 OFF) | (測って書く) | (測って書く) µs | (測って書く) µs | (測って書く) µs | (測って書く) µs | (測って書く) µs |
| タイマ割り込み (SW1 ON、半周期 20 µs) | (測って書く) | (測って書く) µs | (測って書く) µs | (測って書く) µs | (測って書く) µs | (測って書く) µs |
| タイマ割り込み (主ループの周期に近い半周期) | (測って書く) | (測って書く) µs | (測って書く) µs | (測って書く) µs | (測って書く) µs | (測って書く) µs |

見るとよいこと:

- 平均の周期が、5-5 で測った値 (主ループ)、設計値 (タイマ割り込み。半周期 × 2) と合うか
- 「最大 − 最小」が 0.1 µs (標本化の刻み) の 1 つか 2 つ分なら、刻みより小さいばらつきは見えていない。標本化を上げて撮り直す
- 主ループとタイマ割り込みで、ばらつきがどちらに大きいか。見込みは主ループ (上の説明)。**測って違えば、見込みを直す**
- 5-11 の PWM でも同じ測り方をして、3 つを並べる (5-11 の表)

## 出典

自作。繰り返しタイマの時刻の数え方は Raspberry Pi の Pico SDK の `pico_time` (5-9)。Pico 2 の既定のシステムクロックは同じ SDK の
`hardware/platform_defs.h` (`SYS_CLK_HZ` 150 MHz)。AD3 の Logic の使い方は 0-4。
