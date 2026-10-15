// 分周器: DIV クロックごとに led が反転する。ポートは元のカウンタと同じにして、
// harness.cpp とビルドの手順を変えずに済ませる。
module counter #(parameter DIV = 4) (
    input         clk,
    input         rst,
    output [7:0]  count
);
    localparam [3:0] LAST = DIV - 1;

    reg [3:0] phase;    // 0 .. DIV-1 を数える
    reg       led;      // DIV クロックごとに反転 (周期は 2 * DIV クロック)
    reg [5:0] ticks;    // tick の回数

    wire tick = (phase == LAST);

    always @(posedge clk or posedge rst)
        if (rst) begin
            phase <= 4'd0;
            led   <= 1'b0;
            ticks <= 6'd0;
        end else begin
            phase <= tick ? 4'd0 : phase + 4'd1;
            if (tick) begin
                led   <= ~led;
                ticks <= ticks + 6'd1;
            end
        end

    assign count = {ticks, tick, led};
endmodule
