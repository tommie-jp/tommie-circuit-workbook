// move に打ったとき裏返る相手の石を、1 クロックの組み合わせ回路で出す。
// 打てない手 (埋まっているマス・1 つも挟めない) では 0
module flip_calc (
    input      [63:0] own,
    input      [63:0] opp,
    input      [5:0]  move,
    output reg [63:0] flip
);
    localparam [63:0] NOT_A = 64'hFEFE_FEFE_FEFE_FEFE;
    localparam [63:0] NOT_H = 64'h7F7F_7F7F_7F7F_7F7F;

    function [63:0] step(input [63:0] x, input [2:0] d);   // legal_bb と同じ
        case (d)
            3'd0:    step = (x << 1) & NOT_A;
            3'd1:    step = (x >> 1) & NOT_H;
            3'd2:    step =  x << 8;
            3'd3:    step =  x >> 8;
            3'd4:    step = (x << 9) & NOT_A;
            3'd5:    step = (x << 7) & NOT_H;
            3'd6:    step = (x >> 7) & NOT_A;
            default: step = (x >> 9) & NOT_H;
        endcase
    endfunction

    wire [63:0] m = 64'd1 << move;     // 打つマスだけが 1

    integer d, k;
    reg [63:0] run;

    always @(*) begin
        flip = 64'd0;
        for (d = 0; d < 8; d = d + 1) begin
            run = step(m, d[2:0]) & opp;                    // 打つマスの隣の相手の石
            for (k = 0; k < 5; k = k + 1)
                run = run | (step(run, d[2:0]) & opp);
            if ((step(run, d[2:0]) & own) != 64'd0)         // その先に自分の石があれば挟める
                flip = flip | run;
        end
        if (((own | opp) & m) != 64'd0)                     // 埋まっているマスには打てない
            flip = 64'd0;
    end
endmodule
