module ff_sync_rst (
    input  clk,
    input  rst,
    input  d,
    output reg q
);
    always @(posedge clk)
        if (rst) q <= 1'b0;
        else     q <= d;
endmodule

module ff_async_rst (
    input  clk,
    input  rst,
    input  d,
    output reg q
);
    always @(posedge clk or posedge rst)
        if (rst) q <= 1'b0;
        else     q <= d;
endmodule
