`timescale 1ns / 1ps
// top.v を 27 MHz のクロックで回し、blink_out と led_n の変わり目の時刻を書く
module tb_top;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    wire led_n, blink_out;
    top dut (.clk(clk), .rst_n(rst_n), .led_n(led_n), .blink_out(blink_out));
    always #18.5185 clk = ~clk;            // 27 MHz
    always @(blink_out) $display("blink_out = %b at %0.6f s, led_n = %b", blink_out, $realtime / 1.0e9, led_n);
    initial begin
        #200 rst_n = 1'b1;
        #2300000000.0;
        $finish;
    end
endmodule
