#pragma once
#include "../pico_mock.h"
#define DMA_IRQ_0 11
enum dma_channel_transfer_size { DMA_SIZE_8, DMA_SIZE_16, DMA_SIZE_32 };
typedef struct { int dreq, chain, size; bool rinc, winc; } dma_channel_config;
static inline int dma_claim_unused_channel(bool req) { (void)req; return (int)M.dma_claimed++; }
static inline dma_channel_config dma_channel_get_default_config(uint ch) { (void)ch; return (dma_channel_config){0x3f, 0, 2, true, false}; }
static inline void channel_config_set_transfer_data_size(dma_channel_config *c, int s) { c->size = s; }
static inline void channel_config_set_read_increment(dma_channel_config *c, bool b) { c->rinc = b; }
static inline void channel_config_set_write_increment(dma_channel_config *c, bool b) { c->winc = b; }
static inline void channel_config_set_dreq(dma_channel_config *c, uint d) { c->dreq = (int)d; }
static inline void channel_config_set_chain_to(dma_channel_config *c, uint ch) { c->chain = (int)ch; }
static inline void dma_channel_configure(uint ch, const dma_channel_config *c, void *w, const volatile void *r, uint n, bool trig) {
    (void)trig; M.dma[ch].write = w; M.dma[ch].read = (const void *)r; M.dma[ch].count = n; M.dma[ch].size = c->size; M.dma[ch].chain = c->chain;
}
static inline void dma_channel_set_write_addr(uint ch, volatile void *w, bool trig) { (void)trig; M.dma[ch].write = (void *)w; }
static inline void dma_channel_set_irq0_enabled(uint ch, bool e) { M.dma[ch].irq0 = e; }
static inline bool dma_channel_get_irq0_status(uint ch) { return M.dma_pending_mask >> ch & 1; }
static inline void dma_channel_acknowledge_irq0(uint ch) { M.dma_pending_mask &= ~(1u << ch); }
static inline void dma_channel_start(uint ch) { (void)ch; }
static inline void dma_channel_wait_for_finish_blocking(uint ch) { (void)ch; if (M.idle_hook) M.idle_hook(); mock_advance_us(1); }
