// maj3.v — 3 入力の多数決。ゲートなら AND 3 個と OR 2 個
module maj3 (
    input  wire a,
    input  wire b,
    input  wire c,
    output wire y
);
    assign y = (a & b) | (b & c) | (a & c);
endmodule
