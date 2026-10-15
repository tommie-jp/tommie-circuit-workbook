#include <cstdio>
#include "Vadder4_cmp.h"

int main() {
    Vadder4_cmp top;
    // {a, b, cin} を 5 通り (全部の入力を試すのは 3-4)
    const int a_list[]   = {5, 9, 9, 7, 15};
    const int b_list[]   = {3, 1, 9, 1, 15};
    const int cin_list[] = {0, 0, 0, 1, 1};
    std::printf("# a b cin sum cout same\n");
    for (int i = 0; i < 5; i++) {
        top.a = a_list[i];
        top.b = b_list[i];
        top.cin = cin_list[i];
        top.eval();
        std::printf("%x %x %x %x %x %x\n", top.a, top.b, top.cin, top.sum, top.cout, top.same);
    }
    return 0;
}
