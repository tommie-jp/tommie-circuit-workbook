// program: 02-analog-discovery/07-logic/23-clock-overshoot-ringing-1.c
// 7-23 (Analog Discovery): GP16 に 100 kHz・Duty 50 % のクロック。12 mA 駆動・速い立ち上がり。
#include "pico/stdlib.h"
#include "hardware/pwm.h"
#include <math.h>
int main(void) {
    mock_reset(0);
    mock_run(1000);
    uint s = pwm_gpio_to_slice_num(16);
    mock_check(s == 0 && M.func[16] == GPIO_FUNC_PWM, "GP16 はスライス 0 の PWM");
    mock_check(fabs(mock_pwm_period_s(s) - 10e-6) < 1e-12, "周期 10 µs (100 kHz): %g s", mock_pwm_period_s(s));
    mock_check(fabs(mock_pwm_high_s(s, 0) / mock_pwm_period_s(s) - 0.5) < 1e-9, "デューティ 50 %%");
    mock_check(M.pwm[s].enabled, "スライスを有効にする");
    mock_check(M.drive[16] == GPIO_DRIVE_STRENGTH_12MA && M.slew[16] == GPIO_SLEW_RATE_FAST, "12 mA・速い立ち上がり");
    return mock_report();
}
