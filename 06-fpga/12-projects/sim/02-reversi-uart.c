// 12-2 リバーシを UART で PC と対戦させる — Pico 2 の主ループ
// PC とは stdio で話す。stdio は USB (CDC) と UART0 (GP0 が TX、GP1 が RX、115200 bps 8N1) の両方に出し、両方から受ける。
// Debug Probe が無ければ USB だけ、あれば Probe の UART でも同じに話せる。リバーシ UART プロトコル v0.2 の一部を話す。
// AD3 で見るために、受けた行の写しを UART1 (GP4) に出し、行を受け終えてから答えを送り始めるまで GP2 を H にする。
// 内部の状態を GP16〜GP18 に出し、LED で見せる (対局中・自分が白・直前の行に誤りを返した)。AD3 でも読む。
// 盤面の計算 (合法手・裏返す石・最善手) は accel_* の 3 つの関数に任せる。
// SOFT_FPGA を定義したビルドでは accel.cpp が 12-1 の回路 (Verilator の C++) で答え、
// 定義しないビルドでは下の C の関数が同じ答えを出す (比べるためと、PC の試験のため)。
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "pico/stdlib.h"
#include "hardware/uart.h"

#define BAUD      115200
#define PIN_RX0   1                     // UART0 の RX (stdio が使う)。Probe をつながないときに浮かせない
#define COPY_UART uart1
#define PIN_COPY  4                     // UART1 の TX: 受けた行の写し (AD3 用)
#define PIN_BUSY  2                     // 行を受け終えてから答えを送り始めるまで H (AD3 用)
#define PIN_GAME  16                    // 対局中 (緑の LED)
#define PIN_WHITE 17                    // 対局中で、自分が白 (黄の LED)
#define PIN_ERR   18                    // 直前の行に誤り (-0x) を返した (赤の LED)
#define LINE_MAX  80                    // 受ける 1 行の最大 (CR LF を除く)

uint64_t accel_legal(uint64_t own, uint64_t opp);
uint64_t accel_flip(uint64_t own, uint64_t opp, unsigned move);
int      accel_pick(uint64_t own, uint64_t opp, unsigned *clocks);

#ifndef SOFT_FPGA
// ---- 回路を使わないビルドの代わり: 12-1 と同じ答えを C で出す ----
static const int DR[8] = {-1, -1, -1, 0, 0, 1, 1, 1};
static const int DC[8] = {-1, 0, 1, -1, 1, -1, 0, 1};

uint64_t accel_flip(uint64_t own, uint64_t opp, unsigned move) {
    if (((own | opp) >> move) & 1u) return 0;
    uint64_t all = 0;
    for (int d = 0; d < 8; d++) {
        uint64_t line = 0;
        int r = (int)move / 8 + DR[d], c = (int)move % 8 + DC[d];
        while (r >= 0 && r < 8 && c >= 0 && c < 8 && ((opp >> (r * 8 + c)) & 1u)) {
            line |= 1ull << (r * 8 + c);
            r += DR[d]; c += DC[d];
        }
        if (line && r >= 0 && r < 8 && c >= 0 && c < 8 && ((own >> (r * 8 + c)) & 1u)) all |= line;
    }
    return all;
}

uint64_t accel_legal(uint64_t own, uint64_t opp) {
    uint64_t l = 0;
    for (unsigned i = 0; i < 64; i++)
        if (accel_flip(own, opp, i)) l |= 1ull << i;
    return l;
}

int accel_pick(uint64_t own, uint64_t opp, unsigned *clocks) {   // 角を先に、次に裏返る数の多い手
    int best = -1, best_score = -1;
    unsigned n = 0;
    for (unsigned i = 0; i < 64; i++) {
        uint64_t f = accel_flip(own, opp, i);
        if (!f) continue;
        n++;
        int score = __builtin_popcountll(f) + ((i == 0 || i == 7 || i == 56 || i == 63) ? 32 : 0);
        if (score > best_score) { best_score = score; best = (int)i; }
    }
    *clocks = n + 1;                    // 回路なら合法手の数 + 1 クロック (12-1)
    return best;
}
#endif

// ---- 対局の状態 ----
enum { IDLE, WAIT_OPP };
static int      state = IDLE;
static uint64_t black, white;
static int      me;                     // 0 = 黒、1 = 白
static unsigned moves;                  // 自分が考えた回数
static unsigned long total_clocks;      // 回路が探すのに使ったクロックの合計
static uint64_t total_us;               // 考えるのに使った時間の合計
static bool     last_err;               // この行に誤りを返したか

static void send(const char *s) {       // 1 行送る。行の終わりは CR LF
    char buf[LINE_MAX + 3];
    int n = snprintf(buf, sizeof buf, "%s\r\n", s);
    gpio_put(PIN_BUSY, 0);              // 答えを送り始める
    last_err = (s[0] == '-');
    stdio_put_string(buf, n, false, false);  // 改行の変換をしない (CR LF をそのまま送る)
}

static void show_state(void) {          // 状態を LED に出す
    gpio_put(PIN_GAME, state == WAIT_OPP);
    gpio_put(PIN_WHITE, state == WAIT_OPP && me == 1);
    gpio_put(PIN_ERR, last_err);
}

static void copy_line(const char *line, unsigned len, bool had_cr) {  // 受けた行を UART1 に写す
    for (unsigned i = 0; i < len; i++) uart_putc_raw(COPY_UART, line[i]);
    if (had_cr) uart_putc_raw(COPY_UART, '\r');
    uart_putc_raw(COPY_UART, '\n');
}

static void new_game(int side) {
    black = (1ull << 28) | (1ull << 35);    // e4 d5
    white = (1ull << 27) | (1ull << 36);    // d4 e5
    me = side;
}

static void put_stone(uint64_t *own, uint64_t *opp, unsigned m, uint64_t f) {
    *own |= f | (1ull << m);
    *opp &= ~f;
}

static void think_and_move(void) {
    uint64_t *mine = me ? &white : &black, *theirs = me ? &black : &white;
    unsigned clocks = 0;
    uint64_t t0 = time_us_64();
    int m = accel_pick(*mine, *theirs, &clocks);
    if (m >= 0) put_stone(mine, theirs, (unsigned)m, accel_flip(*mine, *theirs, (unsigned)m));
    total_us += time_us_64() - t0;
    total_clocks += clocks;
    moves++;
    if (m < 0) {
        send("PA");                     // 打てる所が無い
    } else {
        char s[5] = {'M', 'O', (char)('a' + m % 8), (char)('1' + m / 8), 0};
        send(s);
    }
    state = WAIT_OPP;
}

static void opponent_move(const char *line, unsigned len) {
    if (len != 4 || line[2] < 'a' || line[2] > 'h' || line[3] < '1' || line[3] > '8') { send("-04 bad coord"); return; }
    unsigned m = (unsigned)(line[3] - '1') * 8u + (unsigned)(line[2] - 'a');
    uint64_t *mine = me ? &white : &black, *theirs = me ? &black : &white;
    uint64_t f = accel_flip(*theirs, *mine, m);
    if (!f) { send("-05 illegal move"); return; }
    put_stone(theirs, mine, m, f);
    think_and_move();
}

static void handle_line(const char *line, unsigned len, bool had_cr) {
    if (!had_cr) { send("-03 need CR LF"); return; }
    if (len == 0) return;                                   // 空行は黙って捨てる
    if (len < 2) { send("-01 unknown"); return; }
    if (line[0] >= 'a' && line[0] <= 'z') { send("-02 lowercase"); return; }
    char c0 = line[0], c1 = line[1];
    if      (c0 == 'P' && c1 == 'I') send("+PI");
    else if (c0 == 'V' && c1 == 'E') send("+VE02wb-reversi-12-2");
    else if (c0 == 'C' && c1 == 'A') send("+CA PI VE CA SB SW MO PA EB EW ED XB");
    else if (c0 == 'X' && c1 == 'B') {
        char s[64];
        snprintf(s, sizeof s, "+XB moves=%u clocks=%lu us=%lu", moves, total_clocks, (unsigned long)total_us);
        send(s);
    }
    else if (c0 == 'S' && (c1 == 'B' || c1 == 'W')) {
        new_game(c1 == 'W');
        if (c1 == 'B') think_and_move();                     // 黒が先に打つ
        else           state = WAIT_OPP;
    }
    else if (c0 == 'M' && c1 == 'O') { if (state == WAIT_OPP) opponent_move(line, len); else send("-06 not my game"); }
    else if (c0 == 'P' && c1 == 'A') { if (state == WAIT_OPP) think_and_move();         else send("-06 not my game"); }
    else if (c0 == 'E' && (c1 == 'B' || c1 == 'W' || c1 == 'D')) state = IDLE;
    else if (c0 == 'X') { }                                   // ほかの拡張は黙って捨てる
    else send("-01 unknown");
}

int main(void) {
    stdio_init_all();                                         // USB と UART0 (GP0・GP1、115200 8N1)
    gpio_pull_up(PIN_RX0);
    uart_init(COPY_UART, BAUD);
    uart_set_format(COPY_UART, 8, 1, UART_PARITY_NONE);
    gpio_set_function(PIN_COPY, GPIO_FUNC_UART);
    static const uint OUT_PINS[] = {PIN_BUSY, PIN_GAME, PIN_WHITE, PIN_ERR};
    for (unsigned i = 0; i < sizeof OUT_PINS / sizeof OUT_PINS[0]; i++) {
        gpio_init(OUT_PINS[i]);
        gpio_set_dir(OUT_PINS[i], GPIO_OUT);
    }
    send("RE");                                               // 起きたことを知らせる

    char line[LINE_MAX];
    unsigned len = 0;
    bool cr = false, too_long = false;
    while (true) {
        int c = getchar_timeout_us(1000000);                  // USB か UART0 から 1 字
        if (c == PICO_ERROR_TIMEOUT) continue;
        if (c == '\n') {                                     // 行の終わり
            gpio_put(PIN_BUSY, 1);
            last_err = false;
            copy_line(line, len, cr);
            if (too_long) send("-00 too long");
            else          handle_line(line, len, cr);
            gpio_put(PIN_BUSY, 0);                            // 答えない行 (SW・EB など) もここで L
            show_state();
            len = 0; cr = false; too_long = false;
        } else if (c == '\r') {
            cr = true;
        } else {
            if (len < LINE_MAX) line[len++] = (char)c;
            else                too_long = true;
            cr = false;
        }
    }
}
