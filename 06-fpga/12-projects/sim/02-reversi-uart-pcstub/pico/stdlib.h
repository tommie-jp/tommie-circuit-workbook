// PC で 12-2 の主ループを動かすための替え玉。stdio (USB・UART0) を標準入出力に置き換える
#pragma once
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
typedef unsigned int uint;
enum { GPIO_FUNC_UART = 2 };
#define GPIO_OUT 1
#define PICO_ERROR_TIMEOUT (-1)
static inline void gpio_set_function(uint pin, int fn) { (void)pin; (void)fn; }
static inline void gpio_init(uint pin) { (void)pin; }
static inline void gpio_set_dir(uint pin, bool out) { (void)pin; (void)out; }
static inline void gpio_put(uint pin, bool v) { (void)pin; (void)v; }
static inline void gpio_pull_up(uint pin) { (void)pin; }
static inline void stdio_init_all(void) { setvbuf(stdout, NULL, _IONBF, 0); }
static inline int stdio_put_string(const char *s, int len, bool newline, bool cr) {
    (void)cr;
    fwrite(s, 1, (size_t)len, stdout);
    if (newline) fputc('\n', stdout);
    return len;
}
static inline int getchar_timeout_us(uint32_t us) {   // 標準入力から 1 字。終わりなら抜ける
    (void)us;
    int c = getchar();
    if (c == EOF) exit(0);
    return c;
}
static inline uint64_t time_us_64(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000000u + (uint64_t)ts.tv_nsec / 1000u;
}
