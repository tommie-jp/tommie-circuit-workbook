// ムーア型とミーリー型を、同じ入力 10 万ビットで、直前 4 ビットを見る基準と比べる
module tb_seq;
    reg clk;
    reg rst;
    reg din;
    wire moore, mealy;
    wire [2:0] ms;
    wire [1:0] ys;

    seq_moore u_moore (.clk(clk), .rst(rst), .din(din), .detect(moore), .state(ms));
    seq_mealy u_mealy (.clk(clk), .rst(rst), .din(din), .detect(mealy), .state(ys));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    reg [3:0] hist;          // 直前 4 ビット (今の din が最下位)
    reg       ref_mealy;     // 基準: 今のクロックで 4 ビット目が来たか
    reg       ref_moore;     // 基準: 1 クロック遅らせたもの
    integer   cyc, bad_mealy, bad_moore, n_mealy, n_moore;

    initial begin
        rst = 1'b1; din = 1'b0; hist = 4'b0; ref_moore = 1'b0;
        cyc = 0; bad_mealy = 0; bad_moore = 0; n_mealy = 0; n_moore = 0;
        repeat (2) @(posedge clk);
        #1 rst = 1'b0;
        repeat (100000) begin
            din = ($random & 1) != 0;
            hist = {hist[2:0], din};
            ref_mealy = (hist == 4'b1011);
            #2;   // 組み合わせの出力が落ち着くのを待つ
            if (mealy !== ref_mealy) bad_mealy = bad_mealy + 1;
            if (moore !== ref_moore) bad_moore = bad_moore + 1;
            if (mealy) n_mealy = n_mealy + 1;
            if (moore) n_moore = n_moore + 1;
            @(posedge clk);
            #1;
            ref_moore = ref_mealy;
            cyc = cyc + 1;
        end
        $display("bits %0d, mealy detections %0d, moore detections %0d", cyc, n_mealy, n_moore);
        $display("mismatch vs reference: mealy %0d, moore %0d", bad_mealy, bad_moore);
        if (bad_mealy == 0 && bad_moore == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
