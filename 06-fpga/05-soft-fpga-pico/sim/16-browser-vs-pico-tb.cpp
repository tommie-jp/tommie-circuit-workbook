#include "Vcounter43.h"
#include <cstdio>
int main(){ VerilatedContext c; Vcounter43 t{&c}; t.clk=0; t.rst=1; t.eval(); t.rst=0; t.eval();
 for(int i=1;i<=100;i++){ t.clk=1; t.eval(); unsigned v=t.count; if(i<=12||i>=96||(i%4==0)) {} ; if(i<=12) printf("%d led=%u tick=%u ticks0=%u ticks1=%u count=%u\n",i,v&1,(v>>1)&1,(v>>2)&1,(v>>3)&1,v); if(i==100) printf("100: count=%u ticks=%u tick=%u led=%u\n",v,(v>>2)&0x3f,(v>>1)&1,v&1); t.clk=0; t.eval(); }
 // reversal events
}
