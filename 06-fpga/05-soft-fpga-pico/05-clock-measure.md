---
book: fpga
chapter: 5
id: 5-5
title: Soft-FPGA のクロックを測る — 1 クロックに何 µs かかるか
tier: 50
source: 自作
board: BB
device: PICO
---

# 5-5 Soft-FPGA のクロックを測る — 1 クロックに何 µs かかるか

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 のプログラムは `.uf2` までのビルドを確かめたが、書き込んで動かしてはいない。
> 1 クロックの時間 (µs) とクロックの周波数は**測っていない**。「見るべき値」の表の空欄は、測って書き込む。

FPGA のクロックは水晶の発振器が決める。27 MHz の発振器なら、回路が大きくても小さくても 1 クロックは 37 ns (ナノ秒) で変わらない。

Soft-FPGA は違う。Pico 2 の CPU が、Verilator の作った C++ (`eval()`) を呼んで、回路の 1 クロック分を**計算する**。
計算が終わると次のクロックに進むので、**1 クロックの長さは計算にかかった時間**になる。
5-2 で LED の点滅が 1 Hz にならなかったのはこのためで、クロックの周波数をだれも決めていない。

この題では、その長さを測る。回路は 2-4 の 8 ビットのカウンタ。主ループを 1 周するたびに GP16 を H → L と動かし、AD3 の Logic で周期を読む。

| 決め | 内容 |
| --- | --- |
| 1 クロック | 立ち上がりの `eval()` と立ち下がりの `eval()` の 2 回。間に LED の書き込みが入る |
| CLK のピン (GP16) | 立ち上がりの `eval()` の直前に H、立ち下がりの `eval()` の直前に L。周期が 1 クロック |
| AUX のピン (GP17) | 1000 クロックごとに反転する。周期は 2000 クロックで、平均の長さを読むのに使う |
| LED (GP2〜GP5) | `count[7:4]`。速く変わるので、目には薄く点いて見えるはず (確かめていない) |

この章の 5-5〜5-8 は同じブレッドボードで組む。図1・図2 は 4 題で共通にしてある。

## 回路図

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/05-clock-measure.svg)

- Pico 2 の右側のピン (GP2〜GP13) に LED と DIP スイッチ、左側のピン (GP16〜GP21) に AD3 をつなぐ
- LED は GP2 が上の桁 (bit3)、GP5 が下の桁 (bit0)。Soft-FPGA-TD4 の `main.cpp` と同じ割り当て
- DIP スイッチはスイッチ 1〜4 を GP10〜GP13 につなぎ、反対側を GND に落とす。プルアップ抵抗は付けず、Pico 2 の内蔵プルアップを使う。ON で L になる
- AD3 は GP16 (CLK)・GP17 (AUX)・GP18〜GP21 を読む。GP18〜GP21 にはプログラムが LED と同じ値を出す (`board.h`)。LED の線に直接つながず、別のピンに写すのは、ブレッドボードの配線が交差しないようにするため
- 電源は Pico 2 の USB から取る。ブレッドボードに電源は配らない。LED は GPIO の 3.3 V で光らせる

## 部品表

| 部品 | 値・型番 | 数 | 役 |
| --- | --- | --- | --- |
| U1 | Raspberry Pi Pico 2 | 1 | Soft-FPGA を動かす |
| R1〜R4 | 330 Ω (オーム) (E24)、1/4 W | 4 | LED の電流を決める |
| D1〜D4 | 5 mm 砲弾型の赤の LED | 4 | OUT3〜OUT0 |
| SW1 | 4 連の DIP スイッチ | 1 | 入力 (5-6〜5-8 で使う) |
| — | ブレッドボード (full、63 列) | 1 | |
| — | ジャンパ線 | 約 25 本 | |
| AD | Analog Discovery 3 | 1 | Logic で測る |

電源は教科書の既定の 5 V ではなく **3.3 V** (Pico 2 の GPIO)。Pico 2 のピンに 5 V を入れると壊れるため (0-3)。
LED の電流は、赤の LED の順方向電圧を 2 V とすると (3.3 − 2) ÷ 330 ≒ 4 mA (計算値)。

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/breadboard/05-clock-measure.svg)

- `pico2 @ g15` は USB を左に向け、下の列 (g 行) に 1〜20 番ピンを挿す。1 番 (GP0) が 15 列、20 番 (GP15) が 34 列。下に h・i・j の 3 行が空くので、LED と DIP スイッチへの線を行ごとに分けて引ける
- 上の列 (b 行) は 40 番 (15 列) から 21 番 (34 列) へ並ぶ。AD3 の線は a 行から取る (GP21 が 28 列、GP16 が 34 列)
- LED の抵抗は溝をまたいで縦に挿す (g 行 → c 行)。LED のカソードは上の − レールへ落とす
- **LED は左から OUT0・OUT1・OUT2・OUT3** (左が下の桁)。線が交差しないように、Pico 2 に近いピン (GP2) を近い LED へつないだ
- DIP スイッチは向きを逆 (`r180`) に挿す。下の列 (f 行) は左からスイッチ 4・3・2・1。**左が下の桁**で、LED と同じ並びになる
- 上下の − レールは 1 列の黒の線でつなぐ。GND は Pico 2 の 8 番ピン (22 列) から下の − レールへ取る
- 線の色: 黄は LED への信号、青は DIP スイッチへの信号、緑は AD3 の DIO2〜DIO5、白は CLK (DIO0)、橙は AUX (DIO1)、黒は GND。赤は電源専用なので使わない
- 流れる電流は LED 1 個あたり約 4 mA で、4 個でも 20 mA に届かない。ブレッドボードの範囲に収まる

## Pico 2 のプログラム

プログラムは C++ (Pico SDK)。Verilator の出す C++ を Pico SDK から呼ぶので、この題は MicroPython では書かない。
ビルドの手順は 5-1 と同じ ([5-1 の「ファイル」と「ビルドする」](01-verilator-on-pico.md#ファイル))。
5-5〜5-8 は 1 つの作業用のフォルダを共通に使い、4 題の `.uf2` をまとめてビルドする。

### 作業用のフォルダに置くもの

| ファイル | 中身 | どこから |
| --- | --- | --- |
| `counter.v` | 8 ビットのカウンタ | 2-4 の `counter.v` そのまま |
| `board.h` | ピンの割り当てと、LED・DIP スイッチの読み書き | 下に載せる。5-6〜5-8 も同じものを使う |
| `clock55.cpp` | この題の主ループ | 下に載せる |
| `blink.v` `TD4.v` `many.v` と `clock56.cpp` ほか | 5-6〜5-8 の回路と主ループ | 2-7・5-6〜5-8。この題だけなら要らない |
| `verilate.sh` | Verilog を C++ にする手順。5-5〜5-8 の回路をまとめて変換する | 下に載せる |
| `CMakeLists.txt` | ビルドの設定 | 5-1 のもの。最後の行を下の 4 行に替える |
| `stub_mutex.h` `cxx_minimal.cpp` `verilated.cpp` `pico_tls.cpp` | Verilator のランタイムを Pico 2 で通すための部品 | 5-1 と同じ |

`board.h`:

```cpp
// board.h — 第 5 章 (5-5〜5-8) のピンの割り当て
#pragma once
#include "pico/stdlib.h"

constexpr uint PIN_OUT3 = 2;   // GP2〜GP5: LED。GP2 が bit3、GP5 が bit0
constexpr uint PIN_SW1  = 10;  // GP10〜GP13: DIP スイッチ 1〜4。ON で L
constexpr uint PIN_CLK  = 16;  // GP16: AD3 の DIO0 へ。Soft-FPGA のクロック
constexpr uint PIN_AUX  = 17;  // GP17: AD3 の DIO1 へ (題ごとに役を決める)
constexpr uint PIN_MON0 = 18;  // GP18〜GP21: LED と同じ値。AD3 の DIO2〜DIO5 へ

constexpr uint32_t MASK_OUT = 0xFu << PIN_OUT3;
constexpr uint32_t MASK_SW  = 0xFu << PIN_SW1;
constexpr uint32_t MASK_MON = 0xFu << PIN_MON0;

// 4 ビットの並びを逆にする (GP2 が bit3 なので)
inline unsigned rev4(unsigned v) {
    return ((v >> 3) & 1u) | ((v >> 1) & 2u) | ((v << 1) & 4u) | ((v << 3) & 8u);
}

inline void board_init() {
    const uint32_t out = MASK_OUT | MASK_MON | (1u << PIN_CLK) | (1u << PIN_AUX);
    gpio_init_mask(out | MASK_SW);
    gpio_set_dir_out_masked(out);
    for (uint p = PIN_SW1; p < PIN_SW1 + 4; p++) gpio_pull_up(p);
}

// 4 ビットを LED (GP2〜GP5) と AD3 用の GP18〜GP21 (GP18 が bit0) に出す
inline void put_leds(unsigned v) {
    v &= 0xFu;
    gpio_put_masked(MASK_OUT | MASK_MON, (rev4(v) << PIN_OUT3) | (v << PIN_MON0));
}

// DIP スイッチを読む。SW1 が bit3、SW4 が bit0。ON で 1
inline unsigned read_sw() {
    return rev4((~gpio_get_all() >> PIN_SW1) & 0xFu);
}
```

`clock55.cpp`:

```cpp
// 5-5 Soft-FPGA のクロックを測る — 8 ビットのカウンタを空回しする
#include "board.h"
#include "Vcounter8.h"

int main() {
    board_init();
    static Vcounter8 top;

    top.rst = 1;                    // 1 クロックだけリセット
    top.clk = 0; top.eval();
    top.clk = 1; top.eval();
    top.rst = 0;

    unsigned n = 0;
    while (true) {
        gpio_put(PIN_CLK, 1);
        top.clk = 1; top.eval();    // 立ち上がり: count が 1 進む
        put_leds(top.count >> 4);   // count[7:4] を LED へ
        gpio_put(PIN_CLK, 0);
        top.clk = 0; top.eval();    // 立ち下がり
        if (++n == 1000) {          // 1000 クロックごとに AUX を反転
            n = 0;
            gpio_xor_mask(1u << PIN_AUX);
        }
    }
}
```

- 1 周の中身は「GP16 を H → 立ち上がりの `eval()` → LED → GP16 を L → 立ち下がりの `eval()` → 1000 回目なら GP17 を反転」
- GP16 の H の幅は立ち上がりの計算と LED の書き込み、L の幅は立ち下がりの計算とループの残り。足したものが 1 クロック
- `top` は `static` にして、主ループの外に 1 つだけ置く

`verilate.sh` (5-1 のものの最後の行を、5-5〜5-8 の回路の 5 行に替える):

```bash
#!/bin/sh
# Verilog を C++ にする (sfa-dev のコンテナの中で打つ)
set -e
rm -rf vlinc && cp -r /usr/local/share/verilator/include vlinc   # ランタイムのヘッダ
verilator --cc --no-timing --no-trace -Wall --prefix Vcounter8  -GW=8        --Mdir v_counter8  counter.v
verilator --cc --no-timing --no-trace -Wall --prefix Vcounter32 -GW=32       --Mdir v_counter32 counter.v
verilator --cc --no-timing --no-trace -Wall --prefix VTD4                    --Mdir v_td4       TD4.v
verilator --cc --no-timing --no-trace -Wall --prefix Vblink     -GCLK_HZ=1000 --Mdir v_blink    blink.v
verilator --cc --no-timing --no-trace -Wall --prefix Vmany      -GN=256      --Mdir v_many      many.v
```

5-6 以降の回路もここでまとめて C++ にしておく (`blink.v` は 2-7、`TD4.v` は 5-8、`many.v` は 5-6)。この題だけなら 1 行目の `counter8` だけでよい。

`CMakeLists.txt` は 5-1 のもの。最後の行 (`add_soft_fpga(blink_pico …)`) を次の 4 行に替える。
5-6 以降の題の `.cpp` もここで決めるので、この題だけなら 1 行目だけでよい。

```cmake
add_soft_fpga(clock55 clock55.cpp counter8)
add_soft_fpga(clock56 clock56.cpp counter8 counter32 td4 blink many)
add_soft_fpga(clock57 clock57.cpp counter8 counter32 td4 blink many)
add_soft_fpga(td4_58  td4_58.cpp  td4)
```

打つ物は [5-1 の「ビルドする」](01-verilator-on-pico.md#ビルドする)の 2 行のまま。

空のフォルダから 5-1 の手順でビルドし、`build/clock55.uf2` (93 696 バイト) ができた (Verilator 5.048、Pico SDK 2.2.0)。**実機では動かしていない。**
`.uf2` を Pico 2 に書く手順は 0-2 と同じ (BOOTSEL を押しながら USB をつなぎ、出てきたドライブにコピーする)。

## 計器の設定

計器は AD3 の Logic。CLK の周期は µs の桁と見込むが、まだ分からないので、速い標本化から始める。

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 (CLK)・DIO1 (AUX) を Enable。標本化は 10 MHz から (1 本 32 768 標本で、窓は約 3.3 ms) |
| Logic のトリガ | DIO0 の立ち上がり |
| 時間軸 | CLK が 2〜10 周期入るように合わせる。図3 は 1 周期を仮に 10 µs と置いて 5 µs/div にした |
| カーソル | X1 と X2 を、続く 2 つの H の真ん中に置く。ΔX が 1 クロック、1/ΔX がクロックの周波数 |
| 平均を見るとき | DIO1 (AUX) を見る。AUX の 2 周期が窓に入るまで標本化を下げる。AUX の周期 ÷ 2000 が 1 クロックの平均 (5-6 の図3) |

標本化は、見せる一番速い変化 (CLK) の 4 倍以上にする。CLK が 1 MHz より速ければ 10 MHz では足りないので、上げる。
AD3 の DIO は 3.3 V の信号で、Pico 2 の GPIO とそろう (0-4)。

## Logic に見えるはずの画面

1 クロックの長さを測っていないので、**図3 の時間の目盛は仮** (1 クロックを 10 µs、H と L を同じ幅として描いた)。
見るものは目盛の数ではなく、**CLK の 1 周期をカーソルで挟む読み方**。実機の画面では、ΔX に測った値が出る。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 CLK の 1 周期を読む (1 クロックを仮に 10 µs として描いた。実測ではない)
device: ad3
time: 5us/div
start: -5us
sample: 10MHz
signals:
  CLK: dio0 clock 100kHz
cursors: [2.5us, 12.5us]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/05-clock-measure.svg)

- カーソルは H の真ん中に置いた。変わり目の上に置くと、新旧どちらの値か曖昧になる
- 実機では H と L の幅は同じにならないはず。立ち上がりと立ち下がりで `eval()` の仕事が違い、L のほうにはループの残りが入るため (見込み。測っていない)

## 見るべき値

**測っていない。測って空欄を埋める。** 数を決め打たないのは、この冊の決め (1 クロックの時間は実測してから書く)。

| 測る所 | 見るべき値 | 分かること |
| --- | --- | --- |
| CLK の周期 (ΔX) | (測って書く) µs | 8 ビットのカウンタの 1 クロックの長さ |
| CLK の周波数 (1/ΔX) | (測って書く) kHz | Soft-FPGA のクロックの周波数 |
| CLK の H の幅 | (測って書く) µs | 立ち上がりの計算 + LED の書き込み |
| CLK の L の幅 | (測って書く) µs | 立ち下がりの計算 + ループの残り |
| AUX の周期 ÷ 2000 | (測って書く) µs | 1 クロックの平均。CLK の周期と近いはず |
| CLK の周期の最小と最大 | (測って書く) µs | 1 クロックの長さがどれだけばらつくか。詳しくは 5-10 |

測った周波数は 5-6 で回路を替えたときの基準になる。2-7 の `blink` をそのまま Pico 2 で回すと、点滅の周期は
`CLK_HZ` ÷ (測った周波数) 倍だけずれる (計算で出せる)。これを決まった周期に直すのが 5-7。

## シミュレーションでの確かめ (対象外を含む)

PC で回す確かめは手元の Verilator 5.042 で行った。`.uf2` の大きさは、本文の Docker でビルドし直した。`counter.v` (2-4) を `-GW=8` で C++ にし、本文の `board.h`・`clock55.cpp` を
替え玉の GPIO (`sim/pcstub/`) で PC で回した (`sim/05-clock-measure-pc.cpp`)。PC 用の `clock55_pc.cpp` は本文の `.cpp` の `while (true)` を `while (g_run())` に、`int main()` を `void target_main()` に `sed` で替えた物で、
`sim/*-pc.cpp` はこれをインクルードして 2500 周回す。他の題の `*-pc.cpp` も同じ作り方。
`.uf2` と `arm-none-eabi-size` の値は、本文の Docker イメージ (`sfa-dev:local` の Verilator 5.048 と `wb-pico-sdk` の Pico SDK 2.2.0、`arm-none-eabi-gcc` 13.2.1) で、本文の `.cpp` と `.v` からビルドし直した値。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint (`counter.v -GW=8`) | 警告なし | 警告 0 件 | 合った |
| AUX の反転 | 1000 クロックごと、周期は 2000 クロック | 1000 周と 2000 周で反転 (2500 周で 2 回) | 合った |
| LED = `count[7:4]`、GP2 が bit3 | 並びが逆 (`rev4`) | 2500 周後の `count[7:4]` = 0xC に対し GP2〜GP5 = 1・1・0・0 (GP2 が上の桁)、GP18〜GP21 = 0xC | 合った |
| `.uf2` の大きさ | 93 696 バイト | 93 696 バイト | 合った |

気付いたこと (本文の数字には影響しない)。

- リセットのあと `clk` が 1 のままなので、主ループの最初の立ち上がりの `eval()` は立ち上がりにならない。`count` は周回数より 1 少ない。5-6 の `Models::reset()` も同じ
- 「見るべき値」の表は測って書く欄なので、空欄のまま

### エミュレータ (picoemu) での確かめ

picoemu (`danish9661/pico-emulator` の `b83786f` に `sim/picoemu-m33.patch` を当てた版。手順は [5-2](02-counter-led.md#エミュレータ-picoemu-での確かめ)) に `clock55.uf2` を載せ、Cortex-M33 で動かした。入力は `-script` で与えた (ms 刻み)。
確かめは `python3 sim/picoemu-check.py --picoemu ./picoemu --uf2 <.uf2 を集めたフォルダ> 5-5`。picoemu は機能の模型で、周期・ジッタ・周波数の実時間は対象外にした。

| 項目 | 本文の数字 | picoemu の結果 | 判定 |
| --- | --- | --- | --- |
| LED = `count[7:4]`、GP2 が bit3 | 並びが逆 (`rev4`)。`count` は周回数より 1 少ない | 8 039 クロック分、GP2〜GP5 と GP18〜GP21 が `((周回数 − 1) >> 4) & 15` と `rev4` のとおり (不一致 0) | 合った |
| AUX の反転 | 1000 クロックごと | 1000・2000・3000 … 8000 クロック目 | 合った |
| CLK の周期・H と L の幅・ばらつき | 測って書く | 模型の値しか出ない | 対象外 (実時間) |

確かめられなかったもの。

- 1 クロックの時間・周波数・H と L の幅・ばらつき (実機で AD3 の Logic を使う)

## 出典

自作。Soft-FPGA を Pico 2 で動かす方式は [Soft-FPGA-TD4](https://github.com/tommie-jp/Soft-FPGA-TD4)、
Verilator のランタイムを Pico 2 で通す部品は [Soft-FPGA-Reversi](https://github.com/tommie-jp/Soft-FPGA-Reversi) の `firmware/src/`。
GPIO の扱いは Raspberry Pi の Pico SDK の資料。AD3 の Logic の使い方は 0-4。
