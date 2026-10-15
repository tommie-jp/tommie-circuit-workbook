`timescale 1ns / 1ps
// 送り手 (AD3 の Protocol の代わり) から 0x00〜0xFF を送り、echo_top が返す字を 4800 bps で受けて数える。
// SKEW   : 送り手の 1 ビットの長さ / 受け手の 1 ビット (208 us = 16 クロック x 13 us)
// GAP_CLK: 字と字の間にあける時間 (クロック数)
module tb_echo;
    parameter real    SKEW    = 1.0;
    parameter integer GAP_CLK = 0;
    localparam real BIT_NS = 208000.0;

    reg clk;
    initial begin
        clk = 1'b0;
        forever #6500 clk = ~clk;              // 13 us
    end
    reg  rst;
    reg  line;
    wire txd, smp, err;
    echo_top dut (.clk(clk), .rst(rst), .rxd(line), .txd(txd), .smp(smp), .err(err));

    task automatic send(input [7:0] b);
        integer k;
        begin
            line = 1'b0; #(BIT_NS * SKEW);
            for (k = 0; k < 8; k = k + 1) begin
                line = b[k]; #(BIT_NS * SKEW);
            end
            line = 1'b1; #(BIT_NS * SKEW);
            if (GAP_CLK > 0) #(GAP_CLK * 13000.0);
        end
    endtask

    // 返ってきた字を読む。送った順に増えていれば正しい (取りこぼした字は抜ける)
    reg [7:0] rx;
    integer   b, nback = 0, last = -1, nbad = 0;
    initial begin
        #1000;
        forever begin
            @(negedge txd);
            #(BIT_NS * 1.5);
            for (b = 0; b < 8; b = b + 1) begin
                rx[b] = txd;
                #(BIT_NS);
            end
            if (rx > last[7:0] || last < 0) nback = nback + 1;
            else                            nbad  = nbad + 1;
            last = {24'd0, rx};
        end
    end

    // 最初の字の頭と、返しの頭の時刻
    realtime t_in, t_out;
    reg      seen_in = 1'b0, seen_out = 1'b0;
    always @(negedge line) if (!seen_in && !rst) begin t_in = $realtime; seen_in = 1'b1; end
    always @(negedge txd)  if (!seen_out && !rst) begin t_out = $realtime; seen_out = 1'b1; end

    integer i;
    initial begin
        line = 1'b1; rst = 1'b1;
        #26000 rst = 1'b0;
        #(5 * BIT_NS);
        for (i = 0; i < 256; i = i + 1) send(i[7:0]);
        #(30 * BIT_NS);
        $display("SKEW %5.2f  GAP %2d クロック: 送った 256 字、返った %3d 字、順番の乱れ %0d、err (LED) = %b",
                 SKEW, GAP_CLK, nback, nbad, err);
        if (SKEW == 1.0 && GAP_CLK == 0)
            $display("最初の字の頭から返しの頭まで %0.1f us", (t_out - t_in) / 1000.0);
        $finish;
    end
endmodule
