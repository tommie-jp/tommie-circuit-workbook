// Pico 2 に載せる最上位。ボタン 1 つの短押し・長押し・繰り返しを、LED 3 個で見せる
module press_top #(
    parameter CLK_HZ    = 1000,
    parameter LONG_MS   = 1000,
    parameter REPEAT_MS = 200,
    parameter SHOW_MS   = 100        // LED を点ける長さ
) (
    input        clk,
    input        rst,
    input        btn_n,              // GP0。押すと 0
    output       led_short,          // GP15 (D1 緑)
    output       led_long,           // GP14 (D2 黄)
    output       led_repeat,         // GP16 (D3 赤)
    output [1:0] o_state,            // 試験で見る。ピンには出さない
    output [2:0] o_pulse             // 試験で見る。{short, long, repeat} の 1 クロックのパルス
);
    localparam integer SHOW_CYC = CLK_HZ / 1000 * SHOW_MS;

    wire clean_n;
    wire press_unused;
    wire short_p, long_p, repeat_p;

    debounce #(.N(CLK_HZ / 50)) u_db (       // 6-3。1/50 s = 20 ms
        .clk(clk), .rst(rst), .btn_n(btn_n), .clean_n(clean_n), .press(press_unused));

    press_fsm #(.CLK_HZ(CLK_HZ), .LONG_MS(LONG_MS), .REPEAT_MS(REPEAT_MS)) u_fsm (
        .clk(clk), .rst(rst), .pressed(~clean_n),
        .short_p(short_p), .long_p(long_p), .repeat_p(repeat_p), .state(o_state));

    pulse_stretch #(.N(SHOW_CYC)) u_s (.clk(clk), .rst(rst), .pulse(short_p),  .out(led_short));
    pulse_stretch #(.N(SHOW_CYC)) u_l (.clk(clk), .rst(rst), .pulse(long_p),   .out(led_long));
    pulse_stretch #(.N(SHOW_CYC)) u_r (.clk(clk), .rst(rst), .pulse(repeat_p), .out(led_repeat));

    assign o_pulse = {short_p, long_p, repeat_p};
endmodule
