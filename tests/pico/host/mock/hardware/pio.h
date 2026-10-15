#pragma once
#include "../pico_mock.h"
typedef struct { int n; } pio_hw_t;
extern pio_hw_t mock_pio[3];
typedef pio_hw_t *PIO;
#define pio0 (&mock_pio[0])
#define pio1 (&mock_pio[1])
typedef struct { uint16_t *instructions; uint8_t length; int8_t origin; } pio_program_t_nonconst;
typedef struct { const uint16_t *instructions; uint8_t length; int8_t origin; } pio_program_t;
typedef struct { uint wrap_target, wrap, set_base, set_count; float div; } pio_sm_config;
static inline int pio_add_program(PIO p, const pio_program_t *pr) {
    (void)p; M.pio_prog_len = pr->length; M.pio_origin = 0;
    for (uint i = 0; i < pr->length; i++) M.pio_prog[i] = pr->instructions[i];
    return 0;
}
static inline int pio_claim_unused_sm(PIO p, bool req) { (void)p; (void)req; return 0; }
static inline pio_sm_config pio_get_default_sm_config(void) { return (pio_sm_config){0, 31, 0, 5, 1.0f}; }
static inline void sm_config_set_wrap(pio_sm_config *c, uint t, uint w) { c->wrap_target = t; c->wrap = w; }
static inline void sm_config_set_set_pins(pio_sm_config *c, uint b, uint n) { c->set_base = b; c->set_count = n; }
static inline void pio_gpio_init(PIO p, uint g) { (void)p; M.pio_gpio_mask |= 1u << g; M.func[g] = GPIO_FUNC_PIO0; }
static inline void pio_sm_set_consecutive_pindirs(PIO p, uint sm, uint b, uint n, bool out) { (void)p; (void)sm; M.pio_pindirs_base = b; M.pio_pindirs_count = n; M.pio_pindirs_out = out; }
static inline void pio_sm_init(PIO p, uint sm, uint pc, const pio_sm_config *c) {
    (void)p; (void)sm; (void)pc; M.pio_set_base = c->set_base; M.pio_set_count = c->set_count;
    M.pio_wrap_target = c->wrap_target; M.pio_wrap = c->wrap; M.pio_clkdiv = c->div;
}
static inline void pio_sm_set_enabled(PIO p, uint sm, bool e) { (void)p; (void)sm; M.pio_sm_enabled = e; }
static inline void pio_sm_set_clkdiv(PIO p, uint sm, float d) { (void)p; (void)sm; M.pio_clkdiv = d; }
static inline void pio_sm_clkdiv_restart(PIO p, uint sm) { (void)p; (void)sm; M.pio_clkdiv_restarts++; }
