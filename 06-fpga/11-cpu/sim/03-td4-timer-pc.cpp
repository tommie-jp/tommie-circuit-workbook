// 11-3 の試験台 (Pico 2 のプログラムの側)。本文の td4_113.cpp を 5-8 と同じ替え玉の GPIO とタイマ
// (05-soft-fpga-pico/sim/pcstub) で PC で回す。td4_113_pc.cpp は本文の .cpp の
// `while (true)` を `while (g_run())` に、`int main()` を `void target_main()` に替えた物 (03-td4-timer-run.sh が作る)。
// 仮想時刻はタイマの呼び出しの回数 x 半周期。
#include <cstdio>
#include "td4_113_pc.cpp"

static long t_clk[4000];   // CLK の立ち上がりの時刻 (µs)
static int  n_clk = 0;
static long t_mon[8]; static unsigned v_mon[8]; static int n_mon = 0;
static long t_aux = -1;
static unsigned mon_last = 0;

static void hook(uint p, int v) {
    const long t = g_iter * g_delay;
    if (p == PIN_CLK && v == 1 && n_clk < 4000) t_clk[n_clk++] = t;
    if (p == PIN_AUX && v == 1 && t_aux < 0) t_aux = t;
}

static void collect() {   // タイマの呼び出しのたびに MON (GP18〜GP21) を見て、変わった時刻を記録する
    const unsigned mon = (g_gpio >> PIN_MON0) & 0xFu;
    if (mon != mon_last && n_mon < 8) { t_mon[n_mon] = g_iter * g_delay; v_mon[n_mon] = mon; n_mon++; mon_last = mon; }
}

static int run(bool fast, long half_us) {
    g_iter = 0; g_cb = nullptr; g_gpio = 0; g_outmask = 0; n_clk = 0; n_mon = 0; t_aux = -1; mon_last = 0; g_count = 0;
    g_extlow = fast ? (1u << (PIN_SW1 + 3)) : 0u;     // SW4 (GP13) を ON
    g_hook = hook;
    g_step = [](long) { collect(); };
    g_limit = 2 * 1700 + 10;                          // 1700 クロックぶん
    target_main();
    collect();
    int fails = 0;
    const char* tag = fast ? "SW4 ON (1 kHz)" : "SW4 OFF (タイマー)";
    const bool half_ok = g_delay == half_us;
    printf("%s %s: 半周期 %ld µs\n", half_ok ? "PASS" : "FAIL", tag, (long)g_delay);
    fails += !half_ok;
    const long t0 = t_clk[1];                          // 最初の命令を実行する立ち上がり (0 番めはリセット中)
    const long T = 2 * half_us;
    const long want_n[3] = {544, 1089, 1634};
    const unsigned want_v[3] = {0x1, 0x3, 0xF};
    for (int i = 0; i < 3; i++) {
        const long dt = (i < n_mon) ? t_mon[i] - t0 : -1;
        const bool ok = i < n_mon && v_mon[i] == want_v[i] && dt == want_n[i] * T;
        fails += !ok;
        printf("%s %s: LED が %X になる時刻 %.6f s (= %ld クロック x %ld µs)\n", ok ? "PASS" : "FAIL", tag,
               i < n_mon ? v_mon[i] : 0u, dt / 1e6, dt / T, T);
    }
    const bool aux_ok = t_aux - t0 == want_n[2] * T;
    printf("%s %s: AUX が H になる時刻 %.6f s\n", aux_ok ? "PASS" : "FAIL", tag, (t_aux - t0) / 1e6);
    fails += !aux_ok;
    const bool stay = n_mon == 3;
    printf("%s %s: そのあと LED は変わらない (変化 %d 回)\n", stay ? "PASS" : "FAIL", tag, n_mon);
    fails += !stay;
    return fails;
}

int main() {
    int fails = run(false, 55080) + run(true, 500);
    printf(fails ? "FAILED %d\n" : "ALL PASS\n", fails);
    return fails ? 1 : 0;
}
