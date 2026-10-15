// CLK_HZ = 1000 (1 クロック = 1 ms) で、設定 → 計数 → 0 で鳴る → 30 秒で戻るまでを回し、自分で合否を言う
module tb_timer99;
    reg clk = 0;
    reg rst = 1;
    reg plus_n = 1;
    reg ss_n   = 1;
    wire [6:0] seg_tens, seg_ones;
    wire       buzzer, sec;
    wire [1:0] state;
    wire [7:0] count;
    integer errors = 0;
    integer now = 0;                         // 何 ms 目か

    timer99 #(.CLK_HZ(1000), .TONE_HZ(500), .RING_S(30)) u (
        .clk(clk), .rst(rst), .btn_plus_n(plus_n), .btn_ss_n(ss_n),
        .seg_tens(seg_tens), .seg_ones(seg_ones), .buzzer(buzzer), .sec(sec),
        .o_state(state), .o_count(count));

    always #1 clk = ~clk;                    // 1 周期 = 2 時間単位 = 1 ms とみなす
    always @(posedge clk) now <= now + 1;

    task ms(input integer n);
        repeat (n) @(posedge clk);
    endtask

    task expect_st(input [1:0] want_state, input [7:0] want_count, input [8*28-1:0] what);
        if (state !== want_state || count !== want_count) begin
            $display("NG %0s: state=%0d count=%h (want %0d %h)", what, state, count, want_state, want_count);
            errors = errors + 1;
        end else
            $display("ok %0s: state=%0d count=%h", what, state, count);
    endtask

    // 押して n ms 待って離す。押し始めの 5 ms は 1 ms ごとに跳ねる
    task push(input integer which, input integer n);
        integer i;
        begin
            for (i = 0; i < 5; i = i + 1) begin
                if (which == 0) plus_n = i[0]; else ss_n = i[0];
                ms(1);
            end
            if (which == 0) plus_n = 0; else ss_n = 0;
            ms(n);
            if (which == 0) plus_n = 1; else ss_n = 1;
            ms(50);
        end
    endtask

    localparam PLUS = 0, SS = 1;
    localparam [1:0] SET = 0, RUN = 1, RING = 2;

    // 状態が変わった時刻を書く
    reg [1:0] last_state = 0;
    integer t_run = 0, t_ring = 0, t_set = 0;
    always @(posedge clk) begin
        if (state !== last_state) begin
            $display("   %7d ms  state %0d -> %0d  count=%h", now, last_state, state, count);
            if (state == RUN)  t_run  = now;
            if (state == RING) t_ring = now;
            if (state == SET && last_state == RING) t_set = now;
        end
        last_state <= state;
    end

    // sec の立ち上がりの間隔と、ブザーの立ち上がりの数・間隔
    integer sec_last = 0, sec_gap = 0, bz_rises = 0, bz_last = 0, bz_gap = 0;
    reg sec_d = 0, bz_d = 0;
    always @(posedge clk) begin
        sec_d <= sec;
        bz_d  <= buzzer;
        if (sec && !sec_d) begin sec_gap = now - sec_last; sec_last = now; end
        if (buzzer && !bz_d) begin bz_rises = bz_rises + 1; bz_gap = now - bz_last; bz_last = now; end
    end

    initial begin
        ms(3); rst = 0; ms(10);
        expect_st(SET, 8'h00, "after reset");
        push(SS, 100);   expect_st(SET, 8'h00, "start at 00 is ignored");

        push(PLUS, 100); push(PLUS, 100); push(PLUS, 100);
        expect_st(SET, 8'h03, "plus x3 (short)");
        push(PLUS, 2000);                                   // 長押し 2 s
        expect_st(SET, 8'h20, "plus held 2 s");

        push(SS, 100);                                      // RUN へ (押して 25 ms ほどで入る)
        ms(5370);        expect_st(RUN, 8'h15, "run 5.5 s");
        $display("   sec period %0d ms", sec_gap);
        if (sec_gap != 1000) begin $display("NG sec period"); errors = errors + 1; end

        push(SS, 100);   expect_st(SET, 8'h15, "pause");
        ms(3000);        expect_st(SET, 8'h15, "pause 3 s later");
        push(SS, 100);                                      // もう一度押して続きから
        ms(15000);       expect_st(RING, 8'h00, "0 -> ring");
        $display("   RUN -> RING %0d ms", t_ring - t_run);
        if (t_ring - t_run != 15000) begin $display("NG run length"); errors = errors + 1; end

        bz_rises = 0;
        ms(1000);
        $display("   buzzer: %0d rises in 1 s, period %0d ms", bz_rises, bz_gap);
        if (bz_rises != 250 || bz_gap != 2) begin $display("NG buzzer"); errors = errors + 1; end

        ms(29500);       expect_st(SET, 8'h00, "back to SET after 30 s");
        $display("   rang %0d ms", t_set - t_ring);
        if (t_set - t_ring != 30000) begin $display("NG ring length"); errors = errors + 1; end
        if (buzzer !== 1'b0) begin $display("NG buzzer stays on"); errors = errors + 1; end

        push(PLUS, 12000);                                  // 長押し 12 s: 99 で止まる
        expect_st(SET, 8'h99, "plus held 12 s stops at 99");
        push(PLUS, 100); expect_st(SET, 8'h99, "plus at 99");

        push(SS, 100);   ms(100000);                        // 99 s 数えて鳴る
        expect_st(RING, 8'h00, "99 s -> ring");
        push(SS, 100);   expect_st(SET, 8'h00, "stop while ringing");

        if (errors == 0) $display("PASS");
        else             $display("FAIL: %0d", errors);
        $finish;
    end
endmodule
