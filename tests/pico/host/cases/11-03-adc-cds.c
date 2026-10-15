// program: 01-circuits/11-microcontrollers/03-adc-cds-1.c
// 11-3: ADC0 (GP26) を 500 ms ごとに読み、値と電圧 (値 × 3.3 / 4096) を出す。
#include "pico/stdlib.h"
#include <string.h>
int main(void) {
    mock_reset(0);
    M.adc_value = 2048;                                 /* 中点 */
    mock_run(1100000);
    mock_check(M.adc_inited && M.adc_input == 0, "adc_init と入力 0");
    mock_check(M.adc_gpio_mask == 1u << 26, "GP26 だけを ADC にする (mask=%x)", M.adc_gpio_mask);
    mock_check(strncmp(M.out, "2048 1.650\n2048 1.650\n", 22) == 0, "2048 → 1.650 V を 500 ms ごと: [%s]", M.out);
    return mock_report();
}
