`timescale 1us / 100ns
// 1 kHz のクロックで 5 つの押し方を入れ、short・long・repeat の数を押し方ごとに数える。
// 時刻は最初に押した時刻 (T0 = 100 ms) を 0 として書く
module tb_press;
    reg clk;
    reg rst;
    reg btn_n;
    wire led_s, led_l, led_r;
    wire [1:0] st;
    wire [2:0] p;

    press_top #(.CLK_HZ(1000)) dut (
        .clk(clk), .rst(rst), .btn_n(btn_n),
        .led_short(led_s), .led_long(led_l), .led_repeat(led_r), .o_state(st), .o_pulse(p));

    // クロックの立ち上がりは 0.5 ms・1.5 ms・2.5 ms …
    initial begin
        clk = 1'b0;
        #500;
        forever begin clk = 1'b1; #500; clk = 1'b0; #500; end
    end

    localparam real T0 = 100000.0;           // 100 ms (µs で)
    integer n_s = 0, n_l = 0, n_r = 0;       // いま数えている押し方の分
    integer errors = 0;

    always @(posedge clk) begin
        if (p[2]) begin n_s = n_s + 1; $display("%9.1f ms  short",  ($realtime - T0) / 1000.0); end
        if (p[1]) begin n_l = n_l + 1; $display("%9.1f ms  long",   ($realtime - T0) / 1000.0); end
        if (p[0]) begin n_r = n_r + 1; $display("%9.1f ms  repeat", ($realtime - T0) / 1000.0); end
    end

    always @(led_s or led_l or led_r)
        if (!rst) $display("%9.1f ms    LED short=%b long=%b repeat=%b",
                           ($realtime - T0) / 1000.0, led_s, led_l, led_r);

    // 押し方ごとに数を確かめ、数え直す
    task check(input [8*24-1:0] name, input integer s, input integer l, input integer r);
        begin
            if (n_s == s && n_l == l && n_r == r)
                $display("ok   %0s: short %0d long %0d repeat %0d", name, n_s, n_l, n_r);
            else begin
                $display("NG   %0s: short %0d long %0d repeat %0d (want %0d %0d %0d)",
                         name, n_s, n_l, n_r, s, l, r);
                errors = errors + 1;
            end
            n_s = 0; n_l = 0; n_r = 0;
        end
    endtask

    initial begin
        rst = 1'b1; btn_n = 1'b1;
        #2000 rst = 1'b0;                       // 2 ms でリセットを解く
        #98000;                                 // T0 = 100 ms
        // (1) 短押し 300 ms。押すときに 3.1 ms、離すときに 1.4 ms 跳ねる
        btn_n = 1'b0; #800 btn_n = 1'b1; #800 btn_n = 1'b0; #600 btn_n = 1'b1; #900 btn_n = 1'b0;   // 0〜3.1 ms
        #296900 btn_n = 1'b1; #700 btn_n = 1'b0; #700 btn_n = 1'b1;                                  // 300〜301.4 ms
        #498600 check("short 300 ms", 1, 0, 0);                                                      // 800 ms
        // (2) 長押し 2.5 s。同じように跳ねる
        btn_n = 1'b0; #800 btn_n = 1'b1; #800 btn_n = 1'b0; #600 btn_n = 1'b1; #900 btn_n = 1'b0;   // 800 ms
        #2496900 btn_n = 1'b1; #700 btn_n = 1'b0; #700 btn_n = 1'b1;                                 // 3300 ms
        #698600 check("long 2.5 s", 0, 1, 7);                                                        // 4000 ms
        // (3) 境の手前: 跳ねずに 0.9 s
        btn_n = 1'b0; #900000 btn_n = 1'b1;
        #600000 check("clean 0.9 s", 1, 0, 0);                                                       // 5500 ms
        // (4) 境の後: 跳ねずに 1.1 s (長押しだが繰り返しの前に離す)
        btn_n = 1'b0; #1100000 btn_n = 1'b1;
        #400000 check("clean 1.1 s", 0, 1, 0);                                                       // 7000 ms
        // (5) 5 ms だけの L (ひげ)
        btn_n = 1'b0; #5000 btn_n = 1'b1;
        #500000 check("glitch 5 ms", 0, 0, 0);
        if (errors == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
