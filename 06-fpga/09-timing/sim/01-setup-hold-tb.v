// tb_setup_hold.v
module tb_setup_hold;
    localparam real TSU = 2.0;   // セットアップ時間 (仮の値、ns)
    localparam real TH  = 1.0;   // ホールド時間 (仮の値、ns)

    reg  clk = 0;
    reg  d   = 0;
    reg  win = 0;                // 動かしてはいけない窓 (立ち上がりの 2 ns 前から 1 ns 後)
    wire q;

    dff u (.clk(clk), .d(d), .q(q));

    always #5 clk = ~clk;        // 立ち上がりは 5, 15, 25, ... ns (100 MHz)
    always begin                 // 窓は 3〜6, 13〜16, ... ns
        #3 win = 1;
        #3 win = 0;
        #4;
    end

    // セットアップとホールドを数える (Verilator はこれを代わりにしてくれない)
    real t_clk = -100.0;         // 直前の立ち上がりの時刻
    real t_d   = -100.0;         // 直前に D が変わった時刻
    integer ng = 0;
    always @(posedge clk) begin
        if ($realtime - t_d < TSU) begin
            ng = ng + 1;
            $display("%5.1f ns: セットアップ違反 (D は %3.1f ns 前に変わった)", $realtime, $realtime - t_d);
        end
        t_clk = $realtime;
    end
    always @(d) begin
        if ($realtime - t_clk < TH) begin
            ng = ng + 1;
            $display("%5.1f ns: ホールド違反 (立ち上がりの %3.1f ns 後に D が変わった)", $realtime, $realtime - t_clk);
        end
        t_d = $realtime;
    end

    initial begin
        $dumpfile("setup_hold.vcd");
        $dumpvars(0, tb_setup_hold);
        #10   d = 1;             // 10 ns: 立ち上がり 15 の 5 ns 前 (守っている)
        #14   d = 0;             // 24 ns: 立ち上がり 25 の 1 ns 前 (セットアップ違反)
        #11.5 d = 1;             // 35.5 ns: 立ち上がり 35 の 0.5 ns 後 (ホールド違反)
        #16.5 d = 0;             // 52 ns: 立ち上がり 55 の 3 ns 前 (守っている)
        #8    $display("違反 %0d 件", ng);
        $finish;
    end
endmodule
