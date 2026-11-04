---
book: fpga
chapter: 4
id: 4-15
title: 中の信号を C++ から直に読む — Verilator の版で変わる名前
tier: 100
source: 自作
board: —
device: SIM
---

# 4-15 中の信号を C++ から直に読む — Verilator の版で変わる名前

この題は実体配線図・Analog Discovery 3・ロジックアナライザの図を付けない。4-5 と同じ 03-uart とラッパを使い、読み方だけを足す題だから (`tx_cnt` の波形は 4-5 の図1)。

4-5 では、送信機の中のビット計数 `clk_cnt` を、最上位に足した薄いラッパのポート `o_tx_cnt` に出した。
ラッパを書かずに、C++ から中の `clk_cnt` を直に読む書き方も 2 つある。ただし、その名前は Verilator が決めていて、版で変わる。
同じ `main` を `-D` で 4 通りに切り替えて、3 つの版の Verilator でビルドして比べる。

## 4 通りの読み方 (C++)

```cpp
// 送信機のビット計数 clk_cnt を 4 通りの書き方で読む。どれを使うかは -D で選ぶ。
#include <cstdio>
#include "verilated.h"
#if defined(WAY_WRAP)
  #include "Vuart_probe_top.h"
  typedef Vuart_probe_top Top;
  #define TX_CNT(t) ((t)->o_tx_cnt)                              // 薄いラッパの出力
#elif defined(WAY_ROOTP)
  #include "Vuart_top.h"
  #include "Vuart_top___024root.h"
  typedef Vuart_top Top;
  #define TX_CNT(t) ((t)->rootp->uart_top__DOT__u_tx__DOT__clk_cnt) // 5.x の中の名前
#elif defined(WAY_OLD)
  #include "Vuart_top.h"
  typedef Vuart_top Top;
  #define TX_CNT(t) ((t)->uart_top__DOT__u_tx__DOT__clk_cnt)        // 4.x の中の名前
#elif defined(WAY_PUBLIC)
  #include "Vuart_top.h"
  #include "Vuart_top_uart_top.h"
  #include "Vuart_top_uart_tx.h"
  typedef Vuart_top Top;
  #define TX_CNT(t) ((t)->uart_top->u_tx->clk_cnt)                  // verilator public
#endif

static void tick(Top* t) { t->clk = 0; t->eval(); t->clk = 1; t->eval(); }

int main() {
    Top* t = new Top;
    t->rst = 1; t->tx_valid = 0; t->tx_data = 0; tick(t); t->rst = 0;
    t->tx_data = 0x41; t->tx_valid = 1; tick(t); t->tx_valid = 0;   // step 1
    for (int s = 2; s <= 20; s++) {
        tick(t);
        if (s <= 3 || s >= 16) printf("step %2d clk_cnt=%2u txd=%u\n", s, (unsigned)TX_CNT(t), (unsigned)t->o_txd);
    }
    delete t;
    return 0;
}
```

- `WAY_ROOTP` と `WAY_OLD` は、Verilator が中の信号に付けた名前 (`uart_top__DOT__u_tx__DOT__clk_cnt`) を直に読む。`__DOT__` は階層の `.` を置き換えた印
- `WAY_PUBLIC` は、`uart_tx.v` の宣言を `reg [15:0] clk_cnt /*verilator public*/;` に書き換えたもの。中のファイルに手を入れる
- ビルドは `verilator --cc --exe --build <Verilog のファイル> read_cnt.cpp -CFLAGS -DWAY_… --top-module <最上位>`

## 見るべき値

| 書き方 | 4.200 (2021) | 5.042 (2025) | 5.048 (2026) | 中のファイルを直すか |
| --- | --- | --- | --- | --- |
| 薄いラッパ `top->o_tx_cnt` | 通る | 通る | 通る | 直さない |
| 中の名前 (5.x の形) `top->rootp->…` | 通らない (`Vuart_top___024root.h` が無い) | 通る | 通る | 直さない |
| 中の名前 (4.x の形) `top->…` | 通る | 通らない (`Vuart_top` に `uart_top__DOT__u_tx__DOT__clk_cnt` が無い) | 通らない | 直さない |
| `/*verilator public*/` `top->uart_top->u_tx->clk_cnt` | 通る | 通る | 通る | 直す |

通った書き方は、どれも同じ値を出した (step 2 で `clk_cnt=14`、step 3 で 13、step 16 で 0)。

- 中の名前は、4.x では最上位のクラスに直に並び、5.x では `rootp` の先に移った。**同じ C++ が、版を上げただけでビルドできなくなる**
- 中の名前は、階層が変わっても変わる。ラッパで包んだ後は、同じ信号が `uart_probe_top__DOT__u_core__DOT__u_tx__DOT__clk_cnt` になった (生成されたヘッダで確かめた)
- `/*verilator public*/` は 3 つの版で通った。ただし、中のファイルを書き換える。しかも、ハーネスが読むクラスの名前 (`Vuart_top_uart_tx`) とその道筋 (`uart_top->u_tx`) は、モジュールとインスタンスの名前で決まる。public を付けると `uart_tx` が別のクラスに分かれ、受信機の側の名前まで `__PVT__u_rx__DOT__clk_cnt` に変わった (5.042 で生成されたヘッダで確かめた)
- ラッパのポートの名前は、自分で決めた名前なので版にも階層にも引きずられない

soft-fpga の設計メモ (`docs/90-rtlscope-OBSERVEマクロ設計メモ.md`) も、`/*verilator public*/` (選択肢 A) とラッパ (選択肢 B) を並べ、A を「Verilator のバージョンに依存しない」としている。見るべき値の表の結果はそれと合う。
4-5 のラッパは、中の信号を階層の名前で最上位のポートまで引き上げる形で、メモの B (下の階層に置く観測用のモジュール) とは置き場所が違う。

## シミュレーションでの確かめ (対象外を含む)

soft-fpga の ac6b663 の `examples/03-uart` の 3 ファイルと 4-5 のラッパ (`sim/05-probe-wrapper.v`) を、Verilator 5.042 で組んだ。
4 通りの読み方は本文の `read_cnt.cpp` (`sim/05-probe-wrapper-tb.cpp`) を `-DWAY_…` で切り替えてビルドした。
入っている Verilator は 5.042 だけなので、4.200 と 5.048 の列は走らせ直していない。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| 薄いラッパ (5.042) | 通る。step 2 で `clk_cnt=14`、3 で 13、16 で 0 | 同じ | 合った |
| 中の名前 (5.x の形) `rootp->…` (5.042) | 通る、同じ値 | 同じ | 合った |
| 中の名前 (4.x の形) (5.042) | 通らない (`uart_top__DOT__u_tx__DOT__clk_cnt` が無い) | 同じエラー | 合った |
| `/*verilator public*/` (5.042) | 通る、同じ値 | 同じ | 合った |
| 4.200・5.048 の列 | 表のとおり | その版が要る | 対象外 |

## 出典

自作。読んだ例は [tommie-jp/soft-fpga](https://github.com/tommie-jp/soft-fpga) の `examples/03-uart`。
中の信号の読み方の選択肢は、同リポジトリの `docs/90-rtlscope-OBSERVEマクロ設計メモ.md`。
Verilator 4.200 は Docker Hub の `verilator/verilator:4.200` で動かした。
