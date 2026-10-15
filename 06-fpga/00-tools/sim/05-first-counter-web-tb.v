`timescale 1ns/1ps
module tb;
  reg clk=0, rst=1; wire [7:0] count;
  counter #(.W(8)) dut(.clk(clk),.rst(rst),.count(count));
  integer i;
  initial begin
    #5 rst=0;
    for(i=1;i<=300;i=i+1) begin
      #5 clk=1; #1;
      if (i<=10 || i==255 || i==256|| i==257) $display("clk %0d count=%0d",i,count);
      #4 clk=0;
    end
    $finish;
  end
endmodule
