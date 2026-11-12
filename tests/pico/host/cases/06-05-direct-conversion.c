// program: 05-etc/06-ham-receiver/05-direct-conversion-1.c
// 6-5: Si5351A (0x60) を I2C0 (GP4=SDA・GP5=SCL、100 kHz) で設定し、CLK0 に 7.0100 MHz を出す。
// 期待値は「出る周波数」: 書いたレジスタ (PLL A 26〜33、CLK0 の分周 42〜49) から a + b/c を逆算して Hz に直す。
#include "pico/stdlib.h"
#include "hardware/i2c.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>

static uint8_t reg[256];
static uint resets;

/* I2C に書いた中身をレジスタの表に写す (先頭のバイトが番地、あとは続きの番地へ) */
static void replay(void) {
    memset(reg, 0, sizeof reg); resets = 0;
    for (uint i = 0; i < M.n_i2c_w; i++) {
        if (M.i2c_w[i].addr != 0x60) continue;
        for (uint k = 1; k < M.i2c_w[i].n; k++) reg[(uint8_t)(M.i2c_w[i].d[0] + k - 1)] = M.i2c_w[i].d[k];
        if (M.i2c_w[i].d[0] == 177) resets++;
    }
}
/* 8 バイトの並びから分周比 a + b/c */
static double ratio(uint base) {
    uint32_t p3 = ((uint32_t)(reg[base + 5] >> 4) << 16) | ((uint32_t)reg[base] << 8) | reg[base + 1];
    uint32_t p1 = ((uint32_t)(reg[base + 2] & 3) << 16) | ((uint32_t)reg[base + 3] << 8) | reg[base + 4];
    uint32_t p2 = ((uint32_t)(reg[base + 5] & 15) << 16) | ((uint32_t)reg[base + 6] << 8) | reg[base + 7];
    return (p1 + 512 + (double)p2 / p3) / 128.0;
}
static double fout(void) { replay(); return 25e6 * ratio(26) / ratio(42); }
static double last_line(void) {             /* シリアルの最後の行 */
    int n = (int)M.nout - 1;
    while (n > 0 && M.out[n - 1] != '\n') n--;
    return atof(M.out + n);
}
static int lines(void) { int c = 0; for (uint i = 0; i < M.nout; i++) c += M.out[i] == '\n'; return c; }

int main(void) {
    /* 1. 何も押さない: 7.0100 MHz */
    mock_reset(0);
    mock_run(350000);
    mock_check(M.i2c_baud[0] == 100000, "100 kHz: %u", M.i2c_baud[0]);
    mock_check(M.func[4] == GPIO_FUNC_I2C && M.func[5] == GPIO_FUNC_I2C, "GP4・GP5 を I2C にする");
    mock_check(!M.dir_out[14] && !M.dir_out[15] && M.pull_up[14] && M.pull_up[15], "GP14・GP15 は入力で内蔵プルアップ");
    mock_check(fabs(fout() - 7010000.0) < 0.05, "起動のとき 7.0100 MHz: %.3f", fout());
    mock_check(fabs(ratio(42) - 120.0) < 1e-9, "CLK0 の分周は 120: %.6f", ratio(42));
    mock_check(reg[3] == 0xFE, "CLK0 だけ出す: 0x%02X", reg[3]);
    mock_check((reg[16] & 0x80) == 0 && (reg[17] & 0x80) && (reg[18] & 0x80), "CLK0 は動かし CLK1・CLK2 は切る");
    mock_check(resets == 1, "PLL のリセットは 1 回: %u", resets);
    mock_check(strncmp(M.out, "7010000.0\n", 10) == 0 && lines() == 1, "表示は 7010000.0 の 1 行: [%s]", M.out);

    /* 2. SW1 (UP、GP14) を押し続ける: 100 Hz を 10 回、そのあと 1 kHz */
    mock_reset(0);
    M.in_value[14] = false;
    mock_run(1250000);                       /* 0, 0.1, ... 1.2 s の 13 回 */
    mock_check(lines() == 14, "0.1 秒ごとに 1 行: %d", lines());
    mock_check(fabs(last_line() - (7010000.0 + 10 * 100 + 3 * 1000)) < 0.05, "100 Hz x 10 + 1 kHz x 3: %.1f", last_line());
    mock_check(fabs(fout() - last_line()) < 0.05, "レジスタの周波数が表示と同じ: %.3f", fout());
    mock_check(strncmp(M.out, "7010000.0\n7010100.0\n7010200.0\n", 30) == 0, "最初の刻みは 100 Hz: [%.30s]", M.out);
    mock_check(resets == 1, "周波数を動かしても PLL をリセットしない: %u", resets);

    /* 3. SW2 (DOWN、GP15) を押し続ける: 7.000 MHz で止まる */
    mock_reset(0);
    M.in_value[15] = false;
    mock_run(3050000);
    mock_check(fabs(last_line() - 7000000.0) < 0.05 && fabs(fout() - 7000000.0) < 0.05, "下の端 7.000 MHz: %.1f", last_line());

    /* 4. シリアルの u・d: 10 kHz ずつ */
    mock_reset(0);
    memcpy(M.in, "uud", 3); M.nin = 3;
    mock_run(2000000);
    mock_check(strncmp(M.out, "7010000.0\n7020000.0\n7030000.0\n7020000.0\n", 40) == 0, "u u d: [%s]", M.out);
    mock_check(fabs(fout() - 7020000.0) < 0.05, "レジスタも 7.0200 MHz: %.3f", fout());
    return mock_report();
}
