---
book: fpga
chapter: 1
id: 1-10
title: プライオリティエンコーダ
tier: 100
source: 自作
board: —
device: SIM
---

# 1-10 プライオリティエンコーダ

複数の入力が同時に 1 になっても、いちばん優先度の高い 1 本の番号を出す回路 (プライオリティエンコーダ) を書く。
1-5 のデコーダが「番号 → 1 本」だったのに対し、これは「1 本 → 番号」の逆向きで、しかも 2 本以上が 1 でも答えが 1 つに決まる。
`casez` で書く方法と `if / else if` で書く方法を並べ、図 1 のゲートと合わせた 3 通りが、16 通りの入力すべてで同じ出力になることを確かめる。

この題は組まない題で、実体配線図と Analog Discovery 3 は付けない。PC の中だけで動かす (`device: SIM`)。

## 説明

- 入力 `req[3:0]` のうち、**番号の大きいビットほど優先度が高い**とする。`req[3]` が 1 なら、ほかがどうでも答えは 3
- 出力は 2 つ。選ばれた番号 `code[1:0]` と、「1 本でも 1 があった」ことを示す `valid`
- **`valid` が要る理由**: `req = 4'b0001` のときの `code` は 0 で、`req = 4'b0000` (何も無い) のときの `code` も 0 だ。`code` だけでは 2 つを区別できない
- `casez` は、`case` の各行の `?` を「0 でも 1 でもよい」(どちらでも一致する) の意味で書ける。`4'b01??` は「上から 2 番目だけが 1、上の 1 本は 0、下の 2 本は何でもよい」を表す
- `case` は上の行から順に比べ、最初に一致した行だけを実行する。優先度の高い順に行を並べるのがコツだ
- `casex` という書き方もあるが、`x` も「どちらでもよい」に数えるため、入力に不定値が混じると思わぬ行に一致する。ここでは使わない

## 論理図

図 1 は、4 入力の場合のゲートだ。式にすると次のとおり。

- `code[1]` = r3 + r2 (どちらかが 1 なら、番号は 2 か 3 で、上の桁が 1)
- `code[0]` = r3 + (r2 の反転)·r1 (番号 3 のとき、または r2 が 0 で r1 が 1 のとき、下の桁が 1)
- `valid` = r3 + r2 + r1 + r0

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 プライオリティエンコーダ (入力は 4 本)
parts:
  r3: port 1,2
  r2: port 1,4
  r1: port 1,6
  r0: port 1,8
  O1: or 20,11
  O2: or 20,14
  O3: or 30,12
  N1: not 13,20
  A1: and 20,21
  O4: or 30,17
  valid: port 36,12
  code1: port 36,14
  code0: port 36,17
wires:
  - 1,2 -- 4,2
  - 4,2 -- 4,17
  - 1,4 -- 6,4
  - 6,4 -- 6,20
  - 1,6 -- 8,6
  - 8,6 -- 8,21
  - 1,8 -- 10,8
  - 10,8 -- 10,11
  - 8,11 |- O1.a
  - 10,11 |- O1.b
  - 4,14 |- O2.a
  - 6,14 |- O2.b
  - O1.out -- 26,11
  - 26,11 |- O3.a
  - O2.out -- 26,14
  - 26,14 -- 36,14
  - 26,14 |- O3.b
  - O3.out -- 36,12
  - 6,20 -- N1.in
  - N1.out -- 17,20
  - 17,20 |- A1.a
  - 8,21 |- A1.b
  - A1.out -- 26,21
  - 26,21 |- O4.b
  - 4,17 |- O4.a
  - O4.out -- 36,17
style:
  grid: off
  pitch: 0.8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/circuit/10-priority-encoder.svg)

- O2 が `code[1]` (r3 と r2 の OR)。その出力は、`valid` を作る O3 にも枝分かれして入る (黒丸の所)
- O1 は r1 と r0 の OR。O3 で O2 の出力と OR して `valid` になる
- N1 は r2 を反転する NOT、A1 はそれと r1 の AND。O4 でそれと r3 を OR して `code[0]` を作る
- r3 が 1 のとき、r2 も r1 も何であっても `code` は 3 (2 進で 11)。`code[1]` も `code[0]` も r3 で 1 になるからだ

## Verilog

`casez` で書いた版。

```verilog
// pri_casez.v  casez で書いた 4 入力のプライオリティエンコーダ
module pri_casez (
    input  wire [3:0] req,
    output reg  [1:0] code,
    output reg        valid
);
    always @(*) begin
        casez (req)
            4'b1???: begin code = 2'd3; valid = 1'b1; end
            4'b01??: begin code = 2'd2; valid = 1'b1; end
            4'b001?: begin code = 2'd1; valid = 1'b1; end
            4'b0001: begin code = 2'd0; valid = 1'b1; end
            default: begin code = 2'd0; valid = 1'b0; end
        endcase
    end
endmodule
```

`if / else if` で書いた版。上から順に調べるので、優先度がそのまま書き方に出る。

```verilog
// pri_if.v  if / else if で書いた 4 入力のプライオリティエンコーダ
module pri_if (
    input  wire [3:0] req,
    output reg  [1:0] code,
    output reg        valid
);
    always @(*) begin
        if (req[3]) begin
            code = 2'd3; valid = 1'b1;
        end else if (req[2]) begin
            code = 2'd2; valid = 1'b1;
        end else if (req[1]) begin
            code = 2'd1; valid = 1'b1;
        end else if (req[0]) begin
            code = 2'd0; valid = 1'b1;
        end else begin
            code = 2'd0; valid = 1'b0;
        end
    end
endmodule
```

図 1 のゲートをそのまま書いた版。

```verilog
// pri_gates.v  図 1 のゲートのとおりに書いた 4 入力のプライオリティエンコーダ
module pri_gates (
    input  wire [3:0] req,
    output wire [1:0] code,
    output wire       valid
);
    assign code[1] = req[3] | req[2];
    assign code[0] = req[3] | (~req[2] & req[1]);
    assign valid   = (req[1] | req[0]) | (req[3] | req[2]);
endmodule
```

3 つを並べて、出力がそろっていれば `same` を 1 にする比較用の箱。

```verilog
// pri_cmp.v  3 通りの書き方に同じ入力を入れ、出力がそろっていれば same を 1 にする
module pri_cmp (
    input  wire [3:0] req,
    output wire [1:0] code,
    output wire       valid,
    output wire       same
);
    wire [1:0] code_i;
    wire       valid_i;
    wire [1:0] code_g;
    wire       valid_g;
    pri_casez u_casez (.req(req), .code(code),   .valid(valid));
    pri_if    u_if    (.req(req), .code(code_i), .valid(valid_i));
    pri_gates u_gates (.req(req), .code(code_g), .valid(valid_g));
    assign same = ({code, valid} == {code_i, valid_i}) && ({code, valid} == {code_g, valid_g});
endmodule
```

- `default` は、`req` が 0 のとき (どの行にも当たらないとき) の出力を決める。`code` を 0 にして、`valid` を 0 にする
- `always @(*)` の中で、`code` と `valid` を全部の枝で代入している。1 つでも抜けると、1-13 で見るラッチになる

## 動かす

```cpp
// tb_pri_cmp.cpp
#include <cstdio>
#include "Vpri_cmp.h"

int main() {
    Vpri_cmp top;
    int bad = 0;
    std::printf("# req code valid same\n");
    for (int req = 0; req < 16; req++) {
        top.req = req;
        top.eval();
        std::printf("%x %x %d %d\n", top.req, top.code, top.valid, top.same);
        if (!top.same) bad++;
    }
    std::printf("same が 0 の入力: %d 通り\n", bad);
    return bad;
}
```

```bash
verilator --lint-only -Wall --top-module pri_cmp pri_cmp.v pri_casez.v pri_if.v pri_gates.v
verilator -Wall --cc --exe --build --top-module pri_cmp pri_cmp.v pri_casez.v pri_if.v pri_gates.v tb_pri_cmp.cpp
./obj_dir/Vpri_cmp
```

lint は警告なしで通った。16 通りを順に与えた結果 (`req` と `code` は 16 進) は次のとおりだった。

```text
# req code valid same
0 0 0 1
1 0 1 1
2 1 1 1
3 1 1 1
4 2 1 1
5 2 1 1
6 2 1 1
7 2 1 1
8 3 1 1
9 3 1 1
a 3 1 1
b 3 1 1
c 3 1 1
d 3 1 1
e 3 1 1
f 3 1 1
same が 0 の入力: 0 通り
```

## 計器の設定

組まない題なので、計器は使わない。実行結果をロジックアナライザの画面と同じ形の図 2 に描く。
実機で測った波形ではなく、実行結果から作った計算の図で、入力を 0 から F まで変えた 1 回を 1 ms と見なして並べた。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図2 req を 0 から F まで変えたときの出力 (Verilator の結果から作った計算の図)
device: generic
window: 16ms
signals:
  r0: pattern 0101010101010101 bit 1ms
  r1: pattern 0011001100110011 bit 1ms
  r2: pattern 0000111100001111 bit 1ms
  r3: pattern 0000000011111111 bit 1ms
  valid: pattern 0111111111111111 bit 1ms
  c1: pattern 0000111111111111 bit 1ms
  c0: pattern 0011000011111111 bit 1ms
buses:
  req: r3 r2 r1 r0 hex
  code: c1 c0 dec
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/logic/10-priority-encoder.svg)

## 見るべき値

| req (2 進) | 当てはまる行 | code | valid |
| --- | --- | --- | --- |
| 1??? (8〜F) | 1 行目 | 3 | 1 |
| 01?? (4〜7) | 2 行目 | 2 | 1 |
| 001? (2・3) | 3 行目 | 1 | 1 |
| 0001 (1) | 4 行目 | 0 | 1 |
| 0000 (0) | default | 0 | 0 |

- 表の `?` はどちらでもよい印で、この行の入力はそれぞれ 8 通り・4 通り・2 通り・1 通り・1 通り。合わせて 16 通りになる
- `req` が 6 (0110) のとき、r2 と r1 が同時に 1 だが、code は 2。番号の大きい r2 が勝つ
- `req` が 1 と 0 のとき、code はどちらも 0。区別できるのは valid だけだ
- 3 通りの書き方の出力は、16 通りすべてで一致した (`same` が 0 の入力は 0 通り)

## シミュレーションでの確かめ

道具は Verilator 5.042 (本文のテストベンチ `sim/10-priority-encoder-tb.cpp` を `--cc --exe --build` で組んで実行) と Icarus Verilog 12.0。回路は `sim/10-priority-encoder.v` に置いた。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint | 警告なし | 警告なし (`--top-module pri_cmp`) | 合った |
| 16 通りの code・valid | req 0 → 0/0、1 → 0/1、2・3 → 1/1、4〜7 → 2/1、8〜f → 3/1 | 同じ | 合った |
| same が 0 の入力 | 0 通り | 0 通り (casez・if・ゲートの 3 通りが一致) | 合った |
| 図 2 のパターン | valid、c1、c0 | 計算した並びと一致 | 合った |
| 図 1 のつながり | code1 = r3 + r2、code0 = r3 + ~r2·r1、valid = 4 本の OR | ネットリストと一致 | 合った |

実行結果の見出し行は `# req code valid same` と出る (本文の表示のとおり)。

## 出典

自作。

参考: [Priority encoder (Wikipedia)](https://en.wikipedia.org/wiki/Priority_encoder)
