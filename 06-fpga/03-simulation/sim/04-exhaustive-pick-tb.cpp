// tb_pick.cpp  (図に載せる 6 通り)
#include <cstdio>
#include "Vadder4_cmp.h"

int main() {
    Vadder4_cmp top;
    const int a_list[]   = {0, 15, 15, 8, 7, 15};
    const int b_list[]   = {0, 0, 1, 8, 9, 15};
    const int cin_list[] = {0, 1, 0, 0, 0, 1};
    std::printf("# a b cin sum cout\n");
    for (int i = 0; i < 6; i++) {
        top.a = a_list[i];
        top.b = b_list[i];
        top.cin = cin_list[i];
        top.eval();
        std::printf("%x %x %x %x %x\n", top.a, top.b, top.cin, top.sum, top.cout);
    }
    return 0;
}
