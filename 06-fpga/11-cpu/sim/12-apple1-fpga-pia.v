// Apple-I の PIA (6820) のうち、Woz Monitor と Integer BASIC が使う 4 つの番地だけを真似て、
// キーボードと画面を UART に置き換える。番地を出した次のクロックに rdata が出る (ブロック RAM と同じ)
//   rs = 0  KBD    読むと {1, 字}。読んだら「字がある」を 0 に戻す
//   rs = 1  KBDCR  ビット 7 = 字がある
//   rs = 2  DSP    書くと最上位ビットが 1 の字だけ送る。読むとビット 7 = 送っている最中
//   rs = 3  DSPCR  読むと 0。書いても何もしない
module pia_uart #(
    parameter CLK_HZ = 27_000_000,
    parameter BAUD   = 115_200
) (
    input            clk,
    input            rst,
    input            cs,          // この 4 つの番地のどれかを出している
    input      [1:0] rs,          // 番地の下 2 ビット
    input            we,
    input      [7:0] wdata,
    output reg [7:0] rdata,
    input            rxd,
    output           txd,
    output           kbd_stb,     // CPU が KBD を読んだクロックだけ 1
    output           dsp_stb      // CPU が DSP に字を書いたクロックだけ 1
);
    // ---- キーボード: UART で受けた字を 1 字だけ持つ ----
    wire [7:0] rx_data;
    wire       rx_valid;
    /* verilator lint_off PINCONNECTEMPTY */     // frame_err と sample は使わない
    uart_rx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
        .clk(clk), .rst(rst), .rxd(rxd), .data(rx_data), .valid(rx_valid), .frame_err(), .sample());
    /* verilator lint_on PINCONNECTEMPTY */

    // Apple-I のキーボードは大文字だけ。BS と DEL は Apple-I の消す字 '_' にする
    function [6:0] to_apple1(input [7:0] c);
        if (c >= "a" && c <= "z")      to_apple1 = c[6:0] - 7'h20;
        else if (c == 8'h08 || c == 8'h7F) to_apple1 = 7'h5F;
        else                           to_apple1 = c[6:0];
    endfunction

    reg [6:0] kbd_char;
    reg       kbd_full;
    wire      kbd_read = cs && !we && (rs == 2'd0);

    always @(posedge clk)
        if (rst) begin
            kbd_char <= 7'h00;
            kbd_full <= 1'b0;
        end else if (rx_valid && rx_data != 8'h0A) begin   // LF は捨てる (Enter は CR で来る)
            kbd_char <= to_apple1(rx_data);
            kbd_full <= 1'b1;
        end else if (kbd_read)
            kbd_full <= 1'b0;

    // ---- 画面: 書かれた字を UART で送る。CR の後に LF を足す ----
    reg  [7:0] tx_data;
    reg        tx_req;      // 送りたい字がある
    reg        lf_pend;     // CR を送ったら LF も送る
    wire       tx_busy;
    wire       tx_start = tx_req && !tx_busy;
    wire       dsp_write = cs && we && (rs == 2'd2) && wdata[7];   // 最上位ビットが 0 の書き込みは設定とみなす
    wire       dsp_busy = tx_req || tx_busy || lf_pend;

    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
        .clk(clk), .rst(rst), .data(tx_data), .start(tx_start), .txd(txd), .busy(tx_busy));

    always @(posedge clk)
        if (rst) begin
            tx_data <= 8'h00;
            tx_req  <= 1'b0;
            lf_pend <= 1'b0;
        end else if (dsp_write && !dsp_busy) begin
            tx_data <= {1'b0, wdata[6:0]};
            tx_req  <= 1'b1;
            lf_pend <= (wdata[6:0] == 7'h0D);
        end else if (tx_start)
            tx_req <= 1'b0;
        else if (lf_pend && !tx_req && !tx_busy) begin
            tx_data <= 8'h0A;
            tx_req  <= 1'b1;
            lf_pend <= 1'b0;
        end

    // ---- 読む値 (次のクロックに出す) ----
    always @(posedge clk)
        case (rs)
            2'd0:    rdata <= {1'b1, kbd_char};
            2'd1:    rdata <= {kbd_full, 7'h00};
            2'd2:    rdata <= {dsp_busy, 7'h00};
            default: rdata <= 8'h00;
        endcase

    assign kbd_stb = kbd_read;
    assign dsp_stb = dsp_write;
endmodule
