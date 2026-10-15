module tb_blink27m;
    reg clk;
    reg rst;
    wire led;
    integer cycles;
    integer last;
    reg     prev;

    blink u (.clk(clk), .rst(rst), .led(led));    // 既定: CLK_HZ = 27_000_000, BLINK_HZ = 1

    initial clk = 0;
    always #1 clk = ~clk;        // 時間の単位は使わない。数えるのはクロックの回数

    always @(posedge clk) begin
        if (rst) begin
            cycles <= 0; last <= 0; prev <= 1'b0;
        end else begin
            cycles <= cycles + 1;
            prev   <= led;
            if (led !== prev) begin
                $display("led=%b at clock %0d (previous change %0d clocks ago)", led, cycles, cycles - last);
                last <= cycles;
            end
        end
    end

    initial begin
        rst = 1;
        #6 rst = 0;
        #(2 * 55_000_000) $finish;   // 55 M クロック
    end
endmodule
