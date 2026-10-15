---
book: fpga
chapter: 5
id: 5-6
title: 回路の規模でクロックは変わる — カウンタと TD4 で比べる
tier: 50
source: 自作
board: BB
device: PICO
---

# 5-6 回路の規模でクロックは変わる — カウンタと TD4 で比べる

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 のプログラムは `.uf2` までのビルドを確かめたが、書き込んで動かしてはいない。
> Pico 2 での 1 クロックの時間は**測っていない**。表の PC の値は、PC (x86) で同じ回路を回して測った参考値で、Pico 2 の値ではない。

5-5 で、Soft-FPGA の 1 クロックは「`eval()` の計算にかかった時間」だと分かった。計算の量は回路で変わるので、
**回路を替えると 1 クロックの長さも変わる**。この題では、5 つの回路を同じプログラムに入れ、DIP スイッチで切り替えて比べる。

| SW1 | SW2 | SW3 | 回路 | 題 |
| --- | --- | --- | --- | --- |
| OFF | OFF | OFF | 8 ビットのカウンタ (`counter`、W = 8) | 2-4 |
| OFF | OFF | ON | 32 ビットのカウンタ (`counter`、W = 32) | 2-4 |
| OFF | ON | OFF | 4 ビット CPU の TD4 | 5-8 |
| OFF | ON | ON | 1 Hz の点滅 (`blink`、CLK_HZ = 1000) | 2-7 |
| ON | どちらでも | どちらでも | 32 ビットのカウンタを 256 本並べた回路 (`many`、N = 256) | この題 |

測り方は 5-5 と同じ。GP16 (CLK) が 1 クロックで 1 往復し、GP17 (AUX) が 1000 クロックごとに反転する。
この題では AUX の周期を読み、2000 で割って 1 クロックの平均を出す。CLK を 1 周期だけ読むより、ばらつきが均される。

## 回路図

図1・図2 は 5-5 と同じ。DIP スイッチの SW1〜SW3 で回路を選ぶ。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/06-clock-vs-size.svg)

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/breadboard/06-clock-vs-size.svg)

- 配線は 5-5 と同じ。DIP スイッチは下の列の左から 4・3・2・1 なので、**右端が SW1**
- AD3 は DIO1 (AUX) を主に読む。DIO0 (CLK) も挿したままでよい

## 部品表

5-5 と同じ (Pico 2、330 Ω の抵抗 4 本、赤の LED 4 個、4 連の DIP スイッチ、full のブレッドボード、AD3)。
電源は 3.3 V (Pico 2 の GPIO)。5 V を入れないのは 0-3 と同じ理由。

## 比べる回路

`counter.v` は 2-4、`blink.v` は 2-7 のものをそのまま使う。`TD4.v` は 5-8 に載せる。新しく書いたのは `many.v` だけ。

`many.v`:

```verilog
// N 本の 32 ビットのカウンタを並べ、全部の XOR を出す (回路の規模を N で変える)
module many #(
    parameter N = 16
) (
    input         clk,
    input         rst,
    output [31:0] sum
);
    reg [31:0] r [0:N-1];
    reg [31:0] x;
    integer i;

    always @(posedge clk)
        for (i = 0; i < N; i = i + 1)
            if (rst) r[i] <= 32'd0;
            else     r[i] <= r[i] + i[31:0] + 32'd1;

    always @(*) begin
        x = 32'd0;
        for (i = 0; i < N; i = i + 1) x = x ^ r[i];
    end

    assign sum = x;
endmodule
```

- `N` 本の 32 ビットのレジスタが、クロックごとに自分の番号 + 1 ずつ増える。全部の XOR を `sum` に出すので、どのレジスタも省けない
- 規模を大きくした回路を 1 つ入れたのは、上の 4 つの規模が小さく、差が出にくいため (下の PC の参考値)

lint は 4 つとも警告 0 件で通った (Verilator 5.042 と 5.048 の `--lint-only -Wall`、`counter.v` は `-GW=8` と `-GW=32`、`blink.v` は `-GCLK_HZ=1000`、`many.v` は既定の N = 16)。
5-5 の `verilate.sh` は `many.v` を `-GN=256` で C++ にする。

## Pico 2 のプログラム

作業用のフォルダは 5-5 と共通で、`board.h` `verilate.sh` `CMakeLists.txt` も 5-5 のまま。ビルドの打ち方は [5-1 の「ビルドする」](01-verilator-on-pico.md#ビルドする)。
5 つの回路をまとめる `models.h` と、主ループの `clock56.cpp` を足す。

`models.h`:

```cpp
// models.h — 5-6・5-7 で選ぶ 5 つの回路
#pragma once
#include "board.h"
#include "Vcounter8.h"
#include "Vcounter32.h"
#include "VTD4.h"
#include "Vblink.h"
#include "Vmany.h"

// SW1〜SW3 で選ぶ (ON = 1、SW1 が上の桁)
//   0 = 8 ビットのカウンタ、1 = 32 ビットのカウンタ、2 = TD4、
//   3 = 2-7 の blink (CLK_HZ = 1000)、4〜7 = 32 ビットのカウンタ 256 本
inline unsigned read_sel() { return read_sw() >> 1; }

class Models {
public:
    void reset() {
        c8.rst = 1; c32.rst = 1; blk.rst = 1; big.rst = 1; td4.reset_n = 0;
        for (unsigned s = 0; s < 5; s++) { edge(s, 0); edge(s, 1); }
        c8.rst = 0; c32.rst = 0; blk.rst = 0; big.rst = 0; td4.reset_n = 1;
    }
    // 選んだ回路のクロックを clk にして eval する。立ち上がりのあと LED を書く
    void edge(unsigned sel, unsigned clk) {
        switch (sel) {
        case 0: c8.clk = clk;    c8.eval();  if (clk) put_leds(c8.count >> 4);  break;
        case 1: c32.clk = clk;   c32.eval(); if (clk) put_leds(c32.count >> 4); break;
        case 2: td4.clock = clk; td4.eval(); if (clk) put_leds(td4.out_port);  break;
        case 3: blk.clk = clk;   blk.eval(); if (clk) put_leds(blk.led);       break;
        default: big.clk = clk;  big.eval(); if (clk) put_leds(big.sum >> 4);  break;
        }
    }
private:
    Vcounter8  c8;
    Vcounter32 c32;
    VTD4       td4;
    Vblink     blk;
    Vmany      big;
};
```

`clock56.cpp`:

```cpp
// 5-6 回路の規模でクロックは変わる — 5 つの回路を同じ測り方で空回しする
#include "models.h"

int main() {
    board_init();
    static Models m;
    m.reset();

    unsigned n = 0;
    while (true) {
        const unsigned sel = read_sel();
        gpio_put(PIN_CLK, 1);
        m.edge(sel, 1);
        gpio_put(PIN_CLK, 0);
        m.edge(sel, 0);
        if (++n == 1000) {          // 1000 クロックごとに AUX を反転 (5-5 と同じ)
            n = 0;
            gpio_xor_mask(1u << PIN_AUX);
        }
    }
}
```

- 主ループの形は 5-5 と同じ。違いは、回る前に DIP スイッチを読み、選んだ回路の `eval()` だけを呼ぶこと
- DIP スイッチを読む・`switch` で分ける手間は、どの回路でも同じだけ 1 クロックに足される。比べるのは回路どうしの差
- 選ばれていない回路は止まっている (クロックが来ない)

5-5 と共通のフォルダを空から作ってビルドし、`build/clock56.uf2` (107 008 バイト) ができた。**実機では動かしていない。**

## 回路の規模 (計算と PC の参考値)

規模は yosys 0.33 の `synth_gowin` (Tang Nano 9K の FPGA 向け) で数えた。PC の値は、同じ Verilog を Verilator 5.048 (`-O3`、`sfa-dev`) で C++ にし、
g++ (`-O2`) で組んで PC (Intel Core Ultra 9 285K) で回した、立ち上がりと立ち下がりの `eval()` 2 回の平均。

| 回路 | FF | LUT・MUX | 加算の段 (ALU) | PC で 1 クロック (参考) |
| --- | --- | --- | --- | --- |
| 8 ビットのカウンタ | 8 | 0 | 8 | 約 29 ns |
| 32 ビットのカウンタ | 32 | 0 | 32 | 約 32 ns |
| TD4 | 12 | 58 | 8 | 約 31 ns |
| `blink` (CLK_HZ = 1000) | 10 | 7 | 9 | 約 29 ns |
| `many` (N = 16) | — | — | — | 約 30 ns |
| `many` (N = 256) | 8192 (計算: 32 × 256) | — | — | 約 1290 ns |

- PC の値は 3 回ずつ測った (2000 万クロックずつ。N = 256 は 100 万クロック)。ばらつきは 1〜2 ns ほどあった
- **小さな回路 4 つの差は PC ではほとんど出なかった。** `eval()` を呼ぶこと自体の手間が大きく、回路の計算はその陰に隠れると考えられる。
  8 ビットと 32 ビットのカウンタは、どちらも 32 ビットの CPU の足し算 1 回で済む
- TD4 の `TD4.v` にはレジスタが 17 ビットあるが、合成の結果は FF 12 個だった。ROM の中身が決まっているので、合成で一部が省かれたと考えられる (どれが省かれたかは確かめていない)
- `many` は N = 16 から 256 で 1 クロックが 40 倍以上になった。回路が大きくなると、計算の量がそのまま 1 クロックに出る
- `many` (N = 256) は yosys で合成していない。FF の数は Verilog から数えた

Pico 2 の CPU (Cortex-M33、既定 150 MHz) は PC と速さも作りも違うので、**PC の値の比がそのまま Pico 2 の比になるとは限らない**。Pico 2 の列は下の表に測って書く。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Logic | DIO1 (AUX) を Enable。標本化は AUX の 2 周期が窓 (32 768 標本) に入る値。図3 の仮の目盛なら 100 kHz |
| Logic のトリガ | DIO1 の立ち上がり |
| カーソル | X1 と X2 を、続く 2 つの H の真ん中に置く。ΔX が 2000 クロック |
| 切り替え | DIP スイッチを替えたら、トリガをかけ直して撮り直す。回路ごとに 1 枚 |

AUX は 1000 クロックで反転するので、ΔX ÷ 2000 が 1 クロックの平均。回路を替えると AUX の周期も変わるので、窓に 2 周期入るように時間軸を合わせ直す。

## Logic に見えるはずの画面

**図3 の目盛は仮** (1 クロックを 10 µs と置き、AUX の周期を 20 ms として描いた)。測っていない数を描かないため、5 つの回路を並べた図は載せない。
同じ画面を回路ごとに撮り、ΔX を下の表に書く。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 AUX は 1000 クロックで反転する。周期 ÷ 2000 が 1 クロック (仮の目盛)
device: ad3
time: 5ms/div
start: -5ms
sample: 100kHz
signals:
  AUX: dio1 clock 50Hz
cursors: [5ms, 25ms]
trigger: AUX rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/06-clock-vs-size.svg)

## 見るべき値

**測っていない。測って空欄を埋める。**

| 回路 (SW1 SW2 SW3) | AUX の周期 (ΔX) | 1 クロック (ΔX ÷ 2000) | クロックの周波数 |
| --- | --- | --- | --- |
| 8 ビットのカウンタ (OFF OFF OFF) | (測って書く) | (測って書く) µs | (測って書く) kHz |
| 32 ビットのカウンタ (OFF OFF ON) | (測って書く) | (測って書く) µs | (測って書く) kHz |
| TD4 (OFF ON OFF) | (測って書く) | (測って書く) µs | (測って書く) kHz |
| `blink` (OFF ON ON) | (測って書く) | (測って書く) µs | (測って書く) kHz |
| `many` N = 256 (ON) | (測って書く) | (測って書く) µs | (測って書く) kHz |

見るとよいこと:

- 8 ビットのカウンタの値が、5-5 で測った値と近いか。この題の主ループは DIP スイッチを読む分だけ長いはず
- 小さな 4 つの回路の差が、PC と同じように小さいか
- `many` で 1 クロックがどれだけ伸びるか。5-7 でクロックを固定するとき、周期はいちばん重い回路の 1 クロックより長くとる必要がある (5-9)

## シミュレーションでの確かめ (対象外を含む)

yosys 0.33 (`synth_gowin`)、Verilator 5.042、手元の Pico SDK 2.2.0 で確かめた。`counter.v` (2-4)・`blink.v` (2-7)・`TD4.v` (5-8) と本文の `many.v`・
`models.h`・`clock56.cpp` を使った。主ループの切り替えは替え玉の GPIO で PC で回した (`sim/06-clock-vs-size.v`・`sim/06-clock-vs-size-pc.cpp`)。
`.uf2` と `arm-none-eabi-size` の値は、本文の Docker イメージ (`sfa-dev:local` の Verilator 5.048 と `wb-pico-sdk` の Pico SDK 2.2.0、`arm-none-eabi-gcc` 13.2.1) で、本文の `.cpp` と `.v` からビルドし直した値。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint (4 つ、`-GW=8/32`、`-GCLK_HZ=1000`、既定の N = 16、`-GN=256`) | 警告 0 件 | 警告 0 件 | 合った |
| 8 ビットのカウンタ FF / LUT・MUX / ALU | 8 / 0 / 8 | DFFR 8、ALU 8、LUT 0 | 合った |
| 32 ビットのカウンタ | 32 / 0 / 32 | DFFR 32、ALU 32、LUT 0 | 合った |
| TD4 | 12 / 58 / 8 | FF 12 (DFFC 4 + DFFCE 8)、LUT 46 + MUX2 12 = 58、ALU 8 | 合った |
| `blink` (CLK_HZ = 1000) | 10 / 7 / 9 | FF 10 (DFFR 9 + DFFRE 1)、LUT 6 + MUX2 1 = 7、ALU 9 | 合った |
| `many` (N = 256) の FF | 8192 (計算: 32 × 256) | 計算どおり (yosys では合成していない) | 計算値として合った |
| `many` (N = 16) | 表では「—」 | 参考: FF 497、ALU 497、LUT4 431 (合成で一部が省かれる) | 参考 |
| DIP の選択 (SW1〜SW3 → 回路) | 000 = counter8、001 = counter32、010 = TD4、011 = blink、1xx = many | `read_sel()` で 0・1・2・3・4 になり、それぞれの回路が回った | 合った |
| AUX の周期 | 1000 クロックごとに反転 | 4000 周で 4 回 (どの回路も) | 合った |
| `.uf2` の大きさ | 107 008 バイト | 107 008 バイト | 合った |
| PC で 1 クロック (3 回ずつの平均) | 約 29・32・31・29・30・1290 ns (本表の並び) | `sfa-dev` の Verilator 5.048 (`-O3`) と g++ (`-O2`) で Core Ultra 9 285K に回した値をそのまま書いた (28.7・32.4・31.6・28.8・29.6・1288 ns) | 合った |

### エミュレータ (picoemu) での確かめ

picoemu (`danish9661/pico-emulator` の `b83786f` に `sim/picoemu-m33.patch` を当てた版。手順は [5-2](02-counter-led.md#エミュレータ-picoemu-での確かめ)) に `clock56.uf2` (回路 5 つ) を載せ、Cortex-M33 で動かした。入力は `-script` で与えた (ms 刻み)。
確かめは `python3 sim/picoemu-check.py --picoemu ./picoemu --uf2 <.uf2 を集めたフォルダ> 5-6`。picoemu は機能の模型で、周期・ジッタ・周波数の実時間は対象外にした。

| 項目 | 本文の数字 | picoemu の結果 | 判定 |
| --- | --- | --- | --- |
| DIP の選択 | 000 = counter8、001 = counter32、010 = TD4、011 = blink、1xx = many | DIP を `-script` で与えると 5 つとも回り、LED が回路どおりに変わる (counter8・32 は `count[7:4]`、blink は 500 クロックごとに反転、TD4 は OUT が 3・6・C・8・C・6・3・1 と変わり、many は 256 本の XOR の `sum[7:4]`) | 合った |
| AUX の周期 | 1000 クロックごとに反転 | 5 つの回路とも 1000・2000・3000 クロック目 | 合った |
| 規模と 1 クロックの長さ | many が桁違いに遅い (PC では約 43 倍) | 100 万命令あたりのクロック数 は counter8 約 3 700、many 約 108 (命令数で約 34 倍) | 参考 (向きが合う) |
| 1 クロックの時間・周波数 | 測って書く | 模型の値しか出ない | 対象外 (実時間) |

確かめられなかったもの。

- Pico 2 での 1 クロックの時間 (実機)。「見るべき値」の表は空のまま

## 出典

自作。TD4 は [Soft-FPGA-TD4](https://github.com/tommie-jp/Soft-FPGA-TD4) (元は asfdrwe の [simpleTD4](https://github.com/asfdrwe/simpleTD4)、MIT) を 5-8 で直したもの。
合成は [Yosys](https://yosyshq.net/yosys/) の `synth_gowin`。
