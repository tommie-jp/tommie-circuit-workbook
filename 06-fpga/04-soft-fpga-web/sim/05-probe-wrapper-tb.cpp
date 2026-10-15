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
