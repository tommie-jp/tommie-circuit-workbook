// 押しボタンを押すたびに 7 セグの数字が 1 つ進む (0 から F まで。F の次は 0)
module top_btn_seg #(
    parameter CLK_HZ = 27_000_000
) (
    input        clk,       // 52 番ピン。ボードの 27 MHz
    input        rst_n,     // 4 番ピン。ボードの押しボタン (押すと 0)
    input        btn_n,     // IO25。ブレッドボードの押しボタン (押すと 0)
    output [6:0] seg        // {g, f, e, d, c, b, a}。1 で点灯
);
    wire press;

    /* verilator lint_off PINCONNECTEMPTY */
    debounce #(.N(CLK_HZ / 50)) db (       // 1/50 s = 20 ms
        .clk(clk), .rst(~rst_n), .btn_n(btn_n), .clean_n(), .press(press));
    /* verilator lint_on PINCONNECTEMPTY */

    reg [3:0] n;
    always @(posedge clk)
        if (!rst_n)     n <= 4'h0;
        else if (press) n <= n + 4'h1;

    seg7_decoder dec (.d(n), .seg(seg));
endmodule
