#include "pico/stdlib.h"
#include "Vblink.h"
// 5-2: main.cpp (5-1) と同じ主ループを PC で回し、LED の変わる周回の数を数える
static long loops = 0, lastchg = 0;
static void hook(uint p, int v) {
    if (p == 14) { printf("LED=%d at loop %ld (%ld loops after previous)\n", v, loops, loops - lastchg); lastchg = loops; }
}
int main() {
    g_hook = hook;
    gpio_init(14); gpio_set_dir(14, GPIO_OUT);
    VerilatedContext ctx; Vblink top{&ctx};
    top.rst = 1;
    for (int i = 0; i < 2; i++) { top.clk = 0; top.eval(); top.clk = 1; top.eval(); }
    top.rst = 0;
    while (loops < 200000) {
        top.clk = 0; top.eval();
        top.clk = 1; top.eval();
        loops++;
        gpio_put(14, top.led);
    }
}
