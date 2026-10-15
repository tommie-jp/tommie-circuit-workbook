// Tang Nano 9K に TD4 を載せる最上位。TD4.v は Soft-FPGA-TD4 のまま変えない
module top_td4 #(
    parameter CLK_HZ = 27_000_000
) (
    input        clk,       // 52 番ピン。ボードの 27 MHz
    input        rst_n,     // 4 番ピン。ボードの押しボタン (押すと 0)
    input  [3:0] sw_n,      // DIP スイッチ。ON で 0 (FPGA の中でプルアップ)
    output [3:0] led_n,     // ボードの LED。0 で点く
    output [3:0] out,       // out_port をヘッダにも出す。AD3 で読む
    output       td4_clk    // TD4 のクロック。AD3 で読む
);
    wire       slow;
    wire [3:0] out_port;

    // 2-7 の blink を 5 Hz で回して TD4 のクロックにする (Pico 2 の 100 ms ごとの反転と同じ 200 ms の周期)
    blink #(.CLK_HZ(CLK_HZ), .BLINK_HZ(5)) div (.clk(clk), .rst(~rst_n), .led(slow));

    /* verilator lint_off PINCONNECTEMPTY */    // pc_out・op・alu_data はピンに出さない
    TD4 cpu (.clock(slow), .reset_n(rst_n), .in_port(~sw_n), .out_port(out_port),
             .pc_out(), .op(), .alu_data());
    /* verilator lint_on PINCONNECTEMPTY */

    assign led_n   = ~out_port;
    assign out     = out_port;
    assign td4_clk = slow;
endmodule
