module tb06; reg a,b,cin; wire sum,cout; integer i,ok=0;
 full_adder d(.a(a),.b(b),.cin(cin),.sum(sum),.cout(cout));
 initial begin for(i=0;i<8;i=i+1) begin {a,b,cin}=i[2:0]; #1; if({cout,sum}===a+b+cin) ok=ok+1; end $display("sum ok %0d/8",ok); end endmodule
