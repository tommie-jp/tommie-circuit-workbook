// 108 MHz のクロックで div2m を動かし、out の変わり目の間のクロック数を数える
module tb_div2m;
    reg clk = 1'b0;
    reg rst = 1'b1;
    wire out;
    integer n = 0;
    integer last = 0;
    integer toggles = 0;
    reg prev = 1'b0;

    div2m dut (.clk(clk), .rst(rst), .out(out));

    always #1 clk = ~clk;            // 1 周期 = 2 時間単位

    always @(posedge clk) begin
        n <= n + 1;
        prev <= out;
        if (out != prev && toggles < 6) begin
            $display("out=%b  前の変わり目から %0d クロック", out, n - last);
            last <= n;
            toggles <= toggles + 1;
        end
    end

    initial begin
        #10 rst = 1'b0;
        #1000 $finish;
    end
endmodule
