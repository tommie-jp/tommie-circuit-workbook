// pwm.v
module pwm #(
    parameter W = 3
) (
    input          clk,
    input          rst,
    input  [W:0]   duty,
    output         out
);
    reg [W-1:0] cnt;

    assign out = ({1'b0, cnt} < duty);

    always @(posedge clk)
        if (rst) cnt <= {W{1'b0}};
        else     cnt <= cnt + 1'b1;
endmodule
