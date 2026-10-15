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

static int run_out(const std::string& dir) {
    if (sim_init((dir + "/sw/cpm/bios/bios.bin").c_str(), (dir + "/rom/cpm22.bin").c_str(),
                 (dir + "/sw/cpm/disks/cpm22.dsk").c_str()))
        return 1;
    std::string out;
    for (long i = 0; i < 20000000; ++i) {
        step();
        for (int ch; (ch = get_display_char()) >= 0;) out += (char)ch;
        const uint32_t w0 = word(last(), 0);
        const bool out_req = ((w0 >> 24) & 3) == 3;  // io_req と io_wr
        // BIOS の名乗り (2 行目) の後に出る最初の 'A' がプロンプト
        if (out_req && (w0 & 0xFF) == 0x01 && ((w0 >> 16) & 0xFF) == 'A' &&
            out.find("tommie.jp") != std::string::npos) {
            for (int k = 0; k < 3; ++k) step();
            const uint32_t end = get_head(), origin = end - 22;
            for (uint32_t h = origin; h < end; ++h) print_sample(h, origin);
            return 0;
        }
    }
    return 1;
}

static int run_count(const std::vector<uint8_t>& prog) {
    sim_init(nullptr, nullptr, nullptr);
    for (size_t i = 0; i < prog.size(); ++i) sim_poke((uint16_t)i, prog[i]);
    bool prev_sync = false;
    long m1_at = -1;
    uint16_t m1_addr = 0;
    std::string cycles;  // マシンサイクルの status を並べる
    for (long i = 0; i < 4000; ++i) {
        step();
        const uint32_t h = last();
        const bool sync = (word(h, 0) >> 9) & 1;
        if (sync && !prev_sync) {  // SYNC の立ち上がり = マシンサイクルの始まり
            const uint8_t status = word(h, 4) & 0xFF;
            const uint16_t addr = word(h, 1) & 0xFFFF;
            if (status & 0x20) {  // M1 (命令フェッチ)
                if (m1_at >= 0)
                    printf("%04X op=%02X T=%ld status=%s\n", m1_addr, sim_read_byte(m1_addr),
                           (i - m1_at) / 2, cycles.c_str());  // 1 T = 2 step
                if (m1_at >= 0 && addr == 0) break;             // 0000 に戻ったら終わり
                m1_at = i; m1_addr = addr; cycles.clear();
            }
            char b[4];
            snprintf(b, sizeof b, "%s%02X", cycles.empty() ? "" : ",", status);
            cycles += b;
        }
        prev_sync = sync;
    }
    printf("RAM 0080=%02X 0081=%02X\n", sim_read_byte(0x0080), sim_read_byte(0x0081));
    return 0;
}

int main(int argc, char** argv) {
    const std::string mode = argc > 1 ? argv[1] : "";
    if (mode == "out" && argc > 2) return run_out(argv[2]);
    if (mode == "count") {
        std::vector<uint8_t> prog;
        for (int i = 2; i < argc; ++i) prog.push_back((uint8_t)strtol(argv[i], nullptr, 16));
        return run_count(prog);
    }
    fprintf(stderr, "usage: probe8080 out <dir> | probe8080 count <hex bytes...>\n");
    return 2;
}
