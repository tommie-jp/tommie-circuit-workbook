// program: 01-circuits/11-microcontrollers/01-pico-blink-1.c
// 11-1: GP15 を 500 ms ごとに反転する (周期 1 s)。
#include "pico/stdlib.h"
int main(void) {
    mock_reset(0);
    mock_run(5200000);                                  /* 5.2 s */
    mock_check(M.dir_out[15] && M.init[15], "GP15 が出力に設定されていない");
    mock_check(M.nev >= 10, "反転が少ない: %u", M.nev);
    for (uint i = 1; i < M.nev; i++)
        mock_check(M.ev[i].t_us - M.ev[i - 1].t_us == 500000, "反転の間隔が 500 ms でない (%u 番目: %llu us)", i, (unsigned long long)(M.ev[i].t_us - M.ev[i - 1].t_us));
    mock_check(M.ev[0].level == 1 && M.ev[0].t_us == 0, "最初は H で点灯する");
    return mock_report();
}
