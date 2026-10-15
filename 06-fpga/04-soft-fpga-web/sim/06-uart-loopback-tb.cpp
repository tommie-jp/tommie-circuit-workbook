#include <cstdio>
#include <stdint.h>
extern "C" { void sim_init(); void step(); void send_byte(uint8_t); uint32_t get_head(); uint32_t* get_ring_ptr(); int get_ring_size(); int get_ring_words();
 uint32_t get_rx_valid_count(); uint8_t get_rx_byte(uint32_t); }
static uint32_t w0(uint32_t i){ return get_ring_ptr()[(i&(get_ring_size()-1))*get_ring_words()]; }
static void send_str(const char* s){ for(;*s;s++) send_byte((uint8_t)*s); }
int main(){
  sim_init();
  send_byte(0x41);
  uint32_t base=get_head(); // samples before step 1
  uint32_t pt=1,ps=0,pr=0,pv=0,prdy=1,pbit=0,pxs=0; 
  for(int n=1;n<=200;n++){
    step();
    uint32_t w=w0(get_head()-1);
    uint32_t txd=w&1, tv=(w>>2)&1, rdy=(w>>3)&1, rv=(w>>4)&1, ts=(w>>6)&3, rs=(w>>8)&3, rb=(w>>13)&7, rd=(w>>24)&0xFF;
    if(txd!=pt){printf("step %d txd=%u\n",n,txd);pt=txd;}
    if(tv!=pv){printf("step %d tx_valid=%u\n",n,tv);pv=tv;}
    if(ts!=ps){printf("step %d tx_state=%u\n",n,ts);ps=ts;}
    if(rs!=pr){printf("step %d rx_state=%u\n",n,rs);pr=rs;}
    if(rdy!=prdy){printf("step %d tx_ready=%u\n",n,rdy);prdy=rdy;}
    if(rb!=pbit){printf("step %d rx_bit=%u\n",n,rb);pbit=rb;}
    if(rv){printf("step %d rx_valid=1 rx_data=0x%02x\n",n,rd);}
  }
  // Hi
  uint32_t c0=get_rx_valid_count();
  send_str("Hi"); for(int n=0;n<400;n++) step();
  printf("Hi -> %u bytes: ",get_rx_valid_count()-c0); for(uint32_t k=c0;k<get_rx_valid_count();k++) printf("%c(0x%02x) ",get_rx_byte(k),get_rx_byte(k)); printf("\n");
  c0=get_rx_valid_count();
  send_str("Hello World"); for(int n=0;n<2000;n++) step();
  printf("Hello World -> "); for(uint32_t k=c0;k<get_rx_valid_count();k++) printf("%c",get_rx_byte(k)); printf(" (%u)\n",get_rx_valid_count()-c0);
  // queue limit
  sim_init(); c0=get_rx_valid_count();
  for(int i=0;i<70;i++) send_byte('a'+(i%26));
  for(int n=0;n<20000;n++) step();
  printf("queued 70 -> received %u\n",get_rx_valid_count());
  return 0; }
