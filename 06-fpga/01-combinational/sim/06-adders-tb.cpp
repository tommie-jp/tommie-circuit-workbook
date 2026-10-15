#include <cstdio>
#include "Vfull_adder.h"

int main() {
    Vfull_adder top;
    std::printf("# a b cin sum cout\n");
    for (int i = 0; i < 8; i++) {
        top.a   = (i >> 2) & 1;
        top.b   = (i >> 1) & 1;
        top.cin = i & 1;
        top.eval();
        std::printf("%x %x %x %x %x\n", top.a, top.b, top.cin, top.sum, top.cout);
    }
    return 0;
}
