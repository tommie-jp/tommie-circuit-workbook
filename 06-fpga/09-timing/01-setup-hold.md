---
book: fpga
chapter: 9
id: 9-1
title: セットアップとホールド — クロックの前後で動かしてはいけない時間
tier: 50
source: 自作
board: —
device: SIM
---

# 9-1 セットアップとホールド — クロックの前後で動かしてはいけない時間

2-1 の D フリップフロップ (D-FF) は、クロックの立ち上がりの瞬間の D を取り込んだ。
シミュレーションでは「瞬間」に幅が無いので、立ち上がりの 1 ns 前に D が変わっても、きれいに取り込める。

実物の D-FF は違う。D を取り込むには、立ち上がりの前にしばらく D が止まっていて、後にもしばらく止まっている必要がある。

- **セットアップ時間** (t<sub>su</sub>): 立ち上がりの前に、D を動かしてはいけない時間
- **ホールド時間** (t<sub>h</sub>): 立ち上がりの後に、D を動かしてはいけない時間

この 2 つを合わせた「窓」の中で D が変わると、Q が 0 になるか 1 になるかは決まらない。
Q が 0 と 1 の間でしばらく止まり、決まるまで時間がかかることもある。これを **メタステーブル** と呼ぶ (9-6 で見る)。

この題は PC の Verilator だけで動かす。組まない題なので、実体配線図と Analog Discovery 3 は入れない。

## 説明

- 窓を守るのは回路を作る人の仕事だ。FPGA の道具 (配置配線) は、回路の中の線の遅れを足し合わせて、
  どのフリップフロップでも窓が守られるかを調べる。守れる一番速いクロックが最高の動作周波数になる (9-3)
- Verilator は信号を 0 と 1 の 2 値で扱い、線の遅れも持たない。窓の中で D が変わっても、Q は 0 か 1 のどちらかにきれいに決まる。
  **シミュレーションでセットアップ違反とホールド違反は再現できない**
- Verilog には違反を調べる書き方 (`specify` の中の `$setuphold`) がある。しかし Verilator はこれを黙って読み飛ばす
  (下の「動かす」で確かめた)
- そこでこの題では、テストベンチに自分で時刻を数える検査を書き、違反した所を言わせる。Q の値は Verilator が決めたままで、
  実物と同じにはならない。何が見せられて、何が見せられないかは「見るべき値」の最後にまとめる
- t<sub>su</sub> = 2 ns・t<sub>h</sub> = 1 ns は、窓を見せるために決めた仮の値だ。実物の値は FPGA の品種と、
  線の遅れで変わる。実物の数は配置配線の報告で読む (9-3)

Soft-FPGA (第 4・5 章) では、この決まりが無い。Verilator が作った C++ は、入力を書いてから `eval()` で 1 クロック分を計算する。
D が立ち上がりの「近く」で変わる、という時刻がそもそも無い。窓は実物の FPGA だけの決まりだ。

## 論理図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 D フリップフロップ。窓の中で D を動かさない
parts:
  D: port 2,5
  CLK: port 2,7
  U1:
    type: ic3
    at: 6,5
    label: D-FF
    pins: [D, CLK, Q]
  Q: port 10,5
wires:
  - 2,5 -- U1.D
  - 2,7 -- 6,7 -- U1.CLK
  - U1.Q -- 10,5
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/09-timing/circuit/01-setup-hold.svg)

## Verilog

D-FF は 2-1 と同じだ。

```verilog
// dff.v
module dff (
    input  wire clk,
    input  wire d,
    output reg  q
);
    always @(posedge clk)
        q <= d;
endmodule
```

## テストベンチ

クロックは 10 ns 周期 (100 MHz) で、立ち上がりは 5・15・25・… ns。
D は 4 回変える。2 回は窓の外、1 回はセットアップの窓、1 回はホールドの窓の中だ。

```verilog
// tb_setup_hold.v
module tb_setup_hold;
    localparam real TSU = 2.0;   // セットアップ時間 (仮の値、ns)
    localparam real TH  = 1.0;   // ホールド時間 (仮の値、ns)

    reg  clk = 0;
    reg  d   = 0;
    reg  win = 0;                // 動かしてはいけない窓 (立ち上がりの 2 ns 前から 1 ns 後)
    wire q;

    dff u (.clk(clk), .d(d), .q(q));

    always #5 clk = ~clk;        // 立ち上がりは 5, 15, 25, ... ns (100 MHz)
    always begin                 // 窓は 3〜6, 13〜16, ... ns
        #3 win = 1;
        #3 win = 0;
        #4;
    end

    // セットアップとホールドを数える (Verilator はこれを代わりにしてくれない)
    real t_clk = -100.0;         // 直前の立ち上がりの時刻
    real t_d   = -100.0;         // 直前に D が変わった時刻
    integer ng = 0;
    always @(posedge clk) begin
        if ($realtime - t_d < TSU) begin
            ng = ng + 1;
            $display("%5.1f ns: セットアップ違反 (D は %3.1f ns 前に変わった)", $realtime, $realtime - t_d);
        end
        t_clk = $realtime;
    end
    always @(d) begin
        if ($realtime - t_clk < TH) begin
            ng = ng + 1;
            $display("%5.1f ns: ホールド違反 (立ち上がりの %3.1f ns 後に D が変わった)", $realtime, $realtime - t_clk);
        end
        t_d = $realtime;
    end

    initial begin
        $dumpfile("setup_hold.vcd");
        $dumpvars(0, tb_setup_hold);
        #10   d = 1;             // 10 ns: 立ち上がり 15 の 5 ns 前 (守っている)
        #14   d = 0;             // 24 ns: 立ち上がり 25 の 1 ns 前 (セットアップ違反)
        #11.5 d = 1;             // 35.5 ns: 立ち上がり 35 の 0.5 ns 後 (ホールド違反)
        #16.5 d = 0;             // 52 ns: 立ち上がり 55 の 3 ns 前 (守っている)
        #8    $display("違反 %0d 件", ng);
        $finish;
    end
endmodule
```

- 立ち上がりのたびに「D が最後に変わってから何 ns たったか」を見る。`TSU` より短ければセットアップ違反
- D が変わるたびに「最後の立ち上がりから何 ns たったか」を見る。`TH` より短ければホールド違反
- `win` は窓を波形で見せるための信号で、回路には関係しない

## 動かす

```bash
verilator --lint-only -Wall dff.v
verilator --timescale 1ns/100ps --binary --timing --trace --top-module tb_setup_hold dff.v tb_setup_hold.v
./obj_dir/Vtb_setup_hold
```

1 行目の lint は、回路 (`dff.v`) を警告 0 件で通った。テストベンチは 2-1 と同じく `-Wall` を付けずに組む
(テストベンチの初期値の書き方に、回路向けの警告が出るため)。Verilator は 5.042 を使った。
実行すると次の 3 行が出た。

```text
 25.0 ns: セットアップ違反 (D は 1.0 ns 前に変わった)
 35.5 ns: ホールド違反 (立ち上がりの 0.5 ns 後に D が変わった)
違反 2 件
```

### `$setuphold` は読み飛ばされる

`dff.v` に次の 3 行を足して、窓を Verilog で書いてみる。

```verilog
    specify
        $setuphold(posedge clk, d, 2, 1);
    endspecify
```

`verilator --lint-only -Wall` は警告 0 件で通った。
テストベンチから自分で書いた検査 (2 つの `always`) を外して同じ D を与えると、違反の 2 件は 1 行も出なかった。
Verilator は `$setuphold` を受け付けるが、調べない。違反を見たければ、上のように自分で数えるか、
タイミングを調べる道具 (配置配線の報告、9-3) を使う。

## シミュレーションの波形

VCD (3-2) を読んで、ロジックアナライザの画面と同じ形に描いた。
実機で測った波形ではなく、シミュレーションの値だ。WIN はテストベンチの `win` で、窓の中で 1 になる。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図2 窓 (WIN) の中で D が変わっても、Verilator の Q はきれいに決まる
device: generic
time: 6ns/div
signals:
  CLK: pattern 010101010101 bit 5ns
  WIN: edges 0s=0 3ns=1 6ns=0 13ns=1 16ns=0 23ns=1 26ns=0 33ns=1 36ns=0 43ns=1 46ns=0 53ns=1 56ns=0
  D:   edges 0s=0 10ns=1 24ns=0 35.5ns=1 52ns=0
  Q:   edges 0s=0 15ns=1 25ns=0 45ns=1 55ns=0
cursors: [24.5ns, 28ns]
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/09-timing/logic/01-setup-hold.svg)

## 見るべき値 (シミュレーションを実行して得た値)

| 立ち上がり | D が変わった時刻 | 窓との関係 | 検査の言うこと | Verilator の Q |
| --- | --- | --- | --- | --- |
| 15 ns | 10 ns (0 → 1) | 5 ns 前。窓の外 | なし | 1 |
| 25 ns | 24 ns (1 → 0) | 1 ns 前。セットアップの窓 (23〜25 ns) の中 | セットアップ違反 | 0 |
| 35 ns | 35.5 ns (0 → 1) | 0.5 ns 後。ホールドの窓 (35〜36 ns) の中 | ホールド違反 | 0 のまま |
| 45 ns | (35.5 ns から 1) | 窓の外 | なし | 1 |
| 55 ns | 52 ns (1 → 0) | 3 ns 前。窓の外 | なし | 0 |

- 図2のカーソル X1 = 24.5 ns は窓の中で、WIN = 1・D = 0・Q = 1。X2 = 28 ns は窓を出た後で、WIN = 0・D = 0・Q = 0。
  D は 24 ns に窓の中で変わったのに、Verilator の Q は 25 ns の立ち上がりで迷わず 0 になった
- 35 ns では、Verilator は立ち上がりの時点の D (0) を取り込んだ。0.5 ns 後の変化は Q に出ない
- 窓の外の 3 回 (15・45・55 ns) は、実物でもこの表のとおりに取り込める

**見せられたこと**: どの立ち上がりで窓を破ったか (時刻と、何 ns 足りなかったか)。

**見せられないこと**: 窓を破ったときの実物の Q。25 ns と 35 ns の Q は、実物では 0 か 1 か決まらず、
決まるまでの時間も延びることがある。表の「Verilator の Q」の 0 は、シミュレータが選んだ値にすぎない。
実物の t<sub>su</sub>・t<sub>h</sub> の数と、それを守れる最高の周波数は、この PC では出していない
(この題では出していない。配置配線の道具 nextpnr の見積りは 06-fpga/09-timing/03-fmax-report.md (9-3) で扱う。実機の値は測って書く)。

## シミュレーションでの確かめ

Verilator 5.042 で、本文の `dff.v` と `tb_setup_hold.v` を取り出して走らせ直した。
置き場は `sim/01-setup-hold.v` と `sim/01-setup-hold-tb.v`。VCD (時間精度 100 ps) から D と Q の変化の時刻を読んだ。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint (`-Wall`、`dff.v`) | 警告 0 件 | 0 件 | 合った |
| 検査の出力 | 25.0 ns セットアップ違反 (1.0 ns 前)、35.5 ns ホールド違反 (0.5 ns 後)、違反 2 件 | 同じ 3 行 | 合った |
| D の変化の時刻 | 10・24・35.5・52 ns | 同じ | 合った |
| Q の変化の時刻 | 15 ns で 1、25 ns で 0、45 ns で 1、55 ns で 0 | 同じ | 合った |
| `$setuphold` を足した `dff.v` | lint 警告 0 件、違反の表示は 0 | lint 0 件。検査を外したテストベンチで実行しても何も出ない | 合った |

実物の t<sub>su</sub>・t<sub>h</sub> は、この題でも出していない (実機が要る)。
最高の周波数は 9-3 で nextpnr 0.11.1-63 (Yosys 0.70+16) を走らせて確かめた。

## 出典

自作。セットアップ時間・ホールド時間の定義と `$setuphold` は IEEE 1364-2005 (Verilog) の 15 章
(timing checks) による。Verilator が `specify` を調べないことは、Verilator 5.042 で上のとおり確かめた。
Verilator のマニュアルは [https://verilator.org/guide/latest/](https://verilator.org/guide/latest/)。
