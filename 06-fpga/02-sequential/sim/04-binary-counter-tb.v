module tb_counter;
    reg clk;
    reg rst;
    wire [7:0] count;
    integer i, k;
    integer toggles [0:7];
    reg [7:0] prev;

    counter #(.W(8)) u (.clk(clk), .rst(rst), .count(count));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, tb_counter);
        for (k = 0; k < 8; k = k + 1) toggles[k] = 0;
        rst = 1;
        #12 rst = 0;                       // 12 us: 立ち上がり (15) の前に放す
        #1;                                // 13 us: 最初の立ち上がり (15) の前
        prev = count;
        for (i = 0; i < 256; i = i + 1) begin
            @(posedge clk); #1;            // 立ち上がりの 1 us 後に読む
            for (k = 0; k < 8; k = k + 1)
                if (count[k] !== prev[k]) toggles[k] = toggles[k] + 1;
            prev = count;
        end
        for (k = 0; k < 8; k = k + 1)
            $display("bit %0d: toggles in 256 clocks = %0d", k, toggles[k]);
        #20 $finish;
    end
endmodule
