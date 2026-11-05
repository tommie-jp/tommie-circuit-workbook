// program: 02-analog-discovery/07-logic/21-pico-adc-linearity-1.c
// 7-21 (Analog Discovery): GP26 を 10 kS/s で 600,000 回読み、平均・標準偏差・コードごとの度数を出す。
// 入力は 2047・2048・2049・2048 を標本ごとに繰り返す (平均 2048、分散 0.5 → sd 0.71)。
#include "pico/stdlib.h"
#include "hardware/adc.h"
#include <string.h>
static const uint16_t pat[4] = {2047, 2048, 2049, 2048};
static uint64_t first_read_us = 0;
static void feed(void) {
    /* 待ちのループ (tight_loop_contents) から呼ばれる。次の標本の時刻の値を置く */
    M.adc_value = pat[(M.now_us / 100) % 4];
    if (!first_read_us && M.now_us >= 3000000) first_read_us = M.now_us;
}
int main(void) {
    mock_reset(0);
    M.idle_hook = feed;
    mock_run(63500000);                                  /* 3 s + 60 s + 出力 */
    mock_check(M.adc_inited && M.adc_input == 0, "adc_init と入力 0");
    mock_check(M.adc_gpio_mask == 1u << 26, "GP26 だけを ADC にする (mask=%x)", M.adc_gpio_mask);
    mock_check(first_read_us >= 3000000 && first_read_us < 3000200, "3 s 待ってから読み始める: %llu", (unsigned long long)first_read_us);
    mock_check(strncmp(M.out, "N 600000 mean 2048.00 sd 0.71 V 1.6500\n", 39) == 0, "600,000 標本・mean 2048.00・sd 0.71・1.6500 V: [%.60s]", M.out);
    mock_check(strstr(M.out, "\n2047 150000\n2048 300000\n2049 150000\n") != NULL, "度数 150,000・300,000・150,000: [%.120s]", M.out);
    return mock_report();
}
