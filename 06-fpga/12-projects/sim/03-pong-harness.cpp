// examples/91-pong/cxx/harness.cpp — 1 画面ぶんクロックを回し、画素を 160 × 120 の配列に書く
#include "Vpong.h"
#include "verilated.h"
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#else
#define EMSCRIPTEN_KEEPALIVE
#endif
#include <stdint.h>

static Vpong*   top;
static uint8_t  fb[160 * 120];     // 1 画素 1 バイト (0 か 1)
static uint32_t keys   = 0;        // bit0 左上 bit1 左下 bit2 右上 bit3 右下 bit4 左 auto bit5 右 auto
static uint32_t frames = 0;

static void tick() {
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();
}

extern "C" {

EMSCRIPTEN_KEEPALIVE void sim_init() {
    top = new Vpong();
    top->rst = 1; tick();
    top->rst = 0; top->clk = 0; top->eval();
    frames = 0;
}

EMSCRIPTEN_KEEPALIVE void set_keys(uint32_t k) { keys = k; }

// 1 画面 = 160 × 120 = 19 200 クロック。画素は立ち上がりの前の (hpos, vpos) の値
EMSCRIPTEN_KEEPALIVE void run_frame() {
    top->up_l = keys & 1;         top->dn_l = (keys >> 1) & 1;
    top->up_r = (keys >> 2) & 1;  top->dn_r = (keys >> 3) & 1;
    top->auto_l = (keys >> 4) & 1; top->auto_r = (keys >> 5) & 1;
    for (int i = 0; i < 160 * 120; i++) {
        top->clk = 0; top->eval();
        fb[top->vpos * 160 + top->hpos] = top->pixel;
        const bool last = top->frame_end;
        top->clk = 1; top->eval();
        if (last) break;
    }
    frames++;
}

EMSCRIPTEN_KEEPALIVE uint8_t* get_fb()      { return fb; }
EMSCRIPTEN_KEEPALIVE uint32_t get_score()   { return (uint32_t)top->score_l << 4 | top->score_r; }
EMSCRIPTEN_KEEPALIVE uint32_t get_frames()  { return frames; }

} // extern "C"
