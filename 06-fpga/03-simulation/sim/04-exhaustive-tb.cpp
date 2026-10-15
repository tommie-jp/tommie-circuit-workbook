// tb_exhaustive.cpp
#include <cstdio>
#include "Vadder4_cmp.h"

int main() {
    Vadder4_cmp top;
    int tried = 0;
    int errors = 0;
    for (int a = 0; a < 16; a++) {
        for (int b = 0; b < 16; b++) {
            for (int cin = 0; cin < 2; cin++) {
                top.a = a;
                top.b = b;
                top.cin = cin;
                top.eval();
                const int expected = a + b + cin;                 // C++ の足し算が正解
                const int got = (top.cout << 4) | top.sum;
                tried++;
                if (got != expected || !top.same) {
                    errors++;
                    if (errors <= 3) {
                        std::printf("NG: %d + %d + %d = %d のはずが %d (same=%d)\n",
                                    a, b, cin, expected, got, top.same);
                    }
                }
            }
        }
    }
    std::printf("%d 通りを試して、不一致 %d 件\n", tried, errors);
    return errors == 0 ? 0 : 1;
}
