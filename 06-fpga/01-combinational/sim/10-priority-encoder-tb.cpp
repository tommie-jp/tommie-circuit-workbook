#include <cstdio>
#include "Vpri_cmp.h"

int main() {
    Vpri_cmp top;
    int bad = 0;
    std::printf("# req code valid same\n");
    for (int req = 0; req < 16; req++) {
        top.req = req;
        top.eval();
        std::printf("%x %x %d %d\n", top.req, top.code, top.valid, top.same);
        if (!top.same) bad++;
    }
    std::printf("same が 0 の入力: %d 通り\n", bad);
    return bad;
}
