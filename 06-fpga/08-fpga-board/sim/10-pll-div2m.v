// 108 MHz のクロックを 54 分周して 2 MHz (50 %) を作る。27 クロックごとに反転する
module div2m (
    input  clk,       // PLL の 108 MHz
    input  rst,       // 1 のあいだ 0 に保つ (PLL の locked を反転して渡す)
    output reg out
);
    reg [4:0] cnt;    // 0 から 26 まで

    always @(posedge clk)
        if (rst) begin
            cnt <= 5'd0;
            out <= 1'b0;
        end else if (cnt == 5'd26) begin
            cnt <= 5'd0;
            out <= ~out;
        end else begin
            cnt <= cnt + 5'd1;
        end
endmodule
