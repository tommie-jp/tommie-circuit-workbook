// dec_counter.v
module dec_counter (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    output reg  [3:0] q
);
    always @(posedge clk) begin
        if (!rst_n) q <= 4'd0;
        else begin
            if (q == 4'd9) q <= 4'd0;
            else           q <= q + 4'd1;
        end
    end
endmodule
