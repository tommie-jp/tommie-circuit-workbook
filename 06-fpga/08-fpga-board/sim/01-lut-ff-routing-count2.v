// count2.v — 2 ビットのカウンタ (2-4 を 2 ビットにしたもの)
module count2 (
    input  wire       clk,
    input  wire       rst,
    output reg  [1:0] q
);
    always @(posedge clk)
        if (rst) q <= 2'd0;
        else     q <= q + 2'd1;
endmodule
