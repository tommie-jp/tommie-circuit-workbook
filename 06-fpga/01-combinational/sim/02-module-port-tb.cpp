#include <cstdio>
#include "Vparity3.h"

int main() {
    Vparity3 top;
    std::printf("# a b c y\n");
    for (int i = 0; i < 8; i++) {
        top.a = (i >> 2) & 1;
        top.b = (i >> 1) & 1;
        top.c = i & 1;
        top.eval();
        std::printf("%x %x %x %x\n", top.a, top.b, top.c, top.y);
    }
    return 0;
}
