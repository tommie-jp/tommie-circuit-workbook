// Pico 2 に載せる最上位。クロックは 5-7 の方法で CLK_HZ に固定する。時間は秒で書く
module traffic_top #(
    parameter CLK_HZ = 1000
) (
    input        clk,
    input        rst,
    input        btn_n,     // 押しボタン。押すと 0 (Pico 2 の中のプルアップ)
    output       led_green,
    output       led_yellow,
    output       led_red,
    output       led_walk,
    output [1:0] o_state    // 試験で見る。ピンには出さない
);
    traffic_fsm2 #(
        .W          (16),
        .GREEN_TIME (6 * CLK_HZ),
        .YELLOW_TIME(2 * CLK_HZ),
        .RED_TIME   (4 * CLK_HZ),
        .WALK_TIME  (5 * CLK_HZ)
    ) u_fsm (
        .clk   (clk),
        .rst   (rst),
        .btn   (~btn_n),
        .red   (led_red),
        .yellow(led_yellow),
        .green (led_green),
        .walk  (led_walk),
        .state (o_state)
    );
endmodule
