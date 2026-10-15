// 06-8080 の harness.cpp をそのまま使う観測プログラム。
//   probe8080 out  <06-8080 のパス>  : CP/M を起動し、プロンプト "A>" の 'A' を出す OUT 01h の前後を出す
//   probe8080 count <16 進のバイト…> : 0000 から置いた機械語を走らせ、命令ごとの T ステートを数える
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>

extern "C" {
int       sim_init(const char* bios, const char* cpm, const char* dsk);
void      step();
int       get_display_char();
uint32_t* get_ring_ptr();
uint32_t  get_head();
int       get_ring_words();
void      sim_poke(uint16_t addr, uint8_t val);
uint8_t   sim_read_byte(uint16_t addr);
}

static const uint32_t MASK = 4096 - 1;  // RING_SIZE (cpm_const.h)
static uint32_t word(uint32_t h, int k) { return get_ring_ptr()[(h & MASK) * get_ring_words() + k]; }
static uint32_t last() { return get_head() - 1; }

static void print_sample(uint32_t h, uint32_t origin) {
    const uint32_t w0 = word(h, 0), w1 = word(h, 1), w3 = word(h, 3), w4 = word(h, 4);
    printf("%3d T%u SYNC=%u DBIN=%u WR_N=%u io_req=%u status=%02X addr=%04X dbus=%02X\n",
           (int)(h - origin), (w0 >> 26) & 63, (w0 >> 9) & 1, (w0 >> 8) & 1, (w0 >> 10) & 1,
           (w0 >> 24) & 1, w4 & 0xFF, w1 & 0xFFFF, (w3 >> 24) & 0xFF);
}


int main(){
  const uint8_t prog[]={0x31,0x00,0x80,0x00,0x41,0x3E,0x55,0x21,0x80,0x00,0x80,0x3C,0x3D,0x7E,0x77,0xEB,0xDB,0x40,0xD3,0x40,0x2A,0x80,0x00,0x22,0x80,0x00,0xC5,0xE3,0xC1,0x09};
  sim_init(nullptr,nullptr,nullptr);
  for(size_t i=0;i<sizeof prog;i++) sim_poke((uint16_t)i,prog[i]);
  for(long i=0;i<4000;i++){
    step();
    uint32_t h=last(); uint32_t w0=word(h,0);
    if(((w0>>9)&1) && (word(h,4)&0xFF)==0xA2 && (word(h,1)&0xFFFF)==0x001A) {
      uint32_t origin=h;
      for(int k=0;k<24;k++){ print_sample(origin+k-0,origin); if(k<23) step(); }
      return 0; }
  }
  return 1; }
