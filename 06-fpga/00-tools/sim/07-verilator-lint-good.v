// good.v  bad.v の間違いを直した回路
module good (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] a,
    input  wire [1:0] sel,
    input  wire       en,
    output reg  [3:0] y,
    output reg  [3:0] cnt,
    output wire [3:0] z,
    output wire [3:0] w
);
    // 1 幅をそろえる: 下の 3 ビットを使う、と書く
    wire [2:0] narrow;
    assign narrow = a[2:0];

    // 2 else の代わりに、先に既定値を入れる
    always @(*) begin
        y = 4'd0;
        if (en) y = a;
    end

    // 3 default を書く
    reg [3:0] t;
    always @(*) begin
        case (sel)
            2'd0:    t = 4'd1;
            2'd1:    t = 4'd2;
            default: t = 4'd0;
        endcase
    end

    // 4 クロックで動く always は <= を使う
    always @(posedge clk) begin
        if (!rst_n) cnt <= 4'd0;
        else        cnt <= cnt + 4'd1;
    end

    // 5 宣言する
    wire flag;
    assign flag = a[0];
    assign z = {3'b000, flag};

    // 6 駆動する (使わないなら、消す)
    wire [3:0] floating;
    assign floating = 4'd0;
    assign w = floating | t | {1'b0, narrow};
endmodule
