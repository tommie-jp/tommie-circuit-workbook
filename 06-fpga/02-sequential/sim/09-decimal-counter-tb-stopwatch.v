// tb_stopwatch.v
module tb_stopwatch;
    reg        clk;
    reg        rst;
    wire [6:0] seg_ones;
    wire [6:0] seg_tens;
    integer    n;
    integer    sec;

    stopwatch #(.CLK_HZ(4)) u (.clk(clk), .rst(rst), .seg_ones(seg_ones), .seg_tens(seg_tens));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    initial begin
        rst = 1;
        #12 rst = 0;                     // 12 us: 立ち上がり (15) の前に放す
        // CLK_HZ = 4 なので 4 クロックが 1 秒。4 x 秒 のあと、立ち上がりの 1 us 後に読む
        for (n = 1; n <= 4 * 100 + 4; n = n + 1) begin
            @(posedge clk); #1;
            if (n % 4 == 0) begin
                sec = n / 4;
                if (sec <= 11 || sec >= 98)
                    $display("sec=%0d tens=%07b ones=%07b", sec, seg_tens, seg_ones);
            end
        end
        #20 $finish;
    end
endmodule
