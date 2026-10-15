// program: 06-fpga/00-tools/04-ad3-logic-connect-1.c
// FPGA 冊 0-4: GP14・GP15 に 2 ビットの 2 進カウンタを 1 ms ごとに出す (bit0 は 1 ms、bit1 は 2 ms ごとに反転)。
#include "pico/stdlib.h"
int main(void) {
    mock_reset(0);
    mock_run(20000);
    mock_check(M.dir_out[14] && M.dir_out[15], "GP14・GP15 は出力");
    uint64_t last0 = 0, last1 = 0; uint n0 = 0, n1 = 0;
    for (uint i = 0; i < M.nev; i++) {
        if (M.ev[i].pin == 14) { if (n0++) mock_check(M.ev[i].t_us - last0 == 1000, "bit0 は 1 ms ごと"); last0 = M.ev[i].t_us; }
        if (M.ev[i].pin == 15) { if (n1++) mock_check(M.ev[i].t_us - last1 == 2000, "bit1 は 2 ms ごと"); last1 = M.ev[i].t_us; }
    }
    mock_check(n0 >= 15 && n1 >= 8, "反転の数: %u %u", n0, n1);
    return mock_report();
}
