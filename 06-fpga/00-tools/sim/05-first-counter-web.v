module counter #(parameter W = 8) (
    input             clk,
    input             rst,
    output [W-1:0]    count
);
    reg [W-1:0] r;
    assign count = r;

    always @(posedge clk or posedge rst)
        if (rst) r <= {W{1'b0}};
        else     r <= r + 1'b1;
endmodule
