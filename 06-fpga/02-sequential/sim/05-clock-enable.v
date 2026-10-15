module clk_enable #(
    parameter W = 2
) (
    input          clk,
    input          rst,
    output         tick,
    output [3:0]   q
);
    reg [W-1:0] cnt;
    reg [3:0]   r;

    assign tick = (cnt == {W{1'b1}});
    assign q    = r;

    always @(posedge clk)
        if (rst) begin
            cnt <= {W{1'b0}};
            r   <= 4'd0;
        end else begin
            cnt <= cnt + 1'b1;
            if (tick) r <= r + 1'b1;
        end
endmodule
