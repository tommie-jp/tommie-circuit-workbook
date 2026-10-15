// Tang Nano 9K に載せる最上位。27 MHz で DDS を回し、8 本のピンから R-2R へ出す
module top (
    input        clk,        // 52 番ピン。ボードの 27 MHz
    input        btn_n,      // ボードのボタン (4 番ピン)。押すと 0。プリセットを次へ
    input        rxd,        // 18 番ピン。ボードの USB シリアル (BL702) から FPGA へ
    output [7:0] dac,        // R-2R へ。dac[7] が最上位 (40・35・41・42・51・53・54・55 番ピン)
    output       sync        // 32 番ピン。位相の前半だけ 1 (オシロのトリガ)
);
    reg [3:0] por;
    initial por = 4'd0;      // 電源を入れた直後の 15 クロックをリセットにする (12-4)
    always @(posedge clk)
        if (por != 4'hf) por <= por + 4'd1;
    wire rst = (por != 4'hf);

    wire en_btn, press;
    tick   #(.CLK_HZ(27_000_000), .TICK_HZ(100)) t_btn (.clk(clk), .rst(rst), .en(en_btn));
    button b_next (.clk(clk), .rst(rst), .sample(en_btn), .btn_n(btn_n), .press(press));

    wire [7:0] rx_data;
    wire       rx_valid;
    /* verilator lint_off PINCONNECTEMPTY */    // frame_err と sample は使わない
    uart_rx #(.CLK_HZ(27_000_000), .BAUD(9600)) u_rx (
        .clk(clk), .rst(rst), .rxd(rxd), .data(rx_data), .valid(rx_valid),
        .frame_err(), .sample());
    /* verilator lint_on PINCONNECTEMPTY */

    wire [31:0] ftw;
    ftw_cmd u_cmd (.clk(clk), .rst(rst), .rx_data(rx_data), .rx_valid(rx_valid), .next(press), .ftw(ftw));

    dds u_dds (.clk(clk), .rst(rst), .ftw(ftw), .dac(dac), .sync(sync));
endmodule
