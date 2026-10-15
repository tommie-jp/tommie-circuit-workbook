`timescale 1us / 100ns
// 1 kHz のクロックで、跳ねる押し方・きれいな押し方・5 ms のひげを入れる。
// 出力が変わった時刻を書き、press が 2 回 (跳ねる押し方ときれいな押し方) だけ出るかを確かめる
module tb_debounce;
    reg clk;
    reg rst;
    reg btn_n;
    wire led_raw, led_clean, led_hold;

    debounce_top #(.CLK_HZ(1000)) dut (
        .clk(clk), .rst(rst), .btn_n(btn_n),
        .led_raw(led_raw), .led_clean(led_clean), .led_hold(led_hold));

    // クロックの立ち上がりは 0.5 ms・1.5 ms・2.5 ms …
    initial begin
        clk = 1'b0;
        #500;
        forever begin clk = 1'b1; #500; clk = 1'b0; #500; end
    end

    integer presses = 0;
    always @(posedge clk) if (dut.press) presses = presses + 1;

    always @(led_raw or led_clean or led_hold)
        if (!rst) $display("%8.1f ms  raw=%b clean=%b hold=%b", $realtime / 1000.0, led_raw, led_clean, led_hold);

    initial begin
        rst = 1'b1; btn_n = 1'b1;
        #2000 rst = 1'b0;                                  // 2 ms でリセットを解く
        // 跳ねる押し方: 10 ms で押し、3.1 ms のあいだ跳ねる
        #8000  btn_n = 1'b0;   // 10.0 ms
        #800   btn_n = 1'b1;   // 10.8
        #800   btn_n = 1'b0;   // 11.6
        #600   btn_n = 1'b1;   // 12.2
        #900   btn_n = 1'b0;   // 13.1 (ここから押したまま)
        // 200 ms で離し、1.4 ms のあいだ跳ねる
        #186900 btn_n = 1'b1;  // 200.0
        #700   btn_n = 1'b0;   // 200.7
        #700   btn_n = 1'b1;   // 201.4
        // 跳ねない押し方: 400 ms で押し、600 ms で離す
        #198600 btn_n = 1'b0;  // 400.0
        #200000 btn_n = 1'b1;  // 600.0
        // 5 ms だけの L (ひげ): 800 ms
        #200000 btn_n = 1'b0;  // 800.0
        #5000   btn_n = 1'b1;  // 805.0
        #100000;
        $display("press %0d", presses);
        if (presses == 2) $display("PASS");
        else              $display("FAIL");
        $finish;
    end
endmodule
