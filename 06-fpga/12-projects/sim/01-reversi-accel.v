// リバーシのアクセラレータ。合法手と裏返す石は組み合わせ回路で、
// 最善手は合法手を 1 クロックに 1 つずつ調べて選ぶ (調べる回路は flip_calc 1 つ)
module reversi_accel (
    input             clk,
    input             rst,
    input      [63:0] own,         // 打つ側の石 (探している間は変えない)
    input      [63:0] opp,         // 相手の石
    input      [5:0]  move,        // flip を知りたい手
    input             start,       // 1 にした次のクロックから最善手を探す
    output     [63:0] legal,       // 合法手 (すぐ出る)
    output     [63:0] flip,        // move に打ったとき裏返る石 (すぐ出る)
    output reg        busy,        // 探している間 1
    output reg        done,        // 探し終えたクロックだけ 1
    output reg        found,       // 合法手が 1 つ以上あった
    output reg [5:0]  best,        // 選んだ手
    output reg [4:0]  best_gain    // 選んだ手で裏返る数
);
    localparam [63:0] CORNER = 64'h8100_0000_0000_0081;   // a1 h1 a8 h8

    legal_bb  u_legal (.own(own), .opp(opp), .legal(legal));
    flip_calc u_flip  (.own(own), .opp(opp), .move(move), .flip(flip));

    // 調べ残しの合法手。一番小さい番号から 1 つずつ調べて消す
    reg  [63:0] left;
    wire [63:0] low = left & (~left + 64'd1);   // 一番下の 1 だけ残す

    reg [5:0] cand;             // low の番号 (1 が立つ位置)
    integer i;
    always @(*) begin
        cand = 6'd0;
        for (i = 0; i < 64; i = i + 1)
            if (low[i]) cand = i[5:0];
    end

    wire [63:0] cflip;
    flip_calc u_scan (.own(own), .opp(opp), .move(cand), .flip(cflip));

    reg [4:0] gain;             // 裏返る数 (1 手で多くても 19 個)
    always @(*) begin
        gain = 5'd0;
        for (i = 0; i < 64; i = i + 1)
            gain = gain + {4'd0, cflip[i]};
    end

    // 点数 = 角なら 32 + 裏返る数。同じ点数なら先に調べた (番号の小さい) 手を残す
    wire [5:0] score = {(low & CORNER) != 64'd0, gain};
    reg  [5:0] best_score;

    always @(posedge clk) begin
        done <= 1'b0;
        if (rst) begin
            busy <= 1'b0; found <= 1'b0; best <= 6'd0; best_gain <= 5'd0;
            best_score <= 6'd0; left <= 64'd0;
        end else if (start) begin
            busy <= 1'b1; found <= (legal != 64'd0); best <= 6'd0; best_gain <= 5'd0;
            best_score <= 6'd0; left <= legal;
        end else if (busy) begin
            if (left == 64'd0) begin
                busy <= 1'b0;
                done <= 1'b1;
            end else begin
                if (score > best_score) begin
                    best_score <= score;
                    best       <= cand;
                    best_gain  <= gain;
                end
                left <= left & ~low;
            end
        end
    end
endmodule
