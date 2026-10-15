// top を 27 MHz で回し、PC の代わりに設定を送って、返ってきた 4097 バイトを確かめる。
// 返ってきたバイトは la_dump<N>.txt に 16 進で書く (test_la.py が VCD にして確かめる)
module tb_la;
    reg        clk = 0;
    reg  [7:0] ch = 8'd0;
    reg        rxd = 1;
    wire       txd, txd_mon;
    wire [1:0] led_n;
    integer    errors = 0;

    top dut (.clk(clk), .ch(ch), .rxd(rxd), .txd(txd), .txd_mon(txd_mon), .led_n(led_n));

    always #1 clk = ~clk;

    localparam integer BIT = 234;             // 27 MHz ÷ 115 200 bps
    localparam integer N   = 4096;

    task clocks(input integer n);
        repeat (n) @(posedge clk);
    endtask

    // ---- PC からの送信
    task pc_send(input [7:0] c);
        integer i;
        begin
            rxd = 0; clocks(BIT);
            for (i = 0; i < 8; i = i + 1) begin rxd = c[i]; clocks(BIT); end
            rxd = 1; clocks(BIT);
        end
    endtask

    task arm(input [15:0] div, input [7:0] mask, input [7:0] value, input [7:0] edge_cfg, input [15:0] pre);
        begin
            pc_send("A");
            pc_send(div[15:8]);  pc_send(div[7:0]);
            pc_send(mask);       pc_send(value);    pc_send(edge_cfg);
            pc_send(pre[15:8]);  pc_send(pre[7:0]);
        end
    endtask

    // ---- PC での受信 (ビットの真ん中で読む)
    reg [7:0] got [0:N];
    integer   ngot = 0;
    always begin : rx_pc
        integer b;
        reg [7:0] c;
        @(negedge txd);
        clocks(BIT / 2);
        if (!txd) begin
            for (b = 0; b < 8; b = b + 1) begin clocks(BIT); c[b] = txd; end
            clocks(BIT);
            if (ngot <= N) got[ngot] = c;
            ngot = ngot + 1;
        end
    end

    task wait_dump(input integer timeout_clocks);
        integer t;
        begin
            t = 0;
            while (ngot < N + 1 && t < timeout_clocks) begin clocks(1000); t = t + 1000; end
            clocks(BIT * 2);
        end
    endtask

    task save(input [8*16-1:0] name);
        integer i, fd;
        begin
            fd = $fopen(name, "w");
            for (i = 0; i <= N; i = i + 1) $fdisplay(fd, "%02x", got[i]);
            $fclose(fd);
        end
    endtask

    task check(input cond, input [8*48-1:0] what);
        if (!cond) begin $display("NG %0s", what); errors = errors + 1; end
        else             $display("ok %0s", what);
    endtask

    // ---- 入力の模型
    integer mode = 0;                         // 1: カウンタ  2: パルス列  3: 一定  4: 10 kHz
    integer t_in = 0;
    always @(posedge clk) begin
        t_in <= t_in + 1;
        case (mode)
            1: if (t_in % 27 == 0) ch <= ch + 8'd1;                 // 1 µs ごとに 1 つ進むカウンタ
            2: ch <= {4'b0000, (t_in % 300) < 50, 2'b00, (t_in % 10) < 5};   // ch3 は 300 クロックに 50 クロックの H、ch0 は 2.7 MHz
            3: ch <= 8'h55;
            4: ch <= {7'd0, (t_in % 2700) < 1350};                  // ch0 に 10 kHz の方形波
            default: ch <= 8'd0;
        endcase
    end

    integer i, k, bad, rises, last, gap_bad;
    initial begin
        clocks(20);

        // 1. カウンタを 1 MS/s (div 27) で読み、0x80 になった所でトリガ。前に 1024 個残す
        mode = 1;
        ngot = 0; arm(16'd27, 8'hFF, 8'h80, 8'h00, 16'd1024);
        check(led_n[0] == 1'b0, "1: waiting LED on");
        wait_dump(40_000_000);
        save("la_dump1.txt");
        check(ngot == N + 1 && got[0] == "D", "1: header D + 4096 bytes");
        check(txd_mon === txd, "1: txd_mon = txd");
        check(got[1 + 1024] == 8'h80, "1: sample[1024] = 0x80 (trigger)");
        bad = 0;
        for (i = 0; i < N; i = i + 1) if (got[1 + i] !== 8'h80 + i[7:0]) bad = bad + 1;
        check(bad == 0, "1: 4096 samples count up by 1");
        $display("   sample[1020..1028] = %h %h %h %h %h %h %h %h %h", got[1021], got[1022], got[1023], got[1024],
                 got[1025], got[1026], got[1027], got[1028], got[1029]);

        // 2. 27 MS/s (div 1) で ch3 の立ち上がりにトリガ。前に 100 個
        mode = 2;
        ngot = 0; arm(16'd1, 8'h00, 8'h00, 8'h83, 16'd100);
        wait_dump(40_000_000);
        save("la_dump2.txt");
        check(ngot == N + 1, "2: 4097 bytes");
        check(got[1 + 99][3] == 1'b0 && got[1 + 100][3] == 1'b1, "2: ch3 rises at sample[100]");
        rises = 0; last = -1; gap_bad = 0;
        for (i = 1; i < N; i = i + 1)
            if (!got[i][3] && got[1 + i][3]) begin
                if (last >= 0 && i - last != 300) gap_bad = gap_bad + 1;
                last = i; rises = rises + 1;
            end
        $display("   ch3 rises: %0d (every 300 samples = 90 kHz)", rises);
        check(gap_bad == 0 && rises == 14, "2: ch3 rises every 300 samples, 14 times");

        // 3. 来ないパターン (0xAA) を待たせて、'F' で止める
        mode = 3;
        ngot = 0; arm(16'd1, 8'hFF, 8'hAA, 8'h00, 16'd2000);
        clocks(200_000);
        check(led_n[0] == 1'b0 && ngot == 0, "3: still waiting (0xAA never comes)");
        pc_send("F");
        wait_dump(40_000_000);
        bad = 0;
        for (i = 0; i < N; i = i + 1) if (got[1 + i] !== 8'h55) bad = bad + 1;
        check(ngot == N + 1 && bad == 0, "3: forced, 4096 x 0x55");

        // 4. 100 kS/s (div 270) で 10 kHz の方形波。変わり目は 5 サンプルごと
        mode = 4;
        ngot = 0; arm(16'd270, 8'h00, 8'h00, 8'h80, 16'd0);
        wait_dump(40_000_000);
        save("la_dump4.txt");
        k = 0; last = -1; gap_bad = 0;
        for (i = 1; i < N; i = i + 1)
            if (got[i][0] != got[1 + i][0]) begin
                if (last >= 0 && i - last != 5) gap_bad = gap_bad + 1;
                last = i; k = k + 1;
            end
        $display("   ch0 changes: %0d", k);
        check(got[1][0] == 1'b1 && gap_bad == 0 && k == 819, "4: 10 kHz at 100 kS/s = change every 5 samples");
        check(led_n == 2'b11, "4: LEDs off after sending");

        if (errors == 0) $display("PASS");
        else             $display("FAIL: %0d", errors);
        $finish;
    end
endmodule
