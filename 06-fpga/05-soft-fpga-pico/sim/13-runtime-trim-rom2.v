module p_rom2 (
    input        clk,
    input  [3:0] addr,
    output reg [7:0] data
);
    reg [7:0] rom [0:15];

    initial begin
`include "rom_init.vh"
    end

    always @(posedge clk) data <= rom[addr];
endmodule
