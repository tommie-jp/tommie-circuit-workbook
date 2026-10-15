#include <cstdio>
#include "Vgates.h"

int main() {
    Vgates top;
    std::printf("# a b y_and y_or y_not\n");
    for (int i = 0; i < 4; i++) {
        top.a = (i >> 1) & 1;   // i = 0..3 の上位ビットを a、下位ビットを b に
        top.b = i & 1;
        top.eval();             // 入力を変えたら eval で出力を計算させる
        std::printf("%x %x %x %x %x\n", top.a, top.b, top.y_and, top.y_or, top.y_not);
    }
    return 0;
}
