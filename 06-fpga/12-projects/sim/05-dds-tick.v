// CLK_HZ を数えて、TICK_HZ の速さで 1 クロックだけ en を 1 にする (2-5 のクロックイネーブル)
module tick #(
    parameter CLK_HZ  = 27_000_000,
    parameter TICK_HZ = 1
) (
    input      clk,
    input      rst,
    output reg en
);
    localparam N = CLK_HZ / TICK_HZ;
    localparam W = (N > 1) ? $clog2(N) : 1;

    localparam [W-1:0] LAST = N[W-1:0] - 1'b1;

    reg [W-1:0] cnt;

    always @(posedge clk)
        if (rst) begin
            cnt <= {W{1'b0}};
            en  <= 1'b0;
        end else if (cnt == LAST) begin
            cnt <= {W{1'b0}};
            en  <= 1'b1;
        end else begin
            cnt <= cnt + 1'b1;
            en  <= 1'b0;
        end
endmodule
