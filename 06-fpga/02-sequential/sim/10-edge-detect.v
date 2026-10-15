// edge_detect.v
module edge_detect (
    input  clk,
    input  rst,
    input  in,
    output rise,
    output fall
);
    reg in_d;    // 1 クロック前の in

    always @(posedge clk)
        if (rst) in_d <= 1'b0;
        else     in_d <= in;

    assign rise =  in & ~in_d;
    assign fall = ~in &  in_d;
endmodule
