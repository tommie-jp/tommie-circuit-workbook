// 11-12 の試験台。apple1_fpga (65C02 + RAM + ROM + UART) を 27 MHz・115 200 bps のまま回し、
// PC の側の UART (送り・受け) をこの C++ で真似て、ピンの上の 1 ビットずつで話す。
//   1. リセットすると '\' と CR LF が届く
//   2. 小文字で打っても大文字になってエコーが返る。打ち込んだプログラムが HELLO を出す
//   3. E000R で Integer BASIC。PRINT 2+3 で 5
//   4. FOR を 1000 回まわす時間 (クロック数)
//   5. 1 字を送り終えてから、エコーの 1 字が始まるまでのクロック数
// 終わりに PASS か FAIL: n を出す。
#include <cstdint>
#include <cstdio>
#include <string>

#include "Vapple1_fpga.h"
#include "verilated.h"

static const double CLK_HZ = 27e6;
static const double BAUD = 115200.0;
static const double BIT = CLK_HZ / BAUD;  // 1 ビット = 234.375 クロック

static Vapple1_fpga* dut;
static uint64_t      cycle = 0;
static int           errors = 0;
static std::string   screen;        // FPGA から届いた字
static long          kbd_reads = 0, dsp_writes = 0, instructions = 0;
static uint64_t      kbd_at = 0, dsp_at = 0;   // 最後に KBD を読んだ・DSP に書いたクロック

// ---- PC の側の受け手: txd を見て字にする ----
static int      rx_state = 0;       // 0 = 待つ、1 = 受けている
static double   rx_next = 0;        // 次に読む時刻 (クロック)
static int      rx_bit = 0;
static uint8_t  rx_byte = 0;
static uint64_t rx_start_at = 0;    // 最後の字のスタートビットが始まったクロック

static void pc_receive() {
    const int line = dut->txd;
    if (rx_state == 0) {
        if (line == 0) {            // スタートビットの始まり
            rx_state = 1;
            rx_start_at = cycle;
            rx_next = cycle + BIT * 1.5;   // bit0 の真ん中
            rx_bit = 0;
            rx_byte = 0;
        }
    } else if (cycle >= (uint64_t)rx_next) {
        if (rx_bit < 8) {
            rx_byte |= (uint8_t)(line << rx_bit);
            ++rx_bit;
            rx_next += BIT;
        } else {                    // ストップビット
            if (line != 1) printf("framing error at cycle %llu\n", (unsigned long long)cycle);
            screen += (char)rx_byte;
            rx_state = 0;
        }
    }
}

// ---- PC の側の送り手: 字の列を rxd に 1 ビットずつ出す ----
static std::string tx_queue;
static double      tx_t0 = -1;      // 今送っている字のスタートビットの時刻
static uint64_t    tx_start_at = 0; // 最後の字のスタートビットが始まったクロック
static uint64_t    tx_end_at = 0;   // 最後の字のストップビットが終わったクロック

static void pc_send() {
    if (tx_t0 < 0) {
        if (tx_queue.empty()) { dut->rxd = 1; return; }
        tx_t0 = (double)cycle;
        tx_start_at = cycle;
    }
    const int k = (int)((cycle - tx_t0) / BIT);   // 何ビット目か (0 = スタート、9 = ストップ)
    const uint8_t c = (uint8_t)tx_queue[0];
    if (k == 0)      dut->rxd = 0;
    else if (k <= 8) dut->rxd = (c >> (k - 1)) & 1;
    else if (k == 9) dut->rxd = 1;
    else {                                         // 1 字送り終えた
        tx_queue.erase(0, 1);
        tx_end_at = cycle;
        tx_t0 = -1;
        dut->rxd = 1;
    }
}

static void tick() {
    pc_send();
    dut->clk = 0;
    dut->eval();
    dut->clk = 1;
    dut->eval();
    ++cycle;
    if (dut->kbd_stb) { ++kbd_reads; kbd_at = cycle; }
    if (dut->dsp_stb) { ++dsp_writes; dsp_at = cycle; }
    if (dut->sync) ++instructions;
    pc_receive();
}

static void check(bool ok, const char* what) {
    printf("%s %s\n", ok ? "ok" : "NG", what);
    if (!ok) ++errors;
}

// want が今から後に届くまで回す。届いたクロックを返す (届かなければ 0)
static uint64_t run_until(const std::string& want, uint64_t limit) {
    const size_t from = screen.size();
    for (uint64_t i = 0; i < limit; ++i) {
        tick();
        if (screen.find(want, from) != std::string::npos) return cycle;
    }
    return 0;
}

// 1 行を送り、エコーが済むまで待ってから CR を送り、prompt が届くまで回す。届いた字を返す
static std::string line(const std::string& s, const std::string& prompt, uint64_t* clocks = nullptr) {
    tx_queue += s;
    while (!tx_queue.empty()) tick();
    for (int i = 0; i < 20000; ++i) tick();       // 最後のエコーが届くまで
    screen.clear();
    tx_queue += '\r';
    while (!tx_queue.empty()) tick();
    const uint64_t cr_end = tx_end_at;
    const uint64_t got = run_until(prompt, 200000000);
    if (clocks) *clocks = got ? got - cr_end : 0;
    return screen;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    dut = new Vapple1_fpga;
    dut->rxd = 1;
    dut->rst = 1;
    for (int i = 0; i < 16; ++i) tick();
    dut->rst = 0;

    // 1. リセット直後
    const uint64_t prompt_at = run_until("\\\r\n", 1000000);
    printf("prompt at clock %llu (%.1f us)\n", (unsigned long long)prompt_at, prompt_at / 27.0);
    check(prompt_at > 0 && screen == "\\\r\n", "reset prints '\\' CR LF on the UART");

    // 5. エコーの遅れ: 'a' を 1 字送り、そのスタートビットから、返る 'A' のスタートビットまで
    screen.clear();
    tx_queue += "a";
    run_until("A", 100000);
    const uint64_t lag = rx_start_at - tx_start_at;
    printf("echo: 'a' start bit at %llu, 'A' start bit at %llu (+%llu clocks = %.2f us = %.2f bits)\n",
           (unsigned long long)tx_start_at, (unsigned long long)rx_start_at, (unsigned long long)lag,
           lag / 27.0, lag / BIT);
    printf("echo: KBD read at +%llu clocks, DSP write at +%llu clocks (from the start bit of 'a')\n",
           (unsigned long long)(kbd_at - tx_start_at), (unsigned long long)(dsp_at - tx_start_at));
    check(screen == "A", "lower-case 'a' comes back as 'A'");
    tx_queue += "\x1b";                           // ESC で行を捨てる
    run_until("\\\r\n", 1000000);

    // 2. 11-7 と同じプログラム (小文字で打つ)
    line("0300: a2 00 bd 10 03 f0 06 20 ef ff e8 d0 f5 4c 00 ff", "0300: 00\r\n");
    line("0310: c8 c5 cc cc cf 8d 00", "0310: 00\r\n");
    const std::string r = line("0300R", "\\\r\n");
    printf("--- 0300R ---\n%s-------------\n", r.c_str());
    check(r == "\r\n\r\n0300: A2HELLO\r\n\\\r\n", "0300R prints HELLO");

    // 3. Integer BASIC
    check(line("E000R", ">") == "\r\n\r\nE000: 4C\r\n>", "E000R prints '>'");
    uint64_t c = 0;
    const std::string p = line("print 2+3", ">", &c);
    printf("PRINT 2+3 -> %zu chars, %llu clocks from CR to '>'\n", p.size(), (unsigned long long)c);
    check(p == "\r\n5\r\n\r\n>", "PRINT 2+3 prints 5");

    // 4. FOR を 1000 回
    line("10 FOR I=1 TO 1000", ">");
    line("20 NEXT I", ">");
    line("30 END", ">");
    uint64_t loop = 0;
    const long i0 = instructions;
    const std::string run = line("RUN", ">", &loop);
    printf("RUN (FOR 1..1000): %llu clocks = %.2f ms at 27 MHz, %ld instructions\n",
           (unsigned long long)loop, loop / 27e3, instructions - i0);
    check(run == "\r\n\r\n>", "the loop ends and returns to '>'");
    line("10 FOR I=1 TO 2000", ">");
    uint64_t loop2 = 0;
    line("RUN", ">", &loop2);
    printf("RUN (FOR 1..2000): %llu clocks, per pass %.1f clocks\n", (unsigned long long)loop2,
           (double)(loop2 - loop) / 1000.0);
    // 測り始め (CR のストップビットの終わり) と UART の受けの刻みの位相で、1 ビット (234 クロック) ほど揺れる
    const long d = (long)(loop2 - loop) - 1260000;
    check(d > -300 && d < 300, "one pass of FOR/NEXT is 1260 clocks (the same as 11-8)");

    printf("KBD reads %ld, DSP writes %ld, total %llu clocks\n", kbd_reads, dsp_writes,
           (unsigned long long)cycle);
    if (errors == 0) printf("PASS\n");
    else             printf("FAIL: %d\n", errors);
    dut->final();
    delete dut;
    return errors == 0 ? 0 : 1;
}
