// program: 01-circuits/11-microcontrollers/12-decoupling-ground-1.c
// 11-12: GP15 (スライス 7 の B) を 1 MHz・H 50 % の PWM に。
#include "pico/stdlib.h"
#include "hardware/pwm.h"
#include <math.h>
int main(void) {
    mock_reset(0);
    mock_run(1000);
    double T = mock_pwm_period_s(7);
    mock_check(M.func[15] == GPIO_FUNC_PWM && M.pwm[7].enabled, "GP15 が PWM");
    mock_check(fabs(T - 1e-6) < 1e-12, "1 MHz: %g s", T);
    mock_check(fabs(mock_pwm_high_s(7, 1) / T - 0.5) < 1e-9, "H 50 %%");
    return mock_report();
}
