module tb_counter;
  reg clk=0, rst=1; wire [7:0] c;
  counter d(.clk(clk),.rst(rst),.count(c));
  integer i;
  initial begin
    #1 clk=1; #1 clk=0; rst=0;   // reset applied for one edge
    for (i=0;i<100;i=i+1) begin
      #1; $display("%0d count=%0d din=%b mealy=%b moore=%b ms=%0d ys=%0d", i, c, c[0], c[1], c[2], c[5:3], c[7:6]);
      clk=1; #1 clk=0;
    end
    #1 $display("last count=%0d", c); $finish;
  end
endmodule
