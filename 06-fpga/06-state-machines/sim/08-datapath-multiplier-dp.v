// 掛け算のデータパス。数を入れる箱 (レジスタ) と、足し算・引き算だけを持つ。
// 手順は持たない。いつ何をするかは、制御信号 ld と add で外から決まる
module mul_dp #(
    parameter W = 8                  // 被乗数・乗数の幅
) (
    input              clk,
    input              rst,
    input              ld,           // 制御信号: a と b を取り込み、積を 0 にする
    input              add,          // 制御信号: 積に a を足し、残りの回数を 1 減らす
    input  [W-1:0]     a,
    input  [W-1:0]     b,
    output [2*W-1:0]   p,            // 積
    output             zero          // 状態信号: 残りの回数が 0
);
    reg [W-1:0]   a_r;               // 足す数 (取り込んだ a)
    reg [W-1:0]   cnt;               // 残りの回数 (取り込んだ b から 1 ずつ減る)
    reg [2*W-1:0] acc;               // 積を貯める箱

    always @(posedge clk)
        if (rst) begin
            a_r <= {W{1'b0}};
            cnt <= {W{1'b0}};
            acc <= {2*W{1'b0}};
        end else if (ld) begin
            a_r <= a;
            cnt <= b;
            acc <= {2*W{1'b0}};
        end else if (add) begin
            acc <= acc + {{W{1'b0}}, a_r};
            cnt <= cnt - 1'b1;
        end

    assign p    = acc;
    assign zero = (cnt == {W{1'b0}});
endmodule
