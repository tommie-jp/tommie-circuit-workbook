#include <cstdio>
#include <stdint.h>
extern "C" { void sim_init(); void step(); void step_only(); uint32_t get_count(); void step_n_callback(uint32_t); void step_n(uint32_t); uint32_t* get_ring_ptr(); uint32_t get_head(); int get_ring_size(); }
static const uint32_t N=2000000;
int main(){
  uint32_t out=0;
  sim_init(); for(uint32_t i=0;i<N;i++){ step_only(); out=get_count(); } printf("A last=%u (N mod 256=%u)\n",out,N&255);
  sim_init(); step_n_callback(N); printf("B head-less ok\n");
  sim_init(); for(uint32_t i=0;i<N;i++) step(); printf("C last=%u head=%u\n",get_ring_ptr()[(get_head()-1)&1023],get_head());
  sim_init(); step_n(N); printf("D last=%u head=%u ring_size=%d\n",get_ring_ptr()[(get_head()-1)&1023],get_head(),get_ring_size());
  return 0; }
