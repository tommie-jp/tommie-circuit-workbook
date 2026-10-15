module tb_blink16;
    reg clk;
    reg rst;
    wire led;

    blink #(.CLK_HZ(16), .BLINK_HZ(1)) u (.clk(clk), .rst(rst), .led(led));

    initial clk = 0;
    always #31250 clk = ~clk;    // 16 Hz: 周期 62500 us。立ち上がりは 31250, 93750, ... us

    initial begin
        $dumpfile("blink16.vcd");
        $dumpvars(0, tb_blink16);
        rst = 1;
        #50000 rst = 0;          // 50 ms: 2 つ目の立ち上がり (93.75 ms) の前に放す
        #3000000 $finish;        // 3 s
    end
endmodule
