// 1 つの読み書きポートの RAM。クロックに合わせて書き、クロックに合わせて読む
module ram #(
    parameter ABITS = 8,
    parameter WIDTH = 8
) (
    input                  clk,
    input                  we,
    input      [ABITS-1:0] addr,
    input      [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout
);
    reg [WIDTH-1:0] mem [0:(1 << ABITS) - 1];

    always @(posedge clk) begin
        if (we) mem[addr] <= din;
        dout <= mem[addr];
    end
endmodule
