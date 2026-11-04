---
book: fpga
chapter: 6
id: 6-20
title: 合成して回路の大きさを数える — 状態の符号と、制御器・データパスの分け方
tier: 100
source: 自作
board: —
device: SIM
---

# 6-20 合成して回路の大きさを数える — 状態の符号と、制御器・データパスの分け方

この題は実体配線図・Analog Discovery 3・ロジックアナライザの図を付けない。PC の yosys で合成して数えるだけの題で、組む物が無いから。

6-5 (状態の符号) と 6-8 (制御器とデータパスを分ける) の Verilog を、yosys の `synth_gowin` (Tang Nano 9K の FPGA の部品に合成する) に通し、FF と LUT の数を数える。
配置と配線はしていない (版を替えて 1 回だけ走らせた結果は確かめの節に書いた)。
Verilog は 6-5・6-8 の本文のものをそのまま使い、ここには載せない。

## 状態の符号 (6-5)

6-5 の `seq_enc.v` (`ENC` で 2 進・ワンホット・グレイを選ぶ) と `seq_onehot.v` (ワンホットらしく書いた物) を合成する。

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

- 2 進とグレイは同じ大きさ。この回路では、符号を替えても式の複雑さはほとんど変わらない
- 5 ビット全部を比べる書き方のままワンホットにすると、FF が 3 から 5、LUT も 4 から 22 に増えた。ワンホットの得を使っていない
- ワンホットらしく書くと LUT は 5 に収まる (FF は 5)。**符号に合わせて式を書き直す**ところまでが 1 組
- yosys には状態レジスタの符号を自動で選び直す `fsm` パスがあるが、この回路では「利益が見込めない」として働かず (ログに `Not marking seq_enc.st as FSM state register`)、書いた符号のまま合成された

## 制御器とデータパス (6-8)

6-8 の分けた版 (`mul_top`・`mul_ctl`・`mul_dp`) と分けない版 (`mul_flat`) を合成する。

```bash
yosys -p "read_verilog -sv mul_top.v mul_ctl.v mul_dp.v; hierarchy -top mul_top; synth_gowin -top mul_top; stat"
```

| 書き方 | ALU | FF | LUT |
| --- | --- | --- | --- |
| 分けた (`mul_top`、`W = 8`) | 24 | 37 | 17 |
| 分けない (`mul_flat`、`W = 8`) | 24 | 37 | 32 |
| 分けた、`W = 4` | 12 | 21 | 17 |
| 分けた、`W = 16` | 48 | 69 | 30 |
| 制御器だけ (`mul_ctl`) | 0 | 5 | 5 |

(yosys 0.33、`synth_gowin`。FF は DFF と DFFRE の合計、LUT は LUT1〜LUT4 の合計。)

- ALU は 3 × `W` 個 (残りの回数の引き算が `W`、積の足し算が `2 * W`)、FF は 5 + 4 × `W` 個。幅を替えると、データパスだけが大きくなり、制御器の 5 FF は変わらない
- 分けない版の LUT が 15 個多い。差の原因は調べていない。**分けると回路が小さくなる、とは言えない**。この題で得るのは回路の小ささでなく、直す場所が分かれることである

## 見るべき値

PC の yosys (0.33) で実際に合成して得た値。実機はこの題に無い。

| 見る所 | 値 |
| --- | --- |
| 状態の符号 (FF / LUT) | 2 進 3 / 4、グレイ 3 / 4、ワンホット (同じ書き方) 5 / 22、ワンホットらしく 5 / 5 |
| 掛け算 (ALU / FF / LUT) | 分けた版 24 / 37 / 17、分けない版 24 / 37 / 32 |

## シミュレーションでの確かめ

yosys 0.33 で、6-5・6-8 の本文の Verilog を本文のコマンドのまま (`synth_gowin`) 合成し直した。原本は `sim/05-state-encoding.v`・`sim/05-state-encoding-onehot.v` と `sim/08-datapath-multiplier.v` (`mul_top`)・`-dp.v`・`-ctl.v`・`-flat.v`。
`seq_onehot` は `read_verilog -sv seq_onehot.v; synth_gowin -top seq_onehot` で数えた。`W` を替えた合成は `hierarchy -top mul_top -chparam W 4` (16) を付けて数えた。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
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
| 合成 (分けた、`W` = 8) | 24 / 37 / 17 | ALU 24、DFF 5 + DFFRE 32、LUT2 3 + LUT3 9 + LUT4 5 | 合った |
| 合成 (分けない、`W` = 8) | 24 / 37 / 32 | ALU 24、FF 37、LUT2 18 + LUT3 9 + LUT4 5 | 合った |
| 合成 (分けた、`W` = 4) | 12 / 21 / 17 | ALU 12、FF 21、LUT 17 (LUT1 6・LUT2 2・LUT3 6・LUT4 3) | 合った |
| 合成 (分けた、`W` = 16) | 48 / 69 / 30 | ALU 48、FF 69、LUT 30 (LUT1 2・LUT2 4・LUT3 17・LUT4 7) | 合った |
| 合成 (`mul_ctl` だけ) | 0 / 5 / 5 | ALU 0、DFF 5、LUT3 4 + LUT4 1 | 合った |
| 合成 (分けた、`W` = 8、Yosys 0.70+16) | 24 / 37 / 17 | ALU 24、DFF 5 + DFFRE 32、LUT2 3 + LUT3 9 + LUT4 5 = 17 | 合った |
| 合成 (分けない、`W` = 8、Yosys 0.70+16) | 24 / 37 / 32 | ALU 24、FF 37、LUT1 1 + LUT2 18 + LUT3 11 + LUT4 3 = 33 (ほかに MUX2_LUT5 1) | 近い (版の差。1 個多い) |
| 合成 (分けた、`W` = 4、Yosys 0.70+16) | 12 / 21 / 17 | ALU 12、FF 21、LUT2 3 + LUT3 7 + LUT4 2 = 12 | 近い (版の差。LUT が 5 個少ない) |
| 合成 (分けた、`W` = 16、Yosys 0.70+16) | 48 / 69 / 30 | ALU 48、FF 69、LUT1 2 + LUT2 4 + LUT3 17 + LUT4 7 = 30 (ほかに MUX2_LUT5 2) | 合った |
| 合成 (`mul_ctl` だけ、Yosys 0.70+16) | 0 / 5 / 5 | ALU 0、DFF 5、LUT3 4 + LUT4 1 | 合った |
| 配置配線の `Max frequency` (分けた、`W` = 8、`--freq 27`) | (本文に無い) | 233.54 MHz (PASS at 27.00 MHz)。LUT4 45、ALU 28、DFF 37 | 補足 |
| 配置配線の `Max frequency` (分けない、`W` = 8) | (本文に無い) | 422.48 MHz。LUT4 61、MUX2_LUT5 1、ALU 28、DFF 37 | 補足 |
| 配置配線の `Max frequency` (分けた、`W` = 4) | (本文に無い) | 295.60 MHz。LUT4 28、ALU 16、DFF 21 | 補足 |

配置配線は OSS CAD Suite の Yosys 0.70+16 と nextpnr-himbaechel 0.11.1-63 で走らせた。6-5 の回路は制約に `--freq 27` だけを渡した。
ピンは仮の番号で、`--seed` は振っていない。`Max frequency` の値は 1 回の実行のもので、9-3 のとおり数 % 動く。
分けた版の方が `Max frequency` は低く出た。理由は経路の報告まで読んでいないので確かめていない。
`W` = 16 は、仮に割り振るピンの数が足りず走らせていない。

## 出典

自作。合成した Verilog は 6-5 と 6-8。
yosys の `synth_gowin` は [Yosys のマニュアル](https://yosyshq.readthedocs.io/projects/yosys/en/latest/cmd/synth_gowin.html)。
