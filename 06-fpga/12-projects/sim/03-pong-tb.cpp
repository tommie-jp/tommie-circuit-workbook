// 12-3 の試験台。harness.cpp で 1 画面ずつ回し、C++ で書き直した同じ遊びの模型と、
// 点と 160 × 120 の全画素を画面ごとに突き合わせる (球とラケットの位置は画素に出る)。
// verilator --cc --exe --build pong.v harness.cpp tb.cpp
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <algorithm>

extern "C" { void sim_init(); void set_keys(uint32_t); void run_frame(); uint8_t* get_fb(); uint32_t get_score();
              uint32_t get_snd_kind(); uint32_t get_snd_edges(); uint32_t get_snd_clocks(); }

// ---- 模型 ----
struct Game { int bx = 78, by = 58; bool left = true, up = false, fast = false; int pl = 52, pr = 52, sl = 0, sr = 0;
              int snd_n = 0; bool snd_hit = false; };   // 音: 鳴らす画面の残りと、ヒットの音 (v[3]) か壁・点の音 (v[4]) か
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

static void step(Game& g, uint32_t k, int* hits, int* points, int* walls = nullptr) {
    Game n = g;
    int bc = g.by + 1, dy = g.fast ? 2 : 1;
    n.pl = paddle(g.pl, k & 1, k & 2, k & 16, bc);
    n.pr = paddle(g.pr, k & 4, k & 8, k & 32, bc);
    bool on_l = g.by + 3 > g.pl && g.by < g.pl + PH, on_r = g.by + 3 > g.pr && g.by < g.pr + PH;
    bool at_l = g.left && g.bx >= LX + 1 && g.bx <= LX + 3, at_r = !g.left && g.bx + BS >= RX && g.bx + BS <= RX + 2;
    bool out_l = g.left && g.bx < 2, out_r = !g.left && g.bx + BS > 158;
    bool out = out_l || out_r, hit = (at_l && on_l) || (at_r && on_r), wall = false;
    if (out) {
        if (out_l) n.sr = (g.sr + 1) % 10; else n.sl = (g.sl + 1) % 10;
        n.bx = 78; n.by = 58; n.fast = false; n.up = !g.up;
        (*points)++;
    } else {
        auto bounce = [&](int p) { n.fast = bc < p + 4 || bc >= p + PH - 4; n.up = bc < p + 8; (*hits)++; };
        if (at_l && on_l)      { n.left = false; bounce(g.pl); n.bx = g.bx + 2; }
        else if (at_r && on_r) { n.left = true;  bounce(g.pr); n.bx = g.bx - 2; }
        else n.bx = g.left ? g.bx - 2 : g.bx + 2;
        if (g.up) { if (g.by <= TOP + dy - 1) { n.up = false; n.by = TOP; wall = true; } else n.by = g.by - dy; }
        else      { if (g.by + 3 + dy >= BOTTOM) { n.up = true; n.by = BOTTOM - 3; wall = true; } else n.by = g.by + dy; }
    }
    // 音 (pong.v と同じ優先順位: 点 > ヒット > 壁。どれも無ければ、残りを 1 画面ぶん減らす)
    if (out)            { n.snd_n = 16; n.snd_hit = false; }
    else if (hit)       { n.snd_n = 1;  n.snd_hit = true;  }
    else if (wall)      { n.snd_n = 1;  n.snd_hit = false; }
    else if (g.snd_n > 0) n.snd_n = g.snd_n - 1;
    if (wall && walls) (*walls)++;
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

static int walls_total_tmp = 0;
static long errors = 0;
static Game last;
// 音の統計 (全部の筋書きの合計)。ヒット・壁・点の 3 種類の音が、どれも 1 回は鳴ったことを最後に確かめる
static long snd_frames = 0, snd_hit_frames = 0, snd_low_frames = 0, walls_total = 0;
static int hit_edges_min = 1 << 30, hit_edges_max = 0, low_edges_min = 1 << 30, low_edges_max = 0;
static int run(const char* name, int frames, uint32_t (*keys)(int), bool quiet = false) {
    sim_init();
    Game g;
    int hits = 0, points = 0, first_point = -1, lit0 = 0;
    bool prev_s = false;                    // 模型の sound (画面をまたいで覚える)
    for (int f = 0; f < frames; f++) {
        uint32_t k = keys(f);
        set_keys(k);
        run_frame();
        const uint8_t* fb = get_fb();
        int bad = 0, lit = 0;
        for (int y = 0; y < 120; y++)
            for (int x = 0; x < 160; x++) { lit += fb[y * 160 + x]; if (fb[y * 160 + x] != render(g, x, y)) bad++; }
        if (f == 0) lit0 = lit;
        // 音: この画面の sound は、行ごとに 1 か 0 の矩形波 (v の 1 ビットを、残りがある間だけ通す)。山の数と 1 のクロック数を数える
        unsigned exp_edges = 0, exp_rows = 0;
        for (int v = 0; v < 120; v++) {
            bool sv = g.snd_n > 0 && ((v >> (g.snd_hit ? 3 : 4)) & 1);
            if (sv && !prev_s) exp_edges++;
            exp_rows += sv;
            prev_s = sv;
        }
        if (get_snd_edges() != exp_edges || get_snd_clocks() != 160u * exp_rows) {
            if (errors < 5) printf("NG %s frame %d: sound edges %u (want %u), clocks %u (want %u)\n", name, f,
                                   get_snd_edges(), exp_edges, get_snd_clocks(), 160u * exp_rows);
            errors++;
        }
        if (g.snd_n > 0) {
            snd_frames++;
            if (g.snd_hit) { snd_hit_frames++; hit_edges_min = std::min<int>(hit_edges_min, exp_edges); hit_edges_max = std::max<int>(hit_edges_max, exp_edges); }
            else           { snd_low_frames++; low_edges_min = std::min<int>(low_edges_min, exp_edges); low_edges_max = std::max<int>(low_edges_max, exp_edges); }
        }
        int p0 = points;
        step(g, k, &hits, &points, (int*)&walls_total_tmp);
        walls_total += walls_total_tmp; walls_total_tmp = 0;
        const uint32_t want_kind = g.snd_n == 0 ? 0 : g.snd_hit ? 1 : 2;   // 次の画面で鳴る音
        if (get_snd_kind() != want_kind) {
            if (errors < 5) printf("NG %s frame %d: snd_kind %u (want %u)\n", name, f, get_snd_kind(), want_kind);
            errors++;
        }
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
    printf("sound: %ld frames (hit %ld, wall/score %ld), rising edges per frame: hit tone %d..%d, low tone %d..%d, wall bounces %ld\n",
           snd_frames, snd_hit_frames, snd_low_frames, hit_edges_min, hit_edges_max, low_edges_min, low_edges_max, walls_total);
    if (snd_hit_frames == 0 || snd_low_frames == 0 || walls_total == 0) { printf("NG: 3 kinds of sound did not all play\n"); errors++; }
    if (errors == 0) printf("PASS\n"); else printf("FAIL: %ld\n", errors);
    return errors ? 1 : 0;
}
