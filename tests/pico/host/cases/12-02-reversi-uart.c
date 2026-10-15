// program: 06-fpga/12-projects/02-reversi-uart-1.c
// 12-2: UART0 を 115200 8N1 で GP0・GP1 に出し、リバーシ UART プロトコルの行に答える。
// 本文の主ループを SOFT_FPGA なし (C の計算) で動かす。回路の版の答えは 12-2 の PC の試験と picoemu で見る。
#include <string.h>
#include "pico/stdlib.h"
#include "hardware/uart.h"

static void feed(const char *s) { while (*s) M.uart_rx[M.nrx++] = (uint8_t)*s++; }

int main(void) {
    mock_reset(0);
    feed("PI\r\nVE\r\nSB\r\nMOe3\r\nXB\r\npi\r\nPI\nMOz9\r\nMOa1\r\nEB\r\nPA\r\n\r\nZZ\r\n");
    mock_run(1000000);
    mock_check(M.uart_baud[0] == 115200, "115200 baud");
    mock_check(M.uart_bits[0] == 8 && M.uart_stop[0] == 1 && M.uart_parity[0] == UART_PARITY_NONE, "8N1");
    mock_check(M.func[0] == GPIO_FUNC_UART && M.func[1] == GPIO_FUNC_UART, "GP0・GP1 を UART にする");
    const char *want =
        "RE\r\n+PI\r\n+VE02wb-reversi-12-2\r\nMOd3\r\nMOf3\r\n+XB moves=2 clocks=11 us=0\r\n"
        "-02 lowercase\r\n-03 need CR LF\r\n-04 bad coord\r\n-05 illegal move\r\n-06 not my game\r\n-01 unknown\r\n";
    size_t n = strlen(want);
    mock_check(M.ntx == n, "送った字の数 %u (期待 %u)", M.ntx, (unsigned)n);
    mock_check(M.ntx >= n && memcmp(M.uart_tx, want, n) == 0, "送った行が期待どおり");
    if (M.ntx >= n && memcmp(M.uart_tx, want, n) != 0) fprintf(stderr, "%.*s\n", (int)M.ntx, (const char *)M.uart_tx);
    return mock_report();
}
