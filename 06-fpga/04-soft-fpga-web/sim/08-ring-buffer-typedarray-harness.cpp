// 4-8 の測定用: 01-counter の harness.cpp に、比べる形を 2 つ足したもの。
#include "Vcounter.h"
#include "verilated.h"
#include <stdint.h>
#define EMSCRIPTEN_KEEPALIVE
static uint32_t g_sink; static uint32_t (*g_cb)(uint32_t)=0;
#define EM_JS(ret,name,args,body) static void name args { g_sink = v; }
#include <stdint.h>

static Vcounter* top;
static const int RING_SIZE = 1024;
static uint32_t ring[RING_SIZE];
static uint32_t head = 0;

// 形 B: 毎クロック、Wasm から JS の関数を呼んで値を渡す
EM_JS(void, js_sample, (uint32_t v), { Module.onSample(v); });

static inline void tick() {
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();
}

extern "C" {

EMSCRIPTEN_KEEPALIVE void sim_init() {
    top = new Vcounter();
    top->clk = 0; top->rst = 1; top->eval();
    tick();
    top->clk = 0; top->eval();
    top->rst = 0; top->eval();
    head = 0;
}

// 01-counter と同じ: 1 クロック進めて、値をリングバッファに書く
EMSCRIPTEN_KEEPALIVE void step() {
    tick();
    ring[head & (RING_SIZE - 1)] = top->count;
    head++;
}

// 1 クロック進めるだけ (値は get_count で読む)
EMSCRIPTEN_KEEPALIVE void step_only() { tick(); }
EMSCRIPTEN_KEEPALIVE uint32_t get_count() { return top->count; }

// 形 B
EMSCRIPTEN_KEEPALIVE void step_n_callback(uint32_t n) {
    for (uint32_t i = 0; i < n; i++) { tick(); js_sample(top->count); }
}

// 形 D: n クロックを Wasm の中で回し、リングバッファに書く
EMSCRIPTEN_KEEPALIVE void step_n(uint32_t n) {
    for (uint32_t i = 0; i < n; i++) {
        tick();
        ring[head & (RING_SIZE - 1)] = top->count;
        head++;
    }
}

EMSCRIPTEN_KEEPALIVE uint32_t* get_ring_ptr() { return ring; }
EMSCRIPTEN_KEEPALIVE uint32_t get_head() { return head; }
EMSCRIPTEN_KEEPALIVE int get_ring_size() { return RING_SIZE; }

}
