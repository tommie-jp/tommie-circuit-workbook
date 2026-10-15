// program: 06-fpga/12-projects/02-reversi-uart-1.c
// 12-2: PC とは stdio (USB と UART0) で話し、リバーシ UART プロトコルの行に答える。
// 受けた行の写しを UART1 (GP4、115200 8N1) に出し、行を受け終えてから答えを送り始めるまで GP2 を H にする。
// 状態を GP16 (対局中)・GP17 (自分が白)・GP18 (直前の行に誤りを返した) に出す。
// 本文の主ループを SOFT_FPGA なし (C の計算) で動かす。回路の版の答えは 12-2 の PC の試験と picoemu で見る。
#include <string.h>
#include "pico/stdlib.h"
#include "hardware/uart.h"

#define IN "PI\r\nVE\r\nSB\r\nMOe3\r\nXB\r\npi\r\nPI\nMOz9\r\nMOa1\r\nEB\r\nPA\r\n\r\nZZ\r\nSW\r\nEW\r\n"
#define NLINES 15

int main(void) {
    mock_reset(0);
    strcpy(M.in, IN);
    M.nin = (uint)strlen(IN);
    mock_run(1000000);

    const char *want =
        "RE\r\n+PI\r\n+VE02wb-reversi-12-2\r\nMOd3\r\nMOf3\r\n+XB moves=2 clocks=11 us=0\r\n"
        "-02 lowercase\r\n-03 need CR LF\r\n-04 bad coord\r\n-05 illegal move\r\n-06 not my game\r\n-01 unknown\r\n";
    size_t n = strlen(want);
    mock_check(M.nout == n && memcmp(M.out, want, n) == 0, "stdio に返した行が期待どおり (CR LF のまま)");
    if (M.nout != n || memcmp(M.out, want, n) != 0) fprintf(stderr, "%.*s\n", (int)M.nout, M.out);

    // 写し: UART1 に、受けた字がそのまま (CR の有無も) 出る。UART0 には直に書かない (stdio が出す)
    mock_check(M.uart_baud[1] == 115200, "UART1 は 115200 baud");
    mock_check(M.uart_bits[1] == 8 && M.uart_stop[1] == 1 && M.uart_parity[1] == UART_PARITY_NONE, "UART1 は 8N1");
    mock_check(M.func[4] == GPIO_FUNC_UART, "GP4 を UART (UART1 の TX) にする");
    uint n1 = 0, n0 = 0;
    char copy[1024];
    for (uint i = 0; i < M.ntx; i++) {
        if (M.uart_tx_n[i] == 1) copy[n1++] = (char)M.uart_tx[i];
        else n0++;
    }
    mock_check(n1 == strlen(IN) && memcmp(copy, IN, n1) == 0, "UART1 の写しが受けた字と同じ (%u 字)", n1);
    mock_check(n0 == 0, "UART0 に直に書かない");
    mock_check(M.pull_up[1], "GP1 (UART0 の RX) をプルアップする");

    // 印: GP2 は行ごとに 1 回 H になり、最後は L
    mock_check(M.dir_out[2], "GP2 を出力にする");
    uint rise = 0;
    for (uint i = 0; i < M.nev; i++) if (M.ev[i].pin == 2 && M.ev[i].level) rise++;
    mock_check(rise == NLINES, "GP2 が H になった回数 %u (期待 %u)", rise, NLINES);
    mock_check(!M.level[2], "GP2 は最後に L");

    // 状態の LED: 行ごとの変わり目の並び (ピン・値)
    const struct { uint pin; bool v; } want_ev[] = {
        {16, 1},            // SB: 対局中
        {18, 1},            // pi: -02 (CR の無い PI・MOz9・MOa1 の誤りの間は 1 のまま)
        {16, 0}, {18, 0},   // EB: 対局が終わる。誤りでない行 (同じ行の中は GP16・GP17・GP18 の順に書く)
        {18, 1},            // PA: -06
        {18, 0},            // 空の行: 答えないが誤りでもない
        {18, 1},            // ZZ: -01
        {16, 1}, {17, 1}, {18, 0},   // SW: 自分が白で対局中
        {16, 0}, {17, 0},   // EW: 対局が終わる
    };
    const uint nw = sizeof want_ev / sizeof want_ev[0];
    uint k = 0;
    bool same = true;
    for (uint i = 0; i < M.nev; i++) {
        uint pin = M.ev[i].pin;
        if (pin < 16 || pin > 18) continue;
        if (k >= nw || want_ev[k].pin != pin || want_ev[k].v != M.ev[i].level) same = false;
        k++;
    }
    mock_check(same && k == nw, "GP16〜GP18 の変わり目の並びが期待どおり (%u 回、期待 %u 回)", k, nw);
    mock_check(M.dir_out[16] && M.dir_out[17] && M.dir_out[18], "GP16〜GP18 を出力にする");
    return mock_report();
}
