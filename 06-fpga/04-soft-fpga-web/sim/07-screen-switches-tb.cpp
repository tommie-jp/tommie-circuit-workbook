#include <cstdio>
#include <stdint.h>
extern "C" { void sim_init(); void step(); void set_sw(uint32_t); void press_btn(); uint32_t get_out(); uint32_t get_cycles(); }
static void show(const char* tag){ uint32_t o=get_out(); printf("%s AND=%u OR=%u presses=%u\n",tag,o&1,(o>>1)&1,(o>>4)&0xF); }
int main(){
  sim_init(); step(); show("open     ");
  set_sw(1); step(); show("SW0 on   ");
  set_sw(3); step(); show("SW1 on   ");
  set_sw(2); step(); show("SW0 off  ");
  for(int i=0;i<3;i++){ press_btn(); step(); step(); }
  show("BTN x3   ");
  // figure scenario: step n rising at n ms
  sim_init();
  uint32_t sw=0; uint32_t pp=0,pa=0,po=0;
  for(int n=1;n<=20;n++){
    if(n==3) sw|=1; if(n==7) sw|=2; if(n==17) sw&=~1u;
    set_sw(sw); if(n==10||n==14) press_btn();
    step(); uint32_t o=get_out();
    if(((o>>4)&0xF)!=pp||(o&1)!=pa||((o>>1)&1)!=po){ printf("step %d AND=%u OR=%u presses=%u\n",n,o&1,(o>>1)&1,(o>>4)&0xF); pp=(o>>4)&0xF;pa=o&1;po=(o>>1)&1; }
  }
  // press twice before one step
  sim_init(); press_btn(); press_btn(); step(); printf("press x2 then 1 step: presses=%u\n",(get_out()>>4)&0xF);
  return 0; }
