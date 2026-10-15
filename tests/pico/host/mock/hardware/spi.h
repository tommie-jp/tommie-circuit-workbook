#pragma once
#include "../pico_mock.h"
typedef struct { int n; } spi_inst_t;
extern spi_inst_t mock_spi[2];
#define spi0 (&mock_spi[0])
#define spi1 (&mock_spi[1])
typedef enum { SPI_CPOL_0 = 0, SPI_CPOL_1 = 1 } spi_cpol_t;
typedef enum { SPI_CPHA_0 = 0, SPI_CPHA_1 = 1 } spi_cpha_t;
typedef enum { SPI_LSB_FIRST = 0, SPI_MSB_FIRST = 1 } spi_order_t;
static inline uint spi_init(spi_inst_t *s, uint b) { (void)s; M.spi_baud = b; return b; }
static inline void spi_set_format(spi_inst_t *s, uint bits, spi_cpol_t p, spi_cpha_t a, spi_order_t o) { (void)s; M.spi_bits = bits; M.spi_cpol = (uint)p; M.spi_cpha = (uint)a; M.spi_order = (uint)o; }
static inline int spi_write16_blocking(spi_inst_t *s, const uint16_t *src, size_t n) { (void)s; for (size_t i = 0; i < n; i++) if (M.nspi < 256) M.spi_tx[M.nspi++] = src[i]; return (int)n; }
