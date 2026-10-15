#pragma once
#include "../pico_mock.h"
#define DREQ_ADC 36
static inline void adc_init(void) { M.adc_inited = true; }
static inline void adc_gpio_init(uint g) { M.adc_gpio_mask |= 1u << g; }
static inline void adc_select_input(uint i) { M.adc_input = i; }
static inline uint16_t adc_read(void) { return M.adc_value; }
static inline void adc_set_clkdiv(float d) { (void)d; }
static inline void adc_set_round_robin(uint m) { (void)m; }
static inline void adc_fifo_setup(bool a, bool b, uint c, bool d, bool e) { (void)a; (void)b; (void)c; (void)d; (void)e; }
static inline void adc_run(bool r) { (void)r; }
static inline void adc_fifo_drain(void) {}
