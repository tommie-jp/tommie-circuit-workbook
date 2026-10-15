#include "Vp_disp.h"
#include <cstdio>
int main(){ VerilatedContext c; Vp_disp t{&c}; t.rst=1; t.clk=0;t.eval();t.clk=1;t.eval(); t.rst=0; int n=0;
  while(!c.gotFinish() && n<100){ t.clk=0;t.eval();t.clk=1;t.eval();n++; }
  printf("p_disp: gotFinish=%d after %d clocks, count=%d\n", (int)c.gotFinish(), n, (int)t.count); }
