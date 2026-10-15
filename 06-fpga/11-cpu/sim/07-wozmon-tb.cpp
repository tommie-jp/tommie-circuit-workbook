// 11-7 の試験台。soft-fpga の examples/04-6502/cxx/harness.cpp をそのまま使い、
// Woz Monitor (wozmon) を 6502 の RTL で動かして、次を自分で確かめる。
//   1. リセットから '\' のプロンプトが出る (何クロック目か)
//   2. キーを待つ間、$D011 (KBDCR) を何クロックごとに読むか
//   3. '\' を出すとき、$D012 (DSP) へ何を書くか
//   4. 自分で打ち込んだプログラムが動いて HELLO を出す
// 終わりに PASS か FAIL: n を出す。
#include <cstdint>
#include <cstdio>
#include <string>
#include <vector>

extern "C" {
void      sim_init();
void      step();
void      send_key(uint8_t ch);
int       get_display_char();
uint32_t  get_cycles();
uint32_t* get_ring_ptr();
uint32_t  get_head();
int       get_ring_size();
}

static int         errors = 0;
static std::string screen;  // 端末に出た字 (0x7F は捨てる)

static void check(bool ok, const char* what) {
    printf("%s %s\n", ok ? "ok" : "NG", what);
    if (!ok) ++errors;
}

// n クロック進め、出た字を screen に足す
static void run(long n) {
    for (long i = 0; i < n; ++i) {
        step();
        for (int ch; (ch = get_display_char()) >= 0;)
            if (ch != 0x7F) screen += (char)ch;
    }
}

// want が screen に現れるまで回す。現れたクロック数を返す (現れなければ -1)
static long run_until(const std::string& want, long limit) {
    const size_t from = screen.size();
    for (long i = 0; i < limit; ++i) {
        run(1);
        if (screen.find(want, from) != std::string::npos) return (long)get_cycles();
    }
    return -1;
}

static void type(const std::string& s) {
    for (char c : s) send_key((uint8_t)c);
}

// リングバッファの直近 n サンプルの Word0 (AB・DB・WE・SYNC)
static std::vector<uint32_t> last_samples(int n) {
    const uint32_t* ring = get_ring_ptr();
    const uint32_t  mask = (uint32_t)get_ring_size() - 1;
    std::vector<uint32_t> v;
    for (int k = n; k >= 1; --k) v.push_back(ring[((get_head() - k) & mask) * 2]);
    return v;
}

int main() {
    sim_init();

    // 1. '\' のプロンプト
    const long prompt_at = run_until("\\\n", 100000);
    printf("prompt '\\' at cycle %ld\n", prompt_at);
    check(prompt_at > 0, "wozmon prints '\\' and a new line after reset");

    // 3. '\' を出したクロックを探す: WE = 1 で addr = $D012
    sim_init();
    screen.clear();
    long dsp_write_cycle = -1;
    uint8_t dsp_data = 0;
    for (long i = 0; i < 1000 && dsp_write_cycle < 0; ++i) {
        run(1);
        const uint32_t w = last_samples(1)[0];
        const uint8_t  data = (w >> 16) & 0xFF;
        if (((w >> 24) & 1) && (w & 0xFFFF) == 0xD012 && (data & 0x80)) {
            dsp_write_cycle = (long)get_cycles();
            dsp_data = data;
        }
    }
    printf("first write to $D012 with bit7=1: cycle %ld data=%02X\n", dsp_write_cycle, dsp_data);
    run(4);
    printf("around the write (addr data we sync):");
    for (uint32_t w : last_samples(14))
        printf(" %04X/%02X%s%s", w & 0xFFFF, (w >> 16) & 0xFF, ((w >> 24) & 1) ? "W" : "", ((w >> 25) & 1) ? "*" : "");
    printf("\n");
    check(dsp_data == 0xDC, "the prompt is written to $D012 as $DC ('\\' + $80)");

    // 2. キー待ちのループ: 直近 21 クロックで $D011 を読んだクロックの間隔
    run(5000);
    const std::vector<uint32_t> s = last_samples(21);
    std::vector<int> at;
    for (int i = 0; i < (int)s.size(); ++i)
        if ((s[i] & 0xFFFF) == 0xD011 && !((s[i] >> 24) & 1)) at.push_back(i);
    printf("wait loop (21 clocks):");
    for (uint32_t w : s) printf(" %04X/%02X%s", w & 0xFFFF, (w >> 16) & 0xFF, ((w >> 25) & 1) ? "*" : "");
    printf("\n");
    bool every7 = at.size() >= 2;
    for (size_t k = 1; k < at.size(); ++k) every7 = every7 && (at[k] - at[k - 1] == 7);
    printf("reads of $D011: %zu, interval %d clocks\n", at.size(), at.size() >= 2 ? at[1] - at[0] : -1);
    check(every7, "the wait loop reads $D011 every 7 clocks (LDA abs 4 + BPL taken 3)");

    // 4. プログラムを打ち込んで走らせる
    //   0300: LDX #0 / LDA $0310,X / BEQ +6 / JSR $FFEF (ECHO) / INX / BNE -11 / JMP $FF00
    //   0310: "HELLO" と CR (最上位ビットを 1 にした Apple-I の字) と 0
    type("0300: A2 00 BD 10 03 F0 06 20 EF FF E8 D0 F5 4C 00 FF\r");
    run(300000);
    type("0310: C8 C5 CC CC CF 8D 00\r");
    run(300000);
    printf("--- store ---\n%s-------------\n", screen.c_str());
    // ':' の行は、書く前に番地と今の中身 (00) を 1 回出す
    check(screen.find("4C 00 FF\n\n0300: 00\n") != std::string::npos &&
              screen.find("8D 00\n\n0310: 00\n") != std::string::npos,
          "store lines are echoed and show the old byte (00)");

    screen.clear();
    type("0300.0316\r");
    run(300000);
    printf("--- dump ---\n%s------------\n", screen.c_str());
    check(screen == "0300.0316\n\n0300: A2 00 BD 10 03 F0 06 20"
                    "\n0308: EF FF E8 D0 F5 4C 00 FF\n0310: C8 C5 CC CC CF 8D 00\n",
          "the dump shows the same 23 bytes");

    screen.clear();
    type("0300R");
    run(300000);
    type("\r");
    const long cr_at = (long)get_cycles();
    const long h_at = run_until("H", 200000);
    const long done_at = run_until("\\\n", 200000);
    run(1000);
    printf("--- run ---\n%s-----------\n", screen.c_str());
    printf("CR typed at cycle %ld, 'H' at %ld (+%ld), back to '\\' at %ld (+%ld)\n", cr_at, h_at,
           h_at - cr_at, done_at, done_at - cr_at);
    check(screen == "0300R\n\n0300: A2HELLO\n\\\n", "0300R prints \"0300: A2\", HELLO and '\\'");

    if (errors == 0) printf("PASS\n");
    else             printf("FAIL: %d\n", errors);
    return errors == 0 ? 0 : 1;
}
