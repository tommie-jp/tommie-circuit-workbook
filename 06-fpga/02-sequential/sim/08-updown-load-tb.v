// tb_updown.v
module tb_updown;
    reg        clk;
    reg        rst;
    reg        load;
    reg  [3:0] d;
    reg        up;
    reg        down;
    wire [3:0] count;

    updown #(.W(4)) u (.clk(clk), .rst(rst), .load(load), .d(d), .up(up), .down(down), .count(count));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    // 立ち上がりの 1 us 後に入力を変え、次の立ち上がりで取り込ませる
    task step(input l, input [3:0] dd, input u_, input dn);
        begin
            load = l; d = dd; up = u_; down = dn;
            @(posedge clk); #1;
            $display("load=%b d=%2d up=%b down=%b -> count=%0d", l, dd, u_, dn, count);
        end
    endtask

    initial begin
        $dumpfile("updown.vcd");
        $dumpvars(0, tb_updown);
        rst = 1; load = 0; d = 0; up = 0; down = 0;
        @(posedge clk); #1 rst = 0;
        step(0, 0, 0, 0);    // 何もしない
        step(1, 5, 0, 0);    // load 5
        step(0, 0, 1, 0);    // up
        step(0, 0, 1, 0);    // up
        step(0, 0, 1, 0);    // up
        step(0, 0, 0, 1);    // down
        step(0, 0, 0, 1);    // down
        step(1, 12, 1, 1);   // load が up と down に勝つ
        step(0, 0, 1, 1);    // up が down に勝つ
        step(1, 15, 0, 0);   // load 15
        step(0, 0, 1, 0);    // up: 15 -> 0
        step(0, 0, 0, 1);    // down: 0 -> 15
        step(0, 0, 0, 0);    // 保持
        #20 $finish;
    end
endmodule
