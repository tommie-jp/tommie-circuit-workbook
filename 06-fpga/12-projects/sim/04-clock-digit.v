// 0 から last まで数える 10 進の 1 桁。inc で 1 進み、last の次は 0 に戻って carry を出す
module digit (
    input            clk,
    input            rst,
    input            clr,
    input            inc,
    input      [3:0] last,
    output reg [3:0] q,
    output           carry
);
    assign carry = inc && (q == last);

    always @(posedge clk)
        if (rst || clr)  q <= 4'd0;
        else if (carry)  q <= 4'd0;
        else if (inc)    q <= q + 4'd1;
endmodule
