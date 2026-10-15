`timescale 1ns / 1ps
// 74HC595 の動きを真似た模型 (SRCLK↑ で SER を取り込む・RCLK↑ で出力へ写す・QH' は最上段) に
// spi_top をつなぎ、送った字が QA〜QH に出ること・次の送りで 1 つ前の字が MISO に返ることを確かめる
module tb_spi;
    reg clk;
    initial begin
        clk = 1'b0;
        forever #6500 clk = ~clk;                // 13 us
    end
    reg rst;
    wire sck, mosi, cs_n, ok;
    wire qh_p;

    // ---- 74HC595 の模型
    reg [7:0] sh;      // シフトレジスタ (sh[7] が QH' に出る)
    reg [7:0] q;       // 出力ラッチ (QA = q[0] … QH = q[7])
    initial begin sh = 8'hC3; q = 8'h00; end    // 電源投入直後は不定。適当な値にしておく
    always @(posedge sck) sh <= {sh[6:0], mosi}; // 上へ送って、いちばん下へ SER を入れる
    always @(posedge cs_n) q <= sh;              // RCLK = CS の立ち上がりで出力へ
    assign qh_p = sh[7];

    spi_top dut (.clk(clk), .rst(rst), .miso(qh_p), .sck(sck), .mosi(mosi), .cs_n(cs_n), .ok(ok));

    // ---- 記録
    realtime tcs;
    integer  nxfer = 0;
    integer  nsck = 0;
    always @(posedge sck) nsck = nsck + 1;
    always @(negedge cs_n) tcs = $realtime;
    real tlow;
    always @(posedge cs_n)
        if (!rst) begin
            nxfer = nxfer + 1;
            tlow = $realtime - tcs;
            #40000;                                 // 出力と ok が更新されたあとで書く
            $display("transfer %0d: CS low %6.1f us, QA-QH = %b (0x%02h)  ok(GP25) = %b",
                     nxfer, tlow / 1000.0, q, q, ok);
        end

    // 2 回目の送り (0xA5 を送り、1 つ前の 0x5A が返る) の変わり目を CS の立ち下がりからの時刻で書く
    always @(sck or mosi or cs_n or qh_p)
        if (!rst && nxfer == 1 && $realtime - tcs < 600000)
            $display("  edge %9.3f us  cs_n=%b sck=%b mosi=%b miso=%b", ($realtime - tcs) / 1000.0, cs_n, sck, mosi, qh_p);

    initial begin
        rst = 1'b1;
        #26000 rst = 1'b0;
        wait (nxfer == 6);
        #60000;
        $display("SCK rising edges: %0d (6 transfers x 8)", nsck);
        $finish;
    end
endmodule
