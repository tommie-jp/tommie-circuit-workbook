#include <cstdio>
#include <stdint.h>
extern "C" { void sim_init(); void step(); uint32_t get_head(); uint32_t* get_ring_ptr(); int get_ring_size(); int get_ring_words(); }
static uint32_t at(uint32_t i){ return get_ring_ptr()[(i&(get_ring_size()-1))*get_ring_words()]&0xFF; }
int main(){
  sim_init();
  printf("head=%u\n",get_head());
  for(int i=0;i<24;i++) step();
  printf("samples 0..25:"); for(int i=0;i<26;i++) printf(" %02x",at(i)); printf("\n");
  // led edges and tick steps (step n = sample n+1)
  printf("led changes at step:"); for(int n=1;n<=24;n++){ if((at(n+1)&1)!=(at(n)&1)) printf(" %d",n);} printf("\n");
  printf("tick=1 at step:"); for(int n=1;n<=24;n++) if((at(n+1)>>1)&1) printf(" %d",n); printf("\n");
  for(int i=24;i<100;i++) step();
  uint32_t v=at(get_head()-1); printf("after100 count=%u ticks=%u tick=%u led=%u\n",v,v>>2,(v>>1)&1,v&1);
  for(int i=100;i<6000;i++) step();
  printf("last 8 after 6000:"); for(int k=8;k>=1;k--) printf(" %u",at(get_head()-k)); printf("\n");
  return 0; }
