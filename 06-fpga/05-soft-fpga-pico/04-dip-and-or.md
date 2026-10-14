---
book: fpga
chapter: 5
id: 5-4
title: DIP スイッチと LED で AND・OR を確かめる
tier: 50
source: 自作
board: BB
device: PICO
---

# 5-4 DIP スイッチと LED で AND・OR を確かめる

> [!WARNING]
> **この題は実機で組んでいない。** Verilog の lint、`.uf2` のビルド、同じ主ループを PC で回して真理値表を確かめるところまでを行った。
> Pico 2 に書き込んで LED を見てはいない。

1-1 では、`assign` で書いた AND・OR・NOT (`gates.v`) を PC の Verilator だけで確かめた。
この題では同じ `gates.v` を Pico 2 で動かし、入力を DIP スイッチで切り替えて、出力を LED で見る。
ブレッドボードは 5-3 と同じ配線をそのまま使い、書き込む `.uf2` だけを替える。

5-3 との違いは、回路にクロックが無いことである。組み合わせ回路なので、主ループは「読む → `eval()` を 1 回 → 書く」になる。
`clk` を上げ下げする `tick()` は要らない。

## 論理図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 AND・OR・NOT の論理図 (1-1 の図1 と同じ)
parts:
  a: port 1,2
  b: port 1,8
  G1: not 8,2
  G2: and 8,5
  G3: or 8,8
  y_not: port 13,2
  y_and: port 13,5
  y_or: port 13,8
wires:
  - 1,2 -- 3,2
  - 3,2 -- 3,7
  - 3,2 |- G1.in
  - 3,5 |- G2.a
  - 3,7 |- G3.a
  - 1,8 -- 5,8
  - 5,8 -- 5,6
  - 5,6 |- G2.b
  - 5,8 |- G3.b
  - G1.out -- 13,2
  - G2.out -- 13,5
  - G3.out -- 13,8
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/04-dip-and-or-1.svg)

ポートと Pico 2 のピンの対応は次のとおり。5-3 の表1 と同じピンを使う。

| Verilog のポート | GPIO (ピンの番号) | 部品 | 1 のとき |
| --- | --- | --- | --- |
| `a` | GP17 (22 番) | SW1 (DIP スイッチの 1) | スイッチが ON (ピンは L) |
| `b` | GP16 (21 番) | SW2 (DIP スイッチの 2) | スイッチが ON (ピンは L) |
| `y_and` | GP14 (19 番) | R1・D1 | D1 が点く |
| `y_or` | GP15 (20 番) | R2・D2 | D2 が点く |
| `y_not` | GP25 | Pico 2 の基板の上の LED | 基板の LED が点く |

- DIP スイッチは 5-3 と同じく、片側を GND につなぎ、Pico 2 の内蔵プルアップで読んで反転する。Soft-FPGA-TD4 の `main.cpp` と同じ形で、
  外付けのプルダウン抵抗は使わない
- 計画 (docs/111) では「プルダウン 10 kΩ」としていたが、そうしなかった。RP2350 のデータシートのエラッタ RP2350-E9 は、
  A2 版のチップで内蔵プルダウンが働かないことがあり、外付けなら 8.2 kΩ 以下にする、と書いている。10 kΩ はこれを満たさない。
  内蔵プルアップならこの不具合の影響を受けず、部品も要らない
- `y_not` は、Pico 2 の基板に載っている LED (GP25) に出す。ブレッドボードの配線は増えない。GP25 はピンとして基板の縁に出ていないので、AD3 では測らない

## Verilog

1-1 の `gates.v` をそのまま使う。

```verilog
// gates.v
module gates (
    input  wire a,
    input  wire b,
    output wire y_and,
    output wire y_or,
    output wire y_not
);
    assign y_and = a & b;
    assign y_or  = a | b;
    assign y_not = ~a;
endmodule
```

C++ にするのは 5-1 の `verilate.sh` で、最後の行を次に替える。`-Wall` の lint は警告なしで通った (Verilator 5.048)。

```bash
verilator --cc --no-timing --no-trace -Wall --prefix Vgates --Mdir v_gates gates.v
```

## Pico 2 のプログラム

ビルドの手順は 5-1 と同じ ([5-1 の「ファイル」と「ビルドする」](01-verilator-on-pico.md#ファイル))。
題ごとに替えるのは、`verilate.sh` の最後の行 (上)、`CMakeLists.txt` の最後の行、`main.cpp` の 3 つ。
`CMakeLists.txt` の最後の行は次にする。

```cmake
add_soft_fpga(gates_pico main.cpp gates)
```

`main.cpp`:

```cpp
// 1-1 の gates.v を Pico 2 で回す。a・b は DIP スイッチ、出力は LED
#include "pico/stdlib.h"
#include "Vgates.h"

#define PIN_A    17   // SW1 (ON で L)
#define PIN_B    16   // SW2 (ON で L)
#define PIN_AND  14   // D1
#define PIN_OR   15   // D2
#define PIN_NOT  25   // Pico 2 の基板の上の LED

int main() {
    const uint in_pins[]  = {PIN_A, PIN_B};
    const uint out_pins[] = {PIN_AND, PIN_OR, PIN_NOT};
    for (uint p : in_pins) {
        gpio_init(p);
        gpio_set_dir(p, GPIO_IN);
        gpio_pull_up(p);               // 内蔵プルアップ。スイッチは GND へ落とす
    }
    for (uint p : out_pins) {
        gpio_init(p);
        gpio_set_dir(p, GPIO_OUT);
    }

    VerilatedContext ctx;
    Vgates top{&ctx};

    while (true) {
        top.a = !gpio_get(PIN_A);      // 1. 読む (ON = L を 1 に反転)
        top.b = !gpio_get(PIN_B);
        top.eval();                    // 2. eval (クロックは無い)
        gpio_put(PIN_AND, top.y_and);  // 3. 書く
        gpio_put(PIN_OR,  top.y_or);
        gpio_put(PIN_NOT, top.y_not);
    }
}
```

空のフォルダから 5-1 の手順でビルドし、`build/gates_pico.uf2` (93 184 バイト) ができた。**実機では動かしていない。**

### PC で主ループを回す

5-2・5-3 と同じく、GPIO の関数を PC の替え玉に差し替えて `main.cpp` を回し、a・b の 4 通りで出力のピンを出した。

```text
GP17=1 GP16=1 (a=0 b=0) -> GP14(AND)=0 GP15(OR)=0 GP25(NOT)=1
GP17=1 GP16=0 (a=0 b=1) -> GP14(AND)=0 GP15(OR)=1 GP25(NOT)=1
GP17=0 GP16=1 (a=1 b=0) -> GP14(AND)=0 GP15(OR)=1 GP25(NOT)=0
GP17=0 GP16=0 (a=1 b=1) -> GP14(AND)=1 GP15(OR)=1 GP25(NOT)=0
```

1-1 の真理値表と同じになった。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図2 DIP スイッチ 2 本と LED 2 個を Pico 2 につなぐ (5-3 と同じ)
parts:
  SW1: dip-switch4 4,7.02
  MCU: pico2 9,3 mirror
  R1: resistor 12,5 14,5 330
  D1: led 14,5 14,7 red
  R2: resistor 12,9 14,9 330
  D2: led 14,9 14,11 red
  G1: ground 1,8
  G2: ground 2,8
  G3: ground 14,7
  G4: ground 14,11
  G5: ground 6.5,1
wires:
  - SW1.B1 -- MCU.GP17
  - SW1.B2 -- MCU.GP16
  - SW1.A1 -| 1,8
  - SW1.A2 -| 2,8
  - MCU.GP14 -| 12,5
  - MCU.GP15 -| 11.5,9
  - 11.5,9 -- 12,9
  - MCU.GND38 -| 6.5,1
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/04-dip-and-or-2.svg)

- 5-3 の図2 と同じ回路。D1 が AND、D2 が OR を示す
- LED の電流は 1 個あたり (3.3 − 2.0) / 330 ≈ 3.9 mA (計算値。赤 LED の V<sub>F</sub> を 2.0 V と置いた)。330 Ω (オーム) は E24 の値

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図3 5-3 と同じ配線。SW1 が a、SW2 が b、D1 が AND、D2 が OR
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor h26 h29 330
  D1: led f29(A) f30(K) red cap=above
  R2: resistor h33 h36 330
  D2: led f36(A) f37(K) red cap=above
  SW1: dip-switch4 @ e40
  PAT:
    type: device
    at: top
    label: AD3 Patterns
    pins: [DIO0, DIO1, GND]
  LOG:
    type: device
    at: bottom
    label: AD3 Logic
    pins: [DIO2, DIO3, GND]
wires:
  - MCU.GND38 -- -t7 black
  - -t3 -- -b3 black
  - i23 -- i26 yellow
  - j24 -- j25 orange
  - g25 -- g33 orange
  - j30 -- -b30 black
  - j37 -- -b37 black
  - MCU.GP17 -- a27 green
  - c27 -- c40 green
  - a24 -- a26 blue
  - d26 -- d41 blue
  - j40 -- -b40 black
  - j41 -- -b41 black
  - PAT.DIO0 -- a40 green
  - PAT.DIO1 -- a41 blue
  - PAT.GND -- -t44 black
  - LOG.DIO2 -- j26 yellow
  - LOG.DIO3 -- j33 orange
  - LOG.GND -- -b44 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/breadboard/04-dip-and-or.svg)

- 配線は 5-3 の図3 と同じ。線の道筋と穴は 5-3 の説明を見る
- DIP スイッチ SW1 の 1 番 (e40・f40 の間) が a、2 番 (e41・f41 の間) が b
- AD3 の Patterns は a・b のピンに信号を入れ、Logic は AND・OR のピンを読む

## 計器の設定

まず AD3 をつながずに、DIP スイッチを手で 4 通りに切り替えて LED を見る。次に AD3 の Patterns で a・b を自動で切り替え、
4 通りを 1 枚の画面に収める。

| 計器 | 設定 |
| --- | --- |
| Patterns | DIO0 (a のピン、GP17) を Clock 50 Hz、DIO1 (b のピン、GP16) を Clock 100 Hz。AD3 の DIO は 3.3 V の信号 (0-3) |
| Logic | DIO0〜DIO3 を Enable。標本化 100 kS/s、4 ms/div |
| Logic のトリガ | DIO0 の立ち下がり (a が 0 から 1 になる所) |

**Patterns を使う間は、DIP スイッチの 1 と 2 を OFF にしておく。** ON のままだと、AD3 が H を出したピンが
スイッチを通って GND につながる (5-3 と同じ)。

ピンの電圧は a・b の値と逆になる (L が 1)。Patterns の 2 本が H・H → H・L → L・H → L・L と進むと、
a・b は 00 → 01 → 10 → 11 と進む。5 ms ごとに 1 通りずつ、20 ms で 4 通りを 1 周する。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 a・b が 4 通りを回り、AND は 11 のときだけ、OR は 00 のとき以外で H
device: ad3
time: 4ms/div
sample: 100kHz
signals:
  GP17: dio0 pattern 11001100 bit 5ms
  GP16: dio1 pattern 10101010 bit 5ms
  GP14: dio2 pattern 00010001 bit 5ms
  GP15: dio3 pattern 01110111 bit 5ms
cursors: [7.5ms, 17.5ms]
trigger: GP17 falling at 10ms
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/04-dip-and-or.svg)

- GP17・GP16 は入力のピン (L が 1)、GP14・GP15 は出力のピン (H が 1)
- 入力から出力までの遅れは 0 と置いて描いた (5-3 と同じ。遅れの測り方は 5-3 の表)
- Patterns の 2 本の位相 (どちらから始まるか) は、図と実機で違うことがある。そのときも、カーソルの所の 4 本の組は下の表と同じになる
- カーソル X1 (7.5 ms) は a = 0・b = 1、X2 (17.5 ms) は a = 1・b = 1 の真ん中に置いた

## 見るべき値

PC で回した結果と、見えるはずの画面の読み。実機では測っていない。

| a (SW1) | b (SW2) | GP17 | GP16 | D1 (AND、GP14) | D2 (OR、GP15) | 基板の LED (NOT、GP25) |
| --- | --- | --- | --- | --- | --- | --- |
| OFF (0) | OFF (0) | H | H | 消える | 消える | 点く |
| OFF (0) | ON (1) | H | L | 消える | 点く | 点く |
| ON (1) | OFF (0) | L | H | 消える | 点く | 消える |
| ON (1) | ON (1) | L | L | 点く | 点く | 消える |

| 測る所 | 見るべき値 | 分かること |
| --- | --- | --- |
| DIP スイッチを手で 4 通り | 上の表のとおりに LED が点く (PC で回した結果) | `gates.v` が Pico 2 の上で 1-1 と同じに働く |
| Logic のカーソル X1 (7.5 ms) | GP17 = 1、GP16 = 0、GP14 = 0、GP15 = 1 (図4) | a = 0・b = 1 で AND は 0、OR は 1 |
| Logic のカーソル X2 (17.5 ms) | GP17 = 0、GP16 = 0、GP14 = 1、GP15 = 1 (図4) | a = 1・b = 1 で AND も OR も 1 |
| Logic の ΔX | 10.00 ms (図4) | カーソルの間は 2 通りぶん |

組み合わせ回路でも、Pico 2 の上では主ループが読んで計算して書くまで出力は変わらない。
FPGA のゲートなら入力が変われば ns (ナノ秒) の桁で出力が変わるのと比べると、ここが Soft-FPGA の違いである。
どれだけ違うかは、5-3 の表の手順で遅れを測ると分かる。

## 出典

自作。`gates.v` と論理図は 1-1。DIP スイッチを GND に落として内蔵プルアップで読む形は
[tommie-jp/Soft-FPGA-TD4](https://github.com/tommie-jp/Soft-FPGA-TD4) の `verilator-TD4/main.cpp`。
内蔵プルダウンの不具合と 8.2 kΩ 以下という値は Raspberry Pi の
[RP2350 Datasheet](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) の付録 D.5.1 RP2350-E9。
Pico 2 の基板の LED が GP25 であることは Soft-FPGA-TD4 の `main.cpp` (`LED_PIN = 25`) と、Pico SDK 2.2.0 の `src/boards/include/boards/pico2.h` (`PICO_DEFAULT_LED_PIN 25`)。
