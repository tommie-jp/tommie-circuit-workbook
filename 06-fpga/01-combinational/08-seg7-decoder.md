---
book: fpga
chapter: 1
id: 1-8
title: 7 セグメントのデコーダ
tier: 100
source: 自作
board: —
device: SIM
---

# 1-8 7 セグメントのデコーダ

4 ビットの数 (0〜F) を、7 セグメント表示器の a〜g の 7 本に直すデコーダを書く。
1-5 の 2 → 4 デコーダは「1 本だけ 1」を出したが、これは「数の形になるように複数本を 1 にする」デコーダだ。
`case` の表で書き、その表の 1 本 (セグメント e) を、ゲートに直した論理図と数で突き合わせる。

この題は組まない題で、実体配線図と Analog Discovery 3 は付けない。PC の中だけで動かす (`device: SIM`)。
実際に 7 セグを光らせる配線は 12-4 で扱う。

## 説明

- 7 セグメント表示器は、a〜g の 7 本の細長い発光部 (セグメント) の組み合わせで数字を描く。
  a が上の横棒、b が右上、c が右下、d が下の横棒、e が左下、f が左上、g が真ん中の横棒だ
- この題の出力 `seg[6:0]` は `{g, f, e, d, c, b, a}` の順で、**1 で点灯**とする。
  共通がカソード (GND 側) の表示器は、1 を出したセグメントが光る。共通がアノードの表示器は光り方が逆になるので、`~seg` にして使う
- 入力が 4 ビットなので 0〜F の 16 通り。表は 16 行で、書き漏れがない。`default` も 1-5 と同じ理由で置く
- 12-4 の `seg7dec` は、この題の表の 0〜9 だけを使っている

## 論理図

`case` の表は、1 本ずつ見ると 4 入力 1 出力の論理回路だ。
7 本ぶんをゲートで描くと大きいので、いちばん項の少ないセグメント e だけを描く。
16 行の表の e の列から、1 になる行をまとめて、次の 4 つの積の和にした。

- d3·d2 (d3 と d2 がともに 1。C・D・E・F)
- d3·d1 (d3 と d1 がともに 1。A・B・E・F)
- d2 の反転·d0 の反転 (0・2・8・A)
- d1·d0 の反転 (2・6・A・E)

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 セグメント e のゲート
parts:
  d3: port 1,2
  d2: port 1,4
  d1: port 1,6
  d0: port 1,8
  N0: not 13,23
  N2: not 13,26
  T1: and 24,11
  T2: and 24,14
  T3: and 24,17
  T4: and 24,20
  O1: or 31,12
  O2: or 31,19
  O3: or 39,15
  e: port 45,15
wires:
  - 1,2 -- 4,2
  - 4,2 -- 4,14
  - 1,4 -- 6,4
  - 6,4 -- 6,26
  - 1,6 -- 8,6
  - 8,6 -- 8,20
  - 1,8 -- 10,8
  - 10,8 -- 10,23
  - 10,23 -- N0.in
  - 6,26 -- N2.in
  - N0.out -- 16,23
  - 16,23 -- 16,17
  - N2.out -- 18,26
  - 18,26 -- 18,17
  - 4,11 |- T1.a
  - 6,11 |- T1.b
  - 4,14 |- T2.a
  - 8,14 |- T2.b
  - 18,17 |- T3.a
  - 16,17 |- T3.b
  - 8,20 |- T4.a
  - 16,20 |- T4.b
  - T1.out -- 28,11
  - 28,11 |- O1.a
  - T2.out -- 28,14
  - 28,14 |- O1.b
  - T3.out -- 28,17
  - 28,17 |- O2.a
  - T4.out -- 28,20
  - 28,20 |- O2.b
  - O1.out -- 36,12
  - 36,12 |- O3.a
  - O2.out -- 36,19
  - 36,19 |- O3.b
  - O3.out -- 45,15
style:
  grid: off
  pitch: 0.8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/circuit/08-seg7-decoder.svg)

- T1 が d3·d2、T2 が d3·d1、T3 が d2 の反転·d0 の反転、T4 が d1·d0 の反転。N2・N0 は d2・d0 を反転する NOT
- 縦線の黒丸の所だけがつながっている。黒丸の無い交差は、線が重なって見えるだけでつながらない
- O1・O2・O3 で 4 つの積を OR にまとめる。OR は 2 入力なので 3 個で足りる

## Verilog

`case` の表で書いたデコーダ本体。

```verilog
// seg7_decoder.v  4 ビットの数 (0〜F) を 7 セグメントの点灯パターンに直す
module seg7_decoder (
    input  wire [3:0] d,
    output reg  [6:0] seg    // {g, f, e, d, c, b, a}。1 で点灯 (共通カソードの並び)
);
    always @(*) begin
        case (d)
            4'h0:    seg = 7'b0111111;
            4'h1:    seg = 7'b0000110;
            4'h2:    seg = 7'b1011011;
            4'h3:    seg = 7'b1001111;
            4'h4:    seg = 7'b1100110;
            4'h5:    seg = 7'b1101101;
            4'h6:    seg = 7'b1111101;
            4'h7:    seg = 7'b0000111;
            4'h8:    seg = 7'b1111111;
            4'h9:    seg = 7'b1101111;
            4'hA:    seg = 7'b1110111;
            4'hB:    seg = 7'b1111100;
            4'hC:    seg = 7'b0111001;
            4'hD:    seg = 7'b1011110;
            4'hE:    seg = 7'b1111001;
            4'hF:    seg = 7'b1110001;
            default: seg = 7'b0000000;
        endcase
    end
endmodule
```

図 1 をそのままゲートで書いたセグメント e。

```verilog
// seg_e_gates.v  セグメント e だけを、図 1 のゲートのとおりに書いたもの
module seg_e_gates (
    input  wire [3:0] d,
    output wire       e
);
    wire nd2 = ~d[2];
    wire nd0 = ~d[0];
    wire t1  = d[3] & d[2];
    wire t2  = d[3] & d[1];
    wire t3  = nd2 & nd0;
    wire t4  = d[1] & nd0;
    assign e = (t1 | t2) | (t3 | t4);
endmodule
```

2 つを並べて、e が同じなら `same` を 1 にする比較用の箱。

```verilog
// seg7_cmp.v  case の表と、e のゲート版を並べ、e が同じなら same を 1 にする
module seg7_cmp (
    input  wire [3:0] d,
    output wire [6:0] seg,
    output wire       same
);
    wire e_gates;
    seg7_decoder u_dec (.d(d), .seg(seg));
    seg_e_gates  u_e   (.d(d), .e(e_gates));
    assign same = (seg[4] == e_gates);
endmodule
```

- `seg[4]` が e。`{g, f, e, d, c, b, a}` の左から 3 番目、右から数えて 0 始まりの 4 番目に当たる
- `wire nd2 = ~d[2];` は、宣言と同時に代入する書き方で、`wire nd2; assign nd2 = ~d[2];` と同じ

## 動かす

```cpp
// tb_seg7_cmp.cpp
#include <cstdio>
#include "Vseg7_cmp.h"

int main() {
    Vseg7_cmp top;
    int bad = 0;
    std::printf("# d seg same\n");
    for (int d = 0; d < 16; d++) {
        top.d = d;
        top.eval();
        std::printf("%X %02x %d\n", top.d, top.seg, top.same);
        if (!top.same) bad++;
    }
    std::printf("same が 0 の入力: %d 通り\n", bad);
    return bad;
}
```

```bash
verilator --lint-only -Wall --top-module seg7_cmp seg7_cmp.v seg7_decoder.v seg_e_gates.v
verilator -Wall --cc --exe --build --top-module seg7_cmp seg7_cmp.v seg7_decoder.v seg_e_gates.v tb_seg7_cmp.cpp
./obj_dir/Vseg7_cmp
```

lint は警告なしで通った。16 通りを順に与えた結果 (`seg` は 16 進) は次のとおりだった。

```text
# d seg same
0 3f 1
1 06 1
2 5b 1
3 4f 1
4 66 1
5 6d 1
6 7d 1
7 07 1
8 7f 1
9 6f 1
A 77 1
B 7c 1
C 39 1
D 5e 1
E 79 1
F 71 1
same が 0 の入力: 0 通り
```

## 計器の設定

組まない題なので、計器は使わない。実行結果をロジックアナライザの画面と同じ形の図 2 に描く。
実機で測った波形ではなく、実行結果から作った計算の図で、入力を変えた 1 回を 1 ms と見なして並べた。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図2 d を 0 から F まで変えたときの a〜g (Verilator の実行結果から作った計算の図)
device: generic
window: 16ms
signals:
  d0: pattern 0101010101010101 bit 1ms
  d1: pattern 0011001100110011 bit 1ms
  d2: pattern 0000111100001111 bit 1ms
  d3: pattern 0000000011111111 bit 1ms
  a: pattern 1011011111101011 bit 1ms
  b: pattern 1111100111100100 bit 1ms
  c: pattern 1101111111110100 bit 1ms
  d: pattern 1011011011011110 bit 1ms
  e: pattern 1010001010111111 bit 1ms
  f: pattern 1000111011111011 bit 1ms
  g: pattern 0011111011110111 bit 1ms
buses:
  num: d3 d2 d1 d0 hex
  seg: g f e d c b a hex
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/logic/08-seg7-decoder.svg)

## 見るべき値

図 1 のゲートを、16 通りの入力で 1 行ずつ計算した表。右端の「e (ゲート)」が、`case` の表から取った「e (case)」と全部の行で一致する。
t1〜t4 は図 1 の T1〜T4 の出力で、いずれかが 1 なら e は 1 になる。

| d | d3 d2 d1 d0 | seg (g f e d c b a) | e (case) | t1 | t2 | t3 | t4 | e (ゲート) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 0000 | 0111111 | 1 | 0 | 0 | 1 | 0 | 1 |
| 1 | 0001 | 0000110 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2 | 0010 | 1011011 | 1 | 0 | 0 | 1 | 1 | 1 |
| 3 | 0011 | 1001111 | 0 | 0 | 0 | 0 | 0 | 0 |
| 4 | 0100 | 1100110 | 0 | 0 | 0 | 0 | 0 | 0 |
| 5 | 0101 | 1101101 | 0 | 0 | 0 | 0 | 0 | 0 |
| 6 | 0110 | 1111101 | 1 | 0 | 0 | 0 | 1 | 1 |
| 7 | 0111 | 0000111 | 0 | 0 | 0 | 0 | 0 | 0 |
| 8 | 1000 | 1111111 | 1 | 0 | 0 | 1 | 0 | 1 |
| 9 | 1001 | 1101111 | 0 | 0 | 0 | 0 | 0 | 0 |
| A | 1010 | 1110111 | 1 | 0 | 1 | 1 | 1 | 1 |
| B | 1011 | 1111100 | 1 | 0 | 1 | 0 | 0 | 1 |
| C | 1100 | 0111001 | 1 | 1 | 0 | 0 | 0 | 1 |
| D | 1101 | 1011110 | 1 | 1 | 0 | 0 | 0 | 1 |
| E | 1110 | 1111001 | 1 | 1 | 1 | 0 | 1 | 1 |
| F | 1111 | 1110001 | 1 | 1 | 1 | 0 | 0 | 1 |

- 数字として読める 0〜9 のうち、e (左下の棒) が点くのは 0・2・6・8 の 4 つ。1・3・4・5・7・9 は左下が空いている。これは数字の形のとおりだ
- 8 は 7 本とも点灯で `7'b1111111` (16 進で 7f)、1 は b と c だけの `7'b0000110` (06)
- A〜F のうち b と d だけを小文字の形にしたのは、大文字の B と D が 8 と 0 に見分けにくいためだ。この表もその慣習に従った
- e は 16 通りのうち 10 通りで 1 になる。表の e の列を数えて 10 になれば、写し間違いはない

## シミュレーションでの確かめ

道具は Verilator 5.042 (本文のテストベンチ `sim/08-seg7-decoder-tb.cpp` を `--cc --exe --build` で組んで実行) と Icarus Verilog 12.0。回路は `sim/08-seg7-decoder.v` に置いた。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint | 警告なし | 警告なし (`--top-module seg7_cmp`) | 合った |
| 16 通りの seg (16 進) | 3f 06 5b 4f 66 6d 7d 07 7f 6f 77 7c 39 5e 79 71 | 同じ | 合った |
| same が 0 の入力 | 0 通り | 0 通り | 合った |
| 図 2 のパターン | a〜g の 7 本 | seg の各ビットを読んだ並びと一致 | 合った |
| 「見るべき値」の t1〜t4 と e (ゲート) | 16 行の表 | 式から計算した 16 行と一致 | 合った |
| e が 1 になる数 | 10 通り | 10 通り (0・2・6・8・A〜F) | 合った |
| 図 1 のつながり | T1 = d3·d2、T2 = d3·d1、T3 = ~d2·~d0、T4 = d1·~d0 | ネットリストと一致 | 合った |

実行結果の見出し行は `# d seg same` と出る (本文の表示のとおり)。

## 出典

自作。
