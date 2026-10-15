// 系列 1011 の検出 (ムーア型、6-4 と同じ 5 状態)。状態の符号を ENC で選ぶ。
//   ENC = 0: 2 進 (000 001 010 011 100)
//   ENC = 1: ワンホット (00001 00010 00100 01000 10000)
//   ENC = 2: グレイ (000 001 011 010 110)
module seq_enc #(
    parameter ENC = 0
) (
    input        clk,
    input        rst,
    input        din,
    output       detect,
    output [4:0] state       // 状態レジスタの中身 (上の桁は 0 で埋める)
);
    localparam integer SW = (ENC == 1) ? 5 : 3;   // 状態レジスタの幅

    // i 番目の状態の符号 (下位 5 ビット。幅が SW の符号は下位 SW ビット)
    function [4:0] code(input integer i);
        case (ENC)
            1:       code = 5'b00001 << i;
            2:       code = i[4:0] ^ (i[4:0] >> 1);
            default: code = i[4:0];
        endcase
    endfunction

    localparam [4:0] C0 = code(0), C1 = code(1), C2 = code(2), C3 = code(3), C4 = code(4);
    localparam [SW-1:0] S0 = C0[SW-1:0],   // 手がかりなし
                        S1 = C1[SW-1:0],   // 直前が 1
                        S2 = C2[SW-1:0],   // 直前が 10
                        S3 = C3[SW-1:0],   // 直前が 101
                        S4 = C4[SW-1:0];   // 直前が 1011 (検出)

    reg [SW-1:0] st;
    reg [SW-1:0] next;

    always @(posedge clk)
        if (rst) st <= S0;
        else     st <= next;

    always @(*) begin
        next = st;
        case (st)
            S0:      next = din ? S1 : S0;
            S1:      next = din ? S1 : S2;
            S2:      next = din ? S3 : S0;
            S3:      next = din ? S4 : S2;
            S4:      next = din ? S1 : S2;
            default: next = S0;          // 定義していない符号に落ちたら S0 へ戻す
        endcase
    end

    assign detect = (st == S4);
    assign state  = {{(5 - SW){1'b0}}, st};
endmodule
