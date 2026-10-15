// 01-counter ハーネス — Verilator カウンタを駆動し、波形を ring buffer へ記録する。
// 11-2: TD4 の中 (A・B・命令・桁上げ) も記録するように record_sample を直した。
//
// ring buffer ビットレイアウト（1 サンプル = 1 uint32_t = 1 word）:
//   bits[ 7: 0] = count  (TD4 では上 4 ビットが PC、下 4 ビットが OUT)
//   bit [    8] = rst    (リセット入力)
//   bit [    9] = o_c    (11-2: 桁上げ、正論理)
//   bits[15:12] = o_a    (11-2: レジスタ A)
//   bits[19:16] = o_b    (11-2: レジスタ B)
//   bits[27:20] = o_op   (11-2: いまの命令)
//
// 記録・Freeze・トリガーは cxx/rtlscope_ring.h が担当する。

#include "Vcounter.h"
#include "verilated.h"
#include "../../../cxx/rtlscope_ring.h"

static Vcounter* top;
static rtlscope::Ring<4096, 1> ring;

// 現在の出力から 1 サンプル分の word を記録する。
static void record_sample() {
    const uint32_t w[1] = {
        ((uint32_t)top->count & 0xFFu) | ((uint32_t)(top->rst & 1u) << 8)
        | ((uint32_t)(top->o_c & 1u) << 9)                  // 11-2 で足した 4 行
        | ((uint32_t)(top->o_a & 0xFu) << 12)
        | ((uint32_t)(top->o_b & 0xFu) << 16)
        | ((uint32_t)(top->o_op & 0xFFu) << 20)
    };
    ring.record(w);
}

// rst を 2 サイクル保持してリセットする。リセット区間も波形に残す。
static void apply_reset() {
    top->rst = 1;
    for (int i = 0; i < 2; i++) {
        top->clk = 0; top->eval();
        top->clk = 1; top->eval();
        record_sample();
    }
    top->clk = 0; top->eval();
    top->rst = 0; top->eval();
}

RTLSCOPE_EXPORT_RING(ring)

extern "C" {

EMSCRIPTEN_KEEPALIVE void sim_init() {
    if (!top) top = new Vcounter();
    top->clk = 0;
    top->rst = 0;
    top->eval();
    ring.start_session();
    apply_reset();
}

EMSCRIPTEN_KEEPALIVE void step() {
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();
    record_sample();
}

// n クロック進める。トリガーで Freeze したらその場で打ち切る。
EMSCRIPTEN_KEEPALIVE void sim_run_n(int n) {
    for (int i = 0; i < n && !ring.hit(); i++) step();
}

// カウンタをリセットする。履歴は残し、Freeze とトリガー発火状態だけ解除する。
EMSCRIPTEN_KEEPALIVE void reset_sim() {
    ring.thaw();
    apply_reset();
}

} // extern "C"
