// top_glitch.v  27 MHz を割った a から、glitch の出力と、それを FF で受けた出力を作る
module top_glitch #(
    parameter M = 16
) (
    input  wire clk,           // 52 番ピン。ボードの 27 MHz
    output wire a_out,         // 38 番ピン。a (27 MHz / 16 = 1.6875 MHz)
    output wire y_raw,         // 37 番ピン。組み合わせの出力をそのまま出す
    output reg  y_reg          // 36 番ピン。同じ出力を FF で受けて出す
);
    reg [3:0] cnt;
    initial cnt = 4'd0;
    always @(posedge clk)
        cnt <= cnt + 4'd1;

    wire a = cnt[3];           // 8 クロックごとに反転 (27 MHz / 16)
    wire y;

    glitch #(.M(M)) g (.a(a), .y(y));

    assign a_out = a;
    assign y_raw = y;

    always @(posedge clk)
        y_reg <= y;
endmodule
