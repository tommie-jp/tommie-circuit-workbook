// seg_counter.v: 押しボタンを押すたびに 0〜9 を数え、7 セグに出す
module seg_counter (
    input  wire       clk,
    input  wire       rst,
    input  wire       btn,      // 1 = 押している
    output reg  [3:0] count,    // 0〜9
    output wire [6:0] seg       // {g, f, e, d, c, b, a}。1 で点灯
);
    wire press;
    wire release_unused;

    edge_detect u_edge (
        .clk(clk), .rst(rst), .in(btn),
        .rise(press), .fall(release_unused)
    );

    always @(posedge clk)
        if (rst)
            count <= 4'd0;
        else if (press)
            count <= (count == 4'd9) ? 4'd0 : count + 4'd1;

    seg7_decoder u_dec (.d(count), .seg(seg));
endmodule
