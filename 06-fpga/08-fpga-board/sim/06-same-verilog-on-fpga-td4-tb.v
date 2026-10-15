// CLK_HZ = 10 にして、TD4 のクロック (5 Hz の分周) を 1 クロックおきに反転させ、out の並びを見る
module tb_td4;
    reg clk = 0;
    reg rst_n = 0;
    wire [3:0] led_n;
    wire [3:0] out;
    wire       td4_clk;
    integer n = 0;

    top_td4 #(.CLK_HZ(10)) u (.clk(clk), .rst_n(rst_n), .sw_n(4'b1111),
                              .led_n(led_n), .out(out), .td4_clk(td4_clk));

    always #1 clk = ~clk;

    always @(posedge td4_clk) if (rst_n) begin
        #2 $display("after TD4 clock %2d: pc=%h out=%b", n, u.cpu.pc, out);
        n = n + 1;
        if (n == 12) $finish;
    end

    initial #5 rst_n = 1;
endmodule
