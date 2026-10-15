`timescale 1ns / 1ps
// 1 クロック 13 µs (76.923 kHz) で回す。
// (1) hello_top の最初の 'H' の変わり目の時刻を書く
// (2) uart_tx で 0x00〜0xFF を続けて送り、4800 bps ちょうどで読む受け手 (このテストベンチの中) と突き合わせる
module tb_tx;
    localparam real BIT_NS = 1.0e9 / 4800.0;      // 208 333 ns
    reg clk;
    reg rst;
    initial begin
        clk = 1'b0;
        forever #6500 clk = ~clk;                  // 周期 13 µs
    end

    // (1)
    wire txd_hello;
    hello_top dut_hello (.clk(clk), .rst(rst), .txd(txd_hello));

    realtime t0;
    integer  nedge = 0;
    always @(txd_hello)
        if (!rst && nedge < 16) begin
            if (nedge == 0) t0 = $realtime;
            $display("hello: edge %0d txd=%b at %10.3f us (start + %8.3f us)",
                     nedge, txd_hello, $realtime / 1000.0, ($realtime - t0) / 1000.0);
            nedge = nedge + 1;
        end

    // (2)
    reg  [7:0] data;
    reg        start;
    wire       txd, busy;
    uart_tx dut_tx (.clk(clk), .rst(rst), .data(data), .start(start), .txd(txd), .busy(busy));

    integer i, errors = 0, got = 0;
    reg [7:0] rx;
    integer   b;

    // 4800 bps ちょうどの受け手: 立ち下がりから 1.5 ビット待ってから、1 ビットごとに読む
    initial begin
        #1000;
        forever begin
            @(negedge txd);
            #(BIT_NS * 1.5);
            for (b = 0; b < 8; b = b + 1) begin
                rx[b] = txd;
                #(BIT_NS);
            end
            if (txd !== 1'b1) begin
                errors = errors + 1;
                $display("stop bit error at byte %0d", got);
            end
            if (rx !== got[7:0]) begin
                errors = errors + 1;
                $display("NG: sent %02h got %02h", got[7:0], rx);
            end
            got = got + 1;
        end
    end

    initial begin
        rst = 1'b1; start = 1'b0; data = 8'h00;
        #26000 rst = 1'b0;
        for (i = 0; i < 256; i = i + 1) begin
            @(negedge clk);
            while (busy) @(negedge clk);
            data  = i[7:0];
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;
            @(negedge clk);                       // busy が 1 になるのを待つ
        end
        while (busy) @(negedge clk);
        #(BIT_NS);
        $display("bytes %0d, errors %0d", got, errors);
        if (got == 256 && errors == 0) $display("PASS");
        else                            $display("FAIL");
        $finish;
    end
endmodule
