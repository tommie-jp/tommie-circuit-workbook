// top_sync2.v  Tang Nano 9K に載せる最上位。AD3 の Patterns からの信号を 2 段で受け、1 段目と 2 段目を外へ出す
module top_sync2 (
    input  clk,        // 52 番ピン。ボードの 27 MHz
    input  async_in,   // 36 番ピン。AD3 の DIO2 (Patterns) から来る、クロックと無関係な信号
    output sync_out,   // 38 番ピン。2 段で受けた信号 (AD3 の DIO0 で読む)
    output ff1_out     // 37 番ピン。1 段目の出力 (AD3 の DIO1 で読む)
);
    sync2 u (.clk(clk), .d_async(async_in), .q1(ff1_out), .q(sync_out));
endmodule
