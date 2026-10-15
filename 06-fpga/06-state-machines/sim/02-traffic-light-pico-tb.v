// CLK_HZ = 1000 (1 クロック = 1 ms) で 30 s 回す。1.0 s から 0.2 s だけボタンを押す
module tb_top;
    reg clk;
    reg rst;
    reg btn_n;
    wire g, y, r, w;
    wire [1:0] st;

    traffic_top #(.CLK_HZ(1000)) dut (
        .clk(clk), .rst(rst), .btn_n(btn_n),
        .led_green(g), .led_yellow(y), .led_red(r), .led_walk(w), .o_state(st));

    integer ms;
    reg [3:0] last;
    initial begin
        clk = 1'b0; rst = 1'b1; btn_n = 1'b1;
        #1 clk = 1'b1; #1 clk = 1'b0;
        rst = 1'b0;
        last = 4'bxxxx;
        for (ms = 0; ms < 30000; ms = ms + 1) begin
            btn_n = !(ms >= 1000 && ms < 1200);
            #0.5;
            if ({g, y, r, w} !== last)
                $display("%6.3f s  green=%b yellow=%b red=%b walk=%b", ms / 1000.0, g, y, r, w);
            last = {g, y, r, w};
            #0.5 clk = 1'b1; #1 clk = 1'b0;
        end
        $finish;
    end
endmodule
