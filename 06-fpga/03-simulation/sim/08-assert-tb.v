// tb_assert.v
`timescale 1ns/1ps
module tb_assert;
    reg        clk;
    reg        rst_n;
    reg        en;
    wire [3:0] q;
    reg  [3:0] q_prev;       // 1 つ前の谷での q
    reg        en_prev;      // 1 つ前の谷での en
    reg        rst_prev;     // 1 つ前の谷での rst_n

    dec_counter dut (.clk(clk), .rst_n(rst_n), .en(en), .q(q));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // クロックの谷 (立ち下がり) で、起きてはいけないことを見張る
    always @(negedge clk) begin
        // 1. q は 9 を超えない
        assert (q <= 4'd9)
            else $error("q が 9 を超えた: q=%0d", q);
        // 2. en が 0 だった直後のクロックでは q が変わらない
        if (rst_prev && !en_prev)
            assert (q == q_prev)
                else $error("en=0 なのに q が %0d から %0d に変わった", q_prev, q);
        q_prev   <= q;
        en_prev  <= en;
        rst_prev <= rst_n;
    end

    initial begin
        rst_n = 1'b0;
        en    = 1'b1;
        repeat (2) @(posedge clk);
        #1 rst_n = 1'b1;
        repeat (12) @(posedge clk);
        #1 en = 1'b0;                  // 5 クロックのあいだ止める
        repeat (5) @(posedge clk);
        #1 en = 1'b1;
        repeat (12) @(posedge clk);
        #1;
        $display("終わり q=%0d", q);
        $finish;
    end
endmodule
