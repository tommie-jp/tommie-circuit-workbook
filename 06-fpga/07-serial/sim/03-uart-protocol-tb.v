`timescale 1ns / 1ps
// count_top を 13 µs のクロックで 5.6 s 回し、送った字を 3 通りの受け手で読む。
// 4800 bps (正しい設定) と、まちがえた 9600 bps・2400 bps (Protocol の Baud をまちがえたとき)
module tb_count;
    reg clk;
    reg rst;
    initial begin
        clk = 1'b0;
        forever #6500 clk = ~clk;
    end
    wire txd;
    count_top dut (.clk(clk), .rst(rst), .txd(txd));

    // まちがえた Baud で 2 行目 (1.0〜1.1 s) に読んだ字を、終わりにまとめて書く
    reg [7:0] got [0:1][0:31];
    reg       bad [0:1][0:31];
    integer   ngot [0:1];
    initial begin ngot[0] = 0; ngot[1] = 0; end

    // 受け手: 立ち下がりから 1.5 ビット待って 1 ビットごとに読む。
    task automatic rx_loop(input real baud);
        real    bit_ns;
        integer b;
        reg [7:0] ch;
        begin
            bit_ns = 1.0e9 / baud;
            forever begin
                @(negedge txd);
                #(bit_ns * 1.5);
                for (b = 0; b < 8; b = b + 1) begin ch[b] = txd; #(bit_ns); end
                if (baud == 4800.0) begin
                    if (ch >= 8'h20 && ch < 8'h7F) $write("%c", ch);
                    else                            $write("<%02h>", ch);
                    if (ch == 8'h0A) $write("   (%7.3f s)\n", $realtime / 1.0e9);
                end else if ($realtime > 1.0e9 && $realtime < 1.1e9) begin
                    got[baud == 9600.0 ? 0 : 1][ngot[baud == 9600.0 ? 0 : 1]] = ch;
                    bad[baud == 9600.0 ? 0 : 1][ngot[baud == 9600.0 ? 0 : 1]] = !txd;
                    ngot[baud == 9600.0 ? 0 : 1] = ngot[baud == 9600.0 ? 0 : 1] + 1;
                end
            end
        end
    endtask

    initial rx_loop(4800.0);
    initial rx_loop(9600.0);
    initial rx_loop(2400.0);

    integer j, k;
    initial begin
        rst = 1'b1;
        #26000 rst = 1'b0;
        #5600000000.0;
        for (k = 0; k < 2; k = k + 1) begin
            $write("%s bps で読んだ 2 行目:", k == 0 ? "9600" : "2400");
            for (j = 0; j < ngot[k]; j = j + 1)
                $write(" %02h%s", got[k][j], bad[k][j] ? "!" : "");
            $write("   (! はストップビットが 0)\n");
        end
        $finish;
    end
endmodule
