// mul8_op.v  演算子 * で書く。8 ビット × 8 ビット = 16 ビット (符号なし)
module mul8_op (
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    output wire [15:0] p
);
    assign p = a * b;
endmodule
