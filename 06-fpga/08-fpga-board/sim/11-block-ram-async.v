module ramasync #(parameter ABITS = 8, parameter WIDTH = 8) (
    input clk, input we, input [ABITS-1:0] addr, input [WIDTH-1:0] din, output [WIDTH-1:0] dout);
    reg [WIDTH-1:0] mem [0:(1 << ABITS) - 1];
    always @(posedge clk) if (we) mem[addr] <= din;
    assign dout = mem[addr];
endmodule
