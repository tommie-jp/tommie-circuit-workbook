// 画面のスイッチ 2 個とボタン 1 個を入力にする。
// sw はスイッチ (押すたびに 0 と 1 が入れ替わり、そのまま残る)、btn はボタン (1 クロックだけ 1)。
module sw_gates (
    input        clk,
    input        rst,
    input  [1:0] sw,
    input        btn,
    output       y_and,
    output       y_or,
    output [3:0] o_presses
);
    reg [3:0] presses;     // ボタンを押した回数 (16 で 0 に戻る)

    assign y_and     = sw[1] & sw[0];
    assign y_or      = sw[1] | sw[0];
    assign o_presses = presses;

    always @(posedge clk) begin
        if (rst)
            presses <= 4'd0;
        else if (btn)
            presses <= presses + 4'd1;
    end
endmodule
