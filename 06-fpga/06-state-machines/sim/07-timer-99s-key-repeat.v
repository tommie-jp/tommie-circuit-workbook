// 押した瞬間に 1 回、押し続けて LONG クロック経ったら、あとは REP クロックごとに step を 1 クロック 1 にする
module key_repeat #(
    parameter LONG = 500,            // 繰り返しが始まるまで (1 kHz なら 0.5 s)
    parameter REP  = 100             // 繰り返しの間隔 (1 kHz なら 0.1 s。1 秒に 10 回)
) (
    input      clk,
    input      rst,
    input      clean_n,              // チャタリングを取った値 (押すと 0)
    input      press,                // 押した瞬間の 1 クロック
    output     step
);
    localparam W = $clog2(LONG + 1);
    localparam [W-1:0] LONG_LAST = LONG[W-1:0] - 1'b1;
    localparam [W-1:0] REP_LAST  = REP[W-1:0] - 1'b1;

    reg [W-1:0] hold;                // 押してから、または前の繰り返しから何クロックか
    reg         fast;                // 1 なら繰り返しに入った
    reg         rep;

    always @(posedge clk)
        if (rst || clean_n || press) begin
            hold <= {W{1'b0}};
            fast <= 1'b0;
            rep  <= 1'b0;
        end else if (hold == (fast ? REP_LAST : LONG_LAST)) begin
            hold <= {W{1'b0}};
            fast <= 1'b1;
            rep  <= 1'b1;
        end else begin
            hold <= hold + 1'b1;
            rep  <= 1'b0;
        end

    assign step = press | rep;
endmodule
