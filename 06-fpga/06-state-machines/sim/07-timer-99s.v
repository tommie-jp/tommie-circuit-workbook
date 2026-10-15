// 99 秒タイマー。設定 (SET)・計数 (RUN)・鳴る (RING) の 3 状態
module timer99 #(
    parameter CLK_HZ  = 1000,        // 5-7 で固定したクロック。1 クロック = 1 ms
    parameter TONE_HZ = 500,         // ブザーの音。1 kHz のクロックで作れるのは 500 Hz まで
    parameter RING_S  = 30,          // 鳴り続けて SET に戻るまでの秒
    parameter DEB_MS  = 20,          // チャタリングを取る長さ (6-3)
    parameter LONG_MS = 500,         // 「+」の長押しで繰り返しが始まるまで (6-6)
    parameter REP_MS  = 100          // 繰り返しの間隔
) (
    input        clk,
    input        rst,
    input        btn_plus_n,         // 「+」。押すと 0
    input        btn_ss_n,           // 「スタート/ストップ」。押すと 0
    output [6:0] seg_tens,           // 10 の位の {g, f, e, d, c, b, a}。1 で点灯
    output [6:0] seg_ones,           // 1 の位
    output       buzzer,             // 圧電サウンダへ。鳴らさない間は 0
    output       sec,                // RUN の間、1 秒の前半だけ 1 (AD3 で 1 秒を測る)
    output [1:0] o_state,            // 試験で見る。ピンには出さない
    output [7:0] o_count             // 残りの秒 {10 の位, 1 の位}。試験で見る
);
    localparam MS     = CLK_HZ / 1000;             // 1 ms のクロック数
    localparam SEC_W  = $clog2(CLK_HZ);
    localparam [SEC_W-1:0] SEC_LAST = CLK_HZ[SEC_W-1:0] - 1'b1;
    localparam [SEC_W-1:0] SEC_HALF = CLK_HZ[SEC_W:1];   // CLK_HZ / 2
    localparam HALF   = (CLK_HZ / (2 * TONE_HZ) > 0) ? CLK_HZ / (2 * TONE_HZ) : 1;
    localparam TONE_W = (HALF > 1) ? $clog2(HALF) : 1;
    localparam [TONE_W-1:0] TONE_LAST = HALF[TONE_W-1:0] - 1'b1;
    localparam RING_W = $clog2(RING_S + 1);
    localparam [RING_W-1:0] RING_LAST = RING_S[RING_W-1:0] - 1'b1;

    localparam [1:0] SET = 2'd0, RUN = 2'd1, RING = 2'd2;

    // ボタン: チャタリングを取り (6-3)、「+」だけ長押しで繰り返す (6-6)
    wire plus_clean_n, plus_press, ss_press, plus_step;
    debounce #(.N(DEB_MS * MS)) u_db_plus (
        .clk(clk), .rst(rst), .btn_n(btn_plus_n), .clean_n(plus_clean_n), .press(plus_press));
    /* verilator lint_off PINCONNECTEMPTY */    // スタート/ストップは押した瞬間だけを使う
    debounce #(.N(DEB_MS * MS)) u_db_ss (
        .clk(clk), .rst(rst), .btn_n(btn_ss_n), .clean_n(), .press(ss_press));
    /* verilator lint_on PINCONNECTEMPTY */
    key_repeat #(.LONG(LONG_MS * MS), .REP(REP_MS * MS)) u_rep (
        .clk(clk), .rst(rst), .clean_n(plus_clean_n), .press(plus_press), .step(plus_step));

    reg [1:0]        state;
    reg [3:0]        tens, ones;     // 残りの秒を 10 進の 2 桁で持つ (12-4 と同じ持ち方)
    reg [SEC_W-1:0]  ms;             // 1 秒の中の何クロック目か
    reg [RING_W-1:0] rang;           // 鳴ってから何秒か
    reg [TONE_W-1:0] tone_cnt;
    reg              tone;

    wire sec_end  = (ms == SEC_LAST);              // 1 秒の最後のクロック
    wire is_zero  = (tens == 4'd0) && (ones == 4'd0);
    wire is_99    = (tens == 4'd9) && (ones == 4'd9);
    wire is_one   = (tens == 4'd0) && (ones == 4'd1);

    // SET で +1 (99 で頭打ち)、RUN で 1 秒ごとに -1。1 の位が 9 → 0 で 10 の位へ桁上げ、0 → 9 で桁借り
    wire up   = (state == SET) && plus_step && !is_99;
    wire down = (state == RUN) && sec_end;

    always @(posedge clk)
        if (rst) begin
            state <= SET;
            tens  <= 4'd0;
            ones  <= 4'd0;
        end else begin
            if (up) begin
                if (ones == 4'd9) begin ones <= 4'd0; tens <= tens + 4'd1; end
                else              ones <= ones + 4'd1;
            end else if (down) begin
                if (ones == 4'd0) begin ones <= 4'd9; tens <= tens - 4'd1; end
                else              ones <= ones - 4'd1;
            end

            case (state)
                SET:  if (ss_press && !is_zero) state <= RUN;         // 00 のままでは始めない
                RUN:  if (ss_press)             state <= SET;         // 一時停止 (残りはそのまま)
                      else if (down && is_one)  state <= RING;        // 01 → 00 になる 1 秒の終わり
                RING: if (ss_press || (sec_end && rang == RING_LAST)) state <= SET;
                default:                        state <= SET;
            endcase
        end

    // 1 秒を数える。SET では 0 に止め、RUN と RING に入った所から数え始める
    always @(posedge clk)
        if (rst || state == SET || (state == RUN && ss_press)) ms <= {SEC_W{1'b0}};
        else if (sec_end)                                       ms <= {SEC_W{1'b0}};
        else                                                    ms <= ms + 1'b1;

    always @(posedge clk)
        if (rst || state != RING) rang <= {RING_W{1'b0}};
        else if (sec_end)         rang <= rang + 1'b1;

    // 音: HALF クロックごとに反転する方形波。1 kHz なら毎クロック反転で 500 Hz
    always @(posedge clk)
        if (rst || state != RING) begin
            tone_cnt <= {TONE_W{1'b0}};
            tone     <= 1'b0;
        end else if (tone_cnt == TONE_LAST) begin
            tone_cnt <= {TONE_W{1'b0}};
            tone     <= ~tone;
        end else
            tone_cnt <= tone_cnt + 1'b1;

    wire half1 = (ms < SEC_HALF);                  // 1 秒の前半
    assign buzzer = tone & half1;                  // 0.5 s 鳴らして 0.5 s 休む
    assign sec    = (state == RUN) && half1;

    seg7dec u_tens (.n(tens), .seg(seg_tens));
    seg7dec u_ones (.n(ones), .seg(seg_ones));

    assign o_state = state;
    assign o_count = {tens, ones};
endmodule
