// program: 01-circuits/11-microcontrollers/05-i2c-temperature-1.c
// 11-5: I2C0 を 100 kHz、GP0=SDA・GP1=SCL。MCP9808 (0x18) の 0x05 を 1 s ごとに読む。
#include "pico/stdlib.h"
#include "hardware/i2c.h"
#include <string.h>
int main(void) {
    mock_reset(0);
    M.i2c_reply[0] = 0x01; M.i2c_reply[1] = 0x90; M.n_i2c_reply = 2;   /* 0x0190 = 25.0 ℃ */
    mock_run(2500000);
    mock_check(M.i2c_baud[0] == 100000, "100 kHz: %u", M.i2c_baud[0]);
    mock_check(M.func[0] == GPIO_FUNC_I2C && M.func[1] == GPIO_FUNC_I2C, "GP0・GP1 を I2C にする");
    mock_check(M.i2c_writes == 3 && M.i2c_reads == 3, "1 s ごと (2.5 s で 3 回): w=%u r=%u", M.i2c_writes, M.i2c_reads);
    mock_check(strncmp(M.out, "25.0000 C\n", 10) == 0, "25 ℃ と読む: [%s]", M.out);
    M.i2c_reply[0] = 0x11; M.i2c_reply[1] = 0x90;       /* 負の値: 0x1190 = 1.0 - 256 + ... */
    return mock_report();
}
