// sync2.v  外から来る信号を、フリップフロップ 2 段で受ける
module sync2 (
    input  wire clk,
    input  wire d_async,   // クロックと無関係に変わる信号
    output wire q1,        // 1 段目の出力 (観察用に外へ出す)
    output wire q          // 2 段目の出力。中の回路にはこれを使う
);
    reg r1;
    reg r2;

    always @(posedge clk) begin
        r1 <= d_async;     // 1 段目: 窓を破るかもしれない
        r2 <= r1;          // 2 段目: 1 段目が落ち着くのを 1 クロック待つ
    end

    assign q1 = r1;
    assign q  = r2;
endmodule
