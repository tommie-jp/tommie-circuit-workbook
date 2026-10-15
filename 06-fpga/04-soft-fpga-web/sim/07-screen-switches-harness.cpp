#include "Vsw_gates.h"
#include "verilated.h"
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#else
#define EMSCRIPTEN_KEEPALIVE
#endif
#include <stdint.h>

static Vsw_gates* top;
static uint8_t  sw_state    = 0;  // スイッチ: JS が書き換えるまで同じ値を入れ続ける
static uint8_t  pending_btn = 0;  // ボタン: 次の 1 クロックだけ 1 を入れる
static uint32_t cycles      = 0;

static void tick() {
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();
}

extern "C" {

EMSCRIPTEN_KEEPALIVE void sim_init() {
    top = new Vsw_gates();
    top->sw = 0; top->btn = 0;
    top->rst = 1; tick();
    top->rst = 0; top->clk = 0; top->eval();
    sw_state = 0; pending_btn = 0; cycles = 0;
}

EMSCRIPTEN_KEEPALIVE void step() {
    top->sw     = sw_state;
    top->btn    = pending_btn;
    pending_btn = 0;
    tick();
    cycles++;
}

EMSCRIPTEN_KEEPALIVE void set_sw(uint32_t v) { sw_state = v & 0x3u; }
EMSCRIPTEN_KEEPALIVE void press_btn()        { pending_btn = 1; }

// bit0 = y_and, bit1 = y_or, bits[7:4] = presses
EMSCRIPTEN_KEEPALIVE uint32_t get_out() {
    return (uint32_t)(top->y_and & 1u)
         | (uint32_t)(top->y_or  & 1u) << 1
         | (uint32_t)(top->o_presses & 0xFu) << 4;
}

EMSCRIPTEN_KEEPALIVE uint32_t get_cycles() { return cycles; }

} // extern "C"
