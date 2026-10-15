// 掛け算の制御器 (ムーア型の状態機械)。数は持たない。
// 見るのは start と zero だけ、出すのは ld・add・done だけ
module mul_ctl (
    input      clk,
    input      rst,
    input      start,                // 1 クロックだけ 1 にすると始まる
    input      zero,                 // 状態信号: データパスの残りの回数が 0
    output     ld,                   // 制御信号
    output     add,                  // 制御信号
    output     done                  // 積が出来た (1 クロックだけ 1)
);
    localparam [2:0] S_IDLE = 3'd0,  // 待つ
                     S_LOAD = 3'd1,  // a と b を取り込む
                     S_TEST = 3'd2,  // 残りの回数を調べる
                     S_ADD  = 3'd3,  // 1 回足す
                     S_DONE = 3'd4;  // 終わり

    reg [2:0] st;
    reg [2:0] next;

    always @(posedge clk)
        if (rst) st <= S_IDLE;
        else     st <= next;

    always @(*) begin
        next = st;
        case (st)
            S_IDLE:  if (start) next = S_LOAD;
            S_LOAD:             next = S_TEST;
            S_TEST:  if (zero)  next = S_DONE;
                     else       next = S_ADD;
            S_ADD:              next = S_TEST;
            S_DONE:             next = S_IDLE;
            default:            next = S_IDLE;
        endcase
    end

    assign ld   = (st == S_LOAD);
    assign add  = (st == S_ADD);
    assign done = (st == S_DONE);
endmodule
