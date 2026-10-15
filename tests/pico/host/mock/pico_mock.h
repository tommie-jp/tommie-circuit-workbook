/* Pico SDK の最小のモック (docs/133 の層 A)。呼び出しを記録し、仮想時刻を進めるだけ。
 * 本物のレジスタは持たない。期待値は物理量 (周期・パルス幅・速度) で書く。 */
#pragma once
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdarg.h>
#include <setjmp.h>

typedef unsigned int uint;
#define GPIO_IN 0
#define GPIO_OUT 1
enum { GPIO_FUNC_XIP = 0, GPIO_FUNC_SPI = 1, GPIO_FUNC_UART = 2, GPIO_FUNC_I2C = 3, GPIO_FUNC_PWM = 4,
       GPIO_FUNC_SIO = 5, GPIO_FUNC_PIO0 = 6, GPIO_FUNC_PIO1 = 7, GPIO_FUNC_PIO2 = 8, GPIO_FUNC_NULL = 0x1f };
enum { GPIO_DRIVE_STRENGTH_2MA, GPIO_DRIVE_STRENGTH_4MA, GPIO_DRIVE_STRENGTH_8MA, GPIO_DRIVE_STRENGTH_12MA };
#define MOCK_NGPIO 48
#define MOCK_SYS_HZ 150000000u   /* Pico 2 (RP2350) の clk_sys。RP2040 は 125 MHz */

/* ---- 仮想時刻 ---- */
typedef struct { uint64_t us; } absolute_time_t;
absolute_time_t get_absolute_time(void);
absolute_time_t delayed_by_us(absolute_time_t t, uint64_t us);
absolute_time_t delayed_by_ms(absolute_time_t t, uint32_t ms);
uint64_t to_us_since_boot(absolute_time_t t);
uint32_t to_ms_since_boot(absolute_time_t t);
uint32_t time_us_32(void);
uint64_t time_us_64(void);
void sleep_ms(uint32_t ms);
void sleep_us(uint64_t us);
void sleep_until(absolute_time_t t);
void busy_wait_us(uint64_t us);
void busy_wait_ms(uint32_t ms);
void tight_loop_contents(void);

/* ---- GPIO ---- */
void gpio_init(uint g);
void gpio_init_mask(uint32_t m);
void gpio_set_dir(uint g, bool out);
void gpio_set_dir_out_masked(uint32_t m);
void gpio_set_function(uint g, uint f);
void gpio_pull_up(uint g);
void gpio_pull_down(uint g);
void gpio_disable_pulls(uint g);
void gpio_set_drive_strength(uint g, uint s);
void gpio_put(uint g, bool v);
void gpio_put_masked(uint32_t mask, uint32_t v);
bool gpio_get(uint g);
uint32_t gpio_get_all(void);

/* ---- repeating timer ---- */
typedef struct repeating_timer { int64_t delay_us; void *user_data; } repeating_timer_t;
typedef bool (*repeating_timer_callback_t)(repeating_timer_t *);
bool add_repeating_timer_us(int64_t d, repeating_timer_callback_t cb, void *u, repeating_timer_t *t);
bool add_repeating_timer_ms(int32_t d, repeating_timer_callback_t cb, void *u, repeating_timer_t *t);

/* ---- stdio ---- */
void stdio_init_all(void);
int mock_printf(const char *fmt, ...);
int getchar_timeout_us(uint32_t us);
#define PICO_ERROR_TIMEOUT (-1)
#define printf mock_printf

/* ---- テストからの入口 ---- */
typedef struct { uint64_t t_us; uint pin; bool level; } gpio_event_t;
typedef struct {
    uint64_t now_us, budget_us;
    bool done;                         /* 予算を使い切ってプログラムを止めた */
    uint8_t func[MOCK_NGPIO];
    bool dir_out[MOCK_NGPIO], level[MOCK_NGPIO], init[MOCK_NGPIO], in_value[MOCK_NGPIO];
    bool pull_up[MOCK_NGPIO];
    uint8_t drive[MOCK_NGPIO];
    gpio_event_t ev[8192]; uint nev;
    char out[16384]; uint nout;        /* printf の出力 */
    /* PWM */
    struct { float clkdiv; uint wrap; uint level[2]; bool enabled; bool phase_correct; } pwm[12];
    /* ADC */
    bool adc_inited; uint adc_input; uint16_t adc_value; uint adc_gpio_mask;
    /* I2C / UART / SPI */
    uint i2c_baud[2]; uint uart_baud[2]; uint uart_bits[2], uart_stop[2], uart_parity[2];
    uint8_t uart_tx[1024]; uint ntx; uint64_t uart_tx_t[1024];
    uint8_t uart_rx[1024]; uint nrx, rx_pos;
    uint8_t i2c_reply[16]; uint n_i2c_reply;
    uint i2c_writes, i2c_reads;
    uint spi_baud; uint calls;
    uint dma_claimed;
} mock_t;
extern mock_t M;
void mock_reset(uint64_t budget_us);
extern jmp_buf mock_exit;
int program_main(void);               /* -Dmain=program_main された本文の main */
/* 予算 (µs) まで本文の main を動かす。戻ったら M を調べる。 */
void mock_run(uint64_t budget_us);
bool mock_check(bool ok, const char *what, ...);
int mock_report(void);
/* 物理量 */
double mock_pwm_period_s(uint slice);
double mock_pwm_high_s(uint slice, uint ch);
