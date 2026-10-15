// half.v  入力の立ち上がりごとに反転する FF 1 個。出力は入力の 1/2 の周波数
module half (
    input  wire clk,
    output reg  q
);
    initial q = 1'b0;

    always @(posedge clk)
        q <= ~q;
endmodule
