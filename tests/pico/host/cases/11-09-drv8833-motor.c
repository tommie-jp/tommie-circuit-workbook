// program: 01-circuits/11-microcontrollers/09-drv8833-motor-1.c
// 11-9: GP14 (AIN1)・GP15 (AIN2) をスライス 7 の 20 kHz の PWM に。前進 50 % 2 s → ブレーキ 1 s → 後進 50 % 2 s → ブレーキ 1 s。
#include "pico/stdlib.h"
#include "hardware/pwm.h"
#include <math.h>
static void at(uint64_t t_us, double a, double b, const char *what) {
    mock_reset(0);
    mock_run(t_us);
    double T = mock_pwm_period_s(7);
    mock_check(fabs(T - 50e-6) < 1e-9, "%s: 周期 50 µs: %g", what, T);
    mock_check(M.func[14] == GPIO_FUNC_PWM && M.func[15] == GPIO_FUNC_PWM && M.pwm[7].enabled, "%s: GP14・GP15 が PWM", what);
    double ha = mock_pwm_high_s(7, 0) / T, hb = mock_pwm_high_s(7, 1) / T;
    mock_check(fabs(ha - a) < 1e-3 && fabs(hb - b) < 1e-3, "%s: AIN1 %.3f・AIN2 %.3f", what, ha, hb);
}
int main(void) {
    at(1000000, 1.0, 0.5, "前進 50 %");
    at(2500000, 1.0, 1.0, "ブレーキ");
    at(4000000, 0.5, 1.0, "後進 50 %");
    at(5500000, 1.0, 1.0, "ブレーキ");
    return mock_report();
}
