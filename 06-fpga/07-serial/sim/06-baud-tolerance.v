// 7-1 の hello_top を、1 ビットのクロック数 DIV を直接決めて使う最上位。
// CLK_HZ = DIV x 4800 にすると、uart_tx の分周が DIV クロックになる。
// 1 ビットの長さは DIV x (クロックの周期)。クロックの周期は 5-7 のタイマ割り込みの間隔 (µs) で決める
module skew_top #(
    parameter integer DIV = 16
) (
    input  clk,
    input  rst,
    output txd       // GP15
);
    hello_top #(.CLK_HZ(DIV * 4800), .BAUD(4800)) u_hello (.clk(clk), .rst(rst), .txd(txd));
endmodule
