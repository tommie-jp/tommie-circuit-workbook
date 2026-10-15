// Tang Nano 9K に載せる最上位。27 MHz でそのまま 65C02 を回す。
// リセットは電源を入れた直後の 15 クロックと、ボードの S1 (押すと 0) を押している間
module top (
    input  clk,          // 52 番ピン。ボードの 27 MHz
    input  rst_n,        // 4 番ピン。ボードの S1
    input  uart_rx,      // USB シリアルの TXD から
    output uart_tx,      // USB シリアルの RXD へ
    output dbg_kbd,      // KBD を読んだら 1 µs だけ 1 (AD3 で見る)
    output dbg_dsp       // DSP に書いたら 1 µs だけ 1
);
    reg [3:0] por;
    initial por = 4'd0;
    always @(posedge clk)
        if (por != 4'hf) por <= por + 4'd1;

    reg [1:0] rst_sync;                    // ボタンは 2 段で受ける (9-2)
    reg       rst;                         // リセットもフリップフロップから出す (下の「合成」)
    initial rst = 1'b1;
    always @(posedge clk) begin
        rst_sync <= {rst_sync[0], rst_n};
        rst      <= (por != 4'hf) || !rst_sync[1];
    end

    wire kbd_stb, dsp_stb;
    /* verilator lint_off PINCONNECTEMPTY */
    apple1_fpga #(.ROM_HEX("rom.hex")) u (
        .clk(clk), .rst(rst), .rxd(uart_rx), .txd(uart_tx),
        .kbd_stb(kbd_stb), .dsp_stb(dsp_stb), .sync());
    /* verilator lint_on PINCONNECTEMPTY */

    // 1 クロック (37 ns) の合図は AD3 で取りこぼすので、27 クロック (1 µs) に延ばす
    reg [4:0] kbd_cnt, dsp_cnt;
    always @(posedge clk) begin
        kbd_cnt <= kbd_stb ? 5'd27 : (kbd_cnt != 5'd0) ? kbd_cnt - 5'd1 : 5'd0;
        dsp_cnt <= dsp_stb ? 5'd27 : (dsp_cnt != 5'd0) ? dsp_cnt - 5'd1 : 5'd0;
    end
    assign dbg_kbd = (kbd_cnt != 5'd0);
    assign dbg_dsp = (dsp_cnt != 5'd0);
endmodule
