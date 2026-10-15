`timescale 1us / 100ns
module tb_raw;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg btn_n = 1'b1;
    wire [6:0] seg;
    top_raw dut (.clk(clk), .rst_n(rst_n), .btn_n(btn_n), .seg(seg));
    always #500 clk = ~clk;
    task press_with_bounce;
        begin
            btn_n = 1'b0; #700;  btn_n = 1'b1; #600;
            btn_n = 1'b0; #500;  btn_n = 1'b1; #900;
            btn_n = 1'b0;
            #100000;
            btn_n = 1'b1; #600; btn_n = 1'b0; #700; btn_n = 1'b1;
            #100000;
            $display("%8.1f ms  n=%h  seg=%b", $realtime / 1000.0, dut.n, seg);
        end
    endtask
    integer i;
    initial begin
        #3000 rst_n = 1'b1;
        $display("%8.1f ms  n=%h  seg=%b", $realtime / 1000.0, dut.n, seg);
        for (i = 0; i < 3; i = i + 1) press_with_bounce;
        $finish;
    end
endmodule
