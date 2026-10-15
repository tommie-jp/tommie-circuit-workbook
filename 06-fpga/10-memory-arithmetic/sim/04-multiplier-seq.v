// mul8_seq.v  シフトと加算を 8 回くり返す。8 ビット × 8 ビット = 16 ビット (符号なし)
module mul8_seq (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,    // 1 クロックだけ 1 にする。そのとき a と b を取り込む
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    output reg  [15:0] p,        // 掛け算の結果。done が 1 の間だけ正しい
    output reg         busy,     // 計算中
    output reg         done      // 計算が終わった (1 クロックだけ 1)
);
    reg [15:0] mcand;            // 掛けられる数。1 回ごとに 1 ビット左へずらす
    reg [7:0]  mplier;           // 掛ける数。1 回ごとに 1 ビット右へずらす
    reg [3:0]  n;                // 残りの回数

    always @(posedge clk) begin
        done <= 1'b0;
        if (rst) begin
            p      <= 16'd0;
            busy   <= 1'b0;
            mcand  <= 16'd0;
            mplier <= 8'd0;
            n      <= 4'd0;
        end else if (start && !busy) begin
            p      <= 16'd0;
            mcand  <= {8'd0, a};
            mplier <= b;
            n      <= 4'd8;
            busy   <= 1'b1;
        end else if (busy) begin
            if (mplier[0])
                p <= p + mcand;           // 掛ける数の最下位が 1 なら、足す
            mcand  <= mcand << 1;
            mplier <= mplier >> 1;
            n      <= n - 4'd1;
            if (n == 4'd1) begin          // 8 回目
                busy <= 1'b0;
                done <= 1'b1;
            end
        end
    end
endmodule
