// tb_counter4.v
`timescale 1ns/1ps
module tb_counter4;
    reg        clk;
    reg        rst_n;
    wire [3:0] q;
    reg  [3:0] expected;       // 参照モデル: 期待値を別に数える
    integer    errors;

    counter4 dut (.clk(clk), .rst_n(rst_n), .q(q));

    initial clk = 1'b0;
    always #5 clk = ~clk;      // 周期 10 ns

    // 参照モデル。立ち上がりで、DUT と同じ rst_n を見て進める
    always @(posedge clk) begin
        if (!rst_n) expected <= 4'd0;
        else        expected <= expected + 4'd1;
    end

    // 比べるのは立ち下がり。立ち上がりの更新が済んだあとの安定した値を見る
    always @(negedge clk) begin
        if (q !== expected) begin
            errors <= errors + 1;
            if (errors < 3)
                $display("NG: %0t q=%0d, 期待は %0d", $time, q, expected);
        end
    end

    initial begin
        $timeformat(-9, 0, " ns", 5);
        $dumpfile("tb_counter4.vcd");
        $dumpvars(0, tb_counter4);
        errors = 0;
        rst_n  = 1'b0;
        repeat (2) @(posedge clk);
        #1 rst_n = 1'b1;                  // 2 クロックのあいだリセット
        repeat (20) @(posedge clk);
        #1;
        if (errors == 0) $display("PASS: 不一致 0 件");
        else             $display("FAIL: 不一致 %0d 件", errors);
        $finish;
    end
endmodule
