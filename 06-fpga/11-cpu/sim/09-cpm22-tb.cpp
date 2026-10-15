// 11-9 の試験台。soft-fpga の examples/06-8080/cxx/harness.cpp をそのまま使い、
// 8080 の RTL (vm80a) で CP/M 2.2 を起こして、次を自分で確かめる。
//   1. 名乗りと A> のプロンプトが出る (何 T ステートか)
//   2. DIR で一覧が出る。その間にディスクのセクタを何回読むか
//   3. TPA ($0100) に置いた機械語を SAVE で .COM にし、名前で走らせる
// 使い方: tb09 <soft-fpga の examples/06-8080> <bios.bin>
// 終わりに PASS か FAIL: n を出す。
#include <cstdint>
#include <cstdio>
#include <string>
#include <vector>

extern "C" {
int       sim_init(const char* bios, const char* cpm, const char* dsk);
void      step();
void      send_key(uint8_t ch);
int       get_display_char();
uint32_t* get_ring_ptr();
uint32_t  get_head();
int       get_ring_words();
void      sim_poke(uint16_t addr, uint8_t val);
int       sim_get_disk_track();
int       sim_get_disk_sector();
uint16_t  sim_get_disk_dma();
}

static int         errors = 0;
static std::string screen;
static long        steps = 0;          // step() の数。1 T ステート = step() 2 回
static long        disk_reads = 0;     // OUT 10h に 0 (READ) を出した数
static long        disk_writes = 0;    // OUT 10h に 1 (WRITE) を出した数
static long        conout = 0;         // OUT 01h (CONOUT) の数
static std::vector<std::string> read_log;  // 読んだセクタ (トラック/セクタ→DMA)
struct IoEvent {
    long    step;
    bool    out;
    uint8_t port, data;
};
static std::vector<IoEvent> io_log;        // ディスクのポート (10h〜14h) の IN・OUT

static void check(bool ok, const char* what) {
    printf("%s %s\n", ok ? "ok" : "NG", what);
    if (!ok) ++errors;
}

static void run1() {
    step();
    ++steps;
    for (int ch; (ch = get_display_char()) >= 0;) screen += (char)ch;
    // Word0: [7:0] = io_addr、[23:16] = io_dout、[24] = io_req、[25] = io_wr (harness.cpp の冒頭の表)
    const uint32_t w0 = get_ring_ptr()[((get_head() - 1) & (4096 - 1)) * get_ring_words()];
    if ((w0 >> 24) & 1) {                    // io_req: IN か OUT
        const bool    out = (w0 >> 25) & 1;
        const uint8_t port = w0 & 0xFF;
        const uint8_t data = out ? (w0 >> 16) & 0xFF   // OUT は io_dout
                                 : (get_ring_ptr()[((get_head() - 1) & (4096 - 1)) * get_ring_words() + 1] >> 16) & 0xFF;  // IN は Word1 の io_din
        if (port >= 0x10 && port <= 0x14) io_log.push_back({steps, out, port, data});
    }
    if (((w0 >> 24) & 3) == 3) {
        const uint8_t port = w0 & 0xFF, data = (w0 >> 16) & 0xFF;
        if (port == 0x10 && data == 0) {
            ++disk_reads;
            char b[32];
            snprintf(b, sizeof b, "%d/%d->%04X", sim_get_disk_track(), sim_get_disk_sector(), sim_get_disk_dma());
            read_log.push_back(b);
        }
        if (port == 0x10 && data == 1) ++disk_writes;
        if (port == 0x01) ++conout;
    }
}

// want が今から後に出るまで回す。出たら true
static bool run_until(const std::string& want, long limit) {
    const size_t from = screen.size();
    for (long i = 0; i < limit; ++i) {
        run1();
        if (screen.find(want, from) != std::string::npos) return true;
    }
    return false;
}

// コマンドを 1 行打ち、次の "A>" が出るまで回す。出た字と、CR からの T ステートと読んだセクタ数を返す
struct Result {
    std::string text;
    long        t_states, reads, writes, chars;
};
static Result command(const std::string& s) {
    for (char c : s) send_key((uint8_t)c);
    run_until(s, 20000000);              // エコーが済むまで
    screen.clear();
    const long s0 = steps, r0 = disk_reads, w0 = disk_writes, c0 = conout;
    send_key('\r');
    run_until("A>", 200000000);
    return {screen, (steps - s0) / 2, disk_reads - r0, disk_writes - w0, conout - c0};
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: tb09 <soft-fpga/examples/06-8080> <bios.bin>\n");
        return 2;
    }
    const std::string dir = argv[1];
    if (sim_init(argv[2], (dir + "/rom/cpm22.bin").c_str(), (dir + "/sw/cpm/disks/cpm22.dsk").c_str()))
        return 2;

    // 1. 名乗りと A>
    const bool booted = run_until("A>", 20000000);
    printf("--- boot ---\n%s\n------------\n", screen.c_str());
    printf("A> after %ld steps (%ld T states), %ld sector reads\n", steps, steps / 2, disk_reads);
    check(booted && screen.find("64K CP/M VERS 2.2") != std::string::npos, "CP/M 2.2 signs on and prints A>");

    // 2. DIR
    read_log.clear();
    io_log.clear();
    const Result d = command("DIR");
    printf("--- DIR ---\n%s\n-----------\n", d.text.c_str());
    printf("DIR: %ld T states, %ld sector reads, %ld writes, %ld chars out\n", d.t_states, d.reads, d.writes,
           d.chars);
    check(d.text.find("A: ") != std::string::npos, "DIR lists files (lines start with \"A: \")");
    check(d.reads > 0 && d.writes == 0, "DIR only reads the disk");
    printf("DIR reads (track/sector->DMA):");
    for (const std::string& r : read_log) printf(" %s", r.c_str());
    printf("\n");
    check(read_log.size() >= 2 && read_log[0] == "2/0->F377" && read_log[1] == "2/6->F377",
          "the directory is on track 2, sectors 0, 6, ... (skew 6) into DIR_BUF F377");

    // 2 つ目のセクタを読むときの I/O の並び: OUT 11h (トラック) から IN 10h (結果) まで
    std::string seq;
    int nread = 0;
    long t0 = -1;
    for (const IoEvent& e : io_log) {
        if (e.out && e.port == 0x11) { t0 = e.step; seq.clear(); }
        if (t0 < 0) continue;
        char b[40];
        snprintf(b, sizeof b, "%sT+%ld %s %02X=%02X", seq.empty() ? "" : ", ", (e.step - t0) / 2,
                 e.out ? "OUT" : "IN", e.port, e.data);
        seq += b;
        if (!e.out && e.port == 0x10 && ++nread == 2) break;
    }
    printf("2nd sector read: %s\n", seq.c_str());
    check(seq == "T+0 OUT 11=02, T+299 OUT 12=06, T+420 OUT 13=77, T+448 OUT 14=F3, T+519 OUT 10=00, T+528 IN 10=00",
          "one sector read is OUT 11h, 12h, 13h, 14h, 10h then IN 10h");

    // 3. 自分の .COM を作る。BDOS の 9 番 (文字列を $ まで出す) を呼んで戻るだけの 23 バイト
    //    0100: LXI D,0109h / MVI C,9 / CALL 0005h / RET / "HELLO, CP/M" CR LF '$'
    const uint8_t prog[] = {0x11, 0x09, 0x01, 0x0E, 0x09, 0xCD, 0x05, 0x00, 0xC9,
                            'H',  'E',  'L',  'L',  'O',  ',',  ' ',  'C',  'P',  '/', 'M', 0x0D, 0x0A, '$'};
    for (unsigned i = 0; i < sizeof prog; ++i) sim_poke((uint16_t)(0x0100 + i), prog[i]);
    const Result s = command("SAVE 1 HELLO.COM");
    printf("SAVE: %ld T states, %ld reads, %ld writes\n", s.t_states, s.reads, s.writes);
    check(s.writes > 0, "SAVE 1 HELLO.COM writes sectors");

    const Result h = command("HELLO");
    printf("--- HELLO ---\n%s\n-------------\n", h.text.c_str());
    printf("HELLO: %ld T states, %ld sector reads, %ld chars out\n", h.t_states, h.reads, h.chars);
    check(h.text.find("HELLO, CP/M\r\n") != std::string::npos, "HELLO.COM runs and prints HELLO, CP/M");

    const Result d2 = command("DIR HELLO.COM");
    check(d2.text.find("HELLO    COM") != std::string::npos, "DIR HELLO.COM finds the new file");

    if (errors == 0) printf("PASS\n");
    else             printf("FAIL: %d\n", errors);
    return errors == 0 ? 0 : 1;
}
