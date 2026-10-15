#include "pico_mock.h"
#include <string.h>
#undef printf
mock_t M;
jmp_buf mock_exit;
static int g_fail;

void mock_reset(uint64_t budget_us) { memset(&M, 0, sizeof M); M.budget_us = budget_us; for (int i = 0; i < MOCK_NGPIO; i++) M.in_value[i] = true; }
static void advance(uint64_t us) {
    M.now_us += us;
    if (M.now_us >= M.budget_us) { M.done = true; longjmp(mock_exit, 1); }
}
void mock_run(uint64_t budget_us) { M.budget_us = budget_us; if (setjmp(mock_exit) == 0) program_main(); }

absolute_time_t get_absolute_time(void) { return (absolute_time_t){M.now_us}; }
absolute_time_t delayed_by_us(absolute_time_t t, uint64_t us) { t.us += us; return t; }
absolute_time_t delayed_by_ms(absolute_time_t t, uint32_t ms) { t.us += (uint64_t)ms * 1000; return t; }
uint64_t to_us_since_boot(absolute_time_t t) { return t.us; }
uint32_t to_ms_since_boot(absolute_time_t t) { return (uint32_t)(t.us / 1000); }
uint32_t time_us_32(void) { return (uint32_t)M.now_us; }
uint64_t time_us_64(void) { return M.now_us; }
void sleep_ms(uint32_t ms) { advance((uint64_t)ms * 1000); }
void sleep_us(uint64_t us) { advance(us); }
void busy_wait_us(uint64_t us) { advance(us); }
void busy_wait_ms(uint32_t ms) { advance((uint64_t)ms * 1000); }
void sleep_until(absolute_time_t t) { if (t.us > M.now_us) advance(t.us - M.now_us); else advance(1); }
void tight_loop_contents(void) { advance(1); }

static void chk(uint g) { if (g >= MOCK_NGPIO) { fprintf(stderr, "mock: GPIO %u は範囲外\n", g); g_fail++; } }
void gpio_init(uint g) { chk(g); M.init[g] = true; M.func[g] = GPIO_FUNC_SIO; M.dir_out[g] = false; M.level[g] = false; }
void gpio_init_mask(uint32_t m) { for (uint g = 0; g < 32; g++) if (m >> g & 1) gpio_init(g); }
void gpio_set_dir(uint g, bool out) { chk(g); M.dir_out[g] = out; }
void gpio_set_dir_out_masked(uint32_t m) { for (uint g = 0; g < 32; g++) if (m >> g & 1) M.dir_out[g] = true; }
void gpio_set_function(uint g, uint f) { chk(g); M.func[g] = (uint8_t)f; }
void gpio_pull_up(uint g) { chk(g); M.pull_up[g] = true; }
void gpio_pull_down(uint g) { chk(g); M.pull_up[g] = false; }
void gpio_disable_pulls(uint g) { chk(g); M.pull_up[g] = false; }
void gpio_set_drive_strength(uint g, uint s) { chk(g); M.drive[g] = (uint8_t)s; }
void gpio_put(uint g, bool v) {
    chk(g);
    if (M.func[g] != GPIO_FUNC_SIO || !M.dir_out[g]) { /* 出力に切り替える前の書き込みは実機でも出ない */ }
    if (M.level[g] != v && M.nev < 8192) M.ev[M.nev++] = (gpio_event_t){M.now_us, g, v};
    M.level[g] = v;
}
void gpio_put_masked(uint32_t mask, uint32_t v) { for (uint g = 0; g < 32; g++) if (mask >> g & 1) gpio_put(g, v >> g & 1); }
bool gpio_get(uint g) { chk(g); return M.dir_out[g] ? M.level[g] : (M.in_value[g] || M.pull_up[g] ? M.in_value[g] : false); }
uint32_t gpio_get_all(void) { uint32_t r = 0; for (uint g = 0; g < 32; g++) r |= (uint32_t)gpio_get(g) << g; return r; }

bool add_repeating_timer_us(int64_t d, repeating_timer_callback_t cb, void *u, repeating_timer_t *t) {
    (void)cb; t->delay_us = d; t->user_data = u; return true;
}
bool add_repeating_timer_ms(int32_t d, repeating_timer_callback_t cb, void *u, repeating_timer_t *t) {
    return add_repeating_timer_us((int64_t)d * 1000, cb, u, t);
}
void stdio_init_all(void) {}
int mock_printf(const char *fmt, ...) {
    va_list ap; va_start(ap, fmt);
    int n = vsnprintf(M.out + M.nout, sizeof M.out - M.nout, fmt, ap);
    va_end(ap);
    if (n > 0) { M.nout += (uint)n; if (M.nout >= sizeof M.out) M.nout = sizeof M.out - 1; }
    return n;
}
int getchar_timeout_us(uint32_t us) { advance(us); return PICO_ERROR_TIMEOUT; }

double mock_pwm_period_s(uint s) {
    double top = M.pwm[s].wrap + 1.0;
    if (M.pwm[s].phase_correct) top *= 2;
    return (double)M.pwm[s].clkdiv * top / MOCK_SYS_HZ;
}
double mock_pwm_high_s(uint s, uint ch) { return (double)M.pwm[s].clkdiv * M.pwm[s].level[ch] / MOCK_SYS_HZ; }

bool mock_check(bool ok, const char *what, ...) {
    va_list ap; va_start(ap, what);
    if (!ok) { fputs("  NG: ", stderr); vfprintf(stderr, what, ap); fputc('\n', stderr); g_fail++; }
    va_end(ap);
    return ok;
}
int mock_report(void) { return g_fail ? 1 : 0; }
#include "hardware/i2c.h"
#include "hardware/uart.h"
i2c_inst_t mock_i2c[2] = {{0}, {1}};
uart_inst_t mock_uart[2] = {{0}, {1}};
void mock_uart_wait(void) { M.done = true; longjmp(mock_exit, 1); }  /* 受信を待って止まる = 入力を使い切った */
