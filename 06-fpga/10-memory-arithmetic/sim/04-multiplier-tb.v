// tb_mul.v  13 × 11 の波形を取る。+full を付けると 0〜255 × 0〜255 の全部を * と突き合わせる
module tb_mul;
    reg         clk = 0;
    reg         rst = 1;
    reg         start = 0;
    reg  [7:0]  a = 0;
    reg  [7:0]  b = 0;
    wire [15:0] p_seq;
    wire        busy, done;
    wire [15:0] p_op;
    integer     i, j;
    integer     ng = 0;
    integer     clocks;
    reg  [15:0] want;

    mul8_seq us (.clk(clk), .rst(rst), .start(start), .a(a), .b(b),
                 .p(p_seq), .busy(busy), .done(done));
    mul8_op  uo (.a(a), .b(b), .p(p_op));

    always #5 clk = ~clk;        // 立ち上がりは 5, 15, 25, ... us

    // a × b を 1 回計算する。start を 1 クロック出し、done まで待つ
    task run(input [7:0] ta, input [7:0] tb);
        begin
            a = ta; b = tb; start = 1;
            @(posedge clk); #1;
            start = 0;
            clocks = 0;
            while (!done) begin
                @(posedge clk); #1;
                clocks = clocks + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("mul.vcd");
        $dumpvars(0, tb_mul);
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;
        run(8'd13, 8'd11);       // 波形に残す 1 回
        $display("13 x 11: seq=%0d op=%0d (start の次の立ち上がりから done まで %0d クロック)",
                 p_seq, p_op, clocks);
        if (p_seq !== 16'd143 || p_op !== 16'd143) ng = ng + 1;
        #20;
        if ($test$plusargs("full")) begin
            for (i = 0; i < 256; i = i + 1)
                for (j = 0; j < 256; j = j + 1) begin
                    run(i[7:0], j[7:0]);
                    want = i[7:0] * j[7:0];
                    if (p_seq !== want || p_op !== want) ng = ng + 1;
                end
            if (ng == 0) $display("PASS: 65536 通りとも * と同じ");
            else         $display("FAIL: %0d 件", ng);
        end else begin
            if (ng == 0) $display("PASS: 13 x 11");
            else         $display("FAIL");
        end
        $finish;
    end
endmodule
