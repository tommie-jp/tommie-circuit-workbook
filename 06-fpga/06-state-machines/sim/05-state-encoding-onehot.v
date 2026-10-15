// 系列 1011 の検出 (ムーア型) をワンホットらしく書いた物。
// 状態の名前ごとに 1 ビットを持ち、「次にそのビットが 1 になる条件」を直接書く
module seq_onehot (
    input        clk,
    input        rst,
    input        din,
    output       detect,
    output [4:0] state
);
    // st[0] = S0 手がかりなし、st[1] = S1 直前が 1、st[2] = S2 直前が 10、
    // st[3] = S3 直前が 101、st[4] = S4 直前が 1011 (検出)
    reg [4:0] st;

    wire [4:0] next;
    assign next[0] = ~din & (st[0] | st[2]);          // S0 か S2 で 0 が来た
    assign next[1] =  din & (st[0] | st[1] | st[4]);  // S0・S1・S4 で 1 が来た
    assign next[2] = ~din & (st[1] | st[3] | st[4]);  // S1・S3・S4 で 0 が来た
    assign next[3] =  din & st[2];                    // S2 で 1 が来た
    assign next[4] =  din & st[3];                    // S3 で 1 が来た

    always @(posedge clk)
        if (rst) st <= 5'b00001;
        else     st <= next;

    assign detect = st[4];
    assign state  = st;
endmodule
