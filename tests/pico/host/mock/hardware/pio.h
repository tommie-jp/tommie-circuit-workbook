#pragma once
#include "../pico_mock.h"
typedef struct { int n; } pio_hw_t;
extern pio_hw_t mock_pio[3];
typedef pio_hw_t *PIO;
#define pio0 (&mock_pio[0])
#define pio1 (&mock_pio[1])
typedef struct { uint16_t *instructions; uint8_t length; int8_t origin; } pio_program_t_nonconst;
typedef struct { const uint16_t *instructions; uint8_t length; int8_t origin; } pio_program_t;
typedef struct { uint wrap_target, wrap, set_base, set_count; float div; uint out_base, out_count, sideset_base, sideset_count; bool shift_right, autopull; uint pull_thresh; int fifo_join; } pio_sm_config;
enum pio_fifo_join { PIO_FIFO_JOIN_NONE = 0, PIO_FIFO_JOIN_TX = 1, PIO_FIFO_JOIN_RX = 2 };
static inline int pio_add_program(PIO p, const pio_program_t *pr) {
    (void)p; M.pio_prog_len = pr->length; M.pio_origin = 0;
    for (uint i = 0; i < pr->length; i++) M.pio_prog[i] = pr->instructions[i];
    return 0;
}
static inline int pio_claim_unused_sm(PIO p, bool req) { (void)p; (void)req; return 0; }
static inline pio_sm_config pio_get_default_sm_config(void) { return (pio_sm_config){0, 31, 0, 5, 1.0f, 0, 0, 0, 0, false, false, 32, 0}; }
static inline void sm_config_set_out_pins(pio_sm_config *c, uint b, uint n) { c->out_base = b; c->out_count = n; }
static inline void sm_config_set_sideset_pins(pio_sm_config *c, uint b) { c->sideset_base = b; }
static inline void sm_config_set_sideset(pio_sm_config *c, uint n, bool opt, bool pindirs) { (void)opt; (void)pindirs; c->sideset_count = n; }
static inline void sm_config_set_out_shift(pio_sm_config *c, bool right, bool autopull, uint thresh) { c->shift_right = right; c->autopull = autopull; c->pull_thresh = thresh; }
static inline void sm_config_set_fifo_join(pio_sm_config *c, enum pio_fifo_join j) { c->fifo_join = j; }
static inline void sm_config_set_clkdiv(pio_sm_config *c, float d) { c->div = d; }
static inline void sm_config_set_wrap(pio_sm_config *c, uint t, uint w) { c->wrap_target = t; c->wrap = w; }
static inline void sm_config_set_set_pins(pio_sm_config *c, uint b, uint n) { c->set_base = b; c->set_count = n; }
static inline void pio_gpio_init(PIO p, uint g) { (void)p; M.pio_gpio_mask |= 1u << g; M.func[g] = GPIO_FUNC_PIO0; }
static inline void pio_sm_set_consecutive_pindirs(PIO p, uint sm, uint b, uint n, bool out) { (void)p; (void)sm; M.pio_pindirs_base = b; M.pio_pindirs_count = n; M.pio_pindirs_out = out; }
static inline void pio_sm_init(PIO p, uint sm, uint pc, const pio_sm_config *c) {
    (void)p; (void)sm; (void)pc; M.pio_set_base = c->set_base; M.pio_set_count = c->set_count;
    M.pio_wrap_target = c->wrap_target; M.pio_wrap = c->wrap; M.pio_clkdiv = c->div;
    M.pio_out_base = c->out_base; M.pio_out_count = c->out_count; M.pio_sideset_base = c->sideset_base; M.pio_sideset_count = c->sideset_count;
    M.pio_shift_right = c->shift_right; M.pio_autopull = c->autopull; M.pio_pull_thresh = c->pull_thresh; M.pio_fifo_join = c->fifo_join;
}
/* TX FIFO に書いた語と時刻を記録する (FIFO の深さは模さない。語が出る速さは試験が計算する) */
static inline void pio_sm_put_blocking(PIO p, uint sm, uint32_t w) { (void)p; (void)sm; if (M.npio_tx < 4096) { M.pio_tx[M.npio_tx] = w; M.pio_tx_t[M.npio_tx] = M.now_us; M.npio_tx++; } }
static inline void pio_sm_set_enabled(PIO p, uint sm, bool e) { (void)p; (void)sm; M.pio_sm_enabled = e; }
static inline void pio_sm_set_clkdiv(PIO p, uint sm, float d) { (void)p; (void)sm; M.pio_clkdiv = d; }
static inline void pio_sm_clkdiv_restart(PIO p, uint sm) { (void)p; (void)sm; M.pio_clkdiv_restarts++; }
