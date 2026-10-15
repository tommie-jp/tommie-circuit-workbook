// bits.v
module bits (
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire [3:0] cat,
    output wire [1:0] low,
    output wire       msb
);
    assign cat = {a, b};      // 連結: 上位に a、下位に b
    assign low = cat[1:0];    // 切り出し: 下位 2 ビット
    assign msb = cat[3];      // 切り出し: 最上位の 1 ビット
endmodule
