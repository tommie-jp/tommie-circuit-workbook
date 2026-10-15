// updown.v
module updown #(
    parameter W = 4
) (
    input          clk,
    input          rst,
    input          load,
    input  [W-1:0] d,
    input          up,
    input          down,
    output [W-1:0] count
);
    reg [W-1:0] r;

    assign count = r;

    always @(posedge clk)
        if (rst)       r <= {W{1'b0}};
        else if (load) r <= d;
        else if (up)   r <= r + 1'b1;
        else if (down) r <= r - 1'b1;
endmodule
