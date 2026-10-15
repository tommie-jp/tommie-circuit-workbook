#include <cstdio>
#include "clock56_pc.cpp"
static int aux; static long clks;
static void hook(uint p,int v){ if(p==PIN_AUX) aux++; if(p==PIN_CLK && v==0) clks++; }
int main(){
  // sel by DIP: SW1..SW3 ON = pin L
  const char* names[]={"counter8","counter32","TD4","blink(1000)","many256"};
  int sws[5][3]={{0,0,0},{0,0,1},{0,1,0},{0,1,1},{1,0,0}};
  for(int k=0;k<5;k++){
    g_iter=0; aux=0; clks=0; g_limit=4001; g_hook=hook;
    g_gpio=0xF<<10; g_extlow=0;
    for(int i=0;i<3;i++) if(sws[k][i]) g_extlow|=(1u<<(10+i));
    unsigned sel=read_sel();
    target_main();
    printf("%-12s SW=%d%d%d sel=%u  clocks=%ld AUX toggles=%d  LED(GP18..21)=%u\n",names[k],sws[k][0],sws[k][1],sws[k][2],sel,clks,aux,(g_gpio>>18)&0xF);
  }
}
