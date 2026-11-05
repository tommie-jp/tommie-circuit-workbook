// program: 02-analog-discovery/07-logic/26-adc-sampling-alias-1.c
// 7-26 (Analog Discovery): GP26 を 10 kS/s で読み、コード / 4 を GP16 の PWM のレベルにする。
// 9.5 kHz・1 V (peak)・中心 1.65 V の正弦を与え、レベルの並びが 500 Hz (20 標本で一巡) になることを見る。
#include "pico/stdlib.h"
#include "hardware/adc.h"
#include "hardware/pwm.h"
#include <math.h>
#define NMAX 4000
static uint64_t t_s[NMAX]; static uint lv[NMAX]; static uint n = 0;
static uint last = 0xffff; static uint64_t last_read = 0;
static uint16_t code_at(double t_s_) { return (uint16_t)lround(2048.0 + 1241.0 * sin(2 * M_PI * 9500.0 * t_s_)); }
static void feed(void) {
    /* 読む時刻 (次の 1 µs 後) の値を置く。読んだ後に変わったレベルを記録する */
    if (M.now_us >= 100 && M.pwm[0].level[0] != last && n < NMAX && M.now_us != last_read) {   /* 最初の標本 (100 µs) から */
        last = M.pwm[0].level[0]; t_s[n] = M.now_us; lv[n++] = last; last_read = M.now_us;
    }
    M.adc_value = code_at((double)(M.now_us + 1) * 1e-6);
}
int main(void) {
    mock_reset(0);
    M.idle_hook = feed;
    mock_run(200000);                                   /* 200 ms */
    mock_check(M.adc_inited && M.adc_input == 0 && M.adc_gpio_mask == 1u << 26, "GP26 を ADC0 にする");
    mock_check(M.func[16] == GPIO_FUNC_PWM && M.pwm[0].wrap == 1023 && M.pwm[0].enabled, "GP16 の PWM・wrap 1023");
    mock_check(fabs(mock_pwm_period_s(0) - 1024.0 / 150e6) < 1e-12, "PWM の周期 6.827 µs");
    mock_check(n > 1000, "レベルの変化が十分ある: %u", n);
    uint bad_dt = 0, bad_lv = 0;
    for (uint i = 1; i < n; i++) {
        if ((t_s[i] - t_s[i - 1]) % 100 != 0) bad_dt++;
        uint want = code_at((double)t_s[i] * 1e-6) >> 2;
        if (lv[i] != want) bad_lv++;
    }
    mock_check(bad_dt == 0, "標本は 100 µs の刻み: 外れ %u", bad_dt);
    mock_check(bad_lv == 0, "レベル = その時刻のコード / 4: 外れ %u", bad_lv);
    /* 500 Hz に見える: 標本 k と k + 20 (2 ms 後) のレベルがほぼ同じ、k と k + 10 (1 ms 後) は中心の反対 */
    double d20 = 0, d10 = 0;
    for (uint i = 0; i + 20 < n; i++) {
        d20 = fmax(d20, fabs((double)lv[i + 20] - lv[i]));
        d10 = fmax(d10, fabs((double)lv[i + 10] + lv[i] - 1024.0));
    }
    mock_check(d20 <= 2 && d10 <= 2, "20 標本 (2 ms) で一巡 = 500 Hz: 差 %.0f・%.0f", d20, d10);
    return mock_report();
}
