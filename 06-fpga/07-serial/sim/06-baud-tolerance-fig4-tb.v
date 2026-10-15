`timescale 1ns / 1ps
// 図4: 送り手を +5.0 % ずらし (1 ビット 218.4 us)、0x55 を 1 字送る。TXD と SMP の変わり目を
// スタートビットの立ち下がりからの時刻で書く
module tb_fig4;
    reg clk;
    initial begin clk = 1'b0; forever #6500 clk = ~clk; end
    reg rst, line;
    wire [7:0] data;
    wire valid, frame_err, sample;
    uart_rx dut (.clk(clk), .rst(rst), .rxd(line), .data(data), .valid(valid), .frame_err(frame_err), .sample(sample));
    localparam real BT = 208000.0 * 1.05;
    realtime t0;
    always @(line)   if (t0 > 0) $display("TXD %8.1f %b", ($realtime - t0) / 1000.0, line);
    always @(sample) if (t0 > 0) $display("SMP %8.1f %b", ($realtime - t0) / 1000.0, sample);
    integer k;
    initial begin
        t0 = 0; line = 1'b1; rst = 1'b1;
        #40000 rst = 1'b0;
        #1004000;
        t0 = $realtime;
        line = 1'b0; #(BT);
        for (k = 0; k < 8; k = k + 1) begin line = (8'h55 >> k) & 1; #(BT); end
        line = 1'b1; #(BT);
        #500000;
        $display("data %02h valid-seen frame_err %b", data, frame_err);
        $finish;
    end
endmodule
