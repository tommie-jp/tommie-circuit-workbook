// UART の受信 (8N1)。ボーレートの 16 倍で刻み、スタートビットを見つけてから
// 8 刻み目 (スタートビットの真ん中)、そこから 16 刻みごと (各ビットの真ん中) に読む
module uart_rx #(
    parameter CLK_HZ = 76_923,
    parameter BAUD   = 4800
) (
    input            clk,
    input            rst,
    input            rxd,
    output reg [7:0] data,       // 受けた字 (次の字まで保つ)
    output reg       valid,      // 受け終えたクロックだけ 1
    output reg       frame_err,  // ストップビットが 0 だった
    output reg       sample      // 線を読んだ直後の 1 クロックだけ 1 (読む時刻を Logic で見るため)
);
    // 16 倍の刻み: CLK_HZ を (BAUD × 16) で割る (四捨五入)。1 なら毎クロック
    localparam integer DIV16 = (CLK_HZ + BAUD * 8) / (BAUD * 16);
    localparam integer TW    = (DIV16 > 1) ? $clog2(DIV16) : 1;
    localparam integer TLAST = DIV16 - 1;

    localparam [1:0] S_IDLE = 2'd0, S_START = 2'd1, S_DATA = 2'd2, S_STOP = 2'd3;

    reg [TW-1:0] tcnt;
    wire         tick = (tcnt == TLAST[TW-1:0]);
    reg [1:0]    sync;           // クロックと関係なく変わる入力を 2 段で受ける
    wire         rx = sync[1];
    reg [1:0]    state;
    reg [3:0]    phase;          // 刻みを数える (0〜15)
    reg [2:0]    nbit;           // 何ビット目を読むか
    reg [7:0]    shreg;

    always @(posedge clk)
        if (rst || tick) tcnt <= {TW{1'b0}};
        else             tcnt <= tcnt + 1'b1;

    always @(posedge clk)
        if (rst) begin
            sync      <= 2'b11;
            state     <= S_IDLE;
            phase     <= 4'd0;
            nbit      <= 3'd0;
            shreg     <= 8'h00;
            data      <= 8'h00;
            valid     <= 1'b0;
            frame_err <= 1'b0;
            sample    <= 1'b0;
        end else begin
            sync   <= {sync[0], rxd};
            valid  <= 1'b0;
            sample <= 1'b0;
            if (tick)
                case (state)
                    S_IDLE:
                        if (!rx) begin               // 0 を見た = スタートビットの始まり
                            phase <= 4'd0;
                            state <= S_START;
                        end
                    S_START:
                        if (phase == 4'd7) begin     // 8 刻み目 = スタートビットの真ん中
                            sample <= 1'b1;
                            phase  <= 4'd0;
                            nbit  <= 3'd0;
                            state <= rx ? S_IDLE : S_DATA;   // 1 なら雑音だったので戻る
                        end else
                            phase <= phase + 4'd1;
                    S_DATA:
                        if (phase == 4'd15) begin    // 16 刻み後 = 次のビットの真ん中
                            sample <= 1'b1;
                            phase  <= 4'd0;
                            shreg <= {rx, shreg[7:1]};       // 下位ビットから来るので右へ送る
                            nbit  <= nbit + 3'd1;
                            if (nbit == 3'd7) state <= S_STOP;
                        end else
                            phase <= phase + 4'd1;
                    default:                         // S_STOP
                        if (phase == 4'd15) begin
                            sample <= 1'b1;
                            phase  <= 4'd0;
                            state <= S_IDLE;
                            if (rx) begin
                                data      <= shreg;
                                valid     <= 1'b1;
                                frame_err <= 1'b0;
                            end else
                                frame_err <= 1'b1;
                        end else
                            phase <= phase + 4'd1;
                endcase
        end
endmodule
