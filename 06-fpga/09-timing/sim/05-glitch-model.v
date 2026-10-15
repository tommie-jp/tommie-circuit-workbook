// glitch_model.v  glitch の「模型」。遅れる側に # で遅れ DLY を入れる (実物の遅れではない)
module glitch_model #(
    parameter real DLY = 2.0   // 遅れる側の遅れ (ns)。模型のために決めた値
) (
    input  wire a,
    output wire y,             // 論理は a ^ a = 0
    output wire d              // 遅れた a (波形で見るために出す)
);
    assign #(DLY) d = a;
    assign y = a ^ d;
endmodule
