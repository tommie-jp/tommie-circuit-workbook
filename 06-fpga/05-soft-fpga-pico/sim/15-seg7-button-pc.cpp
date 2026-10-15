#include <cstdio>
#include <vector>
#include "s_pc.cpp"
static unsigned segv(){ unsigned v=0; const unsigned P[7]={11,12,16,17,18,10,9}; for(int i=0;i<7;i++) v|=((g_gpio>>P[i])&1)<<i; return v; }
static unsigned cnt(){ unsigned v=0; const unsigned P[4]={22,21,20,19}; for(int i=0;i<4;i++) v|=((g_gpio>>P[i])&1)<<i; return v; }
static std::vector<int> sc; static std::vector<unsigned> counts, segs;
static void step(long k){ if(k>0){ counts.push_back(cnt()); segs.push_back(segv()); } if(k<(long)sc.size()){ if(sc[k]) g_gpio|=1u<<26; else g_gpio&=~(1u<<26);} }
static void run(const char* name, std::vector<int> s){
  sc=s; counts.clear(); segs.clear(); g_iter=0; g_limit=(long)s.size()+1; g_step=step; g_gpio=0; target_main();
  printf("%s: ",name); unsigned last=999; for(size_t i=0;i<counts.size();i++){ if(counts[i]!=last){ printf("[loop %zu: count=%u seg=0x%02X] ",i+1,counts[i],segs[i]); last=counts[i]; } } printf("\n"); }
int main(){
  std::vector<int> a; for(int i=0;i<10;i++)a.push_back(1); for(int i=0;i<20;i++)a.push_back(0); for(int i=0;i<20;i++)a.push_back(1);
  run("A離10/押20/離20",a);
  std::vector<int> c; for(int i=0;i<10;i++){ c.push_back(1);c.push_back(1);c.push_back(0);c.push_back(0);} 
  run("C 2離2押x10",c);
  // each run re-uses the same static model: counts continue; so print segs for C continuing
  run("B 離3/押(L,H,L)/L 5", {1,1,1,0,1,0,0,0,0,0,0});
  return 0; }
