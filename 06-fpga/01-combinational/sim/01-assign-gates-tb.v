module tb01;
  reg a,b; wire y_and,y_or,y_not; integer i;
  gates d(.a(a),.b(b),.y_and(y_and),.y_or(y_or),.y_not(y_not));
  initial begin
    $display("a b y_and y_or y_not");
    for(i=0;i<4;i=i+1) begin {a,b}=i[1:0]; #1; $display("%b %b %b %b %b",a,b,y_and,y_or,y_not); end
  end
endmodule
