#include <cstdio>
#include "clock57_pc.cpp"
static long calls=0, rises=0; static int tog=0; static long first=-1;
static void hook(uint p,int v){
  if(p==PIN_CLK && v==1) rises++;
  if(p==PIN_MON0){ tog++; printf("LED(OUT0)=%d at rising edge #%ld\n",v,rises); }
}
int main(){ g_hook=hook; g_gpio=0xF<<10; g_extlow=(1u<<11)|(1u<<12); // SW2, SW3 ON -> blink
  g_limit=501; target_main(); // 500 outer loops x 20 callbacks = 10000 half periods
  printf("rising edges %ld, LED toggles %d, delay=%lld us\n",rises,tog,(long long)g_delay); }
