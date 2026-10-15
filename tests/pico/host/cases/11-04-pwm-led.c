// program: 01-circuits/11-microcontrollers/04-pwm-led-servo-1.c
// 11-4 図 LED: GP15 (スライス 7 の B) に 1 kHz、デューティを 16 段階で 50 ms ごとに上げる。
#include "pico/stdlib.h"
#include "hardware/pwm.h"
#include <math.h>
int main(void) {
    mock_reset(0);
    mock_run(900000);                                   /* 16 段 × 50 ms = 800 ms の後 */
    uint s = pwm_gpio_to_slice_num(15);
    mock_check(s == 7 && pwm_gpio_to_channel(15) == 1, "GP15 はスライス 7 の B");
    mock_check(M.func[15] == GPIO_FUNC_PWM, "GP15 を PWM にする");
    mock_check(fabs(mock_pwm_period_s(s) - 0.001) < 1e-9, "周期 1 ms (1 kHz): %g s", mock_pwm_period_s(s));
    mock_check(M.pwm[s].enabled, "スライスを有効にする");
    /* 最後の段: step 15 → 1000 × 15 / 16 = 937 カウント */
    mock_check(M.pwm[s].level[1] == 937, "最後のレベル 937: %u", M.pwm[s].level[1]);
    mock_check(fabs(mock_pwm_high_s(s, 1) / mock_pwm_period_s(s) - 0.937) < 1e-9, "デューティ 93.7 %%: %.12f", mock_pwm_high_s(s, 1) / mock_pwm_period_s(s));
    return mock_report();
}
