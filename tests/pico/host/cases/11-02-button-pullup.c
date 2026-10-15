// program: 01-circuits/11-microcontrollers/02-button-pullup-1.c
// 11-2: GP16 を入力にし、200 ms ごとに値を printf する。離している間は 1、押している間は 0。
#include "pico/stdlib.h"
#include <string.h>
int main(void) {
    mock_reset(0);
    M.in_value[16] = true;                              /* 外付けの R1 で H */
    mock_run(1000000);
    mock_check(!M.dir_out[16], "GP16 が入力でない");
    mock_check(M.init[16], "gpio_init が無い");
    mock_check(!M.pull_up[16], "内蔵プルアップを使わない (外付け R1)");
    mock_check(strncmp(M.out, "1\n1\n1\n1\n1\n", 10) == 0, "1 s で 5 回 \"1\" を出す: [%s]", M.out);
    return mock_report();
}
