// ring.v  インバータを奇数個、輪にしたリングオシレータ。en が 1 の間だけ発振する
// 段ごとに Gowin の LUT (LUT1・LUT2) を 1 個ずつ直に置く。合成の道具は、置いた LUT を消したりまとめたりしない

`ifdef VERILATOR
/* verilator lint_off DECLFILENAME */
// シミュレータには Gowin の部品が無いので、同じ働きの模型を置く (合成の道具には読ませない)
module LUT1 #(parameter [1:0] INIT = 2'b00) (input wire I0, output wire F);
    assign F = INIT[I0];
endmodule
module LUT2 #(parameter [3:0] INIT = 4'b0000) (input wire I0, input wire I1, output wire F);
    assign F = INIT[{I1, I0}];
endmodule
/* verilator lint_on DECLFILENAME */
`endif

module ring #(
    parameter N = 5            // 段数 (奇数)
) (
    input  wire en,
    output wire y              // 輪の最後の段の出力
);
    /* verilator lint_off UNOPTFLAT */    // 輪は循環した組み合わせ回路。それが目的
    wire [N-1:0] w;                       // 各段の出力
    /* verilator lint_on UNOPTFLAT */

    // 1 段目だけ NAND (en = 0 なら w[0] は 1 に止まる)。INIT = 4'b0111 は F = ~(I0 & I1)
    LUT2 #(.INIT(4'b0111)) nand0 (.I0(w[N-1]), .I1(en), .F(w[0]));

    genvar i;
    generate
        for (i = 1; i < N; i = i + 1) begin : stage
            // INIT = 2'b01 は F = ~I0 (インバータ)
            LUT1 #(.INIT(2'b01)) inv (.I0(w[i-1]), .F(w[i]));
        end
    endgenerate

    assign y = w[N-1];
endmodule
