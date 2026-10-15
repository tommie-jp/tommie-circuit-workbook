// glitch.v  論理は常に 0 (a ^ a) なのに、遅れの差で細いパルスが出る回路
// 遅れる側の経路は、Gowin の LUT1 を M 個、直に置いて作る (合成の道具に消されないようにする)

`ifdef VERILATOR
/* verilator lint_off DECLFILENAME */
module LUT1 #(parameter [1:0] INIT = 2'b00) (input wire I0, output wire F);
    assign F = INIT[I0];
endmodule
/* verilator lint_on DECLFILENAME */
`endif

module glitch #(
    parameter M = 16           // 遅れる側に入れる LUT の数
) (
    input  wire a,
    output wire y              // 論理は a ^ a = 0
);
    wire [M:0] d;              // d[0] = a。d[i] は i 段通った a
    assign d[0] = a;

    genvar i;
    generate
        for (i = 0; i < M; i = i + 1) begin : dly
            LUT1 #(.INIT(2'b10)) buffer (.I0(d[i]), .F(d[i+1]));   // INIT = 2'b10 は F = I0 (そのまま通す)
        end
    endgenerate

    assign y = a ^ d[M];
endmodule
