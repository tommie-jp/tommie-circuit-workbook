// 押しボタン (押すと 0) を 2 段で受け、sample ごとに 2 回続けて 0 なら押したとみなす。
// 押した瞬間に 1 クロックだけ press を 1 にする
module button (
    input      clk,
    input      rst,
    input      sample,
    input      btn_n,
    output reg press
);
    reg [1:0] sync;
    reg [1:0] hist;
    reg       held;

    always @(posedge clk)
        if (rst) begin
            sync  <= 2'b11;
            hist  <= 2'b11;
            held  <= 1'b0;
            press <= 1'b0;
        end else begin
            sync  <= {sync[0], btn_n};
            press <= 1'b0;
            if (sample) begin
                hist <= {hist[0], sync[1]};
                if (hist == 2'b00 && !held) begin
                    held  <= 1'b1;
                    press <= 1'b1;
                end else if (hist == 2'b11) begin
                    held <= 1'b0;
                end
            end
        end
endmodule
