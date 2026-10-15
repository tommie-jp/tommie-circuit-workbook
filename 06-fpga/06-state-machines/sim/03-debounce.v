// 押しボタン (押すと 0) を 2 段で受け、同じ値が N クロック続いたら採る。
// 押した瞬間に 1 クロックだけ press を 1 にする
module debounce #(
    parameter N = 20                 // 何クロック続いたら採るか (1 kHz なら 20 ms)
) (
    input      clk,
    input      rst,
    input      btn_n,
    output reg clean_n,              // チャタリングを取った値 (押すと 0)
    output     press
);
    localparam W = $clog2(N);
    localparam [W-1:0] LAST = N[W-1:0] - 1'b1;

    reg [1:0]   sync;                // クロックと関係なく変わる入力を 2 段で受ける
    reg [W-1:0] cnt;                 // clean_n と違う値が何クロック続いたか
    reg         clean_d;             // 1 クロック前の clean_n

    always @(posedge clk)
        if (rst) begin
            sync    <= 2'b11;
            cnt     <= {W{1'b0}};
            clean_n <= 1'b1;
        end else begin
            sync <= {sync[0], btn_n};
            if (sync[1] == clean_n)
                cnt <= {W{1'b0}};            // 同じ値に戻ったら数え直す
            else if (cnt == LAST) begin
                clean_n <= sync[1];          // N クロック続いたので採る
                cnt     <= {W{1'b0}};
            end else
                cnt <= cnt + 1'b1;
        end

    always @(posedge clk)
        if (rst) clean_d <= 1'b1;
        else     clean_d <= clean_n;

    assign press = clean_d & ~clean_n;       // 1 → 0 に変わったクロックだけ 1
endmodule
