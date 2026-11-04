// program: 01-circuits/11-microcontrollers/07-uart-two-picos-1.c
// 11-7: UART0 を 9600 bps・8N1 (GP0=TX・GP1=RX)。1 s ごとに "0\n" "1\n" … を送り、受けた字を USB シリアルへ写す。
#include "pico/stdlib.h"
#include "hardware/uart.h"
#include <string.h>
int main(void) {
    mock_reset(0);
    M.uart_rx[0] = '7'; M.uart_rx[1] = '\n'; M.nrx = 2;    /* 相手から届いた 1 行 */
    mock_run(2500000);
    mock_check(M.uart_baud[0] == 9600, "9600 bps: %u", M.uart_baud[0]);
    mock_check(M.uart_bits[0] == 8 && M.uart_stop[0] == 1 && M.uart_parity[0] == UART_PARITY_NONE, "8N1");
    mock_check(M.func[0] == GPIO_FUNC_UART && M.func[1] == GPIO_FUNC_UART, "GP0・GP1 を UART に");
    mock_check(M.ntx == 6 && memcmp(M.uart_tx, "0\n1\n2\n", 6) == 0, "0・1・2 を送る: n=%u", M.ntx);
    for (uint i = 0; i < M.ntx; i++) mock_check(M.uart_tx_n[i] == 0, "UART0 から");
    mock_check(M.uart_tx_t[2] - M.uart_tx_t[0] == 1000000 && M.uart_tx_t[4] - M.uart_tx_t[2] == 1000000, "1 s ごと");
    mock_check(strcmp(M.out, "7\n") == 0, "受けた字を写す: [%s]", M.out);
    return mock_report();
}
