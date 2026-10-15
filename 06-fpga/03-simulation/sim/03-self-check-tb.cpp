#include <cstdio>
#include "Vcounter4.h"
int main() {
    Vcounter4 top;
    FILE* wave = std::fopen("wave.txt", "w");
    std::fprintf(wave, "# clk rst_n q exp\n");
    int expected = 0;
    int errors = 0;
    top.clk = 0;
    top.rst_n = 0;
    top.eval();
    for (int cycle = 0; cycle < 24; cycle++) {
        if (cycle == 2) top.rst_n = 1;
        expected = top.rst_n ? (expected + 1) & 0xF : 0;
        top.clk = 1;
        top.eval();
        std::fprintf(wave, "%x %x %x %x\n", top.clk, top.rst_n, top.q, expected);
        if (top.q != expected) {
            errors++;
            if (errors <= 3) {
                std::printf("NG: クロック %d で q=%d、期待は %d\n", cycle, top.q, expected);
            }
        }
        top.clk = 0;
        top.eval();
        std::fprintf(wave, "%x %x %x %x\n", top.clk, top.rst_n, top.q, expected);
    }
    std::fclose(wave);
    if (errors == 0) { std::printf("PASS: 24 クロックで不一致 0 件\n"); return 0; }
    std::printf("FAIL: 24 クロックで不一致 %d 件\n", errors);
    return 1;
}
