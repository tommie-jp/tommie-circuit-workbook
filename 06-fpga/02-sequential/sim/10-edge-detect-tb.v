// tb_edge_detect.v
module tb_edge_detect;
    reg  clk;
    reg  rst;
    reg  in;
    wire rise;
    wire fall;
    integer n_rise;
    integer n_fall;

    edge_detect u (.clk(clk), .rst(rst), .in(in), .rise(rise), .fall(fall));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    // 立ち上がりの直前の rise と fall を数える
    always @(posedge clk) begin
        if (rst) begin
            n_rise <= 0;
            n_fall <= 0;
        end else begin
            if (rise) n_rise <= n_rise + 1;
            if (fall) n_fall <= n_fall + 1;
        end
    end

    // in は立ち上がりの 1 us 後に変える (クロックに同期した信号)
    task hold(input v, input integer clocks);
        begin
            in = v;
            repeat (clocks) @(posedge clk);
            #1;
        end
    endtask

    initial begin
        $dumpfile("edge_detect.vcd");
        $dumpvars(0, tb_edge_detect);
        rst = 1; in = 0;
        #12 rst = 0;                  // 12 us: 立ち上がり (15) の前に放す
        @(posedge clk); #1;           // 15 us の 1 us 後
        hold(0, 2);
        hold(1, 6);                   // 長い 1: rise は 1 回だけ
        hold(0, 3);
        hold(1, 1);                   // 1 クロックだけの 1
        hold(0, 2);
        hold(1, 3);
        hold(0, 3);
        #20;
        $display("rise pulses=%0d fall pulses=%0d", n_rise, n_fall);
        $finish;
    end
endmodule
