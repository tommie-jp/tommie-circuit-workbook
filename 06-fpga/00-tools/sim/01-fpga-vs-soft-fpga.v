// 0-1 の 3 行を module に包み、AND の結果が次の立ち上がりで q に入ることを確かめる
module and_ff (
    input  wire clk,
    input  wire a,
    input  wire b,
    output reg  q
);
    wire y;
    assign y = a & b;
    always @(posedge clk) q <= y;
endmodule

module and_ff_tb;
    reg clk = 1'b0, a = 1'b0, b = 1'b0;
    wire q;
    and_ff dut (.clk(clk), .a(a), .b(b), .q(q));
    initial begin
        a = 1; b = 1; #1;
        $display("edge 前 q=%b (a=1 b=1)", q);
        clk = 1; #1;
        $display("edge 後 q=%b", q);
        clk = 0; b = 0; #1; clk = 1; #1;
        $display("a=1 b=0 の edge 後 q=%b", q);
        $finish;
    end
endmodule
