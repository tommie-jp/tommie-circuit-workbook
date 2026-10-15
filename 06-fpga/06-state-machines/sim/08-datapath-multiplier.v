// 制御器とデータパスをつなぐだけの最上位
module mul_top #(
    parameter W = 8
) (
    input              clk,
    input              rst,
    input              start,
    input  [W-1:0]     a,
    input  [W-1:0]     b,
    output [2*W-1:0]   p,
    output             done
);
    wire ld;
    wire add;
    wire zero;

    mul_ctl u_ctl (.clk(clk), .rst(rst), .start(start), .zero(zero),
                   .ld(ld), .add(add), .done(done));
    mul_dp #(.W(W)) u_dp (.clk(clk), .rst(rst), .ld(ld), .add(add),
                          .a(a), .b(b), .p(p), .zero(zero));
endmodule
