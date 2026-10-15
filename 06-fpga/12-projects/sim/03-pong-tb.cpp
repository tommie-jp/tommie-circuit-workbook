// 12-3 の試験台。harness.cpp で 1 画面ずつ回し、C++ で書き直した同じ遊びの模型と、
// 点と 160 × 120 の全画素を画面ごとに突き合わせる (球とラケットの位置は画素に出る)。
// verilator --cc --exe --build pong.v harness.cpp tb.cpp
#include <cstdint>
#include <cstdio>
#include <cstdlib>

extern "C" { void sim_init(); void set_keys(uint32_t); void run_frame(); uint8_t* get_fb(); uint32_t get_score(); }

// ---- 模型 ----
struct Game { int bx = 78, by = 58; bool left = true, up = false, fast = false; int pl = 52, pr = 52, sl = 0, sr = 0; };
static const int TOP = 2, BOTTOM = 118, PH = 16, LX = 6, RX = 151, BS = 3;

static int paddle(int p, bool u, bool d, bool aut, int bc) {
    if (aut) {
        if (bc < p + 8 && p > TOP) return p - 1;
        if (bc > p + 8 && p < BOTTOM - PH) return p + 1;
        return p;
    }
    if (u && p >= TOP + 2) return p - 2;
    if (d && p + 2 <= BOTTOM - PH) return p + 2;
    return p;
}

static void step(Game& g, uint32_t k, int* hits, int* points) {
    Game n = g;
    int bc = g.by + 1, dy = g.fast ? 2 : 1;
    n.pl = paddle(g.pl, k & 1, k & 2, k & 16, bc);
    n.pr = paddle(g.pr, k & 4, k & 8, k & 32, bc);
    bool on_l = g.by + 3 > g.pl && g.by < g.pl + PH, on_r = g.by + 3 > g.pr && g.by < g.pr + PH;
    bool at_l = g.left && g.bx >= LX + 1 && g.bx <= LX + 3, at_r = !g.left && g.bx + BS >= RX && g.bx + BS <= RX + 2;
    bool out_l = g.left && g.bx < 2, out_r = !g.left && g.bx + BS > 158;
    if (out_l || out_r) {
        if (out_l) n.sr = (g.sr + 1) % 10; else n.sl = (g.sl + 1) % 10;
        n.bx = 78; n.by = 58; n.fast = false; n.up = !g.up;
        (*points)++;
    } else {
        auto bounce = [&](int p) { n.fast = bc < p + 4 || bc >= p + PH - 4; n.up = bc < p + 8; (*hits)++; };
        if (at_l && on_l)      { n.left = false; bounce(g.pl); n.bx = g.bx + 2; }
        else if (at_r && on_r) { n.left = true;  bounce(g.pr); n.bx = g.bx - 2; }
        else n.bx = g.left ? g.bx - 2 : g.bx + 2;
        if (g.up) { if (g.by <= TOP + dy - 1) { n.up = false; n.by = TOP; } else n.by = g.by - dy; }
        else      { if (g.by + 3 + dy >= BOTTOM) { n.up = true; n.by = BOTTOM - 3; } else n.by = g.by + dy; }
    }
    g = n;
}

static const uint8_t SEG[10] = {0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f};
static bool digit(int n, int x0, int x, int y) {
    if (x < x0 || x >= x0 + 8 || y < 6 || y >= 20) return false;
    int s = SEG[n], dx = x - x0, d = y - 6;
    return ((s & 1) && d <= 1) || ((s & 2) && dx >= 6 && d <= 7) || ((s & 4) && dx >= 6 && d >= 6)
        || ((s & 8) && d >= 12) || ((s & 16) && dx <= 1 && d >= 6) || ((s & 32) && dx <= 1 && d <= 7)
        || ((s & 64) && d >= 6 && d <= 7);
}
static int render(const Game& g, int x, int y) {   // 1 画素。画面に出すのは「動かす前」の位置
    return y < TOP || y >= BOTTOM || (x == 79 && (y & 4))
        || (x >= LX && x < LX + 3 && y >= g.pl && y < g.pl + PH)
        || (x >= RX && x < RX + 3 && y >= g.pr && y < g.pr + PH)
        || (x >= g.bx && x < g.bx + BS && y >= g.by && y < g.by + 3)
        || digit(g.sl, 60, x, y) || digit(g.sr, 92, x, y);
}

static long errors = 0;
static Game last;
static int run(const char* name, int frames, uint32_t (*keys)(int), bool quiet = false) {
    sim_init();
    Game g;
    int hits = 0, points = 0, first_point = -1, lit0 = 0;
    for (int f = 0; f < frames; f++) {
        uint32_t k = keys(f);
        set_keys(k);
        run_frame();
        const uint8_t* fb = get_fb();
        int bad = 0, lit = 0;
        for (int y = 0; y < 120; y++)
            for (int x = 0; x < 160; x++) { lit += fb[y * 160 + x]; if (fb[y * 160 + x] != render(g, x, y)) bad++; }
        if (f == 0) lit0 = lit;
        int p0 = points;
        step(g, k, &hits, &points);
        if (points != p0 && first_point < 0) first_point = f;
        bool same = get_score() == (uint32_t)(g.sl << 4 | g.sr);
        if (bad || !same) {
            if (errors < 5) printf("NG %s frame %d: %d pixels differ, score %02x\n", name, f, bad, get_score());
            errors++;
        }
        if (g.by < TOP || g.by + 3 > BOTTOM) { printf("NG %s: ball outside walls\n", name); errors++; }
    }
    last = g;
    if (!quiet)
        printf("%s: %d frames, lit pixels in frame 0 = %d, paddle hits %d, points %d (first at frame %d), score %d-%d\n",
               name, frames, lit0, hits, points, first_point, g.sl, g.sr);
    return points;
}

static uint32_t none(int)      { return 0; }
static uint32_t both_auto(int) { return 0x30; }
static uint32_t hold_up_l(int) { return 0x01; }
static unsigned long long rng = 1;
static uint32_t random_keys(int f) {   // 30 画面ごとに押すボタンを乱数で替える
    static uint32_t k = 0;
    if (f % 30 == 0) { rng = rng * 6364136223846793005ull + 1; k = (uint32_t)(rng >> 58); }
    return k;
}

int main() {
    run("no input", 300, none);
    run("hold up (left)", 30, hold_up_l);
    printf("  left paddle top after holding up: %d\n", last.pl);
    if (last.pl != 2) errors++;
    run("both auto", 3600, both_auto);
    run("random keys", 10000, random_keys);
    if (errors == 0) printf("PASS\n"); else printf("FAIL: %ld\n", errors);
    return errors ? 1 : 0;
}
