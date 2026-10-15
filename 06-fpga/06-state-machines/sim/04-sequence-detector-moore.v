// 系列 1011 の検出 (ムーア型)。出力は状態だけで決まる。
// 最後の 1 は次の検出の最初の 1 に使い回す (重なりを許す)
module seq_moore (
    input        clk,
    input        rst,
    input        din,
    output       detect,
    output [2:0] state
);
    localparam [2:0] S0 = 3'd0,   // 手がかりなし
                     S1 = 3'd1,   // 直前が 1
                     S2 = 3'd2,   // 直前が 10
                     S3 = 3'd3,   // 直前が 101
                     S4 = 3'd4;   // 直前が 1011 (検出)

    reg [2:0] st;
    reg [2:0] next;

    always @(posedge clk)
        if (rst) st <= S0;
        else     st <= next;

    always @(*) begin
        next = st;
        case (st)
            S0:      next = din ? S1 : S0;
            S1:      next = din ? S1 : S2;
            S2:      next = din ? S3 : S0;
            S3:      next = din ? S4 : S2;
            S4:      next = din ? S1 : S2;
            default: next = S0;
        endcase
    end

    assign detect = (st == S4);
    assign state  = st;
endmodule
