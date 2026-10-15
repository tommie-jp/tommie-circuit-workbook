module tb_nb;
    reg clk;
    reg d;
    wire nb_q1, nb_q2, bl_q1, bl_q2, rv_q1, rv_q2;

    shift_nb      u_nb (.clk(clk), .d(d), .q1(nb_q1), .q2(nb_q2));
    shift_bl      u_bl (.clk(clk), .d(d), .q1(bl_q1), .q2(bl_q2));
    shift_bl_rev  u_rv (.clk(clk), .d(d), .q1(rv_q1), .q2(rv_q2));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    initial begin
        $dumpfile("nb.vcd");
        $dumpvars(0, tb_nb);
        d = 0;
        #8  d = 1;           //  8 us: 1 を 1 クロックぶんだけ与える
        #10 d = 0;           // 18 us
        #52 $finish;
    end
endmodule
