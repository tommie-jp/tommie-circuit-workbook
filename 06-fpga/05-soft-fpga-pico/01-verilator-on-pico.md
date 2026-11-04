---
book: fpga
chapter: 5
id: 5-1
title: Pico 2 で Verilog を動かす仕組み — Verilator の C++ を Pico SDK でビルドする
tier: 50
source: 自作
board: —
device: PICO
---

# 5-1 Pico 2 で Verilog を動かす仕組み — Verilator の C++ を Pico SDK でビルドする

> [!WARNING]
> **この題は実機で動かしていない。** Verilog の lint と、Pico 2 用の `.uf2` ができるところまでを PC で確かめた。
> Pico 2 に書き込んで動かすのは 5-2 で、その結果もまだ測っていない。

この題は実体配線図と Analog Discovery 3 の図を付けない。PC でビルドするだけの組まない題だから。

第 4 章ではブラウザで動かした Verilator の C++ を、第 5 章では Raspberry Pi Pico 2 の CPU で動かす。FPGA は使わない。Pico 2 の CPU が回路の動きを 1 クロックずつ計算し、結果を GPIO に出す。
この方式を Soft-FPGA と呼ぶ
([Soft-FPGA-TD4](https://github.com/tommie-jp/Soft-FPGA-TD4) が 4 ビット CPU の TD4 で先に動かした)。

この題では、2-7 の `blink.v` (分周して LED を点滅させる回路) を Pico 2 用にビルドする。

## 仕組み

Verilator は、Verilog の 1 つのモジュールを C++ の 1 つのクラスにする。`blink.v` なら `Vblink` というクラスになる。

- 入出力のポートは、クラスのメンバ変数になる (`top.clk` `top.rst` `top.led`)
- `top.eval()` を呼ぶと、そのときの入力で回路を 1 回計算し、出力とフリップフロップの値を新しくする
- クロックもただの入力である。`clk` を 0 にして `eval()`、1 にして `eval()` と 2 回呼ぶと、立ち上がりが 1 回起き、
  回路が 1 クロック進む

```cpp
while (true) {
    top.clk = 0; top.eval();   // 立ち下がり
    top.clk = 1; top.eval();   // 立ち上がり: カウンタが 1 進む
    gpio_put(PIN_LED, top.led);
}
```

Pico 2 の主ループがこれを繰り返す。だから**クロックの周波数は、主ループが 1 周する速さで決まる**。
1 周の時間は `eval()` の計算の量と GPIO の読み書きで変わり、測るまで分からない (測り方は 5-5)。

## 図

```plantuml
@startuml
left to right direction
skinparam shadowing false
skinparam defaultFontName "Noto Sans CJK JP"
skinparam rectangle {
  RoundCorner 6
}
title 図1 Verilog を Verilator で C++ にし、Pico SDK で Pico 2 の .uf2 にする

rectangle "blink.v\n(2-7 の Verilog)" as V #FFF8E1
rectangle "Verilator 5.048\n(sfa-dev の Docker)\nverilate.sh" as VL #E8F0FE
rectangle "v_blink/Vblink*.cpp\n回路の計算 (eval)" as G #FFF8E1
rectangle "verilated.cpp\nVerilator のランタイム\n(Soft-FPGA-Reversi の写し)" as RT #FFF8E1
rectangle "main.cpp\n主ループ: eval と GPIO" as M #FFF8E1
rectangle "Pico SDK 2.2.0\n(wb-pico-sdk の Docker)\nstub_mutex.h・cxx_minimal.cpp\npico_tls.cpp" as SDK #E8F0FE
rectangle "blink_pico.uf2" as U #E6F4EA
rectangle "Pico 2\nCPU が回路を計算し\nGP14 に出す" as P #E6F4EA

V --> VL
VL --> G
G --> SDK
RT --> SDK
M --> SDK
SDK --> U
U --> P : BOOTSEL で\nコピー
@enduml
```

![ブロック図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/plantuml/01-verilator-on-pico.svg)

- `blink.v` から C++ (`v_blink/`) までは第 4 章と同じ。Pico SDK から右が Pico 2 のための所
- Verilator は PC の Docker で走る。Pico 2 の中で動くのは、Verilator が出した C++ とランタイムだけ
- この手順は第 5 章の全部の題で使う。5-2 から先は、題ごとに替わる所だけを書く

## Pico SDK で通らない所と、その直し方

Verilator が出す C++ とランタイム (`verilated.cpp`) は PC の Linux 向けで、Pico SDK でそのままビルドすると次の所で止まる。直し方は、Pico 2 で動いている
[Soft-FPGA-Reversi](https://github.com/tommie-jp/Soft-FPGA-Reversi) の `firmware/src/` に倣い、4 の `pico_tls.cpp` だけをこの本で足した。

| # | 止まる所 | 原因 | 直し方 |
| --- | --- | --- | --- |
| 1 | `'mutex' in namespace 'std' does not name a type` | Pico SDK の C++ には `std::mutex` が無い | `stub_mutex.h` (何もしない `mutex` を定義する) を `-include` で全部の C++ の先頭に差し込む |
| 2 | `verilated_threads.h` の中の `condition_variable_any` などが無い | ランタイムがスレッドの仕組みを読み込む | 同じ `stub_mutex.h` が `verilated_threads.h`・`verilated_trace.h` を読んだことにし、要る型だけを空の形で置く。`verilated.cpp` の行は外さない |
| 3 | 起動の直後に「VerilatedContext thread count mismatch」で止まる | Pico 2 ではスレッドの数が 0 になり、ランタイムの検査に引っかかる | Soft-FPGA-Reversi の `verilated.cpp` (この検査と `<iostream>`・`<sstream>` を外した版) を使う |
| 4 | リンクで `undefined reference to '__aeabi_read_tp'` | `thread_local` の置き場を返す関数が、Ubuntu の `arm-none-eabi-gcc` 13.2.1 の newlib に無い | `pico_tls.cpp` で足す (下。Soft-FPGA-Reversi との違いは 5-23) |

ほかに、Verilator の C++ は `dynamic_cast` を使うので、`CMakeLists.txt` で RTTI を有効にする (`PICO_CXX_ENABLE_RTTI`)。
`cxx_minimal.cpp` は、C++ の例外の仕組みを何もしない関数に置き換え、`.uf2` を小さくする。

`stub_mutex.h` と `verilated.cpp` は Verilator 5.048 向けで、`sfa-dev` の Verilator を上げたら合わせ直す (5-13)。
この手順に決めた理由は 5-23 に分けた。

## ファイル

作業用の空のフォルダに次を置く。

| ファイル | 中身 | どこから |
| --- | --- | --- |
| `blink.v` | 2-7 の Verilog | 2-7 |
| `main.cpp` | 主ループ | 下に載せる |
| `verilate.sh` | Verilog を C++ にする手順 | 下に載せる |
| `CMakeLists.txt` | ビルドの設定 | 下に載せる |
| `pico_tls.cpp` | 上の表の 4 | 下に載せる |
| `stub_mutex.h` `cxx_minimal.cpp` | 上の表の 1・2 と、例外の仕組みの置き換え | Soft-FPGA-Reversi の `firmware/src/` |
| `verilated.cpp` | 上の表の 3 | Soft-FPGA-Reversi の `firmware/src/verilator-runtime/` |
| `pico_sdk_import.cmake` | Pico SDK を読み込む設定 | ビルドのときにコンテナの中で写す (下) |

Soft-FPGA-Reversi の 3 つは、この本で確かめたコミット (`5be3b16`) から取る。

```bash
R=https://raw.githubusercontent.com/tommie-jp/Soft-FPGA-Reversi/5be3b16ef907e9ce9c3b622187ad32672e432831/firmware/src
curl -fsSLO $R/stub_mutex.h
curl -fsSLO $R/cxx_minimal.cpp
curl -fsSLO $R/verilator-runtime/verilated.cpp
```

`main.cpp`:

```cpp
// 2-7 の blink.v を Pico 2 で回す。LED は GP14
#include "pico/stdlib.h"
#include "Vblink.h"

#define PIN_LED 14

int main() {
    gpio_init(PIN_LED);
    gpio_set_dir(PIN_LED, GPIO_OUT);

    VerilatedContext ctx;
    Vblink top{&ctx};

    // リセットを 2 クロック掛ける
    top.rst = 1;
    for (int i = 0; i < 2; i++) {
        top.clk = 0; top.eval();
        top.clk = 1; top.eval();
    }
    top.rst = 0;

    while (true) {
        top.clk = 0; top.eval();   // 立ち下がり
        top.clk = 1; top.eval();   // 立ち上がり: カウンタが 1 進む
        gpio_put(PIN_LED, top.led);
    }
}
```

`verilate.sh` (`sfa-dev:local` の中で打つ):

```bash
#!/bin/sh
# Verilog を C++ にする (sfa-dev のコンテナの中で打つ)
set -e
rm -rf vlinc && cp -r /usr/local/share/verilator/include vlinc   # ランタイムのヘッダ
verilator --cc --no-timing --no-trace -Wall --prefix Vblink -GCLK_HZ=100000 --Mdir v_blink blink.v
```

- 1 行目でランタイムのヘッダ (`include/`) を `vlinc/` に写す。Pico SDK の側はこれを読む
- 2 行目が変換。`--prefix` がクラスの名前、`--Mdir` が C++ を置くフォルダ。`-GCLK_HZ=100000` は 5-2 で使う仮の値
- `-Wall` なので、lint の警告が 1 つでもあれば止まる。`--no-timing` は `#` の遅延などシミュレーション用の書き方を使わない、`--no-trace` は波形を残す仕組みを入れない指定

`CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.13)
set(PICO_BOARD pico2 CACHE STRING "Board type")
include(pico_sdk_import.cmake)
project(soft_fpga C CXX ASM)
set(CMAKE_CXX_STANDARD 17)
set(PICO_CXX_ENABLE_RTTI 1)          # Verilator の出す C++ が dynamic_cast を使う
pico_sdk_init()

set(VL_INC ${CMAKE_SOURCE_DIR}/vlinc)              # Verilator の include (sfa-dev からコピー)
set(VL_RUNTIME ${CMAKE_SOURCE_DIR}/verilated.cpp)  # Soft-FPGA-Reversi の verilated.cpp
set_source_files_properties(${VL_RUNTIME} PROPERTIES COMPILE_FLAGS "-w")

# add_soft_fpga(名前 主ループの.cpp 回路 …)
# 回路の名前 M は、verilate.sh が C++ を出したフォルダ v_M を指す
function(add_soft_fpga NAME MAIN)
    set(SRCS ${MAIN} cxx_minimal.cpp pico_tls.cpp ${VL_RUNTIME})
    set(DIRS "")
    foreach(M ${ARGN})
        file(GLOB GEN ${CMAKE_SOURCE_DIR}/v_${M}/V*.cpp)
        list(APPEND SRCS ${GEN})
        list(APPEND DIRS ${CMAKE_SOURCE_DIR}/v_${M})
        set_source_files_properties(${GEN} PROPERTIES COMPILE_FLAGS "-w")
    endforeach()
    add_executable(${NAME} ${SRCS})
    target_include_directories(${NAME} PRIVATE ${CMAKE_SOURCE_DIR} ${DIRS})
    target_include_directories(${NAME} SYSTEM PRIVATE ${VL_INC} ${VL_INC}/vltstd)
    # C++ のソースには先に stub_mutex.h を読ませる (Pico に無い mutex などの代わり)
    target_compile_options(${NAME} PRIVATE -O2 -Wall -Wextra
        $<$<COMPILE_LANGUAGE:CXX>:-include ${CMAKE_SOURCE_DIR}/stub_mutex.h>)
    target_link_libraries(${NAME} pico_stdlib)
    pico_add_extra_outputs(${NAME})
endfunction()

# ここから下が題ごとに替わる
add_soft_fpga(blink_pico main.cpp blink)
```

- `add_soft_fpga` は、主ループ・`cxx_minimal.cpp`・`pico_tls.cpp`・ランタイム・回路の C++ を 1 つの `.uf2` にする。回路を 2 つ以上使う題は、後ろに回路の名前を並べる (5-6 など)
- `-include` は、ソースの 1 行目に `#include` を書いたのと同じ。Verilator が出し直すたびにファイルを直さずに済む。
  Verilator の出した C++ とランタイムは `-w` で警告を出さない

`pico_tls.cpp`:

```cpp
// pico_tls.cpp — Ubuntu の arm-none-eabi-gcc (newlib) に無い __aeabi_read_tp を足す
// Verilator のランタイムは thread_local を使う。Pico 2 では 1 スレッドなので、
// 両方のコアで同じ TLS の領域を返す。領域は自前の配列に取る。
// リンカスクリプトの __tls_base は .bss の頭と重なるので使わない。
// ARM の TLS は「スレッドポインタ + 8」から始まるので、8 バイトの余白を先頭に置く。
// .tdata が空 (初期値つきの thread_local が無い) こと、.tbss が 0x44 バイトであることを
// readelf で確かめて使う。
alignas(8) static char tls_area[8 + 0x44];

extern "C" void* __aeabi_read_tp(void) {
    return tls_area;
}
```

置き場を自前の配列に取る理由と、配列の大きさの確かめ方は 5-23 に分けた。

## ビルドする

作業用のフォルダで次の 2 行を打つ。1 行目が Verilog から C++ (`sfa-dev:local`)、2 行目が C++ から `.uf2` (`wb-pico-sdk`)。どちらも 0-2 で作ったコンテナ。

```bash
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD":/work -w /work sfa-dev:local sh verilate.sh
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD":/work -w /work wb-pico-sdk \
  bash -c 'cp /opt/pico-sdk/external/pico_sdk_import.cmake . && cmake -S . -B build -DPICO_BOARD=pico2 && cmake --build build -j8'
```

`build/blink_pico.uf2` ができればよい。Pico 2 への書き込みは 0-2 と同じ (BOOTSEL を押しながら USB をつなぎ、出たドライブにコピー)。

README の決まりは C/C++ と MicroPython の併記だが、この章は C++ だけで書く。MicroPython からは Verilator の C++ を呼べない。

## 見るべき値

空のフォルダから上の手順で打って得た値 (Pico 2 では動かしていない)。

| 確かめること | 打つ物 | 出た物 |
| --- | --- | --- |
| C++ への変換と lint | `sh verilate.sh` (`sfa-dev:local` の中) | 警告なし。Verilation Report に `Verilator 5.048`。`v_blink/` に `Vblink.cpp` など 5 つの C++ |
| ビルド | `cmake --build build` | エラーも警告もなし |
| `.uf2` の大きさ | `ls -l build/blink_pico.uf2` | 92 160 バイト |
| プログラムの大きさ | `arm-none-eabi-size build/blink_pico.elf` | text 49 828 バイト、bss 2 388 バイト |
| 内訳 | `arm-none-eabi-size` で `.o` ごと | 回路 (`v_blink/Vblink*.o`) は合わせて text 約 1.6 KB。ランタイム (`verilated.cpp.o`) は text 約 64 KB で、使わない所はリンクで落ちる |

0-2 の C だけの `blink.uf2` は 12 800 バイトだった。大きさのほとんどは、回路でなくランタイムの側にある。
もう 1 つの手順では、同じ `blink` の `.uf2` が 600 576 バイトだった (5-23)。ランタイムを削る話は 5-13。

## シミュレーションでの確かめ (対象外を含む)

本文の Docker イメージ (Verilator 5.048、Pico SDK 2.2.0・`arm-none-eabi-gcc` 13.2.1) と「ファイル」の 8 つで、空のフォルダからビルドし直し、「見るべき値」と比べた。

| 項目 | 実行結果 | 判定 |
| --- | --- | --- |
| C++ への変換 (`-Wall`) | 警告なし、`Verilator 5.048 2026-04-26 rev v5.048`、C++ が 5 つ | 合った |
| ビルド | エラーなし | 合った |
| `.uf2` の大きさ | 92 160 バイト | 合った |
| プログラムの大きさ | text 49 828・bss 2 388 バイト | 合った |
| 回路の `.o` の text | 1 567 バイト (48 + 172 + 219 + 508 + 620) | 合った |
| ランタイム (`verilated.cpp.o`) の text | 64 013 バイト | 合った |

確かめられなかったもの。

- Pico 2 への書き込みと動作 (実機)。5-2 に続く

## 出典

自作。Pico SDK でビルドする手 (`stub_mutex.h`・`cxx_minimal.cpp`・Pico 向けの `verilated.cpp`・RTTI) は
[tommie-jp/Soft-FPGA-Reversi](https://github.com/tommie-jp/Soft-FPGA-Reversi) の `firmware/CMakeLists.txt`・`firmware/src/`・`doc/07-Picoビルド.md` (コミット `5be3b16`) に倣った。
Soft-FPGA の方式と `-include` で差し込む考えは [tommie-jp/Soft-FPGA-TD4](https://github.com/tommie-jp/Soft-FPGA-TD4) の `verilator-TD4/` と `etc/92-FAQ.md`。
`eval()` とモデルのクラスは [Verilator User's Guide](https://veripool.org/guide/latest/)。
Pico SDK は [raspberrypi/pico-sdk](https://github.com/raspberrypi/pico-sdk) の 2.2.0。
