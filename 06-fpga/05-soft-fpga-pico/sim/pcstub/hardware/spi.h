// PC stub of hardware/spi.h: 16 ビットの語を 74HC595 の 2 段に入れる
#pragma once
#include "pico/stdlib.h"
typedef struct spi_inst spi_inst_t;
#define spi0 ((spi_inst_t*)0)
enum { SPI_CPOL_0 = 0, SPI_CPHA_0 = 0, SPI_MSB_FIRST = 1 };
#define GPIO_FUNC_SPI 1
extern uint16_t g_sr;  extern long g_spi_words; extern unsigned g_spi_hz, g_spi_bits;
inline unsigned spi_init(spi_inst_t*, unsigned hz){ g_spi_hz=hz; return hz; }
inline void spi_set_format(spi_inst_t*, unsigned bits, int, int, int){ g_spi_bits=bits; }
inline void gpio_set_function(uint, int){}
inline int spi_write16_blocking(spi_inst_t*, const uint16_t* s, size_t n){ for(size_t i=0;i<n;i++){ g_sr=s[i]; g_spi_words++; } return (int)n; }
inline void busy_wait_us_32(uint32_t){}
