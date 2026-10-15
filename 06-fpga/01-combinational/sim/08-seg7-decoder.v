// seg7_decoder.v  4 ビットの数 (0〜F) を 7 セグメントの点灯パターンに直す
module seg7_decoder (
    input  wire [3:0] d,
    output reg  [6:0] seg    // {g, f, e, d, c, b, a}。1 で点灯 (共通カソードの並び)
);
    always @(*) begin
        case (d)
            4'h0:    seg = 7'b0111111;
            4'h1:    seg = 7'b0000110;
            4'h2:    seg = 7'b1011011;
            4'h3:    seg = 7'b1001111;
            4'h4:    seg = 7'b1100110;
            4'h5:    seg = 7'b1101101;
            4'h6:    seg = 7'b1111101;
            4'h7:    seg = 7'b0000111;
            4'h8:    seg = 7'b1111111;
            4'h9:    seg = 7'b1101111;
            4'hA:    seg = 7'b1110111;
            4'hB:    seg = 7'b1111100;
            4'hC:    seg = 7'b0111001;
            4'hD:    seg = 7'b1011110;
            4'hE:    seg = 7'b1111001;
            4'hF:    seg = 7'b1110001;
            default: seg = 7'b0000000;
        endcase
    end
endmodule

// seg_e_gates.v  セグメント e だけを、図 1 のゲートのとおりに書いたもの
module seg_e_gates (
    input  wire [3:0] d,
    output wire       e
);
    wire nd2 = ~d[2];
    wire nd0 = ~d[0];
    wire t1  = d[3] & d[2];
    wire t2  = d[3] & d[1];
    wire t3  = nd2 & nd0;
    wire t4  = d[1] & nd0;
    assign e = (t1 | t2) | (t3 | t4);
endmodule

// seg7_cmp.v  case の表と、e のゲート版を並べ、e が同じなら same を 1 にする
module seg7_cmp (
    input  wire [3:0] d,
    output wire [6:0] seg,
    output wire       same
);
    wire e_gates;
    seg7_decoder u_dec (.d(d), .seg(seg));
    seg_e_gates  u_e   (.d(d), .e(e_gates));
    assign same = (seg[4] == e_gates);
endmodule
