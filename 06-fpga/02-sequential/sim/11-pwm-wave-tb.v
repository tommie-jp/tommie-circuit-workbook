// 図 2 の波形を作るテストベンチ。duty を 2 -> 4 -> 6 と、立ち上がりの 1 us 後に変える
module tb_pwm_wave;
    reg        clk;
    reg        rst;
    reg  [3:0] duty;
    wire       out;

    pwm #(.W(3)) u (.clk(clk), .rst(rst), .duty(duty), .out(out));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    initial begin
        $dumpfile("pwm_wave.vcd");
        $dumpvars(0, tb_pwm_wave);
        rst = 1; duty = 4'd2;
        #12 rst = 0;             // 12 us
        #234 duty = 4'd4;        // 246 us
        #160 duty = 4'd6;        // 406 us
        #240 $finish;
    end
endmodule
