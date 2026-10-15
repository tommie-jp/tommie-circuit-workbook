// Tang Nano 9K で 2-4 の counter を 27 MHz のまま回し、3 ビットめと 4 ビットめをブレッドボードへ出す
module top_count (
    input  clk,        // 52 番ピン。ボードの 27 MHz
    input  rst_n,      // 4 番ピン。ボードの押しボタン (押すと 0)
    output q3,         // 38 番ピン。27 MHz / 16 = 1.6875 MHz
    output q4          // 37 番ピン。27 MHz / 32 = 0.84375 MHz
);
    /* verilator lint_off UNUSEDSIGNAL */    // 外に出すのは 3 ビットめと 4 ビットめだけ
    wire [7:0] count;
    /* verilator lint_on UNUSEDSIGNAL */

    counter #(.W(8)) u (.clk(clk), .rst(~rst_n), .count(count));

    assign q3 = count[3];
    assign q4 = count[4];
endmodule
