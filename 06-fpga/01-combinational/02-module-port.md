---
book: fpga
chapter: 1
id: 1-2
title: module と port — 回路を箱にして呼ぶ
tier: 50
source: 自作
board: —
device: SIM
---

# 1-2 module と port — 回路を箱にして呼ぶ

1-1 では 1 つの module の中に assign を並べた。大きな回路は、小さな回路を箱 (module) にして、
別の module から呼んで組み立てる。この題では、AND・OR・NOT で XOR の箱 `my_xor` を作り、
それを 2 回呼んで 3 入力のパリティ (1 の数が奇数かどうか) を作る。

この題は組まない題で、実体配線図と Analog Discovery 3 は付けない。PC の中だけで動かす (`device: SIM`)。

## 説明

- **module** は回路の箱。名前と **ポート** (外とやりとりする口) を持つ
- 別の module の中で箱を呼ぶことを **インスタンス化** という。同じ箱を何回呼んでもよく、呼ぶたびに別の回路が 1 つできる
- 呼ぶときは `箱の名前 インスタンスの名前 (.ポート名(つなぐ線), …);` と書く。
  ポートを名前で指す書き方 (`.a(a)`) なら、ポートの並び順を覚えなくてよく、つなぎ間違いに気づきやすい
- 箱の中でしか使わない線は `wire` で宣言する。外に出さない内部の線だ

## 論理図

図 1 は `my_xor` の中身だ。XOR は「a と b のどちらか一方だけが 1」のときに 1 になる。
OR (a か b が 1) から AND (両方 1) を引いた形で、`(a | b) & ~(a & b)` と書ける。

```circuit
title: 図1 my_xor の中身 (論理図)
parts:
  a: port b1
  b: port j1
  G1: or b8
  G2: and f8
  G3: not f13
  G4: and d19
  y: port d24
wires:
  - b1 -- b3
  - b3 -- e3
  - b3 |- G1.a
  - e3 |- G2.a
  - j1 -- j5
  - j5 -- c5
  - c5 |- G1.b
  - i5 |- G2.b
  - G2.out -- G3.in
  - G1.out -- b17
  - b17 |- G4.a
  - G3.out -- f15
  - f15 |- G4.b
  - G4.out -- d24
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/circuit/02-module-port-1.svg)

- G1 の出力が `a_or_b`、G2 の出力が `a_and_b`、G3 でそれを反転し、G4 で G1 の出力と AND を取る
- a の横線は b の縦線と 1 か所で交わる。黒丸が無いので、つながっていない

図 2 は、この箱を 2 つつないだ `parity3` だ。a と b を 1 つ目の XOR に入れ、その出力と c を 2 つ目の XOR に入れる。
図の X1 が Verilog の `u_ab`、X2 が `u_y` に当たる。

```circuit
title: 図2 parity3 は my_xor を 2 つつなぐ (X1 が u_ab、X2 が u_y)
parts:
  a: port d1
  b: port h1
  c: port l1
  X1: xor f9
  X2: xor j19
  y: port j25
wires:
  - d1 -- d4
  - d4 |- X1.a
  - h1 -- h4
  - h4 |- X1.b
  - X1.out -- f14
  - f14 |- X2.a
  - l1 -- l4
  - l4 |- X2.b
  - X2.out -- j25
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/circuit/02-module-port-2.svg)

## Verilog

まず箱を作る。

```verilog
// my_xor.v
module my_xor (
    input  wire a,
    input  wire b,
    output wire y
);
    wire a_or_b  = a | b;
    wire a_and_b = a & b;
    assign y = a_or_b & ~a_and_b;
endmodule
```

次に、その箱を 2 回呼ぶ。

```verilog
// parity3.v
module parity3 (
    input  wire a,
    input  wire b,
    input  wire c,
    output wire y
);
    wire ab;
    my_xor u_ab (.a(a),  .b(b), .y(ab));
    my_xor u_y  (.a(ab), .b(c), .y(y));
endmodule
```

- `my_xor u_ab (.a(a), .b(b), .y(ab));` は、`my_xor` の箱を `u_ab` という名前で 1 つ作り、
  箱のポート a に外の線 a、ポート b に外の線 b、ポート y に内部の線 `ab` をつなぐ、という意味だ
- 内部の線 `ab` が、図 2 の X1 から X2 へ渡る線に当たる
- ファイルの名前は module の名前に合わせた。Verilator の `-Wall` は、名前が違うと警告する

## 動かす

```cpp
// tb_parity3.cpp
#include <cstdio>
#include "Vparity3.h"

int main() {
    Vparity3 top;
    std::printf("# a b c y\n");
    for (int i = 0; i < 8; i++) {
        top.a = (i >> 2) & 1;
        top.b = (i >> 1) & 1;
        top.c = i & 1;
        top.eval();
        std::printf("%x %x %x %x\n", top.a, top.b, top.c, top.y);
    }
    return 0;
}
```

```bash
verilator --lint-only -Wall parity3.v my_xor.v
verilator -Wall --cc --exe --build parity3.v my_xor.v tb_parity3.cpp
./obj_dir/Vparity3
```

Verilator は、呼ばれていない側の module を自動で見つけ、いちばん外側 (最上位) として組み立てる。
ここでは `parity3` が最上位になり、実行ファイルは `Vparity3` になる。実行した結果は次のとおりだった。

```text
a b c y
0 0 0 0
0 0 1 1
0 1 0 1
0 1 1 0
1 0 0 1
1 0 1 0
1 1 0 0
1 1 1 1
```

## 計器の設定

組まない題なので、計器は使わない。実行結果を、ロジックアナライザの画面と同じ形の図 3 に描く。
実機で測った波形ではなく、上の実行結果から作った計算の図で、入力を変えた 1 回を 1 ms と見なして並べた。

```logic
title: 図3 a b c を 000 から 111 まで順に変えたときの y (Verilator の実行結果から作った計算の図)
device: generic
window: 8ms
signals:
  a: pattern 00001111 bit 1ms
  b: pattern 00110011 bit 1ms
  c: pattern 01010101 bit 1ms
  y: pattern 01101001 bit 1ms
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/logic/02-module-port.svg)

## 見るべき値

y は、a・b・c のうち 1 になっている数が奇数のときに 1 になる。

| a | b | c | 1 の数 | y |
| --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 | 1 |
| 0 | 1 | 0 | 1 | 1 |
| 0 | 1 | 1 | 2 | 0 |
| 1 | 0 | 0 | 1 | 1 |
| 1 | 0 | 1 | 2 | 0 |
| 1 | 1 | 0 | 2 | 0 |
| 1 | 1 | 1 | 3 | 1 |

- 実行結果の 8 行が、この表と同じ並びになっている
- 同じ表は、`parity3` の中の `my_xor` を `a ^ b` に書き換えても変わらない。箱の中身を替えても、ポートが同じなら外から見た働きは同じだ

## 出典

自作。
