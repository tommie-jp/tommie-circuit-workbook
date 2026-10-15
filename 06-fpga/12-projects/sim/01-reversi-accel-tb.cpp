// 12-1 の試験台。reversi_accel を、8×8 の配列で数える素朴な参照実装と突き合わせる。
// 乱数で打ち進めた盤面で、合法手・全 64 マスの flip・最善手と探すクロック数を比べ、
// 最後に初期配置から深さ 8 までの局面の数 (perft) を両方で数える。
#include "Vreversi_accel.h"
#include "verilated.h"
#include <cstdint>
#include <cstdio>

typedef uint64_t u64;
static Vreversi_accel* top;
static long errors = 0;

// ---- 参照実装: 盤を 8×8 の配列にして、8 方向を 1 マスずつ辿る ----
static const int DR[8] = {-1, -1, -1, 0, 0, 1, 1, 1};
static const int DC[8] = {-1, 0, 1, -1, 1, -1, 0, 1};

static int at(u64 b, int r, int c) { return (int)((b >> (r * 8 + c)) & 1u); }

static u64 ref_flip(u64 own, u64 opp, int idx) {
    int r0 = idx / 8, c0 = idx % 8;
    if (at(own | opp, r0, c0)) return 0;
    u64 all = 0;
    for (int d = 0; d < 8; d++) {
        u64 line = 0;
        int r = r0 + DR[d], c = c0 + DC[d];
        while (r >= 0 && r < 8 && c >= 0 && c < 8 && at(opp, r, c)) {
            line |= 1ull << (r * 8 + c);
            r += DR[d]; c += DC[d];
        }
        if (line && r >= 0 && r < 8 && c >= 0 && c < 8 && at(own, r, c)) all |= line;
    }
    return all;
}

static u64 ref_legal(u64 own, u64 opp) {
    u64 l = 0;
    for (int i = 0; i < 64; i++)
        if (ref_flip(own, opp, i)) l |= 1ull << i;
    return l;
}

// 角を先に、次に裏返る数の多い手。同じなら番号の小さい手
static int ref_pick(u64 own, u64 opp, int* gain) {
    int best = -1, best_score = -1;
    for (int i = 0; i < 64; i++) {
        u64 f = ref_flip(own, opp, i);
        if (!f) continue;
        int g = __builtin_popcountll(f);
        bool corner = (i == 0 || i == 7 || i == 56 || i == 63);
        int score = (corner ? 32 : 0) + g;
        if (score > best_score) { best_score = score; best = i; *gain = g; }
    }
    return best;
}

// ---- アクセラレータを動かす ----
static void tick() { top->clk = 0; top->eval(); top->clk = 1; top->eval(); }

static u64 hw_legal(u64 own, u64 opp) { top->own = own; top->opp = opp; top->eval(); return top->legal; }
static u64 hw_flip(u64 own, u64 opp, int m) {
    top->own = own; top->opp = opp; top->move = m; top->eval(); return top->flip;
}
// start を 1 クロック入れ、done まで待つ。clocks は start の次の立ち上がりから done が 1 になるまでの数
static int hw_pick(u64 own, u64 opp, int* gain, int* clocks, int* found) {
    top->own = own; top->opp = opp;
    top->start = 1; tick(); top->start = 0;
    int n = 0;
    do { tick(); n++; } while (!top->done && n < 200);
    *clocks = n; *gain = top->best_gain; *found = top->found;
    return top->best;
}

static unsigned long long rng = 12345;
static unsigned rnd(unsigned n) { rng = rng * 6364136223846793005ull + 1442695040888963407ull; return (unsigned)(rng >> 33) % n; }

static long positions = 0, flips_checked = 0, picks_checked = 0;
static long max_clocks = 0;

static void check_position(u64 own, u64 opp) {
    positions++;
    u64 l = hw_legal(own, opp), rl = ref_legal(own, opp);
    if (l != rl) { if (errors < 10) printf("NG legal %016llx %016llx: %016llx (want %016llx)\n",
        (unsigned long long)own, (unsigned long long)opp, (unsigned long long)l, (unsigned long long)rl); errors++; }
    for (int i = 0; i < 64; i++) {
        flips_checked++;
        if (hw_flip(own, opp, i) != ref_flip(own, opp, i)) { if (errors < 10) printf("NG flip at %d\n", i); errors++; }
    }
    int g, cl, f, rg = 0;
    int b = hw_pick(own, opp, &g, &cl, &f);
    int rb = ref_pick(own, opp, &rg);
    int want_clocks = __builtin_popcountll(rl) + 1;
    picks_checked++;
    if (cl > max_clocks) max_clocks = cl;
    if (rb < 0) {
        if (f || cl != 1) { if (errors < 10) printf("NG pick (no move): found=%d clocks=%d\n", f, cl); errors++; }
    } else if (!f || b != rb || g != rg || cl != want_clocks) {
        if (errors < 10) printf("NG pick: best=%d gain=%d clocks=%d (want %d %d %d)\n", b, g, cl, rb, rg, want_clocks);
        errors++;
    }
}

// 乱数で 1 局打ち、途中の盤面を全部調べる。パスも打ち方どおりに扱う
static void random_game() {
    u64 black = (1ull << 28) | (1ull << 35), white = (1ull << 27) | (1ull << 36);
    int side = 0, passes = 0;
    while (passes < 2) {
        u64& own = side ? white : black;
        u64& opp = side ? black : white;
        check_position(own, opp);
        u64 l = ref_legal(own, opp);
        if (!l) { passes++; side ^= 1; continue; }
        passes = 0;
        int k = (int)rnd((unsigned)__builtin_popcountll(l)), idx = -1;
        for (int i = 0; i < 64; i++) if ((l >> i) & 1u) { if (k-- == 0) { idx = i; break; } }
        u64 f = ref_flip(own, opp, idx);
        own |= f | (1ull << idx);
        opp &= ~f;
        side ^= 1;
    }
}

// 深さ depth の葉の数。パスは 1 手と数え、両者が打てなければそこを葉にする
static long long perft(u64 own, u64 opp, int depth, bool hw, bool passed) {
    if (depth == 0) return 1;
    u64 l = hw ? hw_legal(own, opp) : ref_legal(own, opp);
    if (!l) {
        if (passed) return 1;
        return perft(opp, own, depth - 1, hw, true);
    }
    long long n = 0;
    for (int i = 0; i < 64; i++) {
        if (!((l >> i) & 1u)) continue;
        u64 f = hw ? hw_flip(own, opp, i) : ref_flip(own, opp, i);
        n += perft(opp & ~f, own | f | (1ull << i), depth - 1, hw, false);
    }
    return n;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    top = new Vreversi_accel;
    top->start = 0; top->move = 0;
    top->rst = 1; tick(); top->rst = 0;

    // 初期配置の黒番: d3 c4 f5 e6 の 4 手。角は無く、どれも 1 個裏返す → 番号の一番小さい d3 (19)
    u64 b0 = (1ull << 28) | (1ull << 35), w0 = (1ull << 27) | (1ull << 36);
    int g, cl, f;
    int b = hw_pick(b0, w0, &g, &cl, &f);
    printf("start position: legal=%016llx best=%d gain=%d clocks=%d\n",
           (unsigned long long)hw_legal(b0, w0), b, g, cl);

    const int GAMES = 1000;
    for (int i = 0; i < GAMES; i++) random_game();
    printf("random games: %d, positions: %ld, flip checks: %ld, pick checks: %ld, max clocks: %ld\n",
           GAMES, positions, flips_checked, picks_checked, max_clocks);

    for (int d = 1; d <= 8; d++) {
        long long h = perft(b0, w0, d, true, false), r = perft(b0, w0, d, false, false);
        printf("perft %d: accel %lld, ref %lld%s\n", d, h, r, h == r ? "" : "  NG");
        if (h != r) errors++;
    }
    if (errors == 0) printf("PASS\n"); else printf("FAIL: %ld\n", errors);
    delete top;
    return errors ? 1 : 0;
}
