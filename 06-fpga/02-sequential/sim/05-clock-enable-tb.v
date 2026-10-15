module tb_clk_enable;
    reg clk;
    reg rst;
    wire tick;
    wire [3:0] q;
    integer n_tick;

    clk_enable #(.W(2)) u (.clk(clk), .rst(rst), .tick(tick), .q(q));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    always @(posedge clk) if (!rst && tick) n_tick <= n_tick + 1;

    initial begin
        $dumpfile("clk_enable.vcd");
        $dumpvars(0, tb_clk_enable);
        n_tick = 0;
        rst = 1;
        #12 rst = 0;         // 12 us: 立ち上がり (15) の前に放す
        #400;
        $display("clocks=40 tick_count=%0d q=%0d", n_tick, q);
        $finish;
    end
endmodule
