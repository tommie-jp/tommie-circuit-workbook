module tb_shift4;
    reg clk;
    reg rst;
    reg din;
    wire [3:0] q;

    shift4 u (.clk(clk), .rst(rst), .din(din), .q(q));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    initial begin
        $dumpfile("shift4.vcd");
        $dumpvars(0, tb_shift4);
        rst = 1; din = 0;
        #12 rst = 0;         // 12 us: リセットを放す
        #8  din = 1;         // 20 us: 立ち上がり (25) の前に 1 を与え
        #10 din = 0;         // 30 us: 1 クロックぶんだけで 0 に戻す
        #100 $finish;
    end
endmodule
