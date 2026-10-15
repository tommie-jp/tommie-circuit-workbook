// bad.v  わざと間違いを入れた回路
module bad (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] a,
    input  wire [1:0] sel,
    input  wire       en,
    input  wire       spare,
    output reg  [3:0] y,
    output reg  [3:0] cnt,
    output wire [3:0] z,
    output wire [3:0] w
);
    // 1 幅が合わない: 4 ビットを 3 ビットに入れる
    wire [2:0] narrow;
    assign narrow = a;

    // 2 else の無い if: ラッチになる
    always @(*) begin
        if (en) y = a;
    end

    // 3 case の取りこぼし: sel が 2 と 3 のとき t が決まらない
    reg [3:0] t;
    always @(*) begin
        case (sel)
            2'd0: t = 4'd1;
            2'd1: t = 4'd2;
        endcase
    end

    // 4 クロックで動く always に = を使う
    always @(posedge clk) begin
        if (!rst_n) cnt = 4'd0;
        else        cnt = cnt + 4'd1;
    end

    // 5 宣言していない名前を左辺に書く
    assign flag = a[0];
    assign z = {3'b000, flag};

    // 6 どこからも駆動されない
    wire [3:0] floating;
    assign w = floating | t | {1'b0, narrow};
endmodule
