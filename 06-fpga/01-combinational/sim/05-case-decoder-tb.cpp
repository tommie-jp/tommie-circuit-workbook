#include <cstdio>
#include "Vdecoder2to4.h"

int main() {
    Vdecoder2to4 top;
    std::printf("# a y\n");
    for (int a = 0; a < 4; a++) {
        top.a = a;
        top.eval();
        std::printf("%x %x\n", top.a, top.y);
    }
    return 0;
}
