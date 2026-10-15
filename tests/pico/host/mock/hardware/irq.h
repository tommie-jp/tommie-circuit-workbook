#pragma once
#include "../pico_mock.h"
static inline void irq_set_exclusive_handler(uint n, void (*h)(void)) { M.irq_handler[n] = h; }
static inline void irq_set_enabled(uint n, bool e) { M.irq_enabled[n] = e; }
static inline void irq_set_priority(uint n, uint8_t p) { (void)n; (void)p; }
