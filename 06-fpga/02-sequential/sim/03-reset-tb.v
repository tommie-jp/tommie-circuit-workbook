module tb_rst;
    reg clk;
    reg rst;
    reg d;
    wire q_sync, q_async;

    ff_sync_rst  u_s (.clk(clk), .rst(rst), .d(d), .q(q_sync));
    ff_async_rst u_a (.clk(clk), .rst(rst), .d(d), .q(q_async));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    initial begin
        $dumpfile("rst.vcd");
        $dumpvars(0, tb_rst);
        d = 1;
        rst = 1;
        #8  rst = 0;         //  8 us: リセットを放す
        #14 rst = 1;         // 22 us: 立ち上がり (15) の後、(25) の前にリセット
        #6  rst = 0;         // 28 us: 放す
        #10 rst = 1;         // 38 us: 立ち上がりの無い間 (35 と 45 の間) に短いリセット
        #4  rst = 0;         // 42 us
        #40 $finish;
    end
endmodule
