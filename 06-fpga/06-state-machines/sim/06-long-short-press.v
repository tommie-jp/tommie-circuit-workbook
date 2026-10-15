// 押している長さで、短押し・長押し・繰り返しを分ける状態機械。
// pressed は 6-3 の debounce を通した値 (押している間 1)。出力は 1 クロックだけ 1 のパルス
module press_fsm #(
    parameter CLK_HZ    = 1000,   // クロックの周波数 (1000 の倍数にする)
    parameter LONG_MS   = 1000,   // これだけ押し続けたら長押し
    parameter REPEAT_MS = 200,    // 長押しの後、押し続ける間 repeat を出す間隔
    parameter W         = 16      // timer の幅 (LONG_MS のクロック数が入る幅)
) (
    input            clk,
    input            rst,
    input            pressed,
    output           short_p,     // 1 秒より前に離した
    output           long_p,      // 1 秒押し続けた
    output           repeat_p,    // 長押しの後、0.2 秒ごと
    output reg [1:0] state
);
    localparam [1:0] S_IDLE  = 2'd0;   // 待つ
    localparam [1:0] S_PRESS = 2'd1;   // 押している (長押しになるまで数える)
    localparam [1:0] S_HOLD  = 2'd2;   // 長押しの後も押している

    localparam integer LONG_CYC   = CLK_HZ / 1000 * LONG_MS;
    localparam integer REPEAT_CYC = CLK_HZ / 1000 * REPEAT_MS;
    localparam [W-1:0] T_LONG   = LONG_CYC[W-1:0]   - 1'b1;
    localparam [W-1:0] T_REPEAT = REPEAT_CYC[W-1:0] - 1'b1;

    reg [1:0]   next;
    reg [W-1:0] timer;                 // 今の状態に入ってから (HOLD では前の repeat から) 何クロックか
    wire long_done   = (state == S_PRESS) && (timer == T_LONG);
    wire repeat_done = (state == S_HOLD)  && (timer == T_REPEAT);

    // (1) 状態のレジスタ
    always @(posedge clk)
        if (rst) state <= S_IDLE;
        else     state <= next;

    // (2) 次の状態
    always @(*) begin
        next = state;
        case (state)
            S_IDLE:  if (pressed)        next = S_PRESS;
            S_PRESS: if (!pressed)       next = S_IDLE;
                     else if (long_done) next = S_HOLD;
            S_HOLD:  if (!pressed)       next = S_IDLE;
            default:                     next = S_IDLE;
        endcase
    end

    // (3) 状態に付いた時間: 状態が変わるクロックと repeat を出したクロックで 0 に戻す
    always @(posedge clk)
        if (rst || state == S_IDLE || next != state || repeat_done)
            timer <= {W{1'b0}};
        else
            timer <= timer + 1'b1;

    // (4) 出力: 状態と入力で決まる (ミーリー型)。どれも 1 クロックだけ 1
    assign short_p  = (state == S_PRESS) && !pressed;
    assign long_p   = long_done   && pressed;
    assign repeat_p = repeat_done && pressed;
endmodule
