---
book: fpga
chapter: 8
id: 8-23
title: 使われないレジスタは合成で消える — TD4 の 17 ビットが 12 個になる理由
tier: 100
source: 自作
board: —
device: FPGA
---

# 8-23 使われないレジスタは合成で消える — TD4 の 17 ビットが 12 個になる理由

> [!WARNING]
> **この題は実機が要らない。** 合成 (yosys) は手元の PC で実際に回して数を取った。
> ボードへの書き込みと AD3 での測定は、この題では行わない。数はすべて「合成の結果」で、測った値ではない。

8-8 では合成の報告の数を読んだ。この題では、その数が Verilog の `reg` の数より少ないわけを、8-22 の `top_td4` で読む。

**組まない題である。** 実体配線図・Analog Discovery 3・`logic` の図は入れない。
道具の出力を読むだけで、配線も信号も無いため。

## FF が消える — 17 ビットが 12 個になる理由

8-22 では、TD4 のレジスタが A・B・OUT・PC の 4 ビット × 4 と桁上げの 1 ビットで 17 ビットあるのに、
合成した FF の中で TD4 の分は 12 個だと書いた (DFFC 4 + DFFCE 8)。何が消えたかを、`top_td4.json` の FF の名前から読む。

| TD4 のレジスタ | 合成後 | 理由 |
| --- | --- | --- |
| `pc` (4) | **残る** (DFFC) | 次の命令の番地。出力に効く |
| `reg_out` (4) | **残る** (DFFCE) | 出力ポートそのもの |
| `reg_a` (4) | **残る** (DFFCE) | NOP の行 (`A ← A + 0`) が自分の値を読んでいる |
| `reg_b` (4) | **消える** | ROM に B を書く命令 (`MOV B`・`ADD B`) が無く、読む命令 (`MOV A,B`・`OUT B`) も無い |
| `cflag` (1) | **消える** | 桁上げを見る `JNC` が ROM に無く、ジャンプは `JMP` だけ |

消えた理由が「ROM の中身」であることは、ROM に 3 行足して確かめた。
`TD4.v` の ROM の 10〜12 番地 (NOP) を、B を使う命令と桁上げを使う命令に替える (`TD4_b.v`)。

```verilog
    rom[4'b1010] = 8'b0111_0101; // 1010: MOV B,0101
    rom[4'b1011] = 8'b1001_0000; // 1011: OUT B
    rom[4'b1100] = 8'b1110_0000; // 1100: JNC 0000
```

```bash
verilator --lint-only --no-timing TD4_b.v
yosys -p "read_verilog top_td4.v blink.v TD4_b.v; synth_gowin -top top_td4; stat"
```

lint は警告 0 件。合成の結果は次のとおり。

| 回路 | FF の内訳 (yosys 0.33) | FF の合計 | LUT (0.33 / 0.69) |
| --- | --- | --- | --- |
| `top_td4` (元の ROM) | DFFC 4・DFFCE 8・DFFR 22・DFFRE 1 | 35 | 50 / 28 |
| `top_td4` (ROM に 3 行足した) | DFFC 4・DFFCE **12**・DFFP **1**・DFFR 22・DFFRE 1 | **40** | 56 / 44 |

- FF は 5 個増えた。`reg_b` の 4 個 (DFFCE) と、`cflag` の 1 個 (DFFP。リセットで 1 になるので、非同期プリセットの `P`)
- **足した 3 行は実行されない。** 9 番地の `JMP 0000` で頭に戻るので、10 番地には来ない。
  それでも FF は残った。**合成の道具は、その行が実行されるかを調べない。** ROM に書いてあれば、読む部品が必要だと見なす
- 逆に言うと、`reg_a` は実際には 0 のままだが、残った。合成は、命令の流れを追って「ここは常に 0」と証明する所までは行かない

報告を読むときは、`stat` の FF (`DFF…`) の合計を Verilog の `reg` の数と見比べる (8-8 の手順の 1)。少なければ、使われないレジスタが消えている。

## 見るべき値

すべて合成の結果で、実機で測った値ではない。道具は yosys 0.33 と 0.69+274。

| 項目 | 見るべき値 | どこで得たか |
| --- | --- | --- |
| `top_td4` の FF と、TD4 の分 | 35 個、うち TD4 は 12 個 | yosys の `stat` と `top_td4.json` |
| ROM に B と `JNC` を足したときの FF | +5 個 (35 → 40) | yosys の `stat` |

## シミュレーションでの確かめ

Yosys 0.33・Yosys 0.70+16 で、8-22 の `top_td4.v` を合成し直した。新しく起こした Verilog は無いので、`sim/` には置いていない。
TD4 を変えた `TD4_b.v` は、`TD4.v` の ROM の 10〜12 番地を `sed` で書き換えて作った (本文の 3 行)。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| `top_td4` (8-22) | FF 35 (DFFC 4・DFFCE 8・DFFR 22・DFFRE 1) | 同じ | 合った |
| `TD4_b.v` の lint | 警告 0 件 | 0 件 | 合った |
| `top_td4` + `TD4_b.v` | FF 40 (DFFC 4・DFFCE 12・DFFP 1・DFFR 22・DFFRE 1)、LUT 56 | 同じ | 合った |
| `top_td4` + `TD4_b.v` (0.70+16) | LUT 44 (0.69) | LUT 44・FF 40 | 合った |

## 出典

自作。

- 部品の名前と意味 (`DFFC` の非同期クリア、`DFFP` の非同期プリセット ほか): OSS CAD Suite (2026-10-10) に入っている yosys の
  `share/yosys/gowin/cells_sim.v` の模型と、その中のコメント
- `TD4.v`: [tommie-jp/Soft-FPGA-TD4](https://github.com/tommie-jp/Soft-FPGA-TD4) の `verilator-TD4/TD4.v`。元は
  [asfdrwe/simpleTD4](https://github.com/asfdrwe/simpleTD4) (MIT ライセンス)
