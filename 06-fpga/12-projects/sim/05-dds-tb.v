// top を 27 MHz のクロックで回し、周波数・ボタン・UART の設定を確かめる。
// 最後に 65 536 クロック分の dac を 1 MHz と 100 kHz の 2 通り書く (fft.py でスペクトルを見る)
module tb_dds;
    reg  clk = 0;
    reg  btn_n = 1;
    reg  rxd = 1;
    wire [7:0] dac;
    wire       sync;
    integer errors = 0;

    top dut (.clk(clk), .btn_n(btn_n), .rxd(rxd), .dac(dac), .sync(sync));

    always #1 clk = ~clk;                       // 1 周期 = 1 クロック (27 MHz とみなす)

    task clocks(input integer n);
        repeat (n) @(posedge clk);
    endtask

    // n クロックの間に sync が立ち上がった回数を数え、ftw から出る数と比べる
    task count_sync(input integer n, input [8*16-1:0] what);
        integer i, edges;
        reg prev;
        real want;
        begin
            edges = 0;
            prev  = sync;
            for (i = 0; i < n; i = i + 1) begin
                @(posedge clk);
                if (sync && !prev) edges = edges + 1;
                prev = sync;
            end
            want = n * (dut.ftw / 4294967296.0);
            if (edges < want - 1.0 || edges > want + 1.0) begin
                $display("NG %0s: ftw=%0d  %0d edges in %0d clocks (want %.2f)", what, dut.ftw, edges, n, want);
                errors = errors + 1;
            end else
                $display("ok %0s: ftw=%0d  %0d edges in %0d clocks (want %.2f) -> %.3f Hz",
                         what, dut.ftw, edges, n, want, dut.ftw * 27.0e6 / 4294967296.0);
        end
    endtask

    task expect_ftw(input [31:0] want, input [8*16-1:0] what);
        if (dut.ftw !== want) begin
            $display("NG %0s: ftw=%h (want %h)", what, dut.ftw, want);
            errors = errors + 1;
        end else
            $display("ok %0s: ftw=%h", what, dut.ftw);
    endtask

    // 押して 50 ms、離して 50 ms (12-4 と同じ)
    task press;
        begin
            btn_n = 0; clocks(27_000 * 50);
            btn_n = 1; clocks(27_000 * 50);
        end
    endtask

    // 9600 bps (1 ビット 2812 クロック) で 1 字送る
    task send(input [7:0] c);
        integer i;
        begin
            rxd = 0; clocks(2812);
            for (i = 0; i < 8; i = i + 1) begin rxd = c[i]; clocks(2812); end
            rxd = 1; clocks(2812 * 2);
        end
    endtask

    task send_str(input [8*20-1:0] s, input integer n);
        integer i;
        for (i = n - 1; i >= 0; i = i - 1) send(s[8*i +: 8]);
    endtask

    integer i, fd;
    reg [7:0] lo, hi;
    initial begin
        clocks(20);

        // 1. 電源を入れた直後は 1 kHz。1 周期で 0 から 255 まで出るか
        expect_ftw(32'd159073, "reset = 1 kHz");
        lo = 255; hi = 0;
        for (i = 0; i < 27_000; i = i + 1) begin
            @(posedge clk);
            if (dac < lo) lo = dac;
            if (dac > hi) hi = dac;
        end
        if (lo != 0 || hi != 255) begin
            $display("NG dac range: %0d..%0d", lo, hi); errors = errors + 1;
        end else
            $display("ok dac range: %0d..%0d", lo, hi);

        // 2. 4 つのプリセットの周波数を 0.1 s (2 700 000 クロック) で数える
        count_sync(2_700_000, "1 kHz");
        press; expect_ftw(32'd1590729,   "button 1");   count_sync(2_700_000, "10 kHz");
        press; expect_ftw(32'd15907286,  "button 2");   count_sync(2_700_000, "100 kHz");
        press; expect_ftw(32'd159072863, "button 3");   count_sync(2_700_000, "1 MHz");
        press; expect_ftw(32'd159073,    "button 4");

        // 3. UART: 16 進 8 桁 + CR LF。440 Hz を 1 s (27 000 000 クロック) で数える
        send_str("00011168\r\n", 10); clocks(100);
        expect_ftw(32'h00011168, "uart 440 Hz");
        count_sync(27_000_000, "440 Hz");

        // 4. 受け付けない形
        send_str("1234567\r", 8);   clocks(100); expect_ftw(32'h00011168, "7 digits");
        send_str("0001116G\r", 9);  clocks(100); expect_ftw(32'h00011168, "not hex");
        send_str("ffff097B0000\r", 13); clocks(100); expect_ftw(32'h097B0000, "last 8 of 12");

        // 5. ftw = 2427 × 65 536 (1.000 MHz に近い)。65 536 クロックで表をちょうど 2427 周する
        clocks(10);
        fd = $fopen("dds_samples.txt", "w");
        for (i = 0; i < 65536; i = i + 1) begin
            @(posedge clk);
            $fdisplay(fd, "%0d", dac);
        end
        $fclose(fd);
        $display("wrote dds_samples.txt (65536 samples, ftw=%h)", dut.ftw);

        // 6. ftw = 243 × 65 536 (100.1 kHz)。同じく dds_samples_100k.txt に
        send_str("00F30000\r", 9); clocks(100);
        expect_ftw(32'h00F30000, "uart 100.1 kHz");
        fd = $fopen("dds_samples_100k.txt", "w");
        for (i = 0; i < 65536; i = i + 1) begin
            @(posedge clk);
            $fdisplay(fd, "%0d", dac);
        end
        $fclose(fd);
        $display("wrote dds_samples_100k.txt (65536 samples, ftw=%h)", dut.ftw);

        if (errors == 0) $display("PASS");
        else             $display("FAIL: %0d", errors);
        $finish;
    end
endmodule
