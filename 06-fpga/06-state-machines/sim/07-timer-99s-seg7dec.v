// 0 から 9 を 7 セグの a〜g に直す (1-8・12-4 と同じ)。1 が点灯
module seg7dec (
    input      [3:0] n,
    output reg [6:0] seg    // {g, f, e, d, c, b, a}
);
    always @(*)
        case (n)
            4'd0:    seg = 7'b0111111;
            4'd1:    seg = 7'b0000110;
            4'd2:    seg = 7'b1011011;
            4'd3:    seg = 7'b1001111;
            4'd4:    seg = 7'b1100110;
            4'd5:    seg = 7'b1101101;
            4'd6:    seg = 7'b1111101;
            4'd7:    seg = 7'b0000111;
            4'd8:    seg = 7'b1111111;
            4'd9:    seg = 7'b1101111;
            default: seg = 7'b0000000;
        endcase
endmodule
