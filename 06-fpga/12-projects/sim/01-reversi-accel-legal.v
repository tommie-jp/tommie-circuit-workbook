// 合法手の地図を 1 クロックの組み合わせ回路で出す。
// 盤は 64 ビット。番号 = 行 * 8 + 列 (a1 が 0、h1 が 7、a8 が 56、h8 が 63)
module legal_bb (
    input      [63:0] own,      // 打つ側の石
    input      [63:0] opp,      // 相手の石
    output reg [63:0] legal     // 打てるマスが 1
);
    localparam [63:0] NOT_A = 64'hFEFE_FEFE_FEFE_FEFE;   // a 列 (左端) を消す
    localparam [63:0] NOT_H = 64'h7F7F_7F7F_7F7F_7F7F;   // h 列 (右端) を消す

    // 盤の全部の石を、方向 d へ 1 マス進める。端からはみ出した石は消す
    function [63:0] step(input [63:0] x, input [2:0] d);
        case (d)
            3'd0:    step = (x << 1) & NOT_A;   // 東 (列 +1)
            3'd1:    step = (x >> 1) & NOT_H;   // 西 (列 -1)
            3'd2:    step =  x << 8;            // 南 (行 +1)
            3'd3:    step =  x >> 8;            // 北 (行 -1)
            3'd4:    step = (x << 9) & NOT_A;   // 南東
            3'd5:    step = (x << 7) & NOT_H;   // 南西
            3'd6:    step = (x >> 7) & NOT_A;   // 北東
            default: step = (x >> 9) & NOT_H;   // 北西
        endcase
    endfunction

    wire [63:0] empty = ~(own | opp);

    integer d, k;
    reg [63:0] run;     // 自分の石から d の向きに続く相手の石

    always @(*) begin
        legal = 64'd0;
        for (d = 0; d < 8; d = d + 1) begin
            run = step(own, d[2:0]) & opp;                  // 隣が相手の石
            for (k = 0; k < 5; k = k + 1)
                run = run | (step(run, d[2:0]) & opp);      // 相手の石を辿る (6 個まで)
            legal = legal | (step(run, d[2:0]) & empty);    // その先が空きなら打てる
        end
    end
endmodule
