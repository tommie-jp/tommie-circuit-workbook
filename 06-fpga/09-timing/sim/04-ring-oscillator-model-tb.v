// tb_ring_model.v  遅れを # で入れた模型。段数を 3・5・7・9 にして、周期が 2 × 段数 × 遅れ になるかを見る
module tb_ring_model;
    localparam real TPD = 0.5;    // 1 段の遅れ (ns)。模型のために決めた値で、実物の値ではない

    reg  en = 0;
    wire y3, y5, y7, y9;
    real t_prev3 = 0, t_last3 = 0, t_prev5 = 0, t_last5 = 0;
    real t_prev7 = 0, t_last7 = 0, t_prev9 = 0, t_last9 = 0;

    ring_model #(.N(3), .TPD(TPD)) u3 (.en(en), .y(y3));
    ring_model #(.N(5), .TPD(TPD)) u5 (.en(en), .y(y5));
    ring_model #(.N(7), .TPD(TPD)) u7 (.en(en), .y(y7));
    ring_model #(.N(9), .TPD(TPD)) u9 (.en(en), .y(y9));

    always @(posedge y3) begin t_prev3 = t_last3; t_last3 = $realtime; end
    always @(posedge y5) begin t_prev5 = t_last5; t_last5 = $realtime; end
    always @(posedge y7) begin t_prev7 = t_last7; t_last7 = $realtime; end
    always @(posedge y9) begin t_prev9 = t_last9; t_last9 = $realtime; end

    initial begin
        $dumpfile("ring_model.vcd");
        $dumpvars(0, tb_ring_model.u5);
        #10 en = 1;               // 10 ns で発振を許す
        #200;
        $display("N = 3: 周期 %0.3f ns (2 x N x TPD = %0.3f ns)", t_last3 - t_prev3, 2.0 * 3 * TPD);
        $display("N = 5: 周期 %0.3f ns (2 x N x TPD = %0.3f ns)", t_last5 - t_prev5, 2.0 * 5 * TPD);
        $display("N = 7: 周期 %0.3f ns (2 x N x TPD = %0.3f ns)", t_last7 - t_prev7, 2.0 * 7 * TPD);
        $display("N = 9: 周期 %0.3f ns (2 x N x TPD = %0.3f ns)", t_last9 - t_prev9, 2.0 * 9 * TPD);
        $finish;
    end
endmodule
