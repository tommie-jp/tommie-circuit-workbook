// 2 進・ワンホット・グレイの 3 つを同じ入力 10 万ビットで回す。
// 検出が基準 (直前 4 ビット) と合うこと、状態レジスタのビットが何回変わったかを数える。
// 最後に、定義していない符号を 1 つ押し込んで、次のクロックで S0 に戻ることを見る
module tb_enc;
    reg clk;
    reg rst;
    reg din;
    wire d0, d1, d2, d3;
    wire [4:0] s0, s1, s2, s3;

    seq_enc #(.ENC(0)) u0 (.clk(clk), .rst(rst), .din(din), .detect(d0), .state(s0));
    seq_enc #(.ENC(1)) u1 (.clk(clk), .rst(rst), .din(din), .detect(d1), .state(s1));
    seq_enc #(.ENC(2)) u2 (.clk(clk), .rst(rst), .din(din), .detect(d2), .state(s2));
    seq_onehot u3 (.clk(clk), .rst(rst), .din(din), .detect(d3), .state(s3));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    reg [3:0] hist;
    reg       ref_moore;
    reg [4:0] p0, p1, p2, p3;
    integer   k, cyc, bad, flips0, flips1, flips2, flips3, moves0, moves1, moves2, moves3;

    function integer popcount(input [4:0] v);
        integer k;
        begin
            popcount = 0;
            for (k = 0; k < 5; k = k + 1) popcount = popcount + {31'd0, v[k]};
        end
    endfunction

    initial begin
        rst = 1'b1; din = 1'b0; hist = 4'b0; ref_moore = 1'b0;
        cyc = 0; bad = 0; flips0 = 0; flips1 = 0; flips2 = 0; flips3 = 0; moves0 = 0; moves1 = 0; moves2 = 0; moves3 = 0;
        repeat (2) @(posedge clk);
        #1 rst = 1'b0;
        p0 = s0; p1 = s1; p2 = s2; p3 = s3;
        repeat (100000) begin
            din = ($random & 1) != 0;
            hist = {hist[2:0], din};
            @(posedge clk);
            #1;
            // この立ち上がりで din を取り込んだ。検出は 1 クロック後の状態に出る
            ref_moore = (hist == 4'b1011);
            if (d0 !== ref_moore || d1 !== ref_moore || d2 !== ref_moore || d3 !== ref_moore) bad = bad + 1;
            flips0 = flips0 + popcount(s0 ^ p0); if (s0 != p0) moves0 = moves0 + 1;
            flips1 = flips1 + popcount(s1 ^ p1); if (s1 != p1) moves1 = moves1 + 1;
            flips2 = flips2 + popcount(s2 ^ p2); if (s2 != p2) moves2 = moves2 + 1;
            flips3 = flips3 + popcount(s3 ^ p3); if (s3 != p3) moves3 = moves3 + 1;
            p0 = s0; p1 = s1; p2 = s2; p3 = s3;
            cyc = cyc + 1;
        end
        $display("bits %0d, mismatches with reference %0d", cyc, bad);
        $display("            width  state moves  bit flips  flips/move");
        $display("binary      %0d      %0d        %0d      %0.3f", 3, moves0, flips0, flips0 * 1.0 / moves0);
        $display("one-hot     %0d      %0d        %0d      %0.3f", 5, moves1, flips1, flips1 * 1.0 / moves1);
        $display("gray        %0d      %0d        %0d      %0.3f", 3, moves2, flips2, flips2 * 1.0 / moves2);
        $display("onehot-2   %0d      %0d        %0d      %0.3f", 5, moves3, flips3, flips3 * 1.0 / moves3);
        if (bad == 0) $display("PASS"); else $display("FAIL");

        // 定義していない符号を押し込む (宇宙線や電源の乱れで状態レジスタが化けた想定)
        din = 1'b0;
        u0.st = 3'd7;      // 2 進の 111
        u1.st = 5'b00011;  // ワンホットで 2 本立った
        u2.st = 3'd5;      // グレイの 101
        u3.st = 5'b00011;  // ワンホットらしく書いた物も 2 本立てる
        #1;
        $display("forced:   binary %b  one-hot %b  gray %b  onehot-2 %b", u0.st, u1.st, u2.st, u3.st);
        for (k = 0; k < 5; k = k + 1) begin
            @(posedge clk); #1;
            $display("clk +%0d:  binary %b  one-hot %b  gray %b  onehot-2 %b", k + 1, u0.st, u1.st, u2.st, u3.st);
            din = ($random & 1) != 0;
        end
        $finish;
    end
endmodule
