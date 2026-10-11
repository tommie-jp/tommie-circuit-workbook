---
book: fpga
chapter: 5
id: 5-14
title: USB シリアルで内部の信号を出す
tier: 100
source: 自作
board: BB
device: PICO
---

# 5-14 USB シリアルで内部の信号を出す

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 のプログラムは `.uf2` までのビルドを確かめたが、書き込んで動かしてはいない。
> 表示の行は PC の Verilator で同じ回路を回した値。USB シリアルを出したときの 1 クロックの時間は**測っていない**。
> 「見るべき値」の空欄は、測って書き込む。

Logic で見られるのは、ピンに出した信号だけ。TD4 の PC (命令の番地) や、いま実行中の命令 (`op`) のような**回路の内部の値**は、
ピンに出さない限り見えない。この題では、内部の値を USB のシリアルに**字で**出す。
Pico 2 は USB の CDC (仮想のシリアルポート) として見え、PC の端末ソフトで読める。配線は USB ケーブルだけで増えない。

代わりに、**字を送る時間が 1 クロックに足される**。1 クロックに 1 行出すと、クロックは 5-5 で測った値より大きく遅くなるはずで、
その大きさを同じ測り方 (AUX の周期 ÷ 2000) で測り直す。

| 決め | 内容 |
| --- | --- |
| 回路 | 5-8 の TD4 (プログラム A)。`TD4.v` の出力ポートの `pc_out`・`op`・`out_port` を字にする |
| 出す形 | `<立ち上がりの回数> pc=<PC> op=<命令 2 桁> out=<OUT>`。1 行に 1 クロック |
| SW1 OFF | 1 クロックごとに 1 行 |
| SW1 ON | 1000 クロックごとに 1 行 (出す回数を減らす) |
| CLK のピン (GP16) | 主ループで立ち上がりの前に H、立ち下がりの前に L (5-5 と同じ) |
| AUX のピン (GP17) | 1000 クロックごとに反転 (5-5 と同じ)。AUX の周期 ÷ 2000 が 1 クロックの平均 |

## 出す行の読み方

PC の Verilator で同じ `TD4.v` を回し、リセットのあとの立ち上がりごとに同じ形で出した行 (12 行)。

```text
1 pc=1 op=B6 out=3
2 pc=2 op=BC out=6
3 pc=3 op=B8 out=C
4 pc=4 op=B8 out=8
5 pc=5 op=BC out=8
6 pc=6 op=B6 out=C
7 pc=7 op=B3 out=6
8 pc=8 op=B1 out=3
9 pc=9 op=F0 out=1
10 pc=0 op=B3 out=1
11 pc=1 op=B6 out=3
12 pc=2 op=BC out=6
```

- `pc` は立ち上がりのあとの番地、`op` はその番地の ROM の命令 (8 ビット)。`out` は `OUT` 命令が書いた出力ポート。5-8 の LED の並び (3・6・C・8・8・C・6・3・1・1) と同じ
- 9 行めの `op=F0` は `JMP 0000`。次の行で `pc=0` に戻る。`JMP` は `OUT` を書かないので、10 行めの `out` は 9 行めと同じ 1
- 命令の読み方は 5-8 の「TD4 の命令」。`B` で始まる命令は `OUT <4 ビットの値>`

## 回路図

図1・図2 は 5-5 と同じ。USB ケーブルは Pico 2 の給電と、シリアルの両方を兼ねる。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/14-usb-serial.svg)

- 配線は 5-5 と同じ。DIP スイッチ SW1 が表示の頻度、SW2〜SW4 が TD4 の IN に入る (プログラム A は IN を読まない)
- AD3 は GP16 (CLK) と GP17 (AUX)、GP18〜GP21 (OUT の写し) を読む

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/breadboard/14-usb-serial.svg)

- 配線は 5-5 と同じ。PC につなぐのは Pico 2 の USB コネクタ (図の左端)。AD3 は上、LED は左、DIP スイッチは右
- DIP スイッチは下の列の左から 4・3・2・1。**右端が SW1**

## 部品表

5-5 と同じ (Pico 2、330 Ω (オーム) の抵抗 4 本、赤の LED 4 個、4 連の DIP スイッチ、full のブレッドボード、AD3)。USB ケーブル (PC 側の端子による) が 1 本いる。
電源は USB の 5 V から Pico 2 が 3.3 V を作る。GPIO は 3.3 V (0-3)。

## Pico 2 のプログラム

作業用のフォルダは 5-5 と共通で、`board.h` と `TD4.v` は 5-8 のまま。ビルドの打ち方は [5-1 の「ビルドする」](01-verilator-on-pico.md#ビルドする)。

`serial514.cpp`:

```cpp
// 5-14 USB シリアルで内部の信号を出す — TD4 の PC・命令・OUT を字で出す
#include <stdio.h>
#include "board.h"
#include "VTD4.h"

static VTD4 top;

int main() {
    stdio_init_all();               // USB の CDC を起こす (CMake で USB を有効にしてある)
    board_init();

    top.reset_n = 0;
    top.clock = 0; top.eval();
    top.clock = 1; top.eval();
    top.clock = 0; top.eval();      // 立ち下がりに戻してからリセットを放す
    top.reset_n = 1;

    unsigned n = 0;
    unsigned long long total = 0;   // 立ち上がりの回数
    while (true) {
        const unsigned every = (read_sw() & 0x8u) ? 1000u : 1u;   // SW1 ON: 1000 クロックに 1 行
        top.in_port = read_sw() & 0x7u;
        gpio_put(PIN_CLK, 1);
        top.clock = 1; top.eval();
        put_leds(top.out_port);
        total++;
        if (++n >= every) {
            n = 0;
            printf("%llu pc=%X op=%02X out=%X\n", total, top.pc_out, top.op, top.out_port);
        }
        gpio_put(PIN_CLK, 0);
        top.clock = 0; top.eval();
        if ((total % 1000u) == 0) gpio_xor_mask(1u << PIN_AUX);
    }
}
```

`CMakeLists.txt` の最後に次の 3 行を足す。`pico_enable_stdio_usb` が USB の CDC を有効にし、`pico_enable_stdio_uart` が既定の UART を止める
(5-13 の表のとおり、`printf` の出る先は stdio の設定で決まる)。

```cmake
add_soft_fpga(serial514 serial514.cpp td4)
pico_enable_stdio_usb(serial514 1)
pico_enable_stdio_uart(serial514 0)
```

- `printf` は**主ループの中だけ**で呼ぶ。5-7 のタイマ割り込みの中では呼ばない。USB の出力は、PC が読むのを待つ間に時間を使い (最大 0.5 s)、
  割り込みの中でそれをすると 5-9 の「間に合わない」に直結する (Pico SDK の `stdio_usb.c` を読んだ)
- PC の端末ソフトを開いていないとき、出力は**すぐ捨てられる** (`stdio_usb_connected()` が偽の間は何もしない)。端末を開く前の行は読めない。
  端末を開いてから Pico 2 をリセットするか、最初の行を急がない作りにする
- 端末を開いているのに読まないとき (表示が止まっているとき) は、最大 0.5 s 待ってから捨てる。**1 行ごとに 0.5 s の待ちになる**ことはない (1 度待って捨てたあとは、読み出されるまでの間は書かずに捨てる。ソースの読み)

### 手元のビルド環境の注意

5-1 の `wb-pico-sdk` には TinyUSB (USB の部品) が入っていない。CMake が「TinyUSB submodule has not been initialized; USB support will be unavailable」と警告し、
`pico_enable_stdio_usb` を書いても**黙って USB が付かない**。USB が付いたことは、`.uf2` の大きさで確かめられる (下の表)。

TinyUSB 入りの Pico SDK (`git clone --recurse-submodules`、または `git submodule update --init`) を使う。ここでは手元の Pico SDK 2.2.0 を `-v ... :/psdk:ro`
でコンテナに渡して、`PICO_SDK_PATH=/psdk` でビルドした。

```bash
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD":/work -v "$HOME/pico-sdk":/psdk:ro -w /work -e PICO_SDK_PATH=/psdk wb-pico-sdk \
  bash -c 'cp /psdk/external/pico_sdk_import.cmake . && cmake -S . -B build_usb -DPICO_BOARD=pico2 && cmake --build build_usb --target serial514'
```

`build_usb/serial514.uf2` (123 392 バイト) ができた (Verilator 5.048、Pico SDK 2.2.0)。`arm-none-eabi-size` は text 65 272 バイト、bss 4 948 バイト。
USB を付けない `build/serial514.uf2` は 95 232 バイト、text 51 432 バイトで、**USB の部品が text を約 14 KB、bss を約 2.6 KB 増やす**。**実機では動かしていない。**

## 端末で読む

| 環境 | 開き方 |
| --- | --- |
| Linux | `ls /dev/ttyACM*` で出た名前に、`screen /dev/ttyACM0 115200` (または `minicom`)。USB の CDC なので速度の数は無視される |
| Windows | デバイスマネージャーで COM 番号を見て、Tera Term などで開く |

行が流れ始めたら成功。SW1 を ON にすると、行が 1000 クロックに 1 行になる (クロックが速ければ、行は読めない速さで流れる)。

## 計器の設定

計器は AD3 の Logic。5-6 と同じ測り方で、AUX の周期から 1 クロックの平均を出す。

| 計器 | 設定 |
| --- | --- |
| Logic | DIO1 (AUX)・DIO0 (CLK) を Enable。標本化は AUX の 2 周期が窓 (32 768 標本) に入る値。回路・SW1 を替えるたびに、窓に 2 周期入るように合わせ直す |
| Logic のトリガ | DIO1 の立ち上がり |
| カーソル | X1 と X2 を、続く 2 つの H の真ん中に置く。ΔX が 2000 クロック。ΔX ÷ 2000 が 1 クロックの平均 |
| 端末 | 端末ソフトを**開いた状態と閉じた状態**の両方で測る。閉じていれば出力が捨てられるので、`printf` の時間が短くなる (見込み) |

## Logic に見えるはずの画面

図3 は、シリアルの `out=` の並びを Logic で見たもの。TD4 の OUT (DIO5〜DIO2 を 1 本のバスにして 16 進で見る) は、上の 12 行の `out=` と同じ並びになる。
**時間の目盛は仮** (1 クロックを 1 ms と置いた。実機の 1 クロックは、シリアルを出すと 5-5 の値より長くなる)。

```logic
title: 図3 シリアルの out= と同じ並びが、OUT のバスに出る (1 クロックを 1 ms と置いた仮の目盛)
device: ad3
time: 1200us/div
start: -100us
sample: 1MHz
signals:
  CLK: dio0 clock 1kHz
  MON3: dio5 pattern 000111100000011110000 bit 1ms from -1ms
  MON2: dio4 pattern 001100110000110011000 bit 1ms from -1ms
  MON1: dio3 pattern 011000011001100001100 bit 1ms from -1ms
  MON0: dio2 pattern 010000001111000000111 bit 1ms from -1ms
buses:
  OUT: MON3 MON2 MON1 MON0 hex
cursors: [250us, 10.25ms]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/14-usb-serial.svg)

- OUT のバスは立ち上がりのたびに書き直される。`8` が 2 クロック続くのは `OUT 1000` が 2 つ並ぶため、`1` が 2 クロック続くのは `JMP 0000` では OUT が変わらないため (5-8 と同じ)
- シリアルの行は、`out=` の値だけでなく `pc` と `op` も出す。Logic に出していない**内部の値**が、字で読める

## 見るべき値

**測っていない。測って空欄を埋める。** 数を決め打たないのは、この冊の決め (1 クロックの時間は実測してから書く)。

| 測る所 | 見るべき値 | 分かること |
| --- | --- | --- |
| 端末の行の並び | 上の 12 行と同じ (Verilator の値) | 内部の値が字で読める。`out=` が LED と合う |
| SW1 ON (1000 クロックに 1 行) の 1 クロック | (測って書く) µs (マイクロ秒) | シリアルの出力の頻度を減らしたときの 1 クロック |
| SW1 OFF (1 クロックに 1 行) の 1 クロック | (測って書く) µs | 毎クロック字を出したときの 1 クロック。SW1 ON より長いはず (見込み) |
| 5-5 で測った `counter8` の 1 クロック | (5-5 の値) µs | 比べる基準。TD4 とカウンタは回路が違うので、5-6 の TD4 の値と比べる |
| 端末を閉じたときの 1 クロック | (測って書く) µs | 出力が捨てられるときの時間 |
| 端末を開いたまま読まない (止めた) ときの 1 クロック | (測って書く) µs | 0.5 s の待ちが入るか |

見るとよいこと:

- 行を出すと 1 クロックがどれだけ長くなるか。**回路の計算 (5-6) より字を送る時間のほうが大きい**かどうか
- 1000 クロックに 1 行にすると、1 クロックが 5-6 の値にどこまで戻るか
- 速さの数を測る道具としては、このプログラムは Logic で測る値を**変えてしまう**。**測るときは SW1 を ON、または USB シリアルを付けないビルド (5-6) で測る**

## 出典

自作。TD4 は 5-8 ([Soft-FPGA-TD4](https://github.com/tommie-jp/Soft-FPGA-TD4))。USB の CDC は Raspberry Pi の Pico SDK の `pico_stdio_usb`
(`stdio_usb.h`・`stdio_usb.c`、SDK 2.2.0) と、`pico_enable_stdio_usb` / `pico_enable_stdio_uart` の CMake 関数。行の値は PC の Verilator 5.042 で回した。
