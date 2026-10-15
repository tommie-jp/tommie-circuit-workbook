// SPI のマスタ (モード 0、8 ビット、MSB 先)。start を 1 クロック 1 にして data を送る。
// SCK の半周期は HALF クロック。cs_n は 1 字を送る間だけ 0。
// MOSI は SCK の立ち下がり側 (SCK = 0 の間) で変え、MISO は SCK を立ち上げる直前に読む
module spi_master #(
    parameter HALF = 2                 // SCK の半周期 (クロック数)。2 なら SCK = クロック / 4
) (
    input            clk,
    input            rst,
    input            start,
    input      [7:0] tx_data,
    input            miso,
    output reg       sck,
    output reg       mosi,
    output reg       cs_n,
    output           busy,
    output reg       done,             // 送り終えたクロックだけ 1
    output reg [7:0] rx_data           // done のとき、読んだ 8 ビット
);
    localparam integer W = (HALF > 1) ? $clog2(HALF) : 1;
    localparam [1:0] S_IDLE = 2'd0, S_LOW = 2'd1, S_HIGH = 2'd2, S_END = 2'd3;

    reg [1:0]   state;
    reg [W-1:0] cnt;      // 半周期の中のクロック
    reg [2:0]   nbit;     // 送ったビット数 (0〜7)
    reg [7:0]   tx_sh;    // 送るビット。上から出す
    reg [7:0]   rx_sh;    // 読んだビット。下から入れる
    wire        last = (cnt == HALF[W-1:0] - 1'b1);

    assign busy = (state != S_IDLE);

    always @(posedge clk)
        if (rst) begin
            state   <= S_IDLE;
            sck     <= 1'b0;
            mosi    <= 1'b0;
            cs_n    <= 1'b1;
            done    <= 1'b0;
            rx_data <= 8'h00;
            cnt     <= {W{1'b0}};
            nbit    <= 3'd0;
            tx_sh   <= 8'h00;
            rx_sh   <= 8'h00;
        end else begin
            done <= 1'b0;
            case (state)
                S_IDLE:
                    if (start) begin
                        cs_n  <= 1'b0;
                        tx_sh <= {tx_data[6:0], 1'b0};
                        mosi  <= tx_data[7];       // 最初のビットは SCK を上げる前に出しておく
                        nbit  <= 3'd0;
                        cnt   <= {W{1'b0}};
                        state <= S_LOW;
                    end
                S_LOW:                              // SCK = 0 の半周期
                    if (last) begin
                        rx_sh <= {rx_sh[6:0], miso};   // 立ち上げる直前の MISO を読む
                        sck   <= 1'b1;
                        cnt   <= {W{1'b0}};
                        state <= S_HIGH;
                    end else
                        cnt <= cnt + 1'b1;
                S_HIGH:                             // SCK = 1 の半周期
                    if (last) begin
                        sck <= 1'b0;
                        cnt <= {W{1'b0}};
                        if (nbit == 3'd7) state <= S_END;
                        else begin
                            mosi  <= tx_sh[7];     // 次のビットを SCK = 0 の間に出す
                            tx_sh <= {tx_sh[6:0], 1'b0};
                            nbit  <= nbit + 3'd1;
                            state <= S_LOW;
                        end
                    end else
                        cnt <= cnt + 1'b1;
                default: begin                      // S_END: CS を上げて終わり
                    cs_n    <= 1'b1;
                    rx_data <= rx_sh;
                    done    <= 1'b1;
                    state   <= S_IDLE;
                end
            endcase
        end
endmodule
