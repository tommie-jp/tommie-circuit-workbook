// 27 MHz を PLL で 108 MHz にし、54 分周した 2 MHz を IO38 に出す。locked はボードの LED (0 で点く)
module top_pll (
    input  clk,        // 52 番ピン。ボードの 27 MHz
    output out_2m,     // IO38。ブレッドボードへ出して AD3 で測る
    output led_n       // 10 番ピン。PLL が locked したら点く
);
    wire clk108;
    wire locked;

    pll108 pll (.clock_in(clk), .clock_out(clk108), .locked(locked));

    div2m div (.clk(clk108), .rst(~locked), .out(out_2m));

    assign led_n = ~locked;
endmodule
