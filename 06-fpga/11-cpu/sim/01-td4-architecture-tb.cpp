// 11-1 の試験台。部品に分けた td4_core を、2 つの模型と 5-8 の TD4.v に突き合わせる。
//  1. 命令表の模型: 5-8 の表の 12 命令だけで作った乱数のプログラム
//  2. ビットの決めの模型: 上 2 ビットが書く先、次の 2 ビットが足す元。256 通りのオペコード全部
//  3. 5-8 の TD4.v (プログラム A) と、同じ ROM を外から与えた td4_core を並べて回す
// どれも 1 クロックごとに PC・A・B・OUT・キャリーを比べ、食い違いを数える。
#include <cstdio>
#include <cstdint>
#include <random>
#include "Vtd4_core.h"
#include "VTD4.h"

struct State { unsigned pc = 0, a = 0, b = 0, out = 0, c = 0; };  // c は正論理 (1 で桁上げ)

// 1. 命令表の模型 (5-8 の表をそのまま書いた)
static State step_table(State s, uint8_t code, unsigned in) {
    const unsigned op = code >> 4, im = code & 15u;
    unsigned r = 0;
    State n = s;
    n.pc = (s.pc + 1) & 15u;
    switch (op) {
        case 0x0: r = s.a + im; n.a = r & 15u; break;   // ADD A,Im
        case 0x1: r = s.b;      n.a = r;       break;   // MOV A,B
        case 0x2: r = in;       n.a = r;       break;   // IN A
        case 0x3: r = im;       n.a = r;       break;   // MOV A,Im
        case 0x4: r = s.a;      n.b = r;       break;   // MOV B,A
        case 0x5: r = s.b + im; n.b = r & 15u; break;   // ADD B,Im
        case 0x6: r = in;       n.b = r;       break;   // IN B
        case 0x7: r = im;       n.b = r;       break;   // MOV B,Im
        case 0x9: r = s.b;      n.out = r;     break;   // OUT B
        case 0xB: r = im;       n.out = r;     break;   // OUT Im
        case 0xE: r = im; if (!s.c) n.pc = im; break;   // JNC Im
        case 0xF: r = im; n.pc = im;           break;   // JMP Im
        default: break;
    }
    n.c = (r >> 4) & 1u;
    return n;
}

// 2. ビットの決めの模型 (上 2 ビット = 書く先、次の 2 ビット = 足す元。書く先が PC なら足す元は 0)
static State step_fields(State s, uint8_t code, unsigned in) {
    const unsigned dst = code >> 6, src = (code >> 4) & 3u, im = code & 15u;
    const unsigned x = (dst == 3) ? 0 : (src == 0 ? s.a : src == 1 ? s.b : src == 2 ? in : 0);
    const unsigned r = x + im;
    State n = s;
    n.pc = (s.pc + 1) & 15u;
    if (dst == 0) n.a = r & 15u;
    if (dst == 1) n.b = r & 15u;
    if (dst == 2) n.out = r & 15u;
    if (dst == 3 && (((code >> 4) & 1u) || !s.c)) n.pc = r & 15u;
    n.c = (r >> 4) & 1u;
    return n;
}

static void tick(Vtd4_core& m) { m.clk = 0; m.eval(); m.clk = 1; m.eval(); }
static void reset(Vtd4_core& m) {
    m.reset_n = 0; m.clk = 0; m.eval(); m.reset_n = 1; m.eval();
}
static State read(const Vtd4_core& m) {
    State s; s.pc = m.rom_addr; s.a = m.reg_a; s.b = m.reg_b; s.out = m.out_port; s.c = m.c_n ? 0 : 1;
    return s;
}
static bool same(const State& x, const State& y) {
    return x.pc == y.pc && x.a == y.a && x.b == y.b && x.out == y.out && x.c == y.c;
}

// 乱数のプログラムを programs 本、各 cycles クロック回す
template <class F>
static long run_random(Vtd4_core& m, std::mt19937& rng, F model, bool defined_only, int programs, int cycles) {
    static const uint8_t ops[12] = {0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x9, 0xB, 0xE, 0xF};
    long bad = 0;
    for (int p = 0; p < programs; p++) {
        uint8_t rom[16];
        for (auto& r : rom) {
            if (defined_only) {
                const uint8_t op = ops[rng() % 12];
                const bool no_im = (op == 0x1 || op == 0x2 || op == 0x4 || op == 0x6 || op == 0x9);
                r = (uint8_t)((op << 4) | (no_im ? 0 : (rng() & 15u)));
            } else {
                r = (uint8_t)(rng() & 0xFFu);
            }
        }
        reset(m);
        State s;
        for (int t = 0; t < cycles; t++) {
            const unsigned in = rng() & 15u;
            m.in_port = in;
            m.rom_data = rom[m.rom_addr];
            m.eval();
            const State want = model(s, rom[s.pc], in);
            tick(m);
            m.rom_data = rom[m.rom_addr];
            m.eval();
            if (!same(read(m), want)) bad++;
            s = want;
        }
    }
    return bad;
}

int main() {
    Vtd4_core core;
    std::mt19937 rng(11);
    int fails = 0;

    const int P = 2000, C = 200;
    const long bad1 = run_random(core, rng, step_table, true, P, C);
    printf("%s 命令表の模型 (12 命令の乱数のプログラム %d 本 x %d クロック): 食い違い %ld\n",
           bad1 ? "FAIL" : "PASS", P, C, bad1);
    fails += bad1 != 0;

    const long bad2 = run_random(core, rng, step_fields, false, P, C);
    printf("%s ビットの決めの模型 (256 通りの乱数のプログラム %d 本 x %d クロック): 食い違い %ld\n",
           bad2 ? "FAIL" : "PASS", P, C, bad2);
    fails += bad2 != 0;

    // 3. 5-8 の TD4.v (ROM はプログラム A を中に持つ) と並べる
    static const uint8_t progA[16] = {0xB3, 0xB6, 0xBC, 0xB8, 0xB8, 0xBC, 0xB6, 0xB3,
                                      0xB1, 0xF0, 0, 0, 0, 0, 0, 0};
    VTD4 ref;
    ref.reset_n = 0; ref.clock = 0; ref.in_port = 0; ref.eval(); ref.reset_n = 1; ref.eval();
    reset(core);
    core.in_port = 0;
    long bad3 = 0;
    const int N3 = 100;
    for (int t = 0; t < N3; t++) {
        core.rom_data = progA[core.rom_addr]; core.eval();
        tick(core);
        ref.clock = 0; ref.eval(); ref.clock = 1; ref.eval();
        core.rom_data = progA[core.rom_addr]; core.eval();
        if (core.rom_addr != ref.pc_out || core.out_port != ref.out_port) bad3++;
    }
    printf("%s 5-8 の TD4.v とプログラム A を %d クロック並べる: 食い違い %ld\n", bad3 ? "FAIL" : "PASS", N3, bad3);
    fails += bad3 != 0;

    // 決まっていないオペコード 4 つの働き (A=5、B=9、IN=3、Im=1 から 1 クロック)
    static const uint8_t extra[4] = {0x81, 0xA1, 0xC1, 0xD1};
    for (uint8_t code : extra) {
        for (int c = 0; c < 2; c++) {
            uint8_t rom[16] = {0x35, 0x79, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
            rom[2] = c ? 0x0F : 0x00;   // c=1 なら ADD A,1111 で桁上げを立てる (A は 4 になる)
            rom[3] = code;
            reset(core);
            core.in_port = 3;
            for (int t = 0; t < 3; t++) { core.rom_data = rom[core.rom_addr]; core.eval(); tick(core); }
            core.rom_data = rom[core.rom_addr]; core.eval();
            const State before = read(core);
            tick(core);
            core.rom_data = rom[core.rom_addr]; core.eval();
            const State after = read(core);
            const State want = step_fields(before, code, 3);
            const bool ok = same(after, want);
            fails += !ok;
            printf("%s op=%X%X 桁上げ=%u: A %X->%X  OUT %X->%X  PC %X->%X\n", ok ? "PASS" : "FAIL",
                   code >> 4, code & 15, before.c, before.a, after.a, before.out, after.out, before.pc, after.pc);
        }
    }

    printf(fails ? "FAILED %d\n" : "ALL PASS\n", fails);
    return fails ? 1 : 0;
}
