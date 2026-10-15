// program: 02-analog-discovery/07-logic/06-uart-echo-1.c
// 7-6: 受けた 1 バイトに 1 を足して返す。0xFF は 0x00 に戻る。
#include "pico/stdlib.h"
#include "hardware/uart.h"
int main(void) {
    mock_reset(0);
    const uint8_t in[] = {0x00, 0x41, 0x7F, 0xFE, 0xFF};
    for (uint i = 0; i < sizeof in; i++) M.uart_rx[M.nrx++] = in[i];
    mock_run(1000000);
    mock_check(M.uart_baud[0] == 115200, "115200 baud");
    mock_check(M.ntx == 5, "5 バイト返す: %u", M.ntx);
    const uint8_t out[] = {0x01, 0x42, 0x80, 0xFF, 0x00};
    for (uint i = 0; i < M.ntx && i < 5; i++) mock_check(M.uart_tx[i] == out[i], "%u 番目: %02x", i, M.uart_tx[i]);
    return mock_report();
}
