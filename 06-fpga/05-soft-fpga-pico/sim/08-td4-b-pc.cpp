#include <cstdio>
#include "td4_58_pc.cpp"
static void hook(uint p,int v){ if(p==PIN_CLK && v==0){ printf("%X ",(g_gpio>>18)&0xF);} }
int main(int argc,char**argv){ g_hook=hook; g_limit=2*12+1; g_gpio=0xF<<10; unsigned dip=argc>1?atoi(argv[1]):0;
  // dip value: SW1=bit3 ... ON = pin L; SW1=GP10
  g_extlow=0; for(int b=0;b<4;b++) if((dip>>(3-b))&1) g_extlow|=1u<<(10+b);
  target_main(); printf("\n"); }
