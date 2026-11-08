// board_test.v: 学習ボードの入出力を全部確かめる
//   LED      : 下 4 個がスライドスイッチ、上 4 個が押しボタンをそのまま写す
//   7 セグ   : k 桁めに BTNk を押した回数 (16 進 0〜F)。点 (dp) は SWk
module board_test (
    input  wire       clk,       // 1 kHz (5-7 のタイマ)
    input  wire       rst,
    input  wire [3:0] sw,        // 1 = ON
    input  wire [3:0] btn,       // 1 = 押している
    output wire [7:0] led,       // 1 で点灯
    output wire [7:0] seg,       // {dp, g, f, e, d, c, b, a}。1 で点灯
    output wire [3:0] dig,       // 1 の桁だけ光る。dig[3] が左端
    output reg [15:0] cnt        // 4 桁の回数 {BTN3, BTN2, BTN1, BTN0}
);
    // 4 ビットのカウンタ。下 2 ビットが光らせる桁、16 クロック (16 ms) に 1 回ボタンを見る
    reg  [3:0] div;
    reg  [3:0] btn_q;            // 前に見たボタン
    wire       smp   = (div == 4'd15);
    wire [3:0] press = smp ? (btn & ~btn_q) : 4'b0000;

    always @(posedge clk)
        if (rst) begin
            div   <= 4'd0;
            btn_q <= 4'b0000;
            cnt   <= 16'h0000;
        end else begin
            div <= div + 4'd1;
            if (smp) btn_q <= btn;
            if (press[0]) cnt[3:0]   <= cnt[3:0]   + 4'd1;
            if (press[1]) cnt[7:4]   <= cnt[7:4]   + 4'd1;
            if (press[2]) cnt[11:8]  <= cnt[11:8]  + 4'd1;
            if (press[3]) cnt[15:12] <= cnt[15:12] + 4'd1;
        end

    // 光らせる桁 pos の回数を 7 セグの形に直す (1-8)
    wire [1:0] pos = div[1:0];
    wire [3:0] shown = cnt[{pos, 2'b00} +: 4];
    wire [6:0] abc;
    seg7_decoder dec (.d(shown), .seg(abc));

    assign seg = {sw[pos], abc};
    assign dig = 4'b0001 << pos;
    assign led = {btn, sw};
endmodule
