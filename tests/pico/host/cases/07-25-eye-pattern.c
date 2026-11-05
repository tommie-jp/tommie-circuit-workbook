// program: 02-analog-discovery/07-logic/25-eye-pattern-1.c
// 7-25 (Analog Discovery): UART0 (TX = GP16) を 1 Mbit/s・8N1 にし、PRBS7 の 127 バイトを送っては 2 ms 休む。
#include "pico/stdlib.h"
#include "hardware/uart.h"
static int bit_at(uint i) { return (M.uart_tx[i / 8] >> (i % 8)) & 1; }   /* LSB から送る順 */
int main(void) {
    mock_reset(0);
    mock_run(5000);
    mock_check(M.uart_baud[0] == 1000000, "1 Mbit/s: %u", M.uart_baud[0]);
    mock_check(M.uart_bits[0] == 8 && M.uart_stop[0] == 1 && M.uart_parity[0] == UART_PARITY_NONE, "8N1");
    mock_check(M.func[16] == GPIO_FUNC_UART, "GP16 を UART にする");
    mock_check(M.ntx >= 254 && M.uart_tx_n[0] == 0, "UART0 から 2 束以上 (%u バイト)", M.ntx);
    mock_check(M.uart_tx_t[127] >= 2000, "127 バイトごとに 2 ms 休む: %llu µs", (unsigned long long)M.uart_tx_t[127]);
    int same = 1, ones = 0;
    for (uint i = 0; i + 127 < 127 * 8; i++) if (bit_at(i) != bit_at(i + 127)) same = 0;
    for (uint i = 0; i < 127; i++) ones += bit_at(i);
    mock_check(same, "127 ビットの周期で繰り返す");
    mock_check(ones == 64, "1 周期に 1 が 64 個: %d", ones);
    unsigned char seen[128] = {0}; int distinct = 0;
    for (uint i = 0; i < 127; i++) {
        uint w = 0;
        for (uint k = 0; k < 7; k++) w = (w << 1) | (uint)bit_at(i + k);
        if (!seen[w]) { seen[w] = 1; distinct++; }
    }
    mock_check(distinct == 127 && !seen[0], "7 ビットの窓が 127 通りで全部違い、0000000 が無い: %d", distinct);
    for (uint i = 0; i < 127; i++) mock_check(M.uart_tx[i] == M.uart_tx[127 + i], "2 束めも同じ (%u)", i);
    return mock_report();
}
