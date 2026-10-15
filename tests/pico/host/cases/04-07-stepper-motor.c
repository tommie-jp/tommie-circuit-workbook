// program: 04-denken/09-rotating-machines/07-stepper-motor-1.c
// 電験 9-7: 2 相励磁 0x3→0x6→0xC→0x9 を 200 Hz で 2048 ステップ出し、止めるときは全相 L。
#include "pico/stdlib.h"
int main(void) {
    mock_reset(0);
    mock_run(12000000);                                 /* 2048 / 200 = 10.24 s の後 */
    for (uint p = 2; p < 6; p++) mock_check(M.dir_out[p], "GP%u を出力にする", p);
    mock_check(!M.level[2] && !M.level[3] && !M.level[4] && !M.level[5], "最後は全相 L");
    /* 最初の 4 ステップの並び: 0x3 0x6 0xC 0x9 */
    uint32_t state = 0; uint steps = 0; uint32_t seq[8]; uint64_t last = ~0ull;
    for (uint i = 0; i < M.nev && steps < 5; i++) {
        if (M.ev[i].t_us != last) { if (last != ~0ull) seq[steps++] = state; last = M.ev[i].t_us; }
        state = (state & ~(1u << M.ev[i].pin)) | ((uint32_t)M.ev[i].level << M.ev[i].pin);
    }
    const uint32_t want[4] = {0x3, 0x6, 0xC, 0x9};
    for (uint k = 0; k < 4 && k < steps; k++) mock_check((seq[k] >> 2) == want[k], "ステップ %u: %x", k, seq[k] >> 2);
    /* 全体の長さ: 最後の変化は 2048 ステップ目の後 = 10.24 s */
    mock_check(M.ev[M.nev - 1].t_us >= 10200000 && M.ev[M.nev - 1].t_us <= 10300000, "10.24 s で止まる: %llu us", (unsigned long long)M.ev[M.nev - 1].t_us);
    return mock_report();
}
