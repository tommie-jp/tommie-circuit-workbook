// Pong — CPU を使わず、カウンタと比較器だけで球とラケットを描く。
// 1 クロックで 1 画素。横 160 × 縦 120 画素を左上から順に出し、1 画面の終わりで球とラケットを 1 回動かす
module pong (
    input        clk,
    input        rst,
    input        up_l, dn_l,       // 左のラケット。押している間 1
    input        up_r, dn_r,       // 右のラケット
    input        auto_l, auto_r,   // 1 ならラケットが球を追う (相手がいなくても遊べる)
    output [7:0] hpos,             // いま出している画素の横 (0〜159)
    output [6:0] vpos,             // 縦 (0〜119)
    output       pixel,            // 1 なら白
    output       line_end,         // 行の最後の画素で 1
    output       frame_end,        // 画面の最後の画素で 1
    output [3:0] score_l,
    output [3:0] score_r
);
    localparam [7:0] W = 8'd160;
    localparam [6:0] H = 7'd120;
    localparam [6:0] TOP = 7'd2, BOTTOM = 7'd118;    // 上下の壁の内側
    localparam [6:0] PH = 7'd16;                      // ラケットの長さ
    localparam [7:0] LX = 8'd6, RX = 8'd151;          // ラケットの左端の横位置 (幅 3)
    localparam [7:0] BS = 8'd3;                       // 球の大きさ (3 × 3)

    // ---- 画素のカウンタ ----
    reg [7:0] h;
    reg [6:0] v;
    assign hpos      = h;
    assign vpos      = v;
    assign line_end  = (h == W - 8'd1);
    assign frame_end = line_end && (v == H - 7'd1);

    always @(posedge clk)
        if (rst)            begin h <= 8'd0; v <= 7'd0; end
        else if (frame_end) begin h <= 8'd0; v <= 7'd0; end
        else if (line_end)  begin h <= 8'd0; v <= v + 7'd1; end
        else                      h <= h + 8'd1;

    // ---- 球とラケットの位置 (左上の角) ----
    reg [7:0] bx;
    reg [6:0] by;
    reg       left, up, fast;          // 球の向き: 左へ・上へ・縦に 2 画素ずつ
    reg [6:0] pl, pr;                  // ラケットの上端
    reg [3:0] sl, sr;                  // 点 (0〜9)
    assign score_l = sl;
    assign score_r = sr;

    wire [6:0] dy = fast ? 7'd2 : 7'd1;
    wire [6:0] bc = by + 7'd1;         // 球の縦の真ん中

    // 球がラケットの縦の範囲に入っているか
    wire on_l = (by + 7'd3 > pl) && (by < pl + PH);
    wire on_r = (by + 7'd3 > pr) && (by < pr + PH);
    // 球がラケットの横の位置まで来たか (横に 2 画素ずつ進むので 2 画素の幅で見る)
    wire at_l = left  && (bx >= LX + 8'd1) && (bx <= LX + 8'd3);
    wire at_r = !left && (bx + BS >= RX)    && (bx + BS <= RX + 8'd2);
    wire hit_l = at_l && on_l;
    wire hit_r = at_r && on_r;
    wire out_l = left  && (bx < 8'd2);              // 左の端を越えた → 右の点
    wire out_r = !left && (bx + BS > W - 8'd2);     // 右の端を越えた → 左の点

    // ラケットの端の 4 画素に当たると縦に速くなり、上半分なら上へ、下半分なら下へ返す
    function [1:0] bounce(input [6:0] p);           // {fast, up}
        bounce = {(bc < p + 7'd4) || (bc >= p + PH - 7'd4), bc < p + 7'd8};
    endfunction

    // ラケットを 1 画面ぶん動かす。auto なら球の真ん中を 1 画素ずつ追い、手で動かすときは 2 画素ずつ
    function [6:0] paddle(input [6:0] p, input u, input d, input auto);
        reg [6:0] q;
        begin
            q = p;
            if (auto) begin
                if      (bc < p + 7'd8 && p > TOP)          q = p - 7'd1;
                else if (bc > p + 7'd8 && p < BOTTOM - PH)  q = p + 7'd1;
            end else begin
                if      (u && p >= TOP + 7'd2)              q = p - 7'd2;
                else if (d && p + 7'd2 <= BOTTOM - PH)      q = p + 7'd2;
            end
            paddle = q;
        end
    endfunction

    always @(posedge clk)
        if (rst) begin
            bx <= 8'd78; by <= 7'd58; left <= 1'b1; up <= 1'b0; fast <= 1'b0;
            pl <= 7'd52; pr <= 7'd52; sl <= 4'd0; sr <= 4'd0;
        end else if (frame_end) begin
            pl <= paddle(pl, up_l, dn_l, auto_l);
            pr <= paddle(pr, up_r, dn_r, auto_r);

            // 横: 当たれば向きを返す。外れたら点を足して真ん中から打ち直す (点を取られた側へ)
            if (out_l || out_r) begin
                if (out_l) sr <= (sr == 4'd9) ? 4'd0 : sr + 4'd1;
                else       sl <= (sl == 4'd9) ? 4'd0 : sl + 4'd1;
                bx <= 8'd78; by <= 7'd58; fast <= 1'b0; up <= !up;
            end else begin
                if (hit_l)      begin left <= 1'b0; {fast, up} <= bounce(pl); bx <= bx + 8'd2; end
                else if (hit_r) begin left <= 1'b1; {fast, up} <= bounce(pr); bx <= bx - 8'd2; end
                else            bx <= left ? bx - 8'd2 : bx + 8'd2;

                // 縦: 上下の壁で返す
                if (up) begin
                    if (by <= TOP + dy - 7'd1) begin up <= 1'b0; by <= TOP; end
                    else                         by <= by - dy;
                end else begin
                    if (by + 7'd3 + dy >= BOTTOM) begin up <= 1'b1; by <= BOTTOM - 7'd3; end
                    else                            by <= by + dy;
                end
            end
        end

    // ---- 絵: いまの (h, v) が何かの形の中にあるかを、比較器で調べる ----
    wire wall   = (v < TOP) || (v >= BOTTOM);
    wire net    = (h == 8'd79) && v[2];                                   // 4 画素おきの点線
    wire racket = ((h >= LX) && (h < LX + 8'd3) && (v >= pl) && (v < pl + PH))
               || ((h >= RX) && (h < RX + 8'd3) && (v >= pr) && (v < pr + PH));
    wire ball   = (h >= bx) && (h < bx + BS) && (v >= by) && (v < by + 7'd3);

    // 点は 7 セグの形 (横 8 × 縦 14 画素) で、左の点を x = 60、右の点を x = 92、y = 6 から描く
    function [6:0] seg7(input [3:0] n);                // {g, f, e, d, c, b, a} (1-8 と同じ)
        case (n)
            4'd0: seg7 = 7'b0111111;  4'd1: seg7 = 7'b0000110;
            4'd2: seg7 = 7'b1011011;  4'd3: seg7 = 7'b1001111;
            4'd4: seg7 = 7'b1100110;  4'd5: seg7 = 7'b1101101;
            4'd6: seg7 = 7'b1111101;  4'd7: seg7 = 7'b0000111;
            4'd8: seg7 = 7'b1111111;  4'd9: seg7 = 7'b1101111;
            default: seg7 = 7'b0000000;
        endcase
    endfunction

    function digit(input [3:0] n, input [7:0] x0, input [7:0] x, input [6:0] y);
        reg [6:0] s;
        reg [7:0] dx;
        reg [6:0] dy7;
        begin
            s = seg7(n);
            dx = x - x0;
            dy7 = y - 7'd6;
            if (x < x0 || x >= x0 + 8'd8 || y < 7'd6 || y >= 7'd20) digit = 1'b0;
            else digit = (s[0] && dy7 <= 7'd1)                                 // a
                      || (s[1] && dx >= 8'd6 && dy7 <= 7'd7)                   // b
                      || (s[2] && dx >= 8'd6 && dy7 >= 7'd6)                   // c
                      || (s[3] && dy7 >= 7'd12)                                // d
                      || (s[4] && dx <= 8'd1 && dy7 >= 7'd6)                   // e
                      || (s[5] && dx <= 8'd1 && dy7 <= 7'd7)                   // f
                      || (s[6] && dy7 >= 7'd6 && dy7 <= 7'd7);                 // g
        end
    endfunction

    wire score = digit(sl, 8'd60, h, v) || digit(sr, 8'd92, h, v);

    assign pixel = wall || net || racket || ball || score;
endmodule
