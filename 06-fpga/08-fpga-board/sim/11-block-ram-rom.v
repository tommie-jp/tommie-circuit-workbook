// 256 語 × 8 ビットの ROM。中身は rom.hex から読む
module rom256 (
    input            clk,
    input      [7:0] addr,
    output reg [7:0] dout
);
    reg [7:0] mem [0:255];

    initial $readmemh("rom.hex", mem);

    always @(posedge clk) dout <= mem[addr];
endmodule
