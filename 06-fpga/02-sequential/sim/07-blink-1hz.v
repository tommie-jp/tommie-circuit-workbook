module blink #(
    parameter CLK_HZ   = 27_000_000,
    parameter BLINK_HZ = 1
) (
    input      clk,
    input      rst,
    output reg led
);
    localparam HALF = CLK_HZ / (2 * BLINK_HZ);
    localparam W    = (HALF > 1) ? $clog2(HALF) : 1;

    localparam [W-1:0] LAST = HALF[W-1:0] - 1'b1;

    reg [W-1:0] cnt;

    always @(posedge clk)
        if (rst) begin
            cnt <= {W{1'b0}};
            led <= 1'b0;
        end else if (cnt == LAST) begin
            cnt <= {W{1'b0}};
            led <= ~led;
        end else begin
            cnt <= cnt + 1'b1;
        end
endmodule
