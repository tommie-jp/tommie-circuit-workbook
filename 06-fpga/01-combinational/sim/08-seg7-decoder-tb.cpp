#include <cstdio>
#include "Vseg7_cmp.h"

int main() {
    Vseg7_cmp top;
    int bad = 0;
    std::printf("# d seg same\n");
    for (int d = 0; d < 16; d++) {
        top.d = d;
        top.eval();
        std::printf("%X %02x %d\n", top.d, top.seg, top.same);
        if (!top.same) bad++;
    }
    std::printf("same が 0 の入力: %d 通り\n", bad);
    return bad;
}
