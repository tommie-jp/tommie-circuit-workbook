---
book: fpga
chapter: 8
id: 8-24
title: ROM の初期値を $readmemh で入れる — ブロック RAM に入れるか LUT にするか
tier: 100
source: 自作
board: —
device: FPGA
---

# 8-24 ROM の初期値を $readmemh で入れる — ブロック RAM に入れるか LUT にするか

> [!WARNING]
> **この題は実機が要らない。** 数はすべて合成 (yosys) の結果で、書き込みと測定は行っていない。
> Verilog は Verilator で動かして確かめた。

8-11 ではブロック RAM に入る RAM の書き方を合成の報告で読んだ。この題では、書き込みのポートが無い ROM に初期値を入れ、
それがブロック RAM に入るか LUT になるかを読む。

**組まない題である。** 実体配線図・Analog Discovery 3・`logic` の図は入れない。
メモリの配置の話で、ピンを使う回路は作らないため。

## 初期値を入れる — `$readmemh`

ROM の中身は、16 進のファイルから `$readmemh` で入れる (10-1)。ここでは、中身が `i × 7 + 3` の下位 8 ビットのファイル (`rom.hex`。
0 番地から 03・0a・11・18 …) で、256 語 × 8 の ROM を作る。

```verilog
// 256 語 × 8 ビットの ROM。中身は rom.hex から読む
module rom256 (
    input            clk,
    input      [7:0] addr,
    output reg [7:0] dout
);
    reg [7:0] mem [0:255];

    initial $readmemh("rom.hex", mem);

    always @(posedge clk) dout <= mem[addr];
endmodule
```

lint は警告 0 件。0・1・2・255 番地を読むと、`03` `0a` `11` `fc` が出た (255 × 7 + 3 = 1788 の下位 8 ビットは 0xfc)。

合成した結果は、**ブロック RAM でなく LUT** だった。

| 書き方 | yosys 0.33 | yosys 0.69 |
| --- | --- | --- |
| そのまま (`reg [7:0] mem [0:255];`) | LUT 33 + MUX2_LUT 26 + DFF 8 | LUT 33 + MUX2_LUT 26 + DFF 8 |
| `(* rom_style = "block" *)` を付ける | SPX9 × 1 | SPX9 × 1 |

- 書き込みのポートが無い (ROM の) メモリは、yosys は LUT の表に直す。256 語では LUT が 33 個ほど
- `(* rom_style = "block" *)` を `reg` の前に付けると、ブロック RAM 1 個になった。`(* ram_style = "block" *)` でも同じ結果だった (yosys 0.33 で確かめた)
- 付けたときの SPX9 の初期値のパラメータ (`INIT_RAM_00`) の先頭の 3 語は、`rom.hex` と同じ `03` `0a` `11` だった (`top.json` の中身を読んだ)。
  ブロック RAM の初期値はビットストリームに入って、電源を入れたときから入っている
- 小さな ROM は LUT に直すほうが、読みが速く、ブロックを使わない。大きな ROM を `block` にすると、LUT が空く

## 見るべき値

すべて合成の結果で、実機で測った値ではない。道具は yosys 0.33 と 0.69+274。

| 項目 | 見るべき値 | どこで得たか |
| --- | --- | --- |
| ROM 0・1・2・255 番地 | `03` `0a` `11` `fc` | Verilator |
| 256 語 × 8 の ROM | 既定で LUT 33 個、`rom_style = "block"` で SPX9 1 個 | yosys の `stat` |

実機で ROM の初期値を Logic で見るのは、この題では行っていない。

## シミュレーションでの確かめ

Verilator 5.042・Yosys 0.33・Yosys 0.70+16 で、本文の `rom256.v` を走らせ直した。`rom.hex` は `i × 7 + 3` の下位 8 ビットで作った。
置き場は 8-11 と同じ並びの `sim/11-block-ram-rom.v` `sim/11-block-ram-rom.hex` `sim/11-block-ram-rom-tb.v`。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint (`rom256.v`) | 警告 0 件 | 0 件 | 合った |
| ROM 0・1・2・255 番地 | 03・0a・11・fc | 同じ | 合った |
| ROM の合成 (そのまま) | LUT 33 + MUX2_LUT 26 + DFF 8 | 同じ | 合った |
| ROM に `rom_style` / `ram_style = "block"` | SPX9 × 1 | 同じ | 合った |
| ROM のそのまま (0.70+16) | LUT 33 + MUX2_LUT 26 + DFF 8 | 同じ | 合った |

## 出典

自作。

- `rom_style` / `ram_style` の属性: yosys の `memory_libmap` が受けた (結果を `stat` で確かめた)
- ブロック RAM の形 (`SPX9` ほか): OSS CAD Suite (2026-10-10) の yosys の `share/yosys/gowin/brams.txt`
