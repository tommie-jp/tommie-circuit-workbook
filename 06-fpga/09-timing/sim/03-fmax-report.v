// top_fmax.v  最高の動作周波数を調べる最上位。W を変えて、カウンタの桁数ごとの値を並べる
module top_fmax #(
    parameter W = 16
) (
    input  clk,        // 52 番ピン。ボードの 27 MHz
    input  rst_n,      // 4 番ピン。ボードの押しボタン (押すと 0)
    output msb         // 38 番ピン。カウンタの最上位ビット
);
    wire [W-1:0] count;

    counter #(.W(W)) u (.clk(clk), .rst(~rst_n), .count(count));

    assign msb = count[W-1];
endmodule
