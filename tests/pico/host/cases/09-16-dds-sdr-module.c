// program: 01-circuits/09-rf/16-dds-sdr-module-1.c
// 9-16: AD9833 に 7 MHz を設定する。FREQ0 の語と、実際に出る周波数 (7000000.03 Hz) を確かめる。
#include "pico/stdlib.h"
#include "hardware/spi.h"
#include <string.h>
int main(void) {
    mock_reset(0);
    mock_run(1500000);
    mock_check(M.spi_baud == 1000000 && M.spi_bits == 16, "SPI 1 MHz・16 bit");
    mock_check(M.spi_cpol == 1 && M.spi_cpha == 0, "CPOL=1 CPHA=0 (AD9833 は SCLK が H で待つ)");
    mock_check(M.func[2] == GPIO_FUNC_SPI && M.func[3] == GPIO_FUNC_SPI, "GP2 SCK・GP3 MOSI を SPI にする");
    mock_check(M.nspi == 5, "16 bit 語は 5 つ: %u", M.nspi);
    /* 7 MHz × 2^28 / 25 MHz = 75161927.68 → 75161928 = 0x047AE148 */
    uint32_t freq = 75161928u;
    mock_check(M.spi_tx[0] == 0x2100, "B28=1・RESET=1");
    mock_check(M.spi_tx[1] == (0x4000 | (freq & 0x3FFF)), "FREQ0 下位 14 bit: %04x", M.spi_tx[1]);
    mock_check(M.spi_tx[2] == (0x4000 | ((freq >> 14) & 0x3FFF)), "FREQ0 上位 14 bit: %04x", M.spi_tx[2]);
    mock_check(M.spi_tx[3] == 0xC000 && M.spi_tx[4] == 0x2000, "PHASE0 と RESET 解除");
    mock_check(strncmp(M.out, "7000000.03\n", 11) == 0, "実際の周波数: [%s]", M.out);
    mock_check(M.dir_out[5] && M.level[5], "FSYNC (GP5) は最後に H");
    return mock_report();
}
