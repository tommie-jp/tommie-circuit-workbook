// tb_glitch.v  同じ a を、遅れ無しの回路・遅れ 2 ns の模型・遅れ 45 ns の模型に通し、パルスの数を数える
module tb_glitch;
    localparam real HALF = 18.5185;    // 27 MHz の半周期 (ns)

    reg        clk = 0;
    reg  [3:0] cnt = 4'd0;
    wire       a = cnt[3];             // 8 クロックごとに反転 (27 MHz / 16)
    wire       y_zero;                 // 遅れ 0 (glitch.v の LUT 列。シミュレータでは遅れ 0)
    wire       y_2, d_2;               // 遅れ 2 ns の模型
    wire       y_45, d_45;             // 遅れ 45 ns の模型 (1 クロック 37 ns より長い)
    reg        yr_2 = 0, yr_45 = 0;    // それぞれを 27 MHz の FF で受けたもの
    integer    n_a = 0, n_zero = 0, n_2 = 0, n_45 = 0, n_r2 = 0, n_r45 = 0;

    glitch #(.M(16)) g0 (.a(a), .y(y_zero));
    glitch_model #(.DLY(2.0))  g2  (.a(a), .y(y_2),  .d(d_2));
    glitch_model #(.DLY(45.0)) g45 (.a(a), .y(y_45), .d(d_45));

    always #(HALF) clk = ~clk;
    always @(posedge clk) begin
        cnt  <= cnt + 4'd1;
        yr_2  <= y_2;
        yr_45 <= y_45;
    end

    always @(posedge a or negedge a) n_a = n_a + 1;
    always @(posedge y_zero) n_zero = n_zero + 1;
    always @(posedge y_2)    n_2    = n_2 + 1;
    always @(posedge y_45)   n_45   = n_45 + 1;
    always @(posedge yr_2)   n_r2   = n_r2 + 1;
    always @(posedge yr_45)  n_r45  = n_r45 + 1;

    initial begin
        $dumpfile("glitch.vcd");
        $dumpvars(0, tb_glitch);
        #10000;
        $display("a の変化 %0d 回", n_a);
        $display("遅れ 0 の回路           : y のパルス %0d 個", n_zero);
        $display("遅れ 2 ns の模型        : y のパルス %0d 個、FF で受けた出力のパルス %0d 個", n_2, n_r2);
        $display("遅れ 45 ns の模型       : y のパルス %0d 個、FF で受けた出力のパルス %0d 個", n_45, n_r45);
        $finish;
    end
endmodule
