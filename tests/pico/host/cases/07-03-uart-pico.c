// program: 02-analog-discovery/07-logic/03-uart-pico-1.c
// 7-3: UART0 を 115200 8N1 で GP0 から出し、'U' (0x55) を 1 s ごとに送る。
#include "pico/stdlib.h"
#include "hardware/uart.h"
int main(void) {
    mock_reset(0);
    mock_run(3500000);
    mock_check(M.uart_baud[0] == 115200, "115200 baud");
    mock_check(M.uart_bits[0] == 8 && M.uart_stop[0] == 1 && M.uart_parity[0] == UART_PARITY_NONE, "8N1");
    mock_check(M.func[0] == GPIO_FUNC_UART && M.func[1] == GPIO_FUNC_UART, "GP0・GP1 を UART にする");
    mock_check(M.ntx == 4, "3.5 s で 4 文字: %u", M.ntx);
    for (uint i = 0; i < M.ntx; i++) {
        mock_check(M.uart_tx[i] == 0x55, "送る文字は 0x55");
        mock_check(M.uart_tx_t[i] == (uint64_t)i * 1000000, "1 s 間隔");
    }
    return mock_report();
}
