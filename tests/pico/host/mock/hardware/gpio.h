#pragma once
#include "../pico_mock.h"
/* GPIO の割り込み (01-circuits 11-8 で足した)。登録した呼び出し先と、ピンごとの割り込みの種類を残すだけ。
 * 割り込みを起こすのはテストの側 (M.idle_hook などから mock_gpio_irq_cb を呼ぶ)。
 * 変数は weak の定義にして、本文の .o とテストの .c の両方から同じ物が見えるようにした。 */
enum { GPIO_IRQ_LEVEL_LOW = 0x1u, GPIO_IRQ_LEVEL_HIGH = 0x2u, GPIO_IRQ_EDGE_FALL = 0x4u, GPIO_IRQ_EDGE_RISE = 0x8u };
typedef void (*gpio_irq_callback_t)(uint gpio, uint32_t event_mask);
__attribute__((weak)) gpio_irq_callback_t mock_gpio_irq_cb;
__attribute__((weak)) uint32_t mock_gpio_irq_events[MOCK_NGPIO];
static inline void gpio_set_irq_enabled(uint g, uint32_t ev, bool en) { if (en) mock_gpio_irq_events[g] |= ev; else mock_gpio_irq_events[g] &= ~ev; }
static inline void gpio_set_irq_enabled_with_callback(uint g, uint32_t ev, bool en, gpio_irq_callback_t cb) { gpio_set_irq_enabled(g, ev, en); mock_gpio_irq_cb = cb; }
