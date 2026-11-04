---
book: fpga
chapter: 5
id: 5-13
title: Verilator のランタイムを Pico で通す — 削る所と差し替える所
tier: 100
source: 自作
board: —
device: PICO
---

# 5-13 Verilator のランタイムを Pico で通す — 削る所と差し替える所

> [!WARNING]
> **この題は実機で動かしていない。** 確かめたのは、PC の Docker での Verilator の変換と Pico SDK でのビルド (`.uf2` ができること) と、
> ランタイムのソースを読んだ結果だけ。「Pico 2 で動いたらこうなる」と書いた所は、ソースの読みで、実機では確かめていない。

この題は実体配線図と Analog Discovery 3 の図を付けない。PC でビルドするだけの組まない題だから。

5-1 では、Verilator のランタイム (`verilated.cpp`) を Pico SDK で通すために、4 つの所を直した。
この題では、その 4 つがなぜ要るのかを**ランタイムの役割ごと**に見直し、Verilator の版を上げたときに削った所をどう見つけ直すかを書く。
Verilog に `$display`・`$finish`・`$readmemh` を書いたとき何が起きるかを、ビルドして確かめる話は 5-26 に分けた。

## ランタイムの役割と、Pico での扱い

Verilator が作る C++ は、回路の計算 (`eval()`) だけを持つ。`$display` の書式・`$finish`・ファイルの読み書き・
複数スレッド・波形の記録といった**周りの仕事**は、ランタイム (`verilated.cpp`) が引き受ける。
周りの仕事は PC の Linux を前提に書かれているので、Pico 2 で通すときに扱いを決める必要がある。

| 役割 | ランタイムがやること | Pico での扱い | 方法 |
| --- | --- | --- | --- |
| スレッド | `std::mutex`・`std::condition_variable`・スレッドプール | 使わない (Pico 2 の Soft-FPGA は 1 本で回す) | `stub_mutex.h` を全ての C++ の先頭に差し込み、何もしない型に置き換える |
| 文字の整形と出力 | `$display` などの書式を整形して `printf` で出す | そのまま使う。出る先は stdio (既定は UART0 の GP0・GP1)。USB に出すのは 5-14 | `stdio_init_all()` を呼ぶ。呼ばないと出ない |
| ファイル | `$readmemh`・`$fopen` が `fopen` を呼ぶ | **使えない。** Pico にファイルシステムは無い | `$readmemh` は `initial` 文に置き換える (5-26) |
| 終了 | `$finish` が `gotFinish` を立てる。`$stop`・`$fatal` は `std::exit(1)` | `$finish` は主ループで `gotFinish()` を見て止める。`exit` は `_exit` が無限ループ (ソースの読み) | プログラムの側で `gotFinish()` を見る (5-26) |
| 波形の記録 | `--trace` の VCD・FST の書き出し | **使わない。** `--no-trace` で作る | 5-1 の `verilate.sh` の指定。付けるとコンパイルが通らない (下) |
| 時刻 | `clock_gettime`・`sc_time_stamp` | 使わない | `stub_mutex.h` が `clock_gettime` を 0 を返す形で置く |
| 例外・型情報 | `dynamic_cast`・例外の仕組み | RTTI を有効にし、例外は何もしない関数に置き換える | `PICO_CXX_ENABLE_RTTI`、`cxx_minimal.cpp` |
| 検査と診断 | スレッド数の検査、文字列ストリーム (`<sstream>`) の診断文 | 削る (実行に要らない) | Soft-FPGA-Reversi の `verilated.cpp` |

### 削った所 — Soft-FPGA-Reversi の `verilated.cpp` と、Verilator 5.048 の差

5-1 で取った `verilated.cpp` (Soft-FPGA-Reversi のコミット `5be3b16`) と、`sfa-dev` の Verilator 5.048 が持つ `verilated.cpp` を `diff` に掛けた。

```bash
docker run --rm sfa-dev:local cat /usr/local/share/verilator/include/verilated.cpp > orig_verilated.cpp
diff orig_verilated.cpp verilated.cpp
```

差は 5 か所、`<` と `>` の行を合わせて 50 行。どれもランタイムの**診断と検査の文字列を作る所**で、回路の計算には関わらない。

| 所 (行) | 元 | 直し | 理由 |
| --- | --- | --- | --- |
| `#include <iostream>`・`<sstream>` (62・66) | 標準ライブラリの入出力 | 外す | C++ のロケールなどを引き込み、`.uf2` が大きくなる (5-1 の「見るべき値」に 600 576 バイトと 92 160 バイトの差) |
| スレッド数の検査 (3126) | モデルのスレッド数がコンテキストより多いと止まる | 検査を外す | Pico 2 では `hardware_concurrency()` が 0 を返し、検査に引っかかる (5-1 の表の 3) |
| 引数の診断 `fail` (3295) | `std::stringstream` で文を作る | 固定の文にする | `Verilated::commandArgs()` を呼ばないので届かない |
| SystemC の時間精度の診断 (3576) | `std::ostringstream` で文を作る | 固定の文にする | SystemC は使わない |

行番号は 5.048 のもの。`<sstream>` の使い所 2 か所 (3295・3576) は、どちらも異常終了の文を作るだけ。

## 波形の記録は付けない

`verilate.sh` の `--no-trace` を `--trace` に替えて、5-26 の `p_none` を変換し直して Pico SDK でビルドした。
**コンパイルが通らなかった。** `verilated_vcd_c.h` が `VerilatedTrace` と `VerilatedTracePrefixType` を要求するが、
`stub_mutex.h` が `verilated_trace.h` を読んだことにして中身を空にしているので、型が見つからない。

波形は PC で見る (0-6)。Pico 2 では、見たい信号を GPIO に出して Logic で見るか (5-5〜5-12)、USB シリアルに字で出す (5-14)。

## Verilator の版を上げたとき

`sfa-dev` の Verilator を上げたら、次の順で削った所を見つけ直す。

1. 新しい Verilator のランタイムを取り出し、Soft-FPGA-Reversi の `verilated.cpp` と `diff` する (上のコマンド)。
   差が 5-1 の表の 4 つの性質の所だけなら、その行を写し直す
2. `stub_mutex.h` の冒頭の対象の版を書き直す。`verilated.cpp` が `verilated_threads.h`・`verilated_trace.h` から
   要求するシンボルが増えていないか、`grep` で確かめる
3. 5-1 の `blink` と、5-26 の `p_none`・`p_disp`・`p_rom2` をビルドし直し、リンクが通ることを確かめる
4. Pico 2 に書き込んで、5-2 の LED の点滅が動くことを確かめる (実機が要る)

## 見るべき値

**実機では動かしていない。** 表は、PC の Docker (Verilator 5.048、Pico SDK 2.2.0) でビルドして出た値。

| 確かめること | 打つ物 | 出た物 |
| --- | --- | --- |
| `--trace` で変換して通すと | `cmake --build` | コンパイルエラー (`VerilatedTrace` が不完全な型) |
| 5-1 の `diff` | `diff orig_verilated.cpp verilated.cpp` | 5 か所・50 行。診断文と検査だけ |

## シミュレーションでの確かめ (対象外を含む)

5-26 の `p_none.v` (`sim/13-runtime-trim-none.v`) を `--trace` で変換して Pico SDK でビルドし、`verilated.cpp` の `diff` を取り直し、
Pico SDK の `newlib_interface.c` を読んだ。ビルドは本文の Docker イメージ (`sfa-dev:local` の Verilator 5.048 と `wb-pico-sdk` の Pico SDK 2.2.0、`arm-none-eabi-gcc` 13.2.1)。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| `--trace` でビルド | コンパイルエラー (`VerilatedTrace` が不完全な型) | `invalid use of incomplete type 'class VerilatedTrace<...>'` と `'VerilatedTracePrefixType' was not declared` | 合った |
| `_exit` と `_open` | `_exit` は `__breakpoint()` の無限ループ、`_open` は −1 | `newlib_interface.c` のとおり | 合った |
| `verilated.cpp` の `diff` | 5 か所・50 行、行は 62・66・3126・3295・3576 | `sfa-dev` の 5.048 の `verilated.cpp` と、コミット `5be3b16` の `verilated.cpp` の `diff` が 5 か所・50 行 (`62c62,67`・`66d70`・`3126,3133c3130,3136`・`3295,3302c3298,3302`・`3576,3584c3576,3580`) | 合った |

確かめられなかったもの。

- Pico 2 の上で `exit` で固まる動き (実機)。ソースの読みだけ

## 出典

自作。ランタイムの仕組みは [Verilator User's Guide](https://veripool.org/guide/latest/) と、Verilator 5.048 の `verilated.cpp`・`verilated.h`。
Pico SDK の `_exit`・`_open`・既定の UART は Pico SDK 2.2.0 の `pico_clib_interface/newlib_interface.c` と `boards/pico2.h`。
Pico 向けに直した `verilated.cpp`・`stub_mutex.h` は [tommie-jp/Soft-FPGA-Reversi](https://github.com/tommie-jp/Soft-FPGA-Reversi) (コミット `5be3b16`)。
