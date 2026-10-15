#include <cstdio>
#include "Vsigned_demo.h"

static int as_signed4(int v) { return v >= 8 ? v - 16 : v; }

int main() {
    Vsigned_demo top;
    int bad = 0;
    std::printf("# a 符号なし 符号付き ext_zero ext_sign neg 符号付き lsr asr same\n");
    for (int a = 0; a < 16; a++) {
        top.a = a;
        top.b = 0;
        top.eval();
        std::printf("%x %2d %3d %02x %02x %x %3d %x %x %d\n", a, a, as_signed4(a),
                    top.ext_zero, top.ext_sign, top.neg, as_signed4(top.neg),
                    top.lsr, top.asr, top.same);
        if (!top.same) bad++;
        if (as_signed4(top.ext_sign & 0xF) != as_signed4(a)) bad++;
        if (as_signed4(top.asr) != (as_signed4(a) >> 1)) bad++;
    }
    std::printf("# a b lt_u lt_s\n");
    const int a_list[] = {3, 7, 15, 8, 12};
    const int b_list[] = {5, 15, 1, 7, 12};
    for (int i = 0; i < 5; i++) {
        top.a = a_list[i];
        top.b = b_list[i];
        top.eval();
        std::printf("%x %x %d %d\n", top.a, top.b, top.lt_u, top.lt_s);
    }
    std::printf("食い違い: %d 件\n", bad);
    return bad;
}
