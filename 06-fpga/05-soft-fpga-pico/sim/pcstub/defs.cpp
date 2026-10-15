#include "pico/stdlib.h"
uint32_t g_gpio=0, g_outmask=0, g_extlow=0; long g_iter=0, g_limit=0; int64_t g_delay=1;
repeating_timer_callback_t g_cb=nullptr; void (*g_hook)(uint,int)=nullptr;
void (*g_step)(long)=nullptr;
