#pragma once
#include "../pico_mock.h"
typedef struct { int n; } uart_inst_t;
extern uart_inst_t mock_uart[2];
#define uart0 (&mock_uart[0])
#define uart1 (&mock_uart[1])
typedef enum { UART_PARITY_NONE, UART_PARITY_EVEN, UART_PARITY_ODD } uart_parity_t;
static inline uint uart_init(uart_inst_t *u, uint b) { M.uart_baud[u->n] = b; return b; }
static inline void uart_set_format(uart_inst_t *u, uint d, uint s, uart_parity_t p) { M.uart_bits[u->n] = d; M.uart_stop[u->n] = s; M.uart_parity[u->n] = (uint)p; }
static inline void uart_set_hw_flow(uart_inst_t *u, bool a, bool b) { (void)u; (void)a; (void)b; }
static inline void uart_set_fifo_enabled(uart_inst_t *u, bool e) { (void)u; (void)e; }
static inline void uart_putc_raw(uart_inst_t *u, char c) { if (M.ntx < 1024) { M.uart_tx_t[M.ntx] = M.now_us; M.uart_tx_n[M.ntx] = (uint8_t)u->n; M.uart_tx[M.ntx++] = (uint8_t)c; } }
static inline void uart_putc(uart_inst_t *u, char c) { uart_putc_raw(u, c); }
static inline void uart_puts(uart_inst_t *u, const char *s) { while (*s) uart_putc_raw(u, *s++); }
static inline bool uart_is_readable(uart_inst_t *u) { (void)u; return M.rx_pos < M.nrx; }
extern void mock_uart_wait(void);
static inline char uart_getc(uart_inst_t *u) { (void)u; if (M.rx_pos >= M.nrx) mock_uart_wait(); return (char)M.uart_rx[M.rx_pos++]; }
