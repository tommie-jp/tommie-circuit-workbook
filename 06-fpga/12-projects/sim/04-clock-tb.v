// CLK_HZ = 1000 にして、1 クロック = 1 ms で 1 日を回す
module tb_clock;
    reg clk = 0;
    reg rst = 1;
    reg btn_hour_n = 1;
    reg btn_min_n  = 1;
    reg sync_n     = 1;
    wire [7:0]  seg;
    wire [3:0]  dig;
    wire        sec;
    wire [23:0] now;
    integer errors = 0;

    clock #(.CLK_HZ(1000), .SCAN_HZ(1000), .BTN_HZ(100)) u (
        .clk(clk), .rst(rst), .btn_hour_n(btn_hour_n), .btn_min_n(btn_min_n), .sync_n(sync_n),
        .seg(seg), .dig(dig), .sec(sec), .now(now));

    always #1 clk = ~clk;                    // 1 周期 = 2 時間単位 = 1 ms とみなす

    task ms(input integer n);
        repeat (n) @(posedge clk);
    endtask

    task expect_now(input [23:0] want, input [8*24-1:0] what);
        if (now !== want) begin
            $display("NG %0s: %h (want %h)", what, now, want);
            errors = errors + 1;
        end else
            $display("ok %0s: %h", what, now);
    endtask

    // 時と分だけ比べる (ボタンを押している間も秒は進む)
    task expect_hm(input [15:0] want, input [8*24-1:0] what);
        if (now[23:8] !== want) begin
            $display("NG %0s: %h (want %h__)", what, now, want);
            errors = errors + 1;
        end else
            $display("ok %0s: %h", what, now);
    endtask

    // 押して 50 ms 待ち、離して 50 ms 待つ。押し始めの 6 ms はチャタリングで 1 ms ごとに暴れる
    localparam HOUR = 0, MIN = 1, SYNC = 2;

    task drive(input integer which, input reg v);
        case (which)
            HOUR:    btn_hour_n = v;
            MIN:     btn_min_n  = v;
            default: sync_n     = v;
        endcase
    endtask

    task press(input integer which);
        integer i;
        begin
            for (i = 0; i < 6; i = i + 1) begin drive(which, i[0]); ms(1); end
            drive(which, 1'b0); ms(50);
            drive(which, 1'b1); ms(50);
        end
    endtask

    initial begin
        ms(3); rst = 0;
        ms(10); expect_now(24'h000000, "after reset");    // 確かめるのは秒の変わり目から 10 ms ずらした所

        // 1 秒めは 0.5 s で来る (half の初期値)。あとは 1000 ms ごと
        ms(500);  expect_now(24'h000001, "0.5 s");
        ms(1000 * 3599); expect_now(24'h010000, "1 hour");
        ms(1000 * (23 * 3600 - 1)); expect_now(24'h235959, "23:59:59");
        ms(1000); expect_now(24'h000000, "midnight");

        // 分のボタン: 分 +1、秒は 0
        ms(1000 * 17);                       // 00:00:17
        press(MIN);  expect_now(24'h000100, "min button");
        // 時のボタンを 23 回: 23 時。もう 1 回で 0 時
        repeat (23) press(HOUR);
        expect_hm(16'h2301, "hour x23");
        press(HOUR); expect_hm(16'h0001, "hour x24");

        // 正時合わせ: 12:29 → 12:00、12:31 → 13:00、23:45 → 00:00
        repeat (12) press(HOUR);
        repeat (28) press(MIN);        // 12:29
        press(SYNC);     expect_hm(16'h1200, "sync 12:29");
        repeat (31) press(MIN);        // 12:31
        press(SYNC);     expect_hm(16'h1300, "sync 12:31");
        repeat (10) press(HOUR);
        repeat (45) press(MIN);        // 23:45
        press(SYNC);     expect_hm(16'h0000, "sync 23:45");

        if (errors == 0) $display("PASS");
        else             $display("FAIL: %0d", errors);
        $finish;
    end
endmodule
