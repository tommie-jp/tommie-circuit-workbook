// 系列 1011 の検出 (ミーリー型)。出力は状態と今の入力で決まる。
// 4 つ目のビットが来たそのクロックで detect が 1 になる
module seq_mealy (
    input        clk,
    input        rst,
    input        din,
    output       detect,
    output [1:0] state
);
    localparam [1:0] S0 = 2'd0,   // 手がかりなし
                     S1 = 2'd1,   // 直前が 1
                     S2 = 2'd2,   // 直前が 10
                     S3 = 2'd3;   // 直前が 101

    reg [1:0] st;
    reg [1:0] next;

    always @(posedge clk)
        if (rst) st <= S0;
        else     st <= next;

    always @(*) begin
        next = st;
        case (st)
            S0:      next = din ? S1 : S0;
            S1:      next = din ? S1 : S2;
            S2:      next = din ? S3 : S0;
            S3:      next = din ? S1 : S2;   // 1 なら 1011 の完成。最後の 1 を次の頭に使う
            default: next = S0;
        endcase
    end

    assign detect = (st == S3) && din;
    assign state  = st;
endmodule
