// 0.5 s ごとに LM75 の温度レジスタを読み、2 バイトを 16 進で UART に出す。Pico 2 に載せる最上位
//   読めたとき  "19 80\r\n"   (上位バイト 下位バイト)
//   返事が無いとき "ERR\r\n"
module i2c_temp_top #(
    parameter CLK_HZ = 76_923,
    parameter BAUD   = 4800
) (
    input  clk,
    input  rst,
    input  sda_in,      // GP4  SDA の線の値
    output sda_low,     // GP4  1 のとき出力 0 を出し、0 のとき入力にする (外のプルアップが 1 を作る)
    output scl_low,     // GP5  同上
    output txd          // GP15 UART の TXD
);
    localparam integer HALF = CLK_HZ / 2;
    localparam integer W    = $clog2(HALF);

    reg [W-1:0] tcnt;
    reg         rd_start;
    wire        rd_busy, rd_done, rd_nack;
    wire [7:0]  t_hi, t_lo;

    i2c_read #(.ADDR(7'h48), .PTR(8'h00), .QTR(1)) u_rd (
        .clk(clk), .rst(rst), .start(rd_start), .sda_in(sda_in),
        .sda_low(sda_low), .scl_low(scl_low), .busy(rd_busy), .done(rd_done),
        .nack(rd_nack), .data_hi(t_hi), .data_lo(t_lo));

    // ---- 結果を 1 行にして UART へ
    reg [7:0] hi, lo;
    reg       err;
    reg [2:0] idx;       // 次に送る字の番号
    reg [2:0] len;       // 1 行の字数。7 (16 進 2 桁 + 空白 + 2 桁 + CR LF) か 5 (ERR + CR LF)
    reg       sending;
    reg       tx_start;
    reg [7:0] tx_data;
    wire      tx_busy;

    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
        .clk(clk), .rst(rst), .data(tx_data), .start(tx_start), .txd(txd), .busy(tx_busy));

    function [7:0] hex(input [3:0] n);
        hex = (n < 4'd10) ? (8'h30 + {4'd0, n}) : (8'h37 + {4'd0, n});   // 0-9 は 0x30〜、A-F は 0x41〜
    endfunction

    function [7:0] ch(input [2:0] i, input [7:0] h, input [7:0] l, input e);
        if (e)
            case (i)
                3'd0:    ch = "E";
                3'd1:    ch = "R";
                3'd2:    ch = "R";
                3'd3:    ch = 8'h0D;
                default: ch = 8'h0A;
            endcase
        else
            case (i)
                3'd0:    ch = hex(h[7:4]);
                3'd1:    ch = hex(h[3:0]);
                3'd2:    ch = " ";
                3'd3:    ch = hex(l[7:4]);
                3'd4:    ch = hex(l[3:0]);
                3'd5:    ch = 8'h0D;
                default: ch = 8'h0A;
            endcase
    endfunction

    always @(posedge clk)
        if (rst) begin
            tcnt     <= {W{1'b0}};
            rd_start <= 1'b0;
            hi       <= 8'h00;
            lo       <= 8'h00;
            err      <= 1'b0;
            idx      <= 3'd0;
            len      <= 3'd0;
            sending  <= 1'b0;
            tx_start <= 1'b0;
            tx_data  <= 8'h00;
        end else begin
            rd_start <= 1'b0;
            tx_start <= 1'b0;

            // 0.5 s ごとに読み始める (LM75 の変換は 100 ms 程度。300 ms 以内に続けて読まない)
            if (tcnt == HALF[W-1:0] - 1'b1) begin
                tcnt <= {W{1'b0}};
                if (!rd_busy && !sending) rd_start <= 1'b1;
            end else
                tcnt <= tcnt + 1'b1;

            // 読めたら 1 行にする
            if (rd_done) begin
                hi      <= t_hi;
                lo      <= t_lo;
                err     <= rd_nack;
                len     <= rd_nack ? 3'd5 : 3'd7;
                idx     <= 3'd0;
                sending <= 1'b1;
            end

            // 1 字ずつ送る
            if (sending && !tx_busy && !tx_start) begin
                if (idx == len)
                    sending <= 1'b0;
                else begin
                    tx_data  <= ch(idx, hi, lo, err);
                    tx_start <= 1'b1;
                    idx      <= idx + 3'd1;
                end
            end
        end
endmodule
