---
book: fpga
chapter: 11
id: 11-1
title: TD4 の構成 — 4 ビットのレジスタ・加算器・ROM
tier: 100
source: 自作 (命令の決め方は asfdrwe の simpleTD4 (MIT) の TD4.v に合わせた)
board: —
device: WEB
---

# 11-1 TD4 の構成 — 4 ビットのレジスタ・加算器・ROM

この題は実体配線図と Analog Discovery 3 の図を付けない。ブラウザの中で動く題で、組む物が無いから。

5-8 では TD4 を 1 つの `TD4.v` のまま Pico 2 で動かした (命令表もそちら)。この題では同じ TD4 を**部品に分けて書き直し**、
CPU の部品 (6 種類と ROM) を見る。**足し算をする部品は加算器 1 つだけ**で、`MOV` も `OUT` も `JMP` もこの加算器を通って書き込まれる。

5-8 の `TD4.v` と同じ働きは Verilator で乱数のプログラム 4000 本で確かめ、soft-fpga の 01-counter に載せてブラウザで動かす。

## 構成

```plantuml
@startuml
left to right direction
skinparam shadowing false
skinparam defaultFontName "Noto Sans CJK JP"
skinparam rectangle {
  RoundCorner 6
}
title 図1 TD4 の部品と、1 クロックの間に値が通る道 (書き込み許可の線は省いた)

rectangle "PC\n(td4_pc)" as PC #FFF8E1
rectangle "ROM\n16 番地 × 8 ビット\n(td4_rom)" as ROM #E6F4EA
rectangle "命令デコーダ\n(td4_decode)" as DEC #E6F4EA
rectangle "A\n(td4_reg4)" as A #FFF8E1
rectangle "B\n(td4_reg4)" as B #FFF8E1
rectangle "IN\n(入力ポート)" as IN #FFFFFF
rectangle "データセレクタ\n4 → 1\n(td4_sel4)" as SEL #E6F4EA
rectangle "加算器\n4 ビット\n(td4_add4)" as ADD #E6F4EA
rectangle "キャリーフラグ\n(td4_cflag)" as C #FFF8E1
rectangle "OUT\n(td4_reg4)" as OUT #FFF8E1

PC --> ROM : 番地
ROM --> DEC : 上 4 ビット\n(オペコード)
ROM --> ADD : 下 4 ビット\n(即値 Im)
A --> SEL
B --> SEL
IN --> SEL
DEC --> SEL : どれを選ぶか
SEL --> ADD
ADD --> A : 結果
ADD --> B : 結果
ADD --> OUT : 結果
ADD --> PC : 結果 (跳び先)
ADD --> C : 桁上げ
C --> DEC
@enduml
```

![ブロック図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/11-cpu/plantuml/01-td4-architecture.svg)

黄色はクロックで値を覚える部品 (フリップフロップ)、緑は組み合わせ回路。

- **1 命令が 1 クロックで済むのは、読む・解く・足すが全部組み合わせ回路だから。** PC が変わると ROM → デコーダ → セレクタ → 加算器と値が流れ、
  次の立ち上がりで、デコーダが選んだレジスタ 1 つ (と PC・キャリーフラグ) が取り込む
- 加算器の出口は A・B・OUT・PC の全部につながり、どれに書くかを `load_*_n` が決める (書かれないレジスタは値を保つ)
- PC は書かれなければ 1 を足し、`JMP` と `JNC` のときだけ加算器の結果 (0 + Im = 跳び先) を取り込む
- セレクタの 4 番めは 0。`MOV A,Im` は「0 + Im を A へ」で、即値の命令も足し算で作る

| 部品 | Verilog | 中身 |
| --- | --- | --- |
| レジスタ A・B・OUT | `td4_reg4` × 3 | 4 ビット。`load_n` が 0 のときだけ取り込む |
| プログラムカウンタ | `td4_pc` | 4 ビット。書かれなければ +1 |
| キャリーフラグ | `td4_cflag` | 1 ビット。**負論理** (1 で桁上げ無し)。毎クロック書く |
| データセレクタ | `td4_sel4` | A・B・IN・0 から 1 つ |
| 加算器 | `td4_add4` | 4 ビット + 即値 → 和と桁上げ |
| 命令デコーダ | `td4_decode` | オペコードとキャリーフラグ → 選ぶ入力 2 ビット、書く先 4 本 |
| ROM | `td4_rom` | 16 番地 × 8 ビット |

本の TD4 (『CPU の創りかた』) は部品ごとに 74 シリーズの IC を当てて組む (IC との対応は 11-4)。

## Verilog

`examples/01-counter/verilog/counter.v` の中身を次に置き換える。9 つのモジュールを 1 ファイルに入れ、最上位の `counter` は
01-counter と同じポート (`clk` `rst` `count[7:0]`)。4-3 と同じく、ハーネスと画面は替えない。

```verilog
// 11-1 TD4 を部品に分けて書く。5-8 の TD4.v と同じ働きを、
// レジスタ・PC・データセレクタ・加算器・命令デコーダ・ROM の 6 つのモジュールに分けた。
// soft-fpga の 01-counter に載せるため、最上位は counter (clk・rst・count[7:0]) の形にしてある。
// TD4 の命令の決め方は asfdrwe/simpleTD4 (MIT) の TD4.v に合わせた。
// 1 つのファイルに 9 つのモジュールを置くので、ファイル名とモジュール名の食い違いの警告を切る。
/* verilator lint_off DECLFILENAME */

// 4 ビットのレジスタ。load_n が 0 のときだけ d を取り込む (A・B・OUT に使う)
module td4_reg4 (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       load_n,
    input  wire [3:0] d,
    output reg  [3:0] q
);
    always @(posedge clk or negedge reset_n)
        if (!reset_n)     q <= 4'd0;
        else if (!load_n) q <= d;
endmodule

// プログラムカウンタ。load_n が 0 なら d を取り込み、1 なら 1 を足す
module td4_pc (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       load_n,
    input  wire [3:0] d,
    output reg  [3:0] q
);
    always @(posedge clk or negedge reset_n)
        if (!reset_n)     q <= 4'd0;
        else if (!load_n) q <= d;
        else              q <= q + 4'd1;
endmodule

// キャリーフラグ。負論理で持つ (c_n が 1 なら桁上げ無し)。毎クロック書き直す
module td4_cflag (
    input  wire clk,
    input  wire reset_n,
    input  wire carry,
    output reg  c_n
);
    always @(posedge clk or negedge reset_n)
        if (!reset_n) c_n <= 1'b1;
        else          c_n <= ~carry;
endmodule

// データセレクタ。4 つの入力から 1 つを選ぶ (3 番は 0 につないである)
module td4_sel4 (
    input  wire [1:0] sel,
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [3:0] in_port,
    output wire [3:0] y
);
    assign y = (sel == 2'd0) ? a       :
               (sel == 2'd1) ? b       :
               (sel == 2'd2) ? in_port :
                               4'd0;
endmodule

// 4 ビットの加算器。片方は即値 im
module td4_add4 (
    input  wire [3:0] x,
    input  wire [3:0] im,
    output wire [3:0] s,
    output wire       carry
);
    assign {carry, s} = x + im;
endmodule

// 命令デコーダ。上 4 ビット (オペコード) と c_n から、選ぶ入力と書く先を決める
module td4_decode (
    input  wire [3:0] opc,
    input  wire       c_n,
    output wire [1:0] sel,
    output wire       load_a_n,
    output wire       load_b_n,
    output wire       load_out_n,
    output wire       load_pc_n
);
    wire [1:0] dst = opc[3:2];          // 書く先: 00 A、01 B、10 OUT、11 PC
    assign sel = (dst == 2'b11) ? 2'b11 : opc[1:0];
    assign load_a_n   = ~(dst == 2'b00);
    assign load_b_n   = ~(dst == 2'b01);
    assign load_out_n = ~(dst == 2'b10);
    assign load_pc_n  = ~(dst == 2'b11 && (opc[0] || c_n));   // JMP か、桁上げ無しの JNC
endmodule

// CPU の本体。ROM は外に置く (番地 rom_addr を出し、命令 rom_data を受ける)
module td4_core (
    input  wire       clk,
    input  wire       reset_n,
    input  wire [3:0] in_port,
    output wire [3:0] rom_addr,
    input  wire [7:0] rom_data,
    output wire [3:0] out_port,
    output wire [3:0] reg_a,      // 観測用
    output wire [3:0] reg_b,      // 観測用
    output wire       c_n         // 観測用 (負論理の桁上げ)
);
    wire [1:0] sel;
    wire       load_a_n, load_b_n, load_out_n, load_pc_n;
    wire [3:0] alu_in, alu_out;
    wire       carry;

    td4_decode u_dec (.opc(rom_data[7:4]), .c_n(c_n), .sel(sel),
                      .load_a_n(load_a_n), .load_b_n(load_b_n),
                      .load_out_n(load_out_n), .load_pc_n(load_pc_n));
    td4_sel4   u_sel (.sel(sel), .a(reg_a), .b(reg_b), .in_port(in_port), .y(alu_in));
    td4_add4   u_add (.x(alu_in), .im(rom_data[3:0]), .s(alu_out), .carry(carry));
    td4_reg4   u_a   (.clk(clk), .reset_n(reset_n), .load_n(load_a_n),   .d(alu_out), .q(reg_a));
    td4_reg4   u_b   (.clk(clk), .reset_n(reset_n), .load_n(load_b_n),   .d(alu_out), .q(reg_b));
    td4_reg4   u_out (.clk(clk), .reset_n(reset_n), .load_n(load_out_n), .d(alu_out), .q(out_port));
    td4_pc     u_pc  (.clk(clk), .reset_n(reset_n), .load_n(load_pc_n),  .d(alu_out), .q(rom_addr));
    td4_cflag  u_c   (.clk(clk), .reset_n(reset_n), .carry(carry), .c_n(c_n));
endmodule

// 16 番地 × 8 ビットの ROM。この題のプログラム: A を 1 ずつ増やして OUT に出す
module td4_rom (
    input  wire [3:0] addr,
    output reg  [7:0] data
);
    always @(*)
        case (addr)
            4'h0:    data = 8'b0000_0001;  // ADD A,0001   A <- A + 1
            4'h1:    data = 8'b0100_0000;  // MOV B,A      B <- A
            4'h2:    data = 8'b1001_0000;  // OUT B        OUT <- B
            4'h3:    data = 8'b1111_0000;  // JMP 0000
            default: data = 8'b0000_0000;  // ADD A,0000 (何もしない)
        endcase
endmodule

// soft-fpga の 01-counter に合わせた最上位。count の上 4 ビットが PC、下 4 ビットが OUT
module counter (
    input  wire       clk,
    input  wire       rst,
    output wire [7:0] count
);
    wire [3:0] pc, op_out, a, b;
    wire [7:0] code;
    wire       c_n;

    td4_core u_cpu (.clk(clk), .reset_n(~rst), .in_port(4'd0),
                    .rom_addr(pc), .rom_data(code), .out_port(op_out),
                    .reg_a(a), .reg_b(b), .c_n(c_n));
    td4_rom  u_rom (.addr(pc), .data(code));

    assign count = {pc, op_out};

    wire unused = &{1'b0, a, b, c_n};   // 観測用の出力はここでは使わない
endmodule
```

- `td4_core` は、試験で乱数のプログラムを与えるため ROM を外に出した。`counter` が `td4_core` と `td4_rom` をつなぐ
- `reg_a` `reg_b` `c_n` は試験台が読む観測用の出力。`counter` では `unused` にまとめて lint を黙らせる (Verilator は `unused` を含む名前を言わない)
- `counter` の `rst` は 1 でリセット (01-counter のハーネス)、TD4 の部品は 5-8 と同じ `reset_n` (0 でリセット) なので `~rst` を渡す
- 入力ポートは 0 (この題のプログラムは `IN` を使わない)

### デコーダの読み方

5-8 の命令表の「書く先」と「足す元」は、オペコードの 4 ビットを 2 ビットずつに分けた物だ。

| オペコードのビット | 意味 | 値 |
| --- | --- | --- |
| 3〜2 (`dst`) | 書く先 | 00 A、01 B、10 OUT、11 PC |
| 1〜0 | 足す元 (セレクタ) | 00 A、01 B、10 IN、11 0。**書く先が PC なら 11 (0)** |
| 0 (書く先が PC のとき) | 跳び方 | 1 なら必ず跳ぶ (`JMP`)、0 ならキャリーフラグが 1 (桁上げ無し) のときだけ (`JNC`) |

`td4_decode` の 6 行はこの表そのもの。5-8 の表に無い 1000・1010・1100・1101 は、このデコーダでは次の働きになる (試験台で確かめた。A = 5、IN = 3、Im = 1)。

| オペコード | ビットの決めで読むと | 動かした結果 |
| --- | --- | --- |
| 1000 | OUT ← A + Im | OUT = 6 |
| 1010 | OUT ← IN + Im | OUT = 4 |
| 1100 | 書く先 PC、跳び方 0 → `JNC` と同じ | 桁上げ無しなら PC = 1、有りなら次の番地 |
| 1101 | 書く先 PC、跳び方 1 → `JMP` と同じ | 桁上げに関わらず PC = 1 |

1000 は「A を OUT へ出す」命令に使えるが、**このデコーダの書き方で決まった働き**で、本の TD4 で同じとは限らない (11-4)。命令を足すのは 11-5。

### この題のプログラム

`td4_rom` の 4 命令は A を 1 ずつ増やして OUT に出す。

| 番地 | 機械語 | 命令 | セレクタ → 加算器 → 書く先 |
| --- | --- | --- | --- |
| 0 | 0000 0001 | ADD A,0001 | A + 1 → A |
| 1 | 0100 0000 | MOV B,A | A + 0 → B |
| 2 | 1001 0000 | OUT B | B + 0 → OUT |
| 3 | 1111 0000 | JMP 0000 | 0 + 0 → PC |

4 クロックで 1 巡し、OUT は 4 クロックごとに 1 増える (F から 0 に戻るまで 64 クロック)。

## 規模

Yosys 0.33 で汎用のゲートへ合成した (`synth -top counter`、階層を残して `stat`)。

| 部品 | フリップフロップ | ゲート (`$_AND_` `$_MUX_` など) |
| --- | --- | --- |
| `td4_reg4` (1 個ぶん) | 4 (`$_DFFE_PN0N_`、書き込み許可つき) | 0 |
| `td4_pc` | 4 (`$_DFF_PN0_`) | 10 (+1 と `$_MUX_` 4 個) |
| `td4_cflag` | 1 (`$_DFF_PN1_`、リセットで 1) | 1 |
| `td4_sel4` | 0 | 15 (`$_MUX_` 8 個ほか) |
| `td4_add4` | 0 | 20 |
| `td4_decode` | 0 | 8 |
| `td4_rom` | 0 | 15 (この題のプログラム) |
| `counter` | 0 | 1 (`rst` の反転) |

全部でフリップフロップ 4 × 3 + 4 + 1 = **17 個**、ゲート 70 個ほど。ゲートの多くは加算器とセレクタにあり、ROM は定数なのでゲートになる。

## 手順

1. soft-fpga を取ってくる (0-2)。`examples/01-counter/verilog/counter.v` を上の中身に置き換える
2. lint を掛ける (`verilator --lint-only -Wall examples/01-counter/verilog/counter.v`)
3. 4-3 のコマンドでビルドし、Web サーバを立てて `http://localhost:8081/` を開き、Run を押す。
   `count` の 16 進 2 桁の上の桁が PC (`b7`〜`b4`)、下の桁が OUT

PC 用の自己検査 (`cxx/main_linux.cpp`) は 4-3 と同じく FAIL を出す (差し替えが効いた印)。戻すには `counter.v` を `git checkout` してビルドし直す。

## 画面に見えるはずのもの

1 クロックを 1 ms と置いて、リセットのあとの 16 クロックを描く (PC と OUT は `count` の 4 ビットずつ)。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図2 PC は 0→1→2→3 を回り、OUT は PC が 3 になる立ち上がりで 1 増える
device: generic
window: 16ms
signals:
  CLK: dio0 clock 1kHz
  P: counter bits 4 on CLK rising sequence 1 2 3 0 repeat
  O: counter bits 4 on CLK rising sequence 0 0 1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6
buses:
  PC: P3..P0 hex
  OUT: O3..O0 hex
cursors: [2.5ms, 6.5ms]
trigger: CLK rising at 0s
style:
  width: 1600
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/11-cpu/logic/01-td4-architecture.svg)

- PC は立ち上がりのたびに 1 進み、3 の次は `JMP 0000` で 0 に戻る
- OUT は 2 番地の `OUT B` を実行した立ち上がり (PC が 3 になる所) で変わる
- カーソルの間隔 4 ms (4 クロック) が 1 巡で、OUT は 1 から 2 に進む

## 見るべき値

soft-fpga f89a885 (2026-10-13) の 01-counter に差し替えて `sfa-dev-wasm:local` (Verilator 5.048・Emscripten 5.0.7) でビルドし、Playwright の Chromium で `step()` を呼んで読んだ。

| 見る所 | 値 | どこで確かめたか |
| --- | --- | --- |
| lint (`-Wall`) | 警告なし | Verilator |
| 部品に分けた TD4 と 5-8 の命令表 | 乱数のプログラム 2000 本 × 200 クロックで食い違い 0 | PC の Verilator |
| 部品に分けた TD4 と 5-8 の `TD4.v` | プログラム A の 100 クロックで PC・OUT の食い違い 0 | PC の Verilator |
| ブラウザの `count` (リセットのあと 26 サンプル) | `00 00 10 20 31 01 11 21 32 02 12 22 33 03 13 23 34 04 14 24 35 05 15 25 36 06` | Chromium |
| OUT が F から 0 に戻るクロック | 63 クロック目 (OUT は 4 × k − 1 クロック目に k) | PC で harness.cpp |
| フリップフロップの数 | 17 | Yosys 0.33 で合成 |

## シミュレーションでの確かめ (対象外を含む)

手元の Verilator 5.042 で `bash sim/01-td4-architecture-run.sh` を回した。`sim/01-td4-architecture.v` (本文の `counter.v`) と 5-8 の `sim/08-td4.v` を
試験台 `sim/01-td4-architecture-tb.cpp` に link し、1 クロックごとに PC・A・B・OUT・キャリーを次の 3 つと比べる。

- **命令表の模型**: 5-8 の 12 命令を C++ で書いた物。乱数のプログラムは 12 命令だけ (「Im = 0」の命令は Im を 0)。入力ポートも毎クロック乱数
- **ビットの決めの模型**: 「デコーダの読み方」の表を C++ で書いた物。乱数のプログラムは 256 通りのオペコード全部
- **5-8 の `TD4.v`**: 中のプログラム A と同じ 16 バイトを `td4_core` に外から与えて並べる

画面の側は soft-fpga の `harness.cpp` を `counter` と link し、ブラウザと同じ `step()` を 80 回呼んでリングバッファを読んだ
(`sim/01-td4-architecture-harness-tb.cpp`。期待値は命令表どおりに数える)。

```text
PASS 命令表の模型 (12 命令の乱数のプログラム 2000 本 x 200 クロック): 食い違い 0
PASS ビットの決めの模型 (256 通りの乱数のプログラム 2000 本 x 200 クロック): 食い違い 0
PASS 5-8 の TD4.v とプログラム A を 100 クロック並べる: 食い違い 0
PASS op=81 桁上げ=0: A 5->5  OUT 0->6  PC 3->4
PASS op=A1 桁上げ=0: A 5->5  OUT 0->4  PC 3->4
PASS op=C1 桁上げ=0: A 5->5  OUT 0->0  PC 3->1
PASS op=C1 桁上げ=1: A 4->4  OUT 0->0  PC 3->4
PASS op=D1 桁上げ=1: A 4->4  OUT 0->0  PC 3->1
ALL PASS
count (16 進、step 1 から): 10 20 31 01 11 21 32 02 12 22 33 03 13 23 34 04 14 24 35 05 15 25 36 06 ...
PASS step 1〜80 の count が命令表の並びと一致 (食い違い 0)
```

(未定義のオペコードは 8 行のうち 5 行を載せた。残りの 81・A1 の桁上げ有り、D1 の桁上げ無しも PASS。)

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint (`-Wall`、最上位 `counter` と `td4_core`) | 警告なし | 同じ | 合った |
| 命令表の模型との食い違い | 0 | 0 (40 万クロック) | 合った |
| ビットの決めの模型との食い違い | 0 | 0 (40 万クロック) | 合った |
| 5-8 の `TD4.v` との食い違い | 0 | 0 (100 クロック) | 合った |
| 1000・1010・1100・1101 | 表のとおり | 8 通りとも PASS | 合った |
| 画面の `count` の並び | `10 20 31 01 …` | 80 クロック一致 | 合った |
| ブラウザでの `count` | 同じ並び | Chromium で 26 サンプル同じ | 合った |
| 図2 の sequence | `count` の上と下の 4 ビット | 16 クロック一致 | 合った |
| フリップフロップ 17 個・ゲート数 | 「規模」の表 | Yosys 0.33 の `stat` | 合った |

## 出典

- [simpleTD4](https://github.com/asfdrwe/simpleTD4) (asfdrwe、MIT) — 命令のビットの決め方 (書く先と足す元、負論理のキャリーフラグ)。部品に分けた Verilog は自作
- [Soft-FPGA-TD4](https://github.com/tommie-jp/Soft-FPGA-TD4) — 5-8 の `TD4.v`
- [tommie-jp/soft-fpga](https://github.com/tommie-jp/soft-fpga) の `examples/01-counter` — 差し替え先
- TD4 そのものは、渡波郁『CPU の創りかた』(毎日コミュニケーションズ、2003) の CPU
