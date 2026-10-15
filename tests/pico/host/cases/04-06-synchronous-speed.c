// program: 04-denken/09-rotating-machines/06-synchronous-speed-1.c
// 電験 9-6: 3 相を 7 Hz で出す。V は U より 120° (2 ステップ) 遅れ、W はさらに 120° 遅れる。
#include "pico/stdlib.h"
#include <math.h>
static double first_rise(uint pin) {
    for (uint i = 0; i < M.nev; i++) if (M.ev[i].pin == pin && M.ev[i].level) return (double)M.ev[i].t_us;
    return -1;
}
int main(void) {
    mock_reset(0);
    mock_run(2000000);                                  /* 2 s */
    for (uint p = 2; p <= 4; p++) mock_check(M.dir_out[p], "GP%u を出力にする", p);
    /* U の立ち上がりの間隔 = 周期。STEP_US = 1000000/42 = 23809 を 6 ステップ */
    double t0 = -1, t1 = -1;
    for (uint i = 0; i < M.nev; i++) if (M.ev[i].pin == 2 && M.ev[i].level) { if (t0 < 0) t0 = (double)M.ev[i].t_us; else if (t1 < 0) t1 = (double)M.ev[i].t_us; }
    double period = t1 - t0, f = 1e6 / period;
    mock_check(fabs(f - 7.0) < 0.01, "電源周波数 7 Hz: %.4f Hz", f);
    double step = 1000000 / 42;                         /* 整数の割り算 */
    double du = first_rise(2), dv = first_rise(3), dw = first_rise(4);
    mock_check(fabs((dv - du) - 2 * step) < 1.5 * step || fabs((dv - du) - 4 * step) < 1.5 * step, "V は U から 120° の位置: %.0f us", dv - du);
    mock_check(du >= 0 && dv >= 0 && dw >= 0, "3 相とも立ち上がる");
    return mock_report();
}
