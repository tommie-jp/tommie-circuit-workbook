#include <cstdio>
#include <stdint.h>
extern "C" { void sim_init(); void step(); void press_btn(); uint32_t get_head(); uint32_t* get_ring_ptr(); int get_ring_size(); int get_ring_words(); void reset_sim(); }
static uint32_t at(uint32_t i){ return get_ring_ptr()[(i&(get_ring_size()-1))*get_ring_words()]; }
static void run(const char* name,int press,int total){
  sim_init();
  uint32_t head0=get_head();
  printf("%s:\n",name);
  uint32_t prev=at(head0-1)&3; int prevreq=0; int cnt=0; 
  for(int n=1;n<=total;n++){
    if(n==press) press_btn();
    step();
    uint32_t w=at(get_head()-1);
    uint32_t s=w&3, req=(w>>6)&1;
    if(s!=prev){ const char* nm[]={"GREEN","YELLOW","RED","WALK"}; printf("  step %d -> %s  (timer=%u, g%u y%u r%u w%u)\n",n,nm[s],(w>>16)&0x3FF,(w>>2)&1,(w>>3)&1,(w>>4)&1,(w>>5)&1); prev=s;}
    if(req!=(uint32_t)prevreq){ printf("  step %d btn_req=%u\n",n,req); prevreq=req;}
  }
}
int main(){
  sim_init();
  printf("head after init=%u, first samples rst/timer: ",get_head());
  for(int i=0;i<3;i++){uint32_t w=at(i); printf("[rst=%u timer=%u] ",(w>>7)&1,(w>>16)&0x3FF);} printf("\n");
  run("no button",0,1600);
  run("press at 200",200,1100);
  run("press at 700",700,2000);
  // timer at WALK entry & GREEN first length
  sim_init(); press_btn(); 
  return 0; }
