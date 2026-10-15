// Tang Nano 9K に載せる最上位。2-7 の blink をそのまま入れる
module top (
    input  clk,        // 52 番ピン。ボードの 27 MHz
    input  rst_n,      // 4 番ピン。ボードの押しボタン (押すと 0)
    output led_n,      // 10 番ピン。ボードの LED (0 で点く)
    output blink_out   // 38 番ピン。ブレッドボードへ出して AD3 で測る
);
    wire led;

    blink #(.CLK_HZ(27_000_000), .BLINK_HZ(1)) u (.clk(clk), .rst(~rst_n), .led(led));

    assign led_n     = ~led;
    assign blink_out = led;
endmodule
