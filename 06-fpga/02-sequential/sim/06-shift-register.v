module shift4 (
    input        clk,
    input        rst,
    input        din,
    output [3:0] q
);
    reg [3:0] r;

    assign q = r;

    always @(posedge clk)
        if (rst) r <= 4'b0000;
        else     r <= {r[2:0], din};
endmodule
