#pragma once
#include "../pico_mock.h"
enum clock_index { clk_gpout0, clk_gpout1, clk_gpout2, clk_gpout3, clk_ref, clk_sys, clk_peri, clk_usb, clk_adc };
static inline uint32_t clock_get_hz(enum clock_index c) { return c == clk_sys ? MOCK_SYS_HZ : 48000000u; }
static inline bool set_sys_clock_pll(uint32_t a, uint b, uint c) { (void)a; (void)b; (void)c; return true; }
