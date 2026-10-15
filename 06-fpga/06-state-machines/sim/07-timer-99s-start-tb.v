`timescale 1us / 100ns
module tb_short;
  reg clk=0, rst=1, plus_n=1, ss_n=1; wire [6:0] a,b; wire bz,sec; wire [1:0] st; wire [7:0] c;
  timer99 #(.CLK_HZ(1000)) u(.clk(clk),.rst(rst),.btn_plus_n(plus_n),.btn_ss_n(ss_n),.seg_tens(a),.seg_ones(b),.buzzer(bz),.sec(sec),.o_state(st),.o_count(c));
  initial begin clk=0; #500; forever begin clk=1; #500; clk=0; #500; end end
  always @(posedge sec) $display("sec rise at %0.1f ms", $realtime/1000.0);
  always @(st) if(!rst) $display("state %0d at %0.1f ms count=%h", st, $realtime/1000.0, c);
  always @(bz) if (bz) begin $display("bz rise %0.1f ms", $realtime/1000.0); end
  initial begin
    #2000 rst=0; #98000; plus_n=0; #100000 plus_n=1;   // plus at 100 ms
    #100000; // 300 ms
    $display("press ss at %0.1f ms", $realtime/1000.0);
    ss_n=0; #100000 ss_n=1;
    #1600000 $finish;
  end
endmodule
