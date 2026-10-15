#pragma once
#include "../pico_mock.h"
typedef struct { int n; } i2c_inst_t;
extern i2c_inst_t mock_i2c[2];
#define i2c0 (&mock_i2c[0])
#define i2c1 (&mock_i2c[1])
static inline uint i2c_init(i2c_inst_t *i, uint b) { M.i2c_baud[i->n] = b; return b; }
static inline int i2c_write_blocking(i2c_inst_t *i, uint8_t a, const uint8_t *s, size_t n, bool nostop) { (void)i; (void)a; (void)s; (void)nostop; M.i2c_writes++; return (int)n; }
static inline int i2c_read_blocking(i2c_inst_t *i, uint8_t a, uint8_t *d, size_t n, bool nostop) {
    (void)i; (void)a; (void)nostop; M.i2c_reads++;
    for (size_t k = 0; k < n; k++) d[k] = k < M.n_i2c_reply ? M.i2c_reply[k] : 0;
    return (int)n;
}
