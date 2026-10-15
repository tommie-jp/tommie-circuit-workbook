#include "Vp_rom.h"
#include <cstdio>
int main(){ VerilatedContext c; Vp_rom t{&c}; for(int a=0;a<16;a++){ t.addr=a; t.clk=0;t.eval();t.clk=1;t.eval(); printf("%d ",(int)t.data);} printf("\n"); }
