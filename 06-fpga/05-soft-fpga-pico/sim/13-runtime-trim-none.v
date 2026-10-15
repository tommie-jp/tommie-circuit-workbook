module p_none (
    input        clk,
    input        rst,
    output [3:0] count
);
    reg [3:0] r;
    assign count = r;
    always @(posedge clk)
        if (rst) r <= 4'd0;
        else     r <= r + 4'd1;
endmodule
