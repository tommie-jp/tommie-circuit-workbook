// tb_bcd2.v
module tb_bcd2;
    reg        clk;
    reg        rst;
    wire [3:0] ones;
    wire [3:0] tens;
    wire       carry;
    wire       c0 = u.c0;       // 1 の位の桁上げ (10 の位のイネーブル)
    integer    n;

    bcd2 u (.clk(clk), .rst(rst), .en(1'b1), .ones(ones), .tens(tens), .carry(carry));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    initial begin
        $dumpfile("bcd2.vcd");
        $dumpvars(0, tb_bcd2);
        rst = 1;
        #12 rst = 0;                     // 12 us: 立ち上がり (15) の前に放す
        for (n = 1; n <= 101; n = n + 1) begin
            @(posedge clk); #1;
            if (n <= 12 || n >= 98)
                $display("clock %0d: tens=%0d ones=%0d carry=%b", n, tens, ones, carry);
        end
        #20 $finish;
    end
endmodule
