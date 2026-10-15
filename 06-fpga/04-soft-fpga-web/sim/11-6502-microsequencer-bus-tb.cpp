// 04-6502 の harness.cpp をそのまま使い、Woz Monitor にプログラムを打ち込んで、
// 1 クロックごとのバス (addr・data・we・sync) とマイクロシーケンサの状態を出す。
#include <cstdint>
#include <cstdio>

extern "C" {
void      sim_init();
void      step();
void      send_key(uint8_t ch);
uint32_t* get_ring_ptr();
uint32_t  get_head();
int       get_ring_size();
uint8_t   get_state();
}

// cpu_65c02.v の parameter の並び (0〜53)
static const char* NAME[] = {
    "ABS0", "ABS1", "ABSX0", "ABSX1", "ABSX2", "BRA0", "BRA1", "BRA2",
    "BRK0", "BRK1", "BRK2", "BRK3", "DECODE", "FETCH", "INDX0", "INDX1",
    "INDX2", "INDX3", "INDY0", "INDY1", "INDY2", "INDY3", "JMP0", "JMP1",
    "JMPI0", "JMPI1", "JSR0", "JSR1", "JSR2", "JSR3", "PULL0", "PULL1",
    "PULL2", "PUSH0", "PUSH1", "READ", "REG", "RTI0", "RTI1", "RTI2",
    "RTI3", "RTI4", "RTS0", "RTS1", "RTS2", "RTS3", "WRITE", "ZP0",
    "ZPX0", "ZPX1", "IND0", "JMPIX0", "JMPIX1", "JMPIX2"};

int main(int argc, char** argv) {
    const char* typed = argc > 1 ? argv[1] : "0300: A9 AA 85 10 A5 10 4C 00 03\r0300R\r";
    sim_init();
    for (const char* p = typed; *p; ++p) send_key((uint8_t)*p);
    for (int i = 0; i < 200000; ++i) step();  // 打ち込みが済み、0300 から走り出すまで回す
    for (int i = 0; i < 1000 && get_state() != 22; ++i) step();  // JMP0 (22) まで進め、次の JMP1 から出す

    const uint32_t* ring = get_ring_ptr();
    const uint32_t  mask = (uint32_t)get_ring_size() - 1;
    for (int i = 0; i < 13; ++i) {
        step();
        const uint32_t w = ring[((get_head() - 1) & mask) * 2];  // Word0 = AB/DB/WE/SYNC
        printf("%2d addr=%04X data=%02X we=%u sync=%u state=%s\n", i, w & 0xFFFF,
               (w >> 16) & 0xFF, (w >> 24) & 1, (w >> 25) & 1, NAME[get_state()]);
    }
    return 0;
}
