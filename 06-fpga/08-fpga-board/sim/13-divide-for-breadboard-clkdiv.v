// クロックを N 分周した方形波を出す。カウンタが 0 から N - 1 まで数え、前半の N / 2 クロックだけ 1 にする
module clkdiv #(
    parameter N = 9
) (
    input      clk,
    input      rst,
    output reg out
);
    localparam W = $clog2(N);
    localparam [W-1:0] LAST = N[W-1:0] - 1'b1;
    localparam [W-1:0] HIGH = N[W-1:0] / 2;     // 1 にするクロック数 (N が奇数なら切り捨て)

    reg  [W-1:0] cnt;
    wire [W-1:0] nxt = (cnt == LAST) ? {W{1'b0}} : cnt + 1'b1;

    always @(posedge clk)
        if (rst) begin
            cnt <= {W{1'b0}};
            out <= 1'b1;
        end else begin
            cnt <= nxt;
            out <= (nxt < HIGH);                // 1 つ先のカウンタの値で決める (out は FF の出力)
        end
endmodule
