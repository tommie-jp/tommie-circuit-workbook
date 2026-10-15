#include <cstdint>
#include <cstdio>
#include <cstdlib>
extern "C" { void sim_init(); void step(); void send_key(uint8_t ch); uint32_t* get_ring_ptr(); uint32_t get_head(); int get_ring_size(); uint8_t get_state(); }
static const char* NAME[] = {"ABS0","ABS1","ABSX0","ABSX1","ABSX2","BRA0","BRA1","BRA2","BRK0","BRK1","BRK2","BRK3","DECODE","FETCH","INDX0","INDX1","INDX2","INDX3","INDY0","INDY1","INDY2","INDY3","JMP0","JMP1","JMPI0","JMPI1","JSR0","JSR1","JSR2","JSR3","PULL0","PULL1","PULL2","PUSH0","PUSH1","READ","REG","RTI0","RTI1","RTI2","RTI3","RTI4","RTS0","RTS1","RTS2","RTS3","WRITE","ZP0","ZPX0","ZPX1","IND0","JMPIX0","JMPIX1","JMPIX2"};
int main(int argc,char**argv){
  const char* typed=argv[1]; int opc=strtol(argv[2],0,16);
  sim_init();
  for(const char*p=typed;*p;++p) send_key((uint8_t)*p);
  for(int i=0;i<200000;++i) step();
  const uint32_t* ring=get_ring_ptr(); uint32_t mask=get_ring_size()-1;
  // find a sync clock with opcode
  int tries=0;
  while(tries++<5000){ step(); uint32_t w=ring[((get_head()-1)&mask)*2]; if(((w>>25)&1) && (int)((w>>16)&0xFF)==opc && ((w&0xFFFF)>>8)==3) break; }
  // print this clock and following until next 2 syncs
  int syncs=0;
  for(int i=0;i<14;i++){
    uint32_t w=ring[((get_head()-1)&mask)*2];
    int sync=(w>>25)&1;
    if(sync && i>0) { syncs++; printf("-- next instruction after %d clocks\n",i); break; }
    printf("%2d addr=%04X data=%02X we=%u sync=%u state=%s\n",i,w&0xFFFF,(w>>16)&0xFF,(w>>24)&1,sync,NAME[get_state()]);
    step();
  }
  return 0; }
