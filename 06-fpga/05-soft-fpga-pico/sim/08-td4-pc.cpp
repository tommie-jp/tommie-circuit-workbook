#include <cstdio>
#include "td4_58_pc.cpp"
static int n=0;
static void hook(uint p,int v){ if(p==PIN_CLK && v==0){ printf("%X ",(g_gpio>>18)&0xF); n++; } }
int main(){ g_hook=hook; g_limit=2*24+1; g_gpio=0xF<<10; g_extlow=0; target_main(); printf("\n"); }
