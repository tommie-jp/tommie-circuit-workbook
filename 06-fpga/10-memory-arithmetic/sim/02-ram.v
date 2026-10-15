// ram16x8.v  16 語 × 8 ビットの RAM。書くのも読むのもクロックの立ち上がり
module ram16x8 (
    input  wire       clk,
    input  wire       we,        // 1 のとき、この立ち上がりで addr に wdata を書く
    input  wire [3:0] addr,
    input  wire [7:0] wdata,
    output reg  [7:0] rdata
);
    reg [7:0] mem [0:15];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= wdata;
        rdata <= mem[addr];      // 読んだ語は、次の立ち上がりまで rdata に残る
    end
endmodule
