// DDS: 位相アキュムレータに毎クロック ftw を足し、位相の上位 AW ビットで正弦の表を引く。
// 出る周波数は ftw × CLK_HZ / 2^PW。表は sine.hex (sine.py で作る) をブロック RAM に入れる
module dds #(
    parameter PW = 32,      // 位相アキュムレータのビット数
    parameter AW = 10,      // 表の番地のビット数 (1024 語)
    parameter DW = 8        // DAC のビット数
) (
    input               clk,
    input               rst,
    input      [PW-1:0] ftw,      // 1 クロックに進む位相 (周波数の設定)
    output reg [DW-1:0] dac,      // R-2R へ出す値
    output              sync      // 位相の前半 (0〜π) だけ 1 の方形波。トリガに使う
);
    reg [PW-1:0] phase;

    (* rom_style = "block" *)
    reg [DW-1:0] sine [0:(1 << AW) - 1];

    initial $readmemh("sine.hex", sine);

    always @(posedge clk)
        if (rst) phase <= {PW{1'b0}};
        else     phase <= phase + ftw;

    // 読みをクロックに合わせる (8-11)。これでブロック RAM に入る
    always @(posedge clk)
        dac <= sine[phase[PW-1 -: AW]];

    assign sync = ~phase[PW-1];
endmodule
