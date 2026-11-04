// program: 01-circuits/11-microcontrollers/11-usb-vsys-power-1.c
// 11-11: GP24 (VBUS) を入力、GP29 を ADC3 (VSYS/3)。VSYS と VBUS の有無を 1 s ごとに表示。
#include "pico/stdlib.h"
#include "hardware/adc.h"
#include <string.h>
int main(void) {
    mock_reset(0);
    M.adc_value = 1970;                 /* 1970 × 3.3 / 4096 × 3 = 4.76 V */
    mock_run(2500000);
    mock_check(M.adc_inited && (M.adc_gpio_mask & (1u << 29)) && M.adc_input == 3, "GP29 を ADC3");
    mock_check(M.init[24] && !M.dir_out[24], "GP24 を入力");
    mock_check(strcmp(M.out, "VSYS 4.76 V  VBUS yes\nVSYS 4.76 V  VBUS yes\nVSYS 4.76 V  VBUS yes\n") == 0, "1 s ごと: [%s]", M.out);
    mock_reset(0);
    M.adc_value = 1970; M.in_value[24] = false;
    mock_run(500000);
    mock_check(strcmp(M.out, "VSYS 4.76 V  VBUS no\n") == 0, "USB なし: [%s]", M.out);
    return mock_report();
}
