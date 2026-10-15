// signed_demo.v  同じ 4 ビットを、符号なしと符号付きで読んで比べる
module signed_demo (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire       lt_u,        // 符号なしで a < b
    output wire       lt_s,        // 符号付きで a < b
    output wire [7:0] ext_zero,    // 上に 0 を足して 8 ビットに広げる
    output wire [7:0] ext_sign,    // 上に符号ビットを足して 8 ビットに広げる
    output wire [3:0] neg,         // -a (反転して 1 を足す)
    output wire [3:0] lsr,         // 論理右シフト (上に 0 が入る)
    output wire [3:0] asr,         // 算術右シフト (上に符号ビットが入る)
    output wire       same         // 反転 + 1 と、単項のマイナスが一致していれば 1
);
    wire signed [3:0] sa = a;
    wire signed [3:0] sb = b;

    assign lt_u     = (a < b);
    assign lt_s     = (sa < sb);
    assign ext_zero = {4'b0000, a};
    assign ext_sign = {{4{a[3]}}, a};
    assign neg      = ~a + 4'd1;
    assign lsr      = a >> 1;
    assign asr      = sa >>> 1;

    wire [3:0] neg_op = -sa;
    assign same = (neg == neg_op);
endmodule
