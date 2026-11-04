// program: 01-circuits/11-microcontrollers/06-spi-shift-register-1.c
// 11-6: SPI0 を 1 MHz・8 bit・モード 0・MSB 先。0〜9 の表を 1 バイトずつ送り、GP7 (RCLK) を 1 回上げる。0.5 s ごと。
#include "pico/stdlib.h"
#include "hardware/spi.h"
static const uint16_t WANT[10] = {0x7D, 0x30, 0x5B, 0x7A, 0x36, 0x6E, 0x6F, 0x38, 0x7F, 0x7E};
int main(void) {
    mock_reset(0);
    mock_run(5600000);   /* 5.6 s → 12 回 */
    mock_check(M.spi_baud == 1000000, "1 MHz: %u", M.spi_baud);
    mock_check(M.spi_bits == 8 && M.spi_cpol == 0 && M.spi_cpha == 0 && M.spi_order == 1, "8 bit・モード 0・MSB 先");
    mock_check(M.func[3] == GPIO_FUNC_SPI && M.func[6] == GPIO_FUNC_SPI, "GP3・GP6 を SPI に");
    mock_check(M.nspi == 12, "12 バイト: %u", M.nspi);
    for (uint i = 0; i < M.nspi; i++) mock_check(M.spi_tx[i] == WANT[i % 10], "%u 個目 0x%02X", i, M.spi_tx[i]);
    uint64_t rise[16]; uint nr = 0;
    for (uint i = 0; i < M.nev; i++) if (M.ev[i].pin == 7 && M.ev[i].level && nr < 16) rise[nr++] = M.ev[i].t_us;
    mock_check(nr == 12, "ラッチ 12 回: %u", nr);
    for (uint i = 1; i < nr; i++) { int64_t d = (int64_t)(rise[i] - rise[i - 1]); mock_check(d >= 500000 && d <= 500010, "間隔 0.5 s: %lld", (long long)d); }
    return mock_report();
}
