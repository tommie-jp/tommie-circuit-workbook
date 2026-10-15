// 27 MHz の代わりに 1 クロック = 2 時間単位で動かし、out_3m・out_1m・out_100k の H と L のクロック数を数える
module tb_div;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    wire out_3m, out_1m, out_100k;
    integer n = 0;
    integer h3 = 0, l3 = 0, h1 = 0, l1 = 0, hk = 0, lk = 0;

    top_div dut (.clk(clk), .rst_n(rst_n), .out_3m(out_3m), .out_1m(out_1m), .out_100k(out_100k));

    always #1 clk = ~clk;

    always @(posedge clk) if (rst_n) begin
        if (out_3m)   h3 = h3 + 1; else l3 = l3 + 1;
        if (out_1m)   h1 = h1 + 1; else l1 = l1 + 1;
        if (out_100k) hk = hk + 1; else lk = lk + 1;
        n = n + 1;
    end

    initial begin
        #10 rst_n = 1'b1;
        // 2700 クロック = 270 クロック (3 つの周期 9・27・270 の最小公倍数) の 10 倍を数える
        wait (n == 2700);
        $display("out_3m   : H %0d クロック・L %0d クロック (2700 クロックの合計)", h3, l3);
        $display("out_1m   : H %0d クロック・L %0d クロック", h1, l1);
        $display("out_100k : H %0d クロック・L %0d クロック", hk, lk);
        $finish;
    end
endmodule
