// rom16x8.v  16 語 × 8 ビットの ROM。中身はファイルから読む
module rom16x8 #(
    parameter INIT = "prog.hex"     // 中身のファイル (16 進で 1 行 1 語)
) (
    input  wire [3:0] addr,
    output wire [7:0] data
);
    reg [7:0] mem [0:15];           // 8 ビットの語を 16 個並べた配列

    initial $readmemh(INIT, mem);   // 始める前にファイルから中身を入れる

    assign data = mem[addr];        // 番地を入れれば、すぐ語が出る
endmodule
