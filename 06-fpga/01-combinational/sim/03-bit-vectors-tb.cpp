#include <cstdio>
#include "Vbits.h"

int main() {
    Vbits top;
    const int a_list[] = {0, 1, 2, 3};
    const int b_list[] = {0, 2, 3, 1};
    std::printf("# a b cat low msb\n");
    for (int i = 0; i < 4; i++) {
        top.a = a_list[i];
        top.b = b_list[i];
        top.eval();
        std::printf("%x %x %x %x %x\n", top.a, top.b, top.cat, top.low, top.msb);
    }
    return 0;
}
