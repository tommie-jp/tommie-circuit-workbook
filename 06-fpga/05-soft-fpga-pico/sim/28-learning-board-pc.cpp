// 5-28 の主ループを PC で回す。74HC595 の 2 段を真似て、4 桁の表示を読む
#include <cstdio>
#include <cstring>
#include "s_pc.cpp"
uint16_t g_sr=0; long g_spi_words=0; unsigned g_spi_hz=0, g_spi_bits=0;
static uint16_t latched=0; static long latches=0;
static void hook(uint p,int v){ if(p==RCLK && v){ latched=g_sr; latches++; } }
// 桁ごとに最後に見た seg
static unsigned shown[4]; static int multi=0; static long seq_ok=0; static unsigned last_dig=0;
static void observe(){ unsigned dq=latched&0xFF, sq=latched>>8, dig=0, seg=0;
  for(int i=0;i<4;i++) if((dq>>DIG_Q[i])&1) dig|=1u<<i;
  for(int i=0;i<8;i++) if((sq>>SEG_Q[i])&1) seg|=1u<<i;
  int n=__builtin_popcount(dig); if(n!=1){ multi++; return; }
  int k=__builtin_ctz(dig); shown[k]=seg;
  if(last_dig && dig==((last_dig<<1)&0xF ? (last_dig<<1)&0xF : 1)) seq_ok++; last_dig=dig; }
// 入力の台本: 半周期ごとに呼ばれる
static uint32_t low=0;                 // L にしているピン (スイッチ ON・ボタンを押す)
static long t_half=0;
struct Ev{ long half; uint pin; int on; };
static Ev ev[4096]; static int nev=0, iev=0;
static void step(long k){ t_half=k; while(iev<nev && ev[iev].half<=k){ if(ev[iev].on) low|=1u<<ev[iev].pin; else low&=~(1u<<ev[iev].pin); iev++; } g_extlow=low; if(k%2==1) observe(); }
static void add(long ms, uint pin, int on){ ev[nev++]={ms*2,pin,on}; }
static void press(long &ms, uint pin, int hold, int gap){ add(ms,pin,1); ms+=hold; add(ms,pin,0); ms+=gap; }
static void show(const char* when){ printf("%-34s seg: ",when); for(int k=3;k>=0;k--) printf("%02X ",shown[k]); printf(" led=%02X\n",(unsigned)((g_gpio>>2)&0xFF)); }
static void run_to(long ms){ g_limit=ms*2; target_main(); }
int main(){
  g_hook=hook; g_step=step;
  long ms=100;
  add(ms,10,1); add(ms,12,1); ms+=100;               // SW0・SW2 を ON
  for(int i=0;i<3;i++) press(ms,15,50,50);            // BTN1 を 3 回
  for(int i=0;i<10;i++) press(ms,17,50,50);           // BTN3 を 10 回
  // BTN2 を跳ねさせて 15 回: L 1ms・H 1ms・L 1ms・H 1ms・L 40ms。101 ms おきなので、ボタンを見る時刻との位相が 16 通りずつずれる
  for(int i=0;i<15;i++){ add(ms,16,1); add(ms+1,16,0); add(ms+2,16,1); add(ms+3,16,0); add(ms+4,16,1); add(ms+44,16,0); ms+=101; }
  long end_cfg=ms;
  add(ms+20,14,1);                                    // 最後に BTN0 を押したまま
  g_limit=(end_cfg+40)*2; g_gpio=0; target_main();
  show("all steps (BTN0 held)");
  printf("spi %u Hz, %u bits, words=%ld latches=%ld, ms=%ld\n",g_spi_hz,g_spi_bits,g_spi_words,latches,end_cfg+40);
  printf("multi-digit frames=%d, in-order steps=%ld\n",multi,seq_ok);
  return 0; }
