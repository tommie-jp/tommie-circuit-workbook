`timescale 1ns / 1ps
// 送り手の 1 ビットの長さを、受け手の 1 ビット (16 クロック x 13 us = 208 us) の (1 + ずれ) 倍にして、
// 7-2 の uart_rx で受ける。ずれを SKEW0 から SKEW1 まで SKEWD ずつ (単位は 0.01 %) 変え、
// 各ずれで 0x00〜0xFF を字の間をあけずに送って、正しく受けた字を数える
module tb_skew;
    parameter integer SKEW0 = -800, SKEW1 = 800, SKEWD = 50;
    localparam real BIT_RX_NS = 208000.0;      // 受け手の 1 ビット

    reg clk;
    initial begin
        clk = 1'b0;
        forever #6500 clk = ~clk;              // 13 us
    end
    reg  rst;
    reg  line;
    wire [7:0] data;
    wire valid, frame_err, sample;
    uart_rx dut (.clk(clk), .rst(rst), .rxd(line),
                 .data(data), .valid(valid), .frame_err(frame_err), .sample(sample));

    integer nok, nbad, nframe;
    real    tfirst, bt;                        // 最初の字の頭の時刻と、送り手の 1 ビットの長さ
    integer idx;
    reg     fe_d;

    // valid は字の頭から 9〜10.4 ビット後に来る。時刻から何字目かを決めて、その字と突き合わせる
    always @(posedge clk) begin
        if (valid) begin
            idx = $rtoi((($realtime - tfirst) / bt - 9.7) / 10.0 + 0.5);
            if (data === idx[7:0]) nok = nok + 1;
            else                   nbad = nbad + 1;
        end
        fe_d <= frame_err;
        if (frame_err && !fe_d) nframe = nframe + 1;   // フレームエラーは立ち上がりで数える
    end

    task automatic send(input [7:0] b, input real bit_ns);
        integer k;
        begin
            line = 1'b0; #(bit_ns);
            for (k = 0; k < 8; k = k + 1) begin
                line = b[k]; #(bit_ns);
            end
            line = 1'b1; #(bit_ns);
        end
    endtask

    integer skew, i;
    initial begin
        line = 1'b1; rst = 1'b1; fe_d = 1'b0;
        #40000 rst = 1'b0;
        #1000000;
        $display("skew(%%)   ok  bad  lost  frame_err");
        for (skew = SKEW0; skew <= SKEW1; skew = skew + SKEWD) begin
            bt = BIT_RX_NS * (1.0 + skew * 0.0001);
            nok = 0; nbad = 0; nframe = 0;
            rst = 1'b1; #40000 rst = 1'b0;
            #(10 * BIT_RX_NS);
            for (i = 0; i < 256; i = i + 1) begin
                if (i == 0) tfirst = $realtime;
                send(i[7:0], bt);
            end
            #(5 * BIT_RX_NS);
            $display("%6.2f   %3d  %3d  %4d  %4d", skew * 0.01, nok, nbad, 256 - nok - nbad, nframe);
        end
        $finish;
    end
endmodule
