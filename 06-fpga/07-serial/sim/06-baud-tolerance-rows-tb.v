`timescale 1ns / 1ps
// 実機の表の各行 (uart_tx の分周 DIV と、クロックの周期 TCLK_US) を再現する。
// 送り手は 7-1 の uart_tx を DIV クロックの分周で動かし、受け手は 7-2 の uart_rx (13 us・4800 bps の設定)。
// 0x00〜0xFF を字の間 2 クロックで続けて送り、正しく受けた字を数える
module row #(
    parameter integer DIV     = 16,
    parameter integer TCLK_US = 13
);
    reg txclk;
    initial begin txclk = 1'b0; forever #(TCLK_US * 500) txclk = ~txclk; end
    reg rxclk;
    initial begin rxclk = 1'b0; forever #6500 rxclk = ~rxclk; end

    reg        rst;
    reg  [7:0] data;
    reg        start;
    wire       txd, busy;
    uart_tx #(.CLK_HZ(DIV * 4800), .BAUD(4800)) tx (
        .clk(txclk), .rst(rst), .data(data), .start(start), .txd(txd), .busy(busy));

    wire [7:0] rdata;
    wire       valid, ferr, smp;
    uart_rx rx (.clk(rxclk), .rst(rst), .rxd(txd), .data(rdata), .valid(valid), .frame_err(ferr), .sample(smp));

    localparam real BIT_NS = DIV * TCLK_US * 1000.0;     // 送り手の 1 ビット
    real    ts [0:255];                                  // 各字を送り始めた時刻
    integer nok, nferr, idx, i, k;
    reg     fe_d;

    always @(posedge rxclk) begin
        fe_d <= ferr;
        if (ferr && !fe_d) nferr = nferr + 1;
        if (valid) begin
            // いま受けた字は、頭から 8.5 ビット以上たった字のうち、いちばん後ろの字
            idx = -1;
            for (k = 0; k < 256; k = k + 1)
                if (ts[k] > 0.0 && ts[k] + 8.5 * BIT_NS <= $realtime) idx = k;
            if (idx >= 0 && rdata === idx[7:0]) nok = nok + 1;
        end
    end

    initial begin
        nok = 0; nferr = 0; fe_d = 1'b0;
        for (i = 0; i < 256; i = i + 1) ts[i] = 0.0;
        rst = 1'b1; start = 1'b0; data = 8'h00;
        #(40 * 1000) rst = 1'b0;
        #(10 * 208000);
        @(negedge txclk);
        for (i = 0; i < 256; i = i + 1) begin
            @(negedge txclk);
            while (busy) @(negedge txclk);
            data  = i[7:0];
            ts[i] = $realtime;
            start = 1'b1;
            @(negedge txclk);
            start = 1'b0;
            @(negedge txclk);
        end
        while (busy) @(negedge txclk);
        #(3 * 208000);
        $display("%2d x %2d us = %3d us  ずれ %6.2f %%  受けた字 %3d / 256  フレームエラー %2d",
                 DIV, TCLK_US, DIV * TCLK_US, (BIT_NS / 208000.0 - 1.0) * 100.0, nok, nferr);
    end
endmodule

module tb_rows;
    localparam integer N = 12;
    localparam integer DIVS  [0:N-1] = '{16, 15, 14, 18, 20, 17, 16, 15, 18, 20, 17, 16};
    localparam integer TCLKS [0:N-1] = '{12, 13, 14, 11, 10, 12, 13, 14, 12, 11, 13, 14};
    genvar g;
    generate
        for (g = 0; g < N; g = g + 1) begin : rows
            row #(.DIV(DIVS[g]), .TCLK_US(TCLKS[g])) u ();
        end
    endgenerate
    initial begin
        #1000000000;             // 1 s あれば全部の行が終わる
        $finish;
    end
endmodule
