---
book: fpga
chapter: 11
id: 11-2
title: TD4 の命令を 1 つずつ波形で追う
tier: 100
source: 自作 (命令の決め方は asfdrwe の simpleTD4 (MIT) の TD4.v に合わせた)
board: —
device: WEB
---

# 11-2 TD4 の命令を 1 つずつ波形で追う

この題は実体配線図と Analog Discovery 3 の図を付けない。ブラウザの中で動く題で、組む物が無いから。

11-1 では、TD4 を部品に分けて、PC と OUT だけをブラウザで見た。この題では、**A・B・キャリーフラグ・いまの命令**も画面に出し、
12 種類の命令を 1 つずつ波形で追う。12 種類を全部 1 回は通る 15 命令のプログラムを書き、1 クロックごとに何が起きるかを表と波形で読む。

波形を読むときの決まりは 1 つだけ。

- `op` のレーンに見えている命令は、**その 1 クロックの間に計算され、次の立ち上がりで結果が書き込まれる**。
  だから、ある命令の結果 (A・B・OUT・PC・キャリー) は、`op` がその命令から次の命令に替わるのと同じ立ち上がりで変わる

TD4 の命令表は 5-8、部品の働きは 11-1 のとおり。

## 走らせるプログラム

| 番地 | 機械語 | 命令 | ねらい |
| --- | --- | --- | --- |
| 0 | 0011 0101 | MOV A,0101 | 即値を A へ (0 + Im) |
| 1 | 0100 0000 | MOV B,A | A を B へ (A + 0) |
| 2 | 0000 0011 | ADD A,0011 | 桁上げの出ない足し算 |
| 3 | 0101 1100 | ADD B,1100 | **桁上げの出る**足し算 (5 + 12 = 17) |
| 4 | 1110 0000 | JNC 0000 | 直前に桁上げがあったので**跳ばない** |
| 5 | 0010 0000 | IN A | 入力ポートを A へ |
| 6 | 0001 0000 | MOV A,B | B を A へ |
| 7 | 0110 0000 | IN B | 入力ポートを B へ |
| 8 | 1001 0000 | OUT B | B を OUT へ |
| 9 | 0111 1001 | MOV B,1001 | 即値を B へ |
| A | 1011 0110 | OUT 0110 | 即値を OUT へ |
| B | 0011 1110 | MOV A,1110 | A を 14 にしておく |
| C | 0000 0001 | ADD A,0001 | 14 + 1 = 15。桁上げは出ない |
| D | 1110 1111 | JNC 1111 | 直前に桁上げが無かったので**跳ぶ** (E 番地を跳び越す) |
| E | 1011 1111 | OUT 1111 | 実行されないはずの命令 |
| F | 1111 0000 | JMP 0000 | 頭へ戻る |

入力ポートは 1010 (10) につないでおく。15 クロックで 1 巡する (0〜D の 14 命令と F の 1 命令)。E 番地は一度も実行されない。

## Verilog

11-1 の `counter.v` のうち、`td4_rom` と `counter` の 2 つのモジュールを次に替える。`td4_core` までの 7 つは 11-1 のまま。

```verilog
// 16 番地 × 8 ビットの ROM。12 種類の命令を全部 1 回は通る、15 クロックで 1 巡のプログラム
module td4_rom (
    input  wire [3:0] addr,
    output reg  [7:0] data
);
    always @(*)
        case (addr)
            4'h0: data = 8'b0011_0101;  // MOV A,0101   A <- 5
            4'h1: data = 8'b0100_0000;  // MOV B,A      B <- A
            4'h2: data = 8'b0000_0011;  // ADD A,0011   A <- A + 3
            4'h3: data = 8'b0101_1100;  // ADD B,1100   B <- B + 12 (桁上げが出る)
            4'h4: data = 8'b1110_0000;  // JNC 0000     桁上げがあったので跳ばない
            4'h5: data = 8'b0010_0000;  // IN  A        A <- IN
            4'h6: data = 8'b0001_0000;  // MOV A,B      A <- B
            4'h7: data = 8'b0110_0000;  // IN  B        B <- IN
            4'h8: data = 8'b1001_0000;  // OUT B        OUT <- B
            4'h9: data = 8'b0111_1001;  // MOV B,1001   B <- 9
            4'hA: data = 8'b1011_0110;  // OUT 0110     OUT <- 6
            4'hB: data = 8'b0011_1110;  // MOV A,1110   A <- 14
            4'hC: data = 8'b0000_0001;  // ADD A,0001   A <- A + 1 (桁上げ無し)
            4'hD: data = 8'b1110_1111;  // JNC 1111     桁上げが無いので跳ぶ
            4'hE: data = 8'b1011_1111;  // OUT 1111     (跳び越されて実行されない)
            4'hF: data = 8'b1111_0000;  // JMP 0000
        endcase
endmodule

// soft-fpga の 01-counter に合わせた最上位。count = {PC, OUT} は 11-1 と同じ。
// 中を見るための出力 (A・B・命令・桁上げ) を足した。入力ポートは 1010 につないでおく
module counter (
    input  wire       clk,
    input  wire       rst,
    output wire [7:0] count,
    output wire [3:0] o_a,
    output wire [3:0] o_b,
    output wire [7:0] o_op,
    output wire       o_c
);
    localparam [3:0] IN = 4'b1010;
    wire [3:0] pc, op_out;
    wire       c_n;

    td4_core u_cpu (.clk(clk), .reset_n(~rst), .in_port(IN),
                    .rom_addr(pc), .rom_data(o_op), .out_port(op_out),
                    .reg_a(o_a), .reg_b(o_b), .c_n(c_n));
    td4_rom  u_rom (.addr(pc), .data(o_op));

    assign count = {pc, op_out};
    assign o_c   = ~c_n;               // 正論理に直して出す (1 で桁上げあり)
endmodule
```

- 16 番地を全部書いたので、`case` に `default` は要らない (lint も言わない)
- 足した出力は `o_a` `o_b` `o_op` `o_c` の 4 本。11-1 で観測用に用意しておいた `td4_core` の `reg_a` `reg_b` `c_n` と、ROM の出口をそのまま出す
- キャリーフラグは TD4 の中では負論理 (1 で桁上げ無し)。画面で読みやすいように、`o_c` では正論理 (1 で桁上げあり) に直した

ブラウザの画面に A・B・`op`・C のレーンを出す直し (ハーネスと `js/sft-counter-la-defs.js`) と、1 クロックずつ進める手順は 11-19 に分けた。

## 1 クロックごとの表

リセットのあとの 16 クロック。「加算器」は、セレクタが選んだ値 x と即値 Im の足し算で、結果の 5 ビットめが桁上げ。
「後の」は、その立ち上がりで書き込まれたあとの値 (画面のレーンでは、その立ち上がりの右側の値)。

| クロック | 番地 | 命令 | 加算器 x + Im = 結果 | 書く先 | 後の PC | 後の A | 後の B | 後の OUT | 後の C |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 0 | MOV A,0101 | 0 + 5 = 05 | A | 1 | 5 | 0 | 0 | 0 |
| 2 | 1 | MOV B,A | 5 + 0 = 05 | B | 2 | 5 | 5 | 0 | 0 |
| 3 | 2 | ADD A,0011 | 5 + 3 = 08 | A | 3 | 8 | 5 | 0 | 0 |
| 4 | 3 | ADD B,1100 | 5 + C = **11** | B | 4 | 8 | **1** | 0 | **1** |
| 5 | 4 | JNC 0000 | 0 + 0 = 00 | (PC。C = 1 なので書かない) | **5** | 8 | 1 | 0 | 0 |
| 6 | 5 | IN A | A + 0 = 0A | A | 6 | A | 1 | 0 | 0 |
| 7 | 6 | MOV A,B | 1 + 0 = 01 | A | 7 | 1 | 1 | 0 | 0 |
| 8 | 7 | IN B | A + 0 = 0A | B | 8 | 1 | A | 0 | 0 |
| 9 | 8 | OUT B | A + 0 = 0A | OUT | 9 | 1 | A | A | 0 |
| 10 | 9 | MOV B,1001 | 0 + 9 = 09 | B | A | 1 | 9 | A | 0 |
| 11 | A | OUT 0110 | 0 + 6 = 06 | OUT | B | 1 | 9 | 6 | 0 |
| 12 | B | MOV A,1110 | 0 + E = 0E | A | C | E | 9 | 6 | 0 |
| 13 | C | ADD A,0001 | E + 1 = 0F | A | D | F | 9 | 6 | 0 |
| 14 | D | JNC 1111 | 0 + F = 0F | PC (C = 0 なので書く) | **F** | F | 9 | 6 | 0 |
| 15 | F | JMP 0000 | 0 + 0 = 00 | PC | **0** | F | 9 | 6 | 0 |
| 16 | 0 | MOV A,0101 | 0 + 5 = 05 | A | 1 | 5 | 9 | 6 | 0 |

読みどころ。

- **キャリーフラグは毎クロック書き直される。** クロック 4 の `ADD B,1100` で 1 になり、次のクロック 5 の `JNC` (0 + 0 で桁上げ無し) で 0 に戻る。
  `JNC` が見るのは、自分の 1 つ前の命令が残したキャリーフラグ。間に別の命令を挟むと、その命令の足し算で上書きされる
- **跳ばない `JNC` (クロック 5) は、何もしない命令と同じ。** 加算器の結果 (跳び先の 0) は捨てられ、PC は 4 → 5 と普通に進む
- **跳ぶ `JNC` (クロック 14)** は PC に 0 + F = F を書く。D の次が E ではなく F になり、E 番地の `OUT 1111` は実行されない。OUT は 6 のまま
- **`MOV` と `IN` も足し算。** `MOV A,B` は B + 0、`IN A` は IN + 0、`MOV A,1110` は 0 + E。加算器は 1 つで、セレクタが何を足すかを替えている
- 4 ビットの足し算は 16 であふれる。5 + 12 = 17 は、B に 1 (17 − 16) が残り、16 の分が桁上げになる

## 画面に見えるはずのもの

1 クロックを 1 ms と置いて描く。時刻 0 はリセット中の 2 つめの立ち上がり (ハーネスの 2 つめのリセットのサンプル) で、PC = 0、命令は 35 (0 番地の `MOV A,0101`) が見えている。
1 ms から 16 ms の立ち上がりが、上の表のクロック 1〜16。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図1 PC・命令・桁上げ — C はクロック 4 の ADD で 1 になり、次の JNC で 0 に戻る
device: generic
window: 17ms
signals:
  CLK: dio0 clock 1kHz
  P: counter bits 4 on CLK rising sequence 0 1 2 3 4 5 6 7 8 9 10 11 12 13 15 0 1
  OPC: counter bits 4 on CLK rising sequence 3 4 0 5 14 2 1 6 9 7 11 3 0 14 15 3 4
  IMM: counter bits 4 on CLK rising sequence 5 0 3 12 0 0 0 0 0 9 6 14 1 15 0 5 0
  C: edges 0s=0 4ms=1 5ms=0
buses:
  PC: P3..P0 hex
  opcode: OPC3..OPC0 hex
  Im: IMM3..IMM0 hex
cursors: [4.5ms, 13.5ms]
trigger: CLK rising at 0s
style:
  width: 1600
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/11-cpu/logic/02-td4-trace-1.svg)

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図2 A・B・OUT — 結果は、op がその命令から次の命令へ替わる立ち上がりで書き込まれる
device: generic
window: 17ms
signals:
  CLK: dio0 clock 1kHz
  RA: counter bits 4 on CLK rising sequence 0 5 5 8 8 8 10 1 1 1 1 1 14 15 15 15 5
  RB: counter bits 4 on CLK rising sequence 0 0 5 5 1 1 1 1 10 10 9 9 9 9 9 9 9
  RO: counter bits 4 on CLK rising sequence 0 0 0 0 0 0 0 0 0 10 10 6 6 6 6 6 6
buses:
  A: RA3..RA0 hex
  B: RB3..RB0 hex
  OUT: RO3..RO0 hex
cursors: [4.5ms, 13.5ms]
trigger: CLK rising at 0s
style:
  width: 1600
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/11-cpu/logic/02-td4-trace-2.svg)

- 図1 では命令を上 4 ビット (`opcode`) と下 4 ビット (`Im`) の 2 本のバスに分けた。8 ビットの 16 進 (2 桁) は、1 クロックの幅に収まらないため
- 図1 の X1 (4.5 ms) では `opcode` = E・`Im` = 0 (`JNC 0000`) で、C = 1。だから 5 ms の立ち上がりで PC は 0 ではなく 5 へ進む
- 図1 の X2 (13.5 ms) では `opcode` = E・`Im` = F (`JNC 1111`) で、C = 0。だから 14 ms の立ち上がりで PC は E ではなく F へ跳ぶ
- 図2 の A は 6 ms で A (IN)、7 ms で 1 (B のコピー) に変わる。どちらも 1 クロック前の命令 (20 の `IN A` と 10 の `MOV A,B`) の結果
- 14 ms から 15 ms の間は命令が F0 (`JMP 0000`) で、15 ms の立ち上がりで PC が 0 に戻る。A・B・OUT は変わらない。16 ms の立ち上がりで `MOV A,0101` が A を 5 にし、2 巡めが進む

## 見るべき値

soft-fpga f89a885 (2026-10-13) の 01-counter に本文の Verilog と 11-19 の 2 か所の直しを入れ、`sfa-dev-wasm:local` (Verilator 5.048・Emscripten 5.0.7) でビルドして、
Playwright の Chromium で `step()` を 16 回呼んでリングバッファを読んだ (画面のレーンとリングバッファの値は 11-19)。

| 見る所 | 値 | 種類 |
| --- | --- | --- |
| lint (`-Wall`) | 警告なし | 動かして確かめた |
| 16 クロックの PC・A・B・OUT・C・`op` | 上の表のとおり | 動かして確かめた (Chromium と PC の Verilator) |
| C が 1 になるクロック (1 巡の中で) | 4 (`ADD B,1100` の 5 + 12) だけ | 動かして確かめた |
| 跳ばない `JNC` (クロック 5) のあとの PC | 5 | 動かして確かめた |
| 跳ぶ `JNC` (クロック 14) のあとの PC | F (E 番地を跳び越す) | 動かして確かめた |
| E 番地を実行した回数 (45 クロック) | 0 | 動かして確かめた (PC の Verilator) |
| 1 巡 | 15 クロック (PC が 0 に戻るのは 15・30・45 クロック目) | 動かして確かめた (PC の Verilator) |

## シミュレーションでの確かめ (対象外を含む)

手元の Verilator 5.042 で回した。試験は `bash sim/02-td4-trace-run.sh` で、次の 3 つを行う。

1. `sim/02-td4-trace.v` (本文の `counter.v`) の `td4_core` までが、11-1 の `sim/01-td4-architecture.v` と 1 行も違わないかを `diff` で確かめる
2. lint を掛ける
3. 11-19 の直しを入れた `harness.cpp` (`sim/02-td4-trace-harness.cpp`) と link し、ブラウザと同じ `step()` を 45 回呼んでリングバッファを読む (`sim/02-td4-trace-tb.cpp`)。
   1 クロックごとに、5-8 の命令表を C++ で書いた模型と、PC・A・B・OUT・C・次の命令を比べる。本文の表は、この試験台が出した表を写した物

```text
PASS td4_core までは 11-1 と同じ
番地 E を実行した回数: 0
PC が 0 に戻る step: 15 30 45
PASS step 1〜45 が命令表の模型と一致 (食い違い 0)
```

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| `td4_core` までが 11-1 と同じ | 同じ | `diff` で差なし | 合った |
| lint (`-Wall`) | 警告なし | 警告なし | 合った |
| 1 クロックごとの表 (16 クロック) | 上の表 | 試験台の出した表と同じ。45 クロックまで模型と食い違い 0 | 合った |
| E 番地を実行した回数 | 0 | 0 | 合った |
| 1 巡 | 15 クロック | 15・30・45 で PC = 0 | 合った |
| 図1・図2 の sequence と C の edges | 表の「後の」の列。時刻 0 はリセット中 | 表の値を 1 ms ずつ並べた物。0 ms の値はリセットのサンプル (PC 0・命令 35・A・B・OUT 0)。`check` の読み値の並びが表と一致 | 合った |

## 出典

- [simpleTD4](https://github.com/asfdrwe/simpleTD4) (asfdrwe、MIT) — 命令のビットの決め方と、命令ごとの動きの解説 (`TD4_details_jp.md`)。プログラムと表は自作
- [tommie-jp/soft-fpga](https://github.com/tommie-jp/soft-fpga) の `examples/01-counter` — 載せる先 (ハーネスと画面の直しは 11-19)
- TD4 そのものは、渡波郁『CPU の創りかた』(毎日コミュニケーションズ、2003) の CPU
