`timescale 1ns / 1ps
// 8 ビット x 8 ビットの全 65536 組を、分けた版 (mul_top) と分けない版 (mul_flat) で回し、
// 積が a * b に合うか、done が出るまでのクロック数が両方で同じか調べる。
// 4 ビット版 (W = 4) も同じ制御器のまま全 256 組を回す
module tb_mul;
    reg        clk;
    reg        rst;
    reg        start;
    reg  [7:0] a;
    reg  [7:0] b;
    wire [15:0] p_s;
    wire        done_s;
    wire [15:0] p_f;
    wire        done_f;
    wire [7:0]  p4;
    wire        done4;

    mul_top  #(.W(8)) split  (.clk(clk), .rst(rst), .start(start), .a(a), .b(b), .p(p_s), .done(done_s));
    mul_flat #(.W(8)) flat   (.clk(clk), .rst(rst), .start(start), .a(a), .b(b), .p(p_f), .done(done_f));
    mul_top  #(.W(4)) narrow (.clk(clk), .rst(rst), .start(start), .a(a[3:0]), .b(b[3:0]), .p(p4), .done(done4));

    initial begin clk = 1'b0; forever #5 clk = ~clk; end

    integer n_bad    = 0;     // 積が合わない回数
    integer n_diff   = 0;     // 分けた版と分けない版が食い違った回数
    integer n_late   = 0;     // クロック数が 2b + 2 にならなかった回数
    integer n_runs   = 0;
    integer n_clocks = 0;
    integer max_clk  = 0;
    integer i, j, n;
    reg     ok4;
    wire [7:0]  want4 = a[3:0] * b[3:0];   // 4 ビット版の正しい積
    reg  [15:0] want;

    // a x b を 1 回回し、start を受けてから done が見えるまでのクロック数を返す
    task run(input [7:0] ta, input [7:0] tb, output integer clocks);
        begin
            a = ta; b = tb;
            start = 1'b1;
            @(posedge clk);            // start を受ける (これを 0 番目の立ち上がりと数える)
            #1 start = 1'b0;
            n = 0;
            while (!done_s) begin
                @(posedge clk);
                #1 n = n + 1;
            end
            clocks = n;
            want = ta * tb;
            if (p_s !== want) n_bad = n_bad + 1;
            if (p_s !== p_f || done_s !== done_f) n_diff = n_diff + 1;
            if (n != 2 * tb + 2) n_late = n_late + 1;
            n_runs = n_runs + 1;
            n_clocks = n_clocks + n;
            if (n > max_clk) max_clk = n;
            @(posedge clk);            // DONE から IDLE へ
            #1;
        end
    endtask

    integer c;
    initial begin
        rst = 1'b1; start = 1'b0; a = 8'd0; b = 8'd0;
        repeat (3) @(posedge clk);
        #1 rst = 1'b0;

        // 見せる例
        $display("   a    b      p  clocks");
        run(8'd5,   8'd3,   c); $display("%4d %4d %6d %6d", 5, 3, p_s, c);
        run(8'd12,  8'd0,   c); $display("%4d %4d %6d %6d", 12, 0, p_s, c);
        run(8'd0,   8'd9,   c); $display("%4d %4d %6d %6d", 0, 9, p_s, c);
        run(8'd7,   8'd1,   c); $display("%4d %4d %6d %6d", 7, 1, p_s, c);
        run(8'd1,   8'd7,   c); $display("%4d %4d %6d %6d", 1, 7, p_s, c);
        run(8'd255, 8'd255, c); $display("%4d %4d %6d %6d", 255, 255, p_s, c);

        n_bad = 0; n_diff = 0; n_late = 0; n_runs = 0; n_clocks = 0; max_clk = 0;
        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 256; j = j + 1)
                run(i[7:0], j[7:0], c);
        $display("8 bit: %0d runs, bad %0d, split/flat differ %0d, not 2b+2 %0d, max %0d clocks, avg %0d.%0d",
                 n_runs, n_bad, n_diff, n_late, max_clk, n_clocks / n_runs, (n_clocks * 10 / n_runs) % 10);

        // 4 ビット版: 同じ制御器 (mul_ctl) のまま。a と b の下位 4 ビットだけ使う
        ok4 = 1'b1;
        for (i = 0; i < 16; i = i + 1)
            for (j = 0; j < 16; j = j + 1) begin
                a = i[7:0]; b = j[7:0];
                start = 1'b1; @(posedge clk); #1 start = 1'b0;
                while (!done4) begin @(posedge clk); #1; end
                if (p4 !== want4) ok4 = 1'b0;
                @(posedge clk); #1;
            end
        $display("4 bit: 256 runs, %s", ok4 ? "all match" : "MISMATCH");
        if (n_bad == 0 && n_diff == 0 && n_late == 0 && ok4) $display("PASS");
        else                                                $display("FAIL");
        $finish;
    end
endmodule
