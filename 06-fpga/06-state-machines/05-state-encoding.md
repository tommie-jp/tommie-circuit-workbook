---
book: fpga
chapter: 6
id: 6-5
title: 状態の符号 — 2 進・ワンホット・グレイ
tier: 100
source: 自作
board: —
device: SIM
---

# 6-5 状態の符号 — 2 進・ワンホット・グレイ

この題は実体配線図と Analog Discovery 3 の図を付けない。PC の Verilator だけで動かす題で、組む物が無いから。

6-1 と 6-4 の状態機械は、状態に `S0`〜`S4` の名前を付け、`localparam` で 3 ビットの数を割り当てていた。
この割り当てを**状態の符号**と呼ぶ。同じ状態遷移図でも、符号を変えると、レジスタの数・次の状態の式・出力の式が変わる。

この題では、6-4 のムーア型 (5 状態。状態遷移図は 6-4 の図1と同じ) を 3 通りの符号で書き、次の 3 つを比べる。

- 振る舞いが同じであること (10 万ビットの試験)
- 状態レジスタのビットが切り替わる回数 (シミュレーションの数)
- 合成した回路の大きさ (yosys が数えた FF と LUT の数)

## 3 つの符号

| 状態 | 2 進 (3 ビット) | ワンホット (5 ビット) | グレイ (3 ビット) |
| --- | --- | --- | --- |
| S0 | 000 | 00001 | 000 |
| S1 | 001 | 00010 | 001 |
| S2 | 010 | 00100 | 011 |
| S3 | 011 | 01000 | 010 |
| S4 | 100 | 10000 | 110 |

- 2 進: 状態に 0 から順に番号を振る。ビット数は最小 (5 状態なら 3 ビット)
- ワンホット: 状態 1 つにつき 1 ビット。今の状態のビットだけが 1 になる。ビット数は状態の数と同じ
- グレイ: 番号の順に並べたとき、隣どうしで 1 ビットしか変わらない符号 (2 進を 1 ビット右へ送って排他的論理和をとる)

「その状態にいる」を調べる式が違う。2 進とグレイは 3 ビット全部を比べるが、ワンホットは 1 ビットを見れば足りる。
これが、ワンホットの回路がフリップフロップを多く使うかわりに、組み合わせの回路が小さくなりやすい理由である。

## Verilog

### seq_enc.v — 符号を `ENC` で選ぶ

6-4 の `seq_moore.v` から変えたのは、状態の定数の作り方だけである。`case` と出力の式は同じ文面のまま。

```verilog
// 系列 1011 の検出 (ムーア型、6-4 と同じ 5 状態)。状態の符号を ENC で選ぶ。
//   ENC = 0: 2 進 (000 001 010 011 100)
//   ENC = 1: ワンホット (00001 00010 00100 01000 10000)
//   ENC = 2: グレイ (000 001 011 010 110)
module seq_enc #(
    parameter ENC = 0
) (
    input        clk,
    input        rst,
    input        din,
    output       detect,
    output [4:0] state       // 状態レジスタの中身 (上の桁は 0 で埋める)
);
    localparam integer SW = (ENC == 1) ? 5 : 3;   // 状態レジスタの幅

    // i 番目の状態の符号 (下位 5 ビット。幅が SW の符号は下位 SW ビット)
    function [4:0] code(input integer i);
        case (ENC)
            1:       code = 5'b00001 << i;
            2:       code = i[4:0] ^ (i[4:0] >> 1);
            default: code = i[4:0];
        endcase
    endfunction

    localparam [4:0] C0 = code(0), C1 = code(1), C2 = code(2), C3 = code(3), C4 = code(4);
    localparam [SW-1:0] S0 = C0[SW-1:0],   // 手がかりなし
                        S1 = C1[SW-1:0],   // 直前が 1
                        S2 = C2[SW-1:0],   // 直前が 10
                        S3 = C3[SW-1:0],   // 直前が 101
                        S4 = C4[SW-1:0];   // 直前が 1011 (検出)

    reg [SW-1:0] st;
    reg [SW-1:0] next;

    always @(posedge clk)
        if (rst) st <= S0;
        else     st <= next;

    always @(*) begin
        next = st;
        case (st)
            S0:      next = din ? S1 : S0;
            S1:      next = din ? S1 : S2;
            S2:      next = din ? S3 : S0;
            S3:      next = din ? S4 : S2;
            S4:      next = din ? S1 : S2;
            default: next = S0;          // 定義していない符号に落ちたら S0 へ戻す
        endcase
    end

    assign detect = (st == S4);
    assign state  = {{(5 - SW){1'b0}}, st};
endmodule
```

- `code(i)` が `i` 番目の状態の符号を返す。`ENC` が 1 ならワンホット、2 ならグレイ、それ以外は 2 進
- 状態レジスタの幅 `SW` は、ワンホットだけ 5、ほかは 3。`localparam [SW-1:0]` で幅をそろえて `case` に使う
- 6-1 の `next = st;` と `default` はそのまま。`default` の行は、定義していない符号に落ちたとき S0 へ戻す

Verilator の lint は 3 つの符号とも警告なしで通る (`verilator --lint-only -Wall -GENC=0 seq_enc.v`、`-GENC=1`、`-GENC=2`、確かめた)。

### seq_onehot.v — ワンホットらしく書く

`seq_enc.v` の `ENC = 1` は、状態を 5 ビット全部で比べる書き方のままである。
ワンホットでは、「次にそのビットが 1 になる条件」を直接書くほうが回路が小さくなる。

```verilog
// 系列 1011 の検出 (ムーア型) をワンホットらしく書いた物。
// 状態の名前ごとに 1 ビットを持ち、「次にそのビットが 1 になる条件」を直接書く
module seq_onehot (
    input        clk,
    input        rst,
    input        din,
    output       detect,
    output [4:0] state
);
    // st[0] = S0 手がかりなし、st[1] = S1 直前が 1、st[2] = S2 直前が 10、
    // st[3] = S3 直前が 101、st[4] = S4 直前が 1011 (検出)
    reg [4:0] st;

    wire [4:0] next;
    assign next[0] = ~din & (st[0] | st[2]);          // S0 か S2 で 0 が来た
    assign next[1] =  din & (st[0] | st[1] | st[4]);  // S0・S1・S4 で 1 が来た
    assign next[2] = ~din & (st[1] | st[3] | st[4]);  // S1・S3・S4 で 0 が来た
    assign next[3] =  din & st[2];                    // S2 で 1 が来た
    assign next[4] =  din & st[3];                    // S3 で 1 が来た

    always @(posedge clk)
        if (rst) st <= 5'b00001;
        else     st <= next;

    assign detect = st[4];
    assign state  = st;
endmodule
```

- 状態 `S0`〜`S4` が `st[0]`〜`st[4]` に当たる。たとえば `next[3]` (S3 になる) は、S2 にいて `1` が来たときだけ
- `detect` は `st[4]` を読むだけで、比べる式が要らない
- `default` が無い。`st` に 2 ビット以上が立った符号は、そのまま残る (下の「壊れた符号からの戻り」)

Verilator の lint は警告なしで通る (`verilator --lint-only -Wall seq_onehot.v`、確かめた)。

## 試験 — 4 つの回路を同じ入力で回す

2 進・ワンホット・グレイ (`seq_enc`) と `seq_onehot` を、同じでたらめな 10 万ビットで回す。次の 3 つを数える。

- 検出が基準 (直前の 4 ビットが `1011` か、1 クロック遅らせたもの) と合うか
- 状態が変わったクロックの数と、そのとき切り替わった状態レジスタのビットの数
- 定義していない符号を押し込んだとき、そのあとどうなるか

```verilog
// 2 進・ワンホット・グレイの 3 つを同じ入力 10 万ビットで回す。
// 検出が基準 (直前 4 ビット) と合うこと、状態レジスタのビットが何回変わったかを数える。
// 最後に、定義していない符号を 1 つ押し込んで、次のクロックで S0 に戻ることを見る
module tb_enc;
    reg clk;
    reg rst;
    reg din;
    wire d0, d1, d2, d3;
    wire [4:0] s0, s1, s2, s3;

    seq_enc #(.ENC(0)) u0 (.clk(clk), .rst(rst), .din(din), .detect(d0), .state(s0));
    seq_enc #(.ENC(1)) u1 (.clk(clk), .rst(rst), .din(din), .detect(d1), .state(s1));
    seq_enc #(.ENC(2)) u2 (.clk(clk), .rst(rst), .din(din), .detect(d2), .state(s2));
    seq_onehot u3 (.clk(clk), .rst(rst), .din(din), .detect(d3), .state(s3));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    reg [3:0] hist;
    reg       ref_moore;
    reg [4:0] p0, p1, p2, p3;
    integer   k, cyc, bad, flips0, flips1, flips2, flips3, moves0, moves1, moves2, moves3;

    function integer popcount(input [4:0] v);
        integer k;
        begin
            popcount = 0;
            for (k = 0; k < 5; k = k + 1) popcount = popcount + {31'd0, v[k]};
        end
    endfunction

    initial begin
        rst = 1'b1; din = 1'b0; hist = 4'b0; ref_moore = 1'b0;
        cyc = 0; bad = 0; flips0 = 0; flips1 = 0; flips2 = 0; flips3 = 0; moves0 = 0; moves1 = 0; moves2 = 0; moves3 = 0;
        repeat (2) @(posedge clk);
        #1 rst = 1'b0;
        p0 = s0; p1 = s1; p2 = s2; p3 = s3;
        repeat (100000) begin
            din = ($random & 1) != 0;
            hist = {hist[2:0], din};
            @(posedge clk);
            #1;
            // この立ち上がりで din を取り込んだ。検出は 1 クロック後の状態に出る
            ref_moore = (hist == 4'b1011);
            if (d0 !== ref_moore || d1 !== ref_moore || d2 !== ref_moore || d3 !== ref_moore) bad = bad + 1;
            flips0 = flips0 + popcount(s0 ^ p0); if (s0 != p0) moves0 = moves0 + 1;
            flips1 = flips1 + popcount(s1 ^ p1); if (s1 != p1) moves1 = moves1 + 1;
            flips2 = flips2 + popcount(s2 ^ p2); if (s2 != p2) moves2 = moves2 + 1;
            flips3 = flips3 + popcount(s3 ^ p3); if (s3 != p3) moves3 = moves3 + 1;
            p0 = s0; p1 = s1; p2 = s2; p3 = s3;
            cyc = cyc + 1;
        end
        $display("bits %0d, mismatches with reference %0d", cyc, bad);
        $display("            width  state moves  bit flips  flips/move");
        $display("binary      %0d      %0d        %0d      %0.3f", 3, moves0, flips0, flips0 * 1.0 / moves0);
        $display("one-hot     %0d      %0d        %0d      %0.3f", 5, moves1, flips1, flips1 * 1.0 / moves1);
        $display("gray        %0d      %0d        %0d      %0.3f", 3, moves2, flips2, flips2 * 1.0 / moves2);
        $display("onehot-2   %0d      %0d        %0d      %0.3f", 5, moves3, flips3, flips3 * 1.0 / moves3);
        if (bad == 0) $display("PASS"); else $display("FAIL");

        // 定義していない符号を押し込む (宇宙線や電源の乱れで状態レジスタが化けた想定)
        din = 1'b0;
        u0.st = 3'd7;      // 2 進の 111
        u1.st = 5'b00011;  // ワンホットで 2 本立った
        u2.st = 3'd5;      // グレイの 101
        u3.st = 5'b00011;  // ワンホットらしく書いた物も 2 本立てる
        #1;
        $display("forced:   binary %b  one-hot %b  gray %b  onehot-2 %b", u0.st, u1.st, u2.st, u3.st);
        for (k = 0; k < 5; k = k + 1) begin
            @(posedge clk); #1;
            $display("clk +%0d:  binary %b  one-hot %b  gray %b  onehot-2 %b", k + 1, u0.st, u1.st, u2.st, u3.st);
            din = ($random & 1) != 0;
        end
        $finish;
    end
endmodule
```

```bash
verilator --binary --timing --top-module tb_enc tb_enc.v seq_enc.v seq_onehot.v
./obj_dir/Vtb_enc
```

```text
bits 100000, mismatches with reference 0
            width  state moves  bit flips  flips/move
binary      3      72090        106657      1.479
one-hot     5      72090        144180      2.000
gray        3      72090        94049      1.305
onehot-2   5      72090        144180      2.000
PASS
forced:   binary 111  one-hot 00011  gray 101  onehot-2 00011
clk +1:  binary 000  one-hot 00001  gray 000  onehot-2 00101
clk +2:  binary 001  one-hot 00010  gray 001  onehot-2 01010
clk +3:  binary 001  one-hot 00010  gray 001  onehot-2 10010
clk +4:  binary 001  one-hot 00010  gray 001  onehot-2 00010
clk +5:  binary 010  one-hot 00100  gray 011  onehot-2 00100
```

(Verilator 5.042 で実行。押し込んだあとの入力はでたらめ。)

- 4 つとも基準と食い違い 0。符号を変えても、外から見た振る舞いは同じである
- 状態が変わったクロックは 72090 回で、どの符号でも同じ。切り替わるビットの数は、1 回の変わり目あたり 2 進 1.479、グレイ 1.305、ワンホット 2.000
- ワンホットは、必ず 2 ビット (古い状態の 1 が消え、新しい状態の 1 が立つ)。2 進とグレイは、遷移によって 1〜3 ビットで、平均が 2 を下回る
- グレイは 2 進より少ない。ただし、この状態遷移図は S0 から S2 へ飛ぶ・S4 から S1 へ戻るなど、番号の隣どうしでない矢印がある。グレイは「隣どうし 1 ビット」を保証するだけで、全部の矢印を 1 ビットにはできない

## 合成した回路の大きさ

同じ Verilog を yosys の `synth_gowin` (Tang Nano 9K の FPGA の部品に合成する) に通し、FF と LUT の数を数えた。
FPGA ボードへの配置と配線はしていない。

```bash
yosys -p "read_verilog -sv seq_enc.v; hierarchy -top seq_enc; chparam -set ENC 1 seq_enc; synth_gowin -top seq_enc; stat"
```

| 書き方 | FF | LUT | そのほか |
| --- | --- | --- | --- |
| 2 進 (`seq_enc`、`ENC = 0`) | 3 | 4 | |
| グレイ (`seq_enc`、`ENC = 2`) | 3 | 4 | |
| ワンホット (`seq_enc`、`ENC = 1`) | 5 | 22 | MUX2 16 個 |
| ワンホットらしく書いた (`seq_onehot`) | 5 | 5 | |

(yosys 0.33、`synth_gowin`。数は yosys の `stat` の LUT1〜LUT4 と DFF の合計。)

- 2 進とグレイは同じ大きさになった。この回路では、符号を替えても式の複雑さはほとんど変わらない
- 同じ書き方 (5 ビット全部を比べる) のままワンホットにすると、FF が 3 から 5 に増えるうえ、LUT も 4 から 22 に増えた。ワンホットの得をまったく使っていない
- ワンホットらしく書くと、LUT は 5 に収まった。FF は 5 のまま増える
- 符号を変えるだけでは得にならず、**符号に合わせて式を書き直す**ところまでが 1 組である
- yosys には、状態レジスタを見つけて符号を自動で選び直す機能 (`fsm` パス) がある。今回の回路では「符号を替える利益が見込めない」として働かなかった (ログに `Not marking seq_enc.st as FSM state register` と出た)。書いた符号のまま合成されている

## 壊れた符号からの戻り

状態レジスタには、定義していない符号の組み合わせが残る (2 進とグレイは、5 状態を 3 ビットに入れたので 3 通り。ワンホットは、5 ビットのうち 1 ビットだけ立つ 5 通りを除いた 27 通り)。
電源の乱れや宇宙線で状態レジスタが化けると、そこに落ちる可能性がある。試験では、それぞれに定義していない符号を押し込んだ。

| 符号 | 押し込んだ値 | 次のクロック | そのあと |
| --- | --- | --- | --- |
| 2 進 | 111 | 000 (S0 に戻る) | 入力どおりに進む |
| ワンホット (`seq_enc`) | 00011 | 00001 (S0 に戻る) | 入力どおりに進む |
| グレイ | 101 | 000 (S0 に戻る) | 入力どおりに進む |
| ワンホットらしく (`seq_onehot`) | 00011 | 00101 (2 ビットのまま) | 4 クロック後に 00010 (1 ビットに戻った) |

- `default` の行があるので、`seq_enc` の 3 つは次のクロックで S0 に戻る。ワンホット (`seq_enc`) は 5 ビット全部を比べる書き方だから、`default` に落ちて戻れた
- `seq_onehot` は 1 ビットずつ見て書いたので `default` が無い。2 ビットが立った符号は、入力に従って 2 ビットのまま動き、
  2 つの 1 が同じ状態へ合流したときに 1 ビットに戻る。この試験の入力では 4 クロックで戻ったが、**入力しだいで、戻る保証は無い**。
  確実に戻したいときは、立っているビットが 1 つであることを別に調べる回路を足す
- 定義していない状態からの戻りは、6-11 で扱う

## シミュレーションの波形

6-4 と同じ入力 (24 クロックぶん) で、3 つの符号の状態レジスタを並べた。1 クロックを 1 ms と置いた仮の目盛。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図1 同じ入力でも、状態レジスタのビットは 2 進・ワンホット・グレイで違う動きをする
device: generic
window: 24ms
signals:
  CLK: clock 1kHz
  B2: edges 0s=0 5ms=1 6ms=0 8ms=1 9ms=0 21ms=1 22ms=0
  B1: edges 0s=0 3ms=1 5ms=0 6ms=1 8ms=0 9ms=1 10ms=0 13ms=1 16ms=0 19ms=1 21ms=0 22ms=1
  B0: edges 0s=0 2ms=1 3ms=0 4ms=1 5ms=0 7ms=1 8ms=0 11ms=1 13ms=0 14ms=1 15ms=0 18ms=1 19ms=0 20ms=1 21ms=0 23ms=1
  H4: edges 0s=0 5ms=1 6ms=0 8ms=1 9ms=0 21ms=1 22ms=0
  H3: edges 0s=0 4ms=1 5ms=0 7ms=1 8ms=0 14ms=1 15ms=0 20ms=1 21ms=0 23ms=1
  H2: edges 0s=0 3ms=1 4ms=0 6ms=1 7ms=0 9ms=1 10ms=0 13ms=1 14ms=0 15ms=1 16ms=0 19ms=1 20ms=0 22ms=1 23ms=0
  H1: edges 0s=0 2ms=1 3ms=0 11ms=1 13ms=0 18ms=1 19ms=0
  H0: edges 0s=1 2ms=0 10ms=1 11ms=0 16ms=1 18ms=0
  G2: edges 0s=0 5ms=1 6ms=0 8ms=1 9ms=0 21ms=1 22ms=0
  G1: edges 0s=0 3ms=1 10ms=0 13ms=1 16ms=0 19ms=1
  G0: edges 0s=0 2ms=1 4ms=0 6ms=1 7ms=0 9ms=1 10ms=0 11ms=1 14ms=0 15ms=1 16ms=0 18ms=1 20ms=0 22ms=1 23ms=0
buses:
  Binary: B2 B1 B0 bin
  Gray: G2 G1 G0 bin
cursors: [4.5ms, 5.5ms]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/06-state-machines/logic/05-state-encoding.svg)

- X1 (4.5 ms) は S3、X2 (5.5 ms) は S4。2 進は `011` から `100` で 3 ビットが切り替わる。グレイは `010` から `110` で 1 ビット、ワンホットは `H3` が下がり `H4` が立つ 2 ビット
- 24 クロックのうち状態が変わったのは 20 回。この窓で切り替わったビットの数は、2 進 32、ワンホット 40、グレイ 25

## 見るべき値

PC の Verilator (5.042) と yosys (0.33) で実際に動かして得た値。

| 見る所 | 値 |
| --- | --- |
| lint (`-Wall`) | 4 つとも警告 0 件 |
| 10 万ビットの試験 | 4 つとも基準と食い違い 0 回 |
| 状態が変わったクロック | 72090 回 (どの符号も同じ) |
| 1 回の変わり目あたりの切り替わりビット数 | 2 進 1.479、グレイ 1.305、ワンホット 2.000 |
| 合成 (FF / LUT) | 2 進 3 / 4、グレイ 3 / 4、ワンホット (同じ書き方) 5 / 22、ワンホットらしく 5 / 5 |
| 押し込んだ定義外の符号 | `seq_enc` の 3 つは次のクロックで S0。`seq_onehot` は 2 ビットのまま動き、4 クロック後に 1 ビットへ |

## シミュレーションでの確かめ

Verilator 5.042 と yosys 0.33 で、本文の `seq_enc.v`・`seq_onehot.v`・試験 `tb_enc` を抜き出して走らせ直した。
原本は `sim/05-state-encoding.v`・`sim/05-state-encoding-onehot.v`・`sim/05-state-encoding-tb.v`。
合成は本文のコマンドのまま (`synth_gowin`)。`seq_onehot` は `read_verilog -sv seq_onehot.v; synth_gowin -top seq_onehot` で数えた。
配置配線は OSS CAD Suite の Yosys 0.70+16 と nextpnr-himbaechel 0.11.1-63 でも走らせた。ピンは仮の番号で、制約は `--freq 27` だけを渡した。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint (`-Wall`、`-GENC=0/1/2`、`seq_onehot`) | 4 つとも警告なし | 警告 0 件 | 合った |
| 10 万ビットの試験 | 基準との食い違い 0、`PASS` | 0、`PASS` | 合った |
| 状態が変わったクロック | 72090 回 | 72090 回 | 合った |
| 切り替わったビット数 / 回 | 2 進 1.479、ワンホット 2.000、グレイ 1.305 (合計 106657・144180・94049) | 同じ | 合った |
| 押し込んだ定義外の符号 | `seq_enc` の 3 つは次のクロックで S0、`seq_onehot` は 4 クロック後に 1 ビット | 表のとおり (1 クロック後 000・00001・000、`seq_onehot` は 00101 → 01010 → 10010 → 00010) | 合った |
| 合成 FF / LUT (2 進) | 3 / 4 | DFFR 3、LUT3 1 + LUT4 3 | 合った |
| 合成 FF / LUT (グレイ) | 3 / 4 | 2 進と同じ | 合った |
| 合成 FF / LUT (ワンホット、同じ書き方) | 5 / 22、MUX2 16 個 | DFFR 4 + DFFS 1、LUT1 11 + LUT3 1 + LUT4 10、MUX2_LUT5 11 + MUX2_LUT6 5 | 合った |
| 合成 FF / LUT (`seq_onehot`) | 5 / 5 | DFFR 4 + DFFS 1、LUT2 2 + LUT3 1 + LUT4 2 | 合った |
| yosys の `fsm` パス | `Not marking seq_enc.st as FSM state register` | 同じ行が出た | 合った |
| 合成 FF / LUT (2 進・グレイ、Yosys 0.70+16) | 3 / 4 | DFFR 3、LUT3 1 + LUT4 4 = LUT 5 | 近い (版の差。LUT が 1 個多い) |
| 合成 FF / LUT (ワンホット、同じ書き方、Yosys 0.70+16) | 5 / 22、MUX2 16 個 | DFFR 4 + DFFS 1、LUT1 17 + LUT4 9 = LUT 26、MUX2_LUT5 13 + MUX2_LUT6 6 = MUX2 19 個 | 近い (版の差。多い向きは同じ) |
| 合成 FF / LUT (`seq_onehot`、Yosys 0.70+16) | 5 / 5 | DFFR 4 + DFFS 1、LUT2 2 + LUT3 1 + LUT4 2 | 合った |
| 配置配線の `Max frequency` (2 進・グレイ) | (本文に無い) | 366.30 MHz (PASS at 27.00 MHz)。配置配線後の LUT4 5、DFF 3 | 補足 |
| 配置配線の `Max frequency` (ワンホット、同じ書き方) | (本文に無い) | 213.68 MHz。LUT4 26、MUX2_LUT5 13、MUX2_LUT6 6、DFF 5 | 補足 |
| 配置配線の `Max frequency` (`seq_onehot`) | (本文に無い) | 422.48 MHz。LUT4 5、DFF 5 | 補足 |

## 出典

自作。ワンホットの符号と「次にそのビットが 1 になる条件」を直接書く形は、ディジタル回路設計の一般的な作法である。
グレイ符号は、2 進から 1 ビット右へ送って排他的論理和をとる定義による。
yosys の `synth_gowin` は [Yosys のマニュアル](https://yosyshq.readthedocs.io/projects/yosys/en/latest/cmd/synth_gowin.html)。
Verilog は 6-4 の `seq_moore.v` を元にした。
