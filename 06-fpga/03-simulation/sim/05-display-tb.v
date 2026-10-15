// tb_display.v
`timescale 1ns/1ps
module tb_display;
    reg        clk;
    reg        rst_n;
    wire [3:0] q;
    integer    fd;

    counter4 dut (.clk(clk), .rst_n(rst_n), .q(q));

    initial clk = 1'b0;
    always #5 clk = ~clk;                         // 周期 10 ns

    initial begin
        $timeformat(-9, 0, " ns", 5);             // %t を「15 ns」の形で出す
        fd = $fopen("log.txt", "w");
        rst_n = 1'b0;
        #1;
        $display("%t rst_n=%b q=%0d (0x%h, 0b%b)", $time, rst_n, q, q, q);

        #11 rst_n = 1'b1;                         // 12 ns でリセットを外す
        repeat (3) begin
            @(posedge clk);
            $display("%t display q=%0d", $time, q);
            $strobe ("%t strobe  q=%0d", $time, q);
            $fdisplay(fd, "%0d", q);              // ファイルへも書ける
        end

        #1;
        $write("write は改行しない: ");
        $write("q=%0d ", q);
        $write("\n");

        $monitor("%t monitor q=%0d", $time, q);   // q が変わるたびに 1 行
        repeat (3) @(posedge clk);
        #1 $monitoroff;                           // 以後は出さない
        @(posedge clk);
        $fclose(fd);
        $finish;
    end
endmodule
