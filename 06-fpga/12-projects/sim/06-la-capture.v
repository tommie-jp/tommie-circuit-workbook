// 8 チャネルを 1 本の輪のメモリ (2^AW 語) に貯め続け、トリガの後ろを決まった数だけ貯めて止まる。
// 止まったとき、輪の中には「トリガの前 pre 個 + トリガの 1 個 + 後ろ 2^AW − 1 − pre 個」が並ぶ
module capture #(
    parameter AW = 12                  // 2^12 = 4096 語
) (
    input               clk,
    input               rst,
    input         [7:0] din,           // ピンから。クロックと関係なく変わる
    input               arm,           // 1 クロック 1 で貯め始める
    input               force_trig,    // 1 クロック 1 でトリガを待たずに止まる方へ進む
    input        [15:0] div,           // div クロックに 1 回読む (1 で 27 MS/s)
    input         [7:0] mask,          // パターン: 1 のチャネルだけ比べる
    input         [7:0] value,         //           比べる値
    input               edge_en,       // 立ち上がりも条件にするか
    input         [2:0] edge_ch,       //           どのチャネルの立ち上がりか
    input      [AW-1:0] pre,           // トリガの前に残す数
    output              waiting,       // トリガを待っている (LED に出す)
    output              done,          // 貯め終えた
    output reg [AW-1:0] start,         // 貯めた並びの頭の番地 (= トリガの番地 − pre)
    input      [AW-1:0] ra,            // 読み出しの番地
    output reg    [7:0] rd             // 読み出した値 (1 クロック遅れ)
);
    localparam [2:0] S_IDLE = 3'd0, S_PRE = 3'd1, S_WAIT = 3'd2, S_POST = 3'd3, S_DONE = 3'd4;

    reg [7:0] mem [0:(1 << AW) - 1];

    // 2 段で受ける (9-2)
    reg [7:0] s1, s2;
    always @(posedge clk) begin
        s1 <= din;
        s2 <= s1;
    end

    // div クロックに 1 回だけ tick を 1 にする
    reg  [15:0] dcnt;
    wire        tick = (dcnt == 16'd0);
    always @(posedge clk)
        if (rst || arm || tick) dcnt <= (div == 16'd0) ? 16'd0 : div - 16'd1;
        else                    dcnt <= dcnt - 16'd1;

    reg [2:0]    state;
    reg [AW-1:0] wa;        // 次に書く番地
    reg [AW-1:0] n;         // PRE では貯めた数、POST では残りの数
    reg [7:0]    prev;      // 1 つ前に読んだ値 (立ち上がりを見る)
    reg          have_prev;
    reg          forced;    // force_trig を受けた (次の tick まで覚えておく)

    wire hit_pat  = ((s2 ^ value) & mask) == 8'd0;
    wire hit_edge = !edge_en || (have_prev && !prev[edge_ch] && s2[edge_ch]);
    wire hit      = hit_pat && hit_edge;

    assign waiting = (state == S_PRE) || (state == S_WAIT);
    assign done    = (state == S_DONE);

    always @(posedge clk) begin
        if (tick && (state == S_PRE || state == S_WAIT || state == S_POST))
            mem[wa] <= s2;
        rd <= mem[ra];
    end

    always @(posedge clk)
        if (rst) begin
            state     <= S_IDLE;
            wa        <= {AW{1'b0}};
            n         <= {AW{1'b0}};
            prev      <= 8'd0;
            have_prev <= 1'b0;
            start     <= {AW{1'b0}};
            forced    <= 1'b0;
        end else if (arm) begin
            state     <= (pre == {AW{1'b0}}) ? S_WAIT : S_PRE;
            wa        <= {AW{1'b0}};
            n         <= {AW{1'b0}};
            have_prev <= 1'b0;
            forced    <= 1'b0;
        end else if (force_trig && waiting) begin
            forced    <= 1'b1;
        end else if (tick) begin
            case (state)
                S_PRE: begin                              // トリガの前の pre 個を先に貯める
                    wa <= wa + 1'b1;
                    n  <= n + 1'b1;
                    if (n + 1'b1 == pre) state <= S_WAIT;
                end
                S_WAIT: begin                             // 輪を回しながらトリガを待つ
                    wa <= wa + 1'b1;
                    if (hit || forced) begin
                        start <= wa - pre;
                        n     <= ~pre;                    // 残り 2^AW − 1 − pre 個
                        state <= (pre == {AW{1'b1}}) ? S_DONE : S_POST;
                        forced <= 1'b0;
                    end
                end
                S_POST: begin
                    wa <= wa + 1'b1;
                    n  <= n - 1'b1;
                    if (n == {{(AW-1){1'b0}}, 1'b1}) state <= S_DONE;
                end
                default: ;
            endcase
            prev      <= s2;
            have_prev <= 1'b1;
        end
endmodule
