// tb_counter4.v
`timescale 1ns / 1ps
module tb_counter4;
    reg        clk;
    reg        rst_n;
    wire [3:0] q;

    counter4 dut (.clk(clk), .rst_n(rst_n), .q(q));

    initial begin                   // 100 ns 周期のクロック
        clk = 1'b0;
        forever #50 clk = ~clk;
    end

    initial begin
        $dumpfile("counter4.vcd");
        $dumpvars(0, tb_counter4);
        rst_n = 1'b0;
        #175 rst_n = 1'b1;          // 立ち上がりの合間に外す
        #1000;
        $display("q = %0d", q);
        $finish;
    end
endmodule
