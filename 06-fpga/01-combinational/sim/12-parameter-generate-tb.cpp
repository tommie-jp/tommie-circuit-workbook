#include <cstdio>
#include "Vadder_param_cmp.h"

int main() {
    Vadder_param_cmp top;
    const int a_list[]   = {0x0F, 0xFF, 0x7F, 0xFF, 0x34};
    const int b_list[]   = {0x01, 0x01, 0x7F, 0xFF, 0x1C};
    const int cin_list[] = {0, 0, 1, 1, 0};
    std::printf("# a b cin sum8 cout8 sum4 cout4 same4 same8\n");
    for (int i = 0; i < 5; i++) {
        top.a = a_list[i];
        top.b = b_list[i];
        top.cin = cin_list[i];
        top.eval();
        std::printf("%02x %02x %d %02x %d %x %d %d %d\n", top.a, top.b, top.cin,
                    top.sum8, top.cout8, top.sum4, top.cout4, top.same4, top.same8);
    }
    // 8 ビットの a・b と cin の全部 (2^17 通り) を試す
    long bad = 0;
    long tried = 0;
    for (int a = 0; a < 256; a++) {
        for (int b = 0; b < 256; b++) {
            for (int cin = 0; cin < 2; cin++) {
                top.a = a;
                top.b = b;
                top.cin = cin;
                top.eval();
                int total = a + b + cin;
                int total4 = (a & 0xF) + (b & 0xF) + cin;
                if (!top.same8 || !top.same4) bad++;
                if (top.sum8 != (total & 0xFF) || top.cout8 != (total >> 8)) bad++;
                if (top.sum4 != (total4 & 0xF) || top.cout4 != (total4 >> 4)) bad++;
                tried++;
            }
        }
    }
    std::printf("%ld 通りを試し、食い違いは %ld 件\n", tried, bad);
    return bad != 0;
}
