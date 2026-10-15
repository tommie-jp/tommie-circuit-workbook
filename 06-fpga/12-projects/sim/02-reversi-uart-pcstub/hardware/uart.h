// PC の替え玉: uart_getc は標準入力から 1 字読み、終わりなら抜ける。uart_puts は標準出力へ
#pragma once
#include "pico/stdlib.h"
typedef int uart_inst_t;
#define uart0 ((uart_inst_t *)0)
typedef enum { UART_PARITY_NONE } uart_parity_t;
static inline uint uart_init(uart_inst_t *u, uint baud) { (void)u; return baud; }
static inline void uart_set_format(uart_inst_t *u, uint d, uint s, uart_parity_t p) { (void)u; (void)d; (void)s; (void)p; }
static inline void uart_puts(uart_inst_t *u, const char *s) { (void)u; fputs(s, stdout); fflush(stdout); }
static inline char uart_getc(uart_inst_t *u) {
    (void)u;
    int c = getchar();
    if (c == EOF) exit(0);
    return (char)c;
}
