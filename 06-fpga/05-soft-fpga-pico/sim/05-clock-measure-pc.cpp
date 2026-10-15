#include <cstdio>
#include "clock55_pc.cpp"
static int aux=0; static long clks=0; static int last_leds=-1;
static void hook(uint p,int v){ if(p==PIN_AUX){ aux++; printf("AUX toggled to %d at clock %ld\n",v,clks);} if(p==PIN_CLK && v==0) clks++; }
int main(){ g_gpio=0xF<<10; g_hook=hook; g_limit=2501; target_main();
  printf("clocks %ld, AUX toggles %d\n",clks,aux);
  // after reset(1 clk) + n clocks, count=n; LEDs show count[7:4] with GP2=bit3
  unsigned count=(unsigned)(clks); unsigned leds=(count>>4)&0xF;
  unsigned gp2_5=(g_gpio>>2)&0xF, mon=(g_gpio>>18)&0xF;
  printf("count=%u count[7:4]=%u  GP2..5 bits=%u (bit3<-GP2)  GP18..21=%u\n",count&0xFF,leds,gp2_5,mon);
}
