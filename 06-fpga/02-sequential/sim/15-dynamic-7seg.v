// dyn7seg.v — 4 桁の 10 進カウンタを、1 クロックに 1 桁ずつ順に光らせる
module dyn7seg #(
    parameter CLK_HZ = 1000,     // 5-7 のタイマで決めた 1 kHz
    parameter BLANK  = 0         // 1: 桁を替える前に 1 クロックだけ全部消す (ゴースト対策)
) (
    input         clk,
    input         rst,
    output [7:0]  seg,           // {dp, g, f, e, d, c, b, a}。1 で点灯
    output [3:0]  dig,           // 1 の桁だけ光る。dig[3] が左端 (DIG1)
    output [15:0] value          // 4 桁の BCD {千, 百, 十, 一}。試験で見る
);
    // 1 秒に 1 クロックだけ 1 になる合図 (2-5・2-7)
    wire en_sec;
    tick #(.CLK_HZ(CLK_HZ), .TICK_HZ(1)) t_sec (.clk(clk), .rst(rst), .en(en_sec));

    // 0000〜9999 を数える。下の桁の carry を上の桁の en に (2-9)
    wire [3:0] d0, d1, d2, d3;
    wire       c0, c1, c2;

    bcd_digit u0 (.clk(clk), .rst(rst), .en(en_sec), .q(d0), .carry(c0));
    bcd_digit u1 (.clk(clk), .rst(rst), .en(c0),     .q(d1), .carry(c1));
    bcd_digit u2 (.clk(clk), .rst(rst), .en(c1),     .q(d2), .carry(c2));
    /* verilator lint_off PINCONNECTEMPTY */    // 9999 の次は 0000。千の位の carry は使わない
    bcd_digit u3 (.clk(clk), .rst(rst), .en(c2),     .q(d3), .carry());
    /* verilator lint_on PINCONNECTEMPTY */

    // 光らせる桁の番号 pos (0 が左端)。BLANK = 1 なら、光らせた次の 1 クロックは dark で全部消す
    reg [1:0] pos;
    reg       dark;

    always @(posedge clk)
        if (rst) begin
            pos  <= 2'd0;
            dark <= 1'b0;
        end else if (BLANK == 0) begin
            pos  <= pos + 2'd1;             // 1 クロックごとに次の桁へ
        end else begin
            dark <= ~dark;                  // 光る・消すを 1 クロックずつ
            if (!dark) pos <= pos + 2'd1;   // 消している間に次の桁へ進めておく
        end

    // pos の桁の数を選んで a〜g に直す
    reg [3:0] shown;
    always @(*)
        case (pos)
            2'd0:    shown = d3;
            2'd1:    shown = d2;
            2'd2:    shown = d1;
            default: shown = d0;
        endcase

    wire [6:0] abc;
    seg7 dec (.d(shown), .seg(abc));

    assign seg   = dark ? 8'd0 : {1'b0, abc};          // 点 (dp) は使わない
    assign dig   = dark ? 4'd0 : (4'b1000 >> pos);
    assign value = {d3, d2, d1, d0};
endmodule

// CLK_HZ を数えて、TICK_HZ の速さで 1 クロックだけ en を 1 にする (2-5 のクロックイネーブル)
module tick #(
    parameter CLK_HZ  = 27_000_000,
    parameter TICK_HZ = 1
) (
    input      clk,
    input      rst,
    output reg en
);
    localparam N = CLK_HZ / TICK_HZ;
    localparam W = (N > 1) ? $clog2(N) : 1;

    localparam [W-1:0] LAST = N[W-1:0] - 1'b1;

    reg [W-1:0] cnt;

    always @(posedge clk)
        if (rst) begin
            cnt <= {W{1'b0}};
            en  <= 1'b0;
        end else if (cnt == LAST) begin
            cnt <= {W{1'b0}};
            en  <= 1'b1;
        end else begin
            cnt <= cnt + 1'b1;
            en  <= 1'b0;
        end
endmodule

// bcd_digit.v
module bcd_digit (
    input            clk,
    input            rst,
    input            en,
    output reg [3:0] q,
    output           carry
);
    assign carry = en && (q == 4'd9);

    always @(posedge clk)
        if (rst)     q <= 4'd0;
        else if (en) q <= (q == 4'd9) ? 4'd0 : q + 4'd1;
endmodule

// seg7.v
module seg7 (
    input      [3:0] d,
    output reg [6:0] seg
);
    always @(*)
        case (d)
            4'd0:    seg = 7'b0111111;
            4'd1:    seg = 7'b0000110;
            4'd2:    seg = 7'b1011011;
            4'd3:    seg = 7'b1001111;
            4'd4:    seg = 7'b1100110;
            4'd5:    seg = 7'b1101101;
            4'd6:    seg = 7'b1111101;
            4'd7:    seg = 7'b0000111;
            4'd8:    seg = 7'b1111111;
            4'd9:    seg = 7'b1101111;
            default: seg = 7'b0000000;
        endcase
endmodule
