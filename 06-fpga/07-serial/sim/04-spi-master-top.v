// 0.5 s ごとに 0x5A と 0xA5 を交互に 74HC595 へ送る。Pico 2 に載せる最上位。
// 74HC595 の QH' (MISO) からは 1 つ前に送った字が返る。それが合っていれば ok を 1 にする
module spi_top #(
    parameter CLK_HZ = 76_923
) (
    input  clk,
    input  rst,
    input  miso,       // GP2   74HC595 の QH' (9 番)
    output sck,        // GP3   74HC595 の SRCLK (11 番)
    output mosi,       // GP5   74HC595 の SER (14 番)
    output cs_n,       // GP4   74HC595 の RCLK (12 番)。立ち上がりで出力 QA〜QH に写る
    output ok          // GP25  返ってきた字が 1 つ前に送った字と同じなら 1 (Pico 2 の基板の LED)
);
    localparam integer HALF_S = CLK_HZ / 2;               // 0.5 s のクロック数
    localparam integer W      = $clog2(HALF_S);

    reg [W-1:0] tcnt;
    reg         start;
    reg [7:0]   data;        // 次に送る字
    reg [7:0]   last_sent;   // 1 つ前に送った字。次の送りで MISO から返ってくる
    reg [7:0]   expect_rx;   // いま送っている間に返ってくるはずの字
    reg         ok_r;
    wire        busy, done;
    wire [7:0]  rx_data;

    spi_master #(.HALF(2)) u_spi (
        .clk(clk), .rst(rst), .start(start), .tx_data(data), .miso(miso),
        .sck(sck), .mosi(mosi), .cs_n(cs_n), .busy(busy), .done(done), .rx_data(rx_data));

    assign ok = ok_r;

    always @(posedge clk)
        if (rst) begin
            tcnt      <= {W{1'b0}};
            start     <= 1'b0;
            data      <= 8'h5A;
            last_sent <= 8'h00;
            expect_rx <= 8'h00;
            ok_r      <= 1'b0;
        end else begin
            start <= 1'b0;
            if (tcnt == HALF_S[W-1:0] - 1'b1) begin
                tcnt  <= {W{1'b0}};
                start <= !busy;                  // 次のクロックで spi_master が data を取り込む (送信中なら見送る)
            end else
                tcnt <= tcnt + 1'b1;

            if (start) begin
                expect_rx <= last_sent;
                last_sent <= data;
                data      <= ~data;              // 0x5A ↔ 0xA5
            end
            if (done) ok_r <= (rx_data == expect_rx);
        end
endmodule
