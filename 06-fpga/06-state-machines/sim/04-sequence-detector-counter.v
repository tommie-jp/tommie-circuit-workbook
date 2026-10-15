// soft-fpga の 01-counter に差し替える用。ポートは元の counter と同じ (clk, rst, count[7:0])。
// 16 ビットの決まった列を 1 クロック 1 ビットずつ入れ、ムーア型とミーリー型の出力を count に並べる
module counter (
    input        clk,
    input        rst,
    output [7:0] count
);
    // 時間の順に 0,1,0,1,1,0,1,1,0,0,1,1,0,1,0,0 (最下位ビットが最初)
    localparam [15:0] PAT = 16'b0010_1100_1101_1010;

    reg  [3:0] phase;
    wire       din = PAT[phase];
    wire       moore;
    wire       mealy;
    wire [2:0] mstate;
    wire [1:0] ystate;

    always @(posedge clk)
        if (rst) phase <= 4'd0;
        else     phase <= phase + 4'd1;

    seq_moore u_moore (.clk(clk), .rst(rst), .din(din), .detect(moore), .state(mstate));
    seq_mealy u_mealy (.clk(clk), .rst(rst), .din(din), .detect(mealy), .state(ystate));

    // b0 = din, b1 = ミーリー, b2 = ムーア, b5:b3 = ムーアの状態, b7:b6 = ミーリーの状態
    assign count = {ystate, mstate, moore, mealy, din};
endmodule
