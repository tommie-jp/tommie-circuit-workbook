// program: 01-circuits/09-rf/24-iq-mw-radio-1.c
// 9-24: 594 kHz に合わせる。LO は PIO の 4 状態 (set pins 0→1→3→2)、f_LO = sys / (4 × M)。
#include "pico/stdlib.h"
#include "hardware/pio.h"
#include "hardware/pwm.h"
#include "hardware/dma.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>
static void deliver(void) {
    static uint k = 0;
    if (M.dma_pending_mask) return;
    memset(M.dma[k].write, 0, 2000 * 2);
    mock_advance_us(2000);
    mock_dma_deliver(k);
    k ^= 1;
}
int main(void) {
    mock_reset(0);
    M.idle_hook = deliver;
    M.in_value[10] = M.in_value[11] = true;
    mock_run(200000);
    mock_check(M.pio_prog_len == 4 && M.pio_prog[0] == 0xe000 && M.pio_prog[1] == 0xe001 && M.pio_prog[2] == 0xe003 && M.pio_prog[3] == 0xe002,
               "LO の 4 命令: set pins 0,1,3,2");
    mock_check(M.pio_set_base == 2 && M.pio_set_count == 2, "set pins は GP2 から 2 本 (S0・S1)");
    mock_check(M.pio_pindirs_base == 2 && M.pio_pindirs_count == 2 && M.pio_pindirs_out, "GP2・GP3 を出力方向");
    mock_check(M.pio_wrap_target == 0 && M.pio_wrap == 3, "4 命令で wrap");
    mock_check(M.pio_sm_enabled, "状態機械を有効にする");
    mock_check(M.func[15] == GPIO_FUNC_PWM, "GP15 を PWM (音声)");
    mock_check(M.sys_pll_calls >= 1, "sys クロックを PLL で設定する");
    /* tune(594000): LO は局から 1 kHz 以上離し、sys が 100〜150 MHz、M は整数 */
    double sys = 12e6 * (M.sys_pll_vco / 12000000u) / (M.sys_pll_pd1 * M.sys_pll_pd2) / 12e6 * 12e6;
    sys = (double)M.sys_pll_vco / (M.sys_pll_pd1 * M.sys_pll_pd2);
    mock_check(sys >= 100e6 && sys <= 150e6, "sys %.3f MHz は 100〜150 MHz", sys / 1e6);
    double lo = sys / (4.0 * M.pio_clkdiv);
    mock_check(M.pio_clkdiv == (float)(uint)M.pio_clkdiv, "PIO の分周は整数: %g", M.pio_clkdiv);
    mock_check(fabs(lo - 594000.0) >= 1000.0 && fabs(lo - 594000.0) < 1500.0, "LO %.3f kHz は局の 1 kHz 上か下", lo / 1e3);
    mock_check(strncmp(M.out, "594 kHz  sys ", 13) == 0, "表示は 594 kHz から: [%.40s]", M.out);
    return mock_report();
}
