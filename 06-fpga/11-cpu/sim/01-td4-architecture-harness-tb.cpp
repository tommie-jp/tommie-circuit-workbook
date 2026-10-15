// 11-1 の試験台 (画面の側)。soft-fpga の examples/01-counter/cxx/harness.cpp を、
// この題の counter (TD4) と link し、ブラウザと同じ step() を呼んでリングバッファを読む。
// count の上 4 ビットが PC、下 4 ビットが OUT。期待値は命令表どおりに PC で数えて作る。
#include <cstdio>
#include <cstdint>
extern "C" { void sim_init(); void step(); uint32_t get_head(); uint32_t* get_ring_ptr(); int get_ring_size(); int get_ring_words(); }
static uint32_t at(uint32_t i) { return get_ring_ptr()[(i & (get_ring_size() - 1)) * get_ring_words()] & 0x1FFu; }

int main() {
    sim_init();                  // リセットの 2 サンプルが入る
    const int N = 80;
    for (int i = 0; i < N; i++) step();
    // 期待値: ADD A,1 / MOV B,A / OUT B / JMP 0 を命令表どおりに回す
    unsigned pc = 0, a = 0, b = 0, out = 0;
    int bad = 0;
    for (int k = 0; k < 2; k++) if (at(k) != 0x100u) bad++;           // リセット中は rst=1・count=0
    printf("count (16 進、step 1 から):");
    for (int n = 1; n <= N; n++) {
        switch (pc) { case 0: a = (a + 1) & 15u; break; case 1: b = a; break; case 2: out = b; break; default: break; }
        pc = (pc == 3) ? 0 : pc + 1;
        const uint32_t want = (pc << 4) | out;
        const uint32_t got = at((uint32_t)n + 1);
        if (got != want) bad++;
        if (n <= 24) printf(" %02X", got);
    }
    printf(" ...\n");
    printf("%s step 1〜%d の count が命令表の並びと一致 (食い違い %d)\n", bad ? "FAIL" : "PASS", N, bad);
    // OUT が F から 0 に戻る step
    for (int n = 1; n <= N; n++) if ((at(n) & 15u) == 15u && (at(n + 1) & 15u) == 0u) printf("OUT が F → 0 になる step: %d\n", n);
    return bad ? 1 : 0;
}
