// Tang Nano 9K に載せる最上位。リセットのボタンは時刻合わせに使うので、電源を入れた直後の 15 クロックをリセットにする
module top (
    input        clk,          // 52 番ピン。ボードの 27 MHz
    input        btn_hour_n,   // ボードのボタン (4 番ピン)
    input        btn_min_n,    // ボードのボタン (3 番ピン)
    input        sync_n,       // 正時の合図 (押すと 0)。この題では AD3 の DIO5 から
    output [7:0] seg,
    output [3:0] dig,
    output       sec
);
    reg [3:0] por;
    initial por = 4'd0;        // FPGA は書き込んだ直後にこの初期値から始まる (2-18)
    always @(posedge clk)
        if (por != 4'hf) por <= por + 4'd1;
    wire rst = (por != 4'hf);

    /* verilator lint_off PINCONNECTEMPTY */    // now は試験で見るだけ。ピンには出さない
    clock u (.clk(clk), .rst(rst), .btn_hour_n(btn_hour_n), .btn_min_n(btn_min_n), .sync_n(sync_n),
             .seg(seg), .dig(dig), .sec(sec), .now());
    /* verilator lint_on PINCONNECTEMPTY */
endmodule
