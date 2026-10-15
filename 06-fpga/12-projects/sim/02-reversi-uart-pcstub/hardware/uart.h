// PC の替え玉: UART1 (受けた行の写し) は捨てる
#pragma once
#include "pico/stdlib.h"
typedef int uart_inst_t;
#define uart1 ((uart_inst_t *)1)
typedef enum { UART_PARITY_NONE } uart_parity_t;
static inline uint uart_init(uart_inst_t *u, uint baud) { (void)u; return baud; }
static inline void uart_set_format(uart_inst_t *u, uint d, uint s, uart_parity_t p) { (void)u; (void)d; (void)s; (void)p; }
static inline void uart_putc_raw(uart_inst_t *u, char c) { (void)u; (void)c; }
