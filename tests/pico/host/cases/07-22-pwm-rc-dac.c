// program: 02-analog-discovery/07-logic/22-pwm-rc-dac-1.c
// 7-22 (Analog Discovery): GP16 (スライス 0 の A) に 146.48 kHz の 10 ビット PWM。0・256・512・768 を 20 ms ずつ。
#include "pico/stdlib.h"
#include "hardware/pwm.h"
#include <math.h>
static uint level_at(uint64_t t_us) { mock_reset(0); mock_run(t_us); return M.pwm[0].level[0]; }
int main(void) {
    mock_reset(0);
    mock_run(10000);
    mock_check(pwm_gpio_to_slice_num(16) == 0 && pwm_gpio_to_channel(16) == 0, "GP16 はスライス 0 の A");
    mock_check(M.func[16] == GPIO_FUNC_PWM, "GP16 を PWM にする");
    mock_check(M.pwm[0].wrap == 1023 && M.pwm[0].clkdiv == 1.0f, "wrap 1023・clkdiv 1");
    mock_check(fabs(mock_pwm_period_s(0) - 1024.0 / 150e6) < 1e-12, "周期 6.827 µs: %g s", mock_pwm_period_s(0));
    mock_check(M.pwm[0].enabled, "スライスを有効にする");
    const uint64_t t[] = {10000, 30000, 50000, 70000, 90000};
    const uint want[] = {0, 256, 512, 768, 0};
    for (int i = 0; i < 5; i++) {
        uint l = level_at(t[i]);
        mock_check(l == want[i], "%llu µs でレベル %u: %u", (unsigned long long)t[i], want[i], l);
    }
    level_at(50000);
    mock_check(fabs(mock_pwm_high_s(0, 0) / mock_pwm_period_s(0) - 0.5) < 1e-9, "レベル 512 でデューティ 50 %%");
    return mock_report();
}
