module tb03;
  reg [1:0] a,b; wire [3:0] cat; wire [1:0] low; wire msb;
  bits d(.a(a),.b(b),.cat(cat),.low(low),.msb(msb));
  integer i; reg [1:0] al[0:3], bl[0:3];
  initial begin
    al[0]=0;al[1]=1;al[2]=2;al[3]=3; bl[0]=0;bl[1]=2;bl[2]=3;bl[3]=1;
    for(i=0;i<4;i=i+1) begin a=al[i];b=bl[i];#1;$display("%x %x %x %x %x",a,b,cat,low,msb); end
  end
endmodule
