// 図の波形を取る試験台。終盤の 1 局面で最善手を探させ、クロックごとの cand と best を出す。
// 1 クロックを 10 時間単位 (10 µs と置く) にした
`timescale 1us/1ns
module tb_wave;
    reg         clk, rst, start;
    reg  [63:0] own = 64'h1602_197B_771F_1704;   // 黒 (打つ側)
    reg  [63:0] opp = 64'h40FC_E084_88E0_E8F9;   // 白
    wire [63:0] legal;
    /* verilator lint_off UNUSEDSIGNAL */
    wire [63:0] flip;           // この図では使わない
    /* verilator lint_on UNUSEDSIGNAL */
    wire        busy, done, found;
    wire [5:0]  best;
    wire [4:0]  best_gain;

    reversi_accel u (.clk(clk), .rst(rst), .own(own), .opp(opp), .move(6'd0), .start(start),
                     .legal(legal), .flip(flip), .busy(busy), .done(done), .found(found),
                     .best(best), .best_gain(best_gain));

    always #5 clk = ~clk;

    always @(posedge clk)
        #1 $display("t=%0d start=%b busy=%b done=%b cand=%0d best=%0d gain=%0d",
                    $time - 1, start, busy, done, u.cand, best, best_gain);

    initial begin
        clk = 0; rst = 1; start = 0;
        $dumpfile("accel.vcd");
        $dumpvars(0, tb_wave);
        #12 rst = 0;
        #4  start = 1;            // 16 µs
        #10 start = 0;            // 26 µs
        @(posedge done);
        #20;
        if (found && best == 6'd63 && best_gain == 5'd2) $display("PASS: best=h8 gain=2, legal=%016h", legal);
        else                                             $display("FAIL");
        $finish;
    end
endmodule
