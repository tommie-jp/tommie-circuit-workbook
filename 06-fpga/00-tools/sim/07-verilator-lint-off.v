// off.v  使わない入力を、理由を書いて黙らせる
module off (
    input  wire       a,
    /* verilator lint_off UNUSEDSIGNAL */
    input  wire       spare,   // 将来の拡張用。いまは使わない
    /* verilator lint_on UNUSEDSIGNAL */
    output wire       y
);
    assign y = a;
endmodule
