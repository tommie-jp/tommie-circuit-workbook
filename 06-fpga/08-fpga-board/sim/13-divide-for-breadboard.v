// 27 MHz を分周して、ブレッドボードに出せる周波数 (3 MHz 以下) の信号を 3 本出す
module top_div (
    input  clk,        // 52 番ピン。ボードの 27 MHz
    input  rst_n,      // 4 番ピン。ボードの押しボタン (押すと 0)
    output out_3m,     // IO38。27 MHz ÷ 9   = 3 MHz
    output out_1m,     // IO37。27 MHz ÷ 27  = 1 MHz
    output out_100k    // IO36。27 MHz ÷ 270 = 100 kHz
);
    wire rst = ~rst_n;

    clkdiv #(.N(9))   d3m   (.clk(clk), .rst(rst), .out(out_3m));
    clkdiv #(.N(27))  d1m   (.clk(clk), .rst(rst), .out(out_1m));
    clkdiv #(.N(270)) d100k (.clk(clk), .rst(rst), .out(out_100k));
endmodule
