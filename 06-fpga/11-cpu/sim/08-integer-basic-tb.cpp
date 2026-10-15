// 11-8 の試験台。soft-fpga の examples/04-6502/cxx/harness.cpp をそのまま使い、
// Woz Monitor から E000R で Integer BASIC を起こして、次を自分で確かめる。
//   1. '>' のプロンプトが出る
//   2. PRINT 2+3 で 5 が出る (CR から何クロックか)
//   3. 整数だけの計算 (7/2・-7/2・32767+1)
//   4. END の無いプログラムは END ERR で止まる。消すのは NEW でなく SCR
//   5. プログラムがメモリにどう入るか (トークンの並び)
//   6. FOR を 1000 回まわす時間 (クロック数)
// 終わりに PASS か FAIL: n を出す。
#include <cstdint>
#include <cstdio>
#include <string>

extern "C" {
void     sim_init();
void     step();
void     send_key(uint8_t ch);
int      get_display_char();
uint32_t get_cycles();
uint32_t* get_ring_ptr();
uint32_t  get_head();
int       get_ring_size();
}

static int         errors = 0;
static std::string screen;

static void check(bool ok, const char* what) {
    printf("%s %s\n", ok ? "ok" : "NG", what);
    if (!ok) ++errors;
}

static void run(long n) {
    for (long i = 0; i < n; ++i) {
        step();
        for (int ch; (ch = get_display_char()) >= 0;)
            if (ch != 0x7F) screen += (char)ch;
    }
}

// want が (今から後に) 出るまで回し、出たときのクロック数を返す。出なければ -1
static long run_until(const std::string& want, long limit) {
    const size_t from = screen.size();
    for (long i = 0; i < limit; ++i) {
        run(1);
        if (screen.find(want, from) != std::string::npos) return (long)get_cycles();
    }
    return -1;
}

// 1 行打ち込み、CR を送ってから次のプロンプト '>' が出るまで回す。
// 出た字 (打ち込んだ字のエコーを除く) を返し、CR から '>' までのクロック数を *cycles に入れる
static std::string line(const std::string& s, long* cycles = nullptr, const char* prompt = "\n>") {
    for (char c : s) send_key((uint8_t)c);
    run_until(s, 4000000);                 // エコーが済むまで
    screen.clear();
    send_key('\r');
    const long cr_at = (long)get_cycles();
    const long end_at = run_until(prompt, 40000000);
    if (cycles) *cycles = end_at < 0 ? -1 : end_at - cr_at;
    return screen;
}

int main() {
    sim_init();
    check(run_until("\\\n", 100000) > 0, "wozmon prompt '\\'");

    // 1. E000R で BASIC へ
    check(line("E000R") == "\n\nE000: 4C\n>", "E000R starts Integer BASIC and prints '>'");

    // 2. PRINT 2+3
    long c = 0;
    const std::string r = line("PRINT 2+3", &c);
    printf("PRINT 2+3 -> \"%s\" (%ld clocks from CR to '>')\n", r.c_str(), c);
    check(r == "\n5\n\n>", "PRINT 2+3 prints 5");
    screen.clear();
    send_key('P'); send_key('R'); send_key('I'); send_key('N'); send_key('T');
    send_key(' '); send_key('2'); send_key('+'); send_key('3');
    run_until("2+3", 4000000);
    send_key('\r');
    const long cr_at = (long)get_cycles();
    const long five_at = run_until("5", 4000000);
    printf("PRINT 2+3: CR -> '5' %ld clocks\n", five_at - cr_at);

    // '5' ($B5) を書いたクロックの前後をリングバッファから出す。BASIC は $D012 でなく $D0F2 に書く
    run(400000);
    screen.clear();
    for (char ch : std::string("PRINT 2+3\r")) send_key((uint8_t)ch);
    const uint32_t* ring = get_ring_ptr();
    const uint32_t  mask = (uint32_t)get_ring_size() - 1;
    auto sample = [&](int k) { return ring[((get_head() - k) & mask) * 2]; };  // k = 1 が直近
    std::string trace;
    for (long i = 0; i < 4000000 && trace.empty(); ++i) {
        run(1);
        const uint32_t w = sample(1);
        if (((w >> 24) & 1) && (w & 0xFFFF) == 0xD0F2 && ((w >> 16) & 0xFF) == 0xB5) {
            run(2);
            char b[32];
            for (int k = 16; k >= 1; --k) {
                const uint32_t x = sample(k);
                snprintf(b, sizeof b, "%04X/%02X%s%s ", x & 0xFFFF, (x >> 16) & 0xFF,
                         ((x >> 24) & 1) ? "W" : "", ((x >> 25) & 1) ? "*" : "");
                trace += b;
            }
        }
    }
    run(400000);
    printf("around '5': %s\n", trace.c_str());
    check(trace == "E3D4/E6* 0024/24 0024/01 0024/02W E3D5/02 E3D6/2C* E3D7/F2 D0F2/D0 "
                   "E3D8/00 E3D9/30* E3DA/FB E3DB/8D* E3DC/F2 D0F2/B5W E3DD/00 E3DE/60* ",
          "'5' is written to $D0F2 after INC $24 and BIT $D0F2");

    // 3. 整数だけ
    check(line("PRINT 7/2") == "\n3\n\n>", "PRINT 7/2 prints 3 (integer division)");
    check(line("PRINT -7/2") == "\n-3\n\n>", "PRINT -7/2 prints -3 (truncates toward 0)");
    check(line("PRINT 32767+1") == "\n*** >32767 ERR\n>", "PRINT 32767+1 is an error (16-bit signed)");

    // 4. END の無いプログラム
    line("10 FOR I=1 TO 5");
    line("20 PRINT I*I;\" \";");
    line("30 NEXT I");
    line("40 PRINT");
    const std::string run1 = line("RUN");
    printf("RUN -> \"%s\"\n", run1.c_str());
    check(run1 == "\n1 4 9 16 25 \n*** END ERR\n>", "a program without END stops with END ERR");
    line("50 END");
    check(line("RUN") == "\n1 4 9 16 25 \n\n>", "with 50 END it ends normally");

    // 5. トークンの並び: SCR で消して 2 行だけにし、モニタへ戻ってメモリを見る。
    //    Apple-I の BASIC に NEW は無い (消すのは SCR)
    check(line("NEW") == "\n*** SYNTAX ERR\n>", "NEW is not a command (SYNTAX ERR)");
    line("SCR");
    line("10 PRINT 2+3");
    line("20 END");
    line("CALL -151", nullptr, "\\\n");    // モニタへ ('\' が出る)
    screen.clear();
    for (char ch : std::string("4C.4D\r")) send_key((uint8_t)ch);
    run(400000);
    printf("HIMEM: %s", screen.c_str());
    check(screen.find("004C: 00 10") != std::string::npos, "HIMEM ($4C,$4D) = $1000");
    screen.clear();
    for (char ch : std::string("CA.CB\r")) send_key((uint8_t)ch);
    run(400000);
    printf("PP: %s", screen.c_str());
    check(screen.find("00CA: EF 0F") != std::string::npos, "program pointer ($CA,$CB) = $0FEF");
    screen.clear();
    for (char ch : std::string("0FEF.0FFF\r")) send_key((uint8_t)ch);
    run(400000);
    printf("program bytes: %s", screen.c_str());
    check(screen.find("0FEF: 0C\n0FF0: 0A 00 62 B2 02 00 12 B3\n0FF8: 03 00 01 05 14 00 51 01") !=
              std::string::npos,
          "10 PRINT 2+3 / 20 END is stored as 17 bytes of tokens");

    // 6. 暖かい再始動 (E2B3) ならプログラムが残る
    check(line("E2B3R") == "\n\nE2B3: 20\n>", "E2B3R returns to BASIC");
    check(line("LIST") == "\n   10 PRINT 2+3\n   20 END \n\n>", "LIST shows the same program");

    // 7. FOR を 1000 回
    line("SCR");
    line("10 FOR I=1 TO 1000");
    line("20 NEXT I");
    line("30 END");
    long loop = 0;
    line("RUN", &loop);
    line("10 FOR I=1 TO 2000");
    long loop2 = 0;
    line("RUN", &loop2);
    printf("RUN FOR 1..1000: %ld clocks, FOR 1..2000: %ld clocks, per pass %.1f clocks\n", loop, loop2,
           (loop2 - loop) / 1000.0);
    check(loop > 0 && loop2 > loop, "the loop runs and returns to '>'");

    if (errors == 0) printf("PASS\n");
    else             printf("FAIL: %d\n", errors);
    return errors == 0 ? 0 : 1;
}
