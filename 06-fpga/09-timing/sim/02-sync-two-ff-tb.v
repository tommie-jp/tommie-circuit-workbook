// tb_sync2.v  クロックと無関係な入力を 2 段で受ける。変わった時刻と、出てくる時刻を比べる
module tb_sync2;
    localparam real HALF = 18.5185;   // 27 MHz の半周期 (ns)。周期 37.037 ns

    reg  clk = 0;
    reg  d_async = 0;
    wire q1, q;
    real t_rise = 0, t_fall = 0;     // 入力が最後に 1 になった時刻、0 になった時刻
    integer n_edge = 0;

    sync2 u (.clk(clk), .d_async(d_async), .q1(q1), .q(q));

    always #(HALF) clk = ~clk;        // 立ち上がりは 18.5185 + 37.037 × k ns

    // 入力が変わってから、q が変わるまでの時間 (ns とクロック数) を出す
    always @(posedge d_async) t_rise = $realtime;
    always @(negedge d_async) t_fall = $realtime;
    always @(posedge q) begin
        n_edge = n_edge + 1;
        $display("%7.1f ns: Q が 1 に。入力が 1 になってから %5.1f ns (%4.2f クロック)",
                 $realtime, $realtime - t_rise, ($realtime - t_rise) / (2 * HALF));
    end
    always @(negedge q) begin
        n_edge = n_edge + 1;
        $display("%7.1f ns: Q が 0 に。入力が 0 になってから %5.1f ns (%4.2f クロック)",
                 $realtime, $realtime - t_fall, ($realtime - t_fall) / (2 * HALF));
    end

    // 入力は 27 MHz のクロックとは無関係な時刻に変える
    initial begin
        $dumpfile("sync2.vcd");
        $dumpvars(0, tb_sync2);
        #100.0 d_async = 1;           // 長く 1
        #300.0 d_async = 0;           // 400 ns
        #300.0 d_async = 1;           // 700 ns: 10 ns の細いパルス
        #10.0  d_async = 0;           // 710 ns
        #90.0  d_async = 1;           // 800 ns: 30 ns のパルス (1 クロックより短い)
        #30.0  d_async = 0;           // 830 ns
        #30.0  d_async = 1;           // 860 ns: 30 ns のパルス
        #30.0  d_async = 0;           // 890 ns
        #100.0 d_async = 1;           // 990 ns: 長く 1
        #200.0 $display("Q の変わり目 %0d 回", n_edge);
        $finish;
    end
endmodule
