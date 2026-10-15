// 11-3 の試験台。ラーメンタイマーの TD4.v (03-td4-timer.v) を Verilator で回し、
// リセットのあと OUT が変わるまでのクロックの数を数えて、式の値と比べる。
//   内側のループ  ADD A,1 / JNC     : 16 回 x 2 命令 = 32 クロック
//   外側のループ  内側 + ADD B,1 / JNC : 16 回 x (32 + 2) = 544 クロック
//   OUT 0001 は 544、OUT 0011 は 544 + 1 + 544 = 1089、OUT 1111 は 1089 + 1 + 544 = 1634 番めのクロック
#include <cstdio>
#include "VTD4.h"

int main() {
    VTD4 top;
    top.in_port = 0;
    top.reset_n = 0; top.clock = 0; top.eval();
    top.clock = 1; top.eval();          // リセット中の立ち上がり (5-8 の主ループと同じく 1 回)
    top.clock = 0; top.eval();
    top.reset_n = 1; top.eval();

    const long inner = 16 * 2, outer = 16 * (inner + 2);
    const long want[3] = {outer, outer + 1 + outer, outer + 1 + outer + 1 + outer};
    const unsigned want_out[3] = {0x1, 0x3, 0xF};
    long got[3] = {-1, -1, -1};
    unsigned last = top.out_port;
    int k = 0;
    long n = 0;
    for (n = 0; n < 3000 && k < 3; n++) {        // n 番めの立ち上がり (0 から数える) で番地 PC の命令を実行
        top.clock = 1; top.eval();
        if (top.out_port != last) { got[k] = n; if (top.out_port != want_out[k]) got[k] = -2; k++; last = top.out_port; }
        top.clock = 0; top.eval();
    }
    int fails = 0;
    for (int i = 0; i < 3; i++) {
        const bool ok = got[i] == want[i];
        fails += !ok;
        printf("%s OUT が %X になるのは %ld 番めのクロック (式: %ld)\n", ok ? "PASS" : "FAIL", want_out[i], got[i], want[i]);
    }
    // 止まったまま (PC = F、OUT = F) か、1000 クロック見る
    bool halted = true;
    for (int i = 0; i < 1000; i++) {
        top.clock = 1; top.eval(); top.clock = 0; top.eval();
        if (top.pc_out != 0xF || top.out_port != 0xF) halted = false;
    }
    printf("%s OUT 1111 のあと 1000 クロック、PC = F・OUT = F のまま\n", halted ? "PASS" : "FAIL");
    fails += !halted;

    const double T_timer = 2 * 55080e-6, T_fast = 2 * 500e-6, T_10 = 0.1;
    for (int i = 0; i < 3; i++)
        printf("  OUT %X: %4ld クロック -> %.3f s (110.16 ms) / %.3f s (10 Hz) / %.3f s (1 kHz)\n", want_out[i], got[i],
               got[i] * T_timer, got[i] * T_10, got[i] * T_fast);
    printf(fails ? "FAILED %d\n" : "ALL PASS\n", fails);
    return fails ? 1 : 0;
}
