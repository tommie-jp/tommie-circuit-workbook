// tb_pwm.v
module tb_pwm;
    reg        clk;
    reg        rst;
    reg  [3:0] duty;
    wire       out;
    integer    hi;
    integer    i;
    integer    d;

    pwm #(.W(3)) u (.clk(clk), .rst(rst), .duty(duty), .out(out));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    initial begin
        $dumpfile("pwm.vcd");
        $dumpvars(0, tb_pwm);
        rst = 1; duty = 4'd0;
        #12 rst = 0;                     // 12 us: 立ち上がり (15) の前に放す
        for (d = 0; d <= 8; d = d + 1) begin
            duty = d[3:0];
            @(posedge clk); #1;          // duty が変わった周期の途中を捨てるため 1 周期分進める
            repeat (7) @(posedge clk);
            #1;
            hi = 0;
            for (i = 0; i < 64; i = i + 1) begin
                @(posedge clk);
                if (out) hi = hi + 1;
            end
            $display("duty=%0d/8: out was 1 for %0d of 64 clocks", d, hi);
        end
        #20 $finish;
    end
endmodule
