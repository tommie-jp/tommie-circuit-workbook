// DIP の 1 番・2 番の 4 通りで、out (AND・OR・NOT・0) を見る
module tb_gates;
    reg  [3:2] sw_n;
    wire [3:0] led_n;
    wire [3:0] out;
    integer i;

    top_gates u (.sw_n(sw_n), .led_n(led_n), .out(out));

    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            sw_n = ~i[1:0];           // i の 1 のビットの DIP を ON にする
            #1 $display("DIP1=%b DIP2=%b  out=%b (AND OR NOT 0)  led_n=%b", i[1], i[0], out, led_n);
        end
        $finish;
    end
endmodule
