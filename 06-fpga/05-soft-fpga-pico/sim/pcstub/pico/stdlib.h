// PC stub of pico/stdlib.h for logic checks (gpio as one 32-bit word, repeating timer driven by sleep/tight loop)
#pragma once
#include <cstdio>
#include <cstdint>
typedef unsigned uint;
#define GPIO_IN 0
#define GPIO_OUT 1
extern uint32_t g_gpio;      // pin levels (inputs preset by harness, outputs written by program)
extern uint32_t g_outmask;
extern uint32_t g_extlow;   // pins held low externally (switch ON)
extern long g_iter, g_limit;
extern int64_t g_delay;
struct repeating_timer_t { int dummy; };
typedef bool (*repeating_timer_callback_t)(repeating_timer_t*);
extern repeating_timer_callback_t g_cb;
extern void (*g_hook)(uint pin,int v);
extern void (*g_step)(long);
inline bool g_run(){ if(g_step) g_step(g_iter); return ++g_iter < g_limit; }
inline void gpio_init(uint){}
inline void gpio_init_mask(uint32_t){}
inline void gpio_set_dir(uint p,int out){ if(out) g_outmask|=1u<<p; else g_outmask&=~(1u<<p);}
inline void gpio_set_dir_out_masked(uint32_t m){ g_outmask|=m; }
inline void gpio_pull_up(uint p){ g_gpio|=1u<<p; }
inline int gpio_get(uint p){return ((g_gpio&~g_extlow)>>p)&1;}
inline uint32_t gpio_get_all(){return g_gpio&~g_extlow;}
inline void gpio_put(uint p,int v){ int old=(g_gpio>>p)&1; v=!!v; if(v) g_gpio|=1u<<p; else g_gpio&=~(1u<<p); if(old!=v && g_hook) g_hook(p,v);}
inline void gpio_put_masked(uint32_t m,uint32_t v){ for(uint p=0;p<32;p++) if((m>>p)&1) gpio_put(p,(v>>p)&1);}
inline void gpio_xor_mask(uint32_t m){ for(uint p=0;p<32;p++) if((m>>p)&1) gpio_put(p,!((g_gpio>>p)&1));}
inline bool add_repeating_timer_us(int64_t d, repeating_timer_callback_t cb, void*, repeating_timer_t*){ g_cb=cb; g_delay=d<0?-d:d; return true;}
inline void tight_loop_contents(){ if(g_cb){ repeating_timer_t t; g_cb(&t);} }
inline void sleep_ms(unsigned ms){ if(g_cb){ long n=ms*1000L/g_delay; repeating_timer_t t; for(long i=0;i<n;i++) g_cb(&t);} }
