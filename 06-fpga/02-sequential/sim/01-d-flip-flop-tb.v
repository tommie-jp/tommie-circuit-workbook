module tb_dff;
    reg clk;
    reg d;
    wire q;

    dff u (.clk(clk), .d(d), .q(q));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    initial begin
        $dumpfile("dff.vcd");
        $dumpvars(0, tb_dff);
        d = 0;
        #8  d = 1;           //  8 us: 立ち上がり (15) の前に 1
        #9  d = 0;           // 17 us: 立ち上がり (15) の後に 0
        #11 d = 1;           // 28 us: 立ち上がりの間に 1 にして
        #4  d = 0;           // 32 us: 立ち上がり (35) の前に 0 へ戻す
        #4  d = 1;           // 36 us: 立ち上がり (45) の前に 1
        #11 d = 0;           // 47 us: 立ち上がり (45) の後に 0
        #33 $finish;
    end
endmodule
