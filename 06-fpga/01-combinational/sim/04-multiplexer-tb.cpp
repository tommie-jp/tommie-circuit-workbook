#include <cstdio>
#include "Vmux2.h"

int main() {
    Vmux2 top;
    // {sel, a, b} を 6 通り
    const int sel_list[] = {0, 1, 0, 1, 1, 0};
    const int a_list[]   = {0x3, 0x3, 0x9, 0x9, 0x9, 0x9};
    const int b_list[]   = {0xC, 0xC, 0xC, 0xC, 0x5, 0x5};
    std::printf("# sel a b y\n");
    for (int i = 0; i < 6; i++) {
        top.sel = sel_list[i];
        top.a = a_list[i];
        top.b = b_list[i];
        top.eval();
        std::printf("%x %x %x %x\n", top.sel, top.a, top.b, top.y);
    }
    return 0;
}
