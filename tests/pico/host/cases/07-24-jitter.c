// program: 02-analog-discovery/07-logic/24-jitter-1.c
// 7-24 (Analog Discovery): GP18 に PWM の 10 kHz、GP16 にソフトの 10 kHz (50 µs ごとに反転)。
// 1.013 ms ごとの割り込み (中で 3 µs 待つ) を待ちのループから呼び、ソフトの端だけが散ることを見る。
#include "pico/stdlib.h"
#include "hardware/pwm.h"
#include <math.h>
#include <stdlib.h>   /* llabs (CI の gcc は宣言が無いと止まる) */
static uint64_t next_isr = 0;
static int64_t seen_delay = 0;   /* 本文の timer は main の中の変数なので、生きているうちに読む */
static void isr(void) {
    if (!M.timer_cb) return;
    seen_delay = M.timer->delay_us;
    if (!next_isr) next_isr = M.now_us + (uint64_t)llabs(M.timer->delay_us);
    if (M.now_us >= next_isr) { next_isr += (uint64_t)llabs(M.timer->delay_us); M.timer_cb(M.timer); }
}
int main(void) {
    mock_reset(0);
    M.idle_hook = isr;
    mock_run(500000);
    uint s = pwm_gpio_to_slice_num(18);
    mock_check(s == 1 && M.func[18] == GPIO_FUNC_PWM, "GP18 はスライス 1 の PWM");
    mock_check(fabs(mock_pwm_period_s(s) - 100e-6) < 1e-12, "PWM の周期 100 µs: %g s", mock_pwm_period_s(s));
    mock_check(fabs(mock_pwm_high_s(s, 0) / mock_pwm_period_s(s) - 0.5) < 1e-9, "PWM 50 %%");
    mock_check(seen_delay == -1013, "割り込みは 1.013 ms ごと: %lld", (long long)seen_delay);
    uint n = 0, odd = 0; uint64_t first = 0, last = 0, prev = 0, mn = 1000, mx = 0;
    for (uint i = 0; i < M.nev; i++) {
        if (M.ev[i].pin != 16) continue;
        uint64_t t = M.ev[i].t_us;
        if (n) { uint64_t d = t - prev; if (d < mn) mn = d; if (d > mx) mx = d; if (d != 50) odd++; } else first = t;
        prev = last = t; n++;
    }
    mock_check(n > 1000, "GP16 の反転が十分ある: %u", n);
    mock_check(fabs((double)(last - first) / (n - 1) - 50.0) < 0.01, "平均の間隔 50 µs: %.4f", (double)(last - first) / (n - 1));
    mock_check(mn >= 46 && mx <= 54, "間隔は 46〜54 µs に収まる: %llu〜%llu", (unsigned long long)mn, (unsigned long long)mx);
    mock_check(odd > 0 && odd < n / 10, "散る反転はたまにある: %u / %u", odd, n);
    return mock_report();
}
