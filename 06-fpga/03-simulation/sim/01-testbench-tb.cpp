#include <cstdio>
#include "Vcounter4.h"

int main() {
    Vcounter4 top;
    top.clk = 0;
    top.rst_n = 0;
    top.eval();
    std::printf("# clk rst_n q\n");
    std::printf("%x %x %x\n", top.clk, top.rst_n, top.q);
    for (int half = 0; half < 16; half++) {
        if (half == 3) top.rst_n = 1;
        top.clk = !top.clk;
        top.eval();
        std::printf("%x %x %x\n", top.clk, top.rst_n, top.q);
    }
    return 0;
}
