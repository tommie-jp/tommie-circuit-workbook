// program: 01-circuits/11-microcontrollers/04-pwm-led-servo-2.c
// 11-4 図 サーボ: GP14 (スライス 7 の A) に周期 20 ms、パルス幅 1.5 → 1.0 → 2.0 ms。
#include "pico/stdlib.h"
#include "hardware/pwm.h"
#include <math.h>
int main(void) {
    mock_reset(0);
    mock_run(500000);                                   /* 最初の 1 s の途中 */
    uint s = pwm_gpio_to_slice_num(14);
    mock_check(s == 7 && pwm_gpio_to_channel(14) == 0, "GP14 はスライス 7 の A");
    mock_check(M.func[14] == GPIO_FUNC_PWM, "GP14 を PWM にする");
    mock_check(fabs(mock_pwm_period_s(s) - 0.020) < 1e-9, "周期 20 ms: %g s", mock_pwm_period_s(s));
    mock_check(fabs(mock_pwm_high_s(s, 0) - 0.0015) < 1e-9, "最初のパルス 1.5 ms: %g s", mock_pwm_high_s(s, 0));
    mock_run(1500000);                                  /* 続きは最初から回し直す */
    mock_reset(0);
    mock_run(1500000);
    mock_check(fabs(mock_pwm_high_s(s, 0) - 0.0010) < 1e-9, "1 s 後 1.0 ms: %g s", mock_pwm_high_s(s, 0));
    mock_reset(0);
    mock_run(2500000);
    mock_check(fabs(mock_pwm_high_s(s, 0) - 0.0020) < 1e-9, "2 s 後 2.0 ms: %g s", mock_pwm_high_s(s, 0));
    mock_check(2000 <= 19999, "パルス幅が周期の内");
    return mock_report();
}
