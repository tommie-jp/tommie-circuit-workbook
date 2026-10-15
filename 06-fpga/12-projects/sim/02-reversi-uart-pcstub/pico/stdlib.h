// PC で 12-2 の主ループを動かすための替え玉。UART を標準入出力に置き換える
#pragma once
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
typedef unsigned int uint;
enum { GPIO_FUNC_UART = 2 };
static inline void gpio_set_function(uint pin, int fn) { (void)pin; (void)fn; }
static inline uint64_t time_us_64(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000000u + (uint64_t)ts.tv_nsec / 1000u;
}
