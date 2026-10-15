// Tang Nano 9K に 1-1 の gates を載せる最上位。gates.v は 1-1 のまま変えない
module top_gates (
    input  [3:2] sw_n,      // DIP スイッチの 1 番と 2 番。ON で 0 (FPGA の中でプルアップ)
    output [3:0] led_n,     // ボードの LED。0 で点く
    output [3:0] out        // 同じ値をヘッダにも出す。AD3 で読む
);
    wire       a = ~sw_n[3];    // DIP の 1 番
    wire       b = ~sw_n[2];    // DIP の 2 番
    wire [3:0] y;

    gates g (.a(a), .b(b), .y_and(y[3]), .y_or(y[2]), .y_not(y[1]));
    assign y[0] = 1'b0;         // 4 つ目は使わない

    assign led_n = ~y;
    assign out   = y;
endmodule
