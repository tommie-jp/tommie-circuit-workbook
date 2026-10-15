module tb02;
  reg a,b,c; wire y; integer i, ok=0;
  parity3 d(.a(a),.b(b),.c(c),.y(y));
  initial begin
    $display("a b c y");
    for(i=0;i<8;i=i+1) begin {a,b,c}=i[2:0]; #1; $display("%b %b %b %b",a,b,c,y); if (y===^{a,b,c}) ok=ok+1; end
    $display("parity match %0d/8",ok);
  end
endmodule
