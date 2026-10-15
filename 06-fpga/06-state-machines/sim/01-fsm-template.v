// 4-4 の信号機を、状態のレジスタと次の状態の case に分けて書き直す
module traffic_fsm2 #(
    parameter W           = 10,   // timer の幅 (いちばん長い時間が入る幅)
    parameter GREEN_TIME  = 500,  // 各状態の長さ (クロック数)
    parameter YELLOW_TIME = 100,
    parameter RED_TIME    = 300,
    parameter WALK_TIME   = 400
) (
    input            clk,
    input            rst,
    input            btn,
    output           red,
    output           yellow,
    output           green,
    output           walk,
    output reg [1:0] state
);
    localparam [1:0] S_GREEN  = 2'd0;
    localparam [1:0] S_YELLOW = 2'd1;
    localparam [1:0] S_RED    = 2'd2;
    localparam [1:0] S_WALK   = 2'd3;

    localparam [W-1:0] T_GREEN  = GREEN_TIME[W-1:0]  - 1'b1;
    localparam [W-1:0] T_YELLOW = YELLOW_TIME[W-1:0] - 1'b1;
    localparam [W-1:0] T_RED    = RED_TIME[W-1:0]    - 1'b1;
    localparam [W-1:0] T_WALK   = WALK_TIME[W-1:0]   - 1'b1;

    reg [1:0]   next;
    reg [W-1:0] timer;
    reg         btn_req;
    wire        done = (timer == {W{1'b0}});

    // (1) 状態のレジスタ: クロックの立ち上がりで next を取り込むだけ
    always @(posedge clk)
        if (rst) state <= S_GREEN;
        else     state <= next;

    // (2) 次の状態: 今の状態と入力から、組み合わせ回路で決める
    always @(*) begin
        next = state;                 // 矢印に当たらなければ今の状態のまま
        case (state)
            S_GREEN:  if (done) next = S_YELLOW;
            S_YELLOW: if (done) next = btn_req ? S_WALK : S_RED;
            S_RED:    if (done) next = S_GREEN;
            S_WALK:   if (done) next = S_GREEN;
            default:            next = S_GREEN;
        endcase
    end

    // (3) 状態に付いた時間: 状態が変わるクロックで次の状態の長さを入れ、ほかは 1 ずつ減らす
    always @(posedge clk)
        if (rst)
            timer <= T_GREEN;
        else if (next != state)
            case (next)
                S_GREEN:  timer <= T_GREEN;
                S_YELLOW: timer <= T_YELLOW;
                S_RED:    timer <= T_RED;
                default:  timer <= T_WALK;
            endcase
        else
            timer <= timer - 1'b1;

    // 歩行者ボタンの記憶: 押したら 1、WALK が終わるクロックで 0
    always @(posedge clk)
        if (rst)                         btn_req <= 1'b0;
        else if (state == S_WALK && done) btn_req <= 1'b0;
        else if (btn)                    btn_req <= 1'b1;

    // (4) 出力: 今の状態だけで決まる
    assign green  = (state == S_GREEN);
    assign yellow = (state == S_YELLOW);
    assign red    = (state == S_RED) || (state == S_WALK);
    assign walk   = (state == S_WALK);
endmodule

