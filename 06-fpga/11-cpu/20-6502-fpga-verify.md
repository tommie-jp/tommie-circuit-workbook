---
book: fpga
chapter: 11
id: 11-20
title: 6502 の FPGA を PC で確かめる — UART のピンの試験台と合成
tier: 200
source: 自作 (6502 の RTL は 11-7 と同じ cpu_65c02.v で、著作権表示を残せば商用でも使ってよい。ROM の中身はこのリポジトリに置かず、soft-fpga の harness.cpp から読み出して使う)
board: —
device: FPGA
---

# 11-20 6502 の FPGA を PC で確かめる — UART のピンの試験台と合成

> [!WARNING]
> **この題は実機で組んでいない。** 試験台は Verilator で、合成・配置配線・ビットストリーム作りは手元の PC で回した。
> 書き込み・USB シリアルでの対話・AD3 での測定はしていない。数はシミュレーションの値と道具の見積りである。

この題は実体配線図・Analog Discovery 3・ロジックアナライザの図を付けない。PC の中で確かめる題で、組む物が無いから
(組む回路と画面の図は 11-12)。

11-12 では、6502 のコア・RAM・ROM・PIA の代わりの UART (`pia_uart`) を 1 つの FPGA に入れる Verilog を書いた。
この題では、書き込む前にその Verilog を PC で確かめる。C++ で PC の側の UART を真似て、27 MHz・115 200 bps のまま
ピンの上の 1 ビットずつで wozmon と Integer BASIC と話させ、自分で合否を言わせる。続けて Tang Nano 9K の FPGA (GW1NR-9) 向けに
合成と配置配線を通し、規模と最高周波数の見積りを読む。

## UART のピンで話す試験

11-12 の `apple1_fpga` を最上位にし、27 MHz・115 200 bps のまま回す。C++ の側で PC の UART (送り手と受け手) を真似て、`rxd` と `txd` のピンを 1 ビットずつ動かす・読む。

```cpp
// 11-12 の試験台。apple1_fpga (65C02 + RAM + ROM + UART) を 27 MHz・115 200 bps のまま回し、
// PC の側の UART (送り・受け) をこの C++ で真似て、ピンの上の 1 ビットずつで話す。
//   1. リセットすると '\' と CR LF が届く
//   2. 小文字で打っても大文字になってエコーが返る。打ち込んだプログラムが HELLO を出す
//   3. E000R で Integer BASIC。PRINT 2+3 で 5
//   4. FOR を 1000 回まわす時間 (クロック数)
//   5. 1 字を送り終えてから、エコーの 1 字が始まるまでのクロック数
// 終わりに PASS か FAIL: n を出す。
#include <cstdint>
#include <cstdio>
#include <string>

#include "Vapple1_fpga.h"
#include "verilated.h"

static const double CLK_HZ = 27e6;
static const double BAUD = 115200.0;
static const double BIT = CLK_HZ / BAUD;  // 1 ビット = 234.375 クロック

static Vapple1_fpga* dut;
static uint64_t      cycle = 0;
static int           errors = 0;
static std::string   screen;        // FPGA から届いた字
static long          kbd_reads = 0, dsp_writes = 0, instructions = 0;
static uint64_t      kbd_at = 0, dsp_at = 0;   // 最後に KBD を読んだ・DSP に書いたクロック

// ---- PC の側の受け手: txd を見て字にする ----
static int      rx_state = 0;       // 0 = 待つ、1 = 受けている
static double   rx_next = 0;        // 次に読む時刻 (クロック)
static int      rx_bit = 0;
static uint8_t  rx_byte = 0;
static uint64_t rx_start_at = 0;    // 最後の字のスタートビットが始まったクロック

static void pc_receive() {
    const int line = dut->txd;
    if (rx_state == 0) {
        if (line == 0) {            // スタートビットの始まり
            rx_state = 1;
            rx_start_at = cycle;
            rx_next = cycle + BIT * 1.5;   // bit0 の真ん中
            rx_bit = 0;
            rx_byte = 0;
        }
    } else if (cycle >= (uint64_t)rx_next) {
        if (rx_bit < 8) {
            rx_byte |= (uint8_t)(line << rx_bit);
            ++rx_bit;
            rx_next += BIT;
        } else {                    // ストップビット
            if (line != 1) printf("framing error at cycle %llu\n", (unsigned long long)cycle);
            screen += (char)rx_byte;
            rx_state = 0;
        }
    }
}

// ---- PC の側の送り手: 字の列を rxd に 1 ビットずつ出す ----
static std::string tx_queue;
static double      tx_t0 = -1;      // 今送っている字のスタートビットの時刻
static uint64_t    tx_start_at = 0; // 最後の字のスタートビットが始まったクロック
static uint64_t    tx_end_at = 0;   // 最後の字のストップビットが終わったクロック

static void pc_send() {
    if (tx_t0 < 0) {
        if (tx_queue.empty()) { dut->rxd = 1; return; }
        tx_t0 = (double)cycle;
        tx_start_at = cycle;
    }
    const int k = (int)((cycle - tx_t0) / BIT);   // 何ビット目か (0 = スタート、9 = ストップ)
    const uint8_t c = (uint8_t)tx_queue[0];
    if (k == 0)      dut->rxd = 0;
    else if (k <= 8) dut->rxd = (c >> (k - 1)) & 1;
    else if (k == 9) dut->rxd = 1;
    else {                                         // 1 字送り終えた
        tx_queue.erase(0, 1);
        tx_end_at = cycle;
        tx_t0 = -1;
        dut->rxd = 1;
    }
}

static void tick() {
    pc_send();
    dut->clk = 0;
    dut->eval();
    dut->clk = 1;
    dut->eval();
    ++cycle;
    if (dut->kbd_stb) { ++kbd_reads; kbd_at = cycle; }
    if (dut->dsp_stb) { ++dsp_writes; dsp_at = cycle; }
    if (dut->sync) ++instructions;
    pc_receive();
}

static void check(bool ok, const char* what) {
    printf("%s %s\n", ok ? "ok" : "NG", what);
    if (!ok) ++errors;
}

// want が今から後に届くまで回す。届いたクロックを返す (届かなければ 0)
static uint64_t run_until(const std::string& want, uint64_t limit) {
    const size_t from = screen.size();
    for (uint64_t i = 0; i < limit; ++i) {
        tick();
        if (screen.find(want, from) != std::string::npos) return cycle;
    }
    return 0;
}

// 1 行を送り、エコーが済むまで待ってから CR を送り、prompt が届くまで回す。届いた字を返す
static std::string line(const std::string& s, const std::string& prompt, uint64_t* clocks = nullptr) {
    tx_queue += s;
    while (!tx_queue.empty()) tick();
    for (int i = 0; i < 20000; ++i) tick();       // 最後のエコーが届くまで
    screen.clear();
    tx_queue += '\r';
    while (!tx_queue.empty()) tick();
    const uint64_t cr_end = tx_end_at;
    const uint64_t got = run_until(prompt, 200000000);
    if (clocks) *clocks = got ? got - cr_end : 0;
    return screen;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    dut = new Vapple1_fpga;
    dut->rxd = 1;
    dut->rst = 1;
    for (int i = 0; i < 16; ++i) tick();
    dut->rst = 0;

    // 1. リセット直後
    const uint64_t prompt_at = run_until("\\\r\n", 1000000);
    printf("prompt at clock %llu (%.1f us)\n", (unsigned long long)prompt_at, prompt_at / 27.0);
    check(prompt_at > 0 && screen == "\\\r\n", "reset prints '\\' CR LF on the UART");

    // 5. エコーの遅れ: 'a' を 1 字送り、そのスタートビットから、返る 'A' のスタートビットまで
    screen.clear();
    tx_queue += "a";
    run_until("A", 100000);
    const uint64_t lag = rx_start_at - tx_start_at;
    printf("echo: 'a' start bit at %llu, 'A' start bit at %llu (+%llu clocks = %.2f us = %.2f bits)\n",
           (unsigned long long)tx_start_at, (unsigned long long)rx_start_at, (unsigned long long)lag,
           lag / 27.0, lag / BIT);
    printf("echo: KBD read at +%llu clocks, DSP write at +%llu clocks (from the start bit of 'a')\n",
           (unsigned long long)(kbd_at - tx_start_at), (unsigned long long)(dsp_at - tx_start_at));
    check(screen == "A", "lower-case 'a' comes back as 'A'");
    tx_queue += "\x1b";                           // ESC で行を捨てる
    run_until("\\\r\n", 1000000);

    // 2. 11-7 と同じプログラム (小文字で打つ)
    line("0300: a2 00 bd 10 03 f0 06 20 ef ff e8 d0 f5 4c 00 ff", "0300: 00\r\n");
    line("0310: c8 c5 cc cc cf 8d 00", "0310: 00\r\n");
    const std::string r = line("0300R", "\\\r\n");
    printf("--- 0300R ---\n%s-------------\n", r.c_str());
    check(r == "\r\n\r\n0300: A2HELLO\r\n\\\r\n", "0300R prints HELLO");

    // 3. Integer BASIC
    check(line("E000R", ">") == "\r\n\r\nE000: 4C\r\n>", "E000R prints '>'");
    uint64_t c = 0;
    const std::string p = line("print 2+3", ">", &c);
    printf("PRINT 2+3 -> %zu chars, %llu clocks from CR to '>'\n", p.size(), (unsigned long long)c);
    check(p == "\r\n5\r\n\r\n>", "PRINT 2+3 prints 5");

    // 4. FOR を 1000 回
    line("10 FOR I=1 TO 1000", ">");
    line("20 NEXT I", ">");
    line("30 END", ">");
    uint64_t loop = 0;
    const long i0 = instructions;
    const std::string run = line("RUN", ">", &loop);
    printf("RUN (FOR 1..1000): %llu clocks = %.2f ms at 27 MHz, %ld instructions\n",
           (unsigned long long)loop, loop / 27e3, instructions - i0);
    check(run == "\r\n\r\n>", "the loop ends and returns to '>'");
    line("10 FOR I=1 TO 2000", ">");
    uint64_t loop2 = 0;
    line("RUN", ">", &loop2);
    printf("RUN (FOR 1..2000): %llu clocks, per pass %.1f clocks\n", (unsigned long long)loop2,
           (double)(loop2 - loop) / 1000.0);
    // 測り始め (CR のストップビットの終わり) と UART の受けの刻みの位相で、1 ビット (234 クロック) ほど揺れる
    const long d = (long)(loop2 - loop) - 1260000;
    check(d > -300 && d < 300, "one pass of FOR/NEXT is 1260 clocks (the same as 11-8)");

    printf("KBD reads %ld, DSP writes %ld, total %llu clocks\n", kbd_reads, dsp_writes,
           (unsigned long long)cycle);
    if (errors == 0) printf("PASS\n");
    else             printf("FAIL: %d\n", errors);
    dut->final();
    delete dut;
    return errors == 0 ? 0 : 1;
}
```

```bash
H=<soft-fpga>/examples/04-6502/verilog/hoglet
verilator --lint-only -Wall lint.vlt --top-module top \
  top.v apple1_fpga.v pia_uart.v uart_tx.v uart_rx.v $H/cpu_65c02.v $H/ALU.v
verilator --cc --exe --build -j 8 -O3 -Wno-fatal -Wno-lint -Wno-style lint.vlt \
  --top-module apple1_fpga -GROM_HEX='"rom.hex"' \
  apple1_fpga.v pia_uart.v uart_tx.v uart_rx.v $H/cpu_65c02.v $H/ALU.v apple1_fpga_tb.cpp -o tb
./obj_dir/tb
```

`lint.vlt` は、借りたコアの警告を lint で見ないための設定 (置き場は `sim/12-apple1-fpga.vlt`)。自分で書いた 4 つのモジュールは `-Wall` で警告 0 件。

```text
`verilator_config
// 借りた 65C02 のコアの警告は見ない (自分の書いた所だけ -Wall で見る)
lint_off -file "*hoglet/*"
// コアは reset を 1 か所だけ非同期 (always @(posedge clk or posedge reset)) で使う。その知らせ
lint_off -rule SYNCASYNCNET
```

```text
prompt at clock 6988 (258.8 us)
ok reset prints '\' CR LF on the UART
echo: 'a' start bit at 6988, 'A' start bit at 9302 (+2314 clocks = 85.70 us = 9.87 bits)
echo: KBD read at +2291 clocks, DSP write at +2312 clocks (from the start bit of 'a')
ok lower-case 'a' comes back as 'A'
--- 0300R ---


0300: A2HELLO
\
-------------
ok 0300R prints HELLO
ok E000R prints '>'
PRINT 2+3 -> 8 chars, 31017 clocks from CR to '>'
ok PRINT 2+3 prints 5
RUN (FOR 1..1000): 1277284 clocks = 47.31 ms at 27 MHz, 385879 instructions
ok the loop ends and returns to '>'
RUN (FOR 1..2000): 2537270 clocks, per pass 1260.0 clocks
ok one pass of FOR/NEXT is 1260 clocks (the same as 11-8)
KBD reads 168, DSP writes 232, total 4683802 clocks
PASS
```

試験は全部 ok で `PASS` (468 万クロック、手元の PC で 0.2 秒ほど)。

- **wozmon と BASIC は 1 バイトも書き替えずに動いた**。11-7 と同じプログラムが `HELLO` を出し、`E000R` で `>`、小文字の `print 2+3` で `5` が出た
- `FOR` の 1 回は 1 260 クロックで、11-8 の soft-fpga と同じ。CPU の RTL が同じなので、クロック数も同じになる。27 MHz では 46.7 µs (計算値)
- `PRINT 2+3` の CR から `>` までは 31 017 クロック。11-8 の 17 356 クロックより 13 661 クロック長い。画面に出す 8 字を UART で送る間、CPU が DSP のビット 7 を見て待つため (1 字 10 ビット = 2 340 クロック)
- 1 字のエコーは、`a` のスタートビットから `A` のスタートビットまで 85.70 µs。そのうち 9.5 ビット (82.5 µs) は、`uart_rx` がストップビットの真ん中を読むまでの時間。
  そこから CPU が KBD を読み (84.85 µs)、ECHO で DSP に書き (85.63 µs)、2 クロック後に `A` を送り始める

## 合成と配置配線

```bash
yosys -p "read_verilog top.v apple1_fpga.v pia_uart.v uart_tx.v uart_rx.v cpu_65c02.v ALU.v; \
  rename ALU alu6502; chtype -map ALU alu6502 cpu_65c02; \
  synth_gowin -top top -json apple1.json; stat"
nextpnr-himbaechel --json apple1.json --write apple1_pnr.json --device GW1NR-LV9QN88PC6/I5 \
  --vopt family=GW1N-9C --vopt cst=apple1.cst --freq 27
gowin_pack -d GW1N-9C -o apple1.fs apple1_pnr.json
```

- **コアの `ALU` というモジュール名は、Gowin の基本セル `ALU` (桁上げの回路) と同じ名前**。そのまま `synth_gowin` に渡すと「`ALU` の定義が 2 つある」と止まる。
  読み込んだ後に `rename` でコアの側の名前を替え、`chtype` で `cpu_65c02` の中の呼び出しも替えてから合成する
- `rom.hex` は yosys を走らせる所に置く (`top.v` が `ROM_HEX("rom.hex")` で読む)

OSS CAD Suite の Yosys 0.70+16 と nextpnr-himbaechel 0.11.1-63 で数えた。

| 種類 | 数 | GW1NR-9 の中の割合 |
| --- | --- | --- |
| LUT (nextpnr の LUT4) | 1 443 | 8 640 の 17 % |
| フリップフロップ (DFF) | 219 | 6 480 の 3 % |
| 桁上げの回路 (ALU) | 120 | 1 % |
| ブロック RAM (BSRAM) | 8 (RAM 4・ROM 4) | 26 の 31 % |
| 分散 RAM (RAM16SDP4) | 2 (コアの A・X・Y・S) | 1 % 未満 |
| 入出力 (IOB) | 6 | 2 % |

| `--seed` | 最高周波数 (配置配線の後) | 27 MHz で |
| --- | --- | --- |
| 指定なし | 35.02 MHz | PASS |
| 1 | 33.07 MHz | PASS |
| 2 | 42.81 MHz | PASS |
| 3 | 35.92 MHz | PASS |

- 一番遅い道は、リセットのフリップフロップからコアの中の加算器を通って `ADD` のレジスタまで (`--seed` 指定なしで 28.56 ns、うち配線 12.67 ns)
- 最高周波数は配置の乱数 (`--seed`) で 33〜43 MHz とばらつく。一番悪い回でも 27 MHz に 2 割の余裕がある。8 KB の RAM を 32 KB (`RAM_AW` = 15) にすると、ブロック RAM は 20 個、最高周波数は 32.74 MHz (`--seed` 指定なしの 1 回) になった
- 6502 のコアだけで LUT の大半を使う。それでも GW1NR-9 の 2 割に満たないので、横にほかの回路 (7 セグ・VGA など) を足す余地がある

書き込むには `openFPGALoader -b tangnano9k apple1.fs` (8-4)。この題では `.fs` ができるところまでを確かめた。書き込みは未実行。

## 見るべき値

シミュレーションの値と道具の見積り。実機では測っていない。

| 項目 | 値 | どこで得たか |
| --- | --- | --- |
| 試験台 | 7 項目 ok、`PASS` | UART の試験 |
| リセットから `\` CR LF が届くまで | 6 988 クロック = 258.8 µs | UART の試験 |
| 1 字のエコー (スタートビットからスタートビット) | 2 314 クロック = 85.70 µs | UART の試験 |
| `FOR` の 1 回 | 1 260 クロック = 46.7 µs | UART の試験 (11-8 と同じ) |
| `PRINT 2+3` の CR から `>` まで | 31 017 クロック | UART の試験 |
| `FOR` 1000 回の `RUN` (CR から `>` まで) | 1 277 284 クロック = 47.3 ms | UART の試験 |
| 同じ 1000 回を実物の Apple-1 (1.023 MHz) で | 1.24 s | 11-8 |
| 最高周波数 (配置配線の見積り) | 33.1〜42.8 MHz | nextpnr (4 回) |
| LUT・FF・ブロック RAM | 1 443・219・8 | nextpnr |

## シミュレーションでの確かめ

Verilator 5.042、Yosys 0.33 と 0.70+16、nextpnr-himbaechel 0.11.1-63 で、本文のファイルを走らせた。
置き場は 11-12 の Verilog と同じ `sim/12-apple1-fpga*.v`・`sim/12-apple1-fpga.cst`・`sim/12-apple1-fpga.vlt` (`lint.vlt`)・`sim/12-apple1-fpga-tb.cpp`。
コアは soft-fpga の f89a885 のサブモジュール `verilog/hoglet` (03951de) の `cpu_65c02.v` と `ALU.v`。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| UART の試験 (`tb`) | 7 項目 ok、PASS | 同じ (0.16 秒) | 合った |
| リセットから `\`・エコーの遅れ | 6 988 クロック、2 314 クロック (KBD +2 291、DSP +2 312) | 同じ | 合った |
| `FOR` の 1 回 | 1 260 クロック | (2 537 270 − 1 277 284) ÷ 1000 = 1 259.99 | 合った (測り始めの位相で ±1 ビットの揺れ) |
| 合成 (Yosys 0.70+16) | (表のとおり) | LUT1 259・LUT2 204・LUT3 372・LUT4 472、MUX2_LUT5〜8 370・146・64・28、ALU 90、FF 207、SP 8、RAM16SDP4 2 (nextpnr は FF を 219、ALU を 120 と数える) | 補足 |
| 合成 (Yosys 0.33) | (本文に無い) | LUT 1 514 (605 + 232 + 230 + 447)、FF 207、ALU 90、SP 8、RAM16SDP4 2 | 補足 (版でブロック RAM の割り当ては同じ) |
| 配置配線 (`--freq 27`) | 33.1〜42.8 MHz、LUT4 1 443、DFF 219、ALU 120、BSRAM 8、IOB 6 | 35.02・33.07・42.81・35.92 MHz、すべて PASS | 合った |
| リセットを組み合わせ回路のまま出したとき | 30.0 MHz | 30.02 MHz (`--seed` 指定なし) | 合った |
| 32 KB の RAM | BSRAM 20、32.74 MHz | 同じ | 合った |
| `gowin_pack` | `.fs` ができる | できた (書き込みは未実行) | 合った |

確かめていない数: 実機への書き込み・USB シリアルでの対話・FPGA の中の実際の遅れ。

## 出典

- 自作。6502 の RTL の出所と条件は 11-7 (hoglet67/verilog-6502 の `cpu_65c02.v`)。Woz Monitor と Integer BASIC の出所と扱いは 11-7・11-8
- GW1NR-9 の LUT・フリップフロップ・ブロック RAM の数: nextpnr-himbaechel の `Device utilisation` と Sipeed の [Tang Nano 9K のページ](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html)
- 打ち方 (`--device`・`--vopt family`): [Apicula](https://github.com/YosysHQ/apicula) の README (8-4)
