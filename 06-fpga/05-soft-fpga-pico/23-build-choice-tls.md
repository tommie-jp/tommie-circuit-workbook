---
book: fpga
chapter: 5
id: 5-23
title: Pico SDK で通す手順を選ぶ — もう 1 つの手順と thread_local の置き場
tier: 100
source: 自作
board: —
device: PICO
---

# 5-23 Pico SDK で通す手順を選ぶ — もう 1 つの手順と thread_local の置き場

> [!WARNING]
> **この題は実機で動かしていない。** PC の Docker でビルドし、`.uf2` の大きさと区画を確かめたところまで。

この題は実体配線図と Analog Discovery 3 の図を付けない。PC でビルドするだけの組まない題だから。

5-1 では、Verilator の C++ を Pico SDK で通す手順を 1 つに決め、そのとおりにビルドした。
この題では、その手順に決めた理由を、もう 1 つの手順と比べて書く。
続けて、5-1 の `pico_tls.cpp` が `thread_local` の置き場を自前の配列に取る理由を書く。ファイルと打つ物は 5-1 のまま。

## この手順に決めた理由

第 5 章は、初め 2 通りの手順で書いていた。もう 1 つは、PC に入れた Verilator 5.042 のランタイムを `sed` で 1 行外して写し、
自作の `pico_compat.h` で `PRIu64` を補い、`thread_local` を空の語に置き換える手順だった。どちらも `.uf2` まではビルドできた。
この本は次の理由で、5-1 の表の手順に決めた。

- 道具の版を固定できる。Verilator は 0-2 の `sfa-dev` (5.048)、Pico SDK は `wb-pico-sdk` (2.2.0、`arm-none-eabi-gcc` 13.2.1) の Docker で走る。
  PC に入れた Verilator の版は人によって違う
- 手で書くファイルが `pico_tls.cpp` の 1 つで済む。ほかの 3 つは Soft-FPGA-Reversi から写すだけ
  (Soft-FPGA-Reversi は xPack の `arm-none-eabi-gcc` 15.2.1 を使うので、`pico_tls.cpp` の関数を自分で書かない)
- Pico 2 で動いている物に倣っている。Soft-FPGA-Reversi は Verilator 5.048 のランタイムを Pico 2 で回している
- `thread_local` の意味を変えない。空の語に置き換えると、ランタイムの変数の持ち方が変わる。`pico_tls.cpp` は置き場を 1 つ返すだけで、`thread_local` はそのまま
- 5-1 の表の 3 の検査を外してある。もう 1 つの手順では、この検査が残っていた (Pico 2 で止まるかは確かめていない)

## thread_local の置き場を配列に取る理由

領域を自前の配列 `tls_area` に取るのは、Pico SDK 2.2.0 のリンカスクリプト (`memmap_default.ld`) の `__tls_base` (`.tbss` の頭) をそのまま使うと、
**`.tbss` と `.bss` が同じ番地に重なる**からである。`.tbss` は TLS の型紙で、リンカは場所を空けない。
重なった範囲では、`.bss` の変数と `thread_local` の変数が同じ場所を使い、書き合う。
5-1 の `blink` は、エミュレータ (5-2 の確かめ) では動いた。5-6 のように回路を 5 つ持つ `.uf2` は、重なった所の `thread_local` の変数が壊れ、
Verilator の起動の検査 (`VerilatedSyms` が `VerilatedContext` の印を調べる所) で止まった。配列に替えると 5-6 も動いた。
配列の大きさは ARM の決まりの 8 バイトと `.tbss` の 0x44 バイトの合計で、
`arm-none-eabi-readelf -S build/blink_pico.elf` で `.tdata` が 0 バイト、`.tbss` が 0x44 バイトであることを確かめて使う。これらが変われば、配列の大きさを直す。

## 見るべき値

5-1 の作業用のフォルダで打って得た値。Pico 2 の上では動かしていない。

| 確かめること | 打つ物 | 出た物 |
| --- | --- | --- |
| `pico_tls.cpp` を外すと | `cmake --build build` | リンクで `undefined reference to '__aeabi_read_tp'` (5-1 の表の 4) |
| `thread_local` の置き場 | `arm-none-eabi-readelf -S build/blink_pico.elf` | `.tdata` は 0 バイト、`.tbss` は 0x44 バイト (配列 `tls_area` の 8 + 0x44 バイトに収まる) |
| もう 1 つの手順の `.uf2` | `ls -l build/blink_pico.uf2` | 600 576 バイト (5-1 の手順では 92 160 バイト) |

もう 1 つの手順 (`sfa-dev` の Verilator 5.048 の `verilated.cpp` から 1 行だけ外した写し) では、同じ `blink` の `.uf2` が 600 576 バイトだった (Verilator 5.042 では 599 040 バイト)。
差の多くは、ランタイムが `<iostream>` と `<sstream>` から引き込む C++ の標準ライブラリ (文字列の書式・ロケールなど) である。
どちらも Pico 2 のフラッシュ (4 MB) には収まる。ランタイムを削る話は 5-13 に置く。

## シミュレーションでの確かめ (対象外を含む)

5-1 と同じ Docker イメージ (`sfa-dev:local` は Verilator 5.048、`wb-pico-sdk` は Pico SDK 2.2.0・`arm-none-eabi-gcc` 13.2.1) で、
5-1 の作業用のフォルダからビルドし直した。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| `pico_tls.cpp` を外すと | リンクで `undefined reference to '__aeabi_read_tp'` | 同じエラー | 合った |
| `thread_local` の置き場 | `.tdata` 0 バイト、`.tbss` 0x44 バイト | `.tdata` 0、`.tbss` 0x44 | 合った |
| 別の手順の `.uf2` | 599 040 バイト (Verilator 5.042 のとき) | 600 576 バイト、text 303 896・bss 6 460 (Verilator 5.048 のとき) | 近い値 (版の差) |

別の手順は、`sfa-dev` の `verilated.cpp` に `sed` で 1 行外すだけを当て、`pico_compat.h` と Soft-FPGA-TD4 の `stub_mutex.h` でビルドした。
Verilator を 5.042 から 5.048 に替えたぶん、0.3 % 大きくなった。

確かめられなかったもの。

- Pico 2 への書き込みと動作 (実機)
- もう 1 つの手順で、5-1 の表の 3 の検査が Pico 2 で止まるか

## 出典

自作。5-1 の手順は [tommie-jp/Soft-FPGA-Reversi](https://github.com/tommie-jp/Soft-FPGA-Reversi) の `firmware/src/` (コミット `5be3b16`) に倣った。
もう 1 つの手順の `stub_mutex.h` は [tommie-jp/Soft-FPGA-TD4](https://github.com/tommie-jp/Soft-FPGA-TD4)。
リンカスクリプト `memmap_default.ld` は [raspberrypi/pico-sdk](https://github.com/raspberrypi/pico-sdk) の 2.2.0。
