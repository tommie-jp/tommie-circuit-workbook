// program: 05-etc/05-ethernet-10base-t/02-tx-link-pulse-1.c
// 5-2: PIO で 10BASE-T を送る。120 MHz・分周 6、リンクパルス 0xA を 16 ms ごと、72 語 + TP_IDL のフレームを 1 s ごと。
#include "pico/stdlib.h"
#include "hardware/pio.h"
#include <string.h>
#include <stdio.h>
/* 語 → バイト (manchester の逆)。壊れた語は -1 */
static int unmanchester(uint32_t w) {
    int b = 0;
    for (int i = 0; i < 8; i++) {
        uint32_t nib = (w >> (4 * i)) & 0xF;
        if (nib == 0x9) b |= 1 << i; else if (nib != 0x6) return -1;
    }
    return b;
}
static uint32_t crc32_ref(const uint8_t *p, size_t n) {
    uint32_t crc = 0xFFFFFFFFu;
    for (size_t i = 0; i < n; i++) { crc ^= p[i]; for (int k = 0; k < 8; k++) crc = (crc >> 1) ^ (0xEDB88320u & (0u - (crc & 1u))); }
    return ~crc;
}
int main(void) {
    mock_reset(0);
    mock_run(2300000);                                   /* 2.3 s: フレーム 2 つ */
    mock_check(M.sys_khz == 120000, "sys クロックは 120 MHz: %u kHz", M.sys_khz);
    mock_check(M.pio_prog_len == 1 && M.pio_prog[0] == 0x6002, "PIO は out pins, 2 の 1 命令: 0x%04x", M.pio_prog[0]);
    mock_check(M.pio_out_base == 16 && M.pio_out_count == 2, "out pins は GP16 から 2 本 (GP16 = TX-, GP17 = TX+)");
    mock_check(M.pio_pindirs_base == 16 && M.pio_pindirs_count == 2 && M.pio_pindirs_out, "GP16・GP17 を出力方向");
    mock_check(M.pio_shift_right && M.pio_autopull && M.pio_pull_thresh == 32, "右シフト・autopull 32");
    mock_check(M.pio_fifo_join == PIO_FIFO_JOIN_TX, "TX FIFO を結合");
    mock_check(M.pio_clkdiv == 6.0f, "分周は 120 MHz / 20 MHz = 6: %g", M.pio_clkdiv);
    mock_check(M.pio_sm_enabled, "状態機械を有効にする");
    mock_check(M.drive[16] == GPIO_DRIVE_STRENGTH_12MA && M.drive[17] == GPIO_DRIVE_STRENGTH_12MA, "GPIO は 12 mA 設定");
    /* 語の列を歩く: NLP (0xA) の間隔と、フレーム (73 語) の中身 */
    uint frames = 0, nlps = 0; uint64_t last_nlp = 0, frame_t[4] = {0};
    for (uint i = 0; i < M.npio_tx; i++) {
        uint32_t w = M.pio_tx[i];
        if (w == 0x0000000Au) {
            if (nlps > 0) mock_check(M.pio_tx_t[i] - last_nlp >= 16000 && M.pio_tx_t[i] - last_nlp <= 16200, "NLP の間隔 16 ms: %llu us", (unsigned long long)(M.pio_tx_t[i] - last_nlp));
            last_nlp = M.pio_tx_t[i]; nlps++;
            continue;
        }
        /* フレームの先頭: プリアンブル 0x55 の語 */
        mock_check(unmanchester(w) == 0x55, "フレームはプリアンブル 0x55 から: 語 %u = 0x%08x", i, w);
        uint8_t f[80]; uint n = 0;
        for (; n < 72 && i + n < M.npio_tx; n++) { int b = unmanchester(M.pio_tx[i + n]); if (b < 0) break; f[n] = (uint8_t)b; }
        mock_check(n == 72, "フレームは 72 語: %u", n);
        mock_check(i + 72 < M.npio_tx && M.pio_tx[i + 72] == 0x00000AAAu, "フレームの後に TP_IDL 0xAAA");
        if (n == 72) {
            mock_check(memcmp(f, "\x55\x55\x55\x55\x55\x55\x55\xd5", 8) == 0, "プリアンブル 7 + SFD 0xD5");
            mock_check(memcmp(&f[8], "\xff\xff\xff\xff\xff\xff", 6) == 0, "宛先 MAC はブロードキャスト");
            mock_check(f[20] == 0x08 && f[21] == 0x00, "EtherType 0x0800");
            uint32_t s = 0; for (int k = 0; k < 20; k += 2) s += (uint32_t)f[22 + k] << 8 | f[23 + k];
            while (s >> 16) s = (s & 0xFFFF) + (s >> 16);
            mock_check(s == 0xFFFF, "IP ヘッダの検査和が合う: 0x%04x", s);
            mock_check(f[31] == 17 && f[38] == 0xFF && f[41] == 0xFF, "UDP、宛先 255.255.255.255");
            mock_check(f[44] == 0x04 && f[45] == 0xD2 && f[46] == 0 && f[47] == 26, "UDP の宛先ポート 1234、長さ 26");
            uint32_t fcs = crc32_ref(&f[8], 60), got = f[68] | f[69] << 8 | f[70] << 16 | (uint32_t)f[71] << 24;
            mock_check(fcs == got, "FCS が CRC-32 と一致: 0x%08x / 0x%08x", fcs, got);
            mock_check(memcmp(&f[50], "P2 10BASE-T 0000", 16) == 0, "payload は P2 10BASE-T 0000n: [%.17s]", (char *)&f[50]);
        }
        if (frames < 4) frame_t[frames] = M.pio_tx_t[i];
        frames++;
        i += 72;
        last_nlp = M.pio_tx_t[i];                       /* フレームの直後から NLP を数え直す */
        nlps = 0;
    }
    mock_check(frames == 2, "2.3 s にフレーム 2 つ: %u", frames);
    mock_check(frames >= 2 && frame_t[1] - frame_t[0] >= 1000000 && frame_t[1] - frame_t[0] <= 1000200, "フレームの間隔 1 s: %llu us", (unsigned long long)(frame_t[1] - frame_t[0]));
    mock_check(M.npio_tx > 100, "NLP が 16 ms ごとに積まれている: 語 %u", M.npio_tx);
    mock_check(strncmp(M.out, "frame 1\n", 8) == 0, "USB シリアルに frame 1: [%.20s]", M.out);
    return mock_report();
}
