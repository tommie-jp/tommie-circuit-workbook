module wf; reg clk=0, rst=1, btn=0; wire r,y,g,w; wire [1:0] s;
traffic_fsm2 #(.GREEN_TIME(5),.YELLOW_TIME(2),.RED_TIME(3),.WALK_TIME(4)) d(.clk(clk),.rst(rst),.btn(btn),.red(r),.yellow(y),.green(g),.walk(w),.state(s));
always #1 clk=~clk; integer i;
initial begin
 @(posedge clk); @(posedge clk); #0.5 rst=0; // after 2 edges
 for(i=0;i<22;i=i+1) begin
   if(i==2) btn=1; else btn=0;
   #0.1;
   $display("%0d btn=%b req=%b done=%b next=%0d state=%0d",i,btn,d.btn_req,d.done,d.next,s);
   @(posedge clk); #0.5;
 end $finish; end
endmodule
