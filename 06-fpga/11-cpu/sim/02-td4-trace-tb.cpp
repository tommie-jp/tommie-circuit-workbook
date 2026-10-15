// 11-2 の試験台。直した harness.cpp (02-td4-trace-harness.cpp) と 02-td4-trace.v の counter を link し、
// ブラウザと同じ step() を呼んでリングバッファを読む。1 step ごとに命令表の模型と比べ、表を出す。
#include <cstdio>
#include <cstdint>
extern "C" { void sim_init(); void step(); uint32_t* get_ring_ptr(); int get_ring_size(); int get_ring_words(); }
static uint32_t at(uint32_t i) { return get_ring_ptr()[(i & (get_ring_size() - 1)) * get_ring_words()]; }

static const uint8_t ROM[16] = {0x35, 0x40, 0x03, 0x5C, 0xE0, 0x20, 0x10, 0x60,
                                0x90, 0x79, 0xB6, 0x3E, 0x01, 0xEF, 0xBF, 0xF0};
static const unsigned IN = 0xA;

struct S { unsigned pc = 0, a = 0, b = 0, out = 0, c = 0; };
static unsigned g_x, g_r;   // 最後に模型が計算した加算器の入口 (セレクタの出口) と結果 (5 ビット)
static S model(S s, uint8_t code) {          // 5-8 の命令表 (11-1 の試験台と同じ書き方)
    const unsigned op = code >> 4, im = code & 15u;
    unsigned r = 0; S n = s; n.pc = (s.pc + 1) & 15u;
    switch (op) {
        case 0x0: r = s.a + im; n.a = r & 15u; break;   case 0x1: r = s.b; n.a = r; break;
        case 0x2: r = IN; n.a = r; break;               case 0x3: r = im; n.a = r; break;
        case 0x4: r = s.a; n.b = r; break;              case 0x5: r = s.b + im; n.b = r & 15u; break;
        case 0x6: r = IN; n.b = r; break;               case 0x7: r = im; n.b = r; break;
        case 0x9: r = s.b; n.out = r; break;            case 0xB: r = im; n.out = r; break;
        case 0xE: r = im; if (!s.c) n.pc = im; break;   case 0xF: r = im; n.pc = im; break;
        default: break;
    }
    n.c = (r >> 4) & 1u;
    g_x = (r - im) & 31u;   // 足し算の片方 (Im を引けば元に戻る)
    if (op == 0x1 || op == 0x2 || op == 0x4 || op == 0x6 || op == 0x9) g_x = r;
    g_r = r;
    return n;
}
static const char* name(uint8_t code) {
    static char buf[16];
    static const char* f[16] = {"ADD A,%X", "MOV A,B", "IN A", "MOV A,%X", "MOV B,A", "ADD B,%X", "IN B", "MOV B,%X",
                                "?", "OUT B", "?", "OUT %X", "?", "?", "JNC %X", "JMP %X"};
    snprintf(buf, sizeof buf, f[code >> 4], code & 15u);
    return buf;
}

int main() {
    sim_init();
    const int N = 45;                      // 3 巡
    for (int i = 0; i < N; i++) step();
    int bad = 0;
    S s;
    for (int k = 0; k < 2; k++) if ((at(k) & 0x1FFu) != 0x100u) bad++;
    if (((at(1) >> 20) & 0xFFu) != ROM[0]) bad++;                 // リセット中は 0 番地の命令が見えている
    printf("step | 実行した番地 命令        | 加算器 x + Im = 結果 | 後の PC  A  B OUT C | 次の命令\n");
    for (int n = 1; n <= N; n++) {
        const uint8_t code = ROM[s.pc];
        const S w = model(s, code);
        const uint32_t g = at((uint32_t)n + 1);
        const S got{(g >> 4) & 15u, (g >> 12) & 15u, (g >> 16) & 15u, g & 15u, (g >> 9) & 1u};
        const unsigned op = (g >> 20) & 0xFFu;
        const bool ok = got.pc == w.pc && got.a == w.a && got.b == w.b && got.out == w.out && got.c == w.c && op == ROM[w.pc];
        bad += !ok;
        if (n <= 16)
            printf("%4d | %X  %02X %-10s | %X + %X = %02X | %X  %X  %X  %X  %u | %02X %s\n", n, s.pc, code, name(code),
                   g_x, code & 15u, g_r, got.pc, got.a, got.b, got.out, got.c, op, ok ? "" : "<- 食い違い");
        s = w;
    }
    // 番地 E (OUT 1111) が一度も実行されないこと
    int e_runs = 0;
    for (int n = 1; n <= N; n++) if (((at((uint32_t)n) >> 4) & 15u) == 0xE) e_runs++;
    printf("番地 E を実行した回数: %d\n", e_runs);
    bad += e_runs != 0;
    // 1 巡の長さ: PC が 0 に戻る step
    printf("PC が 0 に戻る step:");
    for (int n = 1; n <= N; n++) if (((at((uint32_t)n + 1) >> 4) & 15u) == 0) printf(" %d", n);
    printf("\n");
    printf("%s step 1〜%d が命令表の模型と一致 (食い違い %d)\n", bad ? "FAIL" : "PASS", N, bad);
    return bad ? 1 : 0;
}
