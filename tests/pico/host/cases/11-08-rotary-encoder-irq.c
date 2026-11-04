// program: 01-circuits/11-microcontrollers/08-rotary-encoder-irq-1.c
// 11-8: GP14 (CLK) と GP13 (SW) の立ち下がりの割り込み。CLK が落ちた瞬間の DT (GP15) が H なら +1、L なら −1、SW で 0 に戻す。
#include "pico/stdlib.h"
#include "hardware/gpio.h"
#include <string.h>
/* 割り込みを起こす時刻 (µs)・ピン・その時の DT */
static const struct { uint64_t t; uint pin; bool dt; } EV[] = {
    {10000, 14, true}, {35000, 14, true}, {60000, 14, true}, {85000, 14, false}, {120000, 13, true}};
static uint next_ev;
static void hook(void) {
    while (next_ev < 5 && M.now_us >= EV[next_ev].t && mock_gpio_irq_cb) {
        M.in_value[15] = EV[next_ev].dt;
        mock_gpio_irq_cb(EV[next_ev].pin, GPIO_IRQ_EDGE_FALL);
        next_ev++;
    }
}
int main(void) {
    mock_reset(0);
    M.idle_hook = hook;
    mock_run(200000);
    mock_check(mock_gpio_irq_events[14] == GPIO_IRQ_EDGE_FALL && mock_gpio_irq_events[13] == GPIO_IRQ_EDGE_FALL, "GP14・GP13 の立ち下がり");
    mock_check(!M.dir_out[14] && !M.dir_out[15] && !M.dir_out[13], "3 本とも入力");
    mock_check(M.pull_up[13] && !M.pull_up[14] && !M.pull_up[15], "SW だけ内蔵プルアップ");
    mock_check(next_ev == 5, "割り込み 5 回: %u", next_ev);
    mock_check(strcmp(M.out, "1\n2\n3\n2\n0\n") == 0, "1・2・3・2・0: [%s]", M.out);
    return mock_report();
}
