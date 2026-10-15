module tb_wf; reg clk=0,rst=1,start=0; reg [7:0] a=5,b=3; wire [15:0] p; wire done;
mul_top t(.clk(clk),.rst(rst),.start(start),.a(a),.b(b),.p(p),.done(done));
integer k;
initial begin
 repeat(3) begin #5 clk=1; #5 clk=0; end rst=0;
 for(k=0;k<14;k=k+1) begin
   start = (k==1);
   #1 $display("%2d start=%b st=%0d ld=%b add=%b zero=%b done=%b cnt=%0d acc=%0d",k,start,t.u_ctl.st,t.ld,t.add,t.zero,done,t.u_dp.cnt,p);
   #4 clk=1; #5 clk=0;
 end $finish; end
endmodule
