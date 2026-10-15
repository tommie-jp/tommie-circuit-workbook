module p_rom (
    input        clk,
    input  [3:0] addr,
    output reg [7:0] data
);
    reg [7:0] rom [0:15];
    initial $readmemh("rom.hex", rom);
    always @(posedge clk) data <= rom[addr];
endmodule
