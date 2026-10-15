#include <cstdio>
#include "Vcmp4_cmp.h"

int main() {
    Vcmp4_cmp top;
    // 先に、見るための 6 通り
    const int a_list[] = {5, 5, 3, 8, 7, 15};
    const int b_list[] = {5, 3, 9, 7, 8, 0};
    std::printf("# a b eq gt lt same\n");
    for (int i = 0; i < 6; i++) {
        top.a = a_list[i];
        top.b = b_list[i];
        top.eval();
        std::printf("%x %x %d %d %d %d\n", top.a, top.b, top.eq, top.gt, top.lt, top.same);
    }
    // 次に、256 通りすべてを比べる
    int bad = 0;
    int ones = 0;
    for (int a = 0; a < 16; a++) {
        for (int b = 0; b < 16; b++) {
            top.a = a;
            top.b = b;
            top.eval();
            if (!top.same) bad++;
            if (top.eq + top.gt + top.lt != 1) bad++;   // 3 本のうち 1 本だけが 1
            if (top.eq != (a == b) || top.gt != (a > b) || top.lt != (a < b)) bad++;
            ones++;
        }
    }
    std::printf("%d 通りを試し、食い違いは %d 件\n", ones, bad);
    return bad;
}
