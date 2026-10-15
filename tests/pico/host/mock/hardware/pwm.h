#pragma once
#include "../pico_mock.h"
typedef struct { float div; uint top; } pwm_config;
static inline uint pwm_gpio_to_slice_num(uint g) { return (g >> 1) & 7; }
static inline uint pwm_gpio_to_channel(uint g) { return g & 1; }
static inline void pwm_set_clkdiv(uint s, float d) { M.pwm[s].clkdiv = d; }
static inline void pwm_set_wrap(uint s, uint16_t w) { M.pwm[s].wrap = w; }
static inline void pwm_set_chan_level(uint s, uint c, uint16_t l) { M.pwm[s].level[c] = l; }
static inline void pwm_set_both_levels(uint s, uint16_t a, uint16_t b) { M.pwm[s].level[0] = a; M.pwm[s].level[1] = b; }
static inline void pwm_set_gpio_level(uint g, uint16_t l) { M.pwm[pwm_gpio_to_slice_num(g)].level[g & 1] = l; }
static inline void pwm_set_enabled(uint s, bool e) { M.pwm[s].enabled = e; }
static inline pwm_config pwm_get_default_config(void) { return (pwm_config){1.0f, 0xffff}; }
static inline void pwm_config_set_clkdiv_int(pwm_config *c, uint d) { c->div = (float)d; }
static inline void pwm_config_set_clkdiv(pwm_config *c, float d) { c->div = d; }
static inline void pwm_config_set_wrap(pwm_config *c, uint16_t w) { c->top = w; }
static inline void pwm_init(uint s, pwm_config *c, bool start) { M.pwm[s].clkdiv = c->div; M.pwm[s].wrap = c->top; M.pwm[s].enabled = start; }
static inline void pwm_set_irq_enabled(uint s, bool e) { (void)s; (void)e; }
static inline void pwm_clear_irq(uint s) { (void)s; }
static inline void pwm_set_irq_mask_enabled(uint32_t m, bool e) { (void)m; (void)e; }
