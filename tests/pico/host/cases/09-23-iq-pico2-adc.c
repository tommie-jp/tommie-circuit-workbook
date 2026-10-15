// program: 01-circuits/09-rf/23-iq-pico2-adc-1.c
// 9-23: ADC0・ADC1 を DMA で受け、I・Q の位相の進みから LO との差を kHz で出す。
// 合成した I・Q (振幅 0.5 V・LO より +1.000 kHz 上) を DMA の到着として与え、表示を確かめる。
#include "pico/stdlib.h"
#include "hardware/dma.h"
#include <math.h>
#include <string.h>
#define PAIRS 1000
static uint64_t pair = 0;     /* 250 kS/s で数える標本の通し番号 */
static void deliver(void) {
    static uint k = 0;
    if (M.dma_pending_mask) return;                     /* 前の IRQ が済むまで次を出さない */
    uint16_t *w = M.dma[k].write;
    for (int n = 0; n < PAIRS; n++, pair++) {
        double th = 2 * M_PI * 1000.0 * (double)pair / 250000.0;
        double amp = 0.5 * 2.0 / (3.3 / 4096.0);        /* 0.5 V・利得 2・LSB */
        w[2 * n] = (uint16_t)lround(2048 + amp * cos(th));
        w[2 * n + 1] = (uint16_t)lround(2048 - amp * sin(th));   /* RF が LO より上: Q が 90° 進む */
    }
    mock_advance_us(4000);
    mock_dma_deliver(k);
    k ^= 1;
}
int main(void) {
    mock_reset(0);
    M.idle_hook = deliver;
    mock_run(1000000);
    mock_check(M.adc_inited && M.adc_gpio_mask == ((1u << 26) | (1u << 27)), "GP26・GP27 を ADC にする");
    mock_check(M.dma_claimed == 2 && M.dma[0].count == 2000 && M.dma[1].count == 2000, "DMA 2 本・2000 標本");
    mock_check(M.dma[0].size == DMA_SIZE_16 && M.dma[0].chain == 1 && M.dma[1].chain == 0, "16 bit・互いに chain");
    mock_check(strncmp(M.out, "+1.000 kHz  1.00 Vpp", 20) == 0, "表示は +1.000 kHz・1.00 Vpp: [%.60s]", M.out);
    return mock_report();
}
