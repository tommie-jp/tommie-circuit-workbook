// エコーバック: 受けた字をそのまま送り返す。Pico 2 に載せる最上位。
// 受信 (uart_rx) が valid を出したら、送信 (uart_tx) が空くのを待って送る。
// 送り返す字は 1 字ぶんだけ待たせられる (pend)。もう 1 字来たら取りこぼす。
// 取りこぼしと、ストップビットが 0 だったこと (フレームエラー) は err を 1 にして残す
module echo_top #(
    parameter CLK_HZ = 76_923,
    parameter BAUD   = 4800
) (
    input  clk,
    input  rst,
    input  rxd,          // GP14
    output txd,          // GP15
    output smp,          // GP16 受信が線を読んだ直後だけ 1 (7-2 の sample)
    output err           // GP25 (Pico 2 の基板の LED)。取りこぼしかフレームエラーがあれば 1 のまま
);
    wire [7:0] rdata;
    wire       valid, frame_err, sample;

    uart_rx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
        .clk(clk), .rst(rst), .rxd(rxd),
        .data(rdata), .valid(valid), .frame_err(frame_err), .sample(sample));

    reg  [7:0] pend;       // 送るのを待っている字
    reg        pend_v;     // pend に字が入っている
    reg        err_r;
    reg  [7:0] tx_data;
    reg        tx_start;
    wire       tx_busy;

    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
        .clk(clk), .rst(rst), .data(tx_data), .start(tx_start), .txd(txd), .busy(tx_busy));

    assign smp = sample;
    assign err = err_r;

    always @(posedge clk)
        if (rst) begin
            pend     <= 8'h00;
            pend_v   <= 1'b0;
            err_r    <= 1'b0;
            tx_data  <= 8'h00;
            tx_start <= 1'b0;
        end else begin
            tx_start <= 1'b0;

            // 送信が空いていて、待っている字があれば送る
            if (pend_v && !tx_busy && !tx_start) begin
                tx_data  <= pend;
                tx_start <= 1'b1;
                pend_v   <= 1'b0;
            end

            // 受けた字を待たせる。待たせる場所がふさがっていたら取りこぼし
            if (frame_err) err_r <= 1'b1;
            if (valid) begin
                if (pend_v && (tx_busy || tx_start)) err_r <= 1'b1;   // 待たせる場所がふさがっている
                else begin
                    pend   <= rdata;
                    pend_v <= 1'b1;
                end
            end
        end
endmodule
