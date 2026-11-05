// program: 02-analog-discovery/07-logic/18-boot-log-record-1.c
// 7-18: UART0 を 115200 8N1 で GP0 から出し、boot → 0.5 s → ready → 1 s ごとに t=n を送る。
#include <string.h>
#include "pico/stdlib.h"
#include "hardware/uart.h"

static int find(const char *s, uint64_t *t) {
    uint n = (uint)strlen(s);
    for (uint i = 0; i + n <= M.ntx; i++) {
        if (memcmp(&M.uart_tx[i], s, n) == 0) { *t = M.uart_tx_t[i]; return 1; }
    }
    return 0;
}

int main(void) {
    mock_reset(0);
    mock_run(2700000);
    mock_check(M.uart_baud[0] == 115200, "115200 baud");
    mock_check(M.uart_bits[0] == 8 && M.uart_stop[0] == 1 && M.uart_parity[0] == UART_PARITY_NONE, "8N1");
    mock_check(M.func[0] == GPIO_FUNC_UART && M.func[1] == GPIO_FUNC_UART, "GP0・GP1 を UART にする");
    const char *lines[] = {"boot\r\n", "ready\r\n", "t=0\r\n", "t=1\r\n", "t=2\r\n"};
    const uint64_t when[] = {0, 500000, 500000, 1500000, 2500000};
    for (int k = 0; k < 5; k++) {
        uint64_t t = 0;
        int ok = find(lines[k], &t);
        mock_check(ok, "行 %d を送る", k);
        mock_check(ok && t == when[k], "行 %d の時刻 %llu us", k, (unsigned long long)t);
    }
    uint64_t t3;
    mock_check(!find("t=3\r\n", &t3), "2.7 s では t=3 はまだ");
    return mock_report();
}
